SWEP.PrintName = "Flappy Fedora"

SWEP.Slot = 1

SWEP.WorldModel = Model("models/fedora_rainbowdash/fedora_rainbowdash.mdl")
SWEP.ViewModel = Model("models/fedora_rainbowdash/fedora_rainbowdash.mdl")

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
end

function SWEP:OnRemove()
	if CLIENT then
		if self.Owner and self.Owner:IsValid() then sound.Play( "friendzoned.ogg", self.Owner:GetPos(), 75, 100, 1) end
	end
end

function SWEP:OwnerChanged( )
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

	if (not self.Owner:InTheater() or self.jumptimer<CurTime()-1) then
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
