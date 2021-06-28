﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- DEVTOOLS:
-- This lets you conveniently edit clientside code and see your changes in real-time on the live server!
-- To use it, first clone this repository into your garrysmod/addons folder so you have garrysmod/addons/contrib/lua
-- Then, make a pull request to add your Steam ID to the "allowed" table below.
-- Once this is done, you can simply type "dev" in console, and when dev mode is enabled, any changes to files in your
-- local contrib repository will automatically be run while you're on the live server! You also get a "lua" console
-- command which essentially does the same thing as lua_run_cl.
-- Rules: This should only be used for development. Do not use this for anything that could be construed as malicious.
local allowed = {
    ["STEAM_0:0:38422842"] = true, -- swamponions
    ["STEAM_0:0:26424112"] = true, -- pyroteknik
    ["STEAM_0:1:43528204"] = true, -- noz
    ["STEAM_0:0:29598280"] = true, -- ech0
    ["STEAM_0:0:44814758"] = true, -- brian
    ["STEAM_0:0:105777797"] = true, -- nosharp
    
}

concommand.Add("lua", function(ply, cmd, args, args2)
    if not allowed[LocalPlayer():SteamID()] then
        print("Not allowed!")

        return
    end

    RunString(args2)
end)

-- Stores previous value of file.Time
local fileTimes = {}

-- Limitations:
--     - If a path has lua/STRUCTHERE eg. "lua/autorun/lua/weapons/test.lua" then
--         It'll pass the Struct into it, not sure if it's a bug or a feature.
--     - A file within a sub directory of a struct folder like: "lua/weapons/testEnt/mysubdir/lua"
--         Won't have the SWEP/struct table passed to it.
local structEnvironments = {
    ["weapons"] = function(curClass)
        local found = weapons.GetStored(curClass)

        return found and {
            SWEP = found
        } or nil
    end,
    ["entities"] = function(curClass)
        local found = scripted_ents.GetStored(curClass)

        return found and {
            ENT = found
        } or nil
    end,
    ["effects"] = function(curClass)
        local allEffects = effects.GetList()
        local targetEffect = "effects/" .. curClass

        for _, effect in ipairs(allEffects) do
            if effect.Folder == targetEffect then
                return {
                    EFFECT = effect
                }
            end
        end
    end
}

local function loadFile(filePath, environmentVars)
    local code = file.Read(filePath, "MOD")

    if not code then
        error("No file exists with the file path: " .. filePath)
    end

    environmentVars = environmentVars or {}
    environmentVars["GM"] = engine.ActiveGamemode()

    for key, var in pairs(environmentVars) do
        _G[key] = var
    end

    xpcall(function()
        RunString(code, "SwampDevTools/" .. filePath)
    end, function(err)
        print("[contrib] Error during loading file with devtools:", err)
        debug.Trace()
    end)

    -- remove the variaables from the global.
    for key, _ in pairs(environmentVars) do
        _G[key] = nil
    end
end

local function refreshFolder(subDir)
    local fileNames, folders = file.Find(subDir .. "/*", "MOD")

    for _, fileName in ipairs(fileNames) do
        local filePath = subDir .. "/" .. fileName
        if not fileName:EndsWith(".lua") then continue end
        local fTime = file.Time(filePath, "MOD")

        if (fileTimes[filePath] or fTime) == fTime then
            fileTimes[filePath] = fTime
            continue
        end

        local wasFoundDuringLookup = false

        for structName, func in pairs(structEnvironments) do
            local structLookupPath = "lua/" .. structName

            if filePath:find(structLookupPath) then
                local className = fileName:sub(1, -5) -- remove the .lua extension.
                loadFile(filePath, func(className) or func(subDir:gsub(".*/", "")))
                wasFoundDuringLookup = true
            end
        end

        if not wasFoundDuringLookup then
            loadFile(filePath)
        end

        fileTimes[filePath] = fTime
    end

    for _, folder in ipairs(folders) do
        refreshFolder(subDir .. "/" .. folder)
    end
end

concommand.Add("dev", function()
    if not allowed[LocalPlayer():SteamID()] then
        print("Not allowed!")

        return
    end

    DEVTOOLS_ENABLED = not DEVTOOLS_ENABLED

    if DEVTOOLS_ENABLED then
        print("Dev mode enabled")

        timer.Create("DEVTOOLS_Refresh", 2, 0, function()
            refreshFolder("addons/contrib/lua")
            refreshFolder("addons/contrib/gamemodes")
            refreshFolder("data/restricted/lua")
            refreshFolder("data/restricted/gamemodes")
        end)
    else
        print("Dev mode disabled")
        timer.Remove("DEVTOOLS_Refresh")
    end
end, nil, "Toggle dev mode, editing in addons/contrib", FCVAR_UNREGISTERED)

-- force refresh a singular file 
concommand.Add("dev_refresh", function(_, _, args)
    local filePath = args[1]
    if not DEVTOOLS_ENABLED or not filePath then return end
    print("Attempting to force refresh file " .. filePath)
    local structFound
    local ran

    for fileType in filePath:gmatch("[^/\\]+") do
        if structFound then
            loadFile(filePath, structFound(fileType))
            ran = true
            break
        end

        structFound = structEnvironments[fileType]
    end

    if not ran then
        loadFile(filePath, {})
    end

    print("File " .. filePath:gsub(".*/", "") .. " force refreshed")
end, nil, "Force refresh file PATH, CLASSNAME (if ENT or SWEP)", FCVAR_UNREGISTERED)

concommand.Add("trace", function(ply)
    print(LocalPlayer():GetEyeTrace().HitPos)
end)

concommand.Add("origin", function(ply)
    local v = LocalPlayer():GetPos()
    local a = LocalPlayer():EyeAngles()
    local txt = "{Vector(" .. tostring(math.floor(v.x)) .. ", " .. tostring(math.floor(v.y)) .. ", " .. tostring(math.floor(v.z)) .. "), Angle(0, " .. tostring(math.floor(a.y)) .. ", 0)},\n"
    print(txt)
    SetClipboardText(txt)
end)