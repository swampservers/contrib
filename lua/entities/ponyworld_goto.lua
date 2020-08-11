ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()  
    self:SetSolid(SOLID_BBOX)   
    self:SetCollisionBoundsWS(Vector(2964, 2404, -2800), Vector(3044, 2420, -2680))
    self:SetTrigger(true)
end

function ENT:StartTouch(other)
	if CurTime() - (other.PonyTPCooldown or 0) < 2 then return end other.PonyTPCooldown=CurTime()
	if other:IsPlayer() and !other:IsPony() then
		SendFromPonyWorld(other, true)
		other:ChatPrint("[red]Only the condemned may enter this realm.")
	else
		SendToPonyWorld(other)
	end
end

function SendToPonyWorld(e)
	local p = Vector(-10600, -3570, -6022)
	local v = Vector(200, 0, 50)
	SendToTeleport(p, v, e, false)
end

function SendFromPonyWorld(e, rev)
	local p = Vector(3005, 2359, -2740)
	local v = Vector(0, -100, 25)
	SendToTeleport(p, v, e, rev)
end

function SendToTeleport(p, v, e, reverse)
	e:SetPos(p)
	if e:IsPlayer() then
		local a
		if reverse then
			a = Vector(-v.x,-v.y,-v.z/8):Angle()
		else
			a = Vector(v.x,v.y,v.z/8):Angle()
		end
		a.r = 0
		e:SetEyeAngles(a)
		e:SetVelocity(v-e:GetVelocity())
	else
		e:SetVelocity(v)
		if IsValid(e:GetPhysicsObject()) then e:GetPhysicsObject():SetVelocity(v) end
	end
end
