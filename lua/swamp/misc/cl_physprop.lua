-- This file is subject to copyright - contact swampservers@gmail.com for more information.
net.Receive("ClientPhysProp", function()
    local mdl = net.ReadString()
    local pos = net.ReadVector()
    local ang = net.ReadAngle()
    local vel = net.ReadVector()
    local scale = net.ReadFloat()
    local t = net.ReadFloat()
    GibClientProp(mdl, pos, ang, vel, scale, t)
end)

function GibClientProp(mdl, pos, ang, vel, scale, t)
    if not Me then return end
    local ent = ents.CreateClientProp()
    if not IsValid(ent) then return end
    ent:SetModel(mdl)
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:PhysicsInit(SOLID_VPHYSICS)

    if not IsValid(ent:GetPhysicsObject()) then
        local ofs = Vector(0.8, 0.8, 0.8)
        ent:PhysicsInitBox(ent:OBBMins() + ofs, ent:OBBMaxs() - ofs)
        -- print("BADPHY", mdl)
    end

    --ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    ent:Spawn()
    ent:Activate()
    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        phys:EnableMotion(true)
        phys:Wake()
        phys:SetVelocity(vel)
    end

    ent:SetModelScale(scale, 0)

    if t > 0 then
        timer.Simple(t, function()
            if IsValid(ent) then
                ent:Remove()
            end
        end)
    end

    return ent
end

net.Receive("RemoveKGlassesR", function()
    local ent = net.ReadEntity()

    timer.Simple(0.1, function()
        if IsValid(ent) then
            ent = ent:GetRagdollEntity()

            if IsValid(ent) then
                ent:SetSubMaterial(2, "engine/occlusionproxy")
                ent:SetSubMaterial(6, "engine/occlusionproxy")
                ent:SetSubMaterial(7, "engine/occlusionproxy")
            end
        end
    end)
end)
