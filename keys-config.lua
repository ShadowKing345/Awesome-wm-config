local awful = require("awful")
local redflat = require("redflat")

local hotkeys = {mouse = {}, raw = {}, keys = {}, fake = {}}

-- Key aliases
local apprunner = redflat.float.apprunner
local appswitcher = redflat.float.appswitcher
local current = redflat.widget.tasklist.filter.currenttags
local allscr = redflat.widget.tasklist.filter.allscreen
local redtip = redflat.float.hotkeys
local redtitle = redflat.titlebar

-- Key support functions
local focus_switch_byd = function(dir)
  return function()
    awful.client.focus.bydirection(dir)
    if client.focus then client.focus:raise() end
  end
end

local function focus_to_previous()
  awful.client.focus.history.previous()
  if client.focus then client.focus:raise() end
end

local function tag_numkey(i, mod, action)
  return awful.key(mod, "#" .. i + 9, function()
    local screen = awful.screen.focused()
    local tag = screen.tags[i]
    if tag then action(tag) end
  end)
end

local function client_numkey(i, mod, action)
  return awful.key(mod, "#" .. i + 9, function()
    if client.focus then
      local tag = client.focus.screen.tags[i]
      if tag then action(tag) end
    end
  end)
end

-- layout direction functions
local function growClientInDirection(c, amount, direction)
  c.screen.selected_tag.layout.resize(c, amount, direction)
end

-- brightness function
local brightness = function(args)
  redflat.float.brightness:change(args, {
    increase = "brightnessctl s +%s%%",
    decrease = "brightnessctl s %s%%-",
    update = {awful.util.shell, "-c", "brightnessctl i | grep -P '(?<=\\()(.*?)(?=%)' -o --color=never"},
  })
end

-- right bottom corner position
local rt_corner = function()
  return {x = screen[mouse.screen].workarea.x + screen[mouse.screen].workarea.width, y = screen[mouse.screen].workarea.y}
end

-- Build hotkeys depended on config parameters
function hotkeys:init(args)
  -- Init vars
  args = args or {}
  local env = args.env
  local menu = args.menu
  local volume = args.volume

  -- volume functions
  local volume_raise = function()
    volume:change_volume({show_notify = true})
  end
  local volume_lower = function()
    volume:change_volume({show_notify = true, down = true})
  end
  local volume_mute = function()
    volume:mute()
  end

  self.mouse.root = (awful.util.table.join(awful.button({}, 3, function()
    menu:toggle()
  end), awful.button({}, 4, awful.tag.viewnext), awful.button({}, 5, awful.tag.viewprev)))

  -- Widget keys
  -- Apprunner
  local apprunner_keys_move = {
    {
      {env.mod}, "j", function()
        apprunner:down()
      end, {description = "Select next item", group = "Navigation"},
    }, {
      {env.mod}, "k", function()
        apprunner:up()
      end, {description = "Select previous item", group = "Navigation"},
    },
  }

  apprunner:set_keys(awful.util.table.join(apprunner.keys.move, apprunner_keys_move), "move")

  -- Menu
  local menu_keys_move = {
    {{env.mod}, "k", redflat.menu.action.down, {description = "Select next item", group = "Navigation"}},
    {{env.mod}, "i", redflat.menu.action.up, {description = "Select previous item", group = "Navigation"}},
    {{env.mod}, "j", redflat.menu.action.back, {description = "Go back", group = "Navigation"}},
    {{env.mod}, "l", redflat.menu.action.enter, {description = "Open submenu", group = "Navigation"}},
  }
  redflat.menu:set_keys(awful.util.table.join(redflat.menu.keys.move, menu_keys_move), "move")

  -- Appswitcher
  local appswitcher_keys_move = {
    {
      {env.mod}, "a", function()
        appswitcher:switch()
      end, {description = "Select next app", group = "Navigation"},
    }, {
      {env.mod}, "q", function()
        appswitcher:switch({reverse = true})
      end, {description = "Select previous app", group = "Navigation"},
    },
  }

  local appswitcher_keys_action = {
    {
      {env.mod}, "Super_L", function()
        appswitcher:hide()
      end, {description = "Activate and exit", group = "Action"},
    }, {
      {}, "Escape", function()
        appswitcher:hide(true)
      end, {description = "Exit", group = "Action"},
    },
  }

  appswitcher:set_keys(awful.util.table.join(appswitcher.keys.move, appswitcher_keys_move), "move")
  appswitcher:set_keys(awful.util.table.join(appswitcher.keys.action, appswitcher_keys_action), "action")

  self.raw.root = {
    {
      {env.mod}, "F1", function()
        redtip:show()
      end, {description = "Show hotkeys helper", group = "Main"},
    }, {
      {env.mod}, "F2", function()
        redflat.service.navigator:run()
      end, {description = "Window control mode", group = "Main"},
    }, {{env.mod, "Control"}, "r", awesome.restart, {description = "Reload awesome", group = "Main"}}, -- {
    --	{ env.mod }, "c", function() redflat.float.keychain:activate(keyseq, "User") end,
    --	{ description = "User key sequence", group = "Main" }
    -- },
    {
      {env.mod}, "Return", function()
        awful.spawn(env.terminal)
      end, {description = "Open a terminal", group = "Main"},
    }, {{env.mod}, "l", focus_switch_byd("right"), {description = "Go to right client", group = "Client focus"}},
    {{env.mod}, "j", focus_switch_byd("left"), {description = "Go to left client", group = "Client focus"}},
    {{env.mod}, "i", focus_switch_byd("up"), {description = "Go to upper client", group = "Client focus"}},
    {{env.mod}, "k", focus_switch_byd("down"), {description = "Go to lower client", group = "Client focus"}},
    {{env.mod}, "u", awful.client.urgent.jumpto, {description = "Go to urgent client", group = "Client focus"}},
    {{env.mod}, "Tab", focus_to_previous, {description = "Go to previos client", group = "Client focus"}},
    {{env.mod}, "o", awful.client.movetoscreen, {description = "Move client to next screen", group = "Client focus"}}, {
      {env.mod}, "w", function()
        menu:show()
      end, {description = "Show main menu", group = "Widgets"},
    }, {
      {env.mod}, "r", function()
        redflat.float.prompt:run()
      end, {description = "Application launcher", group = "Widgets"},
    }, {
      {env.mod}, "p", function()
        apprunner:show()
      end, {description = "Show the prompt box", group = "Widgets"},
    }, {
      {env.mod, "Control"}, "i", function()
        redflat.widget.minitray:toggle()
      end, {description = "Show minitray", group = "Widgets"},
    }, {
      {env.mod}, "z", function()
        redflat.service.logout:show()
      end, {description = "Log out screen", group = "Widgets"},
    }, {
      {env.mod}, "t", function()
        redtitle.toggle(client.focus)
      end, {description = "Show/hide titlebar for focused client", group = "Titlebar"},
    }, {
      {env.mod, "Control"}, "t", function()
        redtitle.switch(client.focus)
      end, {description = "Switch titlebar view for focused client", group = "Titlebar"},
    }, {
      {env.mod, "Shift"}, "t", function()
        redtitle.toggle_all()
      end, {description = "Show/hide titlebar for all clients", group = "Titlebar"},
    }, {
      {env.mod, "Control", "Shift"}, "t", function()
        redtitle.global_switch()
      end, {description = "Switch titlebar view for all clients", group = "Titlebar"},
    }, {
      {env.mod}, "a", nil, function()
        appswitcher:show({filter = current})
      end, {description = "Switch to next with current tag", group = "Application switcher"},
    }, {
      {env.mod}, "q", nil, function()
        appswitcher:show({filter = current, reverse = true})
      end, {description = "Switch to previous with current tag", group = "Application switcher"},
    }, {
      {env.mod, "Shift"}, "a", nil, function()
        appswitcher:show({filter = allscr})
      end, {description = "Switch to next through all tags", group = "Application switcher"},
    }, {
      {env.mod, "Shift"}, "q", nil, function()
        appswitcher:show({filter = allscr, reverse = true})
      end, {description = "Switch to previous through all tags", group = "Application switcher"},
    }, {{env.mod}, "Escape", awful.tag.history.restore, {description = "Go previos tag", group = "Tag navigation"}},
    {{env.mod}, "Right", awful.tag.viewnext, {description = "View next tag", group = "Tag navigation"}},
    {{env.mod}, "Left", awful.tag.viewprev, {description = "View previous tag", group = "Tag navigation"}},

    {{}, "XF86AudioRaiseVolume", volume_raise, {description = "Play/Pause", group = "Media Controls"}},
    {{}, "XF86AudioLowerVolume", volume_lower, {description = "Play/Pause", group = "Media Controls"}},
    {{}, "XF86AudioMute", volume_mute, {description = "Play/Pause", group = "Media Controls"}}, {
      {env.mod}, "e", function()
        redflat.float.player:show(rt_corner())
      end, {description = "Show/hide widget", group = "Audio player"},
    }, {
      {}, "XF86AudioPlay", function()
        redflat.float.player:action("PlayPause")
      end, {description = "Play/Pause track", group = "Audio player"},
    }, {
      {}, "XF86AudioNext", function()
        redflat.float.player:action("Next")
      end, {description = "Next track", group = "Audio player"},
    }, {
      {}, "XF86AudioPrev", function()
        redflat.float.player:action("Previous")
      end, {description = "Previous track", group = "Audio player"},
    }, {
      {"Shift"}, "XF86AudioRaiseVolume", function()
        redflat.float.player:change_volume(0.05)
      end, {description = "Play/Pause", group = "Media Controls"},
    }, {
      {"Shift"}, "XF86AudioLowerVolume", function()
        redflat.float.player:change_volume(-0.05)
      end, {description = "Play/Pause", group = "Media Controls"},
    }, {
      {}, "XF86MonBrightnessUp", function()
        brightness({step = 2})
      end, {description = "Increase brightness", group = "Brightness control"},
    }, {
      {}, "XF86MonBrightnessDown", function()
        brightness({step = 2, down = true})
      end, {description = "Reduce brightness", group = "Brightness control"},
    }, {
      {env.mod, "Control"}, "s", function()
        for s in screen do env.wallpaper(s) end
      end, {}, -- hidden key
    }, {
      {env.mod}, "v", function()
        TREES.widget:toggleDirection()
      end, {description = "Toggles the layout direction", group = "Layout"},
    },
  }

  -- Client keys
  self.raw.client = {
    {
      {env.mod}, "f", function(c)
        c.fullscreen = not c.fullscreen;
        c:raise()
      end, {description = "Toggle fullscreen", group = "Client keys"},
    }, {
      {env.mod}, "F4", function(c)
        c:kill()
      end, {description = "Close", group = "Client keys"},
    }, {{env.mod, "Control"}, "f", awful.client.floating.toggle, {description = "Toggle floating", group = "Client keys"}}, {
      {env.mod, "Control"}, "o", function(c)
        c.ontop = not c.ontop
      end, {description = "Toggle keep on top", group = "Client keys"},
    }, {
      {env.mod}, "n", function(c)
        c.minimized = true
      end, {description = "Minimize", group = "Client keys"},
    }, {
      {env.mod}, "m", function(c)
        c.maximized = not c.maximized;
        c:raise()
      end, {description = "Maximize", group = "Client keys"},
    }, {
      {env.mod, "Shift"}, "v", function(c)
        require("layouts.binary-tree-layout").toggleNodeDirection(c)
      end, {description = "Toggles direction of node", group = "Layout"},
    }, {
      {env.mod, "Shift"}, "l", function(c)
        growClientInDirection(c, 0.1, "right")
      end, {description = "Grows Client to the right", group = "Layout"},
    }, {
      {env.mod, "Shift"}, "j", function(c)
        growClientInDirection(c, 0.1, "left")
      end, {description = "Grows Client to the right", group = "Layout"},
    }, {
      {env.mod, "Shift"}, "i", function(c)
        growClientInDirection(c, 0.1, "up")
      end, {description = "Grows Client to the right", group = "Layout"},
    }, {
      {env.mod, "Shift"}, "k", function(c)
        growClientInDirection(c, 0.1, "down")
      end, {description = "Grows Client to the right", group = "Layout"},
    }, {
      {env.mod, "Shift", "Control"}, "l", function(c)
        growClientInDirection(c, -0.1, "right")
      end, {description = "Shrinks Client to the right", group = "Layout"},
    }, {
      {env.mod, "Shift", "Control"}, "j", function(c)
        growClientInDirection(c, -0.1, "left")
      end, {description = "Shrinks Client to the right", group = "Layout"},
    }, {
      {env.mod, "Shift", "Control"}, "i", function(c)
        growClientInDirection(c, -0.1, "up")
      end, {description = "Shrinks Client to the right", group = "Layout"},
    }, {
      {env.mod, "Shift", "Control"}, "k", function(c)
        growClientInDirection(c, -0.1, "down")
      end, {description = "Shrinks Client to the right", group = "Layout"},
    },
  }

  self.keys.root = redflat.util.key.build(self.raw.root)
  self.keys.client = redflat.util.key.build(self.raw.client)

  -- Numkeys
  -- add real keys without description here
  for i = 1, 9 do
    self.keys.root = awful.util.table.join(self.keys.root, tag_numkey(i, {env.mod}, function(t)
      t:view_only()
    end), tag_numkey(i, {env.mod, "Control"}, function(t)
      awful.tag.viewtoggle(t)
    end), client_numkey(i, {env.mod, "Shift"}, function(t)
      client.focus:move_to_tag(t)
    end), client_numkey(i, {env.mod, "Control", "Shift"}, function(t)
      client.focus:toggle_tag(t)
    end))
  end

  -- make fake keys with description special for key helper widget
  local numkeys = {"1", "2", "3", "4", "5", "6", "7", "8", "9"}

  self.fake.numkeys = {
    {{env.mod}, "1..9", nil, {description = "Switch to tag", group = "Numeric keys", keyset = numkeys}},
    {{env.mod, "Control"}, "1..9", nil, {description = "Toggle tag", group = "Numeric keys", keyset = numkeys}},
    {{env.mod, "Shift"}, "1..9", nil, {description = "Move focused client to tag", group = "Numeric keys", keyset = numkeys}},
    {{env.mod, "Control", "Shift"}, "1..9", nil, {description = "Toggle focused client on tag", group = "Numeric keys", keyset = numkeys}},
  }

  -- Hotkeys helper setup
  redflat.float.hotkeys:set_pack("Main", awful.util.table.join(self.raw.root, self.raw.client, self.fake.numkeys), 2)

  -- Mouse buttons
  self.mouse.client = awful.util.table.join(awful.button({}, 1, function(c)
    client.focus = c;
    c:raise()
  end), awful.button({env.mod}, 1, awful.mouse.client.move), awful.button({env.mod}, 3, awful.mouse.client.resize))

  -- Set root hotkeys
  root.keys(self.keys.root)
  root.buttons(self.mouse.root)
end

return hotkeys
