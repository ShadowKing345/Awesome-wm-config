//
// Created by alex on 9/5/22.
//

#define UNUSED __attribute((unused))

#include <lua.h>
#include <lauxlib.h>
#include <pulse/pulseaudio.h>

#include "lua_module.h"
#include "types.h"

const char *type_message = "Should be of type {sink, sink_input, source, source_output}";

int get_object(lua_State *L) {
    lua_newtable(L);
    return 1;
}

int set_volume(lua_State *L) {
    return 0;
}

int mute_object(lua_State *L) {
    return 0;
}

int set_default_sink_source(lua_State *L) {
    return 0;
}

int move_input_output(lua_State *L) {
    return 0;
}

UNUSED int luaopen_pulseaudio(lua_State *L) {
    const luaL_Reg pulseaudio_reg[] = {
            {"get_object",              get_object},
            {"set_volume",              set_volume},
            {"mute_object",             mute_object},
            {"set_default_sink_source", set_default_sink_source},
            {"move_input_output",       move_input_output},
            {NULL, NULL}
    };

    luaL_newlib(L, pulseaudio_reg);

    lua_newtable(L);

    lua_pushnumber(L, PA_VOLUME_MUTED);
    lua_setfield(L, -2, "volume_mute");

    lua_pushnumber(L, PA_VOLUME_NORM);
    lua_setfield(L, -2, "volume_norm");

    lua_newtable(L);
    for (int i = 0; i < 4; i++) {
        lua_pushstring(L, PA_TYPES_STRING[i]);
        lua_rawseti(L, -2, i + 1);
    }
    lua_setfield(L, -2, "types");
    lua_setfield(L, -2, "defaults");

    return 1;
}
