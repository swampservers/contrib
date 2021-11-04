-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Big Bomb"
SWEP.Slot = 4
SWEP.ViewModel = Model("models/dynamite/dynamite.mdl")
SWEP.WorldModel = Model("models/dynamite/dynamite.mdl")

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_SLAM_THROW_DRAW)
end
