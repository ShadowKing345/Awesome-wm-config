local wibox = require("wibox")
local awful = require("awful")
local aButton = require("awful.button")
local beautiful = require("beautiful")
local gears = require("gears")
local hotkeysPopup = require("awful.hotkeys_popup")

local screenConfig = {mt = {}}

function screenConfig.set_wallpaper(screen)
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    if type(wallpaper) == "function" then wallpaper = wallpaper(screen) end
    gears.wallpaper.maximized(wallpaper, screen, true)
  end
end

screen.connect_signal("property::geometry", screenConfig.set_wallpaper)

function screenConfig:new(env)
  env = env or {}

  self.awesomeMenu = {
    {
      "hotkeys", function()
        hotkeysPopup.show_help(nil, awful.screen.focused())
      end,
    }, {"manual", env.terminal .. " -e man awesome"}, {"edit config", env.editorCmd .. " " .. awesome.conffile}, {"restart", awesome.restart}, {
      "quit", function()
        awesome.quit()
      end,
    },
  }
  self.mainMenu = awful.menu {items = {{"awesome", self.awesomeMenu, beautiful.awesome_icon}, {"open terminal", env.terminal}}}
  self.launcher = awful.widget.launcher {image = beautiful.awesome_icon, menu = self.mainMenu}

  self.textClock = wibox.widget.textclock()

  self.taglistButtons = gears.table.join(aButton({}, 1, function(t)
    t:view_only()
  end), aButton({env.modkey}, 1, function(t)
    if client.focus then client.focus:move_to_tag(t) end
  end), aButton({}, 3, awful.tag.viewtoggle), aButton({env.modkey}, 3, function(t)
    if client.focus then client.focus:toggle_tag(t) end
  end), aButton({}, 4, function(t)
    awful.tag.viewnext(t.screen)
  end), aButton({}, 5, function(t)
    awful.tag.viewprev(t.screen)
  end))

  self.tasklistButtons = gears.table.join(aButton({}, 1, function(c)
    if c == client.focus then
      c.minimized = true
    else
      c:emit_signal("request::activate", "tasklist", {raise = true})
    end
  end), aButton({}, 3, function()
    awful.menu.client_list({theme = {width = 250}})
  end), aButton({}, 4, function()
    awful.client.focus.byidx(1)
  end), aButton({}, 5, function()
    awful.client.focus.byidx(-1)
  end))

  return self
end

function screenConfig:_init(screen)
  screenConfig.set_wallpaper(screen)

  awful.tag({"1", "2", "3", "4", "5", "6", "7", "8", "9"}, screen, awful.layout.layouts[1])
  screen.prompt = awful.widget.prompt()

  screen.layoutbox = awful.widget.layoutbox(screen)
  screen.taglist = awful.widget.taglist {screen = screen, filter = awful.widget.taglist.filter.all, buttons = self.taglistButtons}
  screen.tasklist = awful.widget.tasklist {screen = screen, filter = awful.widget.tasklist.filter.currenttags, buttons = self.tasklistButtons}

  screen.wibox = awful.wibar {position = "top", screen = screen}
  screen.wibox:setup{
    layout = wibox.layout.align.horizontal,
    {layout = wibox.layout.fixed.horizontal, self.launcher, screen.taglist, screen.prompt},
    screen.tasklist,
    {layout = wibox.layout.fixed.horizontal, self.textClock, wibox.widget.systray(), screen.layoutbox},
  }
end

function screenConfig.init(screen)
  screenConfig:_init(screen)
end

function screenConfig.mt:__call(...)
  return screenConfig:new(...)
end

return setmetatable(screenConfig, screenConfig.mt)
