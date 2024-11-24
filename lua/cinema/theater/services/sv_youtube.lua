-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- -- For porn stuff, so it's not popping up without a warning.
-- function YoutubeVideoIsAdult(info)
-- 	if string.find(info.title:lower(), "condom") then
-- 		return true
-- 	end
-- 	return false
-- end
sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.youtube = function(self, key, ply, onSuccess, onFailure)
    local onReceive = function(body, length, headers, code)
        local resp = util.JSONToTable(body)
        if not resp then return onFailure('Theater_RequestFailed') end
        if resp.error then return onFailure('Theater_RequestFailed') end
        if table.Lookup(resp, 'pageInfo.totalResults', 0) <= 0 then return onFailure('Theater_RequestFailed') end
        local item = resp.items[1]
        --if not table.Lookup(item, 'status.embeddable') then return onFailure('Service_EmbedDisabled') end
        local info = {}
        info.title = table.Lookup(item, 'snippet.title')

        if table.Lookup(item, 'snippet.liveBroadcastContent') ~= 'none' then
            info.duration = 0
        else
            local durStr = table.Lookup(item, 'contentDetails.duration', '')
            local hours = tonumber(string.match(durStr, "(%d+)[Hh]")) or 0
            local mins = tonumber(string.match(durStr, "(%d+)[Mm]")) or 0
            local secs = tonumber(string.match(durStr, "(%d+)[Ss]")) or 0
            info.duration = math.max(1, hours * 3600 + mins * 60 + secs)
        end

        if table.Lookup(item, "status.privacyStatus") == "unlisted" or table.Lookup(item, "contentDetails.contentRating.ytRating") == "ytAgeRestricted" then
            info.data = "adult"
        end

        -- No accountless workaround for age-restricted videos therefore allowing them to be queued is pointless https://github.com/yt-dlp/yt-dlp/issues/11296#issuecomment-2425188728
        if table.Lookup(item, "contentDetails.contentRating.ytRating") == "ytAgeRestricted" then
            return onFailure('This video is age-restricted and cannot be viewed.')
        end

        if not table.Lookup(item, "status.embeddable") then
            info.data = (info.data and "," or "") .. "noembed"
        end

        if not info.data then
            info.data = ""
            -- Medium Size doesn't have a letterbox
            info.thumb = table.Lookup(item, "snippet.thumbnails.medium.url")
        end

        onSuccess(info)
    end

    local url = YOUTUBE_METADATA_URL:format(key)
    self:Fetch(url, onReceive, onFailure)
end

function table.Lookup(tbl, key, default)
    local fragments = string.Split(key, '.')
    local value = tbl

    for _, fragment in ipairs(fragments) do
        value = value[fragment]
        if not value then return default end
    end

    return value
end
