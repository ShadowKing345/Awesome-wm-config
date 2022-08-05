--[[

    Intializer for desktop docks.

--]]
--------------------------------------------------
local awful     = require "awful"
local beautiful = require "beautiful"
local gTable    = require "gears.table"
local wibox     = require "wibox"

local clock = require "ui.desktop.clock"

--------------------------------------------------
---@type Desktop
local M = { mt = {} }

--- Creates a new instance of the wallpaper widget(?) and returns it.
---@return unknown
function M:createWallpaper(s)
    local wallpaper = beautiful.wallpaper

    if type(wallpaper) == "function" then
        wallpaper = wallpaper()
    end

    local w = awful.wallpaper {
        honor_workarea = true,
        screen         = s,
        widget         = {
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

--- Reloads all widgets and wallpaper of a desktop. If they do not exist it will create them instead.
function M:reload()
    if not self.wallpaper then
        self.wallpaper = self:createWallpaper(self.screen)
    end
end

--- Creates a new desktop manager.
---@param env EnvConfig #Environment configs
---@return any #Returns the
function M:new(s, env)

    local obj = {
        env    = env or {},
        screen = s,
    }

    gTable.crush(obj, M, true)

    return obj
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)

--------------------------------------------------

---@class Desktop #Desktop object used to manager the desktop for each screen.
---@field env EnvConfig #Environment configurations set on setup.
---@field mt any #Metadata table.
---@field wallpaper any #Wallpaper widget.
---@field screen any #Screen for desktop.
