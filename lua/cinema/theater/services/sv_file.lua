-- This file is subject to copyright - contact swampservers@gmail.com for more information.
sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.file = function(self, key, ply, onSuccess, onFailure)
    local onReceive = function(info)
        if info.duration > 0 or info.title == "" then
            info.title = key
            local ext = string.Explode(".", info.title)
            info.title = string.TrimRight(info.title, "." .. ext[#ext])
            info.title = string.Explode("/", info.title)
            info.title = info.title[#info.title]
            info.title = string.gsub(info.title, "%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end)
            info.title = string.gsub(info.title, "+", " ")
            info.title = info.title:gsub("_", " ")
            info.title = info.title:sub(1, 1):upper() .. info.title:sub(2)

            for i = 1, info.title:len() - 1 do
                if info.title:sub(i, i) == " " then
                    info.title = info.title:sub(1, i) .. info.title:sub(i + 1, i + 1):upper() .. info.title:sub(i + 2)
                end
            end

            info.title = string.Trim(info.title, " ")
        end

        --add a bit for buffering
        if info.duration > 0 then
            info.duration = info.duration + 2
        end

        if info.duration > 360000 then
            onFailure('Theater_RequestFailed')
        else
            onSuccess(info)
        end
    end

    theater.GetVideoInfoClientside(self:GetClass(), key, ply, function(info)
        --don't accept links that can't be viewed by both the client and the server
        --[[HTTP({
            method = "HEAD",
            url = key,
            success = function(code)
                --whitelist for discord's annoying anti-scrape measure
                if (code == 200 or string.match(key, "cdn.discordapp.com")) then
                    onReceive(info)
                else
                    onFailure('File is only available to you')
                end
            end,
            failed = function(err)
                ply:PrintMessage(HUD_PRINTCONSOLE, err)
                onFailure('File is only available to you')
            end
        })]]
        onReceive(info)
    end, onFailure)
end
