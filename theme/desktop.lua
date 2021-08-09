local desktop = {mt = {}}

function desktop.new(args)
    args = args or {}
    local color = args.color
    local cairo_fonts = args.cairo_fonts
    local path = args.path
    local icon = args.icon

    desktop.color = {
        main = color.main,
        gray = color.desktop_gray,
        icon = color.desktop_icon,
        urgent = color.urgent,
        wibox = color.bg .. "00"
    }

    return {
        common = {
            bar = {
                -- Dashed progressbar
                plain = {

                    width = nil, -- widget width
                    height = nil, -- widget height
                    autoscale = false, -- normalize progressbar value
                    maxm = 1, -- the maximum allowed value

                    -- color (desktop used)
                    color = desktop.color,

                    -- progressbar settings
                    chunk = {
                        width = 6, -- bar width
                        gap = 6 -- space between bars
                    }
                },
                -- Custom shaped vertical progressbar
                shaped = {
                    width = nil, -- widget width
                    height = nil, -- widget height
                    autoscale = true, -- normalize chart values
                    maxm = 1, -- the maximum allowed value
                    shape = "corner", -- progressbar chunk shape
                    show = {tooltip = false}, -- show tooltip
                    color = desktop.color, -- color (desktop used)

                    -- element style
                    chunk = {
                        num = 10, -- number of elements
                        line = 5, -- element line width
                        height = 10 -- element height
                    },

                    -- tooltip style
                    tooltip = {}
                }
            },
            pack = {
                -- Lines (group of progressbars with label in front and text value after it)
                lines = {
                    label = {width = 80, draw = "by_width"}, -- label style (see theme.desktop.common.textbox)
                    text = {width = 92, draw = "by_edges"}, -- value style (see theme.desktop.common.textbox)
                    progressbar = {}, -- progressbar style (see theme.desktop.common.bar.plain)
                    line = {height = desktop.line_height}, -- text/progressbar height
                    tooltip = {}, -- redflat tooltip style (see theme.float.tooltip)
                    color = desktop.color, -- color (desktop used)

                    -- show/hide line elements
                    show = {text = true, label = true, tooltip = false},

                    -- space between label/text and progressbar
                    gap = {text = 22, label = 16}
                }
            },

            -- Common (various elem, 0.20, 0.25ents that used as component for desktop widgets)
            textbox = {
                width = nil, -- widget width
                height = nil, -- widget height
                draw = "by_left", -- align method ("by_left", "by_right", "by_edges", "by_width")
                color = desktop.color.gray, -- text color

                -- font style
                font = cairo_fonts.desktop.textbox
            },

            -- Time chart
            ------------------------------------------------------------
            chart = {
                width = nil, -- widget width
                height = nil, -- widget height
                autoscale = true, -- normalize chart values
                maxm = 1, -- the maximum allowed value
                zero_height = 4, -- height for zero value point in chart
                color = desktop.color.gray, -- chart bars color

                -- chart bars settings
                bar = {
                    width = 5, -- bar width
                    gap = 5 -- space between bars
                }
            }
        },

        speedmeter = {
            -- Speed widget (double progressbar with time chart for each of it)
            normal = {
                barvalue_height = 32, -- height of the area with progressbar and text
                digits = 2, -- minimal number of digits for progressbar value
                fullchart_height = 80, -- height of the each area with progressbar, text and chart
                image_gap = 16, -- space between direction icon and progressbar/chart
                color = desktop.color, -- color (desktop used)

                -- direction icons
                images = {
                    path .. "/desktop/up.svg", -- up
                    path .. "/desktop/down.svg" -- down
                },

                -- !!! WARNING some missed style settings for elemets below will be overwritten by widget
                -- do not try to use full style settings from 'theme.desktop.commom' here

                -- time chart style (see theme.desktop.common.chart)
                chart = {
                    bar = {width = 6, gap = 3},
                    height = 40,
                    zero_height = 4
                },

                -- progressbar label and value (see theme.desktop.common.textbox)
                label = {height = desktop.line_height},

                -- progressbar style (see theme.desktop.common.bar.plain)
                progressbar = {chunk = {width = 16, gap = 6}, height = 6}
            },
            compact = {
                margins = {label = {}, chart = {}}, -- extra margins for some elements
                height = {chart = 50}, -- height of the each area with progressbar, text and chart
                digits = 2, -- minimal number of digits for progressbar value
                color = desktop.color, -- color (desktop used)

                -- direction icons
                icon = {
                    up = icon.system, -- up
                    down = icon.system, -- down
                    margin = {4, 4, 2, 2} -- margins around icon
                },

                -- !!! WARNING some style settings for elemets below will be overwritten by widget
                chart = {zero_height = 0}, -- time chart style (see theme.desktop.common.chart)
                label = {}, -- progressbar value (see theme.desktop.common.textbox)
                progressbar = {} -- double progressbar style (see theme.desktop.common.bar.plain)
            }
        },
        line_height = 18, -- text and progressbar height for desktop wodgets

        grid = {
            width = {420, 1000, 420},
            height = {210, 210, 210},
            edge = {width = {40, 40}, height = {40, 40}}
        },

        places = {clock = {3, 1}, netspeed = {1, 3}},

        -- Custom aligned text block
        textset = {
            font = "Sans 12", -- font
            spacing = 1.15, -- space between lines
            color = desktop.color -- color (desktop used)
        },

        -- Widget with multiple horizontal and vertical progress bars
        ------------------------------------------------------------
        multimeter = {
            digits = 3, -- minimal number of digits for horizontal progressbar values
            color = desktop.color, -- color (desktop used)
            labels = {}, -- list of optional labels for horizontal bars

            -- area height
            height = {
                upright = 80, -- vertical progressbars height
                lines = 58 -- horizontal progressbar area height
            },

            -- widget icon
            icon = {
                image = icon.system, -- widget icon
                margin = {0, 16, 0, 0}, -- margins around icon
                full = false -- draw icon in full height of widget
            },
            -- !!! WARNING some missed style settings for elemets below will be overwritten by widget

            --  vertical progressbars style (see theme.desktop.common.bar.shaped)
            upbar = {width = 34, chunk = {height = 17, num = 10, line = 4}},

            -- horizontal progressbars style (see theme.desktop.common.pack.lines)
            lines = {}
        },

        -- Widget with multiple progress bars
        ------------------------------------------------------------
        multiline = {
            digits = 3, -- minimal number of digits for progressbar value
            margin = {0, 0, 0, 0}, -- margin around progressbar list
            color = desktop.color, -- color (desktop used)

            -- widget icon settings
            icon = {image = nil, margin = {0, 0, 0, 0}},

            -- !!! WARNING some missed style settings for elemets below will be overwritten by widget

            -- progressbars style (see theme.desktop.common.pack.lines)
            lines = {progressbar = {}, tooltip = {}}
        },

        -- Widget with several text groups in single line
        -- every group has label and value and icon in the middle
        ------------------------------------------------------------
        singleline = {
            lbox = {draw = "by_width", width = 50}, -- label style (see theme.desktop.common.textbox)
            rbox = {draw = "by_edges", width = 60}, -- value style (see theme.desktop.common.textbox)
            digits = 2, -- minimal number of digits for value
            icon = icon.system, -- group icon
            iwidth = 142, -- width for every text group
            color = desktop.color -- color (desktop used)
        },

        -- Calendar widget with lined up marks
        ------------------------------------------------------------
        calendar = {
            show_pointer = true, -- show date under mouse
            color = desktop.color, -- color (desktop used)
            -- TODO: check for better font
            -- today label style
            label = {
                gap = 8, -- space between label and pointer
                sep = "-", -- day/month separator
                font = {font = "Play", size = 16, face = 1, slant = 0} -- font
            },

            -- days marks style
            mark = {
                height = 12, -- mark height
                width = 25, -- mark width
                dx = 6, -- pointer arrow width
                line = 2 -- stroke line width for next month marks
            }
        },

        -- Clock widget, self written
        clock = {
            hands = {color = {fg = desktop.color.main}},
            color = {main = desktop.color.main, gray = desktop.color.gray}
        }
    }
end

function desktop.mt:__call(...) return desktop.new(...) end

return setmetatable(desktop, desktop.mt)
