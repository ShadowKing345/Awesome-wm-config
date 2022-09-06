//
// Created by alex on 9/5/22.
//

#ifndef PULSEAUDIO_PA_UTILS_C_H
#define PULSEAUDIO_PA_UTILS_C_H

typedef void (*cb)();

typedef pa_operation *(*pFunction)(pa_context *, cb, void *);

typedef pa_operation *(*pFunctionI)(pa_context *, uint32_t, cb, void *);


int pa_init(pulseaudio_t *pulse);

void pa_deinit(pulseaudio_t *pulse);

void pa_get_sink_inputs(pulseaudio_t *pulse);

void pa_get_sources(pulseaudio_t *pulse);

void pa_get_source_outputs(pulseaudio_t *pulse);

void pa_get_sinks(pulseaudio_t *pulse);

void pa_get_all(pulseaudio_t *pulse);

void pa_volume_sink(pulseaudio_t *pulseaudio);

void pa_volume_sink_input(pulseaudio_t *pulseaudio);

void pa_volume_source(pulseaudio_t *pulseaudio);

void pa_volume_source_output(pulseaudio_t *pulseaudio);

void pa_mute_sink(pulseaudio_t *pulse);

void pa_mute_sink_input(pulseaudio_t *pulseaudio);

void pa_mute_source(pulseaudio_t *pulseaudio);

void pa_mute_source_output(pulseaudio_t *pulseaudio);

#endif //PULSEAUDIO_PA_UTILS_C_H
