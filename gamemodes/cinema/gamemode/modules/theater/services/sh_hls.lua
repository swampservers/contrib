-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

local SERVICE = {}

SERVICE.Name 		= "HLS"

SERVICE.Mature = true

SERVICE.NeedsCodecs = true

SERVICE.LivestreamCacheLife = 0

SERVICE.CacheLife = 0

function SERVICE:GetKey( url )
	if (util.JSONToTable(url.encoded)) then return false end
	if string.sub( url.path, -5) == ".m3u8" or (string.find(url.encoded,"streamwat.ch/(.+)") and not string.find(url.path,"%.")) then
		return url.encoded
	end
	return false
end

if CLIENT then
	function SERVICE:GetVideoInfoClientside(key, callback)
		if (string.EndsWith(key,".m3u8")) then
			Derma_StringRequest("HLS Stream Title", "Name your livestream:", LocalPlayer():Nick().."'s Stream", function(title) callback({title=title}) end, function() callback() end)
		else
			EmbeddedCheckCodecs(function()
				vpanel = vgui.Create("DHTML")
	
				vpanel:SetSize(100,100)
	
				vpanel:SetAlpha(0)
	
				vpanel:SetMouseInputEnabled(false)
				
				local link = nil
				
				timer.Simple(20,function() 
					if IsValid(vpanel) then
						vpanel:Remove() 
						print("Failed")
						callback()
					end
				end)
	
				function vpanel:ConsoleMessage(msg)
					if (LocalPlayer().videoDebug) then print(msg) end
					if msg:StartWith("STREAMWATCHURL:") then
						vpanel:OpenURL( "http://swampservers.net/cinema/hls.html" )
						link = string.sub(msg,16)
						local str = string.format( "th_video('%s');", string.JavascriptSafe(link) )
						timer.Simple(1,function() vpanel:QueueJavascript( str ) end) --delayed so page can load
					end
					if msg:StartWith("LIVE") then
						self:Remove()
						print("Success!")
						Derma_StringRequest("HLS Stream Title", "Name your livestream:", LocalPlayer():Nick().."'s Stream", function(title) callback({data=link,title=title}) end, function() callback() end)
					end
				end
	
				vpanel:OpenURL( key )
				local str = string.format( "console.log('STREAMWATCHURL:'+document.title);", string.JavascriptSafe(key) )
				vpanel:QueueJavascript( str )
			end,
			function()
				chat.AddText("You need codecs to request this. Press F2.")
				return callback()
			end)
		end
	end
	
	function SERVICE:LoadVideo( Video, panel )
		local k = Video:Key()
		if (string.len(Video:Data())>1 and Video:Data() != "true") then
			k = Video:Data()
		end
		local url = "http://swampservers.net/cinema/hls.html"
		panel:EnsureURL(url)
		
		timer.Simple(2,function() --using a 2 second delay is the fastest way to load the video, sending th_video any quicker is much much slower for whatever reason
			if IsValid(panel) then
				local str = string.format( "th_video('%s',%s);", string.JavascriptSafe(k), (Video:Data() == "true") )
				panel:QueueJavascript( str )
			end
		end)
	end
end

theater.RegisterService( 'hls', SERVICE )
