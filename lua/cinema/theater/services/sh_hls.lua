-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "HLS"
SERVICE.Mature = true
SERVICE.NeedsCodecs = true
SERVICE.LivestreamCacheLife = 0
SERVICE.CacheLife = 0

function SERVICE:GetKey(url)
    if util.JSONToTable(url.encoded) then return false end
    if string.sub(url.path, -5) == ".m3u8" and not string.find(url.path, "%.") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        Derma_StringRequest("HLS Stream Title", "Name your livestream:", Me:Nick() .. "'s Stream", function(title)
            callback({
                title = title
            })
        end, function()
            callback()
        end)
    end

    function SERVICE:GetHost(Video)
        local k = Video:Key()

        if string.len(Video:Data()) > 1 and Video:Data() ~= "true" then
            k = Video:Data()
        end

        return url.parse2(k).host
    end

    function SERVICE:LoadVideo(Video, panel)
        local k = Video:Key()
        local url = "http://swamp.sv/s/cinema/file.html"
        panel:EnsureURL(url)

        if IsValid(panel) then
            local str = string.format("th_video('%s');", string.JavascriptSafe(k))
            panel:QueueJavascript(str)
        end
    end
end

theater.RegisterService('hls', SERVICE)
