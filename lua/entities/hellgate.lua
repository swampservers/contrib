ENT.Base = "base_brush"
ENT.Type = "brush"

if SERVER then

	function ENT:Initialize()
	
		self:SetSolid(SOLID_BBOX)   
		self:SetCollisionBoundsWS(Vector(-100.6,5119.5,.6),Vector(-.1,5019,10))
		self:SetTrigger(true)
		
	end
	
	function ENT:StartTouch(other)
	
		if other:IsPlayer() then
			net.Start("HellTeleportEffect")
				net.WriteEntity(other)
				net.WriteBool(true)
			net.Broadcast()
			self:EmitSound("hell/DSTELEPT.wav")
			other:EmitSound("hell/DSTELEPT.wav")
			other:SetPos(Vector(0,-230,1))
		end
		
	end
	
end