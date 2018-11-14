ENT.Base = "base_brush"
ENT.Type = "brush"

if SERVER then

	function ENT:Initialize()
	
		self:SetSolid(SOLID_BBOX)   
		self:SetCollisionBoundsWS(Vector(3457,3462,-975),Vector(3540,3470,-1093))
		self:SetTrigger(true)
		
	end
	
	function ENT:StartTouch(other)
	
		if other:IsPlayer() then
			other:SendLua("HellPromptPlayer()")
		end
		
	end
	
end