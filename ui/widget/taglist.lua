--[[

    Custom Taglist

--]]
--------------------------------------------------
local setmetatable = setmetatable

local awful     = require "awful"
local beautiful = require "beautiful"
local gTable    = require "gears.table"
local wibox     = require "wibox"

local aButton = require "utils".aButton

--------------------------------------------------
local M = { mt = {} }

---@param env EnvArgs
function M.default_buttons(env)
    return {
        aButton {
            modifiers = {},
            button = 1,
            callback = function(t) t:view_only() end,
        },
        aButton {
            modifiers = { env.modKey },
            button = 1,
            callback = function(t) if client.focus then client.focus:move_to_tag(t) end end,
        },
        aButton {
            modifiers = {},
            button = 3,
            callback = awful.tag.viewtoggle,
        },
        aButton {
            modifiers = { env.modKey },
            button = 3,
            callback = function(t) if client.focus then client.focus:toggle_tag(t) end end,
        },
        aButton {
            modifiers = {},
            button = 4,
            callback = function(t) awful.tag.viewnext(t.screen) end,
        },
        aButton {
            modifiers = {},
            button = 5,
            callback = function(t) awful.tag.viewprev(t.screen) end,
        },
    }
end

function M.default_template(style)
    return {
        template = {
            {
                nil,
                {
                    {
                        id = "text_role",
                        widget = wibox.widget.textbox,
                        align = "center",
                    },
                    widget = wibox.container.background,
                    forced_width = 30
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
        },
    }
end

function M.default_style()
    return {
        bg = {
            normal = beautiful["taglist_bg_normal"],
            hover  = beautiful["taglist_bg_hover"],
            active = beautiful["taglist_bg_active"],
        },
        fg = {
            normal = beautiful["taglist_fg_normal"],
            hover  = beautiful["taglist_fg_hover"],
            active = beautiful["taglist_fg_active"],
        }
    }
end

function M:new(args)
    args = args or {}
    args.style = gTable.merge(M.default_style(), args.style or {})

    local template = self.default_template(args.style)

    local w = awful.widget.taglist {
        screen = args.screen,
        filter = awful.widget.taglist.filter.all,
        buttons = args.buttons,
        widget_template = template.template
    }

    gTable.crush(w, M, true)

    return w
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
