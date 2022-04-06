-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "AniMixPlay"
SERVICE.NeedsCodecs = true
SERVICE.CacheLife = 0

function SERVICE:GetKey(url)
    if string.match(url.encoded, "animixplay.to/v11?/(.+)") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
		http.Fetch(key, function(body)
			local ep = string.match(key, "animixplay.to/v11?/.+/ep(%d+)") or 1
			
			EmbeddedCheckCodecs(function() --required because the http functions fail to get the location response header
				if vpanel then
					vpanel:Remove()
				end
				
				vpanel = vgui.Create("TheaterHTML")
				vpanel:SetSize(0,0)
				vpanel:SetAlpha(0)
				vpanel:SetMouseInputEnabled(false)
				local duration
				
				timer.Simple(10, function()
					if IsValid(vpanel) then
						vpanel:Remove()
						print("Failed")
						callback()
					end
				end)
				
				timer.Create("animixplayupdate" .. tostring(math.random(1, 100000)), 1, 10, function()
					if IsValid(vpanel) then
						vpanel:RunJavascript("console.log('DURATION:'+Math.ceil(player1.duration))")
					end
				end)
				
				function vpanel:ConsoleMessage(msg)
					if msg:StartWith("DURATION:") and not msg:StartWith("DURATION:0") then
						duration = tonumber(string.sub(msg, 10))
					elseif msg:StartWith("HREF:") and duration ~= nil then
						local url = msg:sub(6)
						if url ~= "about:blank" then
							vpanel:Remove()
							
							callback({
								title = string.match(body,"<span class=\"animetitle\">(.-)</span>") .. (string.match(body, "\"eptotal\":1,") and "" or (" - Episode " .. ep)),
								data = string.Explode("#",url)[2],
								duration = duration
								--data = util.Base64Decode(string.Explode("#",url)[2])
							})
						end
					end
				end
				
				local k = string.match(body,"\""..(ep-1).."\":\".-php%?id=(.-)&title")
				if (not k) then
					chat.AddText(string.match(body, "\"eptotal\":0") and "[red]There are no episodes of this yet." or "[red]Use a different stream server.")
					callback()
				end
				vpanel:OpenURL("https://animixplay.to/api/live"..util.Base64Encode(k.."LTXs3GrU8we9O"..util.Base64Encode(k))) --redirects to player page
			end)
		end)
    end

    function SERVICE:LoadVideo(Video, panel)
        local k = Video:Data()
        panel:EnsureURL("https://animixplay.to/player.html#" .. k) --most gogo streams are CORS locked

        if IsValid(panel) then
            panel:QueueJavascript("x=document.getElementsByClassName('plyr__controls');setInterval(function(){if(x[0])x[0].remove()},100);")
            panel:QueueJavascript("target_time=-.5;to_volume=100;setInterval(function(){target_time+=.1;if(typeof player1!=='undefined'){player1.quality=0;player1.play();player1.media.volume=to_volume*.01;if(target_time<player1.duration&&Math.abs(player1.media.currentTime-target_time)>15){player1.media.currentTime=Math.max(0,target_time)}}},100)")
            panel:QueueJavascript(string.format("target_time=%s;to_volume=%s;", Me:GetTheater():VideoCurrentTime(true), theater.GetVolume()))
        end
    end
	
    function SERVICE:SetVolume(vol, panel)
        panel:RunJavascript(string.format("to_volume=%s;", vol))
    end

    function SERVICE:SeekTo(time, panel)
        panel:RunJavascript(string.format("target_time=%s;", time))
    end
end

theater.RegisterService('animixplay', SERVICE)
