local pulse = require("services.pulse")
local playerctl = require("services.playerctl")

local function init(args)
  pulse(args)
  playerctl(args)
end

return setmetatable({}, {
  __call = function()
    return init()
  end,
})
