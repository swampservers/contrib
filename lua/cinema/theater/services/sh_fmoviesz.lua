-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "Fmoviesz"
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
                gmod.loaded();
            }
        }
    }, 100);
]]
local find_player_iframe_js = [[
    var playerIframe;

    // Automatically find a good server
    let timeSinceLastServerSwitch = 0;
    let currentServerIndex = -1;

    const findPlayerInterval = setInterval(function() {
        if (currentServerIndex == -1 || timeSinceLastServerSwitch >= 2500) {
            const ulServers = document.querySelector('ul.servers');
            if (ulServers) {
                const liElements = ulServers.querySelectorAll('li');
                if (liElements) {
                    if (currentServerIndex < liElements.length - 1) {
                        liElements[++currentServerIndex].click();
                    } else {
                        currentServerIndex = 0;
                    }

                    timeSinceLastServerSwitch = 0;
                }
            }
        } else {
            timeSinceLastServerSwitch += 500;

            const playButton = document.querySelector('.btn-watchnow');
            if (playButton) {
                playButton.click();
            }
            const iframes = document.querySelectorAll('iframe');
            let tempPlayerIframe = null;
            iframes.forEach(iframe => {
                const allowAttributes = iframe.getAttribute('allow');
                if (allowAttributes && allowAttributes.includes('autoplay') && allowAttributes.includes('fullscreen')) {
                    tempPlayerIframe = iframe;
                }
            });
            if (tempPlayerIframe && tempPlayerIframe.src) {
                playerIframe = tempPlayerIframe;
                clearInterval(findPlayerInterval);
            }
        }
    }, 500);
]]

function SERVICE:GetKey(url)
    if string.match(url.encoded, "https://fmovies24.to/movie/([%w%-]+)/1%-1/?$") or string.match(url.encoded, "https://fmovies24.to/tv/([%w%-]+)/%d+%-%d+/?$") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        local videoInfo = {}

        EmbeddedCheckCodecs(function()
            if vpanel then
                vpanel:Remove()
            end

            vpanel = vgui.Create("DHTML", nil, "FmovieszPanel")
            vpanel:SetSize(ScrW(), ScrH())
            vpanel:SetAlpha(0)
            vpanel:SetMouseInputEnabled(false)
            vpanel:SetKeyboardInputEnabled(false)
            vpanel:OpenURL(key)

            timer.Simple(20, function()
                if IsValid(vpanel) then
                    vpanel:Remove()
                    print("Fmoviesz request failed")
                    callback()
                end
            end)

            function vpanel:OnDocumentReady(url)
                self:AddFunction("exTheater", "onVideoInfoReady", function(newVideoInfo)
                    table.Merge(videoInfo, newVideoInfo)

                    if videoInfo.title and videoInfo.duration and videoInfo.thumb then
                        callback(videoInfo)
                        self:Remove()
                    end
                end)

                if url == key then
                    self:QueueJavascript(find_player_iframe_js)
                    self:QueueJavascript([[
                        const title = document.querySelector('h1[itemprop="name"]').textContent;
                        const thumb = document.querySelector('img[itemprop="image"]').src;
                        exTheater.onVideoInfoReady({
                            "title": title,
                            "thumb": thumb
                        });
                        const initInterval = setInterval(function() {
                            if (playerIframe && playerIframe.src) {
                                window.location.href = playerIframe.src;
                                clearInterval(initInterval);
                            }
                        }, 100);
                    ]])
                else
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
        panel:EnsureURL(Video:Key())

        panel.OnDocumentReady = function(_, url)
            if url == Video:Key() then
                panel:QueueJavascript(find_player_iframe_js)
                panel:QueueJavascript([[
                    const initInterval = setInterval(function() {
                        if (playerIframe && playerIframe.src) {
                            window.location.href = playerIframe.src;
                            clearInterval(initInterval);
                        }
                    }, 100);
                ]])
            else
                panel:AddFunction("gmod", "loaded", function()
                    self:SeekTo(CurTime() - Video:StartTime(), panel)
                    self:SetVolume(theater.GetVolume(), panel)
                end)

                panel:QueueJavascript(theater.TheaterJS)
                panel:QueueJavascript(self.ServiceJS)
            end
        end
    end
end

theater.RegisterService('fmoviesz', SERVICE)
