//
// Created by alex on 9/5/22.
//

#include <lua.h>
#include <pulse/pulseaudio.h>

#ifndef PULSEAUDIO_TYPES_H
#define PULSEAUDIO_TYPES_H

enum PA_TYPE {
    sink,
    sink_input,
    source,
    source_output,
    all
};

extern const char *PA_TYPES_STRING[];

typedef struct get_args_t {
    char *type;
    int index;
} get_args_t;

typedef struct volume_args_t {
    char *type;
    int index;
    int volume;
} volume_args_t;

typedef struct mute_args_t {
    char *type;
    int index;
    int mute;
} mute_args_t;

typedef struct pulseaudio_t {
    pa_threaded_mainloop *mainloop;
    pa_context *context;

    lua_State *L;

    char *default_sink;
    char *default_source;

    int success;
} pulseaudio_t;

typedef int(pa_callback_t)(pulseaudio_t *pulse, enum PA_TYPE type);

enum PA_TYPE string_type_to_enum(const char *type);

int try_parse_get_args(lua_State *L, get_args_t *args);

int try_parse_volume_args(lua_State *L, volume_args_t *args);

int try_parse_mute_args(lua_State *L, mute_args_t *args);

#endif
