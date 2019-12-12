SERVICE = {}

SERVICE.Name 	= "YouTube"

SERVICE.NeedsChromium = true
SERVICE.LivestreamNeedsCodecs = true

function SERVICE:GetKey( url )
	if not string.match( url.host or "", "youtu.?be[.com]?" ) then
		return false
	end

	local key = false

	-- http://www.youtube.com/watch?v=(videoId)
	if url.query and url.query.v and string.len(url.query.v) == 11 then
		key = url.query.v

	-- http://www.youtube.com/v/(videoId)
	elseif url.path and string.match(url.path, "^/v/([%a%d-_]+)") then
		key = string.match(url.path, "^/v/([%a%d-_]+)")

	-- http://youtu.be/(videoId)
	elseif string.match(url.host, "youtu.be") and 
		url.path and string.match(url.path, "^/([%a%d-_]+)$") and
		( !info.query or #info.query == 0 ) then -- short url
		key = string.match(url.path, "^/([%a%d-_]+)$")
	end

	return key
end

if CLIENT then
	function SERVICE:LoadVideo( Video, panel )
		panel:EnsureURL("http://swampservers.net/cinema/"..self:GetClass()..".html")

		-- Let the webpage handle loading a video
		local str = string.format( "th_video('%s',%s);", string.JavascriptSafe(Video:Key()), Video:Duration()>0 and "false" or "true" )
		panel:QueueJavascript( str )
	end
end

theater.RegisterService( 'youtube', SERVICE )
