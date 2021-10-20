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
    lookmovieCookies = lookmovieCookies or {}

    function SERVICE:GetVideoInfoClientside(key, callback)
        local info = {}

        local onFetchReceive = function(code, body, headers)
            local t = util.JSONToTable(body)

            if (t == nil) then
                callback()
            else
                local url = t["streams"]["1080p"] or t["streams"]["720p"] or t["streams"]["480p"] or t["streams"]["360p"]
                local subs = ""

                --find a good way to implement subtitle track choosing? lookmovie can have dozens of tracks and over a dozen tracks just for english with varying quality
                --[[for k,v in pairs(t["subtitles"]) do
                    if v["language"] == "English" then
                        subs = "https://lookmovie.io"..v["file"]
                        break
                    end
                end]]
                --change to t["streams"] and load based on quality setting?
                info.data = util.TableToJSON({
                    url = url,
                    subs = subs
                })

                theater.Services.base:Fetch(url, function(sbody)
                    local duration = 0

                    for k, v in ipairs(string.Split(sbody, "\n")) do
                        if (v:StartWith("#EXTINF:")) then
                            duration = duration + tonumber(string.Split(string.sub(v, 9), ",")[1])
                        end
                    end

                    info.duration = math.ceil(duration)

                    if (LocalPlayer().videoDebug) then
                        PrintTable(info)
                    end

                    callback(info)
                end, callback)
            end
        end

        HTTP({
            method = "GET",
            url = key,
            headers = {
                ["Cache-Control"] = "no-cache",
                ["Referer"] = key,
                ["Cookie"] = lookmovieCookies["PHPSESSID"] and (lookmovieCookies["PHPSESSID"].."; "..lookmovieCookies["csrf"].."; have_visited_internal_page=1") or ""
            },
            success = function(code, body, headers)
                if headers["Set-Cookie"] then
                    for s, ss in string.gmatch(headers["Set-Cookie"], "([%w]+)=(.-);") do
                        if (s == "PHPSESSID") then
                            lookmovieCookies["PHPSESSID"] = s .. "=" .. ss
                        end

                        if (s == "csrf") then
                            lookmovieCookies["csrf"] = s .. "=" .. ss
                        end
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
                        ["Cookie"] = lookmovieCookies["PHPSESSID"] .. "; " .. lookmovieCookies["csrf"] .. "; have_visited_internal_page=1"
                    },
                    success = onFetchReceive,
                    failed = callback
                })
            end,
            failed = callback
        })
    end

    function SERVICE:LoadVideo(Video, panel)
        local t = util.JSONToTable(Video:Data())
        local url = "http://swamp.sv/s/cinema/file.html"
        panel:EnsureURL(url)

        if IsValid(panel) then
            local str = string.format("th_video('%s','%s');", string.JavascriptSafe(t.url), t.subs or "")
            panel:QueueJavascript(str)
        end
    end
end

theater.RegisterService('lookmovie', SERVICE)
