# Awesome Window Manager Config
The awesome window manager config I created for myself.
Using Catppucin color scheme with rough understanding of how the colors are meant to be applied.

The configuration uses many personalised widgets that either recreate the function of existing widgets or just add a wrapper button.
Some widgets will automatically hide and disable themselves when they fail in order to not lag out the computer. 

The theme directory is more of a complex script that runs when the called. Attempting to use the standard beautiful init function will not work. 

To help with separation of functions scripts are used for things such as Web api calls and system information processing.
Python 3.10 is needed to run some of the scripts.

# Note about instalation.
I use the overflow layout created in this fork of AwesomeWM `https://github.com/sclu1034/awesome/tree/feature/overflow_container`.
In order to actually use it I needed to modify the /usr/share/awesome/lib/wibox/hiearchy.lua file to get the clipping to function correctly.

If you wish to do the same you will need to add the following.

```lua
if not widgget.clip_child_extends then
--[[Content of line 146 to 151]]
end
```

See: `https://github.com/sclu1034/awesome/blob/feature/overflow_container/lib/wibox/hierarchy.lua` for an example of what I mean.

# Note about naming conventions.
The main naming convention is camelCase. While the common accepted naming convention for lua is snake_case. I have not done so for personal reasons that were there early on. 
If a function or variable uses snake case instead camel case then its probably an awesomewm function or I forgot to change it.
