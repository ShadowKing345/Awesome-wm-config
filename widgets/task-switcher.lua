local awful = require( "awful" )
local wibox = require( "wibox" )
local gears = require( "gears" )
local gtable = require( "gears.table" )
local beautiful = require( "beautiful" )
local object = require( "gears.object" )
local keygrabber = require( "awful.keygrabber" )

local ts = { ts = {} }

-- Temp value to store what the default mouse actions for task list did.
local hold = {
    awful.button( {}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal( "request::activate", "tasklist", { raise = true } )
        end
    end ), awful.button( {}, 4, function() awful.client.focus.byidx( 1 ) end ),
    awful.button( {}, 5, function() awful.client.focus.byidx( -1 ) end )
}

-- Keyboard hotkeys assignment.
-- While not the best way to do it such that users can setup their own, it's good for prototypeing.
ts.keyboard = {
    Up = { "Up", "k" },
    Down = { "Down", "j" },
    Left = { "Left", "h" },
    Right = { "Right", "l" },
    Exec = { "Return" },
    Close = { "Escape" }
}

-- Odd method used to set a OOP methods so that the intelesese does not complain. And possible to be able to do task-switcher:show()
local table_update = function(t, set)
    for k, v in pairs( set ) do t[k] = v end
    return t
end

function ts:show(_)
    keygrabber.run( self._keygrabber )
    self.wibox.visible = true
end

function ts:hide()
    keygrabber.stop( self._keygrabber )
    self.wibox.visible = false
end

function ts:toggle(args)
    if self.wibox.visible then
        self:hide()
    else
        self:show( args )
    end
end

-- todo: mouse contorls
ts.buttons = {}

-- todo: Finish keyboard controls
local function keyboardGrabber(_ts, _, key, event)
    if event ~= "press" then return end
    if gtable.hasitem( ts.keyboard.Close, key ) then _ts:hide() end
end

function ts.new(args)
    args = args or {}
    args.layout = args.layout or wibox.layout.flex.vertical

    local _ts = table_update( object(), {
        show = ts.show,
        hide = ts.hide,
        toggle = ts.toggle,
        add = ts.add,
        layout = args.layout(),
        theme = beautiful.get()
    } )

    _ts._keygrabber = function(...) keyboardGrabber( _ts, ... ) end

    _ts.wibox = awful.popup {
        ontop = true,
        visible = false,
        placement = awful.placement.centered,
        border_color = beautiful.border_color,
        border_width = 1,

        widget = awful.widget.tasklist {
            screen = screen[1],
            filter = awful.widget.tasklist.filter.allscreen,
            buttons = ts.buttons,
            layout = { spacing = 5, forced_num_cols = 5, layout = wibox.layout.grid.vertical },
            widget_template = {
                {
                    id = "application_role",
                    {
                        {
                            { id = "icon_role", widget = wibox.widget.imagebox },
                            margins = 2,
                            widget = wibox.container.margin
                        },
                        { id = "text_role", widget = wibox.widget.textbox },
                        layout = wibox.layout.fixed.vertical
                    },
                    left = 10,
                    right = 10,
                    widget = wibox.container.margin
                },
                id = "background_role",
                forced_height = 48,
                forced_width = 48,
                widget = wibox.container.background,
                create_callback = function(self, c, _, _)
                    self:get_children_by_id( "application_role" )[1].client = c
                end
            }
        }

    }

    _ts.x = _ts.wibox.x
    _ts.y = _ts.wibox.y

    return _ts
end

function ts.ts:__call(...) return ts.new( ... ) end

return setmetatable( ts, ts.ts )
