#define _GNU_SOURCE
#define UNUSED __attribute((unused))

#include "init.h"
#include "pa_utils.h"
#include "utils.h"
#include <lauxlib.h>
#include <lua.h>
#include <math.h>
#include <pulse/pulseaudio.h>
#include <stdbool.h>
#include <stdio.h>

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
