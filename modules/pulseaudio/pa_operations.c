//
// Created by alex on 9/5/22.
//

#define UNUSED __attribute((unused))

#include <pulse/pulseaudio.h>
#include <string.h>

#include "types.h"
#include "callbacks.h"
#include "pa_operations.h"

void state_cb(pa_context *context, void *userdata);

void async_wait(pulseaudio_t *pulse, pFunction fn, cb cb);

void pa_get_sinks(pulseaudio_t *pulse) {
    async_wait(pulse, pa_context_get_server_info, pa_server_info_cb);
    async_wait(pulse, pa_context_get_sink_info_list, pa_get_sink_cb);
}

void pa_get_sink_inputs(pulseaudio_t *pulse) {
    async_wait(pulse, pa_context_get_sink_input_info_list, pa_get_sink_input_cb);
}

void pa_get_sources(pulseaudio_t *pulse) {
    async_wait(pulse, pa_context_get_server_info, pa_server_info_cb);
    async_wait(pulse, pa_context_get_source_info_list, pa_get_source_cb);
}

void pa_get_source_outputs(pulseaudio_t *pulse) {
    async_wait(pulse, pa_context_get_source_output_info_list, pa_get_source_output_cb);
}

void pa_get_all(pulseaudio_t *pulse) {
    lua_State *L = pulse->L;
    async_wait(pulse, pa_context_get_server_info, pa_server_info_cb);

    lua_newtable(L);
    async_wait(pulse, pa_context_get_sink_info_list, pa_get_sink_cb);
    lua_setfield(L, -2, "sink");
    lua_newtable(L);
    async_wait(pulse, pa_context_get_sink_input_info_list, pa_get_sink_input_cb);
    lua_setfield(L, -2, "sink_input");
    lua_newtable(L);
    async_wait(pulse, pa_context_get_source_info_list, pa_get_source_cb);
    lua_setfield(L, -2, "source");
    lua_newtable(L);
    async_wait(pulse, pa_context_get_source_output_info_list, pa_get_source_output_cb);
    lua_setfield(L, -2, "source_output");
}

void pa_mute_sink(pulseaudio_t *pulse) {
    lua_State *L = pulse->L;

    lua_getfield(L, -1, "mute");
    lua_getfield(L, -1, "index");

    int index = lua_tonumber(L, -1);
    lua_pop(L, -1);

    int mute;

    if (lua_isnumber(L, -1)) {
        mute = lua_tonumber(L, -1);
    } else {
        mute = 0;
    }
    lua_pop(L, -1);

    pa_threaded_mainloop_lock(pulse->mainloop);
    pa_operation *op = pa_context_set_sink_mute_by_index(pulse->context, index, mute, pa_success_cb, (void *) pulse);

    while (pa_operation_get_state(op) == PA_OPERATION_RUNNING) {
        pa_threaded_mainloop_wait(pulse->mainloop);
    }

    pa_threaded_mainloop_unlock(pulse->mainloop);

    lua_pushboolean(L, pulse->success);
}

void state_cb(pa_context *context, void *userdata) {
    pulseaudio_t *pulse = (pulseaudio_t *) userdata;

    switch (pa_context_get_state(context)) {
        case PA_CONTEXT_READY:
        case PA_CONTEXT_FAILED:
        case PA_CONTEXT_TERMINATED:
            pa_threaded_mainloop_signal(pulse->mainloop, 0);
            break;
        case PA_CONTEXT_UNCONNECTED:
        case PA_CONTEXT_CONNECTING:
        case PA_CONTEXT_AUTHORIZING:
        case PA_CONTEXT_SETTING_NAME:
            break;
    }
}

int pa_init(pulseaudio_t *pulse) {
    pulse->mainloop = pa_threaded_mainloop_new();
    pulse->context = pa_context_new(pa_threaded_mainloop_get_api(pulse->mainloop),
                                    "lua_pulseaudio");
    pulse->default_sink = NULL;

    pa_context_set_state_callback(pulse->context, state_cb, pulse);

    pa_context_connect(pulse->context, NULL, PA_CONTEXT_NOFLAGS, NULL);

    pa_threaded_mainloop_lock(pulse->mainloop);
    pa_threaded_mainloop_start(pulse->mainloop);

    pa_threaded_mainloop_wait(pulse->mainloop);

    if (pa_context_get_state(pulse->context) != PA_CONTEXT_READY) {
        return 0;
    }
    pa_threaded_mainloop_unlock(pulse->mainloop);
    return 1;
}

void pa_deinit(pulseaudio_t *pulse) {
    pa_context_unref(pulse->context);
    pulse->context = NULL;

    pa_threaded_mainloop_stop(pulse->mainloop);
    pa_threaded_mainloop_free(pulse->mainloop);

    pulse->mainloop = NULL;
}

void async_wait(pulseaudio_t *pulse, pFunction fn, cb cb) {
    pa_threaded_mainloop_lock(pulse->mainloop);
    pa_operation *op = fn(pulse->context, cb, (void *) pulse);

    while (pa_operation_get_state(op) == PA_OPERATION_RUNNING) {
        pa_threaded_mainloop_wait(pulse->mainloop);
    }

    pa_operation_unref(op);
    pa_threaded_mainloop_unlock(pulse->mainloop);
}
