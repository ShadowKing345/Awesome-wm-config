local awful = require("awful")
local redflat = require("redflat")
local beautiful = require("beautiful")

local client = client

local layouts = {}

function layouts:init()
    local layset = {
		awful.layout.suit.tile,
		redflat.layout.grid,
		redflat.layout.map,
    }

    awful.layout.layouts = layset
end

-- advance layout settings
redflat.layout.map.notification = true
redflat.layout.map.notification_style = {icon = redflat.util.table.check(beautiful, "widget.layoutbox.icon.usermap")}

-- layout handler for grid (replace if different handler wanted)
client.disconnect_signal("request::geometry", awful.layout.move_handler)
client.connect_signal("request::geometry", redflat.layout.common.mouse.move)

-- map layout settings?
client.connect_signal("unmanage", redflat.layout.map.clean_client)

client.connect_signal("property::minimized", function(c)
	if c.minimized and redflat.layout.map.check_client(c) then redflat.layout.map.clean_client(c) end
end)
client.connect_signal("property::floating", function(c)
	if c.floating and redflat.layout.map.check_client(c) then redflat.layout.map.clean_client(c) end
end)

client.connect_signal("untagged", function(c, t)
	if redflat.layout.map.data[t] then redflat.layout.map.clean_client(c) end
end)


return layouts