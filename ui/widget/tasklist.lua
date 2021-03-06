--[[

    Custom Tasklist

--]]
--------------------------------------------------
local setmetatable = setmetatable

local awful     = require "awful"
local beautiful = require "beautiful"
local gTable    = require "gears.table"
local wibox     = require "wibox"

local aButton = require "utils".aButton

--------------------------------------------------
local M = { widgets = {}, mt = {} }

function M.default_buttons()
    return {
        aButton {
            modifiers = {},
            button = 1,
            callback = function(c)
                if c == client.focus then
                    c.minimized = true
                else
                    c:emit_signal("request::activate", "tasklist", { raise = true })
                end
            end,
        },
        aButton {
            modifiers = {},
            button = 3,
            callback = function() awful.menu.client_list { theme = { width = 250 } } end,
        },
        aButton {
            modifiers = {},
            button = 4,
            callback = function() awful.client.focus.byidx(1) end,
        },
        aButton {
            modifiers = {},
            button = 5,
            callback = function() awful.client.focus.byidx(-1) end,
        },
    }
end

function M.default_template(style)
    return {
        layout = {
            layout = wibox.layout.fixed.horizontal
        },
        template = {
            {

                nil,
                {
                    {
                        {
                            {
                                {
                                    id     = "icon_role",
                                    widget = wibox.widget.imagebox,
                                },
                                margins = 2,
                                widget  = wibox.container.margin,
                            },
                            {
                                id           = "text_role",
                                widget       = wibox.widget.textbox,
                                forced_width = beautiful["tasklist_width"] or 100,
                            },
                            layout = wibox.layout.fixed.horizontal,
                        },
                        left   = 2,
                        right  = 8,
                        widget = wibox.container.margin
                    },
                    widget = wibox.container.background,
                },
                {
                    id = "background_role",
                    widget = wibox.container.background,
                    forced_height = 3,
                },
                layout = wibox.layout.align.vertical,
            },
            id              = "bg",
            bg              = style.bg.normal,
            widget          = wibox.container.background,
            create_callback = function(self)
                local bg = self:get_children_by_id "bg"[1]

                if not bg then return end

                bg._private.bg = style.bg
                bg._private.fg = style.fg

                function bg:change_state(state)
                    self.bg = self._private.bg[state]
                    self.fg = self._private.fg[state]
                end

                bg:connect_signal("mouse::enter", function() bg:change_state "hover" end)
                bg:connect_signal("mouse::leave", function() bg:change_state "normal" end)
                bg:connect_signal("button::press",
                    function(_, _, _, button)
                        if button ~= 1 then return end
                        bg:change_state "active"
                    end)
                bg:connect_signal("button::release",
                    function(_, _, _, button)
                        if button ~= 1 then return end
                        bg:change_state "hover"
                    end)
            end,
        }
    }
end

function M.default_style()
    return {
        bg = {
            normal = beautiful["tasklist_bg_normal"],
            hover  = beautiful["tasklist_bg_hover"],
            active = beautiful["tasklist_bg_active"],
        },
        fg = {
            normal = beautiful["tasklist_fg_normal"],
            hover  = beautiful["tasklist_fg_hover"],
            active = beautiful["tasklist_fg_active"],
        }
    }
end

function M:new(args)
    args = args or {}
    args.style = gTable.merge(M.default_style(), args.style or {})
    local template = self.default_template(args.style)

    local w = awful.widget.tasklist {
        screen = args.screen,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = args.buttons,
        layout = template.layout,
        widget_template = template.template
    }
    table.insert(self.widgets, w)

    return w
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
