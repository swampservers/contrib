-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "File"
SERVICE.Mature = true
SERVICE.NeedsCodecs = true
SERVICE.CacheLife = 0
SERVICE.LivestreamCacheLife = 0

function SERVICE:GetKey(url)
    if url.scheme == "rtmp" then return url.encoded end

    if string.sub(url.path, -4) == ".mp4" then
        if string.match(url.host, "dropbox.com") then return "https://www.dropbox.com" .. url.path .. "?dl=0" end

        return url.encoded
    end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        local videoInfo = {}
        local isDropbox = string.StartWith(key, "https://www.dropbox.com")

        if Me.videoDebug and isDropbox then
            print("Dropbox Failsafe Activated")
        end

        EmbeddedCheckCodecs(function()
            if vpanel then
                vpanel:Remove()
            end

            vpanel = vgui.Create("DHTML", nil, "FileVPanel")
            vpanel:SetSize(100, 100)
            vpanel:SetAlpha(0)
            vpanel:SetMouseInputEnabled(false)

            timer.Simple(20, function()
                if IsValid(vpanel) then
                    vpanel:Remove()
                    print("Failed")
                    callback()
                end
            end)

            function vpanel:OnDocumentReady(url)
                self:AddFunction("exTheater", "onVideoInfoReady", function(newVideoInfo)
                    table.Merge(videoInfo, newVideoInfo)

                    if videoInfo.duration then
                        callback(videoInfo)

                        if videoInfo.duration > 0 then
                            callback(videoInfo)
                        else
                            Derma_StringRequest("RTMP Stream Title", "Name your livestream:", Me:Nick() .. "'s Stream", function(title)
                                callback({
                                    duration = duration,
                                    title = title
                                })
                            end, function()
                                callback()
                            end)
                        end

                        self:Remove()
                    end
                end)

                if not isDropbox then
                    self:QueueJavascript(string.format("th_video('%s');", string.JavascriptSafe(key)))
                end

                self:QueueJavascript([[
                    const initInterval = setInterval(function() {
                        var videoElem = Array.from(document.querySelectorAll("video")).sort((a, b) => a.duration < b.duration).find(vid => !isNaN(vid.duration));

                        if (typeof(videoElem) != "undefined") {
                            // Stop it from playing sound!
                            videoElem.volume = 0;
                            videoElem.muted = true;

                            if (videoElem.readyState > 0) {
                                exTheater.onVideoInfoReady({"duration": videoElem.duration});
                                clearInterval(initInterval);
                            }
                        }
                    }, 100);
                ]])
            end

            local urll = isDropbox and key or "https://swamp.sv/s/cinema/file.html"
            --if string.StartWith(key:lower(), "rtmp") then
            --	urll = "https://swamp.sv/s/cinema/filedatavjs.php?file="..key
            --end
            vpanel:OpenURL(urll)
        end, function()
            chat.AddText("You need codecs to request this. Press F2.")

            return callback()
        end)
    end

    function SERVICE:GetHost(Video)
        return url.parse2(Video:Key()).host
    end

    function SERVICE:LoadVideo(Video, panel)
        local isDropbox = string.StartWith(Video:Key(), "https://www.dropbox.com")
        panel:EnsureURL(isDropbox and Video:Key() or "https://swamp.sv/s/cinema/file.html")

        panel:AddFunction("gmod", "loaded", function()
            self:SeekTo(CurTime() - Video:StartTime(), panel)
            self:SetVolume(theater.GetVolume(), panel)
        end)

        if isDropbox then
            panel:QueueJavascript(theater.TheaterJS)
            panel:QueueJavascript([[
                const initInterval = setInterval(function() {
                    var videoElem = Array.from(document.querySelectorAll("video")).sort((a, b) => a.duration < b.duration).find(vid => !isNaN(vid.duration));

                    if (typeof(videoElem) != "undefined" && videoElem.readyState > 0) {
                        videoElem.play();

                        player = videoElem;
                        player_ready = true;
                        gmod.loaded();

                        document.body.appendChild(player);

                        var zIndexInterval = setInterval(function() {
                            for (var elem of document.body.getElementsByTagName("*")) {
                                if (elem != player) {
                                    elem.style.setProperty("z-index", "-1", "important");
                                }
                            }
                        }, 100);

                        player.controls = true;
                        player.style.backgroundColor = "#000";
                        player.style.width = "100vw";
                        player.style.height = "100vh";
                        player.style.position = "fixed";
                        player.style.top = "0px";
                        player.style.left = "0px";
                        player.style.setProperty("z-index", "1");
                        document.documentElement.style.overflow = "hidden";
                        document.body.style.overflow = "hidden";

                        clearInterval(initInterval);
                    }
                }, 100);
            ]])
        else
            panel:QueueJavascript([[
                th_video(']] .. string.JavascriptSafe(Video:Key()) .. [[');
                function checkLoaded() {
                    if (player.error().code === 4) {
                        // Try a CORS proxy
                        console.log("Trying CORS proxy");
                        th_video('https://p.micspam.com/]] .. string.JavascriptSafe(Video:Key()) .. [[');
                    }
                }
                setTimeout(checkLoaded, 5000);
            ]])
        end
    end
end

theater.RegisterService("file", SERVICE)
