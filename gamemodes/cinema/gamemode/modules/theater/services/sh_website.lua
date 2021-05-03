-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local SERVICE = {}
SERVICE.Name = "Website"
SERVICE.CacheLife = 0
SERVICE.LivestreamCacheLife = 0

local ALLOWED_WEBSITES = {
    ["americafirst.live"] = true,
}

function SERVICE:GetKey(url)
    if ALLOWED_WEBSITES[url.host or ""] then return url.encoded end

    return false
end

function SERVICE:GetVideoInfo(key, ply, onSuccess, onFailure)
    onSuccess({
        title = key,
        duration = 0
    })
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        error("Can't get video info for " .. self:GetClass())
    end

    -- whitelist above
    -- function SERVICE:ShouldTrust(Video)
    --     return TRUSTED_VIDEO_HOST(Video:Key())
    -- end
    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL(Video:Key())
    end

    function SERVICE:SetVolume(vol, panel)
        -- TODO: maybe iterate all <video> or <sound> elements and set their volume?
    end

    function SERVICE:SeekTo(time, panel)
        -- This service won't support seeking
    end
end

theater.RegisterService("website", SERVICE)