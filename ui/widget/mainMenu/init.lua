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
local mainMenu = {
    pattern = gString.query_to_pattern "",
    category = nil,
    categories = nil,
    applications = {},
    widget = nil,
    mt = {},
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

function mainMenu.default_style()
    return {
        bg           = beautiful["mainmenu_bg"] or beautiful.bg,
        bg_left      = beautiful["mainmenu_bg_left"] or beautiful.bg_minimize,
        bg_right     = beautiful["mainmenu_bg_right"] or beautiful.bg_minimize,
        img_reload   = beautiful["mainmenu_image_reload"] or beautiful.awesome_icon,
        img_quit     = beautiful["mainmenu_image_quit"] or beautiful.awesome_icon,
        img_sleep    = beautiful["mainmenu_image_sleep"] or beautiful.awesome_icon,
        img_reboot   = beautiful["mainmenu_image_reboot"] or beautiful.awesome_icon,
        img_shutdown = beautiful["mainmenu_image_shutdown"] or beautiful.awesome_icon,
    }
end

function mainMenu:set_coords(s, coords)
    local workarea = s.workarea

    if coords == nil then coords = capi.mouse.coords() end

    self.widget.x = utils.clamp(coords.x, workarea.x, workarea.x + workarea.width - self.widget.width)
    self.widget.y = utils.clamp(coords.y, workarea.y, workarea.y + workarea.height - self.widget.height)
end

function mainMenu:genSideCategories(categories)
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
        callback = function() mainMenu:setCategory(nil) end
    })

    for k, v in pairs(categories) do
        local index = 2
        while index <= #w.children and w.children[index].category.name < v.name do
            index = index + 1
        end
        w:insert(index, categoryWidget { category = v, callback = function() mainMenu:setCategory(k) end })
    end
end

function mainMenu:setCategory(category)
    if self.category == category then
        return
    end

    self.category = category
    self:resetApplicationsWidget()
end

function mainMenu:resetApplicationsWidget()
    self.widget.shownItems:reset()
    for _, v in ipairs(self.applications) do
        if (not self.category or (v.category == self.category))
            and (v.name:match("^" .. self.pattern) or v.cmdline:match("^" .. self.pattern)) then
            self.widget.shownItems:add(applicationWidget { application = v, callback = self.appliction_callback })
        end
    end
end

function mainMenu.appliction_callback(application)
    awful.spawn(application.cmdline)
    mainMenu:hide()
end

function mainMenu:init(args)
    args = args or {}
    args.style = gTable.merge(mainMenu.default_style(), args.style or {})

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
                                text    = "Reload",
                                image   = args.style.img_reload,
                                buttons = {
                                    utils.aButton {
                                        modifiers = {},
                                        button    = 1,
                                        callback  = awesome.restart,
                                    }
                                }
                            },
                            button {
                                text    = "Quit",
                                image   = args.style.img_quit,
                                buttons = {
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
                                text    = "Sleep",
                                image   = args.style.img_sleep,
                                buttons = {
                                    utils.aButton {
                                        modifiers = {},
                                        button    = 1,
                                        callback  = function() awful.spawn.with_shell "systemctl suspend" end,
                                    }
                                }
                            },
                            button {
                                text    = "Restart",
                                image   = args.style.img_reboot,
                                buttons = {
                                    utils.aButton {
                                        modifiers = {},
                                        button    = 1,
                                        callback  = function() awful.spawn.with_shell "reboot" end,
                                    }
                                }
                            },
                            button {
                                text    = "Shutdown",
                                image   = args.style.img_shutdown,
                                buttons = {
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

function mainMenu:hide()
    self.widget.visible = false
end

function mainMenu:show(args)
    args = args or {}
    local coords = args.coords or nil
    local s = args.screen or capi.mouse.screen

    self:resetApplicationsWidget()

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
            table.sort(result, function(a, b) return a.name < b.name end)
            self.applications = result
        end)
    end

    return self
end

--------------------------------------------------
function mainMenu.mt:__call(...)
    return mainMenu:new(...)
end

return setmetatable(mainMenu, mainMenu.mt)

--------------------------------------------------
