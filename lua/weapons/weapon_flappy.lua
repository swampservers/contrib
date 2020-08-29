-- This file is subject to copyright - contact swampservers@gmail.com for more information.

SWEP.PrintName = "Flappy Fedora"

SWEP.Slot = 1

SWEP.Instructions = "Press jump to tip your fedora!"

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.ViewModelFOV = 85

SWEP.WorldModel = Model("models/fedora_rainbowdash/fedora_rainbowdash.mdl")
SWEP.ViewModel = Model("models/fedora_rainbowdash/fedora_rainbowdash.mdl")

if CLIENT then --console command to turn off the trail
	local cvar = CreateClientConVar("cl_fedoratrail", "1", true, false, "Toggles the Flappy Fedora trail. 0 = Disabled, 1 = Enabled", 0, 1)
	FLAPPYFEDORATRAIL = tobool(cvar:GetInt()) --first join
	cvars.AddChangeCallback("cl_fedoratrail", function(cvar, old, new)
		FLAPPYFEDORATRAIL = tobool(new)
	end)
end

function SWEP:Initialize()
	self:SetHoldType("normal")
	self.justreloaded=0
	self.jumptimer=0
	self.cantip = true
end

function SWEP:Deploy()
	if not self.Owner:InTheater() then
		self:EmitSound("mlady.ogg")
	end
	if CLIENT then return end

	local ply = self:GetOwner()
	if !IsValid(ply.FedoraPoint) then --if ply already has a trail, don't create a new one
		ply.FedoraPoint = ents.Create("ent_fedora_point")
		ply.FedoraPoint:SetOwner(ply)
		ply.FedoraPoint:Spawn()
		ply.FedoraPoint:Activate()
	end
end

function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
	if CLIENT then
		if self.Owner and self.Owner:IsValid() then sound.Play("friendzoned.ogg", self.Owner:GetPos(), 75, 100, 1) end
	end
end

function SWEP:OwnerChanged()
	if SERVER then
		self:ExtEmitSound("mlady.ogg", {speech=0.8})
	end
end

function SWEP:Reload()
	if self.justreloaded<1 then
	self:ExtEmitSound("friendzoned.ogg", {speech=0.85, shared=true})
end
	self.justreloaded=2
end

function SWEP:Tick()
	self.justreloaded = self.justreloaded-1
end

hook.Add( "KeyPress", "keypress_flappy", function( ply, key )
	if key~=IN_JUMP then return end
	if not IsFirstTimePredicted() then return end

	local self = ply:GetActiveWeapon()

	if not IsValid(self) or self:GetClass()~="weapon_flappy" then return end

	if ((not self.Owner:InTheater() or self.jumptimer<CurTime()-1) and self.Owner:GetLocationName() != "Movie Theater") then
		if self.Owner:IsOnGround() then
			--self.Owner:SetPos(self.Owner:GetPos()+Vector(0,0,1))
		end
		self.Owner:SetVelocity((Vector(0,0,1) * 220)-Vector(0,0,self.Owner:GetVelocity().z))
		self.jumptimer=CurTime()
		self.cantip = false
		self:ExtEmitSound("tip.ogg", {speech=0, shared=true})
	end
end )

function SWEP:PrimaryAttack()
	self:ExtEmitSound("nice meme.ogg", {speech=0.7, shared=true})
end


function SWEP:SecondaryAttack()
	self:ExtEmitSound("mlady.ogg", {speech=0.8, shared=true})
end

function SWEP:DrawWorldModel()
	local ply = self:GetOwner()

	if IsValid(ply) then

		local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_Head1"
		local bon = ply:LookupBone(bn) or 0

		local opos = self:GetPos()
		local oang = self:GetAngles()
		local bp,ba = ply:GetBonePosition(bon)
		if bp then opos = bp end
		if ba then oang = ba end
		if ply:IsPony() then
			oang:RotateAroundAxis(oang:Forward(),90)
			oang:RotateAroundAxis(oang:Up(),-90)
			opos = opos + (oang:Up()*13)
		else
			oang:RotateAroundAxis(oang:Right(),-90)
			oang:RotateAroundAxis(oang:Up(),180)
			opos = opos + (oang:Right()*-0.5) + (oang:Up()*6.5)
		end
		self:SetupBones()

		local mrt = self:GetBoneMatrix(0)
		if mrt then
		mrt:SetTranslation(opos)
		mrt:SetAngles(oang)

		self:SetBoneMatrix(0, mrt )
		end
	end
	self:DrawModel()
end

function SWEP:GetViewModelPosition( pos, ang )
	pos = pos + ang:Up()*5.5
	ang:RotateAroundAxis(ang:Up(),-90)
	ang:RotateAroundAxis(ang:Forward(),-8+(math.Clamp((CurTime()-self.jumptimer)*4,0,1)*8))
	return pos, ang 
end
