-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.hls = function(self, key, ply, onSuccess, onFailure)

	local streamwatch_key = string.match(key,"streamwat.ch/(%w+)/*$")
	
	local onReceive = function(info)
	
		http.Post( "https://swampservers.net/fedorabot/gis.php", {q=info.title}, 
			function(body) 
				info.thumb="http://swampservers.net/cinema/contain.php?i="..body
				onSuccess(info)
			end, onFailure)
			
	end
	
	local onFetchReceive = function( body, length, headers, code )
		
		local streamwatch_url = string.match(body,"(http.+%.m3u8)")
		
		if streamwatch_url != nil or code == 0 then
			theater.GetVideoInfoClientside(self:GetClass(), (code==0 and key) or streamwatch_url, ply, function(info)
				info.data = streamwatch_url
				onSuccess(info)
			end, onFailure)
		else
			onFailure( 'Theater_RequestFailed' )
		end
		
	end
	
	if streamwatch_key != nil then
		self:Fetch( "https://streamwat.ch/"..streamwatch_key.."/player.min.js", onFetchReceive, onFailure )
	else
		theater.GetVideoInfoClientside(self:GetClass(), key, ply, onReceive, onFailure)
	end
end
