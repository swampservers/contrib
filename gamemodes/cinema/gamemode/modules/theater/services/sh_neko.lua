-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

local SERVICE = {}

SERVICE.Name 		= "Neko"

SERVICE.Mature = true

function SERVICE:GetKey( url )
	if string.match( url.encoded, "horatio.tube:68([8-9][0-9])" ) then
		return url.encoded
	end
	return false
end

if CLIENT then
	function SERVICE:GetVideoInfoClientside(key, callback)
		Derma_StringRequest("Neko Stream Title", "Name your livestream:", LocalPlayer():Nick().."'s Stream", function(title) callback({duration=0,title=title}) end, function() callback() end)
	end
	
	function SERVICE:LoadVideo(Video, panel)
		panel:EnsureURL(Video:Key())
		panel:QueueJavascript("document.getElementsByClassName('header-container')[0].style.display='none';document.getElementsByClassName('room-container')[0].style.display='none';document.getElementsByClassName('video-menu')[0].style.display='none';document.getElementsByClassName('neko-menu')[0].style.display='none';document.getElementsByClassName('connect')[0].style.display='none';document.getElementsByClassName('vue-notification-group')[0].style.display='none';") --hide ui
		panel.phase = 0
		
		timer.Create("nekoupdate"..tostring(math.random(1,100000)),1,45,function()
			if IsValid(panel) then
				panel:RunJavascript("document.getElementsByClassName('vue-notification-group')[0].style.display='none';document.getElementsByClassName('header-container')[0].style.display='none';document.getElementsByClassName('room-container')[0].style.display='none';document.getElementsByClassName('video-menu')[0].style.display='none';document.getElementsByClassName('neko-menu')[0].style.display='none';document.getElementsByClassName('connect')[0].style.display='none';") --failsafe hide ui
				--panel:RunJavascript("function th_volume(vol){document.getElementsByTagName('input')[1].value=vol;document.getElementsByTagName('input')[1].dispatchEvent(new Event('input'));}") --volume control
				if panel.phase == 0 then
					panel:RunJavascript("var nekoparent=document.getElementById('neko');console.log(nekoparent.getElementsByTagName('input').length);console.log('LOGIN:'+document.getElementsByClassName('connect').length);") --check if already logged in
					panel:RunJavascript("if(document.getElementsByClassName('neko-menu').length==0){document.getElementsByTagName('i')[1].click();}document.getElementsByClassName('tabs-container')[0].getElementsByTagName('i')[1].click();") --switch to settings tab
					panel:RunJavascript("if(document.getElementsByTagName('input')[6].checked){document.getElementsByTagName('input')[6].click();}else{document.getElementsByClassName('neko-menu')[0].remove();}") --disable chat sounds
					return
				elseif panel.phase == 1 then
					panel:RunJavascript("nekoparent=document.getElementById('neko');var inputevent=new Event('input');nekoparent.getElementsByTagName('input')[2].value='"..LocalPlayer():SteamID().."';nekoparent.getElementsByTagName('input')[3].value='tgclub';nekoparent.getElementsByTagName('input')[2].dispatchEvent(inputevent);nekoparent.getElementsByTagName('input')[3].value='tgclub';nekoparent.getElementsByTagName('input')[3].dispatchEvent(inputevent);nekoparent.getElementsByTagName('button')[0].click();") --log in
					panel:RunJavascript("console.log('LOGIN:'+document.getElementsByClassName('connect').length);")
					return
				elseif panel.phase == 2 then
					panel:RunJavascript("if(document.getElementsByClassName('fa-volume-mute fas').length>0)document.getElementsByClassName('fa-volume-mute fas')[0].click();") --unmute player
					return
				end
			end
		end)
		
		function panel:ConsoleMessage(msg)
			if msg then
				local smsg = tostring(msg)
				if (LocalPlayer().videoDebug and not smsg:StartWith("HREF:")) then print(smsg) end --required for debug in this case
				if self.phase == 0 then
					if type(msg) == "number" and msg >= 4 then
						self.phase = 1
					elseif string.StartWith(smsg,"LOGIN:") and smsg:sub(7,-1) == "0" then
						self.phase = 2
					end
					return
				elseif self.phase == 1 then
					if string.StartWith(smsg,"LOGIN:") and smsg:sub(7,-1) == "0" then
						self.phase = 2
					end
					return
				end
			end
		end
	end
	
	function SERVICE:SetVolume(vol, panel)
		local str = string.format("document.getElementsByTagName('input')[1].value=%s;document.getElementsByTagName('input')[1].dispatchEvent(new Event('input'));", vol)
		panel:RunJavascript( str ) --QueueJavascript is unreliable
	end
end

theater.RegisterService( 'neko', SERVICE )
