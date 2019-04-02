ENT.Base = "base_brush"
ENT.Type = "brush"


function ENT:Initialize()  
    self:SetSolid(SOLID_BBOX)   
    self:SetCollisionBoundsWS(Vector(-9152,432,-6112),Vector(-9120,624,-6000))
    self:SetTrigger(true)
end

function ENT:StartTouch(other)
	SendFromPonyWorld(other, false)
end