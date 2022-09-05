--[[

        Volume widget.

]]
--------------------------------------------------
local awful     = require "awful"
local beautiful = require "beautiful"
local gTable    = require "gears.table"
local wibox     = require "wibox"

local utils = require "utils"

--------------------------------------------------
local M = { mt = {}, wibox = nil, pulseaudio_service = nil }

function M.defaultStyle(style)
    local n = "widget_volume_"
    return utils.deepMerge({
        bg      = {
            normal = beautiful[n .. "bg_normal"],
            hover  = beautiful[n .. "bg_hover"],
            active = beautiful[n .. "bg_active"],
        },
        padding = beautiful[n .. "padding"] or 0,
        margin  = beautiful[n .. "margin"] or 0,
    }, style or {})
end

function M:init()
    self.wibox = wibox {
        x = 10,
        y = 10,
        width = 250,
        height = 30,
        visible = false,
        ontop = true,
        widget = wibox.widget {
            text = self.pulseaudio_service:volume {},
            widget = wibox.widget.textbox,
        }
    }
end

function M:toggle(args)
    args = args or {}

    if not self.wibox then
        self:init()
    end

    if self.wibox.visible then
        self:hide()
    else
        self:show(args)
    end
end

function M:show(args)
    args = args or {}

    if not self.wibox then
        self:init()
    end

    ((args.geometry and awful.placement.next_to or awful.placement.under_mouse) + awful.placement.no_offscreen)
    (self.wibox, { geometry = args.geometry })

    self.wibox.visible = true
end

function M:hide()
    if not self.wibox then
        self:init()
    end

    self.wibox.visible = false
end

function M:new(args)
    args = args or {}
    local style = self.defaultStyle(args.style or {})

    if not self.pulseaudio_service or args.force_reload then
        self.pulseaudio_service = args.env.pulseaudio_service or nil
    end

    if not self.wibox then
        self:init()
    end

    local button = wibox.widget {
        {
            {
                image  = beautiful.awesome_icon,
                widget = wibox.widget.imagebox,
            },
            margins = style.padding,
            widget  = wibox.container.margin,
        },
        bg     = style.bg.normal,
        widget = wibox.container.background,
    }

    local w = wibox.widget {
        button,
        margins = style.margin,
        widget  = wibox.container.margin,
    }

    button:connect_signal("mouse::enter", function() button.bg = style.bg.hover end)
    button:connect_signal("mouse::leave", function() button.bg = style.bg.normal end)
    button:buttons(gTable.join(
        args.buttons or {},
        awful.button({}, 1, function() button.bg = style.bg.active end, function() button.bg = style.bg.hover end)
    ))
    button:connect_signal("button::press", function(_, _, _, _, _, geometry)
        self:toggle { geometry = geometry }
    end)

    gTable.crush(w, self, false)

    return w
end

--------------------------------------------------
function M.mt:__call(args)
    return M:new(args)
end

return setmetatable(M, M.mt)
