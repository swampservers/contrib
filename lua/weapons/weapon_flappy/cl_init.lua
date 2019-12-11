include("shared.lua")

SWEP.Instructions	= "Press jump to tip your fedora!"

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.ViewModelFOV = 85


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
			opos = opos + (oang:Right()*-0.3) + (oang:Up()*6.5)
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