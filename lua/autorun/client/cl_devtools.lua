-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWAMP_DEV = SWAMP_DEV or {}
SWAMP_DEV.isDev = false
SWAMP_DEV.refreshDelay = 2
SWAMP_DEV.itemStruct = nil
SWAMP_DEV.fileTimes = SWAMP_DEV.fileTimes or {}

SWAMP_DEV.structTypes = {
    ["weapons"] = function(curClass)
        SWEP = weapons.GetStored(curClass)
    end,
    ["entities"] = function(curClass)
        ENT = scripted_ents.GetStored(curClass)
    end,
    ["effects"] = function(curClass)
        local fxTab = effects.GetList()
        local fx = "effects/" .. curClass

        for _, v in ipairs(fxTab) do
            if (v.Folder == fx) then
                EFFECT = v

                return
            end
        end
    end
}

-- Returns a string to print
local function refreshFile(path, filename)
    local code = file.Read(path, "MOD")

    -- current filename as class format
    if SWAMP_DEV.itemStruct then
        local parentFolder = string.gsub(string.sub(path, 1, -#filename - 2), ".*/", "")

        -- if parent isn't a struct then use parent as class, else use filename
        if (not SWAMP_DEV.structTypes[parentFolder]) then
            SWAMP_DEV.structTypes[SWAMP_DEV.itemStruct](parentFolder)
        else
            SWAMP_DEV.structTypes[SWAMP_DEV.itemStruct](string.TrimRight(string.gsub(path, "^.*/", ""), ".lua"))
        end
    end

    BaseGamemode = engine.ActiveGamemode()
    GM = baseclass.Get(BaseGamemode)

    -- handle include
    for s in string.gmatch(code, "include%s*%b()") do
        local reqInclude = string.sub(string.gsub(s, "[%s%(%)\'\"]+", ""), 8)
        local includePath = string.sub(path, 1, -#filename - 1) .. reqInclude

        -- First check the parent folder
        if file.Exists(includePath, "MOD") then
            print("INCLUDING: " .. refreshFile(includePath, string.gsub(reqInclude, ".*/", "")))
            -- Then check the lua/ game folder
        elseif file.Exists("addons/contrib/lua/" .. reqInclude, "MOD") then
            print("INCLUDING: " .. refreshFile("addons/contrib/lua/" .. reqInclude, string.gsub(reqInclude, ".*/", "")))
        else
            print("Include handled by file")
        end
    end

    -- only replace includes that don't use variables
    RunString(code:gsub("include%s*%(%s*[\'\"].-[\'\"]%s*%)", ""), "swampDevTools")

    return filename
end
local recurseRefresh
do
    local ipairs = ipairs
    local fileFind = file.Find
    local fileTime = file.Time
    local function recurseRefresh(root, oldFileTimes, curPath)
        local newRoot = root .. curPath
        local files, folders = fileFind( .. "*", "MOD")

        for i, fileName in ipairs(files) do
            local filePath = newRoot .. v

            -- We're on the client so we shouldn't have access to sv_*.lua or init.lua files.
            -- Checking if the file is a lua file should be fine for this.
            if not v:EndsWith(".lua") then
                continue 
            end

            local newtime = fileTime(filePath, "MOD")

            -- Check if the file has been updated, otherwise
            if oldFileTimes[i] and (newtime ~= oldFileTimes[i]) then
                print("File refreshed: " .. newRoot .. refreshFile(filePath, fileName))
            end

            oldFileTimes[i] = newtime
        end

        for _, folder in ipairs(folders) do
            -- Again we're clientside, we won't have access to a server folder.

            if not oldFileTimes[folder] then
                oldFileTimes[folder] = {}
            end

            -- Check if we're in a gmod struct.
            if SWAMP_DEV.structTypes[folder] then
                SWAMP_DEV.itemStruct = folder
            end

            oldFileTimes[folder] = recurseRefresh(root, oldFileTimes[folder], newRoot .. "/")

            if curPath == "" then
                SWAMP_DEV.itemStruct = nil
            end
        end

        return times
    end
end
-- toggle dev editing. Root is addons/contrib
concommand.Add("dev", function()
    if (LocalPlayer():GetRank() <= 0) then return end
    SWAMP_DEV.isDev = not SWAMP_DEV.isDev

    SWAMP_DEV.fileTimes = {
        ["lua"] = {},
        ["gamemodes"] = {}
    }

    if (SWAMP_DEV.isDev) then
        print("Dev mode enabled")

        timer.Create("SWAMP_DEV.Refresh", SWAMP_DEV.refreshDelay, 0, function()
            -- avoid checking unnecessary folders
            recurseRefresh("addons/contrib/lua/", SWAMP_DEV.fileTimes["lua"], "")
            recurseRefresh("addons/contrib/gamemodes/", SWAMP_DEV.fileTimes["gamemodes"], "")
        end)
    else
        print("Dev mode disabled")
        timer.Remove("SWAMP_DEV.Refresh")
    end
end, nil, "Toggle dev mode, editing in addons/contrib", FCVAR_UNREGISTERED)

-- force refresh a singular file 
concommand.Add("dev_refresh", function(_, _, args)
    if not SWAMP_DEV.isDev or not args[1] then return end
    print("Attempting to force refresh file " .. args[1])

    for s in string.gmatch(args[1], "[^/\\]+") do
        if SWAMP_DEV.structTypes[s] then
            SWAMP_DEV.itemStruct = s
        end
    end

    print("File " .. refreshFile(args[1], string.gsub(args[1], ".*/", "")) .. " force refreshed")
end, nil, "Force refresh file PATH, CLASSNAME (if ENT or SWEP)", FCVAR_UNREGISTERED)