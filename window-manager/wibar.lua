local awful = require( "awful" )
local keybindings = require( "keybindings" )
local wibox = require( "wibox" )
local gears = require( "gears" )
local beautiful = require( "beautiful" )
local variables = require( "variables" )

local task_switcher = require( "widgets.task-switcher" )

local r = {}

r.mainmenu = awful.menu( {
    items = {
        {
            "Awesome", {
                { "Hotkeys", function()
                    require"awful.hotkeys_popup".show_help( nil, awful.screen.focused() )
                end }, { "Manual", variables.terminal .. " -e man awesome" },
                { "Edit Config", variables.editor_cmd .. " " .. awesome.conffile }, { "Reload Config", awesome.restart }
            }, beautiful.awesome_icon
        }, {
            "Power Options", {
                { "Logout", awesome.quit }, { "Reboot", function() awful.spawn( "reboot" ) end },
                { "Suspend", function() awful.spawn( "systemctl suspend" ) end },
                { "Shutdown", function() awful.spawn( "shutdown now" ) end }
            }
        }, { "Open Terminal", variables.terminal }
    }
} )

r.task_switcher = task_switcher({})

r.launcher = awful.widget.launcher( { image = beautiful.awesome_icon, menu = r.mainmenu }, {} )
r.textclock = wibox.widget.textclock()

function r.Init()
    awful.screen.connect_for_each_screen( function(s)
        -- Wallpaper
        require"theme".Set_wallpaper( s )

        -- Each screen has its own tag table.
        awful.tag( { "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1] )

        -- Create a promptbox for each screen
        s.promptbox = awful.widget.prompt()
        -- Create an imagebox widget which will contain an icon indicating which layout we're using.
        -- Create an imagebox widget which will contain an icon indicating which layout we're using.
        -- We need one layoutbox per screen.
        s.layoutbox = awful.widget.layoutbox( s )
        s.layoutbox:buttons( gears.table.join( awful.button( {}, 1, function() awful.layout.inc( 1 ) end ),
                                               awful.button( {}, 3, function() awful.layout.inc( -1 ) end ),
                                               awful.button( {}, 4, function() awful.layout.inc( 1 ) end ),
                                               awful.button( {}, 5, function() awful.layout.inc( -1 ) end ) ) )
        -- Create a taglist widget
        s.taglist = awful.widget.taglist {
            screen = s,
            filter = awful.widget.taglist.filter.all,
            buttons = keybindings.mouse.tagList
        }

        -- Create a tasklist widget
        s.tasklist = awful.widget.tasklist {
            screen = s,
            filter = awful.widget.tasklist.filter.currenttags,
            buttons = keybindings.mouse.taskList
        }

        -- Create the wibox
        s.wibox = awful.wibar( { position = "top", screen = s } )

        -- Add widgets to the wibox
        s.wibox:setup{
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                r.launcher,
                s.taglist,
                s.promptbox
            },
            s.tasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                wibox.widget.systray(),
                r.textclock,
                s.layoutbox
            }
        }
    end )
end

return r
