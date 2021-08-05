-- Based on awesomewm config colorless provided by worron on github, owner of redflat.

-- awesome modules
local awful = require("awful")
local wibox = require("wibox")

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
mymenu:init({ env = env })


-- Panel Widgets

-- Seperator
local seperator = redflat.gauge.separator.vertical()

-- Tasklist
local tasklist = {}

tasklist.buttons = awful.util.table.join(
	awful.button({}, 1, redflat.widget.tasklist.action.select),
	awful.button({}, 2, redflat.widget.tasklist.action.close),
	awful.button({}, 3, redflat.widget.tasklist.action.menu),
	awful.button({}, 4, redflat.widget.tasklist.action.switch_next),
	awful.button({}, 5, redflat.widget.tasklist.action.switch_prev)
)

-- Taglist widget
local taglist = {}
taglist.style = { widget = redflat.gauge.tag.orange.new, show_tip = true }
taglist.buttons = awful.util.table.join(
	awful.button({			}, 1, function (t) t:view_only() end ),
	awful.button({ env.mod 	}, 1, function (t) if client.focus then client.focus:move_to_tag(t) end end ),
	awful.button({			}, 2, awful.tag.viewtoggle ),
	awful.button({		}, 3, function (t) redflat.widget.layoutbox:toggle_menu(t) end ),
	awful.button({ env.mod	}, 3, function (t) if client.focus then client.focus:toggle_tag(t) end end ),
	awful.button({		}, 4, function (t) awful.tag.viewnext(t.screen) end ),
	awful.button({		}, 5, function (t) awful.tag.viewprev(t.screen) end )
)

-- Textclock widget
local textclock = {}
textclock.widget = redflat.widget.textclock({ timeformat = "%H:%M", dateformat = "%b %d %a"})

-- Layout config
local layoutbox = {}

layoutbox.buttons = awful.util.table.join(
	awful.button({}, 1, function() awful.layout.inc(1) end),
	awful.button({}, 3, function() redflat.widget.layoutbox:toggle_menu(mouse.screen.selected_tag) end),
	awful.button({}, 4, function() awful.layout.inc(1) end),
	awful.button({}, 5, function() awful.layout.inc(-1) end)
)

-- Tray widget
local tray = {}
tray.widget = redflat.widget.minitray()

tray.buttons = awful.util.table.join(
	awful.button({}, 1, function() redflat.widget.minitray:toggle() end)
)

-- Screen setup
awful.screen.connect_for_each_screen(function (s)
	-- wallpaper	
	env.wallpaper(s)

	-- tags
	awful.tag({"Tag1", "Tag2", "Tag3", "Tag4", "Tag5"}, s, awful.layout.layouts[1])

	-- layout widget
	layoutbox[s] = redflat.widget.layoutbox({screen = s})

	-- taglist widget
	taglist[s] = redflat.widget.taglist({screen = s, buttons = taglist.buttons, hint = env.tagtip }, taglist.style)

	-- tasklist widget
	tasklist[s] = redflat.widget.tasklist({screen = s, buttons = tasklist.buttons})

	-- panel wibox
	s.panel = awful.wibar({ position = "top", screen = s, height = beautiful.pannel_height or 36})

	s.panel:setup {
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
			
			seperator,
			env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
			seperator,
			env.wrapper(textclock.widget, "textclock"),
			seperator,
			env.wrapper(tray.widget,"tray", tray.buttons),
		}
	}
end)

-- Key Bindings
local hotkeys = require("keys-config")
hotkeys:init({env = env, menu = mymenu.mainmenu})

-- Rules
local rules = require("rules-config")
rules:init({ hotkeys = hotkeys })

-- Titlebar setup
local titlebar = require("titlebar-config")
titlebar:init()

-- Base signals for awesome wm
local signals = require("signals-config")
signals:init({env = env})