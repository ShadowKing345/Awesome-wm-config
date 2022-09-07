#!/bin/env lua
--This is a visual test not a automatic test.
package.cpath = "../init.so;./init.so" .. package.cpath
local inspect = require "pl.import_into"().pretty.write
local pulseaudio = require "pulseaudio"

print(inspect(pulseaudio))
print(inspect(pulseaudio.get()))
