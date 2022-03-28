--------------------------------------------------
--
--      Theme file.
--      Based on Catppuccin color scheme with lots of assumptions on what is what.
--
--------------------------------------------------
--  Imports
--------------------------------------------------
local gears = require "gears"
local gColor = require "gears.color"
local theme_assets = require "beautiful.theme_assets"
local xresources = require "beautiful.xresources"

--  General variables
--------------------------------------------------
local dpi = xresources.apply_dpi
local gfs = gears.filesystem
local default_theme_path = gfs.get_themes_dir()
local theme_path = gfs.get_xdg_config_home() .. "awesome/theme/"

--  Main colors
--------------------------------------------------
local colors = {
    flamingo = "#F2CDCD",
    mauve = "#DDB6F2",
    pink = "#F5C2E7",
    maroon = "#E8A2AF",
    red = "#F28FAD",
    peach = "#F8BD96",
    yellow = "#FAE3B0",
    green = "#ABE9B3",
    teal = "#B5E8E0",
    blue = "#96CDFB",
    sky = "#89DCEB",
    black_0 = "#161320",
    black_1 = "#1A1826",
    black_2 = "#1E1E2E",
    black_3 = "#302D41",
    black_4 = "#575268",
    gray_0 = "#6E6C7E",
    gray_1 = "#988BA2",
    gray_2 = "#C3BAC6",
    white = "#D9E0EE",
    lavender = "#C9CBFF",
    rosewater = "#F5E0DC",
}

local theme = {
    main = colors.mauve,
    bg = colors.black_2,
    bg_focus = colors.mauve,
    bg_urgent = colors.red,
    bg_minimize = colors.black_4,
    fg = colors.white,
    fg_focus = colors.gray_0,
    fg_urgent = colors.rosewater,
    fg_minimize = colors.lavender,
}

local config = {
    awesome_icon   = theme_assets.awesome_icon(dpi(30), colors.flamingo, theme.bg),
    bg             = {
        normal = theme.bg,
        focus = theme.bg_focus,
        urgent = theme.bg_urgent,
        minimize = theme.bg_minimize,
    },
    fg             = {
        normal = theme.fg,
        focus = theme.fg_focus,
        urgent = theme.fg_urgent,
        minimize = theme.fg_minimize,
    },
    border         = {
        width = dpi(1),
        normal = theme.bg,
        focus = theme.bg_focus,
        marked = theme.bg_urgent,
    },
    font           = "sans 10",
    input_field_bg = colors.black_3,
    layout         = {
        fairh = default_theme_path .. "default/layouts/fairhw.png",
        fairv = default_theme_path .. "default/layouts/fairvw.png",
        floating = default_theme_path .. "default/layouts/floatingw.png",
        magnifier = default_theme_path .. "default/layouts/magnifierw.png",
        max = default_theme_path .. "default/layouts/maxw.png",
        fullscreen = default_theme_path .. "default/layouts/fullscreenw.png",
        tilebottom = default_theme_path .. "default/layouts/tilebottomw.png",
        tileleft = default_theme_path .. "default/layouts/tileleftw.png",
        tile = default_theme_path .. "default/layouts/tilew.png",
        tiletop = default_theme_path .. "default/layouts/tiletopw.png",
        spiral = default_theme_path .. "default/layouts/spiralw.png",
        dwindle = default_theme_path .. "default/layouts/dwindlew.png",
        cornernw = default_theme_path .. "default/layouts/cornernww.png",
        cornerne = default_theme_path .. "default/layouts/cornernew.png",
        cornersw = default_theme_path .. "default/layouts/cornersww.png",
        cornerse = default_theme_path .. "default/layouts/cornersew.png",
    },
    main_menu      = {
        image = {
            reload = gColor.recolor_image(theme_path .. "mainMenu/power.svg", theme.fg),
            quit = gColor.recolor_image(theme_path .. "mainMenu/power.svg", theme.fg),
            sleep = gColor.recolor_image(theme_path .. "mainMenu/sleep.svg", theme.fg),
            reboot = gColor.recolor_image(theme_path .. "mainMenu/reboot.svg", theme.fg),
            shutdown = gColor.recolor_image(theme_path .. "mainMenu/power.svg", theme.fg),
        },
    },
    taglist        = {
        disable_icon = true,
        bg_occupied = theme.bg_minimize,
        fg_occupied = theme.fg_minimize,
    },
    tasklist       = {
        plain_task_name = true,
    },
    titlebar       = {
        close_button = {
            normal = default_theme_path .. "default/titlebar/close_normal.png",
            focus = default_theme_path .. "default/titlebar/close_focus.png",
        },
        minimize_button = {
            normal = default_theme_path .. "default/titlebar/minimize_normal.png",
            focus = default_theme_path .. "default/titlebar/minimize_focus.png",
        },
        ontop_button = {
            normal = {
                active = default_theme_path .. "default/titlebar/ontop_normal_active.png",
                inactive = default_theme_path .. "default/titlebar/ontop_normal_inactive.png",
            },
            focus = {
                active = default_theme_path .. "default/titlebar/ontop_focus_active.png",
                inactive = default_theme_path .. "default/titlebar/ontop_focus_inactive.png",
            },
        },
        sticky_button = {
            normal_inactive = default_theme_path .. "default/titlebar/sticky_normal_inactive.png",
            focus_inactive = default_theme_path .. "default/titlebar/sticky_focus_inactive.png",
            normal_active = default_theme_path .. "default/titlebar/sticky_normal_active.png",
            focus_active = default_theme_path .. "default/titlebar/sticky_focus_active.png",
        },
        floating_button = {
            normal_inactive = default_theme_path .. "default/titlebar/floating_normal_inactive.png",
            focus_inactive = default_theme_path .. "default/titlebar/floating_focus_inactive.png",
            normal_active = default_theme_path .. "default/titlebar/floating_normal_active.png",
            focus_active = default_theme_path .. "default/titlebar/floating_focus_active.png",
        },
        maximized_button = {
            normal_inactive = default_theme_path .. "default/titlebar/maximized_normal_inactive.png",
            focus_inactive = default_theme_path .. "default/titlebar/maximized_focus_inactive.png",
            normal_active = default_theme_path .. "default/titlebar/maximized_normal_active.png",
            focus_active = default_theme_path .. "default/titlebar/maximized_focus_active.png",
        },
    },
    useless_gap    = dpi(0),
    wallpaper      = theme_path .. "background.svg",
    wibar          = {
        height = dpi(30),
        position = "bottom",
    },
}

---flattens a json style table into a single depth
---@param tbl table
---@param tbl2 table
---@param prefix? string
---@return table #The finished table.
local function convertConfig(tbl, tbl2, prefix)
    prefix = prefix or ""

    if tbl2[1] then
        tbl[prefix] = tbl2[1]
    end

    for k, v in pairs(tbl2) do
        if type(v) == "table" then
            tbl = convertConfig(tbl, v, prefix .. k .. "_")
        else
            tbl[prefix .. k] = v
        end
    end

    return tbl
end

return convertConfig({}, config)
