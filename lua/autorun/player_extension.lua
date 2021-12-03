-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local Player = FindMetaTable("Player")

function Player:UsingWeapon(cls)
    local c = self:GetActiveWeapon()

    return IsValid(c) and c:GetClass() == cls
end

-- Use the player color as the weapon color
function Player:GetWeaponColor()
    return self:GetPlayerColor()
end
