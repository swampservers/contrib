-- This file is subject to copyright - contact swampservers@gmail.com for more information.
sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.kick = function(self, key, ply, onSuccess, onFailure)
    local onReceive = function(body, length, headers, code)
        local t = util.JSONToTable(body)

        if type(t) == "table" and t["livestream"]["session_title"] ~= nil and t["livestream"]["thumbnail"]["url"] ~= nil then
            local info = {}
            info.title = t["livestream"]["session_title"]
            info.thumb = t["livestream"]["thumbnail"]["url"]
            info.duration = 0

            onSuccess(info)
        else
            onFailure('Theater_RequestFailed')
        end
    end

    self:Fetch("https://kick.com/api/v2/channels/" .. key, onReceive, onFailure)
end
