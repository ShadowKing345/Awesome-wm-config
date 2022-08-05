--[[

    Main Menu widget.

--]]
--------------------------------------------------
local setmetatable = setmetatable

local awful       = require "awful"
local beautiful   = require "beautiful"
local capi        = { screen = screen, mouse = mouse, client = client }
local gFilesystem = require "gears.filesystem"
local gTable      = require "gears.table"
local gString     = require "gears.string"
local menu_gen    = require "menubar.menu_gen"
local wibox       = require "wibox"

local relPath           = (...):match ".*"
local applicationWidget = require(relPath .. ".application")
local categoryWidget    = require(relPath .. ".category")
local button            = require(relPath .. ".button")
local inputField        = require "ui.widget.inputField"
local profile           = require "ui.widget.profile"
-- NOTE: Remove when overflow layout comes out.
wibox.layout.overflow   = require "ui.layouts.overflow"
local utils             = require "utils"

--------------------------------------------------
local M = {
    pattern      = gString.query_to_pattern "",
    category     = nil,
    categories   = nil,
    applications = {},
    widget       = nil,
    mt           = {},
    launcher     = nil,
}

local vSeperator = wibox.widget {
    orientation  = "vertical",
    forced_width = 1,
    widget       = wibox.widget.separator,
}

local hSeperator = wibox.widget {
    orientation   = "horizontal",
    forced_height = 1,
    widget        = wibox.widget.separator,
}

function M.default_style()
    return {
        bg           = beautiful["mainmenu_bg"] or beautiful.bg,
        bg_left      = beautiful["mainmenu_bg_left"] or beautiful.bg_minimize,
        bg_right     = beautiful["mainmenu_bg_right"] or beautiful.bg_minimize,
        img_reload   = {
            beautiful["mainmenu_image_reload"] or beautiful.awesome_icon,
            stylesheet = beautiful["mainmenu_image_reload_stylesheet"],
        },
        img_quit     = {
            beautiful["mainmenu_image_quit"] or beautiful.awesome_icon,
            stylesheet = beautiful["mainmenu_image_quit_stylesheet"],
        },
        img_sleep    = {
            beautiful["mainmenu_image_sleep"] or beautiful.awesome_icon,
            stylesheet = beautiful["mainmenu_image_sleep_stylesheet"],
        },
        img_reboot   = {
            beautiful["mainmenu_image_reboot"] or beautiful.awesome_icon,
            stylesheet = beautiful["mainmenu_image_reboot_stylesheet"],
        },
        img_shutdown = {
            beautiful["mainmenu_image_shutdown"] or beautiful.awesome_icon,
            stylesheet = beautiful["mainmenu_image_shutdown_stylesheet"],
        },
    }
end

function M:set_coords(s, coords)
    local workarea = s.workarea

    if coords == nil then coords = capi.mouse.coords() end

    self.widget.x = utils.clamp(coords.x, workarea.x, workarea.x + workarea.width - self.widget.width)
    self.widget.y = utils.clamp(coords.y, workarea.y, workarea.y + workarea.height - self.widget.height)
end

function M:genSideCategories(categories)
    self.categories = self.categories or wibox.widget {
        spacing = 1,
        layout  = wibox.layout.overflow.vertical,
    }

    local w = self.categories
    w:reset()
    w:add(categoryWidget {
        category = {
            icon_name = "",
            name      = "All"
        },
        callback = function() M:setCategory(nil) end
    })

    for k, v in pairs(categories) do
        local index = 2
        while index <= #w.children and w.children[index].category.name < v.name do
            index = index + 1
        end
        w:insert(index, categoryWidget { category = v, callback = function() M:setCategory(k) end })
    end
end

function M:setCategory(category)
    if self.category == category then
        return
    end

    self.category = category
    self:resetApplicationsWidget()
end

function M:resetApplicationsWidget()
    self.widget.shownItems:reset()
    for _, v in ipairs(self.applications) do
        if (not self.category or (v.category == self.category))
            and (v.name:match("^" .. self.pattern) or v.cmdline:match("^" .. self.pattern)) then
            self.widget.shownItems:add(applicationWidget { application = v, callback = self.appliction_callback })
        end
    end
end

function M.appliction_callback(application)
    awful.spawn(application.cmdline)
    M:hide()
end

function M.launcherDefaultStyle(style)
    return gTable.merge({
        padding = beautiful["launcher_padding"],
        shape   = beautiful["launcher_shape"],
    }, style or {})
end

function M:createLauncher(args)
    args = args or {}

    if self.launcher and not args.force then
        return self.launcher
    end

    local style = self.launcherDefaultStyle(args.style or {})
    self.launcher = wibox.widget {
        {
            {
                image  = beautiful.awesome_icon,
                widget = wibox.widget.imagebox,
            },
            shape  = style.shape,
            widget = wibox.container.background,
        },
        margins = style.padding,
        widget  = wibox.container.margin,
        buttons = {
            utils.aButton {
                modifiers = {},
                button = 1,
                callback = function()
                    local geometry = mouse.screen.geometry
                    geometry.y = geometry.height
                    self:toggle {
                        coords = geometry,
                        screen = mouse.screen
                    }
                end,
            }
        }
    }
    return self.launcher
end

