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

--local minitray = require "ui.widgets.minitray"
local taglist = require "ui.widgets.taglist"
local tasklist = require "ui.widgets.tasklist"

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

    self.taglistButtons = taglist.default_buttons(env)
    self.tasklistButtons = tasklist.default_buttons()

    return self
end

function screenConfig:_init(s)
    screenConfig.set_wallpaper(s)

    awful.tag({ "1", "2", "3", "4", "5", "6" }, s, awful.layout.layouts[1])
    s.prompt = awful.widget.prompt()

    s.layoutbox = awful.widget.layoutbox(s)
    s.taglist = taglist { buttons = self.taglistButtons, screen = s, }
    s.tasklist = tasklist { buttons = self.tasklistButtons, screen = s, }

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

    s.wibox = awful.wibar { position = beautiful["wibar_position"], screen = s }
    s.wibox:setup {
        {
            self.launcher,
            seperator,
            s.taglist,
            seperator,
            layout = wibox.layout.fixed.horizontal,
        },
        s.tasklist,
        {
            self.textClock,
            seperator,
            wibox.widget.systray(),
            seperator,
            s.layoutbox,
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
