local SERVICE = {}

SERVICE.Name 		  = "Soundcloud"
SERVICE.NeedsChromium = true

function SERVICE:GetKey(url)
	return string.match(url.host,"soundcloud.com")
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
				if msg:StartWith("DURATION:") then
					local duration = math.ceil(tonumber(string.sub(msg,10)))/1000
					print("Duration: "..duration)
					self:Remove()
					print("Success!")
					callback({duration=duration})
				end
			end
			
			vpanel:OpenURL("http://swampservers.net/cinema/soundcloud.html?url="..string.JavascriptSafe(key))
		end,
		function()
			chat.AddText("You need flash to request this. Press F2.")
			return callback()
		end)
	end

	function SERVICE:LoadVideo( Video, panel )
		local url = "http://swampservers.net/cinema/soundcloud.html?url="..string.JavascriptSafe(Video:Key())
		panel:OpenURL(url)
	
		local startTime = CurTime() - Video:StartTime()
		
		function panel:ConsoleMessage(msg)
			if msg:StartWith("READY") then
				panel:QueueJavascript("th_volume("..theater.GetVolume()..");")
				panel:QueueJavascript("th_seek("..startTime..");")
			end
		end
	end
end

theater.RegisterService( 'soundcloud' , SERVICE )