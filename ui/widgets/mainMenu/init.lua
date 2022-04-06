--------------------------------------------------
--
--      Main Menu widget.
--
--------------------------------------------------
local setmetatable = setmetatable

local awful = require "awful"
local beautiful = require "beautiful"
local capi = { screen = screen, mouse = mouse, client = client }
local gfs = require "gears.filesystem"
local gTable = require "gears.table"
local gShape = require "gears.shape"
local menu_gen = require "menubar.menu_gen"
local wibox = require "wibox"

local relPath = (...):match ".*"
local application = require(relPath .. ".application")
local category = require(relPath .. ".category")
local button = require(relPath .. ".button")
local inputField = require "ui.widgets.inputField"
local utils = require "utils"

--------------------------------------------------
local mainMenu = { applications = {}, widget = nil, mt = {} }

local vSeperator = wibox.widget {
    orientation = "vertical",
    forced_width = 1,
    widget = wibox.widget.separator,
}

local hSeperator = wibox.widget {
    orientation = "horizontal",
    forced_height = 1,
    widget = wibox.widget.separator,
}

function mainMenu.default_style()
    return {
        profile_picture = beautiful["profile_picture"] or os.getenv "HOME" .. "/.face",
        username = beautiful["username"] or os.getenv "HOME":match "/home/(%w+)",
        bg = beautiful["main_menu_bg"] or beautiful.bg,
        bg_left = beautiful["main_menu_bg_left"] or beautiful.bg_minimize,
        bg_right = beautiful["main_menu_bg_right"] or beautiful.bg_minimize,
        img_reload = beautiful["main_menu_image_reload"] or beautiful.awesome_icon,
        img_quit = beautiful["main_menu_image_quit"] or beautiful.awesome_icon,
        img_sleep = beautiful["main_menu_image_sleep"] or beautiful.awesome_icon,
        img_reboot = beautiful["main_menu_image_reboot"] or beautiful.awesome_icon,
        img_shutdown = beautiful["main_menu_image_shutdown"] or beautiful.awesome_icon,
    }
end

function mainMenu:set_coords(s, coords)
    local workarea = s.workarea

    if coords == nil then coords = capi.mouse.coords() end

    self.widget.x = utils.clamp(coords.x, workarea.x, workarea.x + workarea.width - self.widget.width)
    self.widget.y = utils.clamp(coords.y, workarea.y, workarea.y + workarea.height - self.widget.height)
end

