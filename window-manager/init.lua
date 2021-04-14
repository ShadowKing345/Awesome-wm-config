local awful = require( 'awful' )
local keybindings = require( 'keybindings' )
local variables = require( 'variables' )

local r = {}


function r.Init()
	require( "awful.autofocus" )
	require( "awful.hotkeys_popup.keys" )
    require( "menubar" ).utils.terminal = variables.terminal
    require( 'window-manager.layout' )

    require( 'window-manager.wibar' ).Init()
    root.buttons( keybindings.combine_tables( {
        awful.button( {}, 3, function() r.mainmenu:toggle() end ), awful.button( {}, 4, awful.tag.viewnext ),
        awful.button( {}, 5, awful.tag.viewprev )
    } ) )

    require( 'window-manager.window-rules' ).Init()
    require( 'window-manager.titlebars' ).Init()
end

return r
