//
// Created by alex on 9/5/22.
//

#define UNUSED __attribute((unused))

#include <lua.h>
#include <string.h>

#include "callbacks.h"
#include "types.h"

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
        append_to_list(L);
    }
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

void append_to_list(lua_State *L) {
    lua_len(L, -2);
    lua_Number size = lua_tonumber(L, -1);
    lua_remove(L, -1);

    lua_rawseti(L, -2, (int) size + 1);
}
