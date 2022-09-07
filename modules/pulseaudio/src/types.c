//
// Created by alex on 9/5/22.
//

#include <string.h>
#include <lauxlib.h>

#include "types.h"

const char *PA_TYPES_STRING[] = {
        "sink",
        "sink_input",
        "source",
        "source_output",
        "all",
};

enum PA_TYPE type_string_to_enum(const char *type) {
    if (strcmp(PA_TYPES_STRING[sink], type) == 0) {
        return sink;
    } else if (strcmp(PA_TYPES_STRING[sink_input], type) == 0) {
        return sink_input;
    } else if (strcmp(PA_TYPES_STRING[source], type) == 0) {
        return source;
    } else if (strcmp(PA_TYPES_STRING[source_output], type) == 0) {
        return source_output;
    } else if (strcmp(PA_TYPES_STRING[all], type) == 0) {
        return all;
    }

    return -1;
}

const char *type_message = "{sink, sink_input, source, source_output}";

void try_parse_get_args_enf(lua_State *L, get_args_t *args, int enforce_index) {
    if (!lua_istable(L, -1)) {
        luaL_error(L, "Invalid argument type. Must be one table.\n");
        return;
    }

    lua_getfield(L, -1, "type");
    PA_TYPE type = lua_isnil(L, -1) ? all : type_string_to_enum(lua_tostring(L, -1));

    if (type == -1) {
        luaL_error(L, "Bad type argument. Type argument can only be set to %s\n", type_message);
        return;
    }
    args->type = type;
    lua_pop(L, 1);

    lua_getfield(L, -1, "index");
    if (enforce_index != 0 && lua_isnil(L, -1)) {
        luaL_error(L, "Bad type argument. Index cannot be nil.\n");
        return;
    }

    if (lua_isnil(L, -1)) {
        args->index = -1;
        lua_pop(L, 1);
        return;
    }

    if (!lua_isnumber(L, -1)) {
        luaL_error(L, "Bad argument type. Index can only be of type number.\n");
        return;
    }
    args->index = lua_tointeger(L, -1);
    lua_pop(L, 1);
}

void try_parse_get_args(lua_State *L, get_args_t *args) {
    try_parse_get_args_enf(L, args, 0);
}

void try_parse_volume_args(lua_State *L, volume_args_t *args) {
    try_parse_get_args_enf(L, (get_args_t *) args, 1);

    lua_getfield(L, -1, "volume");
    if (!lua_isnumber(L, -1)) {
        luaL_error(L, "Bad argument type. Volume must be of type number.\n");
        return;
    }
    args->volume = lua_tointeger(L, -1);
    if (args->volume < PA_VOLUME_MUTED || PA_VOLUME_MAX < args->volume) {
        luaL_error(L, "Bad argument. Volume must be between %d and %d included the values.\n", PA_VOLUME_MUTED,
                   PA_VOLUME_MAX);
        return;
    }
    lua_pop(L, -1);
}

void try_parse_mute_args(lua_State *L, mute_args_t *args) {
    try_parse_get_args_enf(L, (get_args_t *) args, 1);

    lua_getfield(L, -1, "mute");
    if (!lua_isboolean(L, -1)) {
        luaL_error(L, "Bad argument type. Mute must be of type boolean.\n");
        return;
    }
    args->mute = lua_toboolean(L, -1);
    lua_pop(L, -1);
}
