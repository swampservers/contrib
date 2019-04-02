include("shared.lua")

SWEP.Purpose = "Wage jihad against the infidel"
SWEP.Instructions = "Primary: Detonate\nSecondary: Sing"

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false



function SWEP:DrawWorldModel()

self:SetModelScale(1.6,0)

local movedown = 0
if self.alreadyfired then movedown=-3 end
if self.Owner:IsValid() then
if self.Owner:LookupBone("ValveBiped.Bip01_Spine") then
local thematrix = self.Owner:GetBoneMatrix(self.Owner:LookupBone("ValveBiped.Bip01_Spine"))
if thematrix then
suicidevestrenderat(thematrix,5,-1,-11+movedown,self)
local drew = true
end
end
end
if not drew then
self:DrawModel()
end


end

function suicidevestrenderat( thematrix, down, forward, left,self)
 --move down,move forward,move left
local thepos = thematrix:GetTranslation() + (thematrix:GetRight()*down)  + (thematrix:GetUp()*forward)  + (thematrix:GetForward()*left)
local theang = thematrix:GetAngles()
theang:RotateAroundAxis( thematrix:GetRight(), -90 )
if self.alreadyfired then theang:RotateAroundAxis( thematrix:GetUp(), -6 ) end
self:SetRenderOrigin(thepos)
self:SetRenderAngles(theang)
self:DrawModel()
end


function SWEP:DrawWorldModel()
	local ply = self:GetOwner()

	self:SetModelScale(1.6,0)

	if(IsValid(ply))then

		local bn = ply:IsPony() and "LrigTorso" or "ValveBiped.Bip01_Spine"
		local bon = ply:LookupBone(bn) or 0

		local opos = self:GetPos()
		local oang = self:GetAngles()
		local bp,ba = ply:GetBonePosition(bon)
		if(bp)then opos = bp end
		if(ba)then oang = ba end
		if ply:IsPony() then
			--oang:RotateAroundAxis(oang:Forward(),90)

			opos = opos + (oang:Up()*-13) + (oang:Right()*6) + (oang:Forward()*4)
		else
			oang:RotateAroundAxis(oang:Right(),-90)
			
			opos = opos + oang:Up()*-9 + oang:Right()*5
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
