-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.hls = function(self, key, ply, onSuccess, onFailure)

	local streamwatch_key = string.match(key,"streamwat.ch/(%w+)/*$")
	local datalink = nil
	
	local onReceive = function(info)
		
		http.Post( "https://swampservers.net/fedorabot/gis.php", {q=info.title}, 
			function(body) 
				info.thumb="http://swampservers.net/cinema/contain.php?i="..body
				onSuccess(info)
			end, onFailure)
		
	end
	
	local onFetchReceive = function( body, length, headers, code )
		
		if (headers["Access-Control-Allow-Origin"] and headers["Access-Control-Allow-Origin"] != "*" and headers["Access-Control-Allow-Origin"] != "https://swampservers.net/") then
			datalink = "https://cors.oak.re/"..(datalink or key)
		end
		local info = {}
		local duration = 0
		local timed = false
		for k,v in ipairs(string.Split(body,"\n")) do
			if (v:StartWith("#EXTINF:")) then
				duration = duration+tonumber(string.Split(string.sub(v,9),",")[1]) --split because it can be 1.0000,live instead of just 1.0000,
			end
			if (v == "#EXT-X-ENDLIST" or v == "#EXT-X-PLAYLIST-TYPE:VOD") then
				timed = true
			end
		end
		if (string.TrimRight(string.Split(body,"\n")[1]) == "#EXTM3U") then
			ply:PrintMessage(HUD_PRINTCONSOLE,"#EXTM3U") --debug
			theater.GetVideoInfoClientside(self:GetClass(), datalink or key, ply, function(info) --use player to get the title
				info.duration = 0
				info.data = datalink or ""
				if timed then
					info.duration = math.ceil(duration)
					info.data = "true"
				end
				onSuccess(info)
			end, onFailure)
		else
			ply:PrintMessage(HUD_PRINTCONSOLE,body) --debug
			onFailure( 'Theater_RequestFailed' )
		end
		
	end
	
	local onFetchReceiveStreamWatch = function( body, length, headers, code )

		local streamwatch_url = string.match(body,"(http.+%.m3u8)")

		if streamwatch_url == nil or code == 0 then
			theater.GetVideoInfoClientside(self:GetClass(), key, ply, function(info) --use player to get the hls link due to serverside http issue
				info.data = streamwatch_url
				info.duration = 0
				onReceive(info)
			end, onFailure)
		elseif streamwatch_url != nil then
			datalink = string.Replace(streamwatch_url,"https://cors.oak.re/","")
			self:Fetch( datalink, onFetchReceive, onFailure )
		else
			ply:PrintMessage(HUD_PRINTCONSOLE,body) --debug
			onFailure( 'Theater_RequestFailed' )
		end

	end
	
	if streamwatch_key != nil then
		self:Fetch( "http://streamwat.ch/"..streamwatch_key.."/player.min.js", onFetchReceiveStreamWatch, function()
			theater.GetVideoInfoClientside(self:GetClass(), key, ply, function(info) --use player to get the hls link due to serverside http issue
				info.duration = 0
				onSuccess(info)
			end, onFailure)
		end)
	else
		self:Fetch(key, function(body) --process the first link if it's a playlist/menu
			local newurl = string.Split(key,"/")
			local urlindex = nil
			for k,v in ipairs(string.Split(body,"\n")) do
				if (string.find(v,".m3u8") and not urlindex) then
					urlindex = v
				end
			end
			if (urlindex and not string.find(urlindex,"http.://")) then
				local backcount = #string.Split(urlindex,"..")-1
				for _=1,backcount do table.remove(newurl) end
				newurl[#newurl] = string.sub(urlindex,backcount*3+1) or newurl[#newurl]
				newurl = table.concat(newurl,"/")
			elseif (urlindex and string.find(urlindex,"http.://")) then
				newurl = urlindex
			else
				newurl = key
			end
			self:Fetch(newurl, onFetchReceive, onFailure)
		end, onFailure)
	end
end
