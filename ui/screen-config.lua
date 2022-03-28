--------------------------------------------------
--
--      Screen configuration
--
--------------------------------------------------
local setmetatable = setmetatable

local awful = require "awful"
local beautiful = require "beautiful"
local gears = require "gears"
local wibox = require "wibox"

local mainMenu = require "ui.widgets.mainMenu"
local taglist = require "ui.widgets.taglist"
local tasklist = require "ui.widgets.tasklist"
local utils = require "utils"

--------------------------------------------------
---@class ScreenConfig
---@field mainMenuEntries table<string, function>[] #The collection of entires in the main menu entires.
---@field mainMenu table #The main menu object.
---@field launcher table #Launcher object.
---@field textClock table #Text clock object.
---@field tagListButtons table[] #Collection of buttons used for taglist
---@field tasklistButtons table[] #Collection of buttons used for tasklist
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

    self.mainMenu = mainMenu(env)
    self.launcher = awful.widget.button {
        image = beautiful.awesome_icon,
        buttons = {
            utils.aButton {
                modifiers = {},
                button = 1,
                callback = function()
                    local geometry = mouse.screen.geometry
                    geometry.y = geometry.height
                    self.mainMenu:toggle {
                        coords = geometry,
                        screen = mouse.screen
                    }
                end,
            }
        }
    }

    self.textClock = wibox.widget.textclock()

    self.taglistButtons = taglist.default_buttons(env)
    self.tasklistButtons = tasklist.default_buttons()

    self.systray = wibox.widget.systray()

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
            self.systray,
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

--------------------------------------------------
function screenConfig.mt:__call(...)
    return screenConfig:new(...)
end

return setmetatable(screenConfig, screenConfig.mt)
