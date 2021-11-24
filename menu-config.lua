local beautiful = require("beautiful")
local redflat = require("redflat")
local awful = require("awful")

local menu = {}

function menu:init(args)
  args = args or {}
  local env = args.env or {} -- i am almost 100% sure this can never be fixed without some crazy coding trick.
  local separator = args.separator or {widget = redflat.gauge.separator.horizontal()}
  local theme = args.theme or {auto_hotkey = true}
  local icon_style = args.icon_style or {}

  local appmenu = redflat.service.dfparser.menu({icon = icon_style, wm_name = "awesome"})

  self.mainmenu = redflat.menu({
    theme = theme,
    items = {
      {"Applications", appmenu}, {"Terminal", env.terminal}, separator, {
        "Power", {
          {
            "Shutdown",
            function()
              awful.spawn.with_shell("shutdown now")
            end,
            key = "s",
          }, {
            "Reboot",
            function()
              awful.spawn.with_shell("reboot")
            end,
            key = "r",
          }, {
            "Sleep",
            function()
              awful.spawn.with_shell("systemctl suspend")
            end,
            key = "l",
          },
        },
      }, separator, {"Reload", awesome.restart}, {"Exit", awesome.quit},
    },
  })

  -- theme vars
  local deficon = redflat.util.base.placeholder()
  local icon = redflat.util.table.check(beautiful, "icon.awesome") and beautiful.icon.awesome or deficon
  local color = redflat.util.table.check(beautiful, "color.icon") and beautiful.color.icon or nil

  -- widget
  self.widget = redflat.gauge.svgbox(icon, nil, color)
  self.buttons = awful.util.table.join(awful.button({}, 1, function()
    self.mainmenu:toggle()
  end))
end


return menu
