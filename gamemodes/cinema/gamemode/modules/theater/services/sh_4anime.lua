local SERVICE = {}

SERVICE.Name 		= "4Anime"

SERVICE.NeedsCodecs = true

function SERVICE:GetKey( url )
	if string.match( url.encoded, "4anime.to/(.+)" ) and not string.match( url.encoded, "4anime.to/anime/(.*)" ) then
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
			
			vpanel.phase = 0
			vpanel.title = nil
			vpanel.data = nil
			vpanel.duration = nil
			
			timer.Simple(45,function() 
				if IsValid(vpanel) then
					vpanel:Remove()
					print("Failed")
					callback()
				end
			end)
			
			timer.Create("4animeupdate"..tostring(math.random(1,100000)),1,45,function()
				if IsValid(vpanel) then
					if vpanel.phase == 0 then
						vpanel:RunJavascript("console.log('Title:'+document.title);")
						return
					elseif vpanel.phase == 1 then
						vpanel:RunJavascript("console.log('URL:'+document.getElementsByClassName('mirror_dl').item(0).href);")
						vpanel:RunJavascript("console.log('TITLE:'+document.title);")
						vpanel:RunJavascript("var swampvid=document.getElementById('example_video_1_html5_api');swampvid.volume=0;swampvid.play();console.log('DURATION:'+swampvid.duration);") --videojs player
						vpanel:RunJavascript("var jwp=jwplayer('my_video');jwp.setMute(1);jwp.play();console.log('DURATION:'+jwp.getDuration());") --jwplayer
						return
					end
				end
			end)
			
			function vpanel:ConsoleMessage(msg)
				if msg then
					if self.phase == 0 and msg != 'Title:Just a moment...' then
						print("Passed Cloudflare...")
						self.phase = 1
						return
					elseif self.phase == 1 then
						if string.StartWith(msg,"URL:") and not self.data then
							self.data = msg:sub(5,-1)
							print("URL: "..self.data)
						end
						if string.StartWith(msg,"DURATION:") and not self.duration then
							self.duration = msg:sub(10,-1)
							if self.duration == "0" then
								self.duration = nil
							end
							if self.duration then print("DURATION: "..self.duration) end
						end
						if string.StartWith(msg,"TITLE:") and not self.title then
							self.title = msg:sub(7,-1)
							print("TITLE: "..self.title)
						end
						if (self.data != nil and self.duration != nil and self.title != nil) then
							self.duration = math.floor(tonumber(self.duration))
							print("Duration: "..self.duration)
							callback({title=self.title,data=self.data,duration=self.duration})
							self:Remove()
							print("Success!")
						end
						return
					end
				end
			end

			vpanel:OpenURL( key )
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

		-- Let the webpage handle loading a video
		local str = string.format( "th_video('%s');", string.JavascriptSafe(k) )
		panel:QueueJavascript( str )
	end
end

theater.RegisterService( '4anime', SERVICE )
