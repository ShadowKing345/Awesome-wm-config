--[[

    Theme configuration for layout and layout widgets.

]]
--------------------------------------------------
local dpi         = require "beautiful.xresources".apply_dpi
local gears       = require "gears"
local gFileSystem = require "gears.filesystem"

local theme = require "theme.colors".theme

--------------------------------------------------
local M = { mt = {} }

--  General variables
--------------------------------------------------
local default_theme_path = gFileSystem.get_themes_dir()

function M:call(config)
    local stylesheet = (".icon {stroke: %s;}"):format(theme.main)

    config.launcher   = {
        shape   = function(ctx, width, height) gears.shape.rounded_rect(ctx, width, height, dpi(3)) end,
        padding = dpi(5),
    }
    config.layoutbox  = {
        bg         = {
            normal = theme.bg.button.normal,
            hover  = theme.bg.button.hover,
            active = theme.bg.button.active,
        },
        padding    = dpi(5),
        shape      = function(ctx, width, height) gears.shape.rounded_rect(ctx, width, height, dpi(3)) end,
        stylesheet = stylesheet,
    }
    config.layoutlist = {
        selection_notch_tempate = {},
        selection               = function(selected) return selected and theme.main or theme.bg.minimize end,
        stylesheet              = stylesheet,
        bg                      = {
            normal = theme.bg.button.normal,
            hover  = theme.bg.button.hover,
            active = theme.bg.button.active,
        },
        fg                      = {
            normal = theme.fg.button.normal,
            hover  = theme.fg.button.hover,
            active = theme.fg.button.active,
        },
    }
    config.layout     = {
        floating         = default_theme_path .. "default/layouts/floatingw.png",
        binaryTreeLayout = gFileSystem.get_xdg_config_home() .. "/awesome/binary-tree-layout/icon.svg",
    }
    return config
end

--------------------------------------------------
function M.mt:__call(...)
    return M:call(...)
end

return setmetatable(M, M.mt)
