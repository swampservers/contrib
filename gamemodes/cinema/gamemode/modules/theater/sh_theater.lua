-- This file is subject to copyright - contact swampservers@gmail.com for more information.

module( "theater", package.seeall )

THEATER = {}

function THEATER:Init( locId, info )

	local o = {}

	setmetatable( o, self )
	self.__index = self

	o.Id = locId -- Location ID
	o._Name = info.Name or "Theater"
	o._Flags = info.Flags or THEATER_NONE
	o._Pos = info.Pos or Vector(0,0,0)
	o._Ang = info.Ang or Angle(0,0,0)
	o._PermanentOwnerID = info.PermanentOwnerID
	o._DefaultAllowItems = info.AllowItems or false
	o._AllowItems = o._DefaultAllowItems

	o._Width = (info.Width or 128)
	o._Height = (info.Height or math.Round(o._Width * (9.0/16.0)))

	o._Video = nil

	if SERVER then
		
		-- Keep for resetting the theater
		o._OriginalName = o._Name

		o.Players = {}
		o.Playlist = {}

		if info.ThumbEnt then
			o:SetupThumbnailEntity( info.ThumbEnt )
		elseif info.ThumbInfo then
			o._ThumbInfo = info.ThumbInfo
			o:SetupThumbnailEntity()
		end

		o._Queue = {}
		o._NextId = 0

		o._SkipVotes = {}

		if o:IsPrivate() then
			o._QueueLocked = false
			o._Owner = nil
		end

		o:PlayDefault()

	end

	return o

end

function THEATER:Name()
	return self._Name
end

function THEATER:OriginalName()
	return self._OriginalName
end

function THEATER:GetLocation()
	return self.Id
end

function THEATER:GetFlags()
	return tonumber(self._Flags) or -1
end

function THEATER:GetPos()
	return self._Pos
end

function THEATER:GetAngles()
	return self._Ang
end

function THEATER:GetSize()
	return self._Width, self._Height
end

/*
	Attributes
*/
function THEATER:IsPrivate()
	return bit.band(self._Flags, THEATER_PRIVATE) == THEATER_PRIVATE
end

function THEATER:IsReplicated()
	return bit.band(self._Flags, THEATER_REPLICATED) == THEATER_REPLICATED
end

function THEATER:SetVideo(Video)

	self._Video = Video

	if SERVER then

		if Video then
			if self:VideoOwnerSteamID()~="" then
				sc.log(self:VideoOwnerName().." ("..self:VideoOwnerSteamID()..") played video: "..self:VideoTitle().." ("..self:VideoType().." / "..self:VideoKey()..") in "..self:OriginalName())
			end

			self._Video:SetStartTime(CurTime())
		end

		self:SyncThumbnail()

		self:SendVideo()

	end

end

function THEATER:IsPlaying()
	if self:IsPlayingDefault() then
		return false
	elseif self._Video:IsTimed() then
		return self:VideoCurrentTime() <= self:VideoDuration() + 1
	else
		return true -- Video not timed
	end
end

function THEATER:IsPlayingDefault()
	return self._Video == nil
end

function THEATER:VideoType()
	return self._Video and self._Video:Type() or ""
end

function THEATER:VideoKey()
	return self._Video and self._Video:Key() or ""
end

function THEATER:VideoData()
	return self._Video and self._Video:Data() or ""
end

function THEATER:VideoCurrentTime( clean )
	if clean then
		return math.Clamp(math.Round(CurTime() - self:VideoStartTime()), 0, self:VideoDuration())
	else
		return CurTime() - self:VideoStartTime()
	end
end

function THEATER:VideoDuration()
	return self._Video and self._Video:Duration() or 0
end

function THEATER:VideoTime()

	if !self:IsPlaying() or self:VideoDuration()==0 then
		return ""
	end

	return string.FormatSeconds(self:VideoCurrentTime(true)) .. " / " .. string.FormatSeconds(self:VideoDuration())

end

function THEATER:VideoTitle()
	return self._Video and self._Video:Title() or 'Nothing Playing'
