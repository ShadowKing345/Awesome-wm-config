//
// Created by alex on 9/5/22.
//

#define UNUSED __attribute((unused))

#include <lua.h>
#include <lauxlib.h>
#include <stdio.h>

#include "types.h"
#include "pa_operations.h"
#include "callbacks.h"

int l_call(lua_State *L, callback *call);

int get_sinks(lua_State *L) { return l_call(L, pa_get_sinks); }

int get_sink_inputs(lua_State *L) { return l_call(L, pa_get_sink_inputs); }

int get_sources(lua_State *L) { return l_call(L, pa_get_sources); }

int get_source_outputs(lua_State *L) { return l_call(L, pa_get_source_outputs); }

const luaL_Reg pulseaudio_reg[] = {
        {"get_sinks",          get_sinks},
        {"get_sink_inputs",    get_sink_inputs},
        {"get_sources",        get_sources},
        {"get_source_outputs", get_source_outputs},
        {NULL, NULL}
};

UNUSED int luaopen_pulseaudio(lua_State *L) {
    luaL_newlib(L, pulseaudio_reg);
    return 1;
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
