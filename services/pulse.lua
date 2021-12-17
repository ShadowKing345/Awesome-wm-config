local read = require("util.read")
local awful = require("awful")
local util = require("util")
local naughty = require("naughty")

local pulse = {mt = {}}

local change_volume_default_args = {down = false, step = math.floor(65536 / 100 * 5 + 0.5), show_notify = false}

local function get_default_sink(_type)
  _type = _type or "sink"
  local parse = read.output(string.format("pacmd dump | grep 'set-default-%s'", _type))
  local default_sink = string.match(parse, "set%-default%-%w+%s(.+)\r?\n")

  return default_sink
end

function pulse:change_volume(args)
  args = util.table.merge(change_volume_default_args, args or {})
  local diff = args.down and -args.step or args.step

  local volume = math.max(math.min(self:get_volume_raw() + diff, 65536, 0))

  awful.spawn(string.format("pacmd set-%s-volume %s %s", self._type, self._sink, volume))
end

function pulse:change_volume_exact(amount)
  awful.spawn(string.format("pacmd set-%s-volume %s %s", self._type, self._sink, math.max(math.min(math.floor(65536 * amount / 100), 65536), 0)))
end

function pulse:get_volume_raw()
  local v = read.output(string.format("pacmd dump | grep 'set-%s-volume %s'", self._type, self._sink))
  local parsed = string.match(v, "0x%x+")

  if not parsed then
    naughty.notify {title = "Warning!", text = "PA service could not parse the pacmd output"}
    return
  end

  return tonumber(parsed)
end

function pulse:get_volume()
  return self:get_volume_raw() / 65536 * 100
end

function pulse:init(args)
  args = args or {}

  self._type = args.type or "sink"
  self._sink = get_default_sink()
end

function pulse.mt:__call(...)
  return pulse:init(...)
end

return setmetatable(pulse, pulse.mt)
