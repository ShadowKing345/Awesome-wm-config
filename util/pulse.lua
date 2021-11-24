local read = require("util.read")

local pulse = {mt = {}}

local function get_default(_type)
  _type = _type or "sink"
  local parse = read.output(string.format("pacmd dump | grep 'set-default-%s'", _type))
  local default_sink = string.match(parse, "set%-default%-%w+%s(.+)\r?\n")

  return default_sink
end

function pulse:init(args)
  args = args or {}

  self.default_sink = get_default()
  self.volume = 0

  function self:set_volume(amount)

  end

  function self:toggle_mute()

  end
end

function pulse.mt:__call(...)
  return pulse:init(...)
end

return setmetatable(pulse, pulse.mt)
