local inspect = require "pl.import_into" ().pretty.write
local pulseaudio = require "pulseaudio"

print(inspect(pulseaudio.get_sinks()))
print(inspect(pulseaudio.get_sink_inputs()))
print(inspect(pulseaudio.get_sources()))
print(inspect(pulseaudio.get_source_outputs()))
