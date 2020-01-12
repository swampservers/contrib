local SERVICE = {}

SERVICE.Name 		= "HLS"

SERVICE.Mature = true

SERVICE.NeedsCodecs = true

SERVICE.LivestreamCacheLife = 0

function SERVICE:GetKey( url )
	if string.sub( url.path, -5) == ".m3u8" then
		return url.encoded
	end
	return false
end

if CLIENT then
	function SERVICE:GetVideoInfoClientside(key, callback)
		EmbeddedCheckCodecs(function()
			vpanel = vgui.Create("DHTML")

			vpanel:SetSize(100,100)

			vpanel:SetAlpha(0)

			vpanel:SetMouseInputEnabled(false)
			
			timer.Simple(20,function() 
				if IsValid(vpanel) then
					vpanel:Remove() 
					print("Failed")
					callback()
				end
			end)

			function vpanel:ConsoleMessage(msg)
				if msg:StartWith("LIVE") then
					self:Remove()
					print("Success!")
					Derma_StringRequest("RTMP Stream Title", "Name your livestream:", LocalPlayer():Nick().."'s Stream", function(title) callback({duration=0,title=title}) end, function() callback() end)
				end
			end
				
			local urll = "http://swampservers.net/cinema/hls.html";

			vpanel:OpenURL( urll..key )
		end,
		function()
			chat.AddText("You need codecs to request this. Press F2.")
			return callback()
		end)
	end
	
	function SERVICE:LoadVideo( Video, panel )
		local urll = "http://swampservers.net/cinema/hls.html"
		panel:EnsureURL(urll)
 
		local k = Video:Key()

		-- Let the webpage handle loading a video
		local str = string.format( "th_video('%s');", string.JavascriptSafe(k) )
		panel:QueueJavascript( str )
	end
end

theater.RegisterService( 'hls', SERVICE )
