#!/bin/env lua
--This is a visual test not a automatic test.
package.cpath = "../init.so;./init.so;" .. package.cpath
local inspect = require "pl.import_into"().pretty.write
local pulseaudio = require "pulseaudio"

print(inspect(pulseaudio))

print(inspect(pulseaudio.set_default_sink_source(function(index)
    print(index)
    --print(inspect(pulseaudio.get_object { type = "sink", index = index }))
end)))

while true do
    io.popen("sleep 1"):close()
end

--print(inspect(pulseaudio.get_object {}))
--print(inspect(pulseaudio.set_volume { type = "sink", index = 174, volume = 655 }))
-- print(inspect(pulseaudio.mute_object { type = "sink", index = 49, mute = false }))
