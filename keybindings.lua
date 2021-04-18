local awful = require( "awful" )
local gears = require( "gears" )
local hotkeys_popup = require( "awful.hotkeys_popup" )
require( "awful.hotkeys_popup.keys" )
local menubar = require( "menubar" )
local variables = require( "variables" )

local r = { keyboard = {}, mouse = {} }
local modkey = { variables.modkey }
local modkey_shift = { variables.modkey, "Shift" }
local modkey_contl = { variables.modkey, "Control" }

local function combine_tables(array)
    local _result = {}
    for _, v in ipairs( array ) do _result = gears.table.join( _result, v ) end
    return _result
end

r.combine_tables = combine_tables

local c = "Client"
r.keyboard.client = combine_tables( {
    awful.key( modkey, "l", function() awful.client.focus.byidx( 1 ) end,
               { description = "focus next by index", group = c } ),
    awful.key( modkey, "h", function() awful.client.focus.byidx( -1 ) end,
               { description = "focus previous by index", group = c } ),
    awful.key( modkey_shift, "l", function() awful.client.swap.byidx( 1 ) end,
               { description = "swap with next client by index", group = c } ),
    awful.key( modkey_shift, "h", function() awful.client.swap.byidx( -1 ) end,
               { description = "swap with previous client by index", group = c } ),
    awful.key( modkey, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = c } )
} )

local t = "Tag"
r.keyboard.tags = combine_tables( {
    awful.key( modkey, "Left", awful.tag.viewprev, { description = "view previous", group = t } ),
    awful.key( modkey, "Right", awful.tag.viewnext, { description = "view next", group = t } ),
    awful.key( modkey, "Escape", awful.tag.history.restore, { description = "go back to previous Tag", group = t } ),
    awful.key( modkey, "space", function() awful.layout.inc( 1 ) end, { description = "select next", group = t } ),
    awful.key( modkey_shift, "space", function() awful.layout.inc( -1 ) end,
               { description = "select previous", group = t } ), awful.key( modkey_contl, "n", function()
        local _c = awful.client.restore()
        if _c then c:emit_signal( "request::activate", "key.unminimize", { raise = true } ) end
    end, { description = "restore minimized", group = t } )
} )

r.keyboard.screen = combine_tables( {
    awful.key( modkey_contl, "l", function() awful.screen.focus_relative( 1 ) end,
               { description = "focus the next screen", group = "Screen" } ),
    awful.key( modkey_contl, "h", function() awful.screen.focus_relative( -1 ) end,
               { description = "focus the previous screen", group = "Screen" } )
} )

r.keyboard.awesome = combine_tables( {
    awful.key( modkey, "s", hotkeys_popup.show_help, { description = "show help", group = "Awesome" } ),
    awful.key( modkey, "w", function() require"window-manager.wibar".mainmenu:show() end,
               { description = "show main menu", group = "Awesome" } ),
    awful.key( modkey_contl, "r", awesome.restart, { description = "reload awesome", group = "Awesome" } ),
    awful.key( modkey_shift, "q", awesome.quit, { description = "quit awesome", group = "Awesome" } ),
    awful.key( modkey, "r", function() awful.screen.focused().promptbox:run() end,
               { description = "run prompt", group = "Awesome" } ), awful.key( modkey, "x", function()
        awful.prompt.run {
            prompt = "Run Lua code: ",
            textbox = awful.screen.focused().promptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval"
        }
    end, { description = "lua execute prompt", group = "Awesome" } ),
    awful.key( modkey, "p", function() menubar.show() end, { description = "show the menubar", group = "Awesome" } ),
    awful.key( { "Mod1" }, "Tab", function() require( "windows.task-switcher" )() end,
               { description = "Open Task Switcher", group = "Awesome" } )
} )

r.keyboard.application_launchers = combine_tables( {
    awful.key( modkey, "Return", function() awful.spawn( variables.terminal ) end,
               { description = "open a terminal", group = "Applications" } )
} )

r.keyboard.media_controls = combine_tables( {
    awful.key( {}, "XF86AudioRaiseVolume", function() awful.spawn.with_shell( "pulsemixer --change-volume +10" ) end,
               { description = "Increases Volume by 10", group = "Media" } ),
    awful.key( {}, "XF86AudioLowerVolume", function() awful.spawn.with_shell( "pulsemixer --change-volume -10" ) end,
               { description = "Lowers Volume by 10", group = "Media" } ),
    awful.key( {}, "XF86AudioPlay", function() awful.spawn.with_shell( "playerctl play-pause" ) end,
               { description = "Play/Pause any player", group = "Media" } ),
    awful.key( {}, "XF86AudioNext", function() awful.spawn.with_shell( "playerctl next" ) end,
               { description = "Next 'Track'", group = "Media" } ),
    awful.key( {}, "XF86AudioPrev", function() awful.spawn.with_shell( "playerctl previous" ) end,
               { description = "Previous 'Track'", group = "Media" } )
} )

