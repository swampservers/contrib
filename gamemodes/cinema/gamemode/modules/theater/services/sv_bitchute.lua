
sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.bitchute = function(self, key, ply, onSuccess, onFailure)

	local onReceive = function( body, length, headers, code )
		
		local match = string.match(body,"source src=\"(.+)\" type")
		
		if match != nil then
			local info = {}
			info.title = string.match(body,"<title>(.*)</title>") or "(Unknown)"
			info.data = match
			onSuccess(info)
		end
		
		onFailure( 'Theater_RequestFailed' )
	end

	self:Fetch( "https://www.bitchute.com/embed/"..key, onReceive, onFailure )
end