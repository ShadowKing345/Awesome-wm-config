--[[

    Intializer for desktop docks.

--]]
--------------------------------------------------
local awful     = require "awful"
local beautiful = require "beautiful"
local wibox     = require "wibox"

local clock = require "ui.desktop.clock"

--------------------------------------------------
local M = { mt = {} }

---Creates a new wibox base for the desktop.
---@return any #The wibox.
local function createWidget()
    return wibox {
        visible = true,
        type    = "desktop",
        bg      = beautiful.bg_normal .. "55",
    }
end

function M:new(s, env)
    local workarea = s.workarea
    local widgets = {
        clock = createWidget(),
        sound = createWidget(),
    }

    widgets.clock.x      = workarea.x + workarea.width / 2 - 200
    widgets.clock.y      = workarea.y + 10
    widgets.clock.width  = 400
    widgets.clock.height = 100
    widgets.clock.widget = clock(env)

    widgets.sound.x      = 10
    widgets.sound.y      = workarea.height - 10 - 400
    widgets.sound.width  = 400
    widgets.sound.height = 400
    widgets.sound.bg     = "#ff0000"

    return widgets
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
