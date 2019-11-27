local SERVICE = {}

SERVICE.Name 		  = "Soundcloud"
SERVICE.NeedsChromium = true

function SERVICE:GetKey(url)
	if string.match(url.host,"soundcloud.com") then
		return url.encoded
	end
	return false
end

if CLIENT then
	function SERVICE:GetVideoInfoClientside(key, callback)
		EmbeddedCheckChromium(function()
			local vpanel = vgui.Create("DHTML")
			
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
				local splitmsg = string.Explode(":", msg, false)
				if table.remove(splitmsg, 1) == "DURATIONTITLE" then
					local duration = math.ceil(tonumber(table.remove(splitmsg,1))/1000)
					local title = table.concat(splitmsg, ":")
					print("Duration: "..duration)
					print("Title: "..title)
					self:Remove()
					print("Success!")
					callback({duration=duration,title=title})
				end
			end
			
			vpanel:OpenURL("http://swampservers.net/cinema/soundcloud.html?url="..string.JavascriptSafe(key))
		end,
		function()
			chat.AddText("You need chromium to request this. Press F2.")
			return callback()
		end)
	end
end

theater.RegisterService( 'soundcloud' , SERVICE )
