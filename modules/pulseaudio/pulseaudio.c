#define _GNU_SOURCE
#define UNUSED __attribute((unused))

#include <math.h>
#include <stdbool.h>

#include <lauxlib.h>
#include <lua.h>
#include <pulse/pulseaudio.h>

#include <stdio.h>

#include "pulseaudio.h"

inline static void async_wait(pa_threaded_mainloop *main, pa_operation *op) {
  while (pa_operation_get_state(op) == PA_OPERATION_RUNNING) {
    pa_threaded_mainloop_wait(main);
  }

  pa_operation_unref(op);
  pa_threaded_mainloop_unlock(main);
}

int get_sinks(lua_State *L);
int get_sink_inputs(lua_State *L);
int get_sources(lua_State *L);
int get_source_outputs(lua_State *L);
void state_cb(pa_context *context, void *userdata);
int l_call(lua_State *L, callback *fCall);

void pa_get_sinks(pulseaudio_t *pulse);
void pa_get_sink_inputs(pulseaudio_t *pulse);
void pa_get_sources(pulseaudio_t *pulse);
void pa_get_source_outputs(pulseaudio_t *pulse);
void pa_server_info_cb(pa_context *context, const pa_server_info *info,
                       void *userdata);
bool pa_init(pulseaudio_t *pulse);
void pa_deinit(pulseaudio_t *pulse);

const luaL_Reg pulseaudio_reg[] = {{"get_sinks", get_sinks},
                                   {"get_sink_inputs", get_sink_inputs},
                                   {"get_sources", get_sources},
                                   {"get_source_outputs", get_source_outputs},
                                   {NULL, NULL}};

int luaopen_pulseaudio(lua_State *L) {
  luaL_newlib(L, pulseaudio_reg);
  return 1;
}

int get_sinks(lua_State *L) { return l_call(L, pa_get_sinks); }
int get_sink_inputs(lua_State *L) { return l_call(L, pa_get_sink_inputs); }
int get_sources(lua_State *L) { return l_call(L, pa_get_sources); }
int get_source_outputs(lua_State *L) {
  return l_call(L, pa_get_source_outputs);
}

void state_cb(pa_context *context, void *userdata) {
  pulseaudio_t *pulse = (pulseaudio_t *)userdata;

  switch (pa_context_get_state(context)) {
  case PA_CONTEXT_READY:
  case PA_CONTEXT_FAILED:
  case PA_CONTEXT_TERMINATED:
    pa_threaded_mainloop_signal(pulse->mainloop, 0);
    break;
  case PA_CONTEXT_UNCONNECTED:
  case PA_CONTEXT_CONNECTING:
  case PA_CONTEXT_AUTHORIZING:
  case PA_CONTEXT_SETTING_NAME:
    break;
  }
}

int l_call(lua_State *L, callback *call) {
  pulseaudio_t pulse;
  pulse.L = L;

  if (!pa_init(&pulse)) {
    pa_deinit(&pulse);
    return luaL_error(L, "%s\n", "couldn't initialize pulseaudio");
  }

  lua_newtable(L);
  call(&pulse);

  pa_deinit(&pulse);
  return 1;
}

bool pa_init(pulseaudio_t *pulse) {
  pulse->mainloop = pa_threaded_mainloop_new();
  pulse->context = pa_context_new(pa_threaded_mainloop_get_api(pulse->mainloop),
                                  "lua_pulseaudio");
  pulse->default_sink = NULL;

  pa_context_set_state_callback(pulse->context, state_cb, pulse);

  pa_context_connect(pulse->context, NULL, PA_CONTEXT_NOFLAGS, NULL);

  pa_threaded_mainloop_lock(pulse->mainloop);
  pa_threaded_mainloop_start(pulse->mainloop);

  pa_threaded_mainloop_wait(pulse->mainloop);

  if (pa_context_get_state(pulse->context) != PA_CONTEXT_READY) {
    return false;
  }
  pa_threaded_mainloop_unlock(pulse->mainloop);
  return true;
}

void pa_deinit(pulseaudio_t *pulse) {
  pa_context_unref(pulse->context);
  pulse->context = NULL;

  pa_threaded_mainloop_stop(pulse->mainloop);
  pa_threaded_mainloop_free(pulse->mainloop);

  pulse->mainloop = NULL;
}

void pa_server_info_cb(UNUSED pa_context *_, const pa_server_info *info,
                       void *userdata) {
  pulseaudio_t *pulse = (pulseaudio_t *)userdata;

  pulse->default_sink = strdup(info->default_sink_name);
  pulse->default_source = strdup(info->default_source_name);

  pa_threaded_mainloop_signal(pulse->mainloop, 0);
}

void append_to_list(lua_State *L) {
  lua_len(L, -2);
  lua_Number size = lua_tonumber(L, -1);
  lua_remove(L, -1);

  lua_rawseti(L, -2, size + 1);
}

void set_application_values(lua_State *L, const pa_proplist *proplist) {
  lua_newtable(L);

  if (pa_proplist_contains(proplist, "application.process.id")) {
    lua_pushinteger(L,
                    atoi(pa_proplist_gets(proplist, "application.process.id")));
    lua_setfield(L, -2, "pid");
  }

  if (pa_proplist_contains(proplist, "application.process.binary")) {
    lua_pushstring(L, pa_proplist_gets(proplist, "application.process.binary"));
    lua_setfield(L, -2, "binary");
  }

  if (pa_proplist_contains(proplist, "application.name")) {
    lua_pushstring(L, pa_proplist_gets(proplist, "application.name"));
    lua_setfield(L, -2, "name");
  }

  lua_setfield(L, -2, "application");
}

void set_generic_values(lua_State *L, int index, const char *name,
                        const char *description, const pa_cvolume *volume,
                        int mute) {
  double dB = pa_sw_volume_to_dB(pa_cvolume_avg(volume));
  int v = (int)round(100 * exp10(dB / 60));

  lua_pushnumber(L, index);
  lua_setfield(L, -2, "index");

  lua_pushstring(L, name);
  lua_setfield(L, -2, "name");

  lua_pushstring(L, description);
  lua_setfield(L, -2, "description");

  lua_pushnumber(L, v);
  lua_setfield(L, -2, "volume");

  lua_pushboolean(L, mute);
  lua_setfield(L, -2, "mute");
}

void pa_get_sinks_cb(UNUSED pa_context *_, const pa_sink_info *info, int eol,
                     void *userdata) {
  pulseaudio_t *pulse = (pulseaudio_t *)userdata;
  if (!eol) {
    lua_State *L = pulse->L;
    lua_newtable(L);
    set_generic_values(L, info->index, info->name, info->description,
                       &info->volume, info->mute);
    if (pulse->default_sink != NULL) {
      lua_pushboolean(L, strcmp(info->name, pulse->default_sink) == 0);
    } else {
      lua_pushboolean(L, 0);
    }
    lua_setfield(L, -2, "default");
    append_to_list(L);
  }
  pa_threaded_mainloop_signal(pulse->mainloop, 0);
}

void pa_get_sink_input_cb(UNUSED pa_context *_, const pa_sink_input_info *info,
                          int eol, void *userdata) {
  pulseaudio_t *pulse = (pulseaudio_t *)userdata;
  if (!eol) {
    lua_State *L = pulse->L;
    lua_newtable(L);
    set_generic_values(L, info->index, info->name, NULL, &info->volume,
                       info->mute);
    set_application_values(L, info->proplist);
    append_to_list(L);
  }
  pa_threaded_mainloop_signal(pulse->mainloop, 0);
}

void pa_get_sources_cb(UNUSED pa_context *_, const pa_source_info *info,
                       int eol, void *userdata) {
  pulseaudio_t *pulse = (pulseaudio_t *)userdata;
  if (!eol) {
    lua_State *L = pulse->L;
    lua_newtable(L);
    set_generic_values(L, info->index, info->name, info->description,
                       &info->volume, info->mute);
    if (pulse->default_sink != NULL) {
      lua_pushboolean(L, strcmp(info->name, pulse->default_sink) == 0);
    } else {
      lua_pushboolean(L, 0);
    }
    lua_setfield(L, -2, "default");
    append_to_list(L);
  }
  pa_threaded_mainloop_signal(pulse->mainloop, 0);
}

void pa_get_source_outputs_cb(UNUSED pa_context *_,
                              const pa_source_output_info *info, int eol,
                              void *userdata) {
  pulseaudio_t *pulse = (pulseaudio_t *)userdata;
  if (!eol) {
    lua_State *L = pulse->L;
    lua_newtable(L);
    set_generic_values(L, info->index, info->name, NULL, &info->volume,
                       info->mute);
    set_application_values(L, info->proplist);
    append_to_list(L);
  }
  pa_threaded_mainloop_signal(pulse->mainloop, 0);
}

void pa_get_sinks(pulseaudio_t *pulse) {
  pa_threaded_mainloop_lock(pulse->mainloop);
  pa_operation *op = pa_context_get_server_info(
      pulse->context, pa_server_info_cb, (void *)pulse);
  async_wait(pulse->mainloop, op);

  pa_threaded_mainloop_lock(pulse->mainloop);
  op = pa_context_get_sink_info_list(pulse->context, pa_get_sinks_cb,
                                     (void *)pulse);
  async_wait(pulse->mainloop, op);
}

void pa_get_sink_inputs(pulseaudio_t *pulse) {
  pa_threaded_mainloop_lock(pulse->mainloop);
  pa_operation *op = pa_context_get_sink_input_info_list(
      pulse->context, pa_get_sink_input_cb, (void *)pulse);
  async_wait(pulse->mainloop, op);
}

void pa_get_sources(pulseaudio_t *pulse) {
  pa_threaded_mainloop_lock(pulse->mainloop);
  pa_operation *op = pa_context_get_server_info(
      pulse->context, pa_server_info_cb, (void *)pulse);
  async_wait(pulse->mainloop, op);

  pa_threaded_mainloop_lock(pulse->mainloop);
  op = pa_context_get_source_info_list(pulse->context, pa_get_sources_cb,
                                       (void *)pulse);
  async_wait(pulse->mainloop, op);
}

void pa_get_source_outputs(pulseaudio_t *pulse) {
  pa_threaded_mainloop_lock(pulse->mainloop);
  pa_operation *op = pa_context_get_source_output_info_list(
      pulse->context, pa_get_source_outputs_cb, (void *)pulse);
  async_wait(pulse->mainloop, op);
}
