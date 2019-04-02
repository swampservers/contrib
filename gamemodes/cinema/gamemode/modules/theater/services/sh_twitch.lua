SERVICE = {}

SERVICE.Name 	= "Twitch"

SERVICE.NeedsFlash = true
SERVICE.NeedsChromium = true

function SERVICE:GetKey( url )
	if not string.match( url.host or "", "twitch.tv") then
		return false
	end

	--CURRENTLY LIVE ONLY
	local key = string.match(url.path, "^/([%w_]+)$") --string.match(url.path, "^/[%w_]+/(%a/%d+)") or 

	if (not key) or string.len(key)<1 then
		key = false
	end
	
	return key
end

theater.RegisterService( 'twitch', SERVICE )
