--[[

    Tags

--]]
--------------------------------------------------
local awful = require "awful"

--------------------------------------------------
---@type KeybindingModule
local M = { groupName = "Tags" }

function M.keyboard(env)
    return {
        {
            modifiers   = { env.modKey },
            key         = "Left",
            callback    = awful.tag.viewprev,
            description = "View previous",
        },
        {
            modifiers   = { env.modKey },
            key         = "Right",
            callback    = awful.tag.viewnext,
            description = "View next",
        },
    }
end

--------------------------------------------------
return M
