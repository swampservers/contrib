-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.file = function(self, key, ply, onSuccess, onFailure)
	
    local onReceive = function(info)

        if info.duration>0 or info.title=="" then
            local sp = key:reverse():find("/",1,true)
            info.title = string.Trim(key:lower():reverse():sub(1,sp-1):reverse():gsub("mp4:",""), " ")
            local sp2 = info.title:lower():find(".mp4",1,true)
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
	
	local onFetchReceive = function(body,length,headers,code)
		
		local info = {}
		local t = string.match(body,"InitReact.mountComponent%(mod, ({.+ViewerContainer\"})")
		
		if t != nil then
			t = util.JSONToTable(t).props.file or {}
			info.title = t.filename or "(Unknown)"
			info.thumb = (t.preview.content.poster_url_tmpl and t.preview.content.poster_url_tmpl.."?size=1280x960&size_mode=2") or ""
			http.Fetch(t.preview.content.metadata_url or "",function(body2) 
				if (type(util.JSONToTable(body2)) == "table") then
					info.duration = math.ceil(tonumber(util.JSONToTable(body2).duration))
					onReceive(info)
				else
					theater.GetVideoInfoClientside(self:GetClass(), key, ply, onReceive, onFailure) --failsafe
				end
			end,function()
				theater.GetVideoInfoClientside(self:GetClass(), key, ply, onReceive, onFailure) --failsafe
			end)
		else
			theater.GetVideoInfoClientside(self:GetClass(), key, ply, onReceive, onFailure) --failsafe
		end
		
	end
	
	if string.match(key,"dropbox.com") then
		self:Fetch( string.Replace(key,"?dl=1",""), onFetchReceive, onFailure )
	else
		theater.GetVideoInfoClientside(self:GetClass(), key, ply, onReceive, onFailure)
	end
end