--------------------------------------------------
--
--      Custom Tasklist
--
--------------------------------------------------
local setmetatable = setmetatable
local table = table

local awful = require "awful"
local wibox = require "wibox"

local aButton = require "utils".aButton

--------------------------------------------------
local tasklist = { widgets = {}, mt = {} }

function tasklist.default_buttons()
    return {
        aButton {
            modifiers = {},
            button = 1,
            callback = function(c) if c == client.focus then c.minimized = true else c:emit_signal("request::activate", "tasklist", { raise = true }) end end,
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

---@return DefaultTemplate
function tasklist.default_template()
    return {
        layout = {
            layout = wibox.layout.fixed.horizontal
        },
        template = {
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
                            forced_width = 100,
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
        }
    }
end

---@param args {buttons:table,screen:table}
function tasklist:new(args)
    args = args or {}

    ---@type DefaultTemplate
    local template = self.default_template()

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

-- Metadata setup
--------------------------------------------------
function tasklist.mt:__call(...)
    return tasklist:new(...)
end

return setmetatable(tasklist, tasklist.mt)
