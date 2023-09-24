-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "HLS"
SERVICE.Mature = true
SERVICE.NeedsCodecs = true
SERVICE.LivestreamCacheLife = 0
SERVICE.CacheLife = 0

function SERVICE:GetKey(url)
    if string.sub(url.path, -5) == ".m3u8" then return url.encoded end

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
        return url.parse2(Video:Key()).host
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("https://swamp.sv/s/cinema/hls.html")

        panel:AddFunction("gmod", "loaded", function()
            self:SeekTo(CurTime() - Video:StartTime(), panel)
            self:SetVolume(theater.GetVolume(), panel)
        end)

        panel:QueueJavascript([[
            th_video(']] .. string.JavascriptSafe(Video:Key()) .. [[');
            function checkLoaded() {
                if (!loaded) {
                    // Try a CORS proxy
                    // TODO: modify hls.html and add a hls.on for MEDIA_ATTACHED
                    console.log("Trying CORS proxy");
                    th_video('https://p.micspam.com/]] .. string.JavascriptSafe(Video:Key()) .. [[');
                }
            }
            setTimeout(checkLoaded, 5000);
        ]])
    end
end

theater.RegisterService('hls', SERVICE)
