-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "Bflix"
SERVICE.NeedsCodecs = true
SERVICE.NeedsChromium = true
SERVICE.ServiceJS = [[
    const plyrInterval = setInterval(function() {
        const video = document.querySelector('video');
        if (video && video.paused) {
            video.play();
            gmod.loaded();
        }
    }, 100);
]]

function SERVICE:GetKey(url)
    if string.match(url.encoded, "https://bflix.sx/watch%-%w-/.*%-%d+%.%d+$") then return url.encoded end
    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        local videoInfo = {}

        EmbeddedCheckCodecs(function()
            if vpanel then
                vpanel:Remove()
            end

            vpanel = vgui.Create("DHTML", nil, "BflixPanel")
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

                if url == key then
                    self:QueueJavascript([[
                        const initInterval = setInterval(function() {
                            let iframe = document.getElementById("iframe-embed");
                            if (iframe && iframe.src && iframe.src.includes("embed")) {
                                window.location.href = iframe.src;
                                exTheater.onVideoInfoReady({"data": iframe.src});
                                clearInterval(initInterval);
                            }
                        }, 100);

                        exTheater.onVideoInfoReady({
                            "title": document.querySelector("li[aria-current=\"page\"]").textContent.split(':')[0].replace(/\s+/g, ' ').trim(),
                            "thumb": document.querySelector("meta[property='og:image']").content
                        });
                    ]])
                else
                    self:QueueJavascript([[
                        const initInterval = setInterval(function() {
                            const player = document.querySelector("video");
                            if (player != null && player.readyState > 0) {
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
            if url == Video:Data() then
                panel:AddFunction("gmod", "loaded", function()
                    self:SeekTo(CurTime() - Video:StartTime(), panel)
                    self:SetVolume(theater.GetVolume(), panel)
                end)

                panel:QueueJavascript(theater.TheaterJS)
                panel:QueueJavascript(self.ServiceJS)
            else
                panel:QueueJavascript([[
                    const initInterval = setInterval(function() {
                        let iframe = document.getElementById("iframe-embed");
                        if (iframe && iframe.src && iframe.src.includes("embed")) {
                            window.location.href = iframe.src;
                            clearInterval(initInterval);
                        }
                    }, 100);
                ]])
            end
        end
    end 

    function SERVICE:SetVolume(vol, panel)
        panel:QueueJavascript([[
            document.querySelectorAll('video').forEach(element => {
                element.volume = ]] .. (vol * 0.01) .. [[;
            });
        ]])
    end

    function SERVICE:SeekTo(time, panel)
        panel:QueueJavascript([[
            document.querySelectorAll('video').forEach(element => {
                element.currentTime = ]] .. time .. [[;
            });
        ]])
    end
end

theater.RegisterService('bflix', SERVICE)
