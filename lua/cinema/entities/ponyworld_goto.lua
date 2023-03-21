-- This file is subject to copyright - contact swampservers@gmail.com for more information.
ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionBoundsWS(Vector(2964, 2404, -2800), Vector(3044, 2420, -2680))
    self:SetTrigger(true)
end

function ENT:StartTouch(other)
    if CurTime() - (other.PonyTPCooldown or 0) < 2 then return end
    other.PonyTPCooldown = CurTime()

    if other:IsPlayer() and not other:IsPony() then
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

function SendToTeleport(pos, vel, ent, reverse)
    ent:SetPos(pos)

    if ent:IsPlayer() then
        local ang

        if reverse then
            ang = Vector(-vel.x, -vel.y, -vel.z / 8):Angle()
        else
            ang = Vector(vel.x, vel.y, vel.z / 8):Angle()
        end

        ang.r = 0
        ent:SetEyeAngles(ang)
        ent:SetVelocity(vel - ent:GetVelocity())
    else
        ent:SetVelocity(vel)

        if IsValid(ent:GetPhysicsObject()) then
            ent:GetPhysicsObject():SetVelocity(vel)
        end
    end
end
