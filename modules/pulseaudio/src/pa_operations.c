//
// Created by alex on 9/5/22.
//

#define UNUSED __attribute((unused))

#include <pulse/pulseaudio.h>
#include <string.h>
#include <lauxlib.h>

#include "types.h"
#include "callbacks.h"
#include "pa_operations.h"

void state_cb(pa_context *context, void *userdata);

void async_wait(pa_operation *op, pa_threaded_mainloop *mainloop);

int pa_get(pulseaudio_t *pulse, void *userdata) {
    get_args_t *args = (get_args_t *) userdata;
    int is_index_nil = args->index == -1;
    lua_State *L = pulse->L;

    lua_newtable(L);

    pa_threaded_mainloop_lock(pulse->mainloop);
    pa_operation *op;

    switch (args->type) {
        case sink:
        case source:
            op = pa_context_get_server_info(pulse->context, pa_server_info_cb, (void *) pulse);
            async_wait(op, pulse->mainloop);

            if (is_index_nil) {
                op = args->type == sink
                     ? pa_context_get_sink_info_list(pulse->context, pa_get_sink_cb, (void *) pulse)
                     : pa_context_get_source_info_list(pulse->context, pa_get_source_cb, (void *) pulse);
            } else {
                op = args->type == sink
                     ? pa_context_get_sink_info_by_index(pulse->context, args->index, pa_get_sink_cb, (void *) pulse)
                     : pa_context_get_source_info_by_index(pulse->context, args->index, pa_get_source_cb,
                                                           (void *) pulse);
            }
            async_wait(op, pulse->mainloop);
            break;
        case sink_input:
            op = is_index_nil
                 ? pa_context_get_sink_input_info_list(pulse->context, pa_get_sink_input_cb, (void *) pulse)
                 : pa_context_get_sink_input_info(pulse->context, args->index, pa_get_sink_input_cb, (void *) pulse);
            async_wait(op, pulse->mainloop);
            break;
        case source_output:
            op = is_index_nil
                 ? pa_context_get_source_output_info_list(pulse->context, pa_get_source_output_cb, (void *) pulse)
                 : pa_context_get_source_output_info(pulse->context, args->index, pa_get_source_output_cb,
                                                     (void *) pulse);
            async_wait(op, pulse->mainloop);
            break;
        case all:
            op = pa_context_get_server_info(pulse->context, pa_server_info_cb, (void *) pulse);
            async_wait(op, pulse->mainloop);

            if (!is_index_nil) {
                return luaL_error(L,
                                  "You cannot use index with type all. There are different types with the same index.\n");
            }

            lua_newtable(L);
            op = pa_context_get_sink_info_list(pulse->context, pa_get_sink_cb, (void *) pulse);
            async_wait(op, pulse->mainloop);
            lua_setfield(L, -2, "sink");

            lua_newtable(L);
            op = pa_context_get_sink_input_info_list(pulse->context, pa_get_sink_input_cb, (void *) pulse);
            async_wait(op, pulse->mainloop);
            lua_setfield(L, -2, "sink_input");

            lua_newtable(L);
            op = pa_context_get_source_info_list(pulse->context, pa_get_source_cb, (void *) pulse);
            async_wait(op, pulse->mainloop);
            lua_setfield(L, -2, "source");

            lua_newtable(L);
            op = pa_context_get_source_output_info_list(pulse->context, pa_get_source_output_cb, (void *) pulse);
            async_wait(op, pulse->mainloop);
            lua_setfield(L, -2, "source_output");
            break;
        default:
            return luaL_error(L, "%s\n", "Bad type.");
    }
    pa_threaded_mainloop_unlock(pulse->mainloop);

    if (!is_index_nil) {
        lua_rawgeti(L, -1, 1);
        lua_remove(L, -2);
    }

    return 1;
}

int pa_set_volume(pulseaudio_t *pulse, void *userdata) {
    volume_args_t *args = (volume_args_t *) userdata;
    lua_State *L = pulse->L;
    pa_operation *op;

    pa_cvolume cv;
    pa_cvolume_set(&cv, 1, args->volume);

    pa_threaded_mainloop_lock(pulse->mainloop);
    switch (args->type) {
        case sink:
            op = pa_context_set_sink_volume_by_index(pulse->context, args->index, &cv, pa_success_cb,
                                                     (void *) pulse);
            async_wait(op, pulse->mainloop);
            break;
        case sink_input:
            op = pa_context_set_sink_input_volume(pulse->context, args->index, &cv, pa_success_cb,
                                                  (void *) pulse);
            async_wait(op, pulse->mainloop);
            break;
        case source:
            op = pa_context_set_source_volume_by_index(pulse->context, args->index, &cv, pa_success_cb,
                                                       (void *) pulse);
            async_wait(op, pulse->mainloop);
            break;
        case source_output:
            op = pa_context_set_source_output_volume(pulse->context, args->index, &cv, pa_success_cb,
                                                     (void *) pulse);
            async_wait(op, pulse->mainloop);
            break;

        case all:
        default:
            return luaL_error(L, "%s\n", "Bad type.");
    }
    pa_threaded_mainloop_unlock(pulse->mainloop);

    lua_pushboolean(L, pulse->success);

    return 1;
}

int pa_mute_object(pulseaudio_t *pulse, void *userdata) {
    mute_args_t *args = (mute_args_t *) userdata;
    lua_State *L = pulse->L;
    pa_operation *op;

    pa_threaded_mainloop_lock(pulse->mainloop);
    switch (args->type) {
        case sink:
            op = pa_context_set_sink_mute_by_index(pulse->context, args->index, args->mute, pa_success_cb,
                                                   (void *) pulse);
            async_wait(op, pulse->mainloop);
            break;
        case sink_input:
            op = pa_context_set_sink_input_mute(pulse->context, args->index, args->mute, pa_success_cb, (void *) pulse);
            async_wait(op, pulse->mainloop);
            break;
        case source:
            op = pa_context_set_source_mute_by_index(pulse->context, args->index, args->mute, pa_success_cb,
                                                     (void *) pulse);
            async_wait(op, pulse->mainloop);
            break;
        case source_output:
            op = pa_context_set_source_output_mute(pulse->context, args->index, args->mute, pa_success_cb,
                                                   (void *) pulse);
            async_wait(op, pulse->mainloop);
            break;
        case all:
        default:
            return luaL_error(L, "%s\n", "Bad type.");
    }
    pa_threaded_mainloop_unlock(pulse->mainloop);

    lua_pushboolean(L, pulse->success);

    return 1;
}

int pa_init(pulseaudio_t *pulse) {
    pulse->mainloop = pa_threaded_mainloop_new();
    pulse->context = pa_context_new(pa_threaded_mainloop_get_api(pulse->mainloop), "lua_pulseaudio");
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

void async_wait(pa_operation *op, pa_threaded_mainloop *mainloop) {
    while (pa_operation_get_state(op) == PA_OPERATION_RUNNING) {
        pa_threaded_mainloop_wait(mainloop);
    }
    pa_operation_unref(op);
}