local SERVICE = {}

SERVICE.Name 		= "File"

SERVICE.Mature = true

SERVICE.NeedsCodecs = true

SERVICE.LivestreamCacheLife = 0

function SERVICE:GetKey( url )
	if url.scheme == "rtmp" then return url.encoded end 
	if string.sub( url.path, -5) == ".webm" then
		return url.encoded
	end
	if string.sub( url.path, -4) == ".mp4" then
		if string.match( url.host, "dropbox.com" ) then
			return "https://www.dropbox.com"..url.path.."?dl=1"
		end
		return url.encoded
	end
	return false
end

if CLIENT then
	function SERVICE:GetVideoInfoClientside(key, callback)
		--EmbeddedCheckFlash(function()
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
					if duration==0 then
						duration=1
					end
					--what jwplayer says a livestream is
					if duration==-1 then
						duration=0
					end
					print("Duration: "..duration)
					self:Remove()
					print("Success!")

					if duration>0 then
						callback({duration=duration})
					else
						Derma_StringRequest("RTMP Stream Title", "Name your livestream:", LocalPlayer():Nick().."'s Stream", function(title) callback({duration=duration,title=title}) end, function() callback() end)
					end
				end
			end
				
			local urll = "http://swampservers.net/cinema/filedata.php?file="
			if string.StartWith(key:lower(), "rtmp") then
				urll = "http://swampservers.net/cinema/filedatavjs.php?file="
			end

			vpanel:OpenURL( urll..key )
		--end,
		--function()
		--	chat.AddText("You need flash to request this. Press F2.")
		--	return callback()
		--end)
	end
	
	function SERVICE:LoadVideo( Video, panel )
		local urll = "http://swampservers.net/cinema/file.html"
		if string.StartWith(Video:Key():lower(), "rtmp") then
			urll = "http://swampservers.net/cinema/filevjs.html"
		end
		panel:EnsureURL(urll)
		
		local cc = LocalPlayer():GetNetworkedString("cntry", "us")
		local eu_countries = {at=true,be=true,bg=true,cy=true,cz=true,dk=true,ee=true,fi=true,fr=true,de=true,gr=true,hu=true,ie=true,it=true,lv=true,lt=true,lu=true,mt=true,nl=true,pl=true,pt=true,ro=true,sk=true,si=true,es=true,se=true,gb=true}
		
		if eu_countries[cc] then
			cc="eu"
		else
			cc="us"
		end
 
		local k = Video:Key()
		
		k = string.Replace(k, "relay.horatio.tube", cc..".horatio.tube")

		-- Let the webpage handle loading a video
		local str = string.format( "th_video('%s');", string.JavascriptSafe(k) )
		panel:QueueJavascript( str )
	end
end

theater.RegisterService( 'file', SERVICE )