end

function THEATER:VideoThumbnail()
	return self._Video and self._Video:Thumbnail() or ''
end

function THEATER:VideoStartTime()
	return self._Video and self._Video:StartTime() or 0
end

function THEATER:VideoOwnerName()
	return self._Video and self._Video:GetOwnerName() or 'Invalid'
end

function THEATER:VideoOwnerSteamID()
	return self._Video and self._Video:GetOwnerSteamID() or ''
end

/*
	Private Theater
*/
function THEATER:GetOwner()
	return self._Owner
end

function THEATER:Think()

	if self.NextThink and self.NextThink > CurTime() then
		return
	end

	if SERVER then

		if !self:IsPlaying() and (!self:IsPlayingDefault() or !self:IsQueueEmpty())  then
			self:NextVideo()
		end
--[[
	else

		if LocalPlayer():GetLocation() != self:GetLocation() then return end

		-- Synchronize clientside video playback
		if self:IsPlaying() and self._Video:IsTimed() and
			( !self.NextSync || self.NextSync < RealTime() ) then

			local time = self:VideoCurrentTime()
			local panel = ActivePanel
			if time > 5 and ValidPanel(panel) then

				local str = string.format(
					"if(window.theater) theater.sync(%s);", time )
				panel:Queu eJavascript( str )

				self.NextSync = RealTime() + 5

			end

		end]]

	end

	self.NextThink = CurTime() + 1

end

