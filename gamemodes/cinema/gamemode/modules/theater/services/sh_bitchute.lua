-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

local SERVICE = {}

SERVICE.Name 		= "Bitchute"

SERVICE.NeedsCodecs = true

function SERVICE:GetKey( url )
	match = string.match(url.path,"/.+/(.+[^/])")
	if (match != nil and string.find(url.encoded,"bitchute.com/video/(.+)") and not string.find(url.path,"%.")) then
		return match
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
				if msg:StartWith("DURATION:") then
					local duration = math.ceil(tonumber(string.sub(msg,10)))
					print("Duration: "..duration)
					self:Remove()
					print("Success!")
					callback({duration=duration})
				end
			end
			
			vpanel:OpenURL("http://swampservers.net/cinema/filedata.php?file="..key)
		end,
		function()
			chat.AddText("You need codecs to request this. Press F2.")
			return callback()
		end)
	end
	
	function SERVICE:LoadVideo( Video, panel )
		local url = "http://swampservers.net/cinema/file.html"
		panel:EnsureURL(url)
		
		local k = Video:Data()
		
		local str = string.format( "th_video('%s');", string.JavascriptSafe(k) )
		panel:QueueJavascript( str )
	end
end

theater.RegisterService( 'bitchute', SERVICE )
