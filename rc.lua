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
awful.layout.layouts = env.layouts


-- Screen configuration
--------------------------------------------------
require "ui.screen-config" (env)


-- Keybindings
--------------------------------------------------
local keybindings = require "keybindings" (env)
root.keys(keybindings.keys.global)
root.buttons(keybindings.mouse.global)


-- Everything else
--------------------------------------------------
require "rules-config":init { hotkeys = { keys = keybindings.keys, mouse = keybindings.mouse } }
require "service.pulseMixer" {}
require "signals".init(env)


-- Note the collection of applications to autostart are mainly personal. Change them as you need to.
require "autostart-config" {
    "nvidia-settings --load-config-only",
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
    "picom -b",
    "nm-applet",
    "discord",
    "mailspring -b",
}
