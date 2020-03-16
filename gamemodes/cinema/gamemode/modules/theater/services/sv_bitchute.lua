
sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.bitchute = function(self, key, ply, onSuccess, onFailure)

	local onReceive = function( body, length, headers, code )
		
		local bitchute_url = string.match(body,"source src=\"(.+)\" type")
		
		if bitchute_url != nil then
			theater.GetVideoInfoClientside(self:GetClass(), key, ply, function(info)
				info.title = string.match(body,"<title>(.*)</title>") or "(Unknown)"
				info.data = bitchute_url
				onSuccess(info)
			end, onFailure)
		end
		
		onFailure( 'Theater_RequestFailed' )
	end

	self:Fetch( "https://www.bitchute.com/embed/"..key, onReceive, onFailure )
end