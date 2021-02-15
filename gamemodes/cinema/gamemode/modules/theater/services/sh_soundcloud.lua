-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

local SERVICE = {}

SERVICE.Name 		  = "Soundcloud"
SERVICE.NeedsChromium = true

function SERVICE:GetKey(url)
	if (url.host and string.match(url.host,"soundcloud.com") and string.match(url.path,"/.+/(.+)") and not string.find(url.path,"%.") and not string.match(url.host,"api%-v2.soundcloud.com")) then
		return url.encoded
	end
	return false
end

theater.RegisterService( 'soundcloud' , SERVICE )
