
sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.hls = function(self, key, ply, onSuccess, onFailure)

	local match = string.match(key,"streamwat.ch/(%w+)/*$")
	
	local onReceive = function( body, length, headers, code )
		
		local match2 = string.match(body,"(http.+%.m3u8)")
		
		if match2 != nil then
			local info = {}
			info.data = match2
			onSuccess(info)
		end
		
		onFailure( 'Theater_RequestFailed' )
	end
	
	if match != nil then
		self:Fetch( "http://streamwat.ch/"..match.."/player.min.js", onReceive, onFailure )
	else
		onFailure( 'Theater_RequestFailed' )
	end
end