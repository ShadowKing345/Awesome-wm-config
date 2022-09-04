#define _GNU_SOURCE

#include "utils.h"
#include "pa_utils.h"
#include "types.h"
#include <lauxlib.h>
#include <lua.h>
#include <math.h>
#include <string.h>

void async_wait(pa_threaded_mainloop *main, pa_operation *op) {
  while (pa_operation_get_state(op) == PA_OPERATION_RUNNING) {
    pa_threaded_mainloop_wait(main);
  }

  pa_operation_unref(op);
  pa_threaded_mainloop_unlock(main);
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
