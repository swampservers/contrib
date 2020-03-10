sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.soundcloud = function(self, key, ply, onSuccess, onFailure)
	local onReceive = function(info)

		http.Post( "https://swampservers.net/fedorabot/gis.php", {q=info.title}, 
			function(body) 
				info.thumb="http://swampservers.net/cinema/contain.php?i="..body 
				onSuccess(info)
			end, onFailure)
	end

	theater.GetVideoInfoClientside(self:GetClass(), key, ply, onReceive, onFailure)
end



			
