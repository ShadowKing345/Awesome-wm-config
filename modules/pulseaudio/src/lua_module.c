//
// Created by alex on 9/5/22.
//

#define UNUSED __attribute((unused))

#include "sol/sol.hpp"

#include <lua.h>
#include <pulse/pulseaudio.h>

#include "lua_module.h"

const char *type_message = "Should be of type {sink, sink_input, source, source_output}";

sol::table lua_module::get() {
    return this->lua->create_table_with(1, 3);
}

lua_module::lua_module(sol::state_view *lua) {
    this->lua = lua;
}

extern "C" UNUSED int luaopen_pulseaudio(lua_State *L) {
    sol::state_view lua = sol::state_view(L);
    auto luaModule = lua_module(&lua);

    lua.open_libraries(sol::lib::base);

    sol::table table = lua.create_table_with(
            "defaults",
            lua.create_table_with(
                    "volume_mute", PA_VOLUME_MUTED,
                    "volume_norm", PA_VOLUME_NORM
            ),
            "get",
            &lua_module::get
    );
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
    sol::stack::push(lua, table);
    return 1;
}
