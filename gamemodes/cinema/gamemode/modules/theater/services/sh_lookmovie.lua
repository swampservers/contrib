-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local SERVICE = {}
SERVICE.Name = "LookMovie"
--SERVICE.Mature = true
SERVICE.NeedsCodecs = true
SERVICE.CacheLife = 0

function SERVICE:GetKey(url)
    if (util.JSONToTable(url.encoded)) then return false end
    if string.match(url.encoded, "lookmovie.io/movies/view/(.+)") then return url.encoded end

    return false
end

if CLIENT then
    lookmovieCookies = lookmovieCookies or ""

    function SERVICE:GetVideoInfoClientside(key, callback)
        local info = {}

        local onFetchReceive = function(code, body, headers)
            local t = util.JSONToTable(body)
            local url = t["streams"]["1080p"] or t["streams"]["720p"] or t["streams"]["480p"] or t["streams"]["360p"]

            theater.Services.base:Fetch(url, function(sbody)
                local duration = 0

                for k, v in ipairs(string.Split(sbody, "\n")) do
                    if (v:StartWith("#EXTINF:")) then
                        duration = duration + tonumber(string.Split(string.sub(v, 9), ",")[1])
                    end
                end

                info.duration = math.ceil(duration)
                info.data = url --change to t["streams"] and load based on quality setting?
                if (LocalPlayer().videoDebug) then PrintTable(info) end
                callback(info)
            end, callback)
        end

        HTTP({
            method = "GET",
            url = key,
            headers = {
                ["Cache-Control"] = "no-cache",
                ["Referer"] = key,
                ["Cookie"] = lookmovieCookies
            },
            success = function(code, body, headers)
                if headers["Set-Cookie"] then
                    lookmovieCookies = ""
                    for s,ss in string.gmatch(headers["Set-Cookie"],"([%w]+)=(.-);") do
                        if (s == "PHPSESSID" or s == "csrf") then lookmovieCookies = lookmovieCookies..s.."="..ss.."; " end
                    end
                end

                info.title = string.Replace(string.match(body, "title: '(.-)',\n"), "\\'", "'") .. " (" .. string.match(body, "year: '(.-)'") .. ")"
                info.thumb = string.match(body, "movie_poster: '(.-)'")

                HTTP({
                    method = "GET",
                    url = "https://lookmovie.io/api/v1/security/movie-access?id_movie=" .. string.match(body, "id_movie: (%d+)"),
                    headers = {
                        ["Cache-Control"] = "no-cache",
                        ["Referer"] = key,
                        ["Cookie"] = lookmovieCookies
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
