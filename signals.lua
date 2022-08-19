local awful     = require "awful"
local beautiful = require "beautiful"

local signals = { mt = {} }

function signals:init(args)
    args = args or {}

    client.connect_signal("manage", function(c)
        if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_offscreen(c)
        end
    end)

    client.connect_signal("focus", function(client)
        client.border_color = beautiful.border_focus
    end)

    client.connect_signal("unfocus", function(client)
        client.border_color = beautiful.border_normal
    end)
end

function signals.mt:__call(...)
    return signals:init(...)
end

return setmetatable(signals, signals.mt)
