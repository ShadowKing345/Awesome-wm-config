//
// Created by alex on 9/5/22.
//

#include "pulse/pulseaudio.h"

#ifndef PULSEAUDIO_CALLBACK_H
#define PULSEAUDIO_CALLBACK_H

void pa_server_info_cb(pa_context *context, const pa_server_info *info, void *userdata);

void pa_get_sink_cb(pa_context *context, const pa_sink_info *info, int eol, void *userdata);

void pa_get_sink_input_cb(pa_context *context, const pa_sink_input_info *info, int eol, void *userdata);

void pa_get_source_cb(pa_context *context, const pa_source_info *info, int eol, void *userdata);

void pa_get_source_output_cb(pa_context *context, const pa_source_output_info *info, int eol, void *userdata);

#endif //PULSEAUDIO_CALLBACK_H
