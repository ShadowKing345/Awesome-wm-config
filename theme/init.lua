--[[

    Theme file.
    Based on Catppuccin color scheme with lots of assumptions on what is what.
    Note: This file is not meant to be a standard theme script and instead is meant to be called.

--]]
--------------------------------------------------
local gFileSystem  = require "gears.filesystem"
local theme_assets = require "beautiful.theme_assets"
local dpi          = require "beautiful.xresources".apply_dpi

local theme = require "theme.colors".theme
local colors = require "theme.colors".colors
local extensions = {
    layout   = require "theme.layout",
    mainmenu = require "theme.mainmenu",
    wibar    = require "theme.wibar",
    widget   = require "theme.widget",
}
--------------------------------------------------
local M = { mt = {} }

--  general variables
--------------------------------------------------
local theme_path = gFileSystem.get_xdg_config_home() .. "awesome/theme/"

function M:createConfig()

    -- Actual configs
    --------------------------------------------------
    local config = {
        awesome_icon    = theme_assets.awesome_icon(dpi(30), theme.main, theme.bg.normal),
        bg              = {
            normal   = theme.bg.normal,
            focus    = theme.bg.focus,
            urgent   = theme.bg.urgent,
            minimize = theme.bg.minimize,
        },
        fg              = {
            normal   = theme.fg.normal,
            focus    = theme.fg.focus,
            urgent   = theme.fg.urgent,
            minimize = theme.fg.minimize,
        },
        border          = {
            width  = dpi(1),
            normal = theme.bg.normal,
            focus  = theme.bg.focus,
            marked = theme.bg.urgent,
        },
        button          = {
            bg = {
                normal = theme.bg.button.normal,
                hover  = theme.bg.button.hover,
                active = theme.bg.button.active,
            },
            fg = {
                normal = theme.fg.button.normal,
                hover  = theme.fg.button.hover,
                active = theme.fg.button.active,
            }
        },
        font            = "sans 10",
        icon_theme      = "Papirus-Dark",
        input_field_bg  = colors.black_3,
        separator_color = theme.gray,
        useless_gap     = dpi(10),
        wallpaper       = {
            theme_path .. "background.svg",
            bg         = colors.black_1,
            stylesheet = string.format(
                ".bg{fill: %s;} .primary{fill: %s;} .secondary{fill: %s;}",
                colors.black_1,
                theme.main,
                colors.gray_0
            ),
        },
    }

    for _, extension in pairs(extensions) do
        config = extension(config)
    end

    return M.convertConfig({}, config)
end

---flattens a json style table into a single depth
---@param tbl table
---@param tbl2 table
---@param prefix? string
---@return table #The finished table.
function M.convertConfig(tbl, tbl2, prefix)
    prefix = prefix or ""

    if tbl2[1] then
        tbl[prefix:match "(.*)_"] = tbl2[1]
    end

    for k, v in pairs(tbl2) do
        if type(v) == "table" then
            tbl = M.convertConfig(tbl, v, prefix .. k .. "_")
        else
            tbl[prefix .. k] = v
        end
    end

    return tbl
end

--------------------------------------------------
function M.mt:__call()
    return M:createConfig()
end

return setmetatable(M, M.mt)
