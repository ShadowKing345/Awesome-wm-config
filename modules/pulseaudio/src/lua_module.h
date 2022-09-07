//
// Created by alex on 9/7/22.
//

#ifndef PULSEAUDIO_LUA_MODULE_H
#define PULSEAUDIO_LUA_MODULE_H

class lua_module {
public:
    lua_module(sol::state_view *lua);

    sol::table get();
//    int set_volume();
//    int mute();
//    int set_default();
private:
    sol::state_view *lua;
};

#endif //PULSEAUDIO_LUA_MODULE_H
