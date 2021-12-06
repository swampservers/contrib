-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Big Bomb"
SWEP.Slot = 4
SWEP.ViewModel = Model("models/dynamite/dynamite.mdl")
SWEP.WorldModel = Model("models/dynamite/dynamite.mdl")

sound.Add({
    name = "bombfusehissin",
    channel = CHAN_STATIC,
    volume = 1.0,
    level = 80,
    pitch = {95, 110},
    sound = "ambient/gas/cannister_loop.wav"
})

function SWEP:PrimaryAttack()
    if SERVER then
        self:Throw()
        self.Owner:StripWeapon("weapon_bigbomb")
    end

    self.Weapon:SetNextPrimaryFire(CurTime() + 100)
end

function SWEP:SecondaryAttack()
    if IsFirstTimePredicted() then
        self.Owner:EmitSound("npc/attack_helicopter/aheli_megabomb_siren1.wav", 80, 100, 1, CHAN_WEAPON)
    end

    self.Weapon:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_SLAM_THROW_DRAW)
end
