include("shared.lua")

SWEP.Instructions = "Primary: Spray White\nSecondary: Spray Black"

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
			--oang:RotateAroundAxis(oang:Forward(),90)
			oang:RotateAroundAxis(oang:Up(),90)
			opos = opos + (oang:Up()*0) + (oang:Right()*8) + (oang:Forward()*3)
		else
			oang:RotateAroundAxis(oang:Up(),-90)
			oang:RotateAroundAxis(oang:Forward(),180)
			opos = opos + (oang:Up()*-1) + (oang:Right()*3) + (oang:Forward()*2)
		end
		self:SetupBones()

		local mrt = self:GetBoneMatrix(0)
		if(mrt)then
		mrt:SetTranslation(opos)
		mrt:SetAngles(oang)
		mrt:SetScale(Vector(0.4,0.4,0.4))

		self:SetBoneMatrix(0, mrt )
		end
	end

	self:DrawModel()
end

function SWEP:GetViewModelPosition( pos, ang )
	pos = pos + ang:Right()*20
	pos = pos + ang:Up()*-20
	pos = pos + ang:Forward()*40
	ang:RotateAroundAxis(ang:Up(),90)
	return pos, ang 
end

function SWEP:DrawHUD()
	if CLIENT then
		local tr = self.Owner:GetEyeTrace()
		
		if (tr.StartPos:Distance(tr.HitPos)<125) then
		
			surface.DrawCircle(ScrW() / 2, ScrH() / 2, 11, Color(255, 255, 255,8))
			surface.DrawCircle(ScrW() / 2, ScrH() / 2, 10, Color(0,0,0,10))
		end
	end
end