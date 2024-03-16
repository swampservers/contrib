-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "Bflix"
SERVICE.NeedsCodecs = true
SERVICE.NeedsChromium = true
SERVICE.CacheLife = 0
SERVICE.ServiceJS = [[
    var bflixPlayer;
    var targetTime = -0.5;
    var updateTimeNow = false;
    function th_volume(vol) {
        if (bflixPlayer) {
            bflixPlayer.volume = vol * 0.01;
        }
    }
    function th_seek(seconds) {
        targetTime = seconds - 0.5;
        updateTimeNow = true;
    }
    // Think
    setInterval(function() {
        targetTime += 0.1;
        if (bflixPlayer) {
            if (bflixPlayer.paused) {
                bflixPlayer.play();
            }
            if (bflixPlayer.duration > 0) {
                var maxOffset = 15;
                if (updateTimeNow || Math.abs(bflixPlayer.currentTime - targetTime) > maxOffset) {
                    bflixPlayer.currentTime = Math.max(0, targetTime);
                    updateTimeNow = false;
                }
            }
        } else {
            let player = document.querySelector('video');
            if (player) {
                bflixPlayer = player;
                gmod.loaded();
            }
        }
    }, 100);
]]

function SERVICE:GetKey(url)
    if string.match(url.encoded, "https://w1.nites.is/movies/([%w%-]+)$")
        or string.match(url.encoded, "https://w1.nites.is/episode/([%w%-]+)$") then
        return url.encoded
    end
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
                    print("Bflix request failed")
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
                        const title = document.querySelector('body div#aa-wp div.bd.cont section.section.single div.rw aside.left.cl1 article.post.single div.dfxb div header.entry-header h1.entry-title').textContent;
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
                -- Second embed (the actual player)
                elseif string.match(url, "/player/v/") then
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

theater.RegisterService('bflix', SERVICE)
