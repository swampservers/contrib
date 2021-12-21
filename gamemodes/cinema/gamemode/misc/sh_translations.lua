-- This file is subject to copyright - contact swampservers@gmail.com for more information.
ColDefault = Color(200, 200, 200)
ColHighlight = Color(158, 37, 33)
local LANG = {}
translations = {}
local Languages = {}
local DefaultId = "en"

function T(key, ...)
    if not key then return "" end
    ErrorNoHaltWithStack("T CALL")

    return string.format(LANG[key] or key, ...)
end

local patterns = {
    format = "{{%s:%s}}",
    tag = "{{.-}}",
    data = "{{(.-):(.-)}}",
    rgb = "(%d+),(%d+),(%d+)"
}

local function buildTag(name, data)
    return string.format(patterns.format, name, data)
end

local function parseTag(tag)
    local key, value = string.match(tag, patterns.data)

    if key == 'rgb' then
        local r, g, b = string.match(value, patterns.rgb)

        return Color(r, g, b)
    end

    return tag
end

function translations.FormatChat(key, ...)
    local value = T(key, ...)

    -- Parse tags
    if string.find(value, patterns.tag) then
        local tbl = {}

        while true do
            -- Find first tag occurance
            local start, stop = string.find(value, patterns.tag)

            -- Break loop if there are no more tags
            if not start then
                -- Insert remaining fragment of translation
                if value ~= "" then
                    table.insert(tbl, value)
                end

                break
            end

            -- Insert beginning fragment of translation
            if start > 0 then
                local str = value:sub(0, start - 1)
                table.insert(tbl, str)
            end

            -- Extract tag
            local tag = value:sub(start, stop)
            -- Parse and insert tag object
            table.insert(tbl, parseTag(tag))
            -- Reduce translation string past tag
            value = value:sub(stop + 1, string.len(value))
        end

        value = tbl
    end

    return istable(value) and value or {value}
end

local function C(...)
    local str = ""

    for _, v in pairs({...}) do
        -- Serialize color
        if istable(v) and v.r and v.g and v.b then
            local col = string.format("%d,%d,%d", v.r, v.g, v.b)
            str = str .. buildTag('rgb', col)
        else
            str = str .. tostring(v)
        end
    end

    return str
end

LANG.Name = "English"
LANG.Id = "en"
LANG.Author = ""
LANG.Cinema = "CINEMA"
LANG.Volume = "Volume"
LANG.Voteskips = "Voteskips"
LANG.Loading = "Loading..."
LANG.Invalid = "[INVALID]"
LANG.NoVideoPlaying = "No video playing"
LANG.Cancel = "Cancel"
LANG.Set = "Set"
LANG.Theater_VideoRequestedBy = C("Current video requested by ", ColHighlight, "%s", ColDefault, ".")
LANG.Theater_InvalidRequest = "Invalid video request."
LANG.Theater_AlreadyQueued = "The requested video is already in the queue."
LANG.Theater_ProcessingRequest = C("Processing ", ColHighlight, "%s", ColDefault, " request...")
LANG.Theater_RequestFailed = "There was a problem processing the requested video."
LANG.Theater_Voteskipped = "The current video has been voteskipped."
LANG.Theater_ForceSkipped = C(ColHighlight, "%s", ColDefault, " has forced to skip the current video.")
LANG.Theater_ForceSeeked = C(ColHighlight, "%s", ColDefault, " has seeked current video.")
LANG.Theater_PlayerReset = C(ColHighlight, "%s", ColDefault, " has reset the theater.")
LANG.Theater_LostOwnership = "You have lost theater ownership due to leaving the theater."
LANG.Theater_NotifyOwnership = "You're now the owner of the private theater."
LANG.Theater_OwnerLockedQueue = "The owner of the theater has locked the queue."
LANG.Theater_LockedQueue = C(ColHighlight, "%s", ColDefault, " has locked the theater queue.")
LANG.Theater_UnlockedQueue = C(ColHighlight, "%s", ColDefault, " has unlocked the theater queue.")
LANG.Theater_OwnerUseOnly = "Only the theater owner can use that."
LANG.Theater_PublicVideoLength = "Public theater requests are limited to %s second(s) in length."
LANG.Theater_PlayerVoteSkipped = C(ColHighlight, "%s", ColDefault, " has voted to skip ", ColHighlight, "(%s/%s)", ColDefault, ".")
LANG.Theater_VideoAddedToQueue = C(ColHighlight, "%s", ColDefault, " has been added to the queue.")
LANG.Warning_Unsupported_Line1 = "The current map is unsupported by the Cinema gamemode"
LANG.Warning_Unsupported_Line2 = "Press F1 to open the official map on workshop"
LANG.Warning_OSX_Line1 = "Mac OS X users may experience blank screens in Cinema"
LANG.Warning_OSX_Line2 = "Press F1 to view troubleshooting tips and to remove this message"
LANG.Queue_Title = "QUEUE"
LANG.Request_Video = "Request Video"
LANG.Vote_Skip = "Vote Skip"
LANG.Toggle_Fullscreen = "Toggle Fullscreen"
LANG.Refresh_Theater = "Refresh Theater"
LANG.Theater_Admin = "ADMIN"
LANG.Theater_Owner = "OWNER"
LANG.Theater_Skip = "Skip"
LANG.Theater_Seek = "Seek"
LANG.Theater_Reset = "Reset"
LANG.Theater_ChangeName = "Change Name"
LANG.Theater_QueueLock = "Toggle Queue Lock"
LANG.Theater_SeekQuery = "HH:MM:SS or number of seconds (e.g. 1:30:00 or 5400)"
LANG.TheaterList_NowShowing = "NOW SHOWING"
LANG.Request_History = "HISTORY"
LANG.Request_Clear = "Clear"
LANG.Request_DeleteTooltip = "Remove video from history"
LANG.Request_PlayCount = "%d request(s)" -- e.g. 10 request(s)
LANG.Request_Url = "Request URL"
LANG.Request_Url_Tooltip = "Press to request a valid video URL.\nThe button will be red when the URL is valid"
LANG.Settings_Title = "SETTINGS"
LANG.Settings_ClickActivate = "CLICK TO ACTIVATE YOUR MOUSE"
LANG.Settings_VolumeLabel = "Volume"
LANG.Settings_VolumeTooltip = "Use the +/- keys to increase/decrease volume."
LANG.Settings_HDLabel = "HD Video Playback"
LANG.Settings_HDTooltip = "Enable HD video playback for HD enabled videos."
LANG.Settings_HidePlayersLabel = "Hide Players In Theater"
LANG.Settings_HidePlayersTooltip = "Reduce player visibility inside of theaters."
LANG.Settings_MuteFocusLabel = "Mute audio while alt-tabbed"
LANG.Settings_MuteFocusTooltip = "Mute theater volume while Garry's Mod is out-of-focus (e.g. you alt-tabbed)."
LANG.Service_EmbedDisabled = "The requested video is embed disabled."
LANG.Service_PurchasableContent = "The requested video is purchasable content and can't be played."
LANG.Service_StreamOffline = "The requested stream is offline."
LANG.ActCommand = C(ColHighlight, "%s", ColDefault, " %s") -- e.g. Sam dances
