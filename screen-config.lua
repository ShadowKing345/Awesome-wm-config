local wibox = require "wibox"
local awful = require "awful"
local aButton = require "awful.button"
local beautiful = require "beautiful"
local gears = require "gears"
local hotkeysPopup = require "awful.hotkeys_popup"

local screenConfig = { mt = {} }

function screenConfig.set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(tostring(wallpaper), s, true)
    end
end

screen.connect_signal("property::geometry", screenConfig.set_wallpaper)

---@param env EnvConfig
function screenConfig:new(env)
    env = env or {}

    self.awesomeMenu = {
        {
            "hotkeys",
            function()
                hotkeysPopup.show_help(nil, awful.screen.focused())
            end,
        },
        { "manual", env.terminal .. " -e man awesome" },
        { "edit config", env.editorCmd .. " " .. awesome.conffile },
        { "restart", awesome.restart },
        {
            "quit",
            function()
                awesome.quit()
            end,
        },
    }
    self.mainMenu = awful.menu {
        items = { { "awesome", self.awesomeMenu, beautiful.awesome_icon }, { "open terminal", env.terminal } },
    }
    self.launcher = awful.widget.launcher { image = beautiful.awesome_icon, menu = self.mainMenu }

    self.textClock = wibox.widget.textclock()

    self.taglistButtons = {
        aButton({}, 1, function(t)
            t:view_only()
        end),
        aButton({ env.modKey }, 1, function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
        end),
        aButton({}, 3, awful.tag.viewtoggle),
        aButton({ env.modKey }, 3, function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
        end),
        aButton({}, 4, function(t)
            awful.tag.viewnext(t.screen)
        end),
        aButton({}, 5, function(t)
            awful.tag.viewprev(t.screen)
        end),
    }

    self.tasklistButtons = {
        aButton({}, 1, function(c)
            if c == client.focus then
                c.minimized = true
            else
                c:emit_signal("request::activate", "tasklist", { raise = true })
            end
        end),
        aButton({}, 3, function()
            awful.menu.client_list { theme = { width = 250 } }
        end),
        aButton({}, 4, function()
            awful.client.focus.byidx(1)
        end),
        aButton({}, 5, function()
            awful.client.focus.byidx(-1)
        end),
    }

    return self
end

local tagListFocus = beautiful.taglist_bg_focus or beautiful.bg_focus
local tagListNormal = beautiful.taglist_bg_normal or beautiful.bg_normal
local tagListUrgent = beautiful.taglist_bg_urgent or beautiful.bg_urgent

function screenConfig:_init(screen)
    screenConfig.set_wallpaper(screen)

    awful.tag({ "1", "2", "3", "4", "5", "6" }, screen, awful.layout.layouts[1])
    screen.prompt = awful.widget.prompt()

    screen.layoutbox = awful.widget.layoutbox(screen)
    screen.taglist = awful.widget.taglist {
        screen = screen,
        filter = awful.widget.taglist.filter.all,
        buttons = self.taglistButtons,
        widget_template = {
          nil,
          {
            {
              id = "text_role",
              widget = wibox.widget.textbox,
              align = "center",
            },
            widget = wibox.container.background,
            forced_width = 30
          },
          {
            id = "background_role",
            bg = "#ff0000",
            widget = wibox.container.background,
            forced_height = 3,
          },
          layout = wibox.layout.align.vertical,
        }
    }
    screen.tasklist = awful.widget.tasklist {
        screen = screen,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = self.tasklistButtons,
        layout = {
          layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
        nil,
        {
          {
              {
                 {
                    {
                        id     = 'icon_role',
                        widget = wibox.widget.imagebox,
                    },
                    margins = 2,
                    widget  = wibox.container.margin,
                },
                {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                    forced_width = 100,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            left  = 2,
            right = 8,
            widget = wibox.container.margin
        },
        widget = wibox.container.background,
        },
        {
          id = "background_role",
          widget = wibox.container.background,
          forced_height = 3,
        },
        layout = wibox.layout.align.vertical,
        }
    }

    local seperator = wibox.widget {
    {
      orientation = "vertical",
      span_ratio = 0.8,
      thickness = 1,
      widget = wibox.widget.separator,
      },
      left = 3,
      right = 3,
      forced_width = 7,
      widget = wibox.container.margin,
    }

    screen.wibox = awful.wibar { position = beautiful["wibar_position"], screen = screen }
    screen.wibox:setup {
        {
          self.launcher,
          seperator,
          screen.taglist,
          seperator,
          layout = wibox.layout.fixed.horizontal,
        },
        screen.tasklist,
        {
          self.textClock,
          seperator,
          wibox.widget.systray(),
          seperator,
          screen.layoutbox,
          layout = wibox.layout.fixed.horizontal,
        },
        layout = wibox.layout.align.horizontal,
    }
end

function screenConfig.init(screen)
    screenConfig:_init(screen)
end

---@param env EnvConfig
function screenConfig.mt:__call(env)
    return screenConfig:new(env)
end

return setmetatable(screenConfig, screenConfig.mt)
