---@module'menubar'
local menubar = require "menubar"
---@module'gears.table.join'
local gTJoin = require("gears.table").join
local awful = require "awful"
local hotkeysPopup = require "awful.hotkeys_popup"

---@class BindingConfig
---@field keys table
---@field button table
local bindingConfig = { mt = {} }

local function aKey(args)
    args = args or {}

    return awful.key(args.modifier, args.key, args.callback, args.description)
end

local function aButton(args)
    args = args or {}

    return awful.button(args.modifier, args.button, args.callback)
end

---@param env EnvConfig #The environment configurations.
---@return BindingConfig
function bindingConfig:new(env)
    env = env or {}

    self.keys = {
        global = gTJoin(table.unpack {
            -- Tags
            aKey {
                modifier = { env.modKey },
                key = "Left",
                callback = awful.tag.viewprev,
                description = { description = "View previous", group = "Tag" },
            },
            aKey {
                modifier = { env.modKey },
                key = "Right",
                callback = awful.tag.viewnext,
                description = { description = "View next", group = "Tag" },
            },
            -- Launcher
            aKey {
                modifier = { env.modKey },
                key = "Return",
                callback = function()
                    awful.spawn(env.terminal)
                end,
                description = { description = "Opens a terminal", group = "Launcher" },
            },
            aKey {
                modifier = { env.modKey },
                key = "p",
                callback = function()
                    menubar.show()
                end,
                description = { description = "Opens application launcher", group = "Launcher" },
            },
            -- Client
            aKey {
                modifier = { env.modKey, "Control" },
                key = "n",
                callback = function()
                    local c = awful.client.restore()
                    if c then
                        c:emit_signal("request::activate", "key.unminimize", { raise = true })
                    end
                end,
                description = { description = "Restore minimized", group = "Client" },
            },
            -- Awesome
            aKey {
                modifier = { env.modKey, "Control" },
                key = "r",
                callback = awesome.restart,
                description = { description = "Reload Awesome", group = "Awesome" },
            },
            aKey {
                modifier = { env.modKey, "Shift" },
                key = "q",
                callback = awesome.quit,
                description = { description = "Quit Awesome", group = "Awesome" },
            },
            aKey {
                modifier = { env.modKey },
                key = "s",
                callback = hotkeysPopup.show_help,
                description = { description = "Show help", group = "Awesome" },
            },
        }),
        client = gTJoin(table.unpack {
            aKey {
                modifier = { "Mod1" },
                key = "F4",
                callback = function(c)
                    c:kill()
                end,
                description = { description = "Kill application", group = "Client" },
            },
            aKey {
                modifier = { env.modKey },
                key = "f",
                callback = function(c)
                    c.fullscreen = not c.fullscreen
                    c:raise()
                end,
                description = { description = "Toggle fullscreen", group = "Client" },
            },
            aKey {
                modifier = { env.modKey, "Shift" },
                key = "f",
                callback = awful.client.floating.toggle,
                description = { description = "Toggle floating", group = "Client" },
            },
            aKey {
                modifier = { env.modKey },
                key = "t",
                callback = function(c)
                    c.ontop = not c.ontop
                end,
                description = { description = "Toggle keep on top", group = "Client" },
            },
            aKey {
                modifier = { env.modKey },
                key = "n",
                callback = function(c)
                    c.minimized = true
                end,
                description = { description = "Minimize", group = "Client" },
            },
            aKey {
                modifier = { env.modKey },
                key = "m",
                callback = function(c)
                    c.maximized = not c.maximized
                    c:raise()
                end,
                description = { description = "(Un)maximize", group = "Client" },
            },
            aKey {
                modifier = { env.modKey },
                key = "o",
                callback = function(c)
                    c:move_to_screen()
                end,
                description = { description = "Move to screen", group = "Client" },
            },
        }),
    }

    for i = 1, 9 do
        self.keys.global = gTJoin(
            self.keys.global,
            table.unpack {
                aKey {
                    modifier = { env.modKey },
                    key = ("#" .. i + 9),
                    callback = function()
                        local tag = awful.screen.focused().tags[i]
                        if tag then
                            tag:view_only()
                        end
                    end,
                    description = { description = "View tag #" .. i, group = "Tag" },
                },
                -- Toggle tag display.
                aKey {
                    modifier = { env.modKey, "Control" },
                    key = ("#" .. i + 9),
                    callback = function()
                        local tag = awful.screen.focused().tags[i]
                        if tag then
                            awful.tag.viewtoggle(tag)
                        end
                    end,
                    description = { description = "Toggle tag #" .. i, group = "Tag" },
                },
                -- Move client to tag.
                aKey {
                    modifier = { env.modKey, "Shift" },
                    key = ("#" .. i + 9),
                    callback = function()
                        if client.focus then
                            local tag = client.focus.screen.tags[i]
                            if tag then
                                client.focus:move_to_tag(tag)
                            end
                        end
                    end,
                    description = { description = "Move focused client to tag #" .. i, group = "Tag" },
                },
                -- Toggle tag on focused client.
                aKey {
                    modifier = { env.modKey, "Control", "Shift" },
                    key = ("#" .. i + 9),
                    callback = function()
                        if client.focus then
                            local tag = client.focus.screen.tags[i]
                            if tag then
                                client.focus:toggle_tag(tag)
                            end
                        end
                    end,
                    description = { description = "Toggle focused client on tag #" .. i, group = "Tag" },
                },
            }
        )
    end

    self.mouse = {
        global = gTJoin(
            aButton { modifier = {}, button = 4, callback = awful.tag.viewnext },
            aButton { modifier = {}, button = 5, callback = awful.tag.viewprev }
        ),
        client = gTJoin(
            aButton {
                modifier = {},
                button = 1,
                callback = function(client)
                    client:emit_signal("request::activate", "mouse_click", { raise = true })
                end,
            },
            aButton {
                modifier = { env.modKey },
                button = 1,
                callback = function(client)
                    client:emit_signal("request::activate", "mouse_click", { raise = true })
                    awful.mouse.client.move(client)
                end,
            },
            aButton {
                modifier = {},
                button = 3,
                callback = function(client)
                    client:emit_signal("request::activate", "mouse_click", { raise = true })
                end,
            },
            aButton {
                modifier = { env.modKey },
                button = 3,
                callback = function(client)
                    client:emit_signal("request::activate", "mouse_click", { raise = true })
                    awful.mouse.client.resize(client)
                end,
            }
        ),
    }

    return self
end

-- @param env EnvConfig
function bindingConfig.mt:__call(env)
    return bindingConfig:new(env)
end

return setmetatable(bindingConfig, bindingConfig.mt)
