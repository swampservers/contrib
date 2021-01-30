-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.soundcloud = function(self, key, ply, onSuccess, onFailure)
	local onReceive = function( body, length, headers, code )
		
		local t = util.JSONToTable(body)
		
		if (type(t) == "table") and t["duration"] != nil and t["title"]	!= nil then
			local info = {}
			info.title = t["title"]
			info.duration = math.ceil(tonumber(t["duration"])/1000)
			if (t["artwork_url"] != nil) then
				info.thumb = string.Replace(t["artwork_url"],"-large.jpg","-original.jpg")
			end
			onSuccess(info)
		else
			onFailure( 'Theater_RequestFailed' )
		end
		
	end

	self:Fetch( "https://api.soundcloud.com/resolve.json?url="..key.."/tracks&client_id=3775c0743f360c022a2fed672e33909d", onReceive, onFailure )
end
