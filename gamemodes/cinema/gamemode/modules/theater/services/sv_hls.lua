
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
		
		if streamwatch_url != nil then
		
			theater.GetVideoInfoClientside(self:GetClass(), key, ply, function(info)
				http.Post( "https://swampservers.net/fedorabot/gis.php", {q=info.title}, 
					function(body2) 
						info.thumb="http://swampservers.net/cinema/contain.php?i="..body2
						info.data = streamwatch_url
						onSuccess(info)
					end, onFailure)
			end, onFailure)
		
		end
		
		onFailure( 'Theater_RequestFailed' )
	end
	
	if streamwatch_key != nil then
		self:Fetch( "http://streamwat.ch/"..streamwatch_key.."/player.min.js", onFetchReceive, onFailure )
	else
		theater.GetVideoInfoClientside(self:GetClass(), key, ply, onReceive, onFailure)
	end
end