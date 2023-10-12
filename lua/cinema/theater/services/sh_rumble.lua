-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "Rumble"
SERVICE.NeedsCodecs = true
SERVICE.NeedsChromium = true

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
                self:AddFunction("gmod", "onVideoInfoReady", function(newVideoInfo)
                    table.Merge(videoInfo, newVideoInfo)

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

                        const videoInfo = {
                            "title": videoTitle,
                            "data": embedUrl,
                            "duration": durationSeconds,
                            "thumb": thumbnailUrl
                        };

                        gmod.onVideoInfoReady(videoInfo);
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
        panel:EnsureURL(Video:Data())

        panel:AddFunction("gmod", "loaded", function()
            self:SetVolume(theater.GetVolume(), panel)
        end)

        panel:QueueJavascript("document.querySelector('.bigPlayUI.ctp').click();")
        panel:QueueJavascript([[
            const initInterval = setInterval(function() {
                document.querySelectorAll('audio, video').forEach(element => {
                    element.volume = 0;
                    if (element.readyState > 0) {
                        gmod.loaded();
                        clearInterval(initInterval);
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

theater.RegisterService('rumble', SERVICE)
