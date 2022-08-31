--[[

    Audio Keybindings.

--]]
--------------------------------------------------
---@type KeybindingModule
local M = { groupName = "Audio" }

function M.keyboard(env)
    env = env or {}
    local pulseMixer = env.pulseMixer

    if not pulseMixer then
        return {}
    end

    return {
        {
            modifiers   = {},
            key         = "XF86AudioMute",
            press       = function() pulseMixer:mute { toggle = true } end,
            description = "Toggle Mute",
        },
        {
            modifiers   = {},
            key         = "XF86AudioRaiseVolume",
            press       = function() pulseMixer:volume { amount = 1, delta = true } end,
            description = "Raise Volume",
        },
        {
            modifiers   = {},
            key         = "XF86AudioLowerVolume",
            press       = function() pulseMixer:volume { amount = -1, delta = true } end,
            description = "Lower Volume",
        },
    }
end

--------------------------------------------------
return M
