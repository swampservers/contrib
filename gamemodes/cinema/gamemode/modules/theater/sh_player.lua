-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local meta = FindMetaTable("Player")
if not meta then return end

function meta:InTheater()
    return (Location.GetLocationByIndex(self:GetLocation()) or {}).Theater ~= nil
end

function meta:SetInTheater(inTheater)
    --self:SetDTBool(0, inTheater or false)
    return true
end

function meta:GetTheater()
    return theater.GetByLocation(self:GetLocation())
end