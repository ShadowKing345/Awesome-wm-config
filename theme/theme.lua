--[[

    Theme file.
    Based on Catppuccin color scheme with lots of assumptions on what is what.

--]]
--------------------------------------------------
local gears = require "gears"
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
    flamingo  = "#F2CDCD",
    mauve     = "#DDB6F2",
    pink      = "#F5C2E7",
    maroon    = "#E8A2AF",
    red       = "#F28FAD",
    peach     = "#F8BD96",
    yellow    = "#FAE3B0",
    green     = "#ABE9B3",
    teal      = "#B5E8E0",
    blue      = "#96CDFB",
    sky       = "#89DCEB",
    black_0   = "#161320",
    black_1   = "#1A1826",
    black_2   = "#1E1E2E",
    black_3   = "#302D41",
    black_4   = "#575268",
    gray_0    = "#6E6C7E",
    gray_1    = "#988BA2",
    gray_2    = "#C3BAC6",
    white     = "#D9E0EE",
    lavender  = "#C9CBFF",
    rosewater = "#F5E0DC",
}

-- Main Theme
--------------------------------------------------
local bg_prime_colors = {
    colors.flamingo,
    colors.mauve,
    colors.pink,
    colors.maroon,
    colors.red,
    colors.peach,
    colors.yellow,
    colors.green,
    colors.teal,
    colors.blue,
    colors.sky,
    colors.white,
    colors.lavender,
    colors.rosewater,
}