r.keyboard.globalkeys = gears.table.join( r.keyboard.client, r.keyboard.tags, r.keyboard.screen, r.keyboard.awesome,
                                          r.keyboard.application_launchers, r.keyboard.media_controls,
                                          r.keyboard.client_controls )

for i = 1, 9 do
    r.keyboard.globalkeys = gears.table.join( r.keyboard.globalkeys, combine_tables(
                                                  {
            awful.key( modkey, "#" .. i + 9, function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then tag:view_only() end
            end, { description = "view tag #" .. i, group = t } ), awful.key( modkey_contl, "#" .. i + 9, function()
                local tag = awful.screen.focused().tags[i]
                if tag then awful.tag.viewtoggle( tag ) end
            end, { description = "toggle tag #" .. i, group = t } ), awful.key( modkey_shift, "#" .. i + 9, function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then client.focus:move_to_tag( tag ) end
                end
            end, { description = "move focused client to tag #" .. i, group = t } ),
            awful.key( { variables.modkey, "Control", "Shift" }, "#" .. i + 9, function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then client.focus:toggle_tag( tag ) end
                end
            end, { description = "toggle focused client on tag #" .. i, group = t } )
        } ) )
end

r.mouse.tagList = combine_tables( {
    awful.button( {}, 1, function(_t) _t:view_only() end ),
    awful.button( modkey, 1, function(_t) if client.focus then client.focus:move_to_tag( _t ) end end ),
    awful.button( {}, 3, awful.tag.viewtoggle ),
    awful.button( modkey, 3, function(_t) if client.focus then client.focus:toggle_tag( _t ) end end ),
    awful.button( {}, 4, function(_t) awful.tag.viewnext( _t.screen ) end ),
    awful.button( {}, 5, function(_t) awful.tag.viewprev( _t.screen ) end )
} )

r.mouse.taskList = combine_tables( {
    awful.button( {}, 1, function(_c)
        if _c == client.focus then
            _c.minimized = true
        else
            _c:emit_signal( "request::activate", "tasklist", { raise = true } )
        end
    end ), awful.button( {}, 3, function() awful.menu.client_list( { theme = { width = 250 } } ) end ),
    awful.button( {}, 4, function() awful.client.focus.byidx( 1 ) end ),
    awful.button( {}, 5, function() awful.client.focus.byidx( -1 ) end )
} )

local cw = "Window"
r.keyboard.client = combine_tables( {
    awful.key( modkey, "f", function(_c)
        _c.fullscreen = not c.fullscreen
        _c:raise()
    end, { description = "Toggle fullscreen", group = cw } ),
    awful.key( modkey_shift, "f", awful.client.floating.toggle, { description = "Toggle floating", group = cw } ),
    awful.key( modkey_contl, "Return", function(_c) _c:swap( awful.client.getmaster() ) end,
               { description = "Move to master", group = cw } ),
    awful.key( modkey, "o", function(_c) _c:move_to_screen() end, { description = "move to screen", group = cw } ),
    awful.key( modkey, "t", function(_c) _c.ontop = not c.ontop end, { description = "toggle keep on top", group = cw } ),
    awful.key( modkey, "n", function(_c) _c.minimized = true end, { description = "minimize", group = cw } ),
    awful.key( modkey, "m", function(_c)
        _c.maximized = not _c.maximized
        _c:raise()
    end, { description = "(un)maximize", group = cw } ),
    awful.key( modkey_contl, "c", function(_c) _c:kill() end, { description = "Close application", group = cw } )
} )

r.mouse.client = combine_tables( {
    awful.button( {}, 1, function(_c) _c:emit_signal( "request::activate", "mouse_click", { raise = true } ) end ),
    awful.button( modkey, 1, function(_c)
        _c:emit_signal( "request::activate", "mouse_click", { raise = true } )
        awful.mouse.client.move( _c )
    end ), awful.button( modkey, 3, function(_c)
        _c:emit_signal( "request::activate", "mouse_click", { raise = true } )
        awful.mouse.client.resize( _c )
    end )
} )

function r.Init() root.keys( r.keyboard.globalkeys ) end

return r
