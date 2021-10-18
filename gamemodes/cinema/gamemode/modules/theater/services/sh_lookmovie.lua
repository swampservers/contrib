-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local SERVICE = {}
SERVICE.Name = "LookMovie"
SERVICE.Mature = true
SERVICE.NeedsCodecs = true
SERVICE.CacheLife = 0

function SERVICE:GetKey(url)
    if (util.JSONToTable(url.encoded)) then return false end
    if string.match(url.encoded, "lookmovie.io/movies/view/(.+)") and not string.find(url.path, "%.") then return url.encoded end

    return false
end

if CLIENT then
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
