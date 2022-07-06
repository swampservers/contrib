-- This file is subject to copyright - contact swampservers@gmail.com for more information.
sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.hls = function(self, key, ply, onSuccess, onFailure)
    local onFetchReceive = function(body, length, headers, code)
        local info = {}
        local duration = 0
        local timed = false

        for k, v in ipairs(string.Split(body, "\n")) do
            if v:StartWith("#EXTINF:") then
                duration = duration + tonumber(string.Split(string.sub(v, 9), ",")[1]) --split because it can be 1.0000,live instead of just 1.0000,
            end

            if v == "#EXT-X-ENDLIST" or v == "#EXT-X-PLAYLIST-TYPE:VOD" then
                timed = true
            end
        end

        if string.TrimRight(string.Split(body, "\n")[1]) == "#EXTM3U" then
            ply:PrintMessage(HUD_PRINTCONSOLE, "#EXTM3U") --debug

            --use player to get the title
            theater.GetVideoInfoClientside(self:GetClass(), key, ply, function(info)
                info.duration = 0
                info.data = ""

                if timed then
                    info.duration = math.ceil(duration)
                    info.data = "true"
                end

                onSuccess(info)
            end, onFailure)
        else
            ply:PrintMessage(HUD_PRINTCONSOLE, body) --debug
            onFailure('Theater_RequestFailed')
        end
    end

    --process the first link if it's a playlist/menu
    self:Fetch(key, function(body)
        local newurl = string.Split(key, "/")
        local urlindex = nil

        for k, v in ipairs(string.Split(body, "\n")) do
            if string.find(v, ".m3u8") and not urlindex then
                urlindex = v
            end
        end

        if urlindex and not string.find(urlindex, "http.://") then
            local backcount = #string.Split(urlindex, "..") - 1

            for _ = 1, backcount do
                table.remove(newurl)
            end

            newurl[#newurl] = string.sub(urlindex, backcount * 3 + 1) or newurl[#newurl]
            newurl = table.concat(newurl, "/")
        elseif urlindex and string.find(urlindex, "http.://") then
            newurl = urlindex
        else
            newurl = key
        end

        self:Fetch(newurl, onFetchReceive, onFailure)
    end, onFailure)
end
