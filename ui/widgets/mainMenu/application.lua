--------------------------------------------------
--
--      Application button widget for main menu.
--
--------------------------------------------------
local setmetatable = setmetatable

local wibox = require "wibox"

--------------------------------------------------
local application = { mt = {} }

function application.new(args)
    args = args or {}

    return wibox.widget {
        {
            nil,
            {
                image = args.application.icon,
                widget = wibox.widget.imagebox,
            },
            {
                {
                    text = args.application.name,
                    widget = wibox.widget.textbox,
                },
                widget = wibox.container.scroll.horizontal,
            },
            layout = wibox.layout.align.vertical,
        },
        forced_width = 80,
        forced_height = 80,
        bg = "#ff0000",
        widget = wibox.container.background,
    }
end

--------------------------------------------------
function application.mt:__call(...)
    return application.new(...)
end

return setmetatable(application, application.mt)
