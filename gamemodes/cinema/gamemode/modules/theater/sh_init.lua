-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

THEATER_NONE = 0 		-- Default theater
THEATER_PRIVATE = 1 	-- Private theater which can be rented
THEATER_REPLICATED = 2 	-- Theater that should be networked
THEATER_PRIVATEREPLICATED = 3

QUEUE_VOTEUPDOWN = 1
QUEUE_CHRONOLOGICAL = 2

hook.Add( "Think", "TheaterThink", function()
	for _, Theater in pairs(theater.GetTheaters()) do
		Theater:Think()
	end
end)

local url2 = url -- keep reference for extracting url data

module( "theater", package.seeall )

Theaters = {}

function GetTheaters()
	return Theaters
end

function GetByLocation( locId, setup )

	local Theater = Theaters[locId]

	if SERVER and !Theater and setup then

		local loc = Location.GetLocationByIndex( locId )

		-- Theater defined in location code
		local info = loc.Theater

		-- Valid theater info
		if info then
			info.Name = loc.Name

			if info.Thumb then
				local target = ents.FindByName(info.Thumb)
				if target and IsValid(target[1]) then
					info.ThumbEnt = target[1]
				end
			end

			Theater = THEATER:Init(locId, info)
			Theaters[locId] = Theater
		end

	end

	return Theater

end

function GetNameByLocation( locId )
	return Theaters[locId] and Theaters[locId]:Name() or "Unknown"
end

local function GetURLInfo( url )

	data = url2.parse2( url )

	if !data then
		return false
	end

	-- Keep reference to original url
	data.encoded = url

	-- Iterate through each service to check if the url is a valid request
	for _, service in pairs( Services ) do

		-- Ignore certain services
		if service.Hidden then
			continue
		end

		local key = service:GetKey( data )
		if key then
			return {type=service:GetClass(), key=key}
		end
	end

	return false
end

function ExtractURLInfo( url )
	-- Parse url info
	local status, info = pcall( GetURLInfo, url )
	if !status then
		print( "ERROR:\n" .. tostring(info) )
		return
	end

	return info
end
