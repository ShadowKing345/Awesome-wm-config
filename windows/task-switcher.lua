local awful = require( 'awful' )
local wibox = require( 'wibox' )
local gears = require( 'gears' )
local hold = {
    awful.button( {}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal( "request::activate", "tasklist", { raise = true } )
        end
    end ), awful.button( {}, 3, function() awful.menu.client_list( { theme = { width = 250 } } ) end ),
    awful.button( {}, 4, function() awful.client.focus.byidx( 1 ) end ),
    awful.button( {}, 5, function() awful.client.focus.byidx( -1 ) end )
}
local mouse = { Mouse1 = 1, Mouse2 = 2, Mouse3 = 3, Mouse4 = 4, Mouse5 = 5 }
local keyboard = {
    Up = { "Up", "k" },
    Down = { "Down", "j" },
    Left = { "Left", "h" },
    Right = { "Right", "l" },
    Exec = { "Return" },
    Close = { "Escape" }
}

local ts = { ts = {} }

function ts.new(args)
    args = args or {}

    ts = {}
    -- Testing out widgets
    testWidget = wibox.widget {
        { value = 0.2, color = "#ff0000", widget = wibox.widget.progressbar },
        { value = 0.4, color = "#00ff00", widget = wibox.widget.progressbar },
        { value = 0.6, color = "#0000ff", widget = wibox.widget.progressbar },
        layout = wibox.layout.flex.vertical
    }
    print( testWidget )
    awful.widget.only_on_screen( testWidget, awful.screen.focused() )
    return ts
end

function ts.ts:__call(...) ts.new( ... ) end

return setmetatable( ts, ts.ts )
