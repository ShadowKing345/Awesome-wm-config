--[[

    Screen configuration

--]]
--------------------------------------------------
local setmetatable = setmetatable

local awful     = require "awful"
local beautiful = require "beautiful"
local dpi       = require "beautiful.xresources".apply_dpi
local wibox     = require "wibox"

local desktop   = require "ui.desktop"
local layoutbox = require "ui.widget.layoutbox"
local mainMenu  = require "ui.widget.mainMenu"
local taglist   = require "ui.widget.taglist"
local tasklist  = require "ui.widget.tasklist"
local systray   = require "ui.widget.systray"
local wibar     = require "ui.widget.wibar"

--------------------------------------------------
---@class ScreenConfig
---@field mainMenuEntries table<string, function>[] #The collection of entires in the main menu entires.
---@field mainMenu table #The main menu object.
---@field launcher table #Launcher object.
---@field textClock table #Text clock object.
---@field tagListButtons table[] #Collection of buttons used for taglist.
---@field tasklistButtons table[] #Collection of buttons used for tasklist.
---@field tags string[] #Collection of string to be used for the tags.
local M = {
    mt       = {},
    desktops = {},
}

---Runs the setup procedures for each screen.
---@param s any #The screen.
function M:connectScreen(s)
    awful.tag(self.tags or {}, s, awful.layout.layouts[1])

    s.layoutbox = layoutbox { screen = s, }
    s.taglist   = taglist { buttons = self.taglistButtons, screen = s, }
    s.tasklist  = tasklist { buttons = self.tasklistButtons, screen = s, }
    s.systray   = systray {}

    s.wibox = wibar {
        screen    = s,
        taglist   = s.taglist,
        tasklist  = s.tasklist,
        launcher  = self.mainMenu:createLauncher(),
        clock     = self.textClock,
        systray   = s.systray,
        layoutbox = s.layoutbox,
    }
end

---Creates a new desktop instance and/or reloads it.
---@param s any #The screen in question.
function M:requestDesktop(s)
    local d = self.desktops[s]
    if not d then
        d = desktop(s, self.env)
        self.desktops[s.index] = d
    end

    d:reload()
end

---Creates a new instance of the screen configuration module.
---@param env EnvConfig
function M:new(env)
    env = env or {}

    self.env = env

    self.mainMenu  = mainMenu(env)
    self.textClock = wibox.widget.textclock()

    self.taglistButtons  = taglist.default_buttons(env)
    self.tasklistButtons = tasklist.default_buttons()

    self.tags = env.tags or {}


    beautiful.wibar_height = beautiful.wibar_height + (beautiful["wibar_border_width_top"] or dpi(1))

    screen.connect_signal("request::wallpaper", function(s) self:requestDesktop(s) end)
    screen.connect_signal("request::desktop_decoration", function(s) self:connectScreen(s) end)

    return self
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
