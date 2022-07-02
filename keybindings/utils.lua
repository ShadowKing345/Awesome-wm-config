--[[


    Utils for keybindings.


--]]
--------------------------------------------------
local awful = require "awful"

--------------------------------------------------
local M = {
    keys = {
        shift = "Shift",
        clt = "Control",
        alt = "Mod3",
        super = "Mod4",
    },
}

function M.getCurrentLayout(c)
    local tag = c and c.screen.selected_tag or awful.screen.focused().selected_tag

    if tag then
        return tag.layout
    end

    return nil
end

--------------------------------------------------
return M
