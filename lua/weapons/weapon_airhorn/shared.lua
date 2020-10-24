-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

SWEP.Author = ""

SWEP.Instructions = "For all your MLG needs"

SWEP.PrintName = "Airhorn"

SWEP.IconLetter	= "V"
SWEP.Slot = 1
SWEP.SlotPos = 10

SWEP.ViewModelFOV = 62 


SWEP.BounceWeaponIcon = true

SWEP.ViewModel = "models/rockyscroll/airhorn/airhorn.mdl"
SWEP.WorldModel = "models/rockyscroll/airhorn/airhorn.mdl"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.Clipsize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Clipsize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.HoldType = "Slam"

SWEP.Category = "Airhorn"



function SWEP:Deploy()

	self:SetHoldType("Slam")

end



function SWEP:PrimaryAttack()
	self:SetHoldType( "revolver" )
	self:ExtEmitSound("airhorn/mlg.ogg", {shared=true, pitch=(self.Owner:Crouching() and 160 or 100) + math.Rand(-20,20)})
end


function SWEP:SecondaryAttack()
	self:ExtEmitSound("airhorn/honk1.ogg", {shared=true})
end


function SWEP:Reload()
	if (self.ReloadCooldown or 0) > CurTime() then return end
	self.ReloadCooldown = CurTime() + 0.2
	self:ExtEmitSound("airhorn/honk2.ogg", {shared=true})
end

if SERVER then
	util.AddNetworkString("stopsoundcl")
	function stopairhornsound(ent)
		net.Start("stopsoundcl")
		net.WriteEntity(ent)
		net.WriteString("airhorn/mlg.ogg")
		net.SendOmit(IsValid(ent.Owner) and ent.Owner or {})
	end
else
	net.Receive("stopsoundcl", function()
		local ent = net.ReadEntity()
		if IsValid(ent) then ent:StopSound(net.ReadString()) end
	end)
	function stopairhornsound(ent)
		ent:StopSound("airhorn/mlg.ogg")
	end
end



function SWEP:Think()

	if not IsValid(self.Owner) then return end
	if self.Owner:InVehicle() then return end
	

	if	 ( self.Owner:KeyReleased( IN_ATTACK ) ) then 
		
		stopairhornsound(self)
		self:SetHoldType("slam" )
		
	end

end


function SWEP:Holster()
	self.Weapon:StopSound("airhorn/mlg.ogg")
	return true
end



function SWEP:GetViewModelPosition( pos, ang )
	pos = pos + ang:Right()*15
	pos = pos + ang:Up()*-25
	pos = pos + ang:Forward()*50
	ang:RotateAroundAxis(ang:Up(),100)
	ang:RotateAroundAxis(ang:Forward(), -10)
	ang:RotateAroundAxis(ang:Right(),0)
	return pos, ang 
end

function SWEP:DrawWorldModel()

    local ply = self:GetOwner()

    if(IsValid(ply))then

        local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
        local bon = ply:LookupBone(bn) or 0

        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp,ba = ply:GetBonePosition(bon)
        if(bp)then opos = bp end
        if(ba)then oang = ba end
        opos = opos + oang:Right()*3
        opos = opos + oang:Forward()*3
        opos = opos + oang:Up()*2
        if ply:IsPony() then
            opos = opos + oang:Forward()*7
            opos = opos + oang:Up()*2
            opos = opos + oang:Right()*-4
        end
        oang:RotateAroundAxis(oang:Right(),180)
        self:SetupBones()

        self:SetModelScale(0.6,0)
        local mrt = self:GetBoneMatrix(0)
        if(mrt)then
        mrt:SetTranslation(opos)
        mrt:SetAngles(oang)

        self:SetBoneMatrix(0, mrt )
        end
    end

    self:DrawModel()
end
