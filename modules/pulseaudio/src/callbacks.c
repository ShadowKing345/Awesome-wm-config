//
// Created by alex on 9/5/22.
//

#define UNUSED __attribute((unused))

#include <lua.h>
#include <string.h>
#include <stdio.h>

#include "callbacks.h"
#include "types.h"
#include "pa_operations.h"

void
set_generic_values(lua_State *L, u_int32_t index, const char *name, const char *description, const pa_cvolume *volume,
                   int mute);

void set_application_values(lua_State *L, const pa_proplist *proplist);

void append_to_list(lua_State *L);

void pa_server_info_cb(UNUSED pa_context *_, const pa_server_info *info, void *userdata) {
    pulseaudio_t *pulse = (pulseaudio_t *) userdata;

    pulse->default_sink = strdup(info->default_sink_name);
    pulse->default_source = strdup(info->default_source_name);

    pa_threaded_mainloop_signal(pulse->mainloop, 0);
}

void pa_get_sink_cb(UNUSED pa_context *_, const pa_sink_info *info, int eol, void *userdata) {
    pulseaudio_t *pulse = (pulseaudio_t *) userdata;
    if (!eol) {
        lua_State *L = pulse->L;
        lua_newtable(L);
        set_generic_values(L, info->index, info->name, info->description,
                           &info->volume, info->mute);
        if (pulse->default_sink != NULL) {
            lua_pushboolean(L, strcmp(info->name, pulse->default_sink) == 0);
        } else {
            lua_pushboolean(L, 0);
        }
        lua_setfield(L, -2, "default");
        lua_pushstring(L, "sink");
        lua_setfield(L, -2, "type");
        append_to_list(L);
    }
    pa_threaded_mainloop_signal(pulse->mainloop, 0);
}

void pa_get_sink_input_cb(UNUSED pa_context *_, const pa_sink_input_info *info, int eol, void *userdata) {
    pulseaudio_t *pulse = (pulseaudio_t *) userdata;
    if (!eol) {
        lua_State *L = pulse->L;
        lua_newtable(L);
        set_generic_values(L, info->index, info->name, NULL, &info->volume,
                           info->mute);
        set_application_values(L, info->proplist);

        lua_pushstring(L, "sink_input");
        lua_setfield(L, -2, "type");

        append_to_list(L);
    }
    pa_threaded_mainloop_signal(pulse->mainloop, 0);
}

void pa_get_source_cb(UNUSED pa_context *context, const pa_source_info *info, int eol, void *userdata) {
    pulseaudio_t *pulse = (pulseaudio_t *) userdata;
    if (!eol) {
        lua_State *L = pulse->L;
        lua_newtable(L);
        set_generic_values(L, info->index, info->name, info->description,
                           &info->volume, info->mute);
        if (pulse->default_sink != NULL) {
            lua_pushboolean(L, strcmp(info->name, pulse->default_source) == 0);
        } else {
            lua_pushboolean(L, 0);
        }
        lua_setfield(L, -2, "default");

        lua_pushstring(L, "source");
        lua_setfield(L, -2, "type");

        append_to_list(L);
    }
    pa_threaded_mainloop_signal(pulse->mainloop, 0);
}

void pa_get_source_output_cb(UNUSED pa_context *context, const pa_source_output_info *info, int eol, void *userdata) {
    pulseaudio_t *pulse = (pulseaudio_t *) userdata;
    if (!eol) {
        lua_State *L = pulse->L;
        lua_newtable(L);
        set_generic_values(L, info->index, info->name, NULL, &info->volume,
                           info->mute);
        set_application_values(L, info->proplist);

        lua_pushstring(L, "source_output");
        lua_setfield(L, -2, "type");

        append_to_list(L);
    }
    pa_threaded_mainloop_signal(pulse->mainloop, 0);
}

void pa_success_cb(UNUSED pa_context *_, int success, void *userdata) {
    pulseaudio_t *pulse = (pulseaudio_t *) userdata;
    pulse->success = success;
    pa_threaded_mainloop_signal(pulse->mainloop, 0);
}

void
set_generic_values(lua_State *L, u_int32_t index, const char *name, const char *description, const pa_cvolume *volume,
                   int mute) {
    lua_pushnumber(L, index);
    lua_setfield(L, -2, "index");

    lua_pushstring(L, name);
    lua_setfield(L, -2, "name");

    lua_pushstring(L, description);
    lua_setfield(L, -2, "description");

    lua_pushnumber(L, pa_cvolume_avg(volume));
    lua_setfield(L, -2, "volume");

    lua_pushboolean(L, mute);
    lua_setfield(L, -2, "mute");
}

void set_application_values(lua_State *L, const pa_proplist *proplist) {
    lua_newtable(L);

    if (pa_proplist_contains(proplist, "application.process.id")) {
        lua_pushstring(L, pa_proplist_gets(proplist, "application.process.id"));
        lua_setfield(L, -2, "pid");
    }

    if (pa_proplist_contains(proplist, "application.process.binary")) {
        lua_pushstring(L, pa_proplist_gets(proplist, "application.process.binary"));
        lua_setfield(L, -2, "binary");
    }

    if (pa_proplist_contains(proplist, "application.name")) {
        lua_pushstring(L, pa_proplist_gets(proplist, "application.name"));
        lua_setfield(L, -2, "name");
    }

    lua_setfield(L, -2, "application");
}

/**
 * Callback for when a pulseaudio event occurs.
 * @param c Unused context.
 * @param t Event type
 * @param idx Index id of pulseaudio object.
 * @param userdata void* cast of pulseaudio_t
 */
void pa_subscription_cb(UNUSED pa_context *c, pa_subscription_event_type_t t, uint32_t idx, void *userdata) {
    pulseaudio_t *pulse = (pulseaudio_t *) userdata;
    lua_State *L = pulse->L;

    if ((t & PA_SUBSCRIPTION_EVENT_FACILITY_MASK) == PA_SUBSCRIPTION_EVENT_SINK) {
        if ((t & PA_SUBSCRIPTION_EVENT_TYPE_MASK) == PA_SUBSCRIPTION_EVENT_NEW) {
            lua_rawgeti(L, LUA_REGISTRYINDEX, pulse->tab_index);
            lua_rawgeti(L, -1, pulse->fn);

            get_args_t args;
            args.index = (int) idx;
            args.type = sink;

            lua_pushnumber(L, idx);
            lua_call(L, 1, 0);

            lua_pop(L, 2);
        }
    }
}

/**
 * Callback for the pulseaudio context state.
 * @param context Pulseaudio context pointer.
 * @param userdata void* cast of pulseaudio_t
 */
void pa_state_cb(pa_context *context, void *userdata) {
    pulseaudio_t *pulse = (pulseaudio_t *) userdata;

    switch (pa_context_get_state(context)) {
        case PA_CONTEXT_READY:
            printf("Context ready\n");
            pa_context_set_subscribe_callback(context, pa_subscription_cb, userdata);
            pa_operation *op = pa_context_subscribe(context, PA_SUBSCRIPTION_MASK_ALL, NULL, NULL);
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

/**
 * Puts the previous value from the lua stack into the table before that using the number index not a key.
 * @param L lua_State*
 */
void append_to_list(lua_State *L) {
    lua_len(L, -2);
    lua_Number size = lua_tonumber(L, -1);
    lua_remove(L, -1);

    lua_rawseti(L, -2, (int) size + 1);
}
