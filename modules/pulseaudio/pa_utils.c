#define _GNU_SOURCE
#define UNUSED __attribute((unused))

#include "pa_utils.h"
#include "utils.h"
#include <pulse/pulseaudio.h>
#include <string.h>

int pa_init(pulseaudio_t *pulse) {
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
    return 0;
  }
  pa_threaded_mainloop_unlock(pulse->mainloop);
  return 1;
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
