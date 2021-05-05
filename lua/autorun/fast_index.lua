-- This file is subject to copyright - contact swampservers@gmail.com for more information.

local Player = FindMetaTable("Player")
local Weapon = FindMetaTable("Weapon")
local Entity = FindMetaTable("Entity")
local EntTable = Entity.GetTable

function Entity:__index( key )
	local val = Entity[ key ]
	if  val != nil then return val end
	local tab = EntTable(self)
	if  tab  then
		return tab[ key ]
	end
    -- Removed .Owner -> :GetOwner()
end

function Player:__index( key )
	local val = Player[key]
	if  val != nil  then return val end
	local val = Entity[key]
	if  val != nil  then return val end
	local tab = EntTable( self )
	if  tab  then
		return tab[ key ]
	end
end

function Weapon:__index( key )
	local val = Weapon[key]
	if  val != nil  then return val end
	local val = Entity[key]
	if  val != nil  then return val end
	local tab = EntTable( self )
	if  tab != nil  then
		local val = tab[ key ]
		if  val != nil  then return val end
	end
    -- TODO remove this and collapse this function to be like Player
	if  key == "Owner"  then return entity.GetOwner( self ) end
end