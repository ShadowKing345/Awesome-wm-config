--[[

        Volume widget.

]]
--------------------------------------------------
local awful     = require "awful"
local beautiful = require "beautiful"
local gears     = require "gears"
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

---@param obj PAObject
function M:_create_slider_widget(obj)
    if not obj then
        return nil
    end

    local slider = wibox.widget {
        bar_shape           = gears.shape.rounded_rect,
        bar_height          = 3,
        bar_color           = "#ff0000",
        handle_color        = "#00ff00",
        handle_width        = 10,
        handle_shape        = gears.shape.circle,
        handle_border_color = "#0000ff",
        handle_border_width = 1,
        minimum             = self.pulseaudio_service.defaults.volume_mute,
        maximum             = self.pulseaudio_service.defaults.volume_norm,
        widget              = wibox.widget.slider,
    }
    slider.value = obj.volume
    slider:connect_signal(
        "property::value",
        function(_, new_value)
            self.pulseaudio_service:volume { index = obj.index, amount = new_value, raw = true }
        end
    )

    return wibox.widget {
        slider,
        direction = "east",
        widget    = wibox.container.rotate,
    }
end

function M:init()
    local width = 50

    self.wibox = wibox {
        x = 10,
        y = 10,
        width = 50 * 3,
        height = 300,
        visible = false,
        ontop = true,
        widget = wibox.widget {
            {
                {
                    text   = "Output",
                    widget = wibox.widget.textbox,
                },
                {
                    text   = "Input",
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.flex.horizontal,
            },
            {
                self:_create_slider_widget(self.pulseaudio_service.objects.sink[1] or {}),
                layout = wibox.layout.fixed.horizontal,
            },
            layout = wibox.layout.align.vertical,
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
