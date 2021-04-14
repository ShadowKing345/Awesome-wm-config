local awful = require( "awful" )

local r = {}

function r.Init()
    client.connect_signal( "manage", function(c)
        if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_offscreen( c )
        end
    end )

end

return r
