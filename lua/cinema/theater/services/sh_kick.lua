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
    function SERVICE:GetVideoInfoClientside(key, callback)
        if vpanel then
            vpanel:Remove()
        end

        vpanel = vgui.Create("DHTML", nil, "KickVPanel")
        vpanel:SetSize(100, 100)
        vpanel:SetAlpha(0)
        vpanel:SetMouseInputEnabled(false)
        vpanel:SetKeyboardInputEnabled(false)
        vpanel:OpenURL("https://kick.com/api/v2/channels/" .. key)

        timer.Simple(10, function()
            if IsValid(vpanel) then
                vpanel:Remove()
                print("Kick request failed")
                callback()
            end
        end)

        function vpanel:OnDocumentReady(url)
            self:AddFunction("gmod", "onVideoInfoReady", function(videoInfo)
                if videoInfo.title and videoInfo.duration and videoInfo.thumb then
                    callback(videoInfo)
                    self:Remove()
                end
            end)

            self:QueueJavascript([[
                const json = JSON.parse(document.body.textContent);
                const videoInfo = {
                    "title": json["livestream"]["session_title"],
                    "duration": 0,
                    "thumb": json["livestream"]["thumbnail"]["url"]
                };
                gmod.onVideoInfoReady(videoInfo);
            ]])
        end
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("https://player.kick.com/" .. Video:Key() .. "?autoplay=true&muted=false")

        panel:AddFunction("gmod", "loaded", function()
            self:SetVolume(theater.GetVolume(), panel)
        end)

        panel:QueueJavascript("document.querySelector('button[aria-label=\"Mute/Unmute\"]').click();")
        panel:QueueJavascript([[
            const initInterval = setInterval(function() {
                document.querySelectorAll('video').forEach(element => {
                    element.volume = 0;
                    // Wait for the kick player to be loaded
                    if (element.classList.contains("vjs-tech")) {
                        if (element.readyState > 0) {
                            gmod.loaded();
                            clearInterval(initInterval);
                        }
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
