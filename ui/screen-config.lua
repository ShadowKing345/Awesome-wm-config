--[[

    Screen configuration

--]]
--------------------------------------------------
local setmetatable = setmetatable

local awful      = require "awful"
local beautiful  = require "beautiful"
local wibox      = require "wibox"
local xresources = require "beautiful.xresources"
local dpi        = xresources.apply_dpi

local mainMenu = require "ui.widget.mainMenu"
local taglist  = require "ui.widget.taglist"
local tasklist = require "ui.widget.tasklist"
local utils    = require "utils"

--------------------------------------------------
---@class ScreenConfig
---@field mainMenuEntries table<string, function>[] #The collection of entires in the main menu entires.
---@field mainMenu table #The main menu object.
---@field launcher table #Launcher object.
---@field textClock table #Text clock object.
---@field tagListButtons table[] #Collection of buttons used for taglist
---@field tasklistButtons table[] #Collection of buttons used for tasklist
local M = {
    mt         = {},
    wallpapers = {},
}

function M.createWallpaper()
    local wallpaper = beautiful.wallpaper

    if type(wallpaper) == "function" then
        wallpaper = wallpaper()
    end

    local w = awful.wallpaper {
        widget = {
            bg             = beautiful.bg_normal,
            honor_workarea = true,
            image          = wallpaper,
            widget         = wibox.widget.imagebox,
        },
    }

    return w
end

---@param env EnvConfig
function M:new(env)
    screen.connect_signal("request::wallpaper", function(ctx)
        local wallpaper = self.wallpapers[ctx]
        if not wallpaper then
            wallpaper = self.createWallpaper()
            self.wallpapers[ctx] = wallpaper
        end

        wallpaper.screen = ctx
    end)
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

    beautiful.wibar_height = beautiful.wibar_height + dpi(1)

    return self
end

function M:_init(s)
    awful.tag({ "1", "2", "3", "4", "5", "6" }, s, awful.layout.layouts[1])

    s.layoutbox = awful.widget.layoutbox(s)
    s.taglist = taglist { buttons = self.taglistButtons, screen = s, }
    s.tasklist = tasklist { buttons = self.tasklistButtons, screen = s, }

    local separator = wibox.widget {
        {
            orientation = "vertical",
            span_ratio = 0.8,
            thickness = dpi(1),
            widget = wibox.widget.separator,
        },
        left = dpi(3),
        right = dpi(3),
        forced_width = dpi(7),
        widget = wibox.container.margin,
    }

    s.wibox = awful.wibar {
        position = beautiful["wibar_position"],
        screen   = s,
        widget   = {
            {
                forced_height = dpi(1),
                widget        = wibox.widget.separator,
            },
            {
                {
                    self.launcher,
                    separator,
                    s.taglist,
                    separator,
                    layout = wibox.layout.fixed.horizontal,
                },
                s.tasklist,
                {
                    self.textClock,
                    separator,
                    self.systray,
                    separator,
                    s.layoutbox,
                    layout = wibox.layout.fixed.horizontal,
                },
                layout = wibox.layout.align.horizontal,
            },
            layout = wibox.layout.fixed.vertical,
        }
    }
end

function M.init(screen)
    M:_init(screen)
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
