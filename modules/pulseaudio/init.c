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

const char *type_message = "Should be of type {sink, sink_input, source, source_output}";

int l_call(lua_State *L, callback *call);

int mute(lua_State *L) {
    if (!lua_istable(L, -1)) {
        return luaL_error(L, "%s\n", "Arguments cannot be nil.");
    }

    lua_getfield(L, -1, "index");
    if (lua_isnil(L, -1)) {
        return luaL_error(L, "%s\n", "Index field cannot be nil.");
    }
    lua_setfield(L, -1, "index");

    lua_getfield(L, -1, "type");
    if (lua_isnil(L, -1)) {
        return luaL_error(L, "%s\n", "Type field cannot be nil.");
    }

    const char *type_str = lua_tostring(L, -1);
    lua_pop(L, 1);

    switch (string_type_to_enum(type_str)) {
        case sink:
            return l_call(L, pa_mute_sink);
        case sink_input:
            return l_call(L, pa_mute_sink_input);
        case source:
            return l_call(L, pa_mute_source);
        case source_output:
            return l_call(L, pa_mute_source_output);
        default:
            return luaL_error(L, "%s %s\n", "Wrong type value.", type_message);
    }
}

int set_volume(lua_State *L) {
    if (!lua_istable(L, -1)) {
        return luaL_error(L, "%s\n", "Arguments cannot be nil.");
    }

    lua_getfield(L, -1, "index");
    if (lua_isnil(L, -1)) {
        return luaL_error(L, "%s\n", "Index field cannot be nil.");
    }
    lua_setfield(L, -1, "index");

    lua_getfield(L, -1, "type");
    if (lua_isnil(L, -1)) {
        return luaL_error(L, "%s\n", "Type field cannot be nil.");
    }

    const char *type_str = lua_tostring(L, -1);
    lua_pop(L, 1);

    switch (string_type_to_enum(type_str)) {
        case sink:
            return l_call(L, pa_volume_sink);
        case sink_input:
            return l_call(L, pa_volume_sink_input);
        case source:
            return l_call(L, pa_volume_source);
        case source_output:
            return l_call(L, pa_volume_source_output);
        default:
            return luaL_error(L, "%s %s\n", "Wrong type value.", type_message);
    }
}

int get(lua_State *L) {
    if (!lua_istable(L, -1)) {
        return luaL_error(L, "%s\n", "Arguments cannot be nil.");
    }

    lua_getfield(L, -1, "type");
    if (lua_isnil(L, -1)) {
        return luaL_error(L, "%s %s\n", "Argument type cannot be nil.", type_message);
    }
    const char *type_str = lua_tostring(L, -1);
    lua_pop(L, 1);

    switch (string_type_to_enum(type_str)) {
        case sink:
            return l_call(L, pa_get_sinks);
        case sink_input:
            return l_call(L, pa_get_sink_inputs);
        case source:
            return l_call(L, pa_get_sources);
        case source_output:
            return l_call(L, pa_get_source_outputs);
        case all:
            return l_call(L, pa_get_all);
        default:
            return luaL_error(L, "%s\n",
                              "Argument type is not valid. Should be of type {sink, sink_input, source, source_output}.");
    }
}

const luaL_Reg pulseaudio_reg[] = {
        {"mute",       mute},
        {"get",        get},
        {"set_volume", set_volume},
        {NULL, NULL}
};

UNUSED int luaopen_pulseaudio(lua_State *L) {
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
