--[[

    Tags

--]]
--------------------------------------------------
local awful = require "awful"

local utils = require "keybindings.utils"

--------------------------------------------------
---@type KeybindingModule
local M = { groupName = "Tag" }

function M.keyboard(env)
    local result = {
        {
            modifiers   = { env.modKey },
            key         = "Left",
            press       = awful.tag.viewprev,
            description = "View previous",
        },
        {
            modifiers   = { env.modKey },
            key         = "Right",
            press       = awful.tag.viewnext,
            description = "View next",
        },
    }

    for i, tagName in pairs(env.tags) do
        table.insert(result,
            {
                modifiers   = { env.modKey },
                key         = ("#" .. i + 9),
                press       = function()
                    local tag = awful.screen.focused().tags[i]
                    if tag then
                        tag:view_only()
                    end
                end,
                description = "View tag " .. tagName,
            }
        )
        table.insert(result,
            {
                modifiers   = { env.modKey, utils.keys.clt },
                key         = ("#" .. i + 9),
                press       = function()
                    local tag = awful.screen.focused().tags[i]
                    if tag then
                        awful.tag.viewtoggle(tag)
                    end
                end,
                description = "Toggle tag " .. tagName,
            }
        )
        table.insert(result,
            {
                modifiers   = { env.modKey, utils.keys.shift },
                key         = ("#" .. i + 9),
                press       = function()
                    if client.focus then
                        local tag = client.focus.screen.tags[i]
                        if tag then client.focus:move_to_tag(tag) end
                    end
                end,
                description = "Move focused client to tag " .. tagName,
            }
        )
        table.insert(result,
            {
                modifiers   = { env.modKey, utils.keys.clt, utils.keys.shift },
                key         = ("#" .. i + 9),
                press       = function()
                    if client.focus then
                        local tag = client.focus.screen.tags[i]
                        if tag then client.focus:toggle_tag(tag) end
                    end
                end,
                description = "Toggle focused client on tag " .. tagName,
            }
        )
    end

    return result
end

--------------------------------------------------
return M
