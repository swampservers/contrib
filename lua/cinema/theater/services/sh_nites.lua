-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "Nites"
SERVICE.NeedsCodecs = true
SERVICE.NeedsChromium = true
SERVICE.CacheLife = 0
SERVICE.ServiceJS = [[
    var nitesPlayer;
    var targetTime = -0.5;
    var updateTimeNow = false;
    function th_volume(vol) {
        if (nitesPlayer) {
            nitesPlayer.volume = vol * 0.01;
        }
    }
    function th_seek(seconds) {
        targetTime = seconds - 0.5;
        updateTimeNow = true;
    }
    // Think
    setInterval(function() {
        targetTime += 0.1;
        if (nitesPlayer) {
            if (nitesPlayer.paused) {
                nitesPlayer.play();
            }
            if (nitesPlayer.duration > 0) {
                var maxOffset = 15;
                if (updateTimeNow || Math.abs(nitesPlayer.currentTime - targetTime) > maxOffset) {
                    nitesPlayer.currentTime = Math.max(0, targetTime);
                    updateTimeNow = false;
                }
            }
        } else {
            let player = document.querySelector('video');
            if (player) {
                nitesPlayer = player;
                gmod.loaded();
            }
        }
    }, 100);
]]

function SERVICE:GetKey(url)
    if string.match(url.encoded, "https://w1.nites.is/movies/([%w%-]+)/?$") or string.match(url.encoded, "https://w1.nites.is/episode/([%w%-]+)/?$") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        local videoInfo = {}

        EmbeddedCheckCodecs(function()
            if vpanel then
                vpanel:Remove()
            end

            vpanel = vgui.Create("DHTML", nil, "NitesPanel")
            vpanel:SetSize(ScrW(), ScrH())
            vpanel:SetAlpha(0)
            vpanel:SetMouseInputEnabled(false)
            vpanel:SetKeyboardInputEnabled(false)
            vpanel:OpenURL(key)

            timer.Simple(20, function()
                if IsValid(vpanel) then
                    vpanel:Remove()
                    print("Nites request failed")
                    callback()
                end
            end)

            function vpanel:OnDocumentReady(url)
                self:AddFunction("exTheater", "onVideoInfoReady", function(newVideoInfo)
                    table.Merge(videoInfo, newVideoInfo)

                    if videoInfo.title and videoInfo.data and videoInfo.duration and videoInfo.thumb then
                        callback(videoInfo)
                        self:Remove()
                    end
                end)

                -- The main video page
                if url == key then
                    self:QueueJavascript([[
                        const title = document.querySelector('h1[itemprop="name"]').textContent;
                        const thumbnailUrl = document.querySelector('[itemprop=thumbnailUrl]').content;
                        exTheater.onVideoInfoReady({
                            "title": title,
                            "thumb": thumbnailUrl,
                        });
                        // Go to first embed
                        const embedUrl = document.querySelector('[itemprop=embedUrl]').href;
                        window.location.href = embedUrl;
                    ]])
                    -- First embed
                elseif string.match(url, "trembed") then
                    self:QueueJavascript([[
                        const initInterval = setInterval(function() {
                            let iframe = document.querySelector("iframe");
                            if (iframe && iframe.src && iframe.src.includes("/player/v/")) {
                                // Go to second embed
                                window.location.href = iframe.src;
                                exTheater.onVideoInfoReady({"data": iframe.src});
                                clearInterval(initInterval);
                            }
                        }, 100);
                    ]])
                elseif string.match(url, "/player/v/") then
                    -- Second embed (the actual player)
                    self:QueueJavascript([[
                        const initInterval = setInterval(function() {
                            const player = document.querySelector("video");
                            if (player && player.readyState > 0) {
                                player.volume = 0;
                                exTheater.onVideoInfoReady({"duration": player.duration});
                                clearInterval(initInterval);
                            }
                        }, 100);
                    ]])
                    self:QueueJavascript(SERVICE.ServiceJS)
                end
            end
        end)
    end

    function SERVICE:LoadVideo(Video, panel)
        if Video:Data() ~= "" then
            panel:EnsureURL(Video:Data())

            panel.OnDocumentReady = function(_, url)
                if string.match(url, "/player/v/") then
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
end

theater.RegisterService('nites', SERVICE)
