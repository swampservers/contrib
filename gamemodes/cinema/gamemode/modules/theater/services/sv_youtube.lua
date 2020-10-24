-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

-- -- For porn stuff, so it's not popping up without a warning.
-- function YoutubeVideoIsAdult(info)
-- 	if string.find(info.title:lower(), "condom") then
-- 		return true
-- 	end
-- 	return false
-- end


sv_GetVideoInfo = sv_GetVideoInfo or {}

local function convertISO8601Time( duration )
	local a = {}

	for part in string.gmatch(duration, "%d+") do
	   table.insert(a, part)
	end

	if duration:find('M') and not (duration:find('H') or duration:find('S')) then
		a = {0, a[1], 0}
	end

	if duration:find('H') and not duration:find('M') then
		a = {a[1], 0, a[2]}
	end

	if duration:find('H') and not (duration:find('M') or duration:find('S')) then
		a = {a[1], 0, 0}
	end

	duration = 0

	if #a == 3 then
		duration = duration + tonumber(a[1]) * 3600
		duration = duration + tonumber(a[2]) * 60
		duration = duration + tonumber(a[3])
	end

	if #a == 2 then
		duration = duration + tonumber(a[1]) * 60
		duration = duration + tonumber(a[2])
	end

	if #a == 1 then
		duration = duration + tonumber(a[1])
	end

	return duration
end

sv_GetVideoInfo.youtube = function(self, key, ply, onSuccess, onFailure)

	local onReceive = function( body, length, headers, code )

		local resp = util.JSONToTable( body )

		if not resp then
			return onFailure( 'Theater_RequestFailed' )
		end

		if resp.error then
			return onFailure( 'Theater_RequestFailed' )
		end
		
		if table.Lookup( resp, 'pageInfo.totalResults', 0 ) <= 0 then
			return onFailure( 'Theater_RequestFailed' )
		end
		
		local item = resp.items[1]

		if not table.Lookup( item, 'status.embeddable' ) then
			return onFailure( 'Service_EmbedDisabled' )
		end

		local info = {}
		info.title = table.Lookup( item, 'snippet.title' )

		if ( table.Lookup( item, 'snippet.liveBroadcastContent' ) ~= 'none' ) then
			info.duration = 0
		else
			local durStr = table.Lookup( item, 'contentDetails.duration', '' )
			info.duration = math.max(1, convertISO8601Time( durStr ))
		end

		if table.Lookup(item, "status.privacyStatus") == "unlisted" or table.Lookup(item, "contentDetails.contentRating.ytRating") == "ytAgeRestricted" then
			info.data = "adult"
		else
			info.data = ""
			-- Medium Size doesn't have a letterbox
			info.thumb = table.Lookup( item, 'snippet.thumbnails.medium.url' )
		end

		onSuccess(info)
	end

	local url = YOUTUBE_METADATA_URL:format( key )
	self:Fetch( url, onReceive, onFailure ) 
end

function table.Lookup( tbl, key, default )
	local fragments = string.Split(key, '.')
	local value = tbl

	for _, fragment in ipairs(fragments) do
		value = value[fragment]

		if not value then
			return default
		end
	end

	return value
end
