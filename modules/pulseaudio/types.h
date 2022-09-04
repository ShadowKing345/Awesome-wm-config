#include <lua.h>
#include <pulse/pulseaudio.h>

#ifndef TYPES_H
#define TYPES_H

typedef struct pulseaudio_t {
  pa_threaded_mainloop *mainloop;
  pa_context *context;

  lua_State *L;

  char *default_sink;
  char *default_source;

  int success;
} pulseaudio_t;

typedef void(callback)(pulseaudio_t *pulse);
#endif
