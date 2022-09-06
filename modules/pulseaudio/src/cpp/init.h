//
// Created by alex on 9/6/22.
//

#ifndef PULSEAUDIO_INIT_H
#define PULSEAUDIO_INIT_H

class init {
public:
    int get(lua_State* L);
    int volume(lua_State* L);
    int mute(lua_State* L);
};

extern "C" int luaopen_pulseaudio(lua_State *L)

#endif //PULSEAUDIO_INIT_H
