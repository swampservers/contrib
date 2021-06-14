local ranOnce = !ranOnce
if (!ranOnce) then return end -- just to prevent edge cases
ranOnce = true

local isDev = isDev
local refreshTime = 2
local rootFolder = rootFolder or nil
local fileTimes = fileTimes or {}
local devReplStr = nil -- classname of all child files, taken from folder

local function replaceFunction(base, regex, replacement)
	local iStart, iEnd = string.find(base, regex, 1)

	while iStart do
		local xStart, _ = string.find(base, "(", iEnd, true) -- func name index
		base = string.sub(base, 1, iStart-1) ..
			replacement .. "." .. string.sub(base, iEnd + 1, xStart-1) ..
			" = function" .. string.sub(base, xStart)
		iStart, iEnd = string.find(base, regex, xStart)
	end
	return base
end

local function refreshFile(path)
	if (!file.Exists(path, "LUA")) then return print("File " .. path .. " doesn't exist") end
	if (!isDev) then return end
	local code = file.Read(path, "LUA")

	-- current filename as class format
	local curClass = devReplStr or string.TrimRight(string.gsub(path, "^.*/", ""), ".lua")

	-- simple replacement for compatibility, handling weapons and ents, no need for a lexer
	-- performance impact should be minimal, it's ran once for testing, anyway
	local storedStr = ".GetStored(\"" .. curClass .. "\")"

	-- replace variables
	code = string.gsub(string.gsub(code,
		"%f[%a?]SWEP%.", "weapons" .. storedStr .. "."),
		"%f[%a?]ENT%.", "scripted_ents" .. storedStr .. ".")

	-- set all function definitions to assign to table
	code = replaceFunction(replaceFunction(code,
		"function%s+%f[%a?]SWEP:", "weapons" .. storedStr),
		"function%s+%f[%a?]ENT:", "scripted_ents" .. storedStr)

	RunString(code, "swampDevTools")
	print("File refreshed: " .. path)
end

local function recurseRefresh(times, curPath)
	local files, folders = file.Find(rootFolder .. curPath .. "*", "LUA")
	for k, v in pairs(files) do
		local newtime = file.Time(rootFolder .. curPath .. v, "LUA")
		if (!times[k]) then -- new file created, or first run
			times[k] = newtime
		elseif (newtime != times[k]) then
			times[k] = newtime

			refreshFile(rootFolder .. curPath .. v)
		end
	end
	for _, v in pairs(folders) do
		if (!times[v]) then times[v] = {} end
		if ((rootFolder == "weapons/") or (rootFolder == "entities/")) then
			devReplStr = v
		end
		times[v] = recurseRefresh(times[v], v .. "/")
	end
	devReplStr = nil
	return times
end

local function timedRefresh()
	local oldFolder = rootFolder
	recurseRefresh(fileTimes, "")
	timer.Simple(refreshTime, function()
		if (!isDev or rootFolder != oldFolder) then
			return print("Stopped automatic refresh for " .. oldFolder)
		end
		timedRefresh()
	end)
end


-- enable dev editing
concommand.Add("dev",
	function()
		if (LocalPlayer():GetRank() <= 0) then return end
		isDev = true
		print("Dev enabled")
	end,
	nil, "Register dev mode", FCVAR_UNREGISTERED)

-- set project root folder, so we arent checking unnecessary files
-- will refresh all files in root on first run
concommand.Add("setroot",
	function(_, _, args, argStr)
		if (!isDev or !args[1]) then return end
		argStr = string.TrimRight(argStr, "/")
		-- check if argStr is correct
		if (!file.Exists(argStr .. "/*", "LUA")) then
			return print("Directory " .. argStr .. " doesn't exist!")
		end
		rootFolder = argStr .. "/"
		fileTimes = {}
		devReplStr = nil
		timedRefresh()
		print("Root folder set to " .. argStr)
	end,
	nil, "Set project root folder, so we arent checking unnecessary files", FCVAR_UNREGISTERED)


-- stop checking files, exit dev mode
concommand.Add("cleardev",
	function()
		isDev = false
		fileTimes = {}
		print("Dev cleared")
	end,
	nil, "Stop checking files, exit dev mode", FCVAR_UNREGISTERED)


-- force refresh file
concommand.Add("frefresh", function(_, _, args)
		if !isDev or !args[1] then return end
		print("Attempting to force refresh file " .. args[1])
		if (args[2]) then
			devReplStr = args[2]
		end
		refreshFile(args[1])
		devReplStr = nil
	end,
	nil, "Force refresh file PATH, CLASSNAME (if ENT or SWEP)", FCVAR_UNREGISTERED)
