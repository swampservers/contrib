-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "Infowars"
SERVICE.NeedsCodecs = true
SERVICE.NeedsChromium = true

-- All of these are basically just aliases for banned.video
local infowars_domains = {
    "banned.video",
    "conspiracyfact.info",
    "freeworldnews.tv",
    "madmaxworld.tv"
}

-- The key will either be a video ID or a channel name in the format channel:<name>
function SERVICE:GetKey(url)
    for _, v in pairs(infowars_domains) do
        if string.match(url.host or "", v) then
            local key = string.match(url.encoded or "", "/watch%?id=(%w+)$")
            if key then return key end -- was a video ID
            local key = string.match(url.encoded or "", "/channel/(%w+)$")
            if key then return "channel:" .. key end -- was a channel
        end
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

            vpanel = vgui.Create("DHTML", nil, "FileVPanel")
            vpanel:SetSize(100, 100)
            vpanel:SetAlpha(1)
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
                    self:Remove()
                end)

                self:QueueJavascript([[
                    setInterval(function() {
                        document.querySelectorAll('audio, video').forEach(element => {
                            element.volume = 0;
                        });
                    }, 100);

                    const videoPropsJson = document.getElementById('__NEXT_DATA__').textContent;
                    const videoPropsJsonObject = JSON.parse(videoPropsJson);

                    if ('channel' in videoPropsJsonObject.props.pageProps
                            && videoPropsJsonObject.props.pageProps.channel.isLive
                            && 'liveStreamVideo' in videoPropsJsonObject.props.pageProps.channel) {
                        const videoTitle = videoPropsJsonObject.props.pageProps.channel.title;
                        const streamUrl = videoPropsJsonObject.props.pageProps.channel.liveStreamVideo.streamUrl;
                        const durationSeconds = 0;
                        const thumbnailUrl = videoPropsJsonObject.props.pageProps.channel.coverImage;
    
                        const videoInfo = {
                            "title": videoTitle,
                            "data": streamUrl,
                            "duration": durationSeconds,
                            "thumb": thumbnailUrl
                        };

                        gmod.onVideoInfoReady(videoInfo);
                    } else if ('video' in videoPropsJsonObject.props.pageProps) {
                        const videoTitle = videoPropsJsonObject.props.pageProps.video.title;
                        const streamUrl = videoPropsJsonObject.props.pageProps.video.streamUrl;
                        const durationSeconds = parseInt(Math.ceil(videoPropsJsonObject.props.pageProps.video.videoDuration));
                        const thumbnailUrl = videoPropsJsonObject.props.pageProps.video.largeImage;
    
                        const videoInfo = {
                            "title": videoTitle,
                            "data": streamUrl,
                            "duration": durationSeconds,
                            "thumb": thumbnailUrl
                        };

                        gmod.onVideoInfoReady(videoInfo);
                    } else {
                        gmod.onVideoInfoReady({});
                    }
                ]])
            end

            if string.match(key, "channel") then
                vpanel:OpenURL("https://banned.video/channel/" .. string.match(key, "channel:(.+)"))
            else
                vpanel:OpenURL("https://banned.video/watch?id=".. key)
            end
        end, function()
            chat.AddText("You need codecs to request this. Press F2.")

            return callback()
        end)
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("https://swamp.sv/s/cinema/file.html")

        panel:AddFunction("gmod", "loaded", function()
            self:SeekTo(CurTime() - Video:StartTime(), panel)
            self:SetVolume(theater.GetVolume(), panel)
        end)

        panel:QueueJavascript(string.format("th_video('%s');", string.JavascriptSafe(Video:Data())))
    end

    function SERVICE:SetVolume(vol, panel)
        panel:QueueJavascript([[
            document.querySelectorAll('audio, video').forEach(element => {
                element.volume = ]] .. (vol * 0.01) .. [[;
            });
        ]])
    end
end

theater.RegisterService('infowars', SERVICE)
