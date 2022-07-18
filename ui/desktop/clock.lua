--[[

    Desktop clock widget.

--]]
--------------------------------------------------
local wibox = require "wibox"
--------------------------------------------------
local M = { mt = {} }

---Creates a new instance of the desktop clock widget.
---@param env EnvConfig #Environment variables.
---@return any #The clock widget.
function M:new(env)
    local w = wibox.widget {
        {
            {
                refresh = 1,
                format  = "%A, %B %d %Y, %T",
                widget  = wibox.widget.textclock,
            },
            widget = wibox.container.place,
        },
        margins = 20,
        widget  = wibox.container.margin,
    }

    return w
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