if SERVER then

	function THEATER:Reset()

		self._Name = self._OriginalName

		self:ClearQueue()
		self:ClearSkipVotes()
		self:SetupThumbnailEntity()

		if self:IsPrivate() then
			self._QueueLocked = false
			self._Owner = nil
		end

		self:PlayDefault()

	end

	/*
		Thumbnail Entity
	*/
	function THEATER:SetupThumbnailEntity( ent )

		if !IsValid( self._ThumbEnt ) then

			if IsValid( ent ) then
				self._ThumbEnt = ent
			elseif self._ThumbInfo then
				self._ThumbEnt = ents.Create( "theater_thumbnail" )
				self._ThumbEnt:SetPos( self._ThumbInfo.Pos )
				self._ThumbEnt:SetAngles( self._ThumbInfo.Ang )
				self._ThumbEnt:Spawn()
			else
				return
			end

		end

		self:SyncThumbnail()

	end

	function THEATER:SyncThumbnail()
		if !IsValid( self._ThumbEnt ) then return end

		self._ThumbEnt:SetTheaterName( self:Name() )
		self._ThumbEnt:SetTitle( self:VideoTitle() )
		self._ThumbEnt:SetThumbnail( self:VideoThumbnail() )
		self._ThumbEnt:SetService(self._Video and self._Video:Service().ClassName or "")
	end

	/*
		Video Playback
	*/
	function THEATER:PlayDefault()
		self:SetVideo()
	end

	function THEATER:NextVideo()

		self:ClearSkipVotes()

		if self:IsQueueEmpty() then

			self:PlayDefault()

		else

			local key
			local Video

			local curVotes, topVotes = 0, 0

			for k, vid in pairs(self._Queue) do
				curVotes = vid:GetNumVotes()

				if ( (not Video) or -- first index
					( curVotes > topVotes ) or -- more votes
					( (curVotes == topVotes) and (vid:RequestTime() < Video:RequestTime()) ) ) then -- earlier request
					Video = vid
					key = k
					topVotes = curVotes
				end
			end

			table.remove(self._Queue, key)

			self:SetVideo( Video )

			if Video:GetOwnerName() != "" then
				self:AnnounceToPlayers( {
					'Theater_VideoRequestedBy',
					Video:GetOwnerName()
				} )
			end

			hook.Run( "PostPlayVideo", Video, self )
			
		end

	end

	function THEATER:RequestVideo( ply, url, force )

		-- Prevent request spam
		if (ply.LastVideoRequest or 0) + 0.3 > CurTime() then
			return
		end
		ply.LastVideoRequest = CurTime()

		if self:IsPrivate() then

			-- Set new theater owner
			if !IsValid( self:GetOwner() ) then
				self:RequestOwner( ply )
			end

			-- Prevent requests from non-theater-owner if queue is locked
			if self:IsQueueLocked() and ply != self:GetOwner() then
				return self:AnnounceToPlayer( ply, 'Theater_OwnerLockedQueue' )
			end

		end

		local info = ExtractURLInfo( url )

		-- Invalid request data
		if !info then
			return self:AnnounceToPlayer( ply, 'Theater_InvalidRequest' )
		end

		-- Check for duplicate requests
		for _, vid in pairs(self:GetQueue()) do

			if vid:Type() == info.type and
				vid:Key() == info.key then

				-- Place vote for player
				vid:SetVote(ply, 1)

				self:AnnounceToPlayer( ply, 'Theater_AlreadyQueued' )

				return
			end
		end

		local count = 0
		for _, vid in pairs(self:GetQueue()) do
			if vid:GetOwner() == ply then
				count = count + 1
			end
		end

		if count >= 40 then
			ply:PrintMessage( HUD_PRINTTALK, "[red] You've queued too many videos in this theater!" )
			return
		end

		-- Create video object and check if the page is valid
		local vid = VIDEO:Init(info, ply)

		self:AnnounceToPlayer( ply, {
			'Theater_ProcessingRequest',
			vid:Service():GetName()
		} )

		vid:RequestInfo( function( success )

			if not IsValid(ply) then return end
		
			-- Check for duplicate requests again in the case it was requested again while processing
			for _, video in pairs(self:GetQueue()) do

				if video:Type() == vid:Type() and video:Key() == vid:Key() then

					-- Place vote for player
					video:SetVote(ply, 1)

					self:AnnounceToPlayer( ply, 'Theater_AlreadyQueued' )

					return
				end

			end
		
			-- Failed to grab video info, etc.
			if success~=true then
				self:AnnounceToPlayer( ply, (success==false) and 'Theater_RequestFailed' or tostring(success))
				return
			end

			-- Developers can decide whether or not the video should be queued
			if hook.Run( "PreVideoQueued", vid, self ) then return end

			-- Successful request, queue video
			self:QueueVideo( vid )

			-- Send video info to player who requested the video
			-- Used to store request history
			net.Start("PlayerVideoQueued")
				net.WriteString( url )
				net.WriteString( vid:Title() )
				net.WriteInt( vid:Duration(), 32 )
				net.WriteString( vid:Type() )
				net.WriteString( vid:Key() )
			net.Send(ply)

			self:CheckVoteSkip()

		end )

	end

	local hhmmss = "(%d+):(%d+):(%d+)"
	local mmss = "(%d+):(%d+)"
	function THEATER:Seek( seconds )

		if self:VideoDuration()==0 then return end

		-- Seconds isn't a number, check HH:MM:SS
		if !tonumber(seconds) then
			local hr, min, sec = string.match(seconds, hhmmss)

			-- Not in HH:MM:SS, try MM:SS
			if not hr then
			    min, sec = string.match(seconds, mmss)
			    if not min then return end -- Not in MM:SS, give up
			    hr = 0
			end

			seconds = tonumber(hr) * 3600 + 
				tonumber(min) * 60 +
				tonumber(sec)
		end

		-- Clamp video seek time between 0 and video duration
		seconds = math.Clamp(tonumber(seconds), 0, self:VideoDuration())

		-- Convert seek seconds to time after video start
		if self._Video then
			self._Video:SetStartTime(CurTime() - seconds)
		end

		net.Start("TheaterSeek")
			net.WriteFloat( self:VideoStartTime() )
		net.Send(self.Players)

	end

	function THEATER:SendVideo( ply )
		-- Remove player if they aren't valid
		if ply and !IsValid(ply) then
			self:RemovePlayer(ply)
			return
		end

		net.Start("TheaterVideo")

			if self:IsPlayingDefault() then
				net.WriteString("") -- empty type
			else
				net.WriteString( self:VideoType() )
				net.WriteString( self:VideoKey() )
				net.WriteString( self:VideoTitle() )
				net.WriteInt( self:VideoDuration(), 32 )
				net.WriteString( self:VideoData() )
				net.WriteFloat( self:VideoStartTime() )
				net.WriteString( self:VideoOwnerName() )
				net.WriteString( self:VideoOwnerSteamID() )
			end
			
		net.Send(ply or self.Players) -- sent to specific player if specified
	end

	/*
		Queue
	*/
	function THEATER:GetQueue()
		return self._Queue
	end

	function THEATER:ClearQueue()
		table.Empty(self._Queue)
	end

	function THEATER:IsQueueEmpty()
		return #(self._Queue) == 0
	end

	function THEATER:QueueVideo( video )
		video.id = self._NextId
		self._NextId = self._NextId + 1
		video.theaterId = self.Id
		table.insert(self._Queue, video)
	end

	function THEATER:VoteQueuedVideo( ply, id, value )

		if !IsValid(ply) or !id then return end

		for _, vid in pairs(self._Queue) do
			if vid.id == id then
				vid:SetVote(ply, value)
				break
			end
		end

	end

	function THEATER:RemoveQueuedVideo( ply, id )

		id = tonumber(id)
		if !IsValid(ply) or !id then return end

		for k, vid in pairs(self._Queue) do
			if vid.id == id then

				-- Remove video if player is video owner, theater owner, or an admin
				if (vid:GetOwner() == ply) or
					(self:GetOwner() == ply) or -- private theater
					(ply:StaffControlTheater()) then

					if vid:GetOwner() ~= ply then
						if IsValid(vid:GetOwner()) and (vid:GetOwner():GetLocation() == ply:GetLocation()) then
							vid:GetOwner():ChatPrint("[red]"..ply:Nick().." unqueued \""..vid:Title().."\"")
						end
					end

					table.remove(self._Queue, k)

				end

				break

			end
		end

	end

	/*
		Vote Skip
	*/
	function THEATER:SkipVideo()
		self:NextVideo()
	end

	function THEATER:NumVoteSkips()
		return table.Count(self._SkipVotes)
	end

	function THEATER:NumRequiredVoteSkips()

		local ratio = 0.55

		if self._Name=="Movie Theater" then ratio=0.7 end

		local numply = self:NumPlayers()
		if numply < 2 then
			return 1
		else
			return math.max(2, math.Round( self:NumPlayers() * ratio ))
		end

	end

	function THEATER:ClearSkipVotes()
		if !self._SkipVotes then return end
		table.Empty(self._SkipVotes)
	end

	function THEATER:ValidateSkipVotes()
		for k, ply in pairs(self._SkipVotes) do
			if !IsValid(ply) then
				table.remove(self._SkipVotes, k)
			end
		end
	end

	function THEATER:HasPlayerVotedToSkip( ply )
		return table.HasValue(self._SkipVotes, ply)
	end

	function THEATER:VoteSkip( ply )
	
		-- Can't vote skip if the queue is locked
		if self:IsQueueLocked() then return end

		-- Can't vote skip if a video isn't playing
		if !self:IsPlaying() then return end

		-- Validate vote skips before checking them
		self:ValidateSkipVotes()

		-- Ensure the player hasn't already voted
		if self:HasPlayerVotedToSkip(ply) then return end
		
		-- Give hooks a chance to deny the voteskip
		if hook.Run("PreVoteSkipAccept", ply, self) then return end

		-- Insert player into list of vote skips
		table.insert(self._SkipVotes, ply)

		-- Notify theater players of vote skip
		net.Start( "TheaterVoteSkips" )
			net.WriteString( ply:Nick() )
			net.WriteInt( self:NumVoteSkips(), 7 ) -- 128 max players
			net.WriteInt( self:NumRequiredVoteSkips(), 7 )
		net.Send( self.Players )

		-- Check if the current video can be skipped
		self:CheckVoteSkip()

	end

	function THEATER:CheckVoteSkip()

		-- Can't skip if the queue is locked
		if self:IsQueueLocked() then return end

		-- Skip the current video if the voteskip requirement is met
		if self:NumVoteSkips() >= self:NumRequiredVoteSkips() then

			self:AnnounceToPlayers( 'Theater_Voteskipped' )

			self:SkipVideo()

		end

	end


	/*
		Players
	*/
	function THEATER:NumPlayers()
		return #(self.Players)
	end

	function THEATER:HasPlayer( ply )
		return table.HasValue(self.Players, ply)
	end

	function THEATER:AddPlayer( ply )

		-- Don't bother if the player is already in the list
		if self:HasPlayer( ply ) then return end

		-- Add the player to the list
		table.insert(self.Players, ply)

		SendTheaterInfo(ply)

		-- Send current video
		self:SendVideo(ply)

		-- Disable the player's flashlight
		if not self._AllowItems then
			if ply:FlashlightIsOn() then
				ply:Flashlight(false)
			end
		end

		if self._PermanentOwnerID == ply:SteamID() then
			self:ResetOwner()
			self:RequestOwner(ply)
		end

	end

	function THEATER:RemovePlayer( ply )

		-- Don't bother if the player isn't in the list
		if !self:HasPlayer( ply ) then return end

		-- Remove player from list
		table.RemoveByValue(self.Players, ply)
		
		-- Remove player from vote skip table if they have voted
		if self:HasPlayerVotedToSkip( ply ) then
			table.RemoveByValue(self._SkipVotes, ply)
		end

		-- Owner leaving private theater
		if self:IsPrivate() and ply == self:GetOwner() then
			self:ResetOwner()
			self:AnnounceToPlayer( ply, 'Theater_LostOwnership' )
		end

		-- Players remain in the theater
		if self:NumPlayers() > 0 then

			self:CheckVoteSkip()

		-- No player remain in the theater
		else
			-- Reset private theaters (and public if allowed)
			if self:IsPrivate() then
				self:Reset()
			end
		end

	end

	function THEATER:AnnounceToPlayers( tbl )
		self:AnnounceToPlayer( self.Players, tbl )
	end

	function THEATER:AnnounceToPlayer( ply, tbl )

		-- Single message without coloring
		if isstring(tbl) then
			tbl = { tbl }
		end

		-- Send announcement to all players or a single player
		if istable(ply) or IsValid(ply) then
			net.Start( "TheaterAnnouncement" )
				net.WriteTable( tbl )
			net.Send(ply)
		end

	end

	/*
		Private Theater
	*/
	function THEATER:ResetOwner()
		self._Owner = nil
		self._QueueLocked = false
		self._AllowItems = self._DefaultAllowItems
	end

	function THEATER:RequestOwner( ply )

		if !IsValid( ply ) then return end
		if IsValid( self:GetOwner() ) then return end

		self._Owner = ply
		self:AnnounceToPlayer( ply, 'Theater_NotifyOwnership' )

		SendTheaterInfo(ply)

	end

	function THEATER:IsQueueLocked()
		return self._QueueLocked
	end

	function THEATER:ToggleQueueLock( ply )

		if !IsValid(ply) then return end

		-- Toggle theater queue lock
		self._QueueLocked = !self._QueueLocked

		local staffaction = (self:GetOwner() == ply) and "" or " [STAFF ACTION]"

		-- Notify theater players of change
		self:AnnounceToPlayers( {
			self:IsQueueLocked() and 'Theater_LockedQueue' or 'Theater_UnlockedQueue',
			ply:Nick()..staffaction
		} )

	end

	function THEATER:SetName( name, ply )

		if !IsValid(ply) then return end

		-- Theater must be private and player must be the owner
		if !self:IsPrivate() or ply != self:GetOwner() then return end

		-- Clamp new name to 32 chars
		self._Name = string.sub(name,0,32)
		self:SyncThumbnail()

	end

end