function mainMenu:init(args)
    args = args or {}
    args.style = gTable.merge(mainMenu.default_style(), args.style or {})

    self.widget = wibox {
        ontop = true,
        width = 720,
        height = 550,
    }

    local categories = {
        category { category = { icon_name = "", name = "All" } },
        spacing = 1,
        layout = wibox.layout.flex.vertical,
    }

    for _, v in pairs(menu_gen.all_categories) do
        local index = 1
        while index <= #categories and (categories[index].category.name == "All" or categories[index].category.name < v.name) do
            index = index + 1
        end
        table.insert(categories, index, category { category = v })
    end

    self.widget.applications = wibox.widget {
        spacing = 10,
        forced_num_cols = 5,
        horizontal_expand = true,
        layout = wibox.layout.grid.vertical,
    }

    self.widget:setup {
        {
            {
                {
                    {
                        {
                            {
                                image = args.style.profile_picture,
                                forced_width = 26,
                                forced_height = 26,
                                widget = wibox.widget.imagebox,
                            },
                            {
                                text = args.style.username,
                                widget = wibox.widget.textbox,
                            },
                            fill_space = true,
                            spacing = 10,
                            layout = wibox.layout.fixed.horizontal,
                        },
                        margins = 12,
                        widget = wibox.container.margin,
                    },
                    forced_height = 50,
                    bg = args.style.bg,
                    widget = wibox.container.background,
                },
                {
                    hSeperator,
                    {
                        categories,
                        bg = args.style.bg_left,
                        widget = wibox.container.background,
                    },
                    hSeperator,
                    layout = wibox.layout.align.vertical,
                },
                {
                    {
                        {
                            button {
                                text = "Reload",
                                image = args.style.img_reload,
                                buttons = {
                                    utils.aButton {
                                        modifiers = {},
                                        button = 1,
                                        callback = awesome.restart,
                                    }
                                }
                            },
                            button {
                                text = "Quit",
                                image = args.style.img_quit,
                                buttons = {
                                    utils.aButton {
                                        modifiers = {},
                                        button = 1,
                                        callback = function() awesome.quit() end,
                                    }
                                }
                            },
                            spacing = 10,
                            layout = wibox.layout.flex.horizontal,
                        },
                        margins = 12,
                        widget = wibox.container.margin,
                    },
                    forced_height = 50,
                    bg = args.style.bg,
                    widget = wibox.container.background,
                },
                layout = wibox.layout.align.vertical,
            },
            forced_width = 240,
            widget = wibox.container.background,
        },
        {
            {
                {
                    {
                        inputField {
                            prompt_args = {
                                prompt = "Search: ",
                                completion_callback = awful.completion.shell,
                                history_path = gfs.get_cache_dir() .. "/history_menu",
                                done_callback = function()
                                    mainMenu:hide()
                                end,
                                change_callback = function(query)
                                    require "naughty".notify { text = tostring(query) }

                                end
                            }
                        },
                        margins = 12,
                        widget = wibox.container.margin,
                    },
                    forced_height = 50,
                    bg = args.style.bg,
                    widget = wibox.container.background,
                },
                {
                    hSeperator,
                    {
                        {
                            {
                                {
                                    self.widget.applications,
                                    margins = 10,
                                    widget = wibox.container.margin,
                                },
                                widget = wibox.container.background,
                            },
                            {
                                {
                                    bar_color = "#ff0000",
                                    handle_color = "#ffff00",
                                    handle_width = 100,
                                    value = 25,
                                    widget = wibox.widget.slider,
                                },
                                direction = "west",
                                widget = wibox.container.rotate,
                            },
                            expand = "outer",
                            layout = wibox.layout.align.horizontal,
                        },
                        bg = args.style.bg_right,
                        widget = wibox.container.background,
                    },
                    hSeperator,
                    layout = wibox.layout.align.vertical,
                },
                {
                    {
                        {
                            button {
                                text = "Sleep",
                                image = args.style.img_sleep,
                                buttons = {
                                    utils.aButton {
                                        modifiers = {},
                                        button = 1,
                                        callback = function() awful.spawn.with_shell "systemctl suspend" end,
                                    }
                                }
                            },
                            button {
                                text = "Restart",
                                image = args.style.img_reboot,
                                buttons = {
                                    utils.aButton {
                                        modifiers = {},
                                        button = 1,
                                        callback = function() awful.spawn.with_shell "reboot" end,
                                    }
                                }
                            },
                            button {
                                text = "Shutdown",
                                image = args.style.img_shutdown,
                                buttons = {
                                    utils.aButton {
                                        modifiers = {},
                                        button = 1,
                                        callback = function() awful.spawn.with_shell "shutdown now" end,
                                    }
                                }
                            },
                            {
                                widget = wibox.container.background,
                            },
                            fill_space = true,
                            spacing = 10,
                            layout = wibox.layout.fixed.horizontal,
                        },
                        margins = 12,
                        widget = wibox.container.margin,
                    },
                    forced_height = 50,
                    bg = args.style.bg,
                    widget = wibox.container.background,
                },
                layout = wibox.layout.align.vertical,
            },
            widget = wibox.container.background,
        },
        spacing_widget = vSeperator,
        spacing = 1,
        fill_space = true,
        layout = wibox.layout.fixed.horizontal,
    }
end

function mainMenu:hide()
    self.widget.visible = false
end

function mainMenu:show(args)
    args = args or {}
    local coords = args.coords or nil
    local s = args.screen or capi.mouse.screen

    self.widget.applications:reset()
    for _, v in ipairs(self.applications) do
        self.widget.applications:add(wibox.widget {
            application { application = v },
            widget = wibox.container.place,
        })
    end

    self:set_coords(s, coords)
    self.widget.visible = true
end

function mainMenu:toggle(args)
    if self.widget.visible then
        mainMenu:hide()
    else
        mainMenu:show(args)
    end
end

function mainMenu:new(args)
    if not self.widget then
        self:init(args)
    end

    if #self.applications < 1 then
        menu_gen.generate(function(result)
            self.applications = result
            table.sort(self.applications, function(a, b) return a.name < b.name end)
        end)
    end

    return self
end

--------------------------------------------------
function mainMenu.mt:__call(...)
    return mainMenu:new(...)
end

return setmetatable(mainMenu, mainMenu.mt)