function M:init(args)
    args = args or {}
    args.style = gTable.merge(M.default_style(), args.style or {})

    self.widget = wibox {
        ontop  = true,
        width  = 720,
        height = 550,
    }

    if not self.categories then
        self:genSideCategories(menu_gen.all_categories)
    end

    self.widget.shownItems = self.widget.shownItems or wibox.widget {
        spacing           = 10,
        forced_num_cols   = 5,
        horizontal_expand = true,
        layout            = wibox.layout.grid.vertical,
    }

    self.widget:setup {
        {
            {
                {
                    profile(),
                    forced_height = 50,
                    bg            = args.style.bg,
                    widget        = wibox.container.background,
                },
                {
                    hSeperator,
                    {
                        self.categories,
                        bg     = args.style.bg_left,
                        widget = wibox.container.background,
                    },
                    hSeperator,
                    layout = wibox.layout.align.vertical,
                },
                {
                    {
                        {
                            button {
                                text       = "Reload",
                                image      = args.style.img_reload[1],
                                stylesheet = args.style.img_reload.stylesheet,
                                buttons    = {
                                    utils.aButton {
                                        modifiers = {},
                                        button    = 1,
                                        callback  = awesome.restart,
                                    }
                                }
                            },
                            button {
                                text       = "Quit",
                                image      = args.style.img_quit[1],
                                stylesheet = args.style.img_quit.stylesheet,
                                buttons    = {
                                    utils.aButton {
                                        modifiers = {},
                                        button    = 1,
                                        callback  = function() awesome.quit() end,
                                    }
                                }
                            },
                            spacing = 10,
                            layout  = wibox.layout.flex.horizontal,
                        },
                        margins = 12,
                        widget  = wibox.container.margin,
                    },
                    forced_height = 50,
                    bg            = args.style.bg,
                    widget        = wibox.container.background,
                },
                layout = wibox.layout.align.vertical,
            },
            forced_width = 240,
            widget       = wibox.container.background,
        },
        {
            {
                {
                    {
                        inputField {
                            prompt_args = {
                                prompt              = self.pattern,
                                completion_callback = awful.completion.shell,
                                history_path        = gFilesystem.get_cache_dir() .. "/history_menu",
                                changed_callback    = function(query)
                                    if self.pattern == query then
                                        return
                                    end

                                    self.pattern = gString.query_to_pattern(query)
                                    self:resetApplicationsWidget()
                                end
                            }
                        },
                        margins = 12,
                        widget  = wibox.container.margin,
                    },
                    forced_height = 50,
                    bg            = args.style.bg,
                    widget        = wibox.container.background,
                },
                {
                    hSeperator,
                    {
                        {
                            {
                                {
                                    self.widget.shownItems,
                                    margins = 10,
                                    widget  = wibox.container.margin,
                                },
                                widget = wibox.container.background,
                            },
                            layout = wibox.layout.overflow.vertical,
                        },
                        bg     = args.style.bg_right,
                        widget = wibox.container.background,
                    },
                    hSeperator,
                    layout = wibox.layout.align.vertical,
                },
                {
                    {
                        {
                            button {
                                text       = "Sleep",
                                image      = args.style.img_sleep[1],
                                stylesheet = args.style.img_sleep.stylesheet,
                                buttons    = {
                                    utils.aButton {
                                        modifiers = {},
                                        button    = 1,
                                        callback  = function() awful.spawn.with_shell "systemctl suspend" end,
                                    }
                                }
                            },
                            button {
                                text       = "Restart",
                                image      = args.style.img_reboot[1],
                                stylesheet = args.style.img_reboot.stylesheet,
                                buttons    = {
                                    utils.aButton {
                                        modifiers = {},
                                        button    = 1,
                                        callback  = function() awful.spawn.with_shell "reboot" end,
                                    }
                                }
                            },
                            button {
                                text       = "Shutdown",
                                image      = args.style.img_shutdown[1],
                                stylesheet = args.style.img_shutdown.stylesheet,
                                buttons    = {
                                    utils.aButton {
                                        modifiers = {},
                                        button    = 1,
                                        callback  = function() awful.spawn.with_shell "shutdown now" end,
                                    }
                                }
                            },
                            {
                                widget = wibox.container.background,
                            },
                            fill_space = true,
                            spacing    = 10,
                            layout     = wibox.layout.fixed.horizontal,
                        },
                        margins = 12,
                        widget  = wibox.container.margin,
                    },
                    forced_height = 50,
                    bg            = args.style.bg,
                    widget        = wibox.container.background,
                },
                layout = wibox.layout.align.vertical,
            },
            widget = wibox.container.background,
        },
        spacing_widget = vSeperator,
        spacing        = 1,
        fill_space     = true,
        layout         = wibox.layout.fixed.horizontal,
    }
end

function M:hide()
    self.widget.visible = false
end

function M:show(args)
    args = args or {}
    local coords = args.coords or nil
    local s = args.screen or capi.mouse.screen

    self:resetApplicationsWidget()

    self:set_coords(s, coords)
    self.widget.visible = true
end

function M:toggle(args)
    if self.widget.visible then
        M:hide()
    else
        M:show(args)
    end
end

function M:new(args)
    if not self.widget then
        self:init(args)
    end

    if #self.applications < 1 then
        menu_gen.generate(function(result)
            table.sort(result, function(a, b) return a.name < b.name end)
            self.applications = result
        end)
    end

    return self
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)

--------------------------------------------------
