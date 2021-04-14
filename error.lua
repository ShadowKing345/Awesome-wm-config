local naughty = require( 'naughty' )

local r = {}

function r.Init()

    if awesome.startup_errors then
        naughty.notify( {
            present = naughty.config.presets.critical,
            title = "Opps, there were errors during startup!",
            text = awesome.startup_errors
        } )
    end

    do
        local in_error = false
        awesome.connect_signal( "debug::error", function(err)
            if in_error then return end
            in_error = true

            naughty.notify( {
                preset = naughty.config.presets.critical,
                title = "Opps, an error happened!",
                text = tostring( err )
            } )
            in_error = false
        end )
    end
end

return r
