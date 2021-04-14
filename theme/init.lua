local beautiful = require( 'beautiful' )
local gears = require( 'gears' )

local r = {}

function r.Init()
    beautiful.init( gears.filesystem.get_themes_dir() .. "default/theme.lua" )
    screen.connect_signal( "property::geometry", r.Set_wallpaper )
end

function r.Set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type( wallpaper ) == "function" then wallpaper = wallpaper( s ) end
        gears.wallpaper.maximized( wallpaper, s, true )
    end
end

return r
