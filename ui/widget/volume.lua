--[[

        Volume widget.

]]
--------------------------------------------------
local awful     = require "awful"
local beautiful = require "beautiful"
local gShape    = require "gears.shape"
local gTable    = require "gears.table"
local wibox     = require "wibox"

local utils = require "utils"

--------------------------------------------------
local M = {
    mt                 = {},
    wibox              = nil,
    ---@type PulseAudioService
    pulseaudio_service = nil,
    wibox_style        = nil,
    sliders            = nil,
}

function M.default_style(style)
    local n = "widget_volume_"
    local w = n .. "wibox_"
    local s = w .. "slider_"
    return utils.deepMerge({
        bg      = {
            normal = beautiful[n .. "bg_normal"],
            hover  = beautiful[n .. "bg_hover"],
            active = beautiful[n .. "bg_active"],
        },
        padding = beautiful[n .. "padding"] or 0,
        margin  = beautiful[n .. "margin"] or 0,
        wibox   = {
            button = {
                bg = {
                    normal = beautiful[w .. "button_bg_normal"],
                    hover  = beautiful[w .. "button_bg_hover"],
                    active = beautiful[w .. "button_bg_active"],
                },
                fg = {
                    normal = beautiful[w .. "button_fg_normal"],
                    hover  = beautiful[w .. "button_fg_hover"],
                    active = beautiful[w .. "button_fg_active"],
                },
                padding = beautiful[w .. "button_padding"] or 0,
            },
            slider = {
                width  = beautiful[s .. "width"] or 50,
                bg     = beautiful[s .. "bg"],
                handle = {
                    color        = beautiful[s .. "handle_color"] or beautiful.bg_focus,
                    shape        = beautiful[s .. "handle_shape"] or gShape.circle,
                    width        = beautiful[s .. "handle_width"] or 10,
                    border_color = beautiful[s .. "handle_border_color"],
                    border_width = beautiful[s .. "handle_border_width"] or 0,
                },
                bar    = {
                    height = beautiful[s .. "bar_height"] or 3,
                    color  = beautiful[s .. "bar_color"],
                    shape  = beautiful[s .. "bar_shape"] or gShape.rounded_rect,
                }
            },
        },
    }, style or {})
end

---@param obj PAObject
---@return any
function M:_create_slider_widget(obj, style)
    if not (obj and style) then
        return nil
    end

    local slider = wibox.widget {
        bar_shape           = style.bar.shape,
        bar_height          = style.bar.height,
        bar_color           = style.bar.color,
        handle_color        = style.handle.color,
        handle_width        = style.handle.width,
        handle_shape        = style.handle.shape,
        handle_border_color = style.handle.border_color,
        handle_border_width = style.handle.border_width,
        minimum             = self.pulseaudio_service.defaults.volume_mute,
        maximum             = self.pulseaudio_service.defaults.volume_norm,
        widget              = wibox.widget.slider,
    }
    slider.value = obj.volume or 1
    slider:connect_signal(
        "property::value",
        function(_, new_value)
            self.pulseaudio_service:volume { index = obj.index, amount = new_value, raw = true }
        end
    )
    slider._pa_obj = obj

    self.pulseaudio_service:connect_signal("update::object", function(pa_obj)
        if pa_obj.index == slider._pa_obj.index and pa_obj.type == slider._pa_obj.type then
            slider.value = pa_obj.volume
        end
        slider:emit_signal "widget::update"
    end)

    return wibox.widget {
        {
            slider,
            direction = "east",
            widget    = wibox.container.rotate,
        },
        bg           = style.bg,
        forced_width = style.width,
        widget       = wibox.container.background,
    }
end

function M:_get_sliders(force, style)
    style = style or self.wibox_style.slider
    if self.slider_widgets and not force then
        return
    end

    local objs = self.pulseaudio_service:get_objects(self.pulseaudio_service.PA_TYPES.ALL, true)

    self.slider_widgets = {
        layout = wibox.layout.fixed.horizontal,
    }

    for _, obj in ipairs(objs) do
        table.insert(self.slider_widgets, self:_create_slider_widget(obj, style))
    end
end

local function _gen_button(text, style, button)
    local btn = wibox.widget {
        {
            {
                text   = text,
                align  = "center",
                widget = wibox.widget.textbox,
            },
            margins = style.padding,
            widget  = wibox.container.margin,
        },
        bg     = style.bg.normal,
        fg     = style.fg.normal,
        widget = wibox.container.background,
    }

    btn:connect_signal("mouse::enter",
        function()
            btn.bg = style.bg.hover
            btn.fg = style.fg.hover
        end)
    btn:connect_signal("mouse::leave",
        function()
            btn.bg = style.bg.normal
            btn.fg = style.fg.normal
        end)
    btn:buttons(gTable.join(
        button or {},
        awful.button({}, 1,
            function()
                btn.bg = style.bg.active
                btn.fg = style.fg.active
            end,
            function()
                btn.bg = style.bg.hover
                btn.fg = style.fg.hover
            end
        )
    ))
    return btn
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

function M:init(style)
    if not self.wibox_style then
        self.wibox_style = style
    end
    style = style or self.wibox_style

    self:_get_sliders(true, style.slider)

    local output_btn = _gen_button("output", style.button, awful.button({}, 1, function() end))
    local input_btn  = _gen_button("input", style.button, awful.button({}, 1, function() end))

    self.wibox = wibox {
        x = 10,
        y = 10,
        width = style.slider.width * 4,
        height = 300,
        visible = false,
        ontop = true,
        widget = wibox.widget
        {
            {
                output_btn,
                input_btn,
                layout = wibox.layout.flex.horizontal,
            },
            self.slider_widgets,
            layout = wibox.layout.align.vertical,
        }
    }

    self.pulseaudio_service:connect_signal("update::all", function() self:_get_sliders(true) end)
end

function M:new(args)
    args = args or {}
    local style = self.default_style(args.style or {})

    if not self.pulseaudio_service or args.force_reload then
        self.pulseaudio_service = args.env.pulseaudio_service or nil
    end

    if not self.wibox then
        self:init(style.wibox)
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
