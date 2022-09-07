#!/bin/env lua
--This is a visual test not a automatic test.
package.cpath = "../init.so;./init.so" .. package.cpath
local inspect = require "pl.import_into"().pretty.write
local pulseaudio = require "pulseaudio"

print(inspect(pulseaudio))
print(inspect(pulseaudio.get_object { type = "sink", index = 50 }))
print(inspect(pulseaudio.set_volume { type = "sink", index = 49, volume = 32768 }))
print(inspect(pulseaudio.mute_object { type = "sink", index = 49, mute = false }))
