-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SERVICE = {}
SERVICE.Name = "YouTube"
SERVICE.NeedsChromium = true
SERVICE.LivestreamNeedsCodecs = true
SERVICE.CacheLife = 3600 * 24 * 14

function SERVICE:IsMature(video)
    return video:Data() == "adult"
end

function SERVICE:GetKey(url)
    if not string.match(url.host or "", "youtu.?be[.com]?") then return false end
    local key = false

    -- http://www.youtube.com/watch?v=(videoId)
    if url.query and url.query.v and string.len(url.query.v) == 11 then
        key = url.query.v
        -- http://www.youtube.com/v/(videoId)
    elseif url.path and string.match(url.path, "^/v/([%a%d-_]+)") then
        key = string.match(url.path, "^/v/([%a%d-_]+)")
    elseif string.match(url.host, "youtu.be") and url.path and string.match(url.path, "^/([%a%d-_]+)$") and (not info.query or #info.query == 0) then
        -- http://youtu.be/(videoId)
        -- short url
        key = string.match(url.path, "^/([%a%d-_]+)$")
    end

    return key
end

if CLIENT then
    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("http://swamp.sv/s/cinema/" .. self:GetClass() .. ".html")
        -- Let the webpage handle loading a video
        local str = string.format("th_video('%s',%s);", string.JavascriptSafe(Video:Key()), Video:Duration() > 0 and "false" or "true")
        panel:QueueJavascript(str)
        local fn = panel.ConsoleMessage

        panel.ConsoleMessage = function(a, str)
            fn(a, str)

            if str:len() > 2 and str:sub(1, 2) == "T:" and tonumber(str:sub(3)) then
                YOUTUBE_TRUE_START = SysTime() - tonumber(str:sub(3))
                YOUTUBE_TRUE_START_PING = SysTime()
            end
        end
    end

    function YoutubeActualTimestamp()
        if (YOUTUBE_TRUE_START_PING or -100) > SysTime() - 2 then return SysTime() - YOUTUBE_TRUE_START end
    end
end

theater.RegisterService('youtube', SERVICE)