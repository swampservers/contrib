-- This file is subject to copyright - contact swampservers@gmail.com for more information.
GM.Name = "Swamp Cinema"
GM.Author = "Swamp (STEAM_0:0:38422842)"
GM.Email = "swampservers@gmail.com"
GM.Website = "swamp.sv"
GM.Version = "swamp"
GM.TeamBased = false

-- This has to be here for autorefresh to work
Include = function(fn) include(fn) end

local files, dirs = file.Find("cinema/gamemode/*", "LUA", "namedesc")

for i, d in ipairs(dirs) do
    Load("cinema/gamemode/" .. d)
end
