-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Big Bomb"
SWEP.Slot = 4
SWEP.ViewModel = Model("models/dynamite/dynamite.mdl")
SWEP.WorldModel = Model("models/dynamite/dynamite.mdl")

print("TH")

-- models/props_phx/ball.mdl
-- models/props_phx/cannonball.mdl
-- models/props_phx/cannonball_solid.mdl
-- models/shadertest/shader3

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_SLAM_THROW_DRAW)
end



function SWEP:SetupMove(ply, mv, cmd)
    local vel = mv:GetVelocity()
    vel.z = power
    mv:SetVelocity(Vector(0,0,0))
end