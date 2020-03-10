local SERVICE = {}

SERVICE.Name 		= "Bitchute"

SERVICE.NeedsCodecs = true

function SERVICE:GetKey( url )
	match = string.match(url.path,"/.+/(.+[^/])")
	if match != nil and string.find(url.host,"bitchute.com") then
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
			
			http.Fetch("https://www.bitchute.com/embed/"..key,
				function(body,length,headers,code)
					match = string.match(body,"source src=\"(.+)\" type")
					if match != nil then
						vpanel:OpenURL("http://swampservers.net/cinema/filedata.php?file="..match)
					end
				end,
				function(err)
					print("Failed to reach bitchute page while fetching duration")
					vpanel:Remove()
					callback()
				end
			)
		end,
		function()
			chat.AddText("You need codecs to request this. Press F2.")
			return callback()
		end)
	end
	
	function SERVICE:LoadVideo( Video, panel )
		http.Fetch("https://www.bitchute.com/embed/"..Video:Key(),
			function(body,length,headers,code)
				match = string.match(body,"source src=\"(.+)\" type")
				if match != nil then
					local url = "http://swampservers.net/cinema/file.html"
					panel:OpenURL(url)
					
					local k = Video:Key()
					local str = string.format( "th_video('%s');", string.JavascriptSafe(k) )
					panel:QueueJavascript( str )
				end
			end,
			function(err)
				print("Failed to reach bitchute page while loading video")
			end
		)
	end
end

theater.RegisterService( 'bitchute', SERVICE )
