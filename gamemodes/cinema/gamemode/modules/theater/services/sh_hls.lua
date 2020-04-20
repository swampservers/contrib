local SERVICE = {}

SERVICE.Name 		= "HLS"

SERVICE.Mature = true

SERVICE.NeedsCodecs = true

SERVICE.LivestreamCacheLife = 0

function SERVICE:GetKey( url )
	if string.sub( url.path, -5) == ".m3u8" or string.find(url.encoded,"streamwat.ch/(.+)") then
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
			
			timer.Simple(2,function() 
				if IsValid(vpanel) then
					local str = string.format( "th_video('%s');", string.JavascriptSafe(key) )
					vpanel:QueueJavascript( str )
				end
			end)

			function vpanel:ConsoleMessage(msg)
				if (LocalPlayer().videoDebug) then print(msg) end
				if msg:StartWith("LIVE") then
					self:Remove()
					print("Success!")
					Derma_StringRequest("RTMP Stream Title", "Name your livestream:", LocalPlayer():Nick().."'s Stream", function(title) callback({duration=0,title=title}) end, function() callback() end)
				end
			end

			vpanel:OpenURL( "http://swampservers.net/cinema/hls.html" )
		end,
		function()
			chat.AddText("You need codecs to request this. Press F2.")
			return callback()
		end)
	end
	
	function SERVICE:LoadVideo( Video, panel )
		local k = string.len(Video:Data())>5 and Video:Data() or Video:Key()
		local url = "http://swampservers.net/cinema/hls.html"
		if (LocalPlayer().videoDebug) then
			print("K: "..k,string.len(k))
			print("KEY: "..Video:Key(),string.len(Video:Key()))
			print("DATA: "..Video:Data(),string.len(Video:Data()))
			print("URL: "..url)
		end
		panel:EnsureURL(url)
		
		LocalPlayer().theaterPanel = panel
		
		timer.Simple(2,function()
			if IsValid(panel) then
				local str = string.format( "th_video('%s');", string.JavascriptSafe(k) )
				panel:QueueJavascript( str )
			end
		end)
	end
end

theater.RegisterService( 'hls', SERVICE )
