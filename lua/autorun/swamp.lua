-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--[[
    SWAMP LOADING CODE:

    - Load(dir) will recurse a directory
    - all files in the directory will be loaded before any files in subfolders
    - all files should have qualified names (cl_, sv_, sh_, ent_, weapon_)
    - sh_init will be loaded first, followed by cl_init and sv_init, followed by all other files
    - special cases for loading ents/sweps in folders titled "entities" and "weapons"
]]
-- has to be copied into the gamemode to make autorefresh work
Include = function(fn)
    include(fn)
end

-- seems to not be necessary
local function try(func, fn)
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
    _G.ENT = {
        Folder = "entities/" .. name
    }

    callback()
    scripted_ents.Register(_G.ENT, name)
    _G.ENT = nil
end

function load_swep(name, callback)
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

local function auto_file(fn)
    local pathparts = ("/"):Explode(fn)
    local class = nil

    for i, v in ipairs(pathparts) do
        if v:StartWith("cl_") then
            assert(class == nil)
            class = "cl"
        end

        if v:StartWith("sh_") then
            assert(class == nil)
            class = "sh"
        end

        if v:StartWith("sv_") then
            assert(class == nil)
            class = "sv"
        end
    end

    local basefn = table.remove(pathparts):sub(1, -5)
    local topdir = table.remove(pathparts)

    -- if basefn:StartWith("_") then return end
    if basefn:StartWith("ent_") or topdir == "entities" then
        assert(class == nil)
        class = "ent"
    end

    if basefn:StartWith("weapon_") or topdir == "weapons" then
        assert(class == nil)
        class = "swep"
    end

    if topdir == "effects" then
        assert(class == nil)
        class = "effect"
    end

    if class == "cl" then
        try(cl_file, fn)
    elseif class == "sh" then
        try(sh_file, fn)
    elseif class == "sv" then
        try(sv_file, fn)
    elseif class == "ent" then
        load_ent(basefn, function()
            try(sh_file, fn)
        end)
    elseif class == "swep" then
        load_swep(basefn, function()
            try(sh_file, fn)
        end)
    elseif class == "effect" then
        load_effect(basefn, function()
            try(cl_file, fn)
        end)
    else
        print("\n***IGNORING UNQUALIFIED FILE", fn)
    end
end

local function sortluafiles(files)
    local idx = {}

    for i, v in ipairs(files) do
        idx[v] = i
    end

    idx["sh_init.lua"] = -5
    idx["sv_init.lua"] = -3
    idx["cl_init.lua"] = -1
    table.sort(files, function(a, b) return idx[a] < idx[b] end)
end

function Load(dir)
    local files, dirs = file.Find(dir .. "/*", "LUA", "namedesc")
    sortluafiles(files)

    for i, f in ipairs(files) do
        if f:EndsWith(".lua") then
            auto_file(dir .. "/" .. f)
        end
    end

    for i, d in ipairs(dirs) do
        -- if not d:StartWith("_") then 
        if d:StartWith("ent_") or dir:EndsWith("/entities") then
            load_ent(d, function()
                try(sv_file, dir .. "/" .. d .. "/init.lua")
                try(cl_file, dir .. "/" .. d .. "/cl_init.lua")
            end)
        elseif d:StartWith("weapon_") or dir:EndsWith("/weapons") then
            load_swep(d, function()
                try(sv_file, dir .. "/" .. d .. "/init.lua")
                try(cl_file, dir .. "/" .. d .. "/cl_init.lua")
            end)
        elseif dir:EndsWith("/effects") then
            load_effect(basefn, function()
                try(cl_file, dir .. "/" .. d .. "/init.lua")
            end)
        else
            Load(dir .. "/" .. d)
        end
        -- end
    end
end

Load("swamp")
