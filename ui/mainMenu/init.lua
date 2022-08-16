--[[

    Main Menu widget.

--]]
--------------------------------------------------
local awful     = require "awful"
local beautiful = require "beautiful"
local dpi       = require "beautiful.xresources".apply_dpi
local gTable    = require "gears.table"
local gString   = require "gears.string"
local wibox     = require "wibox"
local menuGen   = require "menubar.menu_gen"

local relPath           = (...):match ".*"
local applicationWidget = require(relPath .. ".application")
local categoryWidget    = require(relPath .. ".category")
local buttonWidget      = require(relPath .. ".button")
local launcherWidget    = require(relPath .. ".launcher")
local inputField        = require "ui.widget.inputField"
local profileWidget     = require "ui.widget.profile"
-- NOTE: Remove when overflow layout comes out.
wibox.layout.overflow   = require "ui.layouts.overflow"
local utils             = require "utils"

--------------------------------------------------
local M = {
    pattern            = gString.query_to_pattern "",
    categoriesWidget   = nil,
    category           = nil,
    applicationsWidget = nil,
    applications       = nil,
    mt                 = {},
}

local function call(spawn)
    return function() awful.spawn.with_shell(spawn) end
end

local spacer = {
    v = wibox.widget {
        orientation  = "vertical",
        forced_width = 1,
        widget       = wibox.widget.separator,
    },
    h = wibox.widget {
        orientation   = "horizontal",
        forced_height = 1,
        widget        = wibox.widget.separator,
    }
}

function M.defaultStyle(style)
    local n = "mainmenu_"
    local w = n .. "wibox_"
    local b = w .. "buttons_"
    local i = b .. "icons_"
    local l = n .. "launcher_"
    return utils.deepMerge({
        launcher = {
            icon       = beautiful[l .. "icon"] or beautiful.awesome_icon,
            stylesheet = beautiful[l .. "stylesheet"],
            margins    = beautiful[l .. "margins"],
            padding    = beautiful[l .. "padding"],
            shape      = beautiful[l .. "shape"],
            bg         = {
                normal = beautiful[l .. "bg_normal"],
                hover  = beautiful[l .. "bg_hover"],
                active = beautiful[l .. "bg_active"],
            }
        },
        wibox    = {
            bg         = {
                top    = beautiful[w .. "bg_top"],
                bottom = beautiful[w .. "bg_bottom"],
                left   = beautiful[w .. "bg_left"],
                right  = beautiful[w .. "bg_right"],
            },
            categories = {
                spacing = beautiful[w .. "categories_spacing"] or 0,
            },
            buttons    = {
                icons   = {
                    stylesheet = beautiful[i .. "stylesheet"],
                    reload     = {
                        icon       = beautiful[i .. "reload_icon"] or beautiful.awesome_icon,
                        stylesheet = beautiful[i .. "reload_stylesheet"],
                    },
                    quit       = {
                        icon       = beautiful[i .. "quit_icon"] or beautiful.awesome_icon,
                        stylesheet = beautiful[i .. "quit_stylesheet"],
                    },
                    sleep      = {
                        icon       = beautiful[i .. "sleep_icon"] or beautiful.awesome_icon,
                        stylesheet = beautiful[i .. "sleep_stylesheet"],
                    },
                    reboot     = {
                        icon       = beautiful[i .. "reboot_icon"] or beautiful.awesome_icon,
                        stylesheet = beautiful[i .. "reboot_stylesheet"],
                    },
                    shutdown   = {
                        icon       = beautiful[i .. "shutdown_icon"] or beautiful.awesome_icon,
                        stylesheet = beautiful[i .. "shutdown_stylesheet"],
                    },
                },
                bg      = {
                    normal = beautiful[b .. "bg_normal"],
                    active = beautiful[b .. "bg_active"],
                    hover  = beautiful[b .. "bg_hover"],
                },
                fg      = {
                    normal = beautiful[b .. "fg_normal"],
                    active = beautiful[b .. "fg_active"],
                    hover  = beautiful[b .. "fg_hover"],
                },
                shape   = beautiful[b .. "shape"],
                spacing = beautiful[b .. "spacing"] or 0,
                padding = beautiful[b .. "padding"],
            },
        },
    }, style or {})
end

function M:configureAppliactions()
    menuGen.generate(function(result)
        table.sort(result, function(a, b) return a.name < b.name end)
        self.applications = result
        self:initApplications(true)
    end)
end

function M:setCategory(category)
    if self.category == category then
        return
    end

    self.category = category
    self:initApplications(true)
end

function M:getIconStyle(iconname)
    local style = self.style.wibox.buttons
    return {
        image      = style.icons[iconname].icon,
        stylesheet = style.icons[iconname].stylesheet or style.icons.stylesheet,
        bg         = style.bg,
        fg         = style.fg,
        shape      = style.shape,
        padding    = style.padding,
        spacing    = style.spacing,
    }
end

