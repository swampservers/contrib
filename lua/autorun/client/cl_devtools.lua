-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

SWAMP_DEV = SWAMP_DEV or {}
SWAMP_DEV.isDev = SWAMP_DEV.isDev
SWAMP_DEV.refreshDelay = 2
SWAMP_DEV.itemStruct = SWAMP_DEV.itemStruct
SWAMP_DEV.fileTimes = SWAMP_DEV.fileTimes or {}
SWAMP_DEV.structTypes = {
	["weapons"] = function(curClass) SWEP = weapons.GetStored(curClass) end,
	["entities"] = function(curClass) ENT = scripted_ents.GetStored(curClass) end,
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
		if (!SWAMP_DEV.structTypes[parentFolder]) then
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

		if (file.Exists(includePath, "MOD")) then -- First check the parent folder
			print("INCLUDING: " .. refreshFile(includePath, string.gsub(reqInclude, ".*/", "")))
			-- Then check the lua/ game folder
		elseif (file.Exists("addons/contrib/lua/" .. reqInclude, "MOD")) then
			print("INCLUDING: " .. refreshFile("addons/contrib/lua/" .. reqInclude, string.gsub(reqInclude, ".*/", "")))
		else
			print("Include handled by file")
		end
	end

	-- only replace includes that don't use variables
	RunString(string.gsub(code, "include%s*%(%s*[\'\"].-[\'\"]%s*%)", ""), "swampDevTools")

	return filename
end

local function recurseRefresh(root, times, curPath)
	local files, folders = file.Find(root .. curPath .. "*", "MOD")
	for k, v in ipairs(files) do
		if (!string.EndsWith(v, ".lua") or string.StartWith(v, "sv_") or (v == "init.lua")) then continue end
		local newtime = file.Time(root .. curPath .. v, "MOD")
		if times[k] and (newtime ~= times[k]) then -- check if file has updated
			print("File refreshed: " .. root .. curPath .. refreshFile(root .. curPath .. v, v))
		end
		times[k] = newtime
	end
	for _, v in ipairs(folders) do
		if (v == "server") then continue end

		if (!times[v]) then times[v] = {} end

		if SWAMP_DEV.structTypes[v] then SWAMP_DEV.itemStruct = v end -- defining struct

		times[v] = recurseRefresh(root, times[v], curPath .. v .. "/")
		if (curPath == "") then SWAMP_DEV.itemStruct = nil end
	end
	return times
end

-- toggle dev editing. Root is addons/contrib
concommand.Add("dev",
	function()
		if (LocalPlayer():GetRank() <= 0) then return end
		SWAMP_DEV.isDev = !SWAMP_DEV.isDev
		SWAMP_DEV.fileTimes = { ["lua"] = {}, ["gamemodes"] = {} }
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
	end,
	nil, "Toggle dev mode, editing in addons/contrib", FCVAR_UNREGISTERED)

-- force refresh file
concommand.Add("dev_refresh", function(_, _, args)
		if !SWAMP_DEV.isDev or !args[1] then return end
		print("Attempting to force refresh file " .. args[1])
		for s in string.gmatch(args[1], "[^/\\]+") do
			if SWAMP_DEV.structTypes[s] then SWAMP_DEV.itemStruct = s end
		end
		print("File " .. refreshFile(args[1], string.gsub(args[1], ".*/", "")) .. " force refreshed")
	end,
	nil, "Force refresh file PATH, CLASSNAME (if ENT or SWEP)", FCVAR_UNREGISTERED)
