-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "Rumble"
SERVICE.NeedsCodecs = true
SERVICE.NeedsChromium = true
SERVICE.ServiceJS = [[
    var rumblePlayer;
    var targetTime = -0.5;
    var updateTimeNow = false;
    var lastLiveClickTime = 0;
    function th_volume(vol) {
        if (rumblePlayer) {
            rumblePlayer.volume = vol * 0.01;
        }
    }
    function th_seek(seconds) {
        targetTime = seconds - 0.5;
        updateTimeNow = true;
    }
    // Think
    setInterval(function() {
        document.querySelector('.bigPlayUI')?.click();

        targetTime += 0.1;
        if (rumblePlayer) {
            if (rumblePlayer.paused) {
                rumblePlayer.play();
            }
            let liveButton = [...document.getElementsByTagName('span')].find(span => span.innerText === "● LIVE");
            if (liveButton) {
                targetTime = rumblePlayer.duration - 0.5;
            }

            var maxOffset = 15;
            if (updateTimeNow || Math.abs(rumblePlayer.currentTime - targetTime) > maxOffset) {
                rumblePlayer.currentTime = Math.max(0, targetTime);
                updateTimeNow = false;
            }
        } else {
            let player = document.querySelector('video');
            if (player) {
                rumblePlayer = player;
                gmod.loaded();
            }
        }
    }, 100);
]]

function SERVICE:GetKey(url)
    if string.match(url.host or "", "rumble.com") and string.match(url.path or "", "^/v%w%w%w%w%w%w%-(.+)%.html$") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        local videoInfo = {}

        EmbeddedCheckCodecs(function()
            if vpanel then
                vpanel:Remove()
            end

            vpanel = vgui.Create("DHTML", nil, "RumblePanel")
            vpanel:SetSize(500, 500)
            vpanel:SetAlpha(0)
            vpanel:SetMouseInputEnabled(false)
            vpanel:SetKeyboardInputEnabled(false)

            timer.Simple(20, function()
                if IsValid(vpanel) then
                    vpanel:Remove()
                    print("Rumble request failed")
                    callback()
                end
            end)

            function vpanel:OnDocumentReady(url)
                self:AddFunction("gmod", "onVideoInfoReady", function(newVideoInfo)
                    table.Merge(videoInfo, newVideoInfo)

                    -- 'data' is the embed video ID, different from the ID in the key
                    if videoInfo.title and videoInfo.data and videoInfo.duration and videoInfo.thumb then
                        callback(videoInfo)
                        self:Remove()
                    end
                end)

                if url == key then
                    self:QueueJavascript([[
                        function iso8601ToSeconds(duration) {
                            var match = duration.match(/^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$/);
                            var hours = (parseInt(match[1]) || 0);
                            var minutes = (parseInt(match[2]) || 0);
                            var seconds = (parseInt(match[3]) || 0);
                            return (hours * 3600) + (minutes * 60) + seconds;
                        }

                        const videoInfoJson = document.querySelector('script[type="application/ld+json"]').textContent;
                        const videoInfoJsonObject = JSON.parse(videoInfoJson);
                        const videoTitle = videoInfoJsonObject[0].name;
                        const thumbnailUrl = videoInfoJsonObject[0].thumbnailUrl;
                        const durationISO8601 = videoInfoJsonObject[0].duration;
                        const durationSeconds = iso8601ToSeconds(durationISO8601);
                        const embedUrl = videoInfoJsonObject[0].embedUrl;
                        const match = embedUrl.match("/embed\/([^\/?]+)/");
                        if (match) {
                            const embedId = match[1];
                            const videoInfo = {
                                "title": videoTitle,
                                "data": embedId,
                                "duration": durationSeconds,
                                "thumb": thumbnailUrl
                            };
                            gmod.onVideoInfoReady(videoInfo);
                        }
                    ]])
                end
            end

            vpanel:OpenURL(key)
        end, function()
            chat.AddText("You need codecs to request this. Press F2.")

            return callback()
        end)
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:SetHTML([[
            <html>
                <head>
                    <style>
                        html, body { margin: 0; padding: 0; height: 100%; width: 100%; background: black; }
                    </style>
                </head>
                <body>
                    <script>!function(r,u,m,b,l,e){r._Rumble=b,r[b]||(r[b]=function(){(r[b]._=r[b]._||[]).push(arguments);if(r[b]._.length==1){l=u.createElement(m),e=u.getElementsByTagName(m)[0],l.async=1,l.src="https://rumble.com/embedJS/u4"+(arguments[1].video?'.'+arguments[1].video:'')+"/?url="+encodeURIComponent(location.href)+"&args="+encodeURIComponent(JSON.stringify([].slice.apply(arguments))),e.parentNode.insertBefore(l,e)}})}(window, document, "script", "Rumble");</script>
                    <div id="rumblePlayer"></div>
                </body>
            </html>
        ]])
        panel:AddFunction("gmod", "loaded", function()
            if Video:Duration() > 0 then
                self:SeekTo(CurTime() - Video:StartTime(), panel)
            end
            self:SetVolume(theater.GetVolume(), panel)
        end)
        panel:QueueJavascript(theater.TheaterJS)
        panel:QueueJavascript(self.ServiceJS)
        panel:QueueJavascript("Rumble('play', {'video':'" .. Video:Data() .. "','div':'rumblePlayer', 'opts':['force_ga_load', 'noads', 'norumbleads']});")
        panel:QueueJavascript("document.body.style.overflow = 'hidden';")
    end
end

theater.RegisterService('rumble', SERVICE)
