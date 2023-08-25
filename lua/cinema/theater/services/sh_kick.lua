-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "Kick"
SERVICE.NeedsCodecs = true
SERVICE.NeedsChromium = true

function SERVICE:GetKey(url)
    if not string.match(url.host or "", "kick.com") then return false end
    local key = string.match(url.path, "^/([%w_]+)$")

    if not key or string.len(key) < 1 then
        key = false
    end

    return key
end

if CLIENT then
    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("https://player.kick.com/" .. Video:Key() .. "?autoplay=true&muted=false")
        panel:QueueJavascript("document.querySelector('button[aria-label=\"Mute/Unmute\"]').click();")
    end

    function SERVICE:SetVolume(vol, panel)
        panel:QueueJavascript([[
            document.querySelectorAll('audio, video').forEach(element => {
                element.volume = ]] .. (vol * 0.01) .. [[;
            });
        ]])
    end
end

theater.RegisterService('kick', SERVICE)
