-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local SERVICE = {}
SERVICE.Name = "Neko"
SERVICE.Mature = true

function SERVICE:GetKey(url)
    if string.match(url.encoded, "horatio.tube:68([8-9][0-9])") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        Derma_StringRequest("Neko Stream Title", "Name your livestream:", LocalPlayer():Nick() .. "'s Stream", function(title)
            callback({
                duration = 0,
                title = title
            })
        end, function()
            callback()
        end)
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL(Video:Key() .. "/?pwd=tgclub&usr=" .. LocalPlayer():SteamID() .. "&cast=1")

        timer.Create("nekoupdate" .. tostring(math.random(1, 100000)), 1, 45, function()
            if IsValid(panel) then
                panel:RunJavascript("document.getElementsByTagName('p')[0].style.display='none';") --hides watermark
                panel:RunJavascript("document.getElementsByTagName('video')[0].click();") --unmutes player
                self:SetVolume(GetConVar("cinema_volume"):GetInt(), panel)
            end
        end)
    end

    function SERVICE:SetVolume(vol, panel)
        local str = string.format("document.getElementsByTagName('video')[0].volume = %s", vol / 100)
        panel:RunJavascript(str) --QueueJavascript is unreliable
    end
end

theater.RegisterService('neko', SERVICE)
