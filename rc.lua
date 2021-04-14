pcall( require, "luarocks.loader" )

require( "error" ).Init()
require( 'theme' ).Init()
require( 'window-manager' ).Init()
require( 'keybindings' ).Init()
