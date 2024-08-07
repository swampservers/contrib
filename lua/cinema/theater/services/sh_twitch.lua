-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SERVICE = {}
SERVICE.Name = "Twitch"
SERVICE.NeedsCodecs = true
SERVICE.NeedsChromium = true
SERVICE.ServiceJS = [[
    // TODO(winter): Restore quality selection
    //var quality = window.innerHeight < 700 ? "medium" : "chunked";

    // Close the Muted Segments warning (if present)
    var mutedSegmentsButtonInterval = setInterval(function() {
        const mutedSegmentsButton = document.querySelector('[data-test-selector="muted-segments-alert-overlay-presentation__dismiss-button"]');
        if (mutedSegmentsButton != null) {
            mutedSegmentsButton.click();
            clearInterval(mutedSegmentsButtonInterval);
        }
    }, 10);

    const initInterval = setInterval(function() {
        const videoElem = document.querySelector("video");

        if (videoElem != null) {
            // Stop it from playing sound initially!
            videoElem.volume = 0;
            videoElem.muted = true;

            if (videoElem.readyState > 0) {
                videoElem.play();

                player = videoElem;
                player_ready = true;
                gmod.loaded();
                clearInterval(initInterval);
            }
        }
    }, 100);
]]

function SERVICE:GetKey(url)
    if not string.match(url.host, "twitch.tv") then return false end
    local key = url.host == "clips.twitch.tv" and string.match(url.path, "/(%w+)$") or string.match(url.path, "/clip/([%w%-]+)$") -- Clips
    local isclip = key ~= nil
    local isvod = false

    if not isclip then
        key = string.match(url.path, "^/videos/(%d+)") -- VODs
        isvod = key ~= nil

        if not isvod then
            key = string.match(url.path, "/([%w_%-]+)$") -- Streams
        end
    end

    if not key or string.len(key) < 1 then return false end

    return (isclip and "clips/" or isvod and "videos/" or "") .. key
end

if CLIENT then
    -- TODO(winter): Is this sort of thing standardized anywhere?
    function SERVICE:GetEmbedURLFromKey(key)
        local isvod = string.match(key, "videos/")
        local isclip = string.match(key, "clips/")

        return "https://" .. (isclip and "clips" or "player") .. ".twitch.tv/" .. (isclip and "embed" or "") .. "?parent=twitch.tv&" .. (isclip and "clip=" or isvod and "video=" or "channel=") .. ((isclip or isvod) and string.Explode("/", key)[2] or key)
    end

    function SERVICE:LoadVideo(Video, panel)
        local key = Video:Key()
        local islive = not string.match(key, "/")
        -- NOTE(winter): We aren't using https://swamp.sv/s/cinema/twitch.html anymore; can't support clips or close mature warnings with iframe embeds
        panel:EnsureURL(self:GetEmbedURLFromKey(key))

        panel.OnDocumentReady = function(_, url)
            panel:OnDocumentReadyBase(url)

            panel:AddFunction("gmod", "loaded", function()
                self:SetVolume(theater.GetVolume(), panel)

                if not islive then
                    self:SeekTo(CurTime() - Video:StartTime(), panel)
                end
            end)

            panel:QueueJavascript(theater.TheaterJS)
            panel:QueueJavascript(string.format("maxoffset = 5; islive = %s;", islive))
            panel:QueueJavascript(self.ServiceJS)
        end
        -- TODO: Hook into Swamp's mature warning system to close Twitch's (F8 or whatever)
    end
end

theater.RegisterService("twitch", SERVICE)
