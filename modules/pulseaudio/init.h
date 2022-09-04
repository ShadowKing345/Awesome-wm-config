#include "types.h"
#include <lua.h>
#include <pulse/pulseaudio.h>
#include <string.h>

int get_sinks(lua_State *L);
int get_sink_inputs(lua_State *L);
int get_sources(lua_State *L);
int get_source_outputs(lua_State *L);
void state_cb(pa_context *context, void *userdata);
