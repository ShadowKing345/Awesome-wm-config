//
// Created by alex on 9/5/22.
//

#include <lua.h>
#include <pulse/pulseaudio.h>

#ifndef PULSEAUDIO_TYPES_H
#define PULSEAUDIO_TYPES_H

typedef struct pulseaudio_t {
    pa_threaded_mainloop *mainloop;
    pa_context *context;

    lua_State *L;

    char *default_sink;
    char *default_source;

    int success;
} pulseaudio_t;

typedef void(callback)(pulseaudio_t *pulse);

enum PA_TYPES_ENUM {
    sink,
    sink_input,
    source,
    source_output,
    all
};

extern const char *PA_TYPES_STRING[];

enum PA_TYPES_ENUM string_type_to_enum(const char *type);

#endif
