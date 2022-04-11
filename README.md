# Awesome Window Manager Config
The awesome window manager config I created for myself.
Using Catppucin color scheme with rough understanding of how the colors are meant to be applied.

# Note about instalation.
I use the overflow layout created in this fork of AwesomeWM `https://github.com/sclu1034/awesome/tree/feature/overflow_container`.
In order to actually use it I needed to modify the /usr/share/awesome/lib/wibox/hiearchy.lua file to get the clipping to function correctly.

If you wish to do the same you will need to add the following.

```lua
if not widgget.clip_child_extends then
--[[Content of like 146 to 151]]
end
```

See: `https://github.com/sclu1034/awesome/blob/feature/overflow_container/lib/wibox/hierarchy.lua` for an example of what I mean.
