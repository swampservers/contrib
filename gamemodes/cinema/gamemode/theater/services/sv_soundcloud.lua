-- This file is subject to copyright - contact swampservers@gmail.com for more information.
sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.soundcloud = function(self, key, ply, onSuccess, onFailure)
    local onReceive = function(body, length, headers, code)
        local t = util.JSONToTable(body)

        if (type(t) == "table") and t["duration"] ~= nil and t["title"] ~= nil then
            local info = {}
            info.title = t["title"]
            info.duration = math.ceil(tonumber(t["duration"]) / 1000)

            if t["artwork_url"] ~= nil then
                info.thumb = string.Replace(t["artwork_url"], "-large.jpg", "-original.jpg")
            end

            onSuccess(info)
        else
            onFailure('Theater_RequestFailed')
        end
    end

    self:Fetch("https://api-widget.soundcloud.com/resolve?url=" .. key .. "&format=json&client_id=LBCcHmRB8XSStWL6wKH2HPACspQlXg2P", onReceive, onFailure)
end
