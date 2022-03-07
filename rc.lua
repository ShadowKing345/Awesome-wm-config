pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local beautiful = require("beautiful")
require("awful.hotkeys_popup.keys")

require("error-config")

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

local env = require("env-config")()

awful.layout.layouts = {awful.layout.suit.floating}

local screenConfig = require("screen-config")(env)
awful.screen.connect_for_each_screen(screenConfig.init)

local bindingConfig = require("binding-config")(env)
root.keys(bindingConfig.keys.global)
root.buttons(bindingConfig.mouse.global)

require("rules-config"):init{hotkeys = {keys = bindingConfig.keys, mouse = bindingConfig.mouse}}

require("signals").init(env)


if not gears.filesystem.file_readable("/tmp/awesomeWmFirstBoot") then
  require("autostart-config").run()
  awful.spawn.with_shell("touch /tmp/awesomeWmFirstBoot")
end
