# swampservers/contrib

Please read the **COPYRIGHT** notice of the bottom of this page. If you contribute to this repository, then you agree to the **CONTRIBUTOR LICENSE AGREEMENT** also at the bottom of this page.

# Overview

Contribute to Swamp Cinema here! How to:

- 'Fork' this repo. This creates a copy of it you have edit permissions of.
- Clone your forked repo into garrysmod/addons (so it creates garrysmod/addons/contrib), edit it, and push it back. You'll need the GitHub desktop or commandline client. Look up GitHub tutorials for that.
- For clientside work, check out the [devtools](https://github.com/swampservers/contrib/blob/master/lua/swamp/dev/cl_devtools.lua) which allow you to work on the actual server environment.
- Make a pull request on this repo. Use the 'compare across forks' link to request to merge your changes on your forked repo to this repo. Accepted changes are installed automatically, although new files won't run until after a server reset.
- Minor, single-file changes can just be done in the web browser by clicking the pencil icon.

All models/materials/sounds in this repository will be automatically uploaded to our workshop addons, so don't worry about that.

# Code

- Please submit code that is **clean and concise**. You may want to run it through [glualint](https://fptje.github.io/glualint-web/). Do a good job! 
- Make your code compatible with our [loading system](https://github.com/swampservers/contrib/blob/master/lua/autorun/swamp.lua).
- Try to put cinema-specific code in gamemodes/cinema/ and generic (cross-server) code in lua/. Both folders are loaded using our loading system.

# API


### gm = engine.ActiveGamemode()
Shorthand for gamemode name
\
*file: [lua/autorun/swamp.lua](https://github.com/swampservers/contrib/blob/master/lua/autorun/swamp.lua)*

### function Entity:GetLocation()
Int location ID
\
*file: [lua/cinema/location/sh_location.lua](https://github.com/swampservers/contrib/blob/master/lua/cinema/location/sh_location.lua)*

### function Entity:GetLocationName()
String
\
*file: [lua/cinema/location/sh_location.lua](https://github.com/swampservers/contrib/blob/master/lua/cinema/location/sh_location.lua)*

### function Entity:GetLocationTable()
Location table
\
*file: [lua/cinema/location/sh_location.lua](https://github.com/swampservers/contrib/blob/master/lua/cinema/location/sh_location.lua)*

### function Entity:GetTheater()
Theater table
\
*file: [lua/cinema/location/sh_location.lua](https://github.com/swampservers/contrib/blob/master/lua/cinema/location/sh_location.lua)*

### function Entity:InTheater()
Bool
\
*file: [lua/cinema/location/sh_location.lua](https://github.com/swampservers/contrib/blob/master/lua/cinema/location/sh_location.lua)*

### function FindLocation(ent_or_pos)
Global function to compute a location ID (avoid this, it doesn't cache)
\
*file: [lua/cinema/location/sh_location.lua](https://github.com/swampservers/contrib/blob/master/lua/cinema/location/sh_location.lua)*

### function Player:ExtEmitSound(sound, options)
Will probably be deprecated\
 possible options:\
 pitch\
 crouchpitch\
 level\
 volume\
 channel\
 ent: emit from this ent instead of player\
 shared: emit on client without networking, assuming called in shared function\
 speech: move player lips (time to move lips, or auto if < 0)
\
*file: [lua/cinema/sound/sh_extsound.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/cinema/sound/sh_extsound.lua)*

### function Entity:IsProtected(att)
If we are "protected" from this attacker by theater protection. `att` doesn't need to be passed, it's only used to let theater owners override protection and prevent killing out of a protected area.
\
*file: [lua/cinema/theater/sh_protection.lua](https://github.com/swampservers/contrib/blob/master/lua/cinema/theater/sh_protection.lua)*

### function Player:IsTyping()
Bool (typing a chat message)
\
*file: [lua/swamp/chat/sh_swampchat.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/chat/sh_swampchat.lua)*

### function Player:IsAFK()
Boolean
\
*file: [lua/swamp/clientcheck/sh_afk_detect.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/clientcheck/sh_afk_detect.lua)*

### function Player:IsActive()
Boolean, NOT AFK and NOT BOT
\
*file: [lua/swamp/clientcheck/sh_afk_detect.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/clientcheck/sh_afk_detect.lua)*

### function bench(func)
Prints how long it takes to run a function, averaging over a large number of samples with minimal overhead
\
*file: [lua/swamp/dev/sh_bench.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/dev/sh_bench.lua)*

### Me  (global variable)
Use this global instead of LocalPlayer()\
 It will be either nil or a valid entity. Don't write `if IsValid(Me)`... , just write `if Me`...
\
*file: [lua/swamp/extensions/cl_me.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/cl_me.lua)*

### function MeOnValid(func)
Call the function when Me becomes valid
\
*file: [lua/swamp/extensions/cl_me.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/cl_me.lua)*

### function cam.Culled3D2D(pos, ang, scale, callback)
Runs `cam.Start3D2D(pos, ang, scale) callback() cam.End3D2D()` but only if the user is in front of the "screen" so they can see it.
\
*file: [lua/swamp/extensions/cl_render_extension.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/cl_render_extension.lua)*

### function render.DrawingScreen()
Bool if we are currently drawing to the screen.
\
*file: [lua/swamp/extensions/cl_render_extension.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/cl_render_extension.lua)*

### function render.WithColorModulation(r, g, b, callback)
Sets the color modulation, calls your callback, then sets it back to what it was before.
\
*file: [lua/swamp/extensions/cl_render_extension.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/cl_render_extension.lua)*

### function DFrame:CloseOnEscape()
Makes the DFrame :Close() if escape is pressed
\
*file: [lua/swamp/extensions/cl_vgui_function.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/cl_vgui_function.lua)*

### function vgui(classname, parent (optional), constructor)
This defines the function vgui(classname, parent (optional), constructor) which creates and returns a panel.\
\
 The parent should only be passed when creating a root element (eg. a DFrame) which need a parent.\
 Child elements should be constructed using vgui() from within the parent's constructor, and their parent will be set automatically.\
\
 This is helpful for creating complex guis as the hierarchy of the layout is clearly reflected in the code structure.\
\
 Example: (a better example is in the file)\
 ```\
 vgui("Panel", function(p)\
    -- p is the panel, set it up here\
    vgui("DLabel", function(p)\
        -- p is the label here\
    end)\
 end)\
 ```
\
*file: [lua/swamp/extensions/cl_vgui_function.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/cl_vgui_function.lua)*

### function Entity:TimerCreate(identifier, delay, repetitions, callback)
A timer which will only call the callback (with the entity passed as the argument) if the ent is still valid
\
*file: [lua/swamp/extensions/sh_ent_timer.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/sh_ent_timer.lua)*

### function Entity:TimerSimple(delay, callback)
A timer which will only call the callback (with the entity passed as the argument) if the ent is still valid
\
*file: [lua/swamp/extensions/sh_ent_timer.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/sh_ent_timer.lua)*

### Ents  (global variable)
A global cache of all entities, in subtables divided by classname.\
 Works on client and server. Much, much faster than `ents.FindByClass` or even `player.GetAll`\
 Each subtable is ordered and will never be nil even if no entities were created.\
 To use it try something like this: `for i,v in ipairs(Ents.prop_physics) do` ...
\
*file: [lua/swamp/extensions/sh_ents_cache.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/sh_ents_cache.lua)*

### ply.NWP = {}
NWP="Networked Private"\
 A table on each player. Values written on server will automatically be replicated to that client. Won't be sent to other players. Read-only on client, read-write on server.
\
*file: [lua/swamp/extensions/sh_nwprivate.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/sh_nwprivate.lua)*

### function Entity:IsHuman()
IsPlayer and not IsBot
\
*file: [lua/swamp/extensions/sh_player_extension.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/sh_player_extension.lua)*

### function Player:UsingWeapon(class)
Faster than writing `IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass()==class`
\
*file: [lua/swamp/extensions/sh_player_extension.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/sh_player_extension.lua)*

### function PlyCount(name)
Find a player whose name contains some text. Returns any found player as well as the count of found players.
\
*file: [lua/swamp/extensions/sh_playerbyname.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/sh_playerbyname.lua)*

### function string.FormatSeconds(sec)
Turns a number of seconds into a string like hh:mm:ss or mm:ss
\
*file: [lua/swamp/extensions/sh_string.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/extensions/sh_string.lua)*

### function ShowMotd(url)
Pop up the MOTD browser thing with this URL
\
*file: [lua/swamp/misc/cl_motd.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/misc/cl_motd.lua)*

### function Player:Notify(...)
Show a notification (bottow center screen popup)
\
*file: [lua/swamp/misc/sh_notify.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/misc/sh_notify.lua)*

### function Player:TrueName()
Return player's actual Steam name without any filters (eg removing swamp.sv). All default name functions have filters.
\
*file: [lua/swamp/misc/sh_player_name_filter.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/misc/sh_player_name_filter.lua)*

### function player.GetBySteamID(id)
Unlike the built-in function, this (along with player.GetBySteamID64 and player.GetByAccountID) is fast.
\
*file: [lua/swamp/misc/sh_playerbysteamid.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/misc/sh_playerbysteamid.lua)*

### function Player:GetTitle()
Get current title string or ""
\
*file: [lua/swamp/misc/sh_titles.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/misc/sh_titles.lua)*

### function Entity:IsPony()
Boolean, mostly for players
\
*file: [lua/swamp/pony/sh_init.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/pony/sh_init.lua)*

### function API_Struct(value_type)
A struct is a table with only string keys, and all string keys are kept on the NetworkString table. It's not as static as a C struct.
\
*file: [lua/swamp/sh_api.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_api.lua)*

### if CLIENT then
Register a function which is called on the server and executed on the client. See this file for details.
\
*file: [lua/swamp/sh_api.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_api.lua)*

### function call(func, ...)
Just calls the function with the args
\
*file: [lua/swamp/sh_core.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_core.lua)*

### function call_async(callback, ...)
Shorthand timer.Simple(0, callback) and also passes args
\
*file: [lua/swamp/sh_core.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_core.lua)*

### function defaultdict(constructor, init)
Returns a table such that when indexing the table, if the value doesn't exist, the constructor will be called with the key to initialize it.
\
*file: [lua/swamp/sh_core.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_core.lua)*

### function math.nextpow2(n)
Returns next power of 2 >= n
\
*file: [lua/swamp/sh_core.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_core.lua)*

### function noop()
Shorthand for empty function
\
*file: [lua/swamp/sh_core.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_core.lua)*

### function table.Inverse(tab)
Convert a table of {k=v} to {v=k}
\
*file: [lua/swamp/sh_core.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_core.lua)*

### function table.Set(tab)
Convert an ordered table {a,b,c} into a set {[a]=true,[b]=true,[c]=true}
\
*file: [lua/swamp/sh_core.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_core.lua)*

### function table.ShallowCopy(tab)
Copy table at the first layer only
\
*file: [lua/swamp/sh_core.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_core.lua)*

### function table.SortedInsertIndex(tab, val)
Returns the largest index such that tab[index] > val (or is the end)
\
*file: [lua/swamp/sh_core.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_core.lua)*

### function table.imax(tab)
Selects the maximum value of an ordered table. See also: table.imin
\
*file: [lua/swamp/sh_core.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_core.lua)*

### function table.isum(tab)
Sums an ordered table.
\
*file: [lua/swamp/sh_core.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_core.lua)*

### function table.sub(tab, startpos, endpos)
Selects a range of an ordered table similar to string.sub
\
*file: [lua/swamp/sh_core.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_core.lua)*

### function try(func, catch)
Calls the function and if it fails, calls catch (default: ErrorNoHaltWithStack) with the error. Doesn't return anything
\
*file: [lua/swamp/sh_core.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_core.lua)*

### Player, Entity, Weapon  (global variables)
Omit FindMetaTable from your code because these globals always refer to their respective metatables.\
 Player/Entity are still callable and function the same as the default global functions.
\
*file: [lua/swamp/sh_meta.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sh_meta.lua)*

### function Player:GetStat(name, default)
Get the value of the stat with the given name. If default isn't given it is 0
\
*file: [lua/swamp/sql/sh_stats.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/sql/sh_stats.lua)*

### function Player:AddStat(name, increment)
Adds increment (or 1) to a stat with the given name
\
*file: [lua/swamp/sql/sv_stats.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/sql/sv_stats.lua)*

### function Player:FlagStat(name)
Sets the stat to 1 (cheaper storage than integer stats)
\
*file: [lua/swamp/sql/sv_stats.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/sql/sv_stats.lua)*

### function Player:GroupStat(name, other)
Adds the other player to the "partner set" by the given name. This way you can make stats that require interaction with many players.
\
*file: [lua/swamp/sql/sv_stats.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/sql/sv_stats.lua)*

### function Player:MaxStat(name, record)
Sets the stat with the given name to the max of its previous value and the record
\
*file: [lua/swamp/sql/sv_stats.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/sql/sv_stats.lua)*

### function Player:GetRank()
Numeric player ranking (all players are zero, staff are 1+)
\
*file: [lua/swamp/swampcop/sh_init.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/swampcop/sh_init.lua)*

### function Player:IsStaff()
Boolean
\
*file: [lua/swamp/swampcop/sh_init.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/swampcop/sh_init.lua)*

### function Player:SS_GetPoints()
Number of points
\
*file: [lua/swamp/swampshop/sh_init.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/swampshop/sh_init.lua)*

### function Player:SS_HasPoints(points)
If the player has at least this many points. Don't use it on the server if you are about to buy something; just do SS_TryTakePoints
\
*file: [lua/swamp/swampshop/sh_init.lua](https://github.com/swampservers/contrib/blob/master/lua/swamp/swampshop/sh_init.lua)*

### function Player:SS_GivePoints(points, callback, fcallback)
Give points. `callback` happens once the points are written. `fcallback` = failed to write
\
*file: [lua/swamp/swampshop/sv_init.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/swampshop/sv_init.lua)*

### function Player:SS_TryTakePoints(points, callback, fcallback)
Take points, but only if they have enough.\
 `callback` runs once the points have been taken.\
 `fcallback` runs if they don't have enough points or it otherwise fails to take them
\
*file: [lua/swamp/swampshop/sv_init.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/swampshop/sv_init.lua)*

### function Entity:SetWebMaterial(args)
Like `WebMaterial` but sets it to an entity (only needs to be called once)\
 The material will load when the entity is close unless `args.forceload=true` is passed.
\
*file: [lua/swamp/webmaterials/cl_webmaterials.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/webmaterials/cl_webmaterials.lua)*

### function Entity:SetWebSubMaterial(idx, args)
Like `Entity:SetWebMaterial`
\
*file: [lua/swamp/webmaterials/cl_webmaterials.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/webmaterials/cl_webmaterials.lua)*

### function ITexture:Paint(callback)
Assign a function to this ITexture which will be called(width,height) on the next PreDrawHUD and with the rendertarget/viewport stuff setup.\
 Finishes all painting in order on one frame and can be called recursively.
\
*file: [lua/swamp/webmaterials/cl_webmaterials.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/webmaterials/cl_webmaterials.lua)*

### function RenderTarget(args)
Like CreateRenderTargetEx, but the args are a table with good defaults, you don't need a name, and if the ITexture gets garbage collected it can reuse the rendertarget for another call (since you can't delete RTs)
\
*file: [lua/swamp/webmaterials/cl_webmaterials.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/webmaterials/cl_webmaterials.lua)*

### function WebMaterial(args)
To use web materials, just call in your draw hook:\
\
 `mat = WebMaterial(args)`\
\
 Then set/override material to mat\
\
 args is a table with the following potential keys:\
 - id: string, from `SanitizeImgurId`\
 - owner: player/steamid or nil\
 - pos: vector or nil - rendering position, used for delayed distance loading\
 - stretch: bool = false (stretch to fill frame, or contain to maintain aspect)\
 - shader: str = "VertexLitGeneric"\
 - params: str = "{}" - A "table" of material parameters for CreateMaterial (NOT A TABLE, A STRING THAT CAN BE PARSED AS A TABLE)\
 - pointsample: bool = false\
 - nsfw: bool = false - (can be false, true, or "?")
\
*file: [lua/swamp/webmaterials/cl_webmaterials.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/webmaterials/cl_webmaterials.lua)*

### function AsyncSanitizeImgurId(id, callback)
Like SanitizeImgurId, but more powerful (if a url to an gallery is passed we'll try to look it up)
\
*file: [lua/swamp/webmaterials/sh_webmaterials.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/webmaterials/sh_webmaterials.lua)*

### function SanitizeImgurId(id)
Converts an imgur id or url to an imgur id (nil if it doesn't work)
\
*file: [lua/swamp/webmaterials/sh_webmaterials.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/webmaterials/sh_webmaterials.lua)*

### function SingleAsyncSanitizeImgurId(url, callback)
Like AsyncSanitizeImgurId but won't spam requests (waits until the previous request finished, and only the latest request can stay in the queue)
\
*file: [lua/swamp/webmaterials/sh_webmaterials.lua (hidden)](https://github.com/swampservers/contrib/blob/master/lua/swamp/webmaterials/sh_webmaterials.lua)*


*Note: docs above are generated from luadoc-style code comments. README.md is autogenerated from readme_format.md*

**COPYRIGHT: This repository and most of its content is copyrighted and owned by Swamp Servers. All other content is, to the best of our knowledge, used under license. If your copyrighted work is here without permission, please contact the email shown [here](https://swampservers.net/contact). This repository DOES NOT license its contents to be used for other purposes, nor does its existence on GitHub imply such a license.**

**CONTRIBUTOR LICENSE AGREEMENT: This repository is solely for game assets/code used by [Swamp Servers](https://swampservers.net/) to operate our online games. By submitting your work to this repository (via commits/pull requests), you agree that we have a PERMANENT, IRREVOCABLE, WORLDWIDE, TRANSFERABLE LICENSE to use, modify, and distribute all of your submitted work as we see fit. By submitting work created by a third party, you attest that the creator of that work also agrees that we have a permanent, irrevocable, worldwide, transferable license to use, modify, and distribute their submitted work as we see fit. Do not submit work from a third party without their agreement to these terms. Note that work publicly available on sites like "Steam Workshop" may already be distributed under agreements conducive to this.**

