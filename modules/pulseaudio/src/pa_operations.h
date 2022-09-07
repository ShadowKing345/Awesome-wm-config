//
// Created by alex on 9/5/22.
//

#ifndef PULSEAUDIO_PA_OPERATIONS_H
#define PULSEAUDIO_PA_OPERATIONS_H

typedef void (*cb)();

typedef pa_operation *(*pFunction)(pa_context *, cb, void *);

int pa_get(pulseaudio_t *pulse, enum PA_TYPE type);

int pa_volume(pulseaudio_t *pulse, enum PA_TYPE type);

int pa_mute(pulseaudio_t *pulse, enum PA_TYPE type);

int pa_init(pulseaudio_t *pulse);

void pa_deinit(pulseaudio_t *pulse);

#endif //PULSEAUDIO_PA_OPERATIONS_H
