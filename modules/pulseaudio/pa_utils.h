#include "types.h"

void pa_get_sinks(pulseaudio_t *pulse);
void pa_get_sink_inputs(pulseaudio_t *pulse);
void pa_get_sources(pulseaudio_t *pulse);
void pa_get_source_outputs(pulseaudio_t *pulse);
void pa_server_info_cb(pa_context *context, const pa_server_info *info,
                       void *userdata);
int pa_init(pulseaudio_t *pulse);
void pa_deinit(pulseaudio_t *pulse);
