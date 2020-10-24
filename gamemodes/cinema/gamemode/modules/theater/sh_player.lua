-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

local meta = FindMetaTable("Player")
if !meta then return end

function meta:InTheater()
	return (Location.GetLocationByIndex(self:GetLocation()) or {}).Theater~=nil
end

function meta:SetInTheater( inTheater )
	return true --self:SetDTBool(0, inTheater or false)
end

function meta:GetTheater()
	return theater.GetByLocation(self:GetLocation())
end
