-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWAMP_DEV = SWAMP_DEV or {}
-- Are we in development mode?
SWAMP_DEV.isDev = false
-- The delay on checking if we need to refresh files
SWAMP_DEV.refreshDelay = 2

local currentItemStruct = nil

--- This stores file times for certain root folder.
--- Each sub table will have a Table of FileNames[key] -> SaveTime[value]
SWAMP_DEV.fileTimes = SWAMP_DEV.fileTimes or {
    ["lua"] = {},
    ["gamemodes"] = {}
}

SWAMP_DEV.structEnvironments = {
    ["weapons"] = function(curClass)
        return {
            SWEP = weapons.GetStored(curClass)
        }
    end,
    ["entities"] = function(curClass)
        return {
            ENT = scripted_ents.GetStored(curClass)
        }
    end,
    ["effects"] = function(curClass)
        local allEffects = effects.GetList()
        local targetEffect = "effects/" .. curClass

        for _, effect in ipairs(allEffects) do
            if (effect.Folder == targetEffect) then
                return {
                    EFFECT = effect
                }
            end
        end
    end
}

local rootDirectory = "addons/contrib/"
local refreshFile

do

    local loadFileWithEnvironment 
    do
        local loadFunc = function() end
        function loadFileWithEnvironment(code, environmentVars)
            
            loadFunc = CompileString(code, "SwapDevTools")
            -- setup our environment
            local environment = _G
            for key,var in pairs(environmentVars) do
                environment[key] = var
            end
            
            debug.setfenv(loadFunc,environment)
            loadFunc()

            -- remove the variaables from the global.
            for key,_ in pairs(environmentVars) do
                environment[key] = nil
            end
        end
    end

    -- Returns a string to print
    function refreshFile(path, filename)
        local code = file.Read(path, "MOD")
        local fileName = path:gsub("^.*/", ""):TrimRight(".lua")
        
        local environmentExtras = {}
        -- current filename as class format
        if currentItemStruct then
            local parentFolder = string.gsub(string.sub(path, 1, -#filename - 2), ".*/", "")

            -- if parent isn't a struct then use parent as class, else use filename
            if (not SWAMP_DEV.structEnvironments[parentFolder]) then
                environmentExtras = SWAMP_DEV.structEnvironments[currentItemStruct](parentFolder)
            else
                environmentExtras = SWAMP_DEV.structEnvironments[currentItemStruct](fileName)
            end
        end

        BaseGamemode = engine.ActiveGamemode()
        -- Load it into our environment.
        environmentExtras["GM"] = baseclass.Get(BaseGamemode)

        -- itterate over all includes within the file.
        for inc in code:gmatch("include%s*%b()") do
            local reqInclude = inc:gsub("[%s%(%)\'\"]+", ""):sub(8)

            local includePath = path:sub(1, -#inc - 1) .. reqInclude

            local fileName = reqInclude:gsub(".*/", "")

            -- First check the parent folder
            if file.Exists(includePath, "MOD") then
                print("INCLUDING: " .. refreshFile(includePath, fileName))
                -- Then check the lua/ game folder
            elseif file.Exists(rootDirectory .. "/lua/" .. reqInclude, "MOD") then
                print("INCLUDING: " .. refreshFile(rootDirectory .. "/lua/" .. reqInclude, reqInclude:gsub(".*/", "")))
            else
                print("Include handled by file")
            end
        end

        -- only replace includes that don't use variables
        loadFileWithEnvironment(code:gsub("include%s*%(%s*[\'\"].-[\'\"]%s*%)", ""), environmentExtras)
        return filename
    end

end

---
--- Recursive refresh folders and files in a certain directory.
--- @param subDir String the root directory search from, this should either be "lua" or "gamemodes".
--- @throws "unknown root" This is thrown when the subDir parameter isn't "lua" or "gamemodes"
local refreshFolder

do
    local ipairs = ipairs
    local fileFind = file.Find
    local fileTime = file.Time

    local knownRoots = {
        ["lua"] = true,
        ["gamemodes"] = true 
    }

    ---
    --- refreshes all items in a path
    --- if a folder is found it'll recursively refresh that.
    --- Modifies the fileTimes parameter supplied. 
    --- @param path string The path respective to the addon folder. [look at rootDirectory]
    --- @param fileTimes table The table of filetimes.
    local function recursiveRefresh(path, fileTimes)

        local files, folders = fileFind( path .. "/*", "MOD")
        for _, fileName in ipairs(files) do
            local filePath = path .. "/" .. fileName
            -- We're on the client so we shouldn't have access to sv_*.lua or init.lua files.
            -- Checking if the file is a lua file should be fine for this.
            if not fileName:EndsWith(".lua") then
                continue 
            end

            local newTime = fileTime(filePath, "MOD")

            local oldTime = fileTimes[filePath]

            -- Check if the file has been updated, otherwise
            if oldTime and newTime ~= oldTime then
                print("File refreshed: " .. path .. refreshFile(filePath, fileName))
            end

            fileTimes[filePath] = newTime
        end

        for _, folder in ipairs(folders) do
            recursiveRefresh( path .. "/" .. folder, fileTimes)
        end
    end

    function refreshFolder(subDir)

        assert(knownRoots[subDir], "Unknown Root")

        local path = rootDirectory .. subDir

        local files, folders = fileFind( path .. "/*", "MOD")

        local fileTimes = SWAMP_DEV.fileTimes[subDir]

        for _, fileName in ipairs(files) do
            local filePath = path .. "/" .. fileName
            
            -- We're on the client so we shouldn't have access to sv_*.lua or init.lua files.
            -- Checking if the file is a lua file should be fine for this.
            if not fileName:EndsWith(".lua") then
                continue 
            end

            local newTime = fileTime(filePath, "MOD")

            local oldTime = fileTimes[filePath]

            -- Check if the file has been updated, otherwise
            if oldTime and newTime ~= oldTime then
                print("File refreshed: " .. filePath .. refreshFile(filePath, fileName))
            end

            fileTimes[filePath] = newTime
        end

        for _, folder in ipairs(folders) do
            -- Again we're clientside, we won't have access to a server folder.

            -- Check if we're in a gmod struct.
            if SWAMP_DEV.structEnvironments[folder] then
                currentItemStruct = folder
            end

            recursiveRefresh(path .. "/" .. folder, fileTimes)

            if curPath == "" then
                currentItemStruct = nil
            end
        end
    end
end

-- toggle dev editing. Root is addons/contrib
concommand.Add("dev", function()
    -- if (LocalPlayer():GetRank() <= 0) then return end
    SWAMP_DEV.isDev = not SWAMP_DEV.isDev

    if (SWAMP_DEV.isDev) then
        print("Dev mode enabled")

        timer.Create("SWAMP_DEV.Refresh", SWAMP_DEV.refreshDelay, 0, function()
            print("refresshing?")
            -- avoid checking unnecessary folders
            refreshFolder("lua")
            refreshFolder("gamemodes")
        end)
    else
        print("Dev mode disabled")
        timer.Remove("SWAMP_DEV.Refresh")
    end
end, nil, "Toggle dev mode, editing in addons/contrib", FCVAR_UNREGISTERED)

-- force refresh a singular file 
concommand.Add("dev_refresh", function(_, _, args)
    local filePath = args[1]
    if not SWAMP_DEV.isDev or not filePath then return end
    print("Attempting to force refresh file " ..filePath)

    for fileType in filePath:gmatch("[^/\\]+") do
        if SWAMP_DEV.structEnvironments[fileType] then
            currentItemStruct = fileType
        end
    end

    print("File " .. refreshFile(filePath, filePath:gsub(".*/", "")) .. " force refreshed")
end, nil, "Force refresh file PATH, CLASSNAME (if ENT or SWEP)", FCVAR_UNREGISTERED)