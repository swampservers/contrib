-- This file is subject to copyright - contact swampservers@gmail.com for more information.

SWEP.PrintName			= "Flare"	
SWEP.DrawAmmo 			= false
SWEP.DrawCrosshair 		= true
SWEP.DrawWeaponInfoBox  = true
SWEP.ViewModelFOV		= 85
SWEP.ViewModelFlip		= false

SWEP.Slot				= 0
SWEP.SlotPos			= 2

SWEP.Purpose = "Light Gnomes On Fire"
SWEP.Instructions	= "Primary: Use"

SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false

SWEP.ViewModel 				= Model("models/staticprop/props_junk/flare.mdl")
SWEP.WorldModel 			= Model("models/staticprop/props_junk/flare.mdl")

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.ClipSize			= -1
SWEP.Primary.Damage				= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic			= false
SWEP.Primary.Ammo				= "none"

SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Damage			= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo				= "none"

function SWEP:Initialize() 
	self:SetHoldType("slam") 
end 

if SERVER then
	timer.Create("FlareControl", 5, 0, function()
	for k,v in pairs(ents.FindByClass("weapon_flare")) do
		if v:GetPos().z>-10 then
			v:Remove()
		end
	end
	end)
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 1)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if SERVER then
		--[[ local hit = self.Owner:GetEyeTrace()
		if (hit.HitPos or Vector(0,0,0)):Distance(self.Owner:EyePos()) > 80 then return end
		hit = hit.Entity
		if IsValid(hit) and hit:GetClass()=="keem" then hit:FireAttack() self:Remove() end ]]--
		for k,v in pairs(ents.FindByClass("keem")) do
			if v:GetPos():Distance(self.Owner:GetPos())<80 then
				v:FireAttack()
				self:Remove()
			end
		end
	end
end

function SWEP:SecondaryAttack()

end

function SWEP:Think()
if CLIENT then
	if (!IsValid(self.Owner)) or self.Owner:GetActiveWeapon()~=self then return end
	local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		dlight.pos = self.Owner:EyePos()
		dlight.r = 255
		dlight.g = 50
		dlight.b = 50
		dlight.brightness = math.random(10,22)*0.1
		dlight.Decay = 1000
		dlight.Size = 208
		dlight.DieTime = CurTime() + 0.05
	end
end
end

function SWEP:DrawWorldModel()

	local ply = self:GetOwner()

	if(IsValid(ply))then

		local bn = "ValveBiped.Bip01_R_Hand"
		local bon = ply:LookupBone(bn) or 0

		local opos = self:GetPos()
		local oang = self:GetAngles()
		local bp,ba = ply:GetBonePosition(bon)
		if(bp)then opos = bp end
		if(ba)then oang = ba end
		opos = opos + oang:Right()*1
		opos = opos + oang:Forward()*4
		oang:RotateAroundAxis(oang:Right(),180)
		self:SetupBones()

		self:SetModelScale(0.8,0)
		local mrt = self:GetBoneMatrix(0)
		if(mrt)then
		mrt:SetTranslation(opos)
		mrt:SetAngles(oang)

		self:SetBoneMatrix(0, mrt )
		end
	end

	self:DrawModel()
end

flarefxpos = Vector()
flaresprite = Material("sprites/glow04_noz")

function SWEP:GetViewModelPosition( pos, ang )
	pos = pos + ang:Right()*22
	pos = pos + ang:Up()*-15
	pos = pos + ang:Forward()*25
	flarefxpos:Set(pos)
	flarefxpos = flarefxpos + ang:Up()*7 + ang:Forward()*-1 + ang:Right()*-1
	return pos, ang 
end

function SWEP:PostDrawViewModel()
	render.SetMaterial(flaresprite)
	local a = 0.1
	local b = math.Rand(0.6,1)
	render.DrawSprite(flarefxpos+Vector(math.Rand(-a,a),math.Rand(-a,a),math.Rand(-a,a)), 15,15, Color(255*b,255*b,255*b))

end
