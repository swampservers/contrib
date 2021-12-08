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


### Me = LocalPlayer()
Use this global instead of LocalPlayer() (it will be either nil or a valid entity)\
*lua/swamp/extensions/cl_me.lua*

### function Entity:IsPony()
Boolean, mostly for players\
*lua/swamp/pony/sh_init.lua*

### function defaultdict(constructor)
Returns a table such that when indexing the table, if the value doesn't exist, the constructor will be called with the key to initialize it.\
*lua/swamp/sh_core.lua*

### Player, Entity, Weapon
Omit FindMetaTable from your code because these globals always refer to their respective metatables.
Player/Entity are still callable and function the same as the default global functions.\
*lua/swamp/sh_meta.lua*

### function Player:GetRank()
Numeric player ranking (all players are zero, staff are 1+)\
*lua/swamp/swampcop/sh_init.lua (hidden file)*


**COPYRIGHT: This repository and most of its content is copyrighted and owned by Swamp Servers. All other content is, to the best of our knowledge, used under license. If your copyrighted work is here without permission, please contact the email shown [here](https://swampservers.net/contact). This repository DOES NOT license its contents to be used for other purposes, nor does its existence on GitHub imply such a license.**

**CONTRIBUTOR LICENSE AGREEMENT: This repository is solely for game assets/code used by [Swamp Servers](https://swampservers.net/) to operate our online games. By submitting your work to this repository (via commits/pull requests), you agree that we have a PERMANENT, IRREVOCABLE, WORLDWIDE, TRANSFERABLE LICENSE to use, modify, and distribute all of your submitted work as we see fit. By submitting work created by a third party, you attest that the creator of that work also agrees that we have a permanent, irrevocable, worldwide, transferable license to use, modify, and distribute their submitted work as we see fit. Do not submit work from a third party without their agreement to these terms. Note that work publicly available on sites like "Steam Workshop" may already be distributed under agreements conducive to this.**
