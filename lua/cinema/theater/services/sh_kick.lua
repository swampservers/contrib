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

        panel:AddFunction("gmod", "loaded", function()
            self:SetVolume(theater.GetVolume(), panel)
        end)

        panel:QueueJavascript("document.querySelector('button[aria-label=\"Mute/Unmute\"]').click();")
        panel:QueueJavascript([[
            const initInterval = setInterval(function() {
                document.querySelectorAll('audio, video').forEach(element => {
                    element.volume = 0;
                    if (element.readyState > 0) {
                        gmod.loaded();
                        clearInterval(initInterval);
                    }
                });
            }, 100);
        ]])
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
