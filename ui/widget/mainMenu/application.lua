--------------------------------------------------
--
--      Application button widget for main menu.
--
--------------------------------------------------
local setmetatable = setmetatable

local beautiful = require "beautiful"
local gTable = require "gears.table"
local wibox = require "wibox"

--------------------------------------------------
local application = { mt = {} }

function application.default_style()
    return {
        bg = beautiful["mainmenu_application_bg_normal"] or beautiful.bg_normal,
        fg = beautiful["mainmenu_application_fg_normal"] or beautiful.fg_normal,
        width = beautiful["mainmenu_application_width"] or 80,
        height = beautiful["mainmenu_application_height"] or 80,
        default_application_icon = beautiful["mainmenu_application_default_application_icon"] or nil,
        padding = beautiful["mainmenu_application_padding"] or 5,
        image_padding = beautiful["mainmenu_application_image_padding"] or 5,
        font = beautiful["mainmenu_application_image_font"] or beautiful.font
    }
end

function application.new(args)
    args = args or {}
    args.style = gTable.merge(application.default_style(), args.style or {})

    local ret = wibox.widget {
        {
            {
                nil,
                {
                    {
                        {
                            image = args.application.icon or args.style.default_application_icon,
                            widget = wibox.widget.imagebox,
                        },
                        widget = wibox.container.place,
                    },
                    margins = args.style.image_padding,
                    widget = wibox.container.margin,
                },
                {
                    text = args.application.name,
                    ellipsize = "end",
                    wrap = "char",
                    widget = wibox.widget.textbox,
                    forced_height = beautiful.get_font_height(args.style.font)
                },
                layout = wibox.layout.align.vertical,
            },
            margins = args.style.padding,
            widget = wibox.container.margin,
        },
        forced_width = args.style.width,
        forced_height = args.style.height,
        bg = args.style.bg,
        fg = args.style.fg,
        widget = wibox.container.background,
    }

    gTable.crush(ret, application, true)
    gTable.crush(ret, args, true)

    if args.callback then
        ret:connect_signal("button::press", function(self, _, _, button)
            if button == 1 then
                args.callback(self)
            end
        end)
    end

    return ret
end

--------------------------------------------------
function application.mt:__call(...)
    return application.new(...)
end

return setmetatable(application, application.mt)
