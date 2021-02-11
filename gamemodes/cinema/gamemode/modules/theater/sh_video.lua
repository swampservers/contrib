-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

module( "theater", package.seeall )

VIDEO = {}

function VIDEO:Init( info, ply )

	if (not info) or ((info.type or "")=="") then return end

	local o = {}
	
	setmetatable( o, self )
	self.__index = self
	
	if SERVER then
		o.id = -1 			-- set by theater
		o.theaterId = -1 	-- set by theater

		o._RequestTime = CurTime()
		o._Owner = ply
		o._OwnerName = IsValid(ply) and ply:Nick() or "" -- in case they disconnect
		o._OwnerSteamID = IsValid(ply) and ply:SteamID() or ""

		o._Votes = {}

		o:SetVote(ply, 1)
	else
		o._OwnerName = info.OwnerName
		o._OwnerSteamID = info.OwnerSteamID
	end

	o._VideoType = info.type
	o._VideoKey = info.key or ""

	o._VideoTitle = string.gsub(info.title or "(Unknown)", '%%', '%%%%')
	o._VideoDuration = tonumber(info.duration) or -1
	o._VideoThumbnail = info.thumb or ""
	o._VideoData = info.data or ""

	o._VideoStart = info.start or 0

	return o

end

function VIDEO:SetStartTime(t)
	self._VideoStart = t
end

function VIDEO:StartTime()
	return self._VideoStart
end

function VIDEO:Type()
	return self._VideoType
end

function VIDEO:Service()
	return GetServiceByClass(self._VideoType)
end

function VIDEO:Key()
	return self._VideoKey
end

function VIDEO:Title()
	return self._VideoTitle
end

function VIDEO:Duration()
	if self._VideoDuration<0 then error("incomplete video object") end
	return self._VideoDuration
end

function VIDEO:IsTimed()
	return self:Duration() > 0
end

function VIDEO:Thumbnail()
	return self._VideoThumbnail
end

function VIDEO:Data()
	return self._VideoData
end

function VIDEO:IsMature()
	return self:Service():IsMature(self)
end

/*
	Owner
*/
function VIDEO:GetOwner()
	if not IsValid(self._Owner) then
		self._Owner = player.GetBySteamID(self:GetOwnerSteamID()) or nil
	end
	return self._Owner
end

function VIDEO:GetOwnerName()
	if IsValid(self:GetOwner()) then
		self._OwnerName = self:GetOwner():Nick()
	end
	return self._OwnerName
end

function VIDEO:GetOwnerSteamID()
	return self._OwnerSteamID
end

if SERVER then

	util.AddNetworkString("VideoRequest")

	net.Receive("VideoRequest",function(len,ply)
		local th = IsValid(ply) and ply:GetTheater()
		if th then
			th:RequestVideo(ply,net.ReadString())
		end
	end)

	function VIDEO:RequestTime()
		return self._RequestTime
	end
	
	function VIDEO:GetNumVotes()
		self:ValidateVotes()
		local count = 0
		for _, vote in pairs(self._Votes) do
			count = count + vote
		end
		return count
	end

	function VIDEO:ValidateVotes()
		for k, v in pairs(self._Votes) do
			if not IsValid(k) or k:GetLocation() ~= self.theaterId then
				self._Votes[k] = nil
			end
		end
	end

	function VIDEO:RemoveVoteByPlayer(ply)
		self._Votes[ply] = nil
	end

	function VIDEO:GetVoteByPlayer(ply)
		return self._Votes[ply] or 0
	end

	function VIDEO:SetVote( ply, value )
		if not IsValid(ply) then return end
		self._Votes[ply] = (value ~= 0) and value or nil
	end

	function VIDEO:RequestInfo( callback )

		if !callback then return end

		if self:Type() != "" then

			-- check cache
			GetVideoLog(self, function(stuff)  
				if stuff then
					self._VideoTitle = stuff.title or "(Unknown)"
					self._VideoDuration = tonumber(stuff.duration) or -1
					self._VideoThumbnail = stuff.thumb or ""
					self._VideoData = stuff.data or ""

					callback(true)
				else
					local function loadFailure(code)
						callback((type(code) == 'string') and code or false)
					end

					-- Query info from API
					local status, err = pcall( GetVideoInfo, self:Type(), self:Key(), self:GetOwner(), function(info)
						self._VideoTitle = string.sub(string.Trim(url.htmlentities_decode(info.title) or ""," "),1,100)
						if self._VideoTitle=="" then self._VideoTitle="(Unknown)" end
						self._VideoDuration = tonumber(info.duration) or -1
						self._VideoThumbnail = info.thumb or ""
						self._VideoData = info.data or ""

						-- Problem grabbing duration data
						if self._VideoDuration < 0 then
							print("duration error for "..self:Type().." "..self:Key())
							return callback(false)		
						end

						--log here for better performance
						theater.LogVideo(self)

						callback(true)
					end, loadFailure)

					-- Something went wrong while grabbing the video info
					if !status then
						print("ERROR: "..tostring(err))
						callback(false)
					end
				end
			end)
		else
			callback(false)
		end

	end

end
