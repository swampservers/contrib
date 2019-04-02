ENT.Base = "base_brush"
ENT.Type = "brush"


function ENT:Initialize()  
    self:SetSolid(SOLID_BBOX)   
    self:SetCollisionBoundsWS(Vector(6608,976,-3760),Vector(6832,1232,-3712))
    self:SetTrigger(true)
end

function ENT:StartTouch(other)
	if other:IsPlayer() and !other:IsPony() then
		SendFromPonyWorld(other, true)
		other:ChatPrint("[red]Only the condemned may enter this realm.")
	else
		SendToPonyWorld(other)
	end
end

function SendToPonyWorld(e)
	local p = Vector(-9072,528,-6080)
	local v = Vector(200, 0, 50)
	SendToTeleport(p, v, e, false)
end

function SendFromPonyWorld(e, rev)
	local p = Vector(6704,1120,-3616)
	local v = Vector(-200, 0, 600)
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
	end
end