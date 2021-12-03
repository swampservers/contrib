-- This file is subject to copyright - contact swampservers@gmail.com for more information.
GM.Name = "Swamp Cinema"
GM.Author = "Swamp (STEAM_0:0:38422842)"
GM.Email = "swampservers@gmail.com"
GM.Website = "swamp.sv"
GM.Version = "swamp"
GM.TeamBased = false

local function cl_file(fn)
    include(fn)
end

local function sh_file(fn)
    include(fn)
end

local function sv_file(fn)
end

if SERVER then
    cl_file = function(fn)
        AddCSLuaFile(fn)
    end

    sh_file = function(fn)
        AddCSLuaFile(fn)
        include(fn)
    end

    sv_file = function(fn)
        include(fn)
    end
end

local function auto_file(fn)
    local basefn = table.remove(("/"):Explode(fn))

    if basefn:StartWith("cl_") then
        cl_file(fn)
    elseif basefn:StartWith("sh_") then
        sh_file(fn)
    elseif basefn:StartWith("sv_") then
        sv_file(fn)
    else
        print("unqualified fn", fn)
    end
end

function Load(dir, f_callback)
    local files, dirs = file.Find(dir .. "/*", "LUA", "namedesc")
    local d_callback = Load

    if not f_callback then
        f_callback = auto_file

        if dir:EndsWith("/cl") or dir:EndsWith("/vgui") then
            f_callback = cl_file
        elseif dir:EndsWith("/sh") then
            f_callback = sh_file
        elseif dir:EndsWith("/sv") then
            f_callback = sv_file
        end
    end

    for i, f in ipairs(files) do
        if f:EndsWith(".lua") then
            f_callback(dir .. "/" .. f)
        end
    end

    for i, d in ipairs(dirs) do
        d_callback(dir .. "/" .. d, callback)
    end
end

local files, dirs = file.Find("cinema/gamemode/*", "LUA", "namedesc")

for i, d in ipairs(dirs) do
    Load("cinema/gamemode/" .. d)
end
