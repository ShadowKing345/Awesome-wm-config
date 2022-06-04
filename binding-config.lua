--[[

        Mouse and Keybindings configurations

--]]
--------------------------------------------------
local setmetatable = setmetatable
local unpack       = unpack or table.unpack

local awful        = require "awful"
local hotkeysPopup = require "awful.hotkeys_popup"
local gTJoin       = require "gears.table".join
local menubar      = require "menubar"

local pulseMixer = require "service.pulseMixer"
local utils      = require "utils"
local aKey       = utils.aKey
local aButton    = utils.aButton

--------------------------------------------------
---@class BindingConfig
---@field keys table
---@field button table
local M = { mt = {} }

function M:focus_switch_by_dir(dir)
    return function()
        awful.client.focus.global_bydirection(dir)
        if client.focus then
            client.focus:raise()
        end
    end
end

local function getCurrentLayout(c)
    local tag = c and c.screen.selected_tag or awful.screen.focused().selected_tag

    if tag then
        return tag.layout
    end

    return nil
end

local function clientResize(c, dir, push)
    local layout = getCurrentLayout(c)
    if layout and layout.name == "binaryTreeLayout" then
        layout.resize(c, 5 * (push and -1 or 1), dir)
    end
end

---@param env EnvConfig #The environment configurations.
---@return BindingConfig
function M:new(env)
    env = env or {}

    self.keys = {
        global = gTJoin(unpack {

            -- Tags
            aKey {
                modifiers   = { env.modKey },
                key         = "Left",
                callback    = awful.tag.viewprev,
                description = { description = "View previous", group = "Tag" },
            },
            aKey {
                modifiers   = { env.modKey },
                key         = "Right",
                callback    = awful.tag.viewnext,
                description = { description = "View next", group = "Tag" },
            },

            -- Launcher
            aKey {
                modifiers   = { env.modKey },
                key         = "Return",
                callback    = function()
                    awful.spawn(env.terminal)
                end,
                description = { description = "Opens a terminal", group = "Launcher" },
            },
            aKey {
                modifiers   = { env.modKey },
                key         = "p",
                callback    = function()
                    menubar.show()
                end,
                description = { description = "Opens application launcher", group = "Launcher" },
            },

            -- Client
            aKey {
                modifiers   = { env.modKey, "Control" },
                key         = "n",
                callback    = function()
                    local c = awful.client.restore()
                    if c then
                        c:emit_signal("request::activate", "key.unminimize", { raise = true })
                    end
                end,
                description = { description = "Restore minimized", group = "Client" },
            },

            -- Movement
            aKey {
                modifiers = { env.modKey },
                key = "l",
                callback = M:focus_switch_by_dir "right",
                description = { description = "Go to rigth client.", group = "Client Focus" }
            },
            aKey {
                modifiers = { env.modKey },
                key = "h",
                callback = M:focus_switch_by_dir "left",
                description = { description = "Go to left client.", group = "Client Focus" }
            },
            aKey {
                modifiers = { env.modKey },
                key = "k",
                callback = M:focus_switch_by_dir "up",
                description = { description = "Go to upper client.", group = "Client Focus" }
            },
            aKey {
                modifiers = { env.modKey },
                key = "j",
                callback = M:focus_switch_by_dir "down",
                description = { description = "Go to lower client.", group = "Client Focus" }
            },

            -- Awesome
            aKey {
                modifiers   = { env.modKey, "Control" },
                key         = "r",
                callback    = awesome.restart,
                description = { description = "Reload Awesome", group = "Awesome" },
            },
            aKey {
                modifiers   = { env.modKey, "Shift" },
                key         = "q",
                callback    = awesome.quit,
                description = { description = "Quit Awesome", group = "Awesome" },
            },
            aKey {
                modifiers   = { env.modKey },
                key         = "s",
                callback    = hotkeysPopup.show_help,
                description = { description = "Show help", group = "Awesome" },
            },

            -- Audio
            aKey {
                modifiers   = {},
                key         = "XF86AudioMute",
                callback    = function() pulseMixer:toggleMute() end,
                description = { description = "Toggle Mute", group = "Multimedia" },
            },
            aKey {
                modifiers   = {},
                key         = "XF86AudioRaiseVolume",
                callback    = function() pulseMixer:changeVolume(1) end,
                description = { description = "Raise Volume", group = "Multimedia" },
            },
            aKey {
                modifiers   = {},
                key         = "XF86AudioLowerVolume",
                callback    = function() pulseMixer:changeVolume(-1) end,
                description = { description = "Lower Volume", group = "Multimedia" },
            },

            -- Layout
            aKey {
                modifiers = { env.modKey },
                key = "v",
                callback = function()
                    local layout = getCurrentLayout()
                    if layout and layout.name == "binaryTreeLayout" then
                        layout:toggle()
                    end
                end,
                description = { description = "Toggles the direction of the binary layout", group = "Layout" },
            },
        }),
        client = gTJoin(table.unpack {
            aKey {
                modifiers   = { "Mod1" },
                key         = "F4",
                callback    = function(c)
                    c:kill()
                end,
                description = { description = "Kill application", group = "Client" },
            },
            aKey {
                modifiers   = { env.modKey },
                key         = "f",
                callback    = function(c)
                    c.fullscreen = not c.fullscreen
                    c:raise()
                end,
                description = { description = "Toggle fullscreen", group = "Client" },
            },
            aKey {
                modifiers   = { env.modKey, "Shift" },
                key         = "f",
                callback    = awful.client.floating.toggle,
                description = { description = "Toggle floating", group = "Client" },
            },
            aKey {
                modifiers   = { env.modKey },
                key         = "t",
                callback    = function(c)
                    c.ontop = not c.ontop
                end,
                description = { description = "Toggle keep on top", group = "Client" },
            },
            aKey {
                modifiers   = { env.modKey },
                key         = "n",
                callback    = function(c)
                    c.minimized = true
                end,
                description = { description = "Minimize", group = "Client" },
            },
            aKey {
                modifiers   = { env.modKey },
                key         = "m",
                callback    = function(c)
                    c.maximized = not c.maximized
                    c:raise()
                end,
                description = { description = "(Un)maximize", group = "Client" },
            },
            aKey {
                modifiers   = { env.modKey },
                key         = "o",
                callback    = function(c) c:move_to_screen() end,
                description = { description = "Move to next screen", group = "Client" },
            },
            --- Layout
            aKey {
                modifiers = { env.modKey, "Shift" },
                key = "h",
                callback = function(c) clientResize(c, "left") end,
                description = { description = "Push left", group = "Layout" }
            },
            aKey {
                modifiers = { env.modKey, "Shift", "Control" },
                key = "h",
                callback = function(c) clientResize(c, "left", true) end,
                description = { description = "Pull left", group = "Layout" }
            },

            aKey {
                modifiers = { env.modKey, "Shift" },
                key = "l",
                callback = function(c) clientResize(c, "right") end,
                description = { description = "Push right", group = "Layout" }
            },
            aKey {
                modifiers = { env.modKey, "Shift", "Control" },
                key = "l",
                callback = function(c) clientResize(c, "right", true) end,
                description = { description = "Pull right", group = "Layout" }
            },

            aKey {
                modifiers = { env.modKey, "Shift" },
                key = "k",
                callback = function(c) clientResize(c, "up") end,
                description = { description = "Push up", group = "Layout" }
            },
            aKey {
                modifiers = { env.modKey, "Shift", "Control" },
                key = "k",
                callback = function(c) clientResize(c, "up", true) end,
                description = { description = "Pull up", group = "Layout" }
            },

            aKey {
                modifiers = { env.modKey, "Shift" },
                key = "j",
                callback = function(c) clientResize(c, "down") end,
                description = { description = "Push down", group = "Layout" }
            },
            aKey {
                modifiers = { env.modKey, "Shift", "Control" },
                key = "j",
                callback = function(c) clientResize(c, "down", true) end,
                description = { description = "Pull down", group = "Layout" }
            },

            aKey {
                modifiers = { env.modKey, "Shift" },
                key = "v",
                callback = function(c)
                    local layout = getCurrentLayout(c)
                    if layout and layout.name == "binaryTreeLayout" then
                        layout:changeDirection(c)
                    end
                end,
                description = { description = "Toggles the direction of the binary layout", group = "Layout" },
            },

        }),
    }

    for i = 1, 9 do
        self.keys.global = gTJoin(
            self.keys.global,
            table.unpack {
                aKey {
                    modifiers   = { env.modKey },
                    key         = ("#" .. i + 9),
                    callback    = function()
                        local tag = awful.screen.focused().tags[i]
                        if tag then
                            tag:view_only()
                        end
                    end,
                    description = { description = "View tag #" .. i, group = "Tag" },
                },
                -- Toggle tag display.
                aKey {
                    modifiers   = { env.modKey, "Control" },
                    key         = ("#" .. i + 9),
                    callback    = function()
                        local tag = awful.screen.focused().tags[i]
                        if tag then
                            awful.tag.viewtoggle(tag)
                        end
                    end,
                    description = { description = "Toggle tag #" .. i, group = "Tag" },
                },
                -- Move client to tag.
                aKey {
                    modifiers   = { env.modKey, "Shift" },
                    key         = ("#" .. i + 9),
                    callback    = function()
                        if client.focus then
                            local tag = client.focus.screen.tags[i]
                            if tag then client.focus:move_to_tag(tag) end
                        end
                    end,
                    description = { description = "Move focused client to tag #" .. i, group = "Tag" },
                },
                -- Toggle tag on focused client.
                aKey {
                    modifiers   = { env.modKey, "Control", "Shift" },
                    key         = ("#" .. i + 9),
                    callback    = function()
                        if client.focus then
                            local tag = client.focus.screen.tags[i]
                            if tag then client.focus:toggle_tag(tag) end
                        end
                    end,
                    description = { description = "Toggle focused client on tag #" .. i, group = "Tag" },
                },
            }
        )
    end

    self.mouse = {
        global = gTJoin(
            aButton { modifiers = {}, button = 4, callback = awful.tag.viewnext },
            aButton { modifiers = {}, button = 5, callback = awful.tag.viewprev }
        ),
        client = gTJoin(
            aButton {
                modifiers = {},
                button    = 1,
                callback  = function(c) c:emit_signal("request::activate", "mouse_click", { raise = true }) end,
            },
            aButton {
                modifiers = { env.modKey },
                button    = 1,
                callback  = function(c)
                    c:emit_signal("request::activate", "mouse_click", { raise = true })
                    awful.mouse.client.move(c)
                end,
            },
            aButton {
                modifiers = {},
                button    = 3,
                callback  = function(c) c:emit_signal("request::activate", "mouse_click", { raise = true }) end,
            },
            aButton {
                modifiers = { env.modKey },
                button    = 3,
                callback  = function(c)
                    c:emit_signal("request::activate", "mouse_click", { raise = true })
                    awful.mouse.client.resize(c)
                end,
            }
        ),
    }

    return self
end

--------------------------------------------------
function M.mt:__call(env)
    return M:new(env)
end

return setmetatable(M, M.mt)
