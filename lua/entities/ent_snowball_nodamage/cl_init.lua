include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

function ENT:Think() end

function ENT:Initialize() --debug
	local plycol = self.Owner:GetNWVector("SnowballColor", Vector(1, 1, 1)):ToColor()
	print("Spawning snowball, plycol is "..tostring(plycol))
end
