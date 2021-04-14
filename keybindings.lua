local awful = require( "awful" )
local gears = require( "gears" )
local hotkeys_popup = require( "awful.hotkeys_popup" )
require( "awful.hotkeys_popup.keys" )
local menubar = require( "menubar" )
local variables = require( 'variables' )

local r = { keyboard = {}, mouse = {} }

local function combine_tables(array)
    local _result = {}
    for _, v in ipairs( array ) do _result = gears.table.join( _result, v ) end
    return _result
end

r.combine_tables = combine_tables

r.keyboard.globalkeys = combine_tables( {
    awful.key( { variables.modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" } ),
    awful.key( { variables.modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" } ),
    awful.key( { variables.modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" } ),
    awful.key( { variables.modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" } ),

    awful.key( { variables.modkey }, "j", function() awful.client.focus.byidx( 1 ) end,
               { description = "focus next by index", group = "client" } ),
    awful.key( { variables.modkey }, "k", function() awful.client.focus.byidx( -1 ) end,
               { description = "focus previous by index", group = "client" } ),
    awful.key( { variables.modkey }, "w", function() require'window-manager.wibar'.mainmenu:show() end,
               { description = "show main menu", group = "awesome" } ), -- Layout manipulation
    awful.key( { variables.modkey, "Shift" }, "j", function() awful.client.swap.byidx( 1 ) end,
               { description = "swap with next client by index", group = "client" } ),
    awful.key( { variables.modkey, "Shift" }, "k", function() awful.client.swap.byidx( -1 ) end,
               { description = "swap with previous client by index", group = "client" } ),
    awful.key( { variables.modkey, "Control" }, "j", function() awful.screen.focus_relative( 1 ) end,
               { description = "focus the next screen", group = "screen" } ),
    awful.key( { variables.modkey, "Control" }, "k", function() awful.screen.focus_relative( -1 ) end,
               { description = "focus the previous screen", group = "screen" } ),
    awful.key( { variables.modkey }, "u", awful.client.urgent.jumpto,
               { description = "jump to urgent client", group = "client" } ),
    awful.key( { variables.modkey }, "Tab", function()
        awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end
    end, { description = "go back", group = "client" } ), -- Standard program
    awful.key( { variables.modkey }, "Return", function() awful.spawn( variables.terminal ) end,
               { description = "open a terminal", group = "launcher" } ),
    awful.key( { variables.modkey, "Control" }, "r", awesome.restart,
               { description = "reload awesome", group = "awesome" } ),
    awful.key( { variables.modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" } ),

    awful.key( { variables.modkey }, "l", function() awful.tag.incmwfact( 0.05 ) end,
               { description = "increase master width factor", group = "layout" } ),
    awful.key( { variables.modkey }, "h", function() awful.tag.incmwfact( -0.05 ) end,
               { description = "decrease master width factor", group = "layout" } ),
    awful.key( { variables.modkey, "Shift" }, "h", function() awful.tag.incnmaster( 1, nil, true ) end,
               { description = "increase the number of master clients", group = "layout" } ),
    awful.key( { variables.modkey, "Shift" }, "l", function() awful.tag.incnmaster( -1, nil, true ) end,
               { description = "decrease the number of master clients", group = "layout" } ),
    awful.key( { variables.modkey, "Control" }, "h", function() awful.tag.incncol( 1, nil, true ) end,
               { description = "increase the number of columns", group = "layout" } ),
    awful.key( { variables.modkey, "Control" }, "l", function() awful.tag.incncol( -1, nil, true ) end,
               { description = "decrease the number of columns", group = "layout" } ),
    awful.key( { variables.modkey }, "space", function() awful.layout.inc( 1 ) end,
               { description = "select next", group = "layout" } ),
    awful.key( { variables.modkey, "Shift" }, "space", function() awful.layout.inc( -1 ) end,
               { description = "select previous", group = "layout" } ),
    awful.key( { variables.modkey, "Control" }, "n", function()
        local c = awful.client.restore()
        -- Focus restored client
        if c then c:emit_signal( "request::activate", "key.unminimize", { raise = true } ) end
    end, { description = "restore minimized", group = "client" } ), -- Prompt
    awful.key( { variables.modkey }, "r", function() awful.screen.focused().promptbox:run() end,
               { description = "run prompt", group = "launcher" } ), awful.key( { variables.modkey }, "x", function()
        awful.prompt.run {
            prompt = "Run Lua code: ",
            textbox = awful.screen.focused().promptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval"
        }
    end, { description = "lua execute prompt", group = "awesome" } ), -- Menubar
    awful.key( { variables.modkey }, "p", function() menubar.show() end,
               { description = "show the menubar", group = "launcher" } )
} )

for i = 1, 9 do
    r.keyboard.globalkeys = gears.table.join( r.keyboard.globalkeys, combine_tables(
                                                  {
            awful.key( { variables.modkey }, "#" .. i + 9, function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then tag:view_only() end
            end, { description = "view tag #" .. i, group = "tag" } ), -- Toggle tag display.
            awful.key( { variables.modkey, "Control" }, "#" .. i + 9, function()
                local tag = awful.screen.focused().tags[i]
                if tag then awful.tag.viewtoggle( tag ) end
            end, { description = "toggle tag #" .. i, group = "tag" } ), -- Move client to tag.
            awful.key( { variables.modkey, "Shift" }, "#" .. i + 9, function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then client.focus:move_to_tag( tag ) end
                end
            end, { description = "move focused client to tag #" .. i, group = "tag" } ), -- Toggle tag on focused client.
            awful.key( { variables.modkey, "Control", "Shift" }, "#" .. i + 9, function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then client.focus:toggle_tag( tag ) end
                end
            end, { description = "toggle focused client on tag #" .. i, group = "tag" } )
        } ) )
end

r.mouse.tagList = combine_tables( {
    awful.button( {}, 1, function(t) t:view_only() end ),
    awful.button( { variables.modkey }, 1, function(t) if client.focus then client.focus:move_to_tag( t ) end end ),
    awful.button( {}, 3, awful.tag.viewtoggle ),
    awful.button( { variables.modkey }, 3, function(t) if client.focus then client.focus:toggle_tag( t ) end end ),
    awful.button( {}, 4, function(t) awful.tag.viewnext( t.screen ) end ),
    awful.button( {}, 5, function(t) awful.tag.viewprev( t.screen ) end )
} )

r.mouse.taskList = combine_tables( {
    awful.button( {}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal( "request::activate", "tasklist", { raise = true } )
        end
    end ), awful.button( {}, 3, function() awful.menu.client_list( { theme = { width = 250 } } ) end ),
    awful.button( {}, 4, function() awful.client.focus.byidx( 1 ) end ),
    awful.button( {}, 5, function() awful.client.focus.byidx( -1 ) end )
} )

r.keyboard.client = combine_tables( {
    awful.key( { variables.modkey }, "f", function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end, { description = "toggle fullscreen", group = "client" } ),
    awful.key( { variables.modkey, "Shift" }, "c", function(c) c:kill() end, { description = "close", group = "client" } ),
    awful.key( { variables.modkey, "Control" }, "space", awful.client.floating.toggle,
               { description = "toggle floating", group = "client" } ),
    awful.key( { variables.modkey, "Control" }, "Return", function(c) c:swap( awful.client.getmaster() ) end,
               { description = "move to master", group = "client" } ),
    awful.key( { variables.modkey }, "o", function(c) c:move_to_screen() end,
               { description = "move to screen", group = "client" } ),
    awful.key( { variables.modkey }, "t", function(c) c.ontop = not c.ontop end,
               { description = "toggle keep on top", group = "client" } ),
    awful.key( { variables.modkey }, "n", function(c) c.minimized = true end,
               { description = "minimize", group = "client" } ), awful.key( { variables.modkey }, "m", function(c)
        c.maximized = not c.maximized
        c:raise()
    end, { description = "(un)maximize", group = "client" } ),
    awful.key( { variables.modkey, "Control" }, "m", function(c)
        c.maximized_vertical = not c.maximized_vertical
        c:raise()
    end, { description = "(un)maximize vertically", group = "client" } ),
    awful.key( { variables.modkey, "Shift" }, "m", function(c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
    end, { description = "(un)maximize horizontally", group = "client" } )
} )

r.mouse.client = combine_tables( {
    awful.button( {}, 1, function(c) c:emit_signal( "request::activate", "mouse_click", { raise = true } ) end ),
    awful.button( { variables.modkey }, 1, function(c)
        c:emit_signal( "request::activate", "mouse_click", { raise = true } )
        awful.mouse.client.move( c )
    end ), awful.button( { variables.modkey }, 3, function(c)
        c:emit_signal( "request::activate", "mouse_click", { raise = true } )
        awful.mouse.client.resize( c )
    end )
} )

function r.Init() root.keys( r.keyboard.globalkeys ) end

return r
