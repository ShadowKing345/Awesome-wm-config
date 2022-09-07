//
// Created by alex on 9/5/22.
//

#ifndef PULSEAUDIO_PA_OPERATIONS_H
#define PULSEAUDIO_PA_OPERATIONS_H

typedef void (*cb)();

typedef pa_operation *(*pFunction)(pa_context *, cb, void *);

int pa_get(pulseaudio_t *pulse, void *userdata);

int pa_set_volume(pulseaudio_t *pulse, void *userdata);

int pa_mute_object(pulseaudio_t *pulse, void *userdata);

int pa_init(pulseaudio_t *pulse);

void pa_deinit(pulseaudio_t *pulse);

#endif //PULSEAUDIO_PA_OPERATIONS_H
