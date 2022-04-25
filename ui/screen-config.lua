--[[

    Screen configuration

--]]
--------------------------------------------------
local setmetatable = setmetatable

local awful     = require "awful"
local beautiful = require "beautiful"
local dpi       = require "beautiful.xresources".apply_dpi
local wibox     = require "wibox"

local mainMenu = require "ui.widget.mainMenu"
local taglist  = require "ui.widget.taglist"
local tasklist = require "ui.widget.tasklist"
local systray  = require "ui.widget.systray"
local wibar    = require "ui.widget.wibar"
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
        honor_workarea = true,
        widget = {
            bg         = beautiful["wallpaper_bg"] or beautiful.bg_normal,
            halign     = "center",
            valign     = "center",
            image      = wallpaper,
            stylesheet = beautiful["wallpaper_stylesheet"] or nil,
            widget     = wibox.widget.imagebox,
        },
    }

    return w
end

--- Sets up a new instance of a wallpaper.
--- Will just update the widget if one already exists.
---@param ctx any
function M.setupWallpaper(ctx)
    local wallpaper = M.wallpapers[ctx]
    if not wallpaper then
        wallpaper = M.createWallpaper()
        M.wallpapers[ctx] = wallpaper
    end

    wallpaper.screen = ctx
end

---@param env EnvConfig
function M:new(env)
    env = env or {}

    screen.connect_signal("request::wallpaper", M.setupWallpaper)

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

    beautiful.wibar_height = beautiful.wibar_height + (beautiful["wibar_border_width_top"] or dpi(1))

    return self
end

function M:_init(s)
    local tags = { "1", "2", "3", "4", "5", "6" }
    awful.tag(tags, s, awful.layout.layouts[1])

    s.layoutbox = awful.widget.layoutbox(s)
    s.taglist   = taglist { buttons = self.taglistButtons, screen = s, }
    s.tasklist  = tasklist { buttons = self.tasklistButtons, screen = s, }
    s.systray   = systray {}

    s.wibox = wibar {
        screen    = s,
        taglist   = s.taglist,
        tasklist  = s.tasklist,
        launcher  = self.launcher,
        clock     = self.textClock,
        systray   = s.systray,
        layoutbox = s.layoutbox,
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
