-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

local SERVICE = {}

SERVICE.Name 		= "ThirdParty"

SERVICE.Mature = true

SERVICE.NeedsCodecs = true

SERVICE.LivestreamCacheLife = 0

SERVICE.CacheLife = 0

function SERVICE:GetKey( url )
	--if (util.JSONToTable(url.encoded)) then
	--	return url.encoded
	--end
	return false
end

if CLIENT then
	function SERVICE:GetVideoInfoClientside(key, callback)
	end
	
	function SERVICE:LoadVideo( Video, panel )
	end
end

theater.RegisterService( 'thirdparty', SERVICE )
