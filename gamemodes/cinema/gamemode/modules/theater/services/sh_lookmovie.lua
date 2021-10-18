-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local SERVICE = {}
SERVICE.Name = "LookMovie"
--SERVICE.Mature = true
SERVICE.NeedsCodecs = true
SERVICE.CacheLife = 0

function SERVICE:GetKey(url)
    if (util.JSONToTable(url.encoded)) then return false end
    if string.match(url.encoded, "lookmovie.io/movies/view/(.+)") and not string.find(url.path, "%.") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        local info = {}

        local onFetchReceive = function(code, body, headers)
            local t = util.JSONToTable(body)

            theater.Services.base:Fetch(t["streams"]["1080p"], function(sbody)
                local duration = 0

                for k, v in ipairs(string.Split(sbody, "\n")) do
                    if (v:StartWith("#EXTINF:")) then
                        duration = duration + tonumber(string.Split(string.sub(v, 9), ",")[1])
                    end
                end

                info.duration = math.ceil(duration)
                info.data = t["streams"]["1080p"] --change to t["streams"] and load based on quality setting?
                PrintTable(info)
                callback(info)
            end, callback)
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
                    failed = callback
                })
            end,
            failed = callback
        })
    end

    function SERVICE:LoadVideo(Video, panel)
        local k = Video:Data()
        local url = "http://swamp.sv/s/cinema/hls.html"
        panel:EnsureURL(url)

        --using a 2 second delay is the fastest way to load the video, sending th_video any quicker is much much slower for whatever reason
        timer.Simple(2, function()
            if IsValid(panel) then
                local str = string.format("th_video('%s',%s);", string.JavascriptSafe(k), true)
                panel:QueueJavascript(str)
            end
        end)
    end
end

theater.RegisterService('lookmovie', SERVICE)
