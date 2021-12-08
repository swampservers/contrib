# swampservers/contrib

Please read the **COPYRIGHT** notice of the bottom of this page. If you contribute to this repository, then you agree to the **CONTRIBUTOR LICENSE AGREEMENT** also at the bottom of this page.

# Overview

Contribute to Swamp Cinema here! How to:

- 'Fork' this repo. This creates a copy of it you have edit permissions of.
- Clone your forked repo into garrysmod/addons (so it creates garrysmod/addons/contrib), edit it, and push it back. You'll need the GitHub desktop or commandline client. Look up GitHub tutorials for that.
- For clientside work, check out the [devtools](https://github.com/swampservers/contrib/blob/master/lua/autorun/client/cl_devtools.lua) which allow you to work on the actual server environment.
- Make a pull request on this repo. Use the 'compare across forks' link to request to merge your changes on your forked repo to this repo. We'll review the changes and, if accepted, will be live the next day.
- Minor, single-file changes can just be done in the web browser by clicking the pencil icon.

All models/materials/sounds in this repository will be automatically uploaded to our workshop addons, so don't worry about that.

# Paid contributions

Please see our [task list](https://github.com/swampservers/contrib/issues/231) for more information.

# Code guidelines

 - Please submit code that is readable; you can use https://fptje.github.io/glualint-web/ to do this.
 - Please write *as few lines of code as possible* to acheive the desired result. More code is not better!!!!

# Files

IMPORTANT: Make all your code compatible with our loading system. Refer to lua/autorun/swamp.lua

Try to put cinema-specific weapons/entities in gamemodes/cinema/ and generic code in lua/. Both folders are loaded the same way.

# API


### function Player:IsAFK()
Boolean\
*lua/swamp/clientcheck/sh_afk_detect.lua (hidden file)*

### Me (global)
Use this global instead of LocalPlayer()\
It will be either nil or a valid entity. Don't write `if IsValid(Me)`... , just write `if Me`...\
*lua/swamp/extensions/cl_me.lua*

### ply.NWPrivate = {}
A table on each player. Values written on server will automatically be replicated to that client. Won't be sent to other players. Read-only on client, read-write on server.\
*lua/swamp/extensions/cl_nwprivate.lua*

### function cam.Culled3D2D(pos, ang, scale, callback)
Runs `cam.Start3D2D(pos, ang, scale) callback() cam.End3D2D()` but only if the user is in front of the "screen" so they can see it.\
*lua/swamp/extensions/cl_render_extension.lua*

### function render.DrawingScreen()
Bool if we are currently drawing to the screen.\
*lua/swamp/extensions/cl_render_extension.lua*

### function render.WithColorModulation(r, g, b, callback)
Sets the color modulation, calls your callback, then sets it back to what it was before.\
*lua/swamp/extensions/cl_render_extension.lua*

### --
This defines the function vgui(classname, parent (optional), constructor) which creates and returns a panel.\
*lua/swamp/extensions/cl_vgui_function.lua*

### function DFrame:CloseOnEscape()
Makes the DFrame :Close() if escape is pressed\
*lua/swamp/extensions/cl_vgui_function.lua*

### function Entity:TimerCreate(identifier, delay, repetitions, callback)
A timer which will only call the callback (with the entity passed as the argument) if the ent is still valid\
*lua/swamp/extensions/sh_ent_timer.lua*

### function Entity:TimerSimple(delay, callback)
A timer which will only call the callback (with the entity passed as the argument) if the ent is still valid\
*lua/swamp/extensions/sh_ent_timer.lua*

### Ents (global)
A global cache of all entities, in subtables divided by classname.\
Works on client and server. Much, much faster than `ents.FindByClass` or even `player.GetAll`\
Each subtable is ordered and will never be nil even if no entities were created.\
To use it try something like this: `for i,v in ipairs(Ents.prop_physics) do` ...\
*lua/swamp/extensions/sh_ents_cache.lua*

### function GetG(k)
Get a globally shared value (similar to GetGlobal* but actually works)\
*lua/swamp/extensions/sh_getg_setg.lua*

### function SetG(k, v)
Set a globally shared value (server)\
*lua/swamp/extensions/sh_getg_setg.lua*

### function Player:UsingWeapon(class)
Faster than writing `IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass()==class`\
*lua/swamp/extensions/sh_player_extension.lua*

### function PlyCount(name)
Find a player whose name contains some text. Returns any found player as well as the count of found players.\
*lua/swamp/extensions/sh_playerbyname.lua*

### function string.FormatSeconds(sec)
Turns a number of seconds into a string like hh:mm:ss or mm:ss\
*lua/swamp/extensions/sh_string.lua*

### function player.GetBySteamID(id)
Unlike the built-in function, this (along with player.GetBySteamID64 and player.GetByAccountID) is fast.\
*lua/swamp/extensions/sv_playerbysteamid.lua (hidden file)*

### function Entity:IsPony()
Boolean, mostly for players\
*lua/swamp/pony/sh_init.lua*

### function apcall(func, ...)
Calls the function and does ErrorNoHalt if it fails. Returns nothing\
*lua/swamp/sh_core.lua*

### function call(func, ...)
Just calls the function with the args\
*lua/swamp/sh_core.lua*

### function call_async(callback, ...)
Shorthand timer.Simple(0, callback) and also passes args\
*lua/swamp/sh_core.lua*

### function defaultdict(constructor)
Returns a table such that when indexing the table, if the value doesn't exist, the constructor will be called with the key to initialize it.\
*lua/swamp/sh_core.lua*

### function math.nextpow2(n)
Returns next power of 2 >= n\
*lua/swamp/sh_core.lua*

### function noop()
Shorthand for empty function\
*lua/swamp/sh_core.lua*

### function table.Set(tab)
Convert an ordered table {a,b,c} into a set {[a]=true,[b]=true,[c]=true}\
*lua/swamp/sh_core.lua*

### function table.imax(tab)
Selects the maximum value of an ordered table. See also: table.imin\
*lua/swamp/sh_core.lua*

### function table.isum(tab)
Sums an ordered table.\
*lua/swamp/sh_core.lua*

### function table.sub(tab, startpos, endpos)
Selects a range of an ordered table similar to string.sub\
*lua/swamp/sh_core.lua*

### Player, Entity, Weapon
Omit FindMetaTable from your code because these globals always refer to their respective metatables.\
Player/Entity are still callable and function the same as the default global functions.\
*lua/swamp/sh_meta.lua*

### function Player:GetRank()
Numeric player ranking (all players are zero, staff are 1+)\
*lua/swamp/swampcop/sh_init.lua (hidden file)*

### function Player:IsStaff()
Boolean\
*lua/swamp/swampcop/sh_init.lua (hidden file)*

### function Player:SS_GetPoints()
Number of points\
*lua/swamp/swampshop/sh_init.lua*

### function Player:SS_HasPoints(points)
If the player has at least this many points. Don't use it on the server if you are about to buy something; just do SS_TryTakePoints\
*lua/swamp/swampshop/sh_init.lua*

### function Player:SS_GivePoints(points, callback, fcallback)
Give points. `callback` happens once the points are written. `fcallback` = failed to write\
*lua/swamp/swampshop/sv_init.lua (hidden file)*

### function Player:SS_TryTakePoints(points, callback, fcallback)
Take points, but only if they have enough.\
`callback` runs once the points have been taken.\
`fcallback` runs if they don't have enough points or it otherwise fails to take them\
*lua/swamp/swampshop/sv_init.lua (hidden file)*


**COPYRIGHT: This repository and most of its content is copyrighted and owned by Swamp Servers. All other content is, to the best of our knowledge, used under license. If your copyrighted work is here without permission, please contact the email shown [here](https://swampservers.net/contact). This repository DOES NOT license its contents to be used for other purposes, nor does its existence on GitHub imply such a license.**

**CONTRIBUTOR LICENSE AGREEMENT: This repository is solely for game assets/code used by [Swamp Servers](https://swampservers.net/) to operate our online games. By submitting your work to this repository (via commits/pull requests), you agree that we have a PERMANENT, IRREVOCABLE, WORLDWIDE, TRANSFERABLE LICENSE to use, modify, and distribute all of your submitted work as we see fit. By submitting work created by a third party, you attest that the creator of that work also agrees that we have a permanent, irrevocable, worldwide, transferable license to use, modify, and distribute their submitted work as we see fit. Do not submit work from a third party without their agreement to these terms. Note that work publicly available on sites like "Steam Workshop" may already be distributed under agreements conducive to this.**
