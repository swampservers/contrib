SWEP.Base = "weapon_base"
SWEP.PrintName = "Anti-Pony Rifle"
SWEP.Instructions = "Shoot ponies to kill them instantly!"

SWEP.Slot = 2

SWEP.Primary.Empty = Sound("Weapon_IRifle.Empty")
SWEP.Primary.Fire = Sound("Weapon_AR2.Single")
SWEP.Primary.ClipSize = 0
SWEP.Primary.Damage = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = true

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Damage = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = false

SWEP.UseHands = true
SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.HoldType = "ar2"

if CLIENT then
	killicon.AddFont("weapon_antiponyrifle", "HL2MPTypeDeath", "2", Color( 244, 66, 241, 255 ) )
end

local function PonyRifleDissolve(target, attacker)
	if !target:InVehicle() and !Safe(target) then
		local dinfo = DamageInfo()
		dinfo:SetDamage(target:Health())
		dinfo:SetAttacker(attacker)
		dinfo:SetDamageType(DMG_DISSOLVE)
		target:TakeDamageInfo(dinfo)
		target:ExtEmitSound("squee.wav", {pitch=math.random(70,90)})
	end
end

function SWEP:Initialize()
	self:SetClip1(30)
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.10)
	local ponyeyetrace = self.Owner:GetEyeTrace()

	if self:Clip1() > 0 then
		self:SetClip1(self:Clip1() - 1)
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
		self.Weapon:ExtEmitSound(self.Primary.Fire);
		self.Owner:SetAnimation(PLAYER_ATTACK1);
		self.Owner:MuzzleFlash()
		self.Owner:ViewPunch(Angle( -1, 0, 0 ))

		if SERVER and ponyeyetrace.Hit and ponyeyetrace.Entity:IsPlayer() and ponyeyetrace.Entity:Alive() and ponyeyetrace.Entity:IsPony() then
			PonyRifleDissolve(ponyeyetrace.Entity, self.Owner)
		end
	elseif self:Clip1() == 0 then
		if SERVER and IsValid(self) then
			self:Remove() 
			self.Weapon:EmitSound(self.Primary.Empty)
		end
	end
end

function SWEP:Deploy()
	self:SetHoldType(self.HoldType)
end

function SWEP:Holster()
	return true
end