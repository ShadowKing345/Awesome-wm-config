--[[

    Awesome WM config entry point.

--]]
--------------------------------------------------
pcall(require, "luarocks.loader")

--------------------------------------------------
local awful = require "awful"
require "awful.autofocus"
require "awful.hotkeys_popup.keys"

-- Error checking setup.
--------------------------------------------------
require "error-config"

-- Environment variables setup.
--------------------------------------------------
local env = require "env-config" ()
awful.layout.append_default_layouts(env.layouts)

-- Screen configuration
--------------------------------------------------
require "ui.screen-config" { env = env }
require "client" { env = env }

-- Keybindings
--------------------------------------------------
require "keybindings" { env = env }

-- Everything else
--------------------------------------------------
require "rules-config" { env = env }
require "service.pulseMixer" { env = env }

-- Note the collection of applications to autostart are mainly personal. Change them as you need to.
require "autostart-config" {
    list = {
        "nvidia-settings --load-config-only",
        "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
        "picom -b",
        "nm-applet",
        "discord",
        "mailspring -b",
    },
    env = env
}
