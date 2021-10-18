-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.lookmovie = function(self, key, ply, onSuccess, onFailure)
    local info = {}

    local onFetchReceive = function(code, body, headers)
        local t = util.JSONToTable(body)

        self:Fetch(t["streams"]["1080p"], function(sbody)
            local duration = 0

            for k, v in ipairs(string.Split(sbody, "\n")) do
                if (v:StartWith("#EXTINF:")) then
                    duration = duration + tonumber(string.Split(string.sub(v, 9), ",")[1])
                end
            end

            info.duration = math.ceil(duration)
            info.data = t["streams"]["1080p"] --change to t["streams"] and load based on quality setting?
            onSuccess(info)
        end, onFailure)
    end

    HTTP({
        method = "GET",
        url = key,
        headers = {
            ["Cache-Control"] = "no-cache"
        },
        success = function(code, body, headers)
            local cookies = ""

            for s, ss in string.gmatch(headers["Set-Cookie"], "([%w]+)=(.-);") do
                if (s == "PHPSESSID" or s == "csrf") then
                    cookies = cookies .. s .. "=" .. ss .. "; "
                end
            end

            info.title = string.match(body, "title: '(.-)'") .. " (" .. string.match(body, "year: '(.-)'") .. ")"
            info.thumb = string.match(body, "movie_poster: '(.-)'")

            HTTP({
                method = "GET",
                url = "https://lookmovie.io/api/v1/security/movie-access?id_movie=" .. string.match(body, "id_movie: (%d+)"),
                headers = {
                    ["Cache-Control"] = "no-cache",
                    ["Cookie"] = cookies
                },
                success = onFetchReceive,
                failed = onFailure
            })
        end,
        failed = onFailure
    })
end
