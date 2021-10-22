local awful = require("awful")

local redutil = require("redflat.util")

local signals = {}

local lastFocusedScreen = nil

function signals:init(args)
  args = args or {}
  local env = args.env

  -- actions on every application start
  client.connect_signal("manage", function(c)
    -- put client at the end of the list
    if env.set_slave then awful.client.setslave(c) end

    -- startup placement
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then awful.placement.no_offscreen(c) end

    -- put new floating windows to the center of screen
    if env.set_center and c.floating and not (c.maximized or c.fullscreen) then redutil.placement.centered(c, nil, mouse.screen.workarea) end
  end)

  -- wallpaper update on screen geometry change
  screen.connect_signal("property::geometry", env.wallpaper)

  -- Awesome v4.0 introduce screen handling without restart.
  -- All redflat panel widgets was designed in old fashioned way and doesn't support this fature properly.
  -- Since I'm using single monitor setup I have no will to rework panel widgets by now,
  -- so restart signal added here is simple and dirty workaround.
  -- You can disable it on your own risk.
  screen.connect_signal("list", awesome.restart)

  -- Sloppy screen focus
  client.connect_signal("mouse::enter", function(c)
    if lastFocusedScreen ~= c.screen.index then
      c:emit_signal("request::activate", "mouse_enter", {raise = false})
      lastFocusedScreen = c.screen.index
    end
  end)
end

return signals
