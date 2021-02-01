-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

local SERVICE = {}

SERVICE.Name 		= "Native"

SERVICE.Mature = true

function SERVICE:GetKey( url )
	if string.sub( url.path, -5) == ".webm" or string.sub( url.path, -4) == ".mov" then
		return url.encoded
	end
	return false
end

if CLIENT then
	function SERVICE:GetVideoInfoClientside(key, callback)
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
			if (LocalPlayer().videoDebug) then print(msg) end
			if msg:StartWith("DURATION:") then
				local duration = math.ceil(tonumber(string.sub(msg,10)))
				print("Duration: "..duration)
				self:Remove()

				if duration>0 then
					print("Success!")
					callback({duration=duration})
				else
					print("Error: Duration less than or equal to 0")
					callback()
				end
			end
		end

		local urll = "http://swampservers.net/cinema/filedata.php?file="

		vpanel:OpenURL( urll..key )
	end
	
	function SERVICE:LoadVideo( Video, panel )
		local urll = "http://swampservers.net/cinema/file.html"
		panel:EnsureURL(urll)
		
		local k = Video:Key()
		
		-- Let the webpage handle loading a video
		local str = string.format( "th_video('%s');", string.JavascriptSafe(k) )
		panel:QueueJavascript( str )
	end
end

theater.RegisterService( 'native', SERVICE )
