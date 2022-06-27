-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include("swamp/sh_init.lua")
--- Shorthand for gamemode name
gm = engine.ActiveGamemode()

--[[
    SWAMP LOADING CODE:

    - Load(dir) will recurse a directory
    - all files in the directory will be loaded before any files in subfolders
    - all files should have qualified names (cl_, sv_, sh_, ent_, weapon_)
    - sh_init will be loaded first, followed by cl_init and sv_init, followed by all other files
    - special cases for loading ents/sweps in folders titled "entities" and "weapons"
]]
-- has to be copied to swamp_ents to make autorefresh work
Include = function(fn)
    include(fn)
end

-- local sub=sub 
-- seems to not be necessary
local function try(func, fn)
    -- print(fn)
    -- local ok,err = pcall(func, fn)
    -- if not ok then error(err) end
    func(fn)
end

if SERVER then
    function cl_file(fn)
        AddCSLuaFile(fn)
    end

    function sh_file(fn)
        AddCSLuaFile(fn)
        Include(fn)
    end

    function sv_file(fn)
        Include(fn)
    end
else
    function cl_file(fn)
        Include(fn)
    end

    function sh_file(fn)
        Include(fn)
    end

    function sv_file(fn)
    end
end

function load_ent(name, callback)
    if not LoadingEnts then return end

    _G.ENT = {
        Folder = "entities/" .. name
    }

    callback()
    scripted_ents.Register(_G.ENT, name)
    _G.ENT = nil
end

function load_swep(name, callback)
    if not LoadingEnts then return end

    _G.SWEP = {
        Base = "weapon_base",
        Folder = "weapons/" .. name,
        Primary = {},
        Secondary = {}
    }

    callback()
    weapons.Register(_G.SWEP, name)
    _G.SWEP = nil
end

function load_effect(name, callback)
    if not LoadingEnts then return end

    if CLIENT then
        _G.EFFECT = {
            Folder = "effects/" .. name
        }
    end

    callback()

    if CLIENT then
        effects.Register(_G.EFFECT, name)
        _G.EFFECT = nil
    end
end

local find, sub = string.find, string.sub

-- TODO optimize format thing sub!
local function findfiles(dir)
    local files, dirs = file.Find(dir .. "*", "LUA", "namedesc")

    -- sorting broken by update
    table.sort(files, function(a, b) return a<b end)
    table.sort(dirs, function(a, b) return a<b end)

    local initdirs = list()

    list(dirs):Map(function(d)
        if sub(d, 1, 1) ~= "_" then
            if sub(d, 1, 4) == "init" then
                initdirs:Append(d)
            else
                return d
            end
        end
    end)

    if initdirs[1] then
        dirs = initdirs:Extend(dirs)
    end

    local groups = defaultdict(function() return list() end)

    for i, f in ipairs(files) do
        if sub(f, -4) == ".lua" then
            local s = find(f, "_", 1, true)

            if s ~= 1 then
                local ext = s and sub(f, 1, s - 1) or ""

                local v = {f, ext}

                if sub(f, (s or 0) + 1, (s or 0) + 4) == "init" then
                    groups[ext == "sh" and 1 or 2]:Append(v)
                else
                    groups[ext == "sh" and 3 or (ext == "cl" or ext == "sv") and 4 or 5]:Append(v)
                end
            else
                -- still download the files but dont autorun them
                if SERVER and (startswith(f, "_cl_") or startswith(f, "_sh_")) then
                    AddCSLuaFile(dir .. f)
                end
            end
        end
    end

    files = nil

    for i = 1, 5 do
        local nxt = rawget(groups, i)

        if nxt then
            if files == nil then
                files = nxt
            else
                files:Extend(nxt)
            end
        end
    end

    if files == nil then
        files = list()
    end
    -- local x = ""
    -- for i,v in ipairs(files) do x=x.." "..v[1] end
    -- print("FILES",dir,x)

    return files, dirs
end

local prefixes = {
    sh = true,
    sv = true,
    cl = true,
    ent = true,
    weapon = true
}

