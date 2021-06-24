-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

--[[
    Limitations:
        - If a path has lua/STRUCTHERE eg. "lua/autorun/lua/weapons/test.lua" then
            It'll pass the Struct into it, not sure if it's a bug or a feature.
        - A file within a sub directory of a struct folder like: "lua/weapons/testEnt/mysubdir/lua"
            Won't have the SWEP/struct table passed to it.

]]--
SWAMP_DEV = SWAMP_DEV or {}

SWAMP_DEV.allowed = {
    ["STEAM_0:0:105777797"] = true -- Nosharp https://github.com/nosharp
}

-- Are we in development mode?
SWAMP_DEV.enabled = false
-- The delay on checking if we need to refresh files
SWAMP_DEV.refreshDelay = 2

local currentItemStruct = nil

--- This stores file times for certain root folder.
--- FileNames[key] -> SaveTime[value]
SWAMP_DEV.fileTimes = SWAMP_DEV.fileTimes or {}
 
-- lua/STRUCT/*

SWAMP_DEV.structEnvironments = {
    ["weapons"] = function(curClass)
        local found = weapons.GetStored(curClass)
        return found and {SWEP=found} or nil
    end,
    ["entities"] = function(curClass)
        local found = scripted_ents.GetStored(curClass)
        return found and {ENT=found} or nil
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

local ROOT_DIRECTORY = "addons/contrib/"
local refreshFolder
local loadFile
local engineGamemode = engine.ActiveGamemode()
do 
    local loadFunc = function() end
    function loadFile(filePath, environmentVars)
     
        local code = file.Read(filePath, "MOD")
        if not code then 
            error("No file exists with the file path: " .. filePath)
        end
        environmentVars = environmentVars or {}
        environmentVars["GM"] = engineGamemode
        for key,var in pairs(environmentVars) do
            _G[key] = var
        end
        xpcall(function()
            RunString(code, "SwampDevTools/" .. filePath)
            
        end, function(err)
            print("[contrib] Error during loading file with devtools:", err)
            debug.Trace()
        end)

        -- remove the variaables from the global.
        for key,_ in pairs(environmentVars) do
            _G[key] = nil
        end
    end

    local fileTime = file.Time

    function refreshFolder(subDir)
        local fileNames, folders = file.Find(subDir .. "/*", "MOD")
        local fileTimes = SWAMP_DEV.fileTimes
        for _,fileName in ipairs(fileNames) do
            local filePath = subDir .. "/" .. fileName
            if not fileName:EndsWith(".lua") then continue end

            local fTime = fileTime(filePath, "MOD")

            if not fileTimes[filePath] then
                fileTimes[filePath] = fTime
                continue
            else
                if fileTimes[filePath] == fTime then continue end
            end

            local wasFoundDuringLookup = false
            for structName, func in pairs(SWAMP_DEV.structEnvironments) do
                local structLookupPath = "lua/" .. structName

                if filePath:find(structLookupPath) then
                    local className = fileName:sub(1,-5) -- remove the .lua extension.
                    loadFile(filePath, func(className) or func(subDir:gsub(".*/", "")))
                    wasFoundDuringLookup = true
                end
            end

            if not wasFoundDuringLookup then 
                loadFile(filePath)
            end
            fileTimes[filePath] = fTime
        end

        for _,folder in ipairs(folders) do
            refreshFolder(subDir .. "/" .. folder)
        end
    end
end

-- toggle dev editing. Root is addons/contrib
concommand.Add("dev", function()
    if not SWAMP_DEV.allowed[LocalPlayer():SteamID()] then return end

    SWAMP_DEV.enabled = not SWAMP_DEV.enabled

    if SWAMP_DEV.enabled then
        print("Dev mode enabled")

        timer.Create("SWAMP_DEV.Refresh", SWAMP_DEV.refreshDelay, 0, function()
            -- avoid checking unnecessary folders
            refreshFolder(ROOT_DIRECTORY .. "lua")
            refreshFolder(ROOT_DIRECTORY .. "gamemodes")

        end)
    else
        print("Dev mode disabled")
        timer.Remove("SWAMP_DEV.Refresh")
    end
end, nil, "Toggle dev mode, editing in addons/contrib", FCVAR_UNREGISTERED)

-- force refresh a singular file 
concommand.Add("dev_refresh", function(_, _, args)
    local filePath = args[1]
    if not SWAMP_DEV.enabled or not filePath then return end
    print("Attempting to force refresh file " ..filePath)
    
    local structFound 
    local ran
    for fileType in filePath:gmatch("[^/\\]+") do
        
        if structFound then
            loadFile(filePath, structFound(fileType)) 
            ran = true
            break
        end

        structFound = SWAMP_DEV.structEnvironments[fileType]
    end

    if not ran then 
        loadFile(filePath, {})
    end

    print("File " .. filePath:gsub(".*/", "") .. " force refreshed")
end, nil, "Force refresh file PATH, CLASSNAME (if ENT or SWEP)", FCVAR_UNREGISTERED)