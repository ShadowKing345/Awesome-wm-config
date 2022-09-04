#include <lua.h>
#include <string.h>

#include <pulse/pulseaudio.h>

typedef struct {
  pa_threaded_mainloop *mainloop;
  pa_context *context;

  lua_State *L;

  char *default_sink;
  char *default_source;

  int success;
} pulseaudio_t;

typedef void(callback)(pulseaudio_t *pulse);
