-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.native = function(self, key, ply, onSuccess, onFailure)

    local onReceive = function(info)

		info.title = key
		local ext = string.Explode(".",info.title)
		info.title = string.TrimRight(info.title,"."..ext[#ext])
		info.title = string.Explode("/",info.title)
		info.title = info.title[#info.title]
		info.title = string.gsub(info.title,"%%(%x%x)",function(hex) return string.char(tonumber(hex,16)) end)
		info.title = string.gsub(info.title,"+"," ")
		info.title = info.title:gsub("_"," ")
		info.title = info.title:sub(1,1):upper()..info.title:sub(2)
        for i = 1,info.title:len()-1 do
            if info.title:sub(i,i)==" " then info.title = info.title:sub(1,i)..info.title:sub(i+1,i+1):upper()..info.title:sub(i+2) end
        end
		info.title = string.Trim(info.title," ")
		
		info.duration = info.duration+2

        onSuccess(info)
    end
	
	theater.GetVideoInfoClientside(self:GetClass(), key, ply, onSuccess, onFailure)
end
