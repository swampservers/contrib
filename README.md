# swampservers/contrib

If you contribute to this repository, you agree to the **Contributor License Agreement**, as well as the **Copyright terms** listed at the bottom of this readme file.

# Overview

Contribute to Swamp Cinema here! How to:

- 'Fork' this repo. This creates a copy of it you have edit permissions of.
- Clone your forked repo, edit it, and push it back. You'll need the Github desktop or commandline client. Look up GitHub tutorials for that.
- Make a pull request on this repo. Use the 'compare across forks' link to request to merge your changes on your forked repo to this repo. We'll review the changes and, if accepted, will be live the next day.

Don't worry about workshop addons or any of that. All files in here will be automatically uploaded to workshop. (Except lua which isn't run off of workshop)

PLEASE FORMAT YOUR LUA CODE USING https://fptje.github.io/glualint-web/

# Contributing

If you wish to contribute to this repository, either pick a task from the [tasklist](https://github.com/swampservers/contrib/issues/230) or suggestions from our [Discord](https://swampservers.net/discord).

If you wish to get paid for the work you put in this repository, please contact [Echo](https://discord.com/users/425341154452701185) to decide on a deadline for the task / suggestion you wish to code. At that point you can already start working on it, and you will be reminded later of the reward decided by Swamp. 

If you are working on something that does not have a deadline, you may not get as high of a reward from Swamp. 

Depending on wether or not you manage to finish the project you started before the deadline you and [Echo](https://discord.com/users/425341154452701185) agreed on, will determine the amount of money you recieve in the end.

# How Tos

## Shop Weapons:

Add the weapon to lua/weapons/ as normal (See API for coding stuff)

Register the weapon in lua/sps/tabs/toys.lua or lua/sps/tabs/weapons.lua as shown

## One time use models:

Upload the playermodel

Register in lua/sps/tabs/playermodels.lua

## Props ("wearables"):

Upload model, add to tabs/swag.lua

To set up the default model position/scale, use **hatmaker.lua** (in the root of this repository; instructions are in the file)

# API

See lua/autorun/player_extension.lua:

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

# CONTRIBUTOR LICENSE AGREEMENT

**This repository is solely for game assets/code used by [Swamp Servers](https://swampservers.net/) to operate our online games. By submitting your work to this repository (via commits/pull requests), you agree that we have a PERMANENT, IRREVOCABLE, WORLDWIDE, TRANSFERABLE LICENSE to use, modify, and distribute all of your submitted work as we see fit. By submitting work created by a third party, you attest that the creator of that work also agrees that we have a permanent, irrevocable, worldwide, transferable license to use, modify, and distribute their submitted work as we see fit. Do not submit work from a third party without their agreement to these terms. Note that work publicly available on sites like "Steam Workshop" may already be distributed under agreements conducive to this.**

# COPYRIGHT

**This repository and most of its content is copyrighted and owned by Swamp Servers. All other content is, to the best of our knowledge, used under license. If your copyrighted work is here without permission, please contact the email shown [here](https://swampservers.net/contact). This repository DOES NOT license its contents to be used for other purposes, nor does its existence on GitHub imply such a license.**
