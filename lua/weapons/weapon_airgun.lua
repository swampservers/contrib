
SWEP.PrintName	= "Air Gun"
SWEP.Category = "Other"
SWEP.Author	= "Austin and Noz"
SWEP.Instructions = "Push stuff"

local ForcePower = 300 -- change it if u want change air-power

SWEP.DrawCrosshair		= false
SWEP.Primary.ClipSize		 = -1
SWEP.Primary.DefaultClip	 = -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		 = "none"
SWEP.Primary.Delay = 1.25

SWEP.Secondary.ClipSize	  = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic	 = false
SWEP.Secondary.Ammo	  = "none"

SWEP.Spawnable = true
SWEP.ViewModel = "models/milaco/airgun/airgun.mdl"
SWEP.WorldModel = "models/milaco/airgun/airgun.mdl"

function SWEP:PrimaryAttack()
	
	self.Owner:ExtEmitSound("airgun/air.wav")
	
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	local tr = self:GetOwner():GetEyeTrace(MASK_SHOT)
	
	if tr.Hit and IsValid(tr.Entity) and (self:GetOwner():EyePos() - tr.HitPos):Length() < 100 and not Safe(tr.Entity) then
	
		local enthit = tr.Entity
		if enthit:IsRagdoll() or enthit:GetClass() == "prop_physics" then
		
			local phys = enthit:GetPhysicsObject()
			if IsValid(phys) and phys:IsMoveable() then
			
				local pdir = tr.Normal
				local speed = phys:GetVelocity():Length()
				local maxforce = 9000
				local force = (maxforce + (10 - maxforce) * (speed / 125)) * ForcePower/100
				
				if enthit:GetClass() == "prop_ragdoll" then
					force = force * ForcePower * 90
				end
				
				pdir = pdir * force
				
				local mass = phys:GetMass()
		
				if mass < 50 then
					pdir = pdir * (mass + 0.5) * (1 / 50)
				end
				
				phys:ApplyForceCenter(pdir)
				
			end
			
		elseif enthit:IsPlayer() or enthit:IsNPC() then
		
			local pushvel = tr.Normal * 500
			pushvel.z = math.Clamp(pushvel.z,0,0)
			enthit:SetVelocity(enthit:GetVelocity() + pushvel)
			
		end
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
	self:SetHoldType("pistol")
end

function SWEP:CreateWorldModel()
   if not IsValid(self.WModel) then
      self.WModel = ClientsideModel(self.WorldModel,RENDERGROUP_OPAQUE)
      self.WModel:SetNoDraw(true)
      self.WModel:SetBodygroup(1,1)
   end
   return self.WModel
end

function SWEP:DrawWorldModel()
	local wm = self:CreateWorldModel()
	
	local bone = self.Owner:LookupBone("ValveBiped.Bip01_R_Hand") or 0
	local opos = self:GetPos()
	local oang = self:GetAngles()
	local bp,ba = self.Owner:GetBonePosition(bone)
	if (bp) then opos = bp end
	if (ba) then oang = ba end
	
	wm:SetModelScale(1)
	
	opos = opos + oang:Right()*1.8
	opos = opos + oang:Forward()*3.75
	opos = opos + oang:Up()*0
	oang:RotateAroundAxis(oang:Right(),0)
	oang:RotateAroundAxis(oang:Forward(),180)
	oang:RotateAroundAxis(oang:Up(),0)
	
	wm:SetRenderOrigin(opos)
	wm:SetRenderAngles(oang)
	wm:DrawModel()
end

function SWEP:GetViewModelPosition(pos,ang)
	pos,ang = LocalToWorld(Vector(25,-9,-10),Angle(0,15,0),pos,ang)
	
	return pos, ang
end

function SWEP:OnRemove()
	if self.WModel then self.WModel:Remove() end
end