local function Load(dir, path, upcontext)
    local nextpath = path .. dir .. "/"
    local files, dirs = findfiles(nextpath)
    local context = dir == "entities" and "ent" or dir == "weapons" and "weapon" or dir == "effects" and "effect" or startswith(dir, "sh_") and "sh" or startswith(dir, "cl_") and "cl" or startswith(dir, "sv_") and "sv" or nil

    if upcontext then
        assert(context == nil)
        context = upcontext
    end

    for i, f in ipairs(files) do
        local fn, pfx = unpack(f)
        local fullname = nextpath .. fn
        local class = context

        if prefixes[pfx] then
            assert(context == nil or context == pfx, "invalid " .. fullname)
            class = pfx
        end

        -- print("FILE", class, fullname)
        if class == "cl" then
            if not LoadingEnts then
                try(cl_file, fullname)
            end
        elseif class == "sh" then
            if not LoadingEnts then
                try(sh_file, fullname)
            end
        elseif class == "sv" then
            if not LoadingEnts then
                try(sv_file, fullname)
            end
        else
            if LoadingEnts then
                local entname = f[1]:sub(1, -5)

                if class == "ent" then
                    load_ent(entname, function()
                        try(sh_file, fullname)
                    end)
                elseif class == "weapon" then
                    load_swep(entname, function()
                        try(sh_file, fullname)
                    end)
                elseif class == "effect" then
                    load_effect(entname, function()
                        try(cl_file, fullname)
                    end)
                else
                    print("\n***IGNORING UNQUALIFIED FILE", fn)
                end
            end
        end
    end

    for i, d in ipairs(dirs) do
        -- print("DIR", nextpath, d, context)
        if startswith(d, "ent_") or context == "ent" then
            load_ent(d, function()
                try(sv_file, nextpath .. d .. "/init.lua")
                try(cl_file, nextpath .. d .. "/cl_init.lua")
            end)
        elseif startswith(d, "weapon_") or context == "weapon" then
            load_swep(d, function()
                try(sv_file, nextpath .. d .. "/init.lua")
                try(cl_file, nextpath .. d .. "/cl_init.lua")
            end)
        elseif context == "effect" then
            load_effect(basefn, function()
                try(cl_file, nextpath .. d .. "/init.lua")
            end)
        elseif not (dir == gm and d == "gamemode") then
            -- the gamemode lua gets mounted here
            Load(d, nextpath, context)
        end
    end
end

local function LoadAll(ents)
    LoadingEnts = ents
    Load("swamp", "")
    -- TODO: traverse gamemode hierarchy? engine.GetGamemodes()
    Load(gm, "")
end

GM = GAMEMODE

if not GM then
    GM = {}
    UnloadedGamemode = GM
end

-- load all NON-entity files right now, so autorefresh will just affect that file
LoadAll(false)

-- callback from entities/swamp_ents.lua (loads ents and also applies loaded non-ents)
-- this is so changing an entity's code will trigger reloading all ents with this code, so the global tables are created
function LoadSwampEntities()
    if UnloadedGamemode then
        table.Merge(GAMEMODE, UnloadedGamemode)
        UnloadedGamemode = nil
    end

    GM = GAMEMODE
    LoadAll(true)
    scripted_ents.OnLoaded()
    weapons.OnLoaded()
end
-- Load("swamp")
-- GM = GAMEMODE
-- Load(engine.ActiveGamemode())
-- -- the rest of this code just loads "cinemalua" and makes the global GM work
-- -- at loadtime, GAMEMODE wont be defined yet, so make a new table and put it in later
-- -- if this file is reloaded, just edit the gamemode table directly
-- GM = GAMEMODE or {}
-- -- the gamemode loading later messes with global namespace so save this table
-- local localgm = GM
-- local loadearly = false
-- print("load1")
-- -- append "lua" because the gamemode folder gets mounted there
-- if loadearly then Load(engine.ActiveGamemode()) else
-- hook.Add("OnGamemodeLoaded", "swampfiles", function() 
--     print("GM", GM)
--     PrintTable(GM)
--     -- GM = GAMEMODE
--     Load(engine.ActiveGamemode()) 
-- end)
-- --try using entities folder, encapsulate everything in an entity
-- end
-- print("load3")
-- hook.Add("PostGamemodeLoaded", "swampfiles", function()
--     table.Merge(GAMEMODE, localgm)
--     -- set this global again so we can reload files
--     GM = GAMEMODE
--     -- if not loadearly then
--     -- Load(engine.ActiveGamemode())
--     -- end
--     -- drop this table
--     localgm = nil
-- end)
-- -- TO LOAD FROM THE GAMEMODE ITSELF, PUT THIS IN shared.lua:
-- -- -- This has to be here for autorefresh to work
-- -- Include = function(fn)
-- --     include(fn)
-- -- end
-- -- local files, dirs = file.Find("cinema/gamemode/*", "LUA", "namedesc")
-- -- for i, d in ipairs(dirs) do
-- --     Load("cinema/gamemode/" .. d)
-- -- end
