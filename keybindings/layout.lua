--[[

    Layout

--]]
--------------------------------------------------
local utils = require "keybindings.utils"

--------------------------------------------------
---@type KeybindingModule
local M = { groupName = "Layout" }


function M.keyboard(env)
    return {
        {
            modifiers = { env.modKey },
            key = "v",
            press = function()
                local layout = utils.getCurrentLayout()
                if layout and layout.name == "binaryTreeLayout" then
                    layout:toggle()
                end
            end,
            description = "Toggles the direction of the binary layout",
        },
    }
end

function M.client(env)
    return {
        {
            modifiers   = { env.modKey, utils.keys.shift },
            key         = "v",
            press       = function(c)
                local layout = utils.getCurrentLayout(c)
                if layout and layout.name == "binaryTreeLayout" then
                    layout:changeDirection(c)
                end
            end,
            description = "Toggles the direction of the binary layout",
        },
    }
end

--------------------------------------------------
return M
