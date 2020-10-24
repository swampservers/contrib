-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

include("shared.lua")

SWEP.Instructions = "Primary: Throw hard\nSecondary: Throw soft\nReload: Pass"

SWEP.DrawAmmo = false

SWEP.ViewModelFOV = 85

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
		if ply:IsPony() then
			oang:RotateAroundAxis(oang:Forward(),90)
			oang:RotateAroundAxis(oang:Up(),-90)
			opos = opos + (oang:Up()*-12) + (oang:Right()*-12)
		else
			opos = opos + oang:Right()*12.5
		end
		self:SetupBones()

		self:SetModelScale(0.8,0)
		local mrt = self:GetBoneMatrix(0)
		if(mrt)then
		mrt:SetTranslation(opos)
		mrt:SetAngles(oang)

		self:SetBoneMatrix(0, mrt )
		end
	end

	render.SetColorModulation(1,0,0)
	self:SetColor(255, 0, 0, 255)
	self:DrawModel()
	render.SetColorModulation(1,1,1)
end

function SWEP:PreDrawViewModel( vm, wp, ply )
	render.SetColorModulation(1,0,0)
end

function SWEP:GetViewModelPosition( pos, ang )
	if !LocalPlayer():IsPony() then
		pos = pos + ang:Right()*22
	else
		pos = pos + ang:Up()*-8
	end
	pos = pos + ang:Up()*-15
	pos = pos + ang:Forward()*25
	return pos, ang 
end

function SWEP:PostDrawViewModel( vm, wp, ply )
	render.SetColorModulation(1,1,1)
end
