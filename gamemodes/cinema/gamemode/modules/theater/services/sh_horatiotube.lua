local SERVICE = {}

SERVICE.Name 		= "HoratioTube"

SERVICE.Mature = true

SERVICE.NeedsFlash = true

SERVICE.LivestreamCacheLife = 0

function SERVICE:GetKey( url )
	--[[if url.host == "horatiotube.stream" then
		local pt = url.path
		if not pt then return false end
		pt = pt:gsub("/cat/%a+","")
		local key = string.match(pt, "^/video/(.+)")
		if key then return key end
	end]]
	return false
end

if CLIENT then
	function SERVICE:LoadVideo( Video, panel )
		panel:EnsureURL("http://swampservers.net/cinema/file.html")

		local rtmp = util.JSONToTable(Video:Data())[GetConVar("cinema_hd"):GetBool() and "hd" or "sd"]

		-- Let the webpage handle loading a video
		local str = string.format( "th_video('%s');", string.JavascriptSafe(rtmp) )
		panel:QueueJavascript( str )
	end
end

theater.RegisterService( 'horatio', SERVICE )
