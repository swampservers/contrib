-- This file is subject to copyright - contact swampservers@gmail.com for more information.

local SERVICE = {}

SERVICE.Name 		= "DLive"

SERVICE.NeedsCodecs = true

function SERVICE:GetKey(url)
	if url.host and string.match(url.host,"dlive.tv") and string.match(url.path,"^/([%w_]+)[/]?$") then
		return url.encoded
	end
	return false
end

if CLIENT then
	function SERVICE:GetVideoInfoClientside(key, callback)
		EmbeddedCheckCodecs(function()
			vpanel = vgui.Create("DHTML")

			vpanel:SetSize(1000,100) --dlive hides title if screen is too small

			vpanel:SetAlpha(0)

			vpanel:SetMouseInputEnabled(false)
			
			timer.Simple(20,function() 
				if IsValid(vpanel) then
					vpanel:Remove() 
					print("Failed")
					callback()
				end
			end)
			
			timer.Create("dliveupdate"..tostring(math.random(1,100000)),1,45,function()
				if IsValid(vpanel) then
					vpanel:RunJavascript("console.log('TITLE:'+document.getElementsByClassName('dlive-name text-14-medium text-white')[4].innerText+': '+document.getElementsByClassName('text-14-medium text-white overflow-hidden')[0].innerText);")
					vpanel:RunJavascript("document.getElementsByClassName('dplayer-video dplayer-video-current')[0].volume=0;")
				end
			end)
			
			function vpanel:ConsoleMessage(msg)
				if (LocalPlayer().videoDebug) then print(msg) end
				if string.StartWith(msg,"TITLE:") then
					print("Success!")
					callback({title=msg:sub(7,-1),duration=0})
					self:Remove()
				end
			end

			vpanel:OpenURL(key)
		end,
		function()
			chat.AddText("You need codecs to request this. Press F2.")
			return callback()
		end)
	end
	
	function SERVICE:LoadVideo(Video, panel)
		panel:EnsureURL(Video:Key())
		
		panel:QueueJavascript("var volume=0;setInterval(function(){document.getElementsByClassName('dplayer-video dplayer-video-current')[0].volume=volume*0.01});")
		timer.Create("dliveupdate"..tostring(math.random(1,100000)),1,45,function()
			if IsValid(panel) then
				panel:RunJavascript("document.getElementsByClassName('chatroom-right')[0].style.display='none';")
				panel:RunJavascript("document.getElementsByClassName('application--wrap')[0].children[0].style.display='none';")
				panel:RunJavascript("document.getElementsByClassName('channel-header flex-justify-between flex-align-center bg-grey-darken-5 paddinglr-4')[0].style.display='none';")
				panel:RunJavascript("document.getElementsByClassName('height-100 position-relative sidebar')[0].style.display='none';")
				panel:RunJavascript("document.getElementsByClassName('livestream-info')[0].style.display='none';")
				panel:RunJavascript("dliveparent=document.getElementsByClassName('height-100 flex-auto overflow-y-auto flex-all-center bg-grey-darken-6')[0].children[0].children;dliveparent[1].style.display='none';dliveplayer=dliveparent[0].children[1];dliveplayer.classList='';")
				panel:RunJavascript("function th_volume(vol){volume=vol;}")
				return
			end
		end)
		
		function panel:ConsoleMessage(msg)
			if (LocalPlayer().videoDebug and not msg:StartWith("HREF:")) then print(msg) end
		end
	end
end

theater.RegisterService( 'dlive', SERVICE )