function M:createWidget(style)
    local fw = dpi(240)
    local fh = dpi(50)

    return wibox.widget {
        {
            {
                {
                    profileWidget(),
                    forced_width = fw,
                    margins      = dpi(5),
                    widget       = wibox.container.margin,
                },
                spacer.v,
                {
                    inputField(),
                    margins = dpi(10),
                    widget  = wibox.container.margin,
                },
                forced_height = fh,
                fill_space    = true,
                layout        = wibox.layout.fixed.horizontal,
            },
            bg     = style.bg.top,
            widget = wibox.container.background,
        },
        {
            spacer.h,
            {
                {
                    self.categoriesWidget,
                    bg           = style.bg.left,
                    forced_width = fw,
                    widget       = wibox.container.background,
                },
                spacer.v,
                {
                    {
                        {
                            self.applicationsWidget,
                            margins = 10,
                            widget  = wibox.container.margin,
                        },
                        layout = wibox.layout.overflow.vertical,
                    },
                    bg     = style.bg.right,
                    widget = wibox.container.background,
                },
                fill_space = true,
                layout     = wibox.layout.fixed.horizontal,
            },
            spacer.h,
            layout = wibox.layout.align.vertical,
        },
        {
            {
                {
                    {
                        buttonWidget {
                            text    = "Reload",
                            style   = M:getIconStyle "reload",
                            buttons = {
                                awful.button({}, 1, awesome.restart),
                            },
                        },
                        buttonWidget {
                            text    = "Quit",
                            style   = M:getIconStyle "quit",
                            buttons = {
                                awful.button({}, 1, awesome.quit),
                            },
                        },
                        spacing = dpi(10),
                        layout  = wibox.layout.flex.horizontal,
                    },
                    forced_width = fw,
                    margins      = dpi(10),
                    widget       = wibox.container.margin,
                },
                spacer.v,
                {
                    {
                        buttonWidget {
                            text    = "Sleep",
                            style   = M:getIconStyle "sleep",
                            buttons = {
                                awful.button({}, 1, call "systemctl suspend"),
                            },
                        },
                        buttonWidget {
                            text    = "Reboot",
                            style   = M:getIconStyle "reboot",
                            buttons = {
                                awful.button({}, 1, call "reboot"),
                            },
                        },
                        buttonWidget {
                            text    = "Shutdown",
                            style   = M:getIconStyle "shutdown",
                            buttons = {
                                awful.button({}, 1, call "shutdown now"),
                            },
                        },
                        {
                            widget = wibox.container.background,
                        },
                        spacing = dpi(10),
                        layout  = wibox.layout.flex.horizontal,
                    },
                    margins = dpi(10),
                    widget  = wibox.container.margin,
                },
                forced_height = fh,
                fill_space    = true,
                layout        = wibox.layout.fixed.horizontal,
            },
            bg     = style.bg.bottom,
            widget = wibox.container.background,
        },
        layout = wibox.layout.align.vertical,
    }
end

function M:initCategories(categories, force)
    if self.categoriesWidget and not force then
        return
    end

    local function setCategory(category)
        return function()
            M:setCategory(category)
        end
    end

    self.categoriesWidget = self.categoriesWidget or wibox.widget {
        spacing = dpi(self.style.wibox.categories.spacing),
        layout  = wibox.layout.overflow.vertical,
    }

    local c = {}

    for key, value in pairs(categories) do
        table.insert(c, { key = key, value = value })
    end
    table.sort(c, function(a, b) return a.value.name < b.value.name end)
    table.insert(c, 1, { value = { icon_name = "", name = "All", } })

    self.categoriesWidget:reset()
    for _, v in ipairs(c) do
        self.categoriesWidget:add(categoryWidget { category = v.value, callback = setCategory(v.key), })
    end
end

function M:initApplications(reset)
    if self.applicationsWidget and not reset then
        return
    end

    self.applicationsWidget = self.applicationsWidget or wibox.widget {
        spacing           = 10,
        forced_num_cols   = 5,
        horizontal_expand = true,
        layout            = wibox.layout.grid.vertical,
    }

    if not self.applications then
        self:configureAppliactions()
        return
    end

    local function callback(cmd)
        awful.spawn(cmd)
        self:hide()
    end

    self.applicationsWidget:reset()
    for _, v in ipairs(self.applications) do
        if (not self.category or v.category == self.category) and
            (v.name:match("^" .. self.pattern) or v.cmdline:match("^" .. self.pattern)) then
            self.applicationsWidget:add(applicationWidget { application = v, callback = callback })
        end
    end
end

function M:toggle(args)
    if self.visible then
        self:hide()
    else
        self:show(args)
    end
end

function M:hide()
    self.visible = false
end

function M:show(args)
    args = args or {}

    if args.geometry then
        awful.placement.next_to(self, { geometry = args.geometry })
    else
        awful.placement.under_mouse(self)
    end

    self:initApplications(true)

    self.visible = true
end

function M:createLauncher()
    return launcherWidget {
        style    = self.style.launcher,
        mainMenu = self,
    }
end

function M:new(args)
    args = args or {}
    self.style = self.defaultStyle(args.style or {})

    if not self.categoriesWidget then
        self:initCategories(args.categories or menuGen.all_categories)
    end

    if not self.applicationsWidget then
        self:initApplications()
    end

    local w = wibox {
        ontop  = true,
        width  = dpi(720),
        height = dpi(550),
        type   = "dock",
        widget = self:createWidget(self.style.wibox)
    }

    gTable.crush(w, self, true)

    return w
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
