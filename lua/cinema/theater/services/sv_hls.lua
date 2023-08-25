-- This file is subject to copyright - contact swampservers@gmail.com for more information.
sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.hls = function(self, key, ply, onSuccess, onFailure)
    local onFetchReceive = function(body)
        local info = {}
        local duration = 0
        local timed = false

        for _, v in ipairs(string.Split(body, "\n")) do
            if v:StartWith("#EXTINF:") then
                duration = duration + tonumber(string.Split(string.sub(v, 9), ",")[1]) --split because it can be 1.0000,live instead of just 1.0000,
            end

            if v == "#EXT-X-ENDLIST" or v == "#EXT-X-PLAYLIST-TYPE:VOD" then
                timed = true
            end
        end

        if string.TrimRight(string.Split(body, "\n")[1]) == "#EXTM3U" then
            --use player to get the title
            theater.GetVideoInfoClientside(self:GetClass(), key, ply, function(info)
                info.duration = timed and math.ceil(duration) or 0
                onSuccess(info)
            end, onFailure)
        else
            ply:PrintMessage(HUD_PRINTCONSOLE, body) --debug
            onFailure('Theater_RequestFailed')
        end
    end

    self:Fetch(key, function(body)
        for _, line in ipairs(string.Split(body, "\n")) do
            if string.find(line, ".m3u8") then
                local streamurl
            
                if string.find(line, "https?://") then
                    streamurl = line
                else -- relative path
                    local uri = string.match(line, 'URI="(.-)"')
                    local path = string.Split(key, "/")
                    path[#path] = uri
                    streamurl = table.concat(path, "/")
                end

                self:Fetch(streamurl, onFetchReceive, onFailure)

                return
            end
        end

        onFetchReceive(body)
    end, onFailure)
end
