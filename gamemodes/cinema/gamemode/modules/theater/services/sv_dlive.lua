-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.dlive = function(self, key, ply, onSuccess, onFailure)
	
	local onFetchReceive = function( body, length, headers, code )
		
		local info = {}
		info.title = string.match(body,'displayname":"(.+)","p') or "(Unknown)"
		http.Fetch("https://live.prd.dlive.tv/hls/live/"..(string.match(body,'username":"(.+)","f') or "")..".m3u8",function(body2,length2,headers2,code2) --returns list of active streams
			if (code2 == 200) then
				for k,v in ipairs(string.Split(body2,"\n")) do
					if (v:EndsWith("src/live.m3u8")) then
						info.data = "https://cors.oak.re/"..v
						info.duration = 0
						onReceive(info)
					end
				end
			end
			onFailure( 'Theater_RequestFailed' )
		end, onFailure)
		
	end
	
	self:Fetch( key, onFetchReceive, onFailure )
end
