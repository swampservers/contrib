-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "wco"
SERVICE.NeedsCodecs = true
SERVICE.NeedsChromium = true
SERVICE.CacheLife = 0
SERVICE.ServiceJS = [[
    var embedPlayer;
    var targetTime = -0.5;
    var updateTimeNow = false;
    function th_volume(vol) {
        if (embedPlayer) {
            embedPlayer.volume = vol * 0.01;
        }
    }
    function th_seek(seconds) {
        targetTime = seconds - 0.5;
        updateTimeNow = true;
    }
    // Think
    setInterval(function() {
        targetTime += 0.1;
        if (embedPlayer) {
            if (embedPlayer.paused) {
                embedPlayer.play();
            }
            if (embedPlayer.duration > 0) {
                var maxOffset = 15;
                if (updateTimeNow || Math.abs(embedPlayer.currentTime - targetTime) > maxOffset) {
                    embedPlayer.currentTime = Math.max(0, targetTime);
                    updateTimeNow = false;
                }
            }
        } else {
            let player = document.querySelector('video');
            if (player) {
                embedPlayer = player;
                embedPlayer.style.width = window.innerWidth + 'px';
                embedPlayer.style.height = window.innerHeight + 'px';
                gmod.loaded();
            }
        }
    }, 100);
]]

function SERVICE:GetKey(url)
    if string.match(url.encoded, "https://www.wcofun.net/([%w%-]+)episode([%w%-]+)$") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        local videoInfo = {}

        EmbeddedCheckCodecs(function()
            if vpanel then
                vpanel:Remove()
            end

            vpanel = vgui.Create("DHTML", nil, "WCOPanel")
            vpanel:SetSize(ScrW(), ScrH())
            vpanel:SetAlpha(0)
            vpanel:SetMouseInputEnabled(false)
            vpanel:SetKeyboardInputEnabled(false)
            vpanel:OpenURL(key)

            timer.Simple(20, function()
                if IsValid(vpanel) then
                    vpanel:Remove()
                    chat.AddText("WCO request failed")
                    callback()
                end
            end)

            function vpanel:OnDocumentReady(url)
                self:AddFunction("gmod", "onVideoInfoReady", function(newVideoInfo)
                    table.Merge(videoInfo, newVideoInfo)

                    if videoInfo.title and videoInfo.duration then
                        callback(videoInfo)
                        self:Remove()
                    end
                end)

                self:AddFunction("gmod", "loaded", function() end)

                if url == key then
                    self:QueueJavascript([[
                        const title = document.querySelector("span.episode-descp").querySelector("span").textContent;
                        const embedUrl = document.querySelector('#cizgi-js-0').src;
                        gmod.onVideoInfoReady({"title": title});
                        window.location.href = embedUrl;
                    ]])
                elseif string.match(url, "embed") then
                    self:QueueJavascript([[
                        const initInterval = setInterval(function() {
                            const player = document.querySelector("video");
                            if (player && player.readyState > 0) {
                                player.volume = 0;
                                const duration = player.duration;
                                gmod.onVideoInfoReady({"duration": duration});
                                clearInterval(initInterval);
                            }
                        }, 100);
                    ]])
                    self:QueueJavascript(SERVICE.ServiceJS)
                end
            end
        end, function()
            chat.AddText("You need codecs to request this. Press F2.")

            return callback()
        end)
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL(Video:Key())

        panel.OnDocumentReady = function(_, url)
            if url == Video:Key() then
                panel:QueueJavascript([[
                    const embedUrl = document.querySelector('#cizgi-js-0').src;
                    window.location.href = embedUrl;
                ]])
            elseif string.match(url, "embed") then
                panel:AddFunction("gmod", "loaded", function()
                    self:SeekTo(CurTime() - Video:StartTime(), panel)
                    self:SetVolume(theater.GetVolume(), panel)
                end)

                panel:QueueJavascript(theater.TheaterJS)
                panel:QueueJavascript(self.ServiceJS)
                -- Hide overflow to get rid of scrollbar
                panel:QueueJavascript("document.body.style.overflow = 'hidden';")
            end
        end
    end
end

theater.RegisterService('wco', SERVICE)
