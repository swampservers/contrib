AddCSLuaFile()

hook.Add("Tick","fuck",function()
Init = true
CH = true
end)

local CLIENT_DIRS = {["vgui"] = true}
local SERVER_DIRS = {}
local SHARED_DIRS = {} 
 
local function AddFile( File, directory )

	local prefix = string.lower( string.Left( File, 3 ) )
	
	local parts = string.Explode("/",directory)
	local parentdir = parts[#parts - 1]
	local spacing = ""

	for i=1,#parts  do
		spacing = spacing .."    "
	end

    if(CLIENT_DIRS[parentdir])then prefix = "cl_" end
    if(SERVER_DIRS[parentdir])then prefix = "sv_" end
    if(SHARED_DIRS[parentdir])then prefix = "sh_" end

 
	if SERVER and prefix == "sv_" then
		include( directory .. File )
		print( "[AUTOLOAD]"..spacing.." SERVER INCLUDE: " .. File )
	elseif prefix == "sh_" then
		if SERVER then
			AddCSLuaFile( directory .. File )
			print( "[AUTOLOAD]"..spacing.." SHARED ADDCS: " .. File )
		end
		include( directory .. File )
		print( "[AUTOLOAD]"..spacing.." SHARED INCLUDE: " .. File )
	elseif prefix == "cl_" then
		if SERVER then
			AddCSLuaFile( directory .. File )
			print( "[AUTOLOAD]"..spacing.." CLIENT ADDCS: " .. File )
		elseif CLIENT then
			include( directory .. File )
			print( "[AUTOLOAD]"..spacing.." CLIENT INCLUDE: " .. File )
		end
    else
		--treat everything else like shared?
		if SERVER then
			AddCSLuaFile( directory .. File )
			print( "[AUTOLOAD]"..spacing.." SHARED ADDCS: " .. File )
		end
		include( directory .. File )
		print( "[AUTOLOAD]"..spacing.." SHARED INCLUDE: " .. File )
	end
end
 

local function IncludeDir( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "LUA" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".lua" ) then
			AddFile( v, directory )
		end
	end
	local parts = string.Explode("/",directory)

	local spacing = ""
	
	for i=1,#parts do
		spacing = spacing .."    "
	end

	for _, v in ipairs( directories ) do 
		
		print( "[AUTOLOAD]"..spacing.." Directory: " .. v )
		IncludeDir( directory .. v )
	end 
end
 
 
IncludeDir( "swampshop" ) 