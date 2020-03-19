
sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.bitchute = function(self, key, ply, onSuccess, onFailure)

	local onReceive = function( body, length, headers, code )
		
		local bitchute_url = string.match(body,"source src=\"(.+)\" type")
		
		if bitchute_url != nil then
		
			ServerDebug("bitchute fetch recieve: "..bitchute_url)
			theater.GetVideoInfoClientside(self:GetClass(), bitchute_url, ply, function(info)
				info.title = string.match(body,"<title>(.*)</title>") or "(Unknown)"
				info.data = bitchute_url
				ServerDebug("bitchute fetch sucess")
				onSuccess(info)
			end, onFailure)
			
		else
			ServerDebug("bitchute fetch failed: "..bitchute_url)
			onFailure( 'Theater_RequestFailed' )
		end
		
	end

	self:Fetch( "https://www.bitchute.com/embed/"..key, onReceive, onFailure )
end