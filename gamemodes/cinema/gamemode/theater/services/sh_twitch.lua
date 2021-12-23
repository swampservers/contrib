-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SERVICE = {}
SERVICE.Name = "Twitch"
SERVICE.NeedsCodecs = true
SERVICE.NeedsChromium = true

function SERVICE:GetKey(url)
    if not string.match(url.host or "", "twitch.tv") then return false end
    --CURRENTLY LIVE ONLY
    local key = string.match(url.path, "^/([%w_]+)$") --string.match(url.path, "^/[%w_]+/(%a/%d+)") or 

    if (not key) or string.len(key) < 1 then
        key = false
    end

    return key
end

if CLIENT then
    -- HTTPS NOT HTTP
    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("https://swamp.sv/s/cinema/twitch.html")
        -- Let the webpage handle loading a video
        local str = string.format("th_video('%s');", string.JavascriptSafe(Video:Key()))
        panel:QueueJavascript(str)
    end
end

theater.RegisterService('twitch', SERVICE)
