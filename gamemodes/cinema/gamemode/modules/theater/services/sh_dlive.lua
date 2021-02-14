-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

local SERVICE = {}

SERVICE.Name 		= "DLive"

SERVICE.NeedsCodecs = true

function SERVICE:GetKey(url)
	if url.host and string.match(url.host,"dlive.tv") and string.match(url.path,"^/([%w_]+)[/]?$") then
		return url.encoded
	end
	return false
end

if CLIENT then
	function SERVICE:LoadVideo( Video, panel )
		local url = "http://swampservers.net/cinema/hls.html"
		panel:EnsureURL(url)
		
		timer.Simple(2,function() --using a 2 second delay is the fastest way to load the video, sending th_video any quicker is much much slower for whatever reason
			if IsValid(panel) then
				local str = string.format( "th_video('%s',false);", string.JavascriptSafe(Video:Data()) )
				panel:QueueJavascript( str )
			end
		end)
	end
end

theater.RegisterService( 'dlive', SERVICE )
