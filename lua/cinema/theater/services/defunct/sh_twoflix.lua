-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "2Flix"
SERVICE.NeedsCodecs = true
SERVICE.NeedsChromium = true
SERVICE.CacheLife = 0
SERVICE.RequestBrowserJS = [[
    // This is needed because clicking on a specific Episode doesn't update the URL
    const urlUpdatePatch = setInterval(function() {
        const activeEpisodeElem = document.querySelector("a.btn.active[data-slug]");

        if (window.location.href != activeEpisodeElem.href) {
            window.history.replaceState(null, "", activeEpisodeElem.href);
        }
    }, 100);
]]
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

    let serverSwitchTime = 0;
    let serverIndex = -1;

    // This interval will try to play the video and find the video player from each server until a timeout is reached.
    const findPlayerInterval = setInterval(function() {
        let servers = [...document.querySelectorAll(".server")];
        let timeSinceLastServerSwitch = Date.now() - serverSwitchTime;
        let serversAvailable = servers && servers.length > 0;

        // Every 3 seconds, switch servers
        if (serversAvailable && (serverIndex == -1 || timeSinceLastServerSwitch >= 3000)) {
            if (serverIndex >= servers.length - 1) {
                clearInterval(findPlayerInterval); // We've tried all the servers
                return;
            }
            servers[++serverIndex].click();
            serverSwitchTime = Date.now();
        }

        let playButton = document.querySelector('.playnow-btn');
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
    }, 500);
]]

function SERVICE:GetKey(url)
    if url.host ~= "2flix.to" then return false end
    if not url.path then return false end
    if string.match(url.path, "/movie/([%w%-]+/%d+%-%d+)") or string.match(url.path, "/tv/([%w%-]+/%d+%-%d+)") then return url.encoded end
    if string.match(url.path, "/movie/([%w%-/]+)") or string.match(url.path, "/tv/([%w%-/]+)") then return url.encoded, true end -- Partial match, only used to allow RequestBrowserJS to run

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        local videoInfo = {}

        EmbeddedCheckCodecs(function()
            if vpanel then
                vpanel:Remove()
            end

            vpanel = vgui.Create("DHTML", nil, "2FlixPanel")
            vpanel:SetSize(ScrW(), ScrH())
            vpanel:SetAlpha(0)
            vpanel:SetMouseInputEnabled(false)
            vpanel:SetKeyboardInputEnabled(false)
            vpanel:OpenURL(key)

            timer.Simple(20, function()
                if IsValid(vpanel) then
                    vpanel:Remove()
                    chat.AddText("2Flix request failed")
                    callback()
                end
            end)

            function vpanel:OnDocumentReady(url)
                self:AddFunction("gmod", "onVideoInfoReady", function(newVideoInfo)
                    table.Merge(videoInfo, newVideoInfo)

                    if videoInfo.title and videoInfo.duration and videoInfo.thumb then
                        callback(videoInfo)
                        self:Remove()
                    end
                end)

                if url == key then
                    self:QueueJavascript(find_player_iframe_js)
                    self:QueueJavascript([[
                        const initInterval = setInterval(function() {
                            if (playerIframe && playerIframe.src) {
                                const thumb = document.querySelector('img[itemprop="image"]').src;
                                const activeEpisodeElem = document.querySelector("a.btn.active[data-slug]");
                                const activeEpisodeElemVisible = activeEpisodeElem.offsetParent != null;

                                var title = document.querySelector('h1[itemprop="name"]').textContent; // Movie / TV Show

                                if (activeEpisodeElemVisible) {
                                    title += " " + document.querySelector("a.season-item.active").innerText.trim(); // Season
                                    title += " " + activeEpisodeElem.innerText.split("\n")[0].trim(); // Episode
                                }

                                gmod.onVideoInfoReady({
                                    "thumb": thumb,
                                    "title": title
                                });

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
                                gmod.onVideoInfoReady({"duration": player.duration});
                                clearInterval(initInterval);
                            }
                        }, 100);
                    ]])
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

theater.RegisterService("twoflix", SERVICE)
