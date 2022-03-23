--------------------------------------------------
--
--      Custom Taglist
--
--------------------------------------------------
local setmetatable = setmetatable

local awful = require "awful"
local wibox = require "wibox"

local aButton = require "utils".aButton

--------------------------------------------------
---@type WidgetModule
local taglist = { widgets = {}, mt = {} }

---@param env EnvArgs
function taglist.default_buttons(env)
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

---@return DefaultTemplate
function taglist.default_template()
    return {
        template = {
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
        }
    }
end

---@param args {buttons:table,screen:table}
function taglist:new(args)
    args = args or {}

    ---@type DefaultTemplate
    local template = self.default_template()

    local w = awful.widget.taglist {
        screen = args.screen,
        filter = awful.widget.taglist.filter.all,
        buttons = args.buttons,
        widget_template = template.template
    }
    table.insert(self.widgets, w)

    return w
end

-- Metadata setup
--------------------------------------------------
function taglist.mt:__call(...)
    return taglist:new(...)
end

return setmetatable(taglist, taglist.mt)
