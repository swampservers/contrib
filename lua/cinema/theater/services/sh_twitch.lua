-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SERVICE = {}
SERVICE.Name = "Twitch"
SERVICE.NeedsCodecs = true
SERVICE.NeedsChromium = true

function SERVICE:GetKey(url)
    if not string.match(url.host or "", "twitch.tv") then return false end
    local key = string.match(url.path, "^/([%w_]+)$") or string.match(url.path, "^/(videos/%d+)$")

    if not key or string.len(key) < 1 then
        key = false
    end

    return key
end

if CLIENT then
    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("https://swamp.sv/s/cinema/twitch.html")
        panel:QueueJavascript(string.format("th_video('%s');", string.JavascriptSafe(Video:Key())))
    end
end

theater.RegisterService('twitch', SERVICE)
