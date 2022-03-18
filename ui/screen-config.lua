--------------------------------------------------
--
--      Screen configuration
--
--------------------------------------------------
local setmetatable = setmetatable

local awful = require "awful"
local beautiful = require "beautiful"
local gears = require "gears"
local hotkeysPopup = require "awful.hotkeys_popup"
local wibox = require "wibox"

local minitray = require "ui.widgets.minitray"
local utils = require "utils"
local aButton = utils.aButton

--------------------------------------------------

---@class ScreenConfig
---@field mainMenuEntries table<string, function>[] #The collection of entires in the main menu entires.
---@field mainMenu Object #The main menu object.
---@field launcher Object #Launcher object.
---@field textClock Object #Text clock object.
---@field tagListButtons Object[] #Collection of buttons used for taglist
---@field tasklistButtons Object[] #Collection of buttons used for tasklist
local screenConfig = { mt = {} }

function screenConfig.set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(tostring(wallpaper), s, true)
    end
end

---@param env EnvConfig
function screenConfig:new(env)
    screen.connect_signal("property::geometry", screenConfig.set_wallpaper)
    env = env or {}

    self.mainMenuEntries = {
        { "hotkeys", function() hotkeysPopup.show_help(nil, awful.screen.focused()) end, },
        { "manual", env.terminal .. " -e man awesome", },
        { "edit config", env.editorCmd .. " " .. awesome.conffile, },
        { "restart", awesome.restart, },
        { "quit", function() awesome.quit() end, },
    }
    self.mainMenu = awful.menu { items = { { "awesome", self.mainMenuEntries, beautiful.awesome_icon }, { "open terminal", env.terminal } }, }
    self.launcher = awful.widget.launcher { image = beautiful.awesome_icon, menu = self.mainMenu }

    self.textClock = wibox.widget.textclock()

    self.taglistButtons = {
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

    self.tasklistButtons = {
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

    return self
end

function screenConfig:_init(screen)
    screenConfig.set_wallpaper(screen)

    awful.tag({ "1", "2", "3", "4", "5", "6" }, screen, awful.layout.layouts[1])
    screen.prompt = awful.widget.prompt()

    screen.layoutbox = awful.widget.layoutbox(screen)
    screen.taglist = awful.widget.taglist {
        screen = screen,
        filter = awful.widget.taglist.filter.all,
        buttons = self.taglistButtons,
        widget_template = {
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
    screen.tasklist = awful.widget.tasklist {
        screen = screen,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = self.tasklistButtons,
        layout = {
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
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

    local seperator = wibox.widget {
        {
            orientation = "vertical",
            span_ratio = 0.8,
            thickness = 1,
            widget = wibox.widget.separator,
        },
        left = 3,
        right = 3,
        forced_width = 7,
        widget = wibox.container.margin,
    }

    screen.wibox = awful.wibar { position = beautiful["wibar_position"], screen = screen }
    screen.wibox:setup {
        {
            self.launcher,
            seperator,
            screen.taglist,
            seperator,
            layout = wibox.layout.fixed.horizontal,
        },
        screen.tasklist,
        {
            self.textClock,
            seperator,
            wibox.widget.systray(),
            seperator,
            screen.layoutbox,
            layout = wibox.layout.fixed.horizontal,
        },
        layout = wibox.layout.align.horizontal,
    }
end

function screenConfig.init(screen)
    screenConfig:_init(screen)
end

-- Metadata setup
--------------------------------------------------
function screenConfig.mt:__call(...)
    return screenConfig:new(...)
end

return setmetatable(screenConfig, screenConfig.mt)

--------------------------------------------------
-- EoF
--------------------------------------------------
