#define _GNU_SOURCE

#include "types.h"
#include <lua.h>
#include <pulse/pulseaudio.h>

void async_wait(pa_threaded_mainloop *main, pa_operation *op);
void state_cb(pa_context *context, void *userdata);
void append_to_list(lua_State *L);
void set_application_values(lua_State *L, const pa_proplist *proplist);
void set_generic_values(lua_State *L, int index, const char *name,
                        const char *description, const pa_cvolume *volume,
                        int mute);
int l_call(lua_State *L, callback *fCall);
