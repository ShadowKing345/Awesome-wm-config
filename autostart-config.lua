--[[

    Autostart applications.
    Does not deal with the autostart directory.

--]]
--------------------------------------------------
local awful = require "awful"
local gears = require "gears"

--------------------------------------------------
local M = {
    tempFile = "/tmp/awesomeWmFirstBoot",
    mt = {}
}

---Automatically starts programs if the temp file is missing.
---@param list string[] #Collection of applications to start.
---@param tempFile? string #File for where tempfile will be created.
function M.init(list, tempFile)
    list = list or {}
    tempFile = tempFile or M.tempFile

    if not gears.filesystem.file_readable(tempFile) then
        -- Creating a blank file as a check.
        awful.spawn.with_shell("touch " .. tempFile)

        for _, item in ipairs(list) do
            awful.spawn.with_shell(item)
        end
    end
end

--------------------------------------------------
function M.mt:__call(list)
    return M.init(list)
end

return setmetatable(M, M.mt)
