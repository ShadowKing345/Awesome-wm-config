--------------------------------------------------
--
--      Main Menu widget.
--
--------------------------------------------------
local setmetatable = setmetatable

local beautiful = require "beautiful"
local wibox = require "wibox"

local inputField = require "ui.widgets.inputField"

--------------------------------------------------
local mainMenu = { widget = nil, mt = {} }

function mainMenu:init(args)
    self.widget = wibox {
        ontop = true,
    }

    self.widget:geometry {
        x = 50,
        y = 50,
        width = 720,
        height = 550,
    }

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

    self.widget:setup {
        {
            {
                {
                    {
                        {
                            {
                                image = beautiful.awesome_icon,
                                forced_width = 26,
                                forced_height = 26,
                                widget = wibox.widget.imagebox,
                            },
                            {
                                text = "Username",
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
                    widget = wibox.container.background,
                },
                {
                    hSeperator,
                    {
                        widget = wibox.container.background,
                    },
                    hSeperator,
                    layout = wibox.layout.align.vertical,
                },
                {
                    {
                        {
                            {
                                text = "Reload",
                                widget = wibox.widget.textbox,
                            },
                            {
                                text = "Quit",
                                widget = wibox.widget.textbox,
                            },
                            spacing = 10,
                            layout = wibox.layout.flex.horizontal,
                        },
                        margins = 12,
                        widget = wibox.container.margin,
                    },
                    forced_height = 50,
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
                        {
                            placeholder = "Search...",
                            widget = inputField,
                        },
                        margins = 12,
                        widget = wibox.container.margin,
                    },
                    forced_height = 50,
                    widget = wibox.container.background,
                },
                {
                    hSeperator,
                    {
                        widget = wibox.container.background,
                    },
                    hSeperator,
                    layout = wibox.layout.align.vertical,
                },
                {
                    {
                        {
                            {
                                text = "Sleep",
                                widget = wibox.widget.textbox,
                            },
                            {
                                text = "Restart",
                                widget = wibox.widget.textbox,
                            },
                            {
                                text = "Shutdown",
                                widget = wibox.widget.textbox,
                            },
                            nil,
                            fill_space = true,
                            spacing = 10,
                            layout = wibox.layout.fixed.horizontal,
                        },
                        margins = 12,
                        widget = wibox.container.margin,
                    },
                    forced_height = 50,
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
    --local coords = args.coords or nil
    --local s = capi.screen[screen.focused()]

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

    return self
end

--  Setup Metadata
--------------------------------------------------
function mainMenu.mt:__call(...)
    return mainMenu:new(...)
end

return setmetatable(mainMenu, mainMenu.mt)
