-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "Yugen"
SERVICE.NeedsCodecs = true
SERVICE.CacheLife = 0
SERVICE.ServiceJS = [[
    const plyrInterval = setInterval(function() {
        var videoElem = Array.from(document.querySelectorAll("video")).sort((a, b) => a.duration < b.duration).find(vid => !isNaN(vid.duration));

        if (typeof(videoElem) != "undefined") {
            var tempPlayer = videoElem.plyr;
            tempPlayer.play();
            tempPlayer.fullscreen.enter();

            player = videoElem;
            player_ready = true;
            gmod.loaded();

            if (typeof(player) != "undefined") {
                clearInterval(plyrInterval);
            }
        }
    }, 100);
]]

function SERVICE:GetKey(url)
    return string.match(url.host, "yugenanime%.tv") and url.path and string.match(url.path, "^/watch/(%d+/[%w%-_]+/%d+/)") and url.encoded
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        local videoInfo = {}

        EmbeddedCheckCodecs(function()
            if vpanel then
                vpanel:Remove()
            end

            vpanel = vgui.Create("DHTML", nil, "YugenVPanel")
            vpanel:SetSize(ScrW(), ScrH())
            vpanel:SetAlpha(0)
            vpanel:SetMouseInputEnabled(false)
            vpanel:SetKeyboardInputEnabled(false)
            vpanel:OpenURL(key)

            function vpanel:OnDocumentReady(url)
                self:AddFunction("gmod", "onVideoInfoReady", function(newVideoInfo)
                    if newVideoInfo.error then
                        chat.AddText("[red]Yugen Error: " .. newVideoInfo.error)
                        callback()

                        return
                    end

                    table.Merge(videoInfo, newVideoInfo)

                    if videoInfo.title and videoInfo.data and videoInfo.duration and videoInfo.thumb then
                        callback(videoInfo)
                        self:Remove()
                    end
                end)

                if url == key then
                    self:QueueJavascript([[
                        gmod.onVideoInfoReady({
                            "title": document.title.replace(" - YugenAnime", ""),
                            "thumb": document.querySelector("meta[property='og:image']").content,
                            "data": document.querySelector("iframe#main-embed").src
                        });

                        window.location.href = document.querySelector("iframe#main-embed").src;
                    ]])
                else
                    self:QueueJavascript([[
                        const initInterval = setInterval(function() {
                            const player = document.querySelector("video");
                            if (player != null && player.readyState > 0) {
                                gmod.onVideoInfoReady({"duration": player.duration});
                                clearInterval(initInterval);
                            }
                        }, 100);
                    ]])
                end
            end
        end)
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL(Video:Key())
        panel:QueueJavascript(string.format("window.location.href = '%s';", string.JavascriptSafe(Video:Data())))

        panel.OnDocumentReady = function(_, url)
            if url == Video:Data() then
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

theater.RegisterService("yugen", SERVICE)
