-- Based on awesomewm config colorless provided by worron on github, owner of redflat.
-- awesome modules
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local beautiful = require("beautiful")
require("awful.autofocus")

-- redflat modules
local redflat = require("redflat")

local lock = lock or {}

redflat.startup.locked = lock.autostart
redflat.startup:activate()

-- Error handling
require("erchec-config")

-- env variables
local env = require("env-config")
env:init()

-- Layout Setup
local layouts = require("layout-config")
layouts:init()

-- Main Menu Configuration
local mymenu = require("menu-config")
mymenu:init({env = env})

-- Panel Widgets
-- Seperator
local seperator = redflat.gauge.separator.vertical()

-- Tasklist
local tasklist = {}

tasklist.buttons = awful.util.table.join(awful.button({}, 1, redflat.widget.tasklist.action.select),
                                         awful.button({}, 2, redflat.widget.tasklist.action.close),
                                         awful.button({}, 3, redflat.widget.tasklist.action.menu),
                                         awful.button({}, 4, redflat.widget.tasklist.action.switch_next),
                                         awful.button({}, 5, redflat.widget.tasklist.action.switch_prev))

-- Taglist widget
local taglist = {}
taglist.style = {widget = redflat.gauge.tag.orange.new, show_tip = true}
taglist.buttons = awful.util.table.join(awful.button({}, 1, function(t)
  t:view_only()
end), awful.button({env.mod}, 1, function(t)
  if client.focus then client.focus:move_to_tag(t) end
end), awful.button({}, 2, awful.tag.viewtoggle), awful.button({}, 3, function(t)
  redflat.widget.layoutbox:toggle_menu(t)
end), awful.button({env.mod}, 3, function(t)
  if client.focus then client.focus:toggle_tag(t) end
end), awful.button({}, 4, function(t)
  awful.tag.viewnext(t.screen)
end), awful.button({}, 5, function(t)
  awful.tag.viewprev(t.screen)
end))

-- Textclock widget
local textclock = {}
textclock.widget = redflat.widget.textclock({timeformat = "%H:%M", dateformat = "%b %d %a"})

-- Tray widget
local tray = {}
tray.widget = redflat.widget.minitray()

tray.buttons = awful.util.table.join(awful.button({}, 1, function()
  redflat.widget.minitray:toggle()
end))

-- PA volume control
local volume = {}
volume.widget = redflat.widget.pulse(nil, {widget = redflat.gauge.audio.blue.new})

-- activate player widget
redflat.float.player:init({name = env.player})

volume.buttons = awful.util.table.join(awful.button({}, 4, function()
  volume.widget:change_volume()
end), awful.button({}, 5, function()
  volume.widget:change_volume({down = true})
end), awful.button({}, 2, function()
  volume.widget:mute()
end), awful.button({}, 3, function()
  redflat.float.player:show()
end), awful.button({}, 1, function()
  redflat.float.player:action("PlayPause")
end), awful.button({}, 8, function()
  redflat.float.player:action("Previous")
end), awful.button({}, 9, function()
  redflat.float.player:action("Next")
end))

-- System monitoring widget.
local sysmon = {widget = {}, buttons = {}, icon = {}}

-- icons
sysmon.icon.battery = redflat.util.table.check(beautiful, "wicon.battery")
sysmon.icon.network = redflat.util.table.check(beautiful, "wicon.wireless")
sysmon.icon.cpuram = redflat.util.table.check(beautiful, "wicon.monitor")

-- batery
sysmon.widget.battery = redflat.widget.sysmon({func = redflat.system.pformatted.bat(25), arg = "BAT0"}, {
  timeout = 60,
  widget = redflat.gauge.icon.single,
  monitor = {is_vertical = true, icon = sysmon.icon.battery},
})

-- network
sysmon.widget.network = redflat.widget.net({
  interface = env.network,
  alert = {up = 5 * 1024 ^ 2, down = 5 * 1024 ^ 2},
  speed = {up = 6 * 1024 ^ 2, down = 6 * 1024 ^ 2},
  autoscale = false,
}, {timeout = 2, widget = redflat.gauge.monitor.double, monitor = {icon = sysmon.icon.network}})

-- Screen setup
awful.screen.connect_for_each_screen(function(s)
  -- wallpaper
  env.wallpaper(s)

  -- tags
  awful.tag({"Tag1", "Tag2", "Tag3", "Tag4", "Tag5"}, s, awful.layout.layouts[1])

  -- taglist widget
  taglist[s] = redflat.widget.taglist({screen = s, buttons = taglist.buttons, hint = env.tagtip}, taglist.style)

  -- tasklist widget
  tasklist[s] = redflat.widget.tasklist({screen = s, buttons = tasklist.buttons})

  -- panel wibox
  s.panel = awful.wibar({position = "top", screen = s, height = beautiful.pannel_height or 36})

  s.panel:setup{
    layout = wibox.layout.align.horizontal,
    {
      -- left widgets
      layout = wibox.layout.fixed.horizontal,

      env.wrapper(mymenu.widget, "mainmenu", mymenu.buttons),
      seperator,
      env.wrapper(taglist[s], "taglist"),
      seperator,
      s.mypromptbox,
    },
    {
      -- middle widget
      layout = wibox.layout.align.horizontal,
      expand = "outside",

      nil,
      env.wrapper(tasklist[s], "tasklist"),
    },
    {
      -- right widgets
      layout = wibox.layout.fixed.horizontal,

      gears.filesystem.is_dir("/sys/class/power_supply/BAT0")
          and {seperator, env.wrapper(sysmon.widget.battery, "battery"), layout = wibox.layout.fixed.horizontal} or nil,
      seperator,
      env.wrapper(volume.widget, "volume", volume.buttons),
      seperator,
      env.wrapper(sysmon.widget.network, "network"),
      seperator,
      require("layouts.binary-tree-layout.widget")({}),
      seperator,
      env.wrapper(textclock.widget, "textclock"),
      seperator,
      env.wrapper(tray.widget, "tray", tray.buttons),
    },
  }
end)

-- Desktop
if not lock.desktop then
  local desktop = require("desktop-config")
  desktop:init({
    env = env,
    buttons = awful.util.table.join(awful.button({}, 3, function()
      mymenu.mainmenu:toggle()
    end)),
  })
end

-- Logout screen
local logout = require("logout-config")
logout:init()

-- Key Bindings
local hotkeys = require("keys-config")
hotkeys:init({env = env, menu = mymenu.mainmenu, volume = volume.widget})

-- Rules
local rules = require("rules-config")
rules:init({hotkeys = hotkeys})

-- Titlebar setup
local titlebar = require("titlebar-config")
titlebar:init()

-- Base signals for awesome wm
local signals = require("signals-config")
signals:init({env = env})

-- Autostart user applications
if redflat.startup.is_startup then
  local autostart = require("autostart-config")
  autostart.run()
end
