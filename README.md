# swampservers/contrib

Please read the **COPYRIGHT** notice of the bottom of this page. If you contribute to this repository, then you agree to the **CONTRIBUTOR LICENSE AGREEMENT** also at the bottom of this page.

# Overview

Contribute to Swamp Cinema here! How to:

- 'Fork' this repo. This creates a copy of it you have edit permissions of.
- Clone your forked repo into garrysmod/addons (so it creates garrysmod/addons/contrib), edit it, and push it back. You'll need the GitHub desktop or commandline client. Look up GitHub tutorials for that.
- Make a pull request on this repo. Use the 'compare across forks' link to request to merge your changes on your forked repo to this repo. We'll review the changes and, if accepted, will be live the next day.
- Minor, single-file changes can just be done in the web browser by clicking the pencil icon.

All models/materials/sounds in this repository will be automatically uploaded to our workshop addons, so don't worry about that.

# Paid contributions

Please see our [task list](https://github.com/swampservers/contrib/issues/231) for more information.

# Code guidelines

 - Please submit code that is readable; you can use https://fptje.github.io/glualint-web/ to do this.
 - Please write *as few lines of code as possible* to acheive the desired result. More code is not better!!!!

# How Tos

## Shop Weapons:

Add the weapon to lua/weapons/ as normal (See API for coding stuff)

Register the weapon in lua/sps/tabs/toys.lua or lua/sps/tabs/weapons.lua as shown

## Playermodels:

Register in lua/sps/tabs/playermodels.lua

Don't upload the model here, add its workshop ID as shown in the file instead (this only works for playermodels, other assets need to be added here).

## Props ("wearables"):

Upload model, add to lua/sps/tabs/swag.lua

To set up the default model position/scale, use **hatmaker.lua** (in the root of this repository; instructions are in the file)

# API

lua/autorun/player_extension.lua:
```
player:IsPony()
player:IsAFK()
player:GetRank() # (0 for players 1+ for staff)
Hook: "PlayerModelChanged" is run when a player's model changes (called on both client and server)
```

lua/autorun/swamp_core.lua:
Extensions to Vector, math, table, etc


lua/autorun/extsound.lua:
entity:ExtEmitSound(soundname, options): Like EmitSound but does stuff so that if one guy is in a theater he won't hear it if its played outside the theater. It also handles the "lip syncing" (not really syncing - they move randomly) for speech sounds. options is a keyvalue table (or nil), possible arguments are:
- pitch
- crouchpitch
- level
- volume
- channel
- ent: emit from this ent instead of player
- shared: emit on client without networking, assuming called in shared function
- speech: move player lips (time to move lips, or auto if < 0)

player:GetLocation(): returns a integer for what location a player is in.
player:GetLocationName(): gets the location name (look at the cinema gamemode for more on this, the swamp version is similar).

global function: Safe(player or entity): is the player/entity in a safe/protected area or otherwise safe

**COPYRIGHT: This repository and most of its content is copyrighted and owned by Swamp Servers. All other content is, to the best of our knowledge, used under license. If your copyrighted work is here without permission, please contact the email shown [here](https://swampservers.net/contact). This repository DOES NOT license its contents to be used for other purposes, nor does its existence on GitHub imply such a license.**

**CONTRIBUTOR LICENSE AGREEMENT: This repository is solely for game assets/code used by [Swamp Servers](https://swampservers.net/) to operate our online games. By submitting your work to this repository (via commits/pull requests), you agree that we have a PERMANENT, IRREVOCABLE, WORLDWIDE, TRANSFERABLE LICENSE to use, modify, and distribute all of your submitted work as we see fit. By submitting work created by a third party, you attest that the creator of that work also agrees that we have a permanent, irrevocable, worldwide, transferable license to use, modify, and distribute their submitted work as we see fit. Do not submit work from a third party without their agreement to these terms. Note that work publicly available on sites like "Steam Workshop" may already be distributed under agreements conducive to this.**
