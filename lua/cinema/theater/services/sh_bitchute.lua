-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "Bitchute"
SERVICE.NeedsCodecs = true
SERVICE.NeedsChromium = true

-- The key is the video ID
function SERVICE:GetKey(url)
    local match = string.match(url.path, "/.+/(.+[^/])")
    if match ~= nil and string.find(url.encoded, "bitchute.com/video/(.+)") and not string.find(url.path, "%.") then return match end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        local video_info = {}

        EmbeddedCheckCodecs(function()
            if vpanel then
                vpanel:Remove()
            end

            vpanel = vgui.Create("DHTML", nil, "BitchutePanel")
            vpanel:SetSize(500, 500)
            vpanel:SetAlpha(0)
            vpanel:SetMouseInputEnabled(false)
            vpanel:SetKeyboardInputEnabled(false)
            vpanel:OpenURL("https://www.bitchute.com/embed/" .. key)

            timer.Simple(20, function()
                if IsValid(vpanel) then
                    vpanel:Remove()
                    chat.AddText("Bitchute request failed")
                    callback()
                end
            end)

            function vpanel:OnDocumentReady(url)
                self:AddFunction("gmod", "onVideoInfoReady", function(new_video_info)
                    table.Merge(video_info, new_video_info)

                    -- 'data' is the backing media URL (.mp4)
                    if video_info.title and video_info.data and video_info.duration and video_info.thumb then
                        callback(video_info)
                        self:Remove()
                    end
                end)

                self:QueueJavascript([[
                    const initInterval = setInterval(function() {
                        let playButton = document.querySelector(".vjs-big-play-button");
                        if (playButton) {
                            playButton.click();
                        }
                        const player = document.querySelector("video");
                        if (player && player.readyState > 0) {
                            player.volume = 0;
                            gmod.onVideoInfoReady({"duration": player.duration});
                            clearInterval(initInterval);
                        }
                    }, 100);
                    gmod.onVideoInfoReady({
                        "title": video_name, // Bitchute embed provides video_name var
                        "data": media_url, // Bitchute embed provides media_url var
                        "thumb": thumbnail_url // Bitchute embed provides thumbnail_url var
                    });
                ]])
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
end

theater.RegisterService('bitchute', SERVICE)
