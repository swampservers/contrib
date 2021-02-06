-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.native = function(self, key, ply, onSuccess, onFailure)

    local onReceive = function(info)

        if info.duration>0 or info.title=="" then
			local ext = string.Explode(".",key)
			ext = ext[#ext]
            local sp = key:reverse():find("/",1,true)
            info.title = string.Trim(key:lower():reverse():sub(1,sp-1):reverse():gsub(ext..":",""), " ")
            local sp2 = info.title:lower():find("."..ext,1,true)
            if sp2 then info.title=info.title:sub(1,sp2-1) end
            info.title = info.title:gsub("%.smil","")
            info.title = info.title:gsub("%%20"," ")
            --info.title = info.title:gsub("%."," ")
            --info.title = info.title:gsub("%-"," ")
            info.title = info.title:gsub("_"," ")
            info.title = info.title:sub(1,1):upper()..info.title:sub(2)
            for i = 1,info.title:len()-1 do
                if info.title:sub(i,i)==" " then info.title = info.title:sub(1,i)..info.title:sub(i+1,i+1):upper()..info.title:sub(i+2) end
            end
            info.title = string.Trim(info.title, " ")
        end

        --add a bit for buffering
        if info.duration>0 then
            info.duration = info.duration+2
        end

        onSuccess(info)
    end
	
	theater.GetVideoInfoClientside(self:GetClass(), key, ply, onSuccess, onFailure)
end