local main = table.remove(bg_prime_colors, math.random(#bg_prime_colors))
local secondary = bg_prime_colors[math.random(#bg_prime_colors)]

local theme = {
    main   = main,
    second = secondary,
    gray   = colors.gray_2,
    bg     = {
        normal   = colors.black_2,
        focus    = main,
        urgent   = secondary,
        minimize = colors.black_4,
        button   = {
            normal = colors.black_3,
            hover  = colors.black_4,
            active = colors.black_1,
        },
    },
    fg     = {
        normal   = colors.white,
        focus    = colors.gray_0,
        urgent   = colors.rosewater,
        minimize = colors.lavender,
        button   = {
            normal = colors.white,
            hover  = colors.lavender,
            active = colors.rosewater,
        },
    },
}

local mainMenuIconStyle = (".primary {stroke: %s; fill: none;}"):format(theme.main)

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
    launcher        = {
        shape   = function(ctx, width, height) gears.shape.rounded_rect(ctx, width, height, dpi(3)) end,
        padding = dpi(5),
    },
    layoutbox       = {
        bg         = {
            normal = theme.bg.button.normal,
            hover  = theme.bg.button.hover,
            active = theme.bg.button.active,
        },
        padding    = dpi(5),
        shape      = function(ctx, width, height) gears.shape.rounded_rect(ctx, width, height, dpi(3)) end,
        stylesheet = (".icon {stroke: %s;}"):format(theme.main),
    },
    layoutlist      = {
        selection_notch_tempate = {},
        selection               = function(selected) return selected and theme.main or theme.bg.minimize end,
        stylesheet              = (".icon {stroke: %s;}"):format(theme.main),
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
    },
    layout          = {
        floating         = default_theme_path .. "default/layouts/floatingw.png",
        binaryTreeLayout = gfs.get_xdg_config_home() .. "/awesome/binary-tree-layout/icon.svg",
    },
    mainmenu        = {
        image       = {
            reload   = {
                theme_path .. "mainMenu/power.svg",
                stylesheet = mainMenuIconStyle,
            },
            quit     = {
                theme_path .. "mainMenu/power.svg",
                stylesheet = mainMenuIconStyle,
            },
            sleep    = {
                theme_path .. "mainMenu/sleep.svg",
                stylesheet = mainMenuIconStyle,
            },
            reboot   = {
                theme_path .. "mainMenu/reboot.svg",
                stylesheet = mainMenuIconStyle,
            },
            shutdown = {
                theme_path .. "mainMenu/power.svg",
                stylesheet = mainMenuIconStyle,
            },
        },
        bg          = {
            left  = colors.black_0,
            right = colors.black_0,
        },
        category    = {
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
        application = {
            bg = {
                normal = theme.bg.button.normal,
                hover  = theme.bg.button.hover,
                active = theme.bg.button.active,
            },
            fg = {
                normal = theme.fg.button.normal,
                hover  = theme.fg.button.hover,
                active = theme.fg.button.active,
            },
            shape = function(ctx, width, height) gears.shape.rounded_rect(ctx, width, height, 3) end,
        },
    },
    profile         = {
        picture = {
            bg           = colors.black_4,
            shape        = gears.shape.circle,
            border_width = 0,
        },
    },
    separator_color = theme.gray,
    systray         = {
        widget = {
            icon    = {
                theme_path .. "systray.svg",
                stylesheet = mainMenuIconStyle,
                spacing = 10,
            },
            bg      = {
                normal = theme.bg.button.normal,
                hover  = theme.bg.button.hover,
                active = theme.bg.button.active,
            },
            fg      = {
                normal = theme.fg.button.normal,
                hover  = theme.fg.button.hover,
                active = theme.fg.button.active,
            },
            padding = dpi(5),
            margins = dpi(5),
            shape   = function(ctx, width, height) gears.shape.rounded_rect(ctx, width, height, dpi(3)) end,
        },
        popup = {
            border_color = theme.main,
        },
    },
    taglist         = {
        disable_icon = true,
        bg           = {
            occupied = colors.gray_1,
            normal   = theme.bg.button.normal,
            hover    = theme.bg.button.hover,
            active   = theme.bg.button.active,
        },
        fg           = {
            occupied = theme.fg.minimize,
            normal   = theme.fg.button.normal,
            hover    = theme.fg.button.hover,
            active   = theme.fg.button.active,
        },
        padding      = dpi(5),
        shape        = function(ctx, width, height) gears.shape.rounded_rect(ctx, width, height, dpi(3)) end,
        width        = dpi(35),
    },
    tasklist        = {
        plain_task_name = true,
        width           = 150,
        bg              = {
            normal = theme.bg.button.normal,
            hover  = theme.bg.button.hover,
            active = theme.bg.button.active,
        },
        fg              = {
            normal = theme.fg.button.normal,
            hover  = theme.fg.button.hover,
            active = theme.fg.button.active,
        },
        padding         = dpi(5),
        shape           = function(ctx, width, height) gears.shape.rounded_rect(ctx, width, height, dpi(3)) end,
    },
    titlebar        = {
        close_button     = {
            normal = default_theme_path .. "default/titlebar/close_normal.png",
            focus  = default_theme_path .. "default/titlebar/close_focus.png",
        },
        minimize_button  = {
            normal = default_theme_path .. "default/titlebar/minimize_normal.png",
            focus  = default_theme_path .. "default/titlebar/minimize_focus.png",
        },
        ontop_button     = {
            normal = {
                active   = default_theme_path .. "default/titlebar/ontop_normal_active.png",
                inactive = default_theme_path .. "default/titlebar/ontop_normal_inactive.png",
            },
            focus  = {
                active   = default_theme_path .. "default/titlebar/ontop_focus_active.png",
                inactive = default_theme_path .. "default/titlebar/ontop_focus_inactive.png",
            },
        },
        sticky_button    = {
            normal = {
                active   = default_theme_path .. "default/titlebar/sticky_normal_active.png",
                inactive = default_theme_path .. "default/titlebar/sticky_normal_inactive.png",
            },
            focus  = {
                active   = default_theme_path .. "default/titlebar/sticky_focus_active.png",
                inactive = default_theme_path .. "default/titlebar/sticky_focus_inactive.png",
            },
        },
        floating_button  = {
            normal = {
                active   = default_theme_path .. "default/titlebar/floating_normal_active.png",
                inactive = default_theme_path .. "default/titlebar/floating_normal_inactive.png",
            },
            focus  = {
                active   = default_theme_path .. "default/titlebar/floating_focus_active.png",
                inactive = default_theme_path .. "default/titlebar/floating_focus_inactive.png",
            },
        },
        maximized_button = {
            normal = {
                active   = default_theme_path .. "default/titlebar/maximized_normal_active.png",
                inactive = default_theme_path .. "default/titlebar/maximized_normal_inactive.png",
            },
            focus  = {
                active   = default_theme_path .. "default/titlebar/maximized_focus_active.png",
                inactive = default_theme_path .. "default/titlebar/maximized_focus_inactive.png",
            },
        },
    },
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
    wibar           = {
        height   = dpi(40),
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
        tbl[prefix:match "(.*)_"] = tbl2[1]
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

print(require "utils".toJson(convertConfig({}, config), true))

return convertConfig({}, config)
