-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.bitchute = function(self, key, ply, onSuccess, onFailure)

	local onReceive = function( body, length, headers, code )
		
		local bitchute_url = string.match(body,"source src=\"(.+)\" type")
		
		if bitchute_url != nil then
		
			theater.GetVideoInfoClientside(self:GetClass(), bitchute_url, ply, function(info)
				info.title = string.match(body,"<title>(.*)</title>") or "(Unknown)"
				info.thumb = string.match(body,'poster="(.+.jpg)"') or ""
				info.data = bitchute_url
				onSuccess(info)
			end, onFailure)
			
		else
			onFailure( 'Theater_RequestFailed' )
		end
		
	end

	self:Fetch( "https://www.bitchute.com/embed/"..key, onReceive, onFailure )
end
