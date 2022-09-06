//
// Created by alex on 9/5/22.
//

#define UNUSED __attribute((unused))

#include <sol.hpp>

#include <lua.h>

//#include "init.h"
////#include "types.h"
////#include "callbacks.h"
//
////const char *type_message = "Should be of type {sink, sink_input, source, source_output}";
//
//int init::get(lua_State *L) {
//    return 0;
////    lua_getfield(L, -1, "type");
////    if (lua_isnil(L, -1)) {
////        return luaL_error(L, "%s %s\n", "Argument type cannot be nil.", type_message);
////    }
////    const char *type_str = lua_tostring(L, -1);
////    lua_pop(L, 1);
////
////    pulseaudio_t pulse;
////    pulse.L = L;
////
////    if (!pa_init(&pulse)) {
////        pa_deinit(&pulse);
////        return luaL_error(L, "%s\n", "couldn't initialize pulseaudio");
////    }
////
////    int return_number = pa_get(&pulse, string_type_to_enum(type_str));
////
////    pa_deinit(&pulse);
////    return return_number;
//}
//
//int init::mute(lua_State *L) {
//    return 0;
//
////    if (!lua_istable(L, -1)) {
////        return luaL_error(L, "%s\n", "Arguments cannot be nil.");
////    }
////
////    lua_getfield(L, -1, "index");
////    if (lua_isnil(L, -1)) {
////        return luaL_error(L, "%s\n", "Index field cannot be nil.");
////    }
////    lua_setfield(L, -1, "index");
////
////    lua_getfield(L, -1, "type");
////    if (lua_isnil(L, -1)) {
////        return luaL_error(L, "%s\n", "Type field cannot be nil.");
////    }
////
////    const char *type_str = lua_tostring(L, -1);
////    lua_pop(L, 1);
////
////    pulseaudio_t pulse;
////    pulse.L = L;
////
////    if (!pa_init(&pulse)) {
////        pa_deinit(&pulse);
////        return luaL_error(L, "%s\n", "couldn't initialize pulseaudio");
////    }
////
////    int return_number = pa_mute(&pulse, string_type_to_enum(type_str));
////
////    pa_deinit(&pulse);
////    return return_number;
//}
//
//int init::volume(lua_State *L) {
//    return 0;
//
////    if (!lua_istable(L, -1)) {
////        return luaL_error(L, "%s\n", "Arguments cannot be nil.");
////    }
////
////    lua_getfield(L, -1, "index");
////    if (lua_isnil(L, -1)) {
////        return luaL_error(L, "%s\n", "Index field cannot be nil.");
////    }
////    lua_setfield(L, -1, "index");
////
////    lua_getfield(L, -1, "type");
////    if (lua_isnil(L, -1)) {
////        return luaL_error(L, "%s\n", "Type field cannot be nil.");
////    }
////
////    const char *type_str = lua_tostring(L, -1);
////    lua_pop(L, 1);
////
////    pulseaudio_t pulse;
////    pulse.L = L;
////
////    if (!pa_init(&pulse)) {
////        pa_deinit(&pulse);
////        return luaL_error(L, "%s\n", "couldn't initialize pulseaudio");
////    }
////
////    int return_number = pa_volume(&pulse, string_type_to_enum(type_str));
////
////    pa_deinit(&pulse);
////    return return_number;
//}

extern "C" UNUSED int luaopen_pulseaudio(lua_State *L) {
//    const luaL_Reg pulseaudio_reg[] = {
//            {"mute",       mute},
//            {"get",        get},
//            {"set_volume", set_volume},
//            {nullptr,      nullptr}
//    };
//
//    luaL_newlib(L, pulseaudio_reg);
//
//    lua_newtable(L);
//
//    lua_pushnumber(L, PA_VOLUME_MUTED);
//    lua_setfield(L, -2, "volume_mute");
//
//    lua_pushnumber(L, PA_VOLUME_NORM);
//    lua_setfield(L, -2, "volume_norm");
//
//    lua_newtable(L);
//    for (int i = 0; i < 4; i++) {
//        lua_pushstring(L, PA_TYPES_STRING[i]);
//        lua_rawseti(L, -2, i + 1);
//    }
//    lua_setfield(L, -2, "types");
//
//    lua_setfield(L, -2, "defaults");

    lua_pushstring(L, "Hello world");

    return 1;
}
