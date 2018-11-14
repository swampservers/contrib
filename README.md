# swampservers/contrib

Contribute to swamp servers here! How to:

- 'Fork' this repo. This creates a copy of it you have edit permissions of.
- Clone your forked repo, edit it, and push it back. You'll need the Github desktop or commandline client. Look up GitHub tutorials for that.
- Make a pull request on this repo. Use the 'compare across forks' link to request to merge your changes on your forked repo to this repo. We'll review the changes and, if accepted, will be live the next day.

Don't worry about workshop addons or any of that. All files in here will be automatically uploaded to workshop. (Except lua which isn't run off of workshop)

If the files should go to all swamp servers (cinema, fatkid, spades), add the paths to commonlua.txt for lua or commonfiles.txt for anything else. Otherwise the files will only go to cinema.

# how tos

## Shop Weapons:

Add the weapon to lua/weapons/ as normal (See API for coding stuff)

Register the weapon in lua/sps/items/free.lua or lua/sps/items/weapons.lua as shown

Add the weapon to lua/sps/categories.lua

## One time use models:

Upload the playermodel

Register in lua/sps/items/uniquemodels.lua

Add to lua/sps/categories.lua

## Props ("wearables"):

Upload model, add to wearables.lua, add to categories.lua

Add the uploaded files to commonfiles.txt because wearables are usable across servers

# api

see lua/autorun/player_extension.lua:

player:IsPony()

player:IsAFK()

player:GetRank() (0 for players 1+ for staff)

entity:ExtEmitSound(soundname, options): its basically like EmitSound but does stuff so that if one guy is in a theater he won't hear it if its played outside the theater. It also handles the "lip syncing" (not really syncing - they move randomly) for speech sounds. options is a keyvalue table (or nil), possible arguments are:
- pitch
- crouchpitch
- level
- volume
- channel
- ent: emit from this ent instead of player
- shared: emit on client without networking, assuming called in shared function
- speech: move player lips (time to move lips, or auto if < 0)

player:GetLocation(): returns a integer for what location they are at
player:GetLocationName(): gets the location name (look at the cinema gamemode for more on this, the swamp version is similar)

global function: Safe(player or entity): is the player/entity in a safe/protected area or otherwise safe

---

everything in here (except stuff I downloaded eg. from workshop) is copyrighted by Swamp Servers
