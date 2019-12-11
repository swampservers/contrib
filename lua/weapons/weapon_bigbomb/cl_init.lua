include("shared.lua")

SWEP.Instructions = "Primary: Drop Bomb\nSecondary: Warning Siren"

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

killicon.Add("weapon_bigbomb", "weapons/killicon/weapon_bigbomb", Color(255, 80, 0))

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
			oang:RotateAroundAxis(oang:Up(),90)
			oang:RotateAroundAxis(oang:Right(),90)
			oang:RotateAroundAxis(oang:Up(),90)
			opos = opos + (oang:Up()*-6) + (oang:Right()*-7) + (oang:Forward()*-6)

		else
						oang:RotateAroundAxis(oang:Forward(),90)
			oang:RotateAroundAxis(oang:Up(),90)
			oang:RotateAroundAxis(oang:Right(),90)
			oang:RotateAroundAxis(oang:Up(),150)
			opos = opos + oang:Up()*-8 + oang:Right()*1 + oang:Forward()*-8
		end
		self:SetupBones()

		local mrt = self:GetBoneMatrix(0)
		if(mrt)then
		mrt:SetTranslation(opos)
		mrt:SetAngles(oang)

		self:SetBoneMatrix(0, mrt )
		end
	end

	self:DrawModel()
end

function SWEP:GetViewModelPosition( pos, ang )
	--if !LocalPlayer():IsPony() then
	pos = pos + ang:Forward()*2
		pos = pos + ang:Right()*15
		pos = pos + ang:Up()*-1
	--else
	--	pos = pos + ang:Up()*-8
	--end
	pos = pos + ang:Up()*-15
	pos = pos + ang:Forward()*25
	ang:RotateAroundAxis(ang:Up(),-160)
	return pos, ang 
end