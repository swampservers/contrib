-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

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
					vpanel:RunJavascript("console.log('TITLE:'+document.getElementsByClassName('dlive-name text-16-medium text-white')[0].innerText.trim()+': '+document.getElementsByClassName('text-14-medium text-white overflow-hidden')[0].innerText);")
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
		
		function panel:OnDocumentReady()
			panel:RunJavascript([[
				if(typeof VOLUME=="undefined")VOLUME=]]..theater.GetVolume()..[[;
				barhidden = false;
			
				setInterval(function(){
					if(document.getElementsByClassName('dplayer-video dplayer-video-current').length)document.getElementsByClassName('dplayer-video dplayer-video-current')[0].volume=VOLUME*0.01;
					
					var bar = document.getElementsByClassName('dplayer dplayer-no-danmaku dplayer-live dplayer-playing');
					if(bar.length && !bar[0].classList.contains('dplayer-hide-controller') && !barhidden)bar[0].classList.add('dplayer-hide-controller');barhidden=true;
					
					if(document.getElementsByClassName('chatroom-right').length)document.getElementsByClassName('chatroom-right')[0].style.display='none';
					if(document.getElementsByClassName('application--wrap').length)document.getElementsByClassName('application--wrap')[0].children[0].style.display='none';
					if(document.getElementsByClassName('channel-header flex-justify-between flex-align-center bg-grey-darken-5 paddinglr-4').length)document.getElementsByClassName('channel-header flex-justify-between flex-align-center bg-grey-darken-5 paddinglr-4')[0].style.display='none';
					if(document.getElementsByClassName('height-100 position-relative sidebar').length)document.getElementsByClassName('height-100 position-relative sidebar')[0].style.display='none';
					if(document.getElementsByClassName('livestream-info').length)document.getElementsByClassName('livestream-info')[0].style.display='none';
					
					dliveparent=document.getElementsByClassName('height-100 flex-auto overflow-y-auto flex-all-center bg-grey-darken-6')[0].children[0].children;
					if(dliveparent.length==2){
						dliveparent[1].style.display='none';
						dliveparent[0].children[1].classList='';
					}
					
					if(dliveparent.length==1){
						dliveparent2=document.getElementsByClassName('bg-grey-darken-5 mobile-page')[0].children;
						dliveparent2[1].style.display='none';
						dliveparent2[2].style.display='none';
						dliveparent[0].children[0].classList='';
					}
				},200);
			]])
		end
		
		function panel:ConsoleMessage(msg)
			if (LocalPlayer().videoDebug and not msg:StartWith("HREF:")) then print(msg) end
		end
	end
	
	function SERVICE:SetVolume(vol, panel)
		local str = string.format("VOLUME=%s;", vol)
		panel:RunJavascript(str) --QueueJavascript is unreliable
	end
end

theater.RegisterService( 'dlive', SERVICE )
