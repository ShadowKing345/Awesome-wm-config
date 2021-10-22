local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")

local redflat = require("redflat")

local unpack = table.unpack

local env = {}

function env:init(args)
  args = args or {}

  self.terminal = "alacritty"
  self.mod = "Mod4"
  self.fm = "nemo"
  self.home = os.getenv("HOME")
  self.themedir = awful.util.get_configuration_dir() .. "theme"
  self.player = args.player or "spotify"
  self.network = "enp3s0"

  -- i can see why boolean defaults are a pain
  self.set_slave = args.set_slave == nil and true or false
  self.desktop_autohide = args.desktop_autohide or false
  self.set_center = args.set_center or false

  -- theme setup
  beautiful.init(env.themedir .. "/theme.lua")

  -- naughty config
  naughty.config.padding = beautiful.useless_gap and 2 * beautiful.useless_gap or 0

  if beautiful.naughty then
    naughty.config.presets.normal = redflat.util.table.merge(beautiful.naughty.base, beautiful.naughty.normal)
    naughty.config.presets.critical = redflat.util.table.merge(beautiful.naughty.base, beautiful.naughty.critical)
    naughty.config.presets.low = redflat.util.table.merge(beautiful.naughty.base, beautiful.naughty.low)
  end
end

-- Wallpaper
env.wallpaper = function(screen)
  if beautiful.wallpaper then
    if not env.desktop_autohide and awful.util.file_readable(beautiful.wallpaper) then
      gears.wallpaper.maximized(beautiful.wallpaper, screen, true)
    else
      gears.wallpaper.set(beautiful.color.bg)
    end
  end
end

-- Tag tooltip text generation
env.tagtip = function(t)
  local layname = awful.layout.getname(awful.tag.getproperty(t, "layout"))
  if redflat.util.table.check(beautiful, "widget.layoutbox.name_alias") then layname = beautiful.widget.layoutbox.name_alias[layname] or layname end
  return string.format("%s (%d apps) [%s]", t.name, #(t:clients()), layname)
end

env.wrapper = function(widget, name, buttons)
  local margin = redflat.util.table.check(beautiful, "widget.wrapper") and beautiful.widget.wrapper[name] or {0, 0, 0, 0}
  if buttons then widget:buttons(buttons) end

  return wibox.container.margin(widget, unpack(margin))
end

return env
