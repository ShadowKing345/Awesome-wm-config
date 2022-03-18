--------------------------------------------------
--
--      Ui configuration
--
--------------------------------------------------
local setmetatable = setmetatable

local awful = require "awful"

local screenConfig = require "ui.screen-config"

--------------------------------------------------
local uiConfig = { mt = {} }

---@param env EnvConfig
function uiConfig:new(env)
    local sc = screenConfig(env)
    awful.screen.connect_for_each_screen(sc.init)
end

-- Metadata setup.
--------------------------------------------------
function uiConfig.mt:__call(...)
    return uiConfig:new(...)
end

return setmetatable(uiConfig, uiConfig.mt)

--------------------------------------------------
-- EoF
--------------------------------------------------
