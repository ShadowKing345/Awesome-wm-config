//
// Created by alex on 9/7/22.
//

#ifndef PULSEAUDIO_LUA_MODULE_H
#define PULSEAUDIO_LUA_MODULE_H

int get_object(lua_State *L);

int set_volume(lua_State *L);

int mute_object(lua_State *L);

int set_default_sink_source(lua_State *L);

int move_input_output(lua_State *L);

#endif //PULSEAUDIO_LUA_MODULE_H
