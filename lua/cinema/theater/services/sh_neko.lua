-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "Neko"
SERVICE.Mature = true

function SERVICE:GetKey(url)
    if string.match(url.encoded, "horatiotube.net/(.+)") or string.match(url.encoded, "stream.anonahost.com/(.+)") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        Derma_StringRequest("Neko Stream Title", "Name your livestream:", Me:Nick() .. "'s Stream", function(title)
            callback({
                duration = 0,
                title = title
            })
        end, function()
            callback()
        end)
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL(Video:Key() .. "?pwd=tgclub&usr=" .. Me:SteamID() .. "&cast=1")

        timer.Create("nekoupdate" .. tostring(math.random(1, 100000)), 1, 25, function()
            if IsValid(panel) then
                panel:RunJavascript("document.getElementsByTagName('p')[0].style.display='none';") --hides watermark
                panel:RunJavascript("document.getElementsByTagName('i')[0].click();") --unmutes player
                self:SetVolume(GetConVar("cinema_volume"):GetInt(), panel)
            end
        end)
    end

    function SERVICE:SetVolume(vol, panel)
        panel:RunJavascript(string.format("document.getElementsByTagName('video')[0].volume = %s", vol / 100)) --QueueJavascript is unreliable
    end
end

theater.RegisterService('neko', SERVICE)
