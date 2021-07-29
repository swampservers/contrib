-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local Entity = FindMetaTable("Entity")

function Entity:IsProtected(att)
    if HumanTeamName ~= nil then return false end
    local loc, name = self:GetLocation(), self:GetLocationName()
    if name == "Movie Theater" and (self:GetPos().y > 1400 or self:GetPos().z > 150) then return true end

    if name == "Golf" then
        if self:IsPlayer() then
            local w = self:GetActiveWeapon()

            if IsValid(w) and w:GetClass() == "weapon_golfclub" then
                if IsValid(w:GetBall()) then return true end
            end
        end
    end

    local pt = protectedTheaterTable and protectedTheaterTable[loc]

    if pt ~= nil and pt["time"] > 1 then
        --if theater is protected and the attacker is the theater owner, then this player is not safe from them.
        local owner = self:GetTheater() and self:GetTheater():GetOwner()
        if IsValid(att) and att:IsPlayer() and self:IsPlayer() and self:InTheater() and owner == att then return false end

        return true
    end

    if self:IsPlayer() then
        if IsValid(self:GetVehicle()) then
            if self:GetVehicle():GetNWBool("IsChessSeat", false) then
                local e = self:GetVehicle():GetNWEntity("ChessBoard", nil)
                if IsValid(e) and e:GetPlaying() then return true end
            end

            local v = self:GetVehicle()
            if (v.SeatData ~= nil) and (v.SeatData.Ent ~= nil) and IsValid(v.SeatData.Ent) and v.SeatData.Ent:GetName() == "rocketseat" then return true end
        end
    end

    if IsValid(att) and att:IsProtected() and att:GetLocation()~=self:GetLocation() then return true end

    return false
end

-- function Safe(ent, attacker)
--     return ent:IsProtected(attacker)
-- end
util.PrecacheModel("models/ppm/pony_anims.mdl")
SkyboxPortalEnabled = SkyboxPortalEnabled or false
SkyboxPortalCenter = Vector(290, -418, -8)

if SERVER then
    util.AddNetworkString("bounce")

    net.Receive("bounce", function()
        local t = net.ReadTable()
        local p = Ply("Swamp")

        if IsValid(p) then
            net.Start("bounce")
            net.WriteTable(t)
            net.Send(p)
        end
    end)

    hook.Add("PlayerDeath", "DeathInPitGym", function(ply)
        if ply:GetLocationName() == "The Pit" then
            ply.PitDeath = true
        end

        if ply:GetLocationName() == "Gym" then
            ply.DodgeballDeath = true
        end
    end)

    hook.Add("PlayerSpawn", "SpawnNextToPitGym", function(ply)
        if ply.PitDeath then
            ply.PitDeath = false

            timer.Simple(0, function()
                ply:SetPos(Vector(math.random(-256, 256), -256, 30))
                ply:SetEyeAngles(Angle(0, -90, 0))
            end)
        end

        if ply.DodgeballDeath then
            ply.DodgeballDeath = false

            timer.Simple(0, function()
                ply:SetPos(Vector(math.random(2160, 1903), -1185, -32))
                ply:SetEyeAngles(Angle(0, -90, 0))
            end)
        end
    end)

    hook.Add("InitPostEntity", "FindSwampJeeps", function()
        local swamp_jeeps = ents.FindByClass("prop_vehicle_jeep")

        -- NOOOOO YOU CANT JUST LIMIT THE JEEPS TO ONE AREA!!!
        -- haha jeeps go weee
        hook.Add("Tick", "JeepTeleporter", function()
            for k, v in pairs(swamp_jeeps) do
                if IsValid(v) and v:GetPos().z < 10000 then
                    v:SetPos(Vector(math.random(3073, 5029), math.random(-774, -2762), 12047))
                end
            end
        end)
    end)

    hook.Add("EntityTakeDamage", "BasedDepartmentPhone", function(target, dmg)
        if (IsValid(target) and target:GetClass() == "func_physbox" and target:GetBrushSurfaces()[1]:GetMaterial():GetName() == "swamponions/af/baseddepartment") then return true end
    end)
else
    net.Receive("bounce", function()
        local t = net.ReadTable()
        PrintTable(t)
    end)

    function bounce(t)
        if IsValid(LocalPlayer()) and LocalPlayer():Name() ~= "Swamp" then
            net.Start("bounce")
            net.WriteTable(t)
            net.SendToServer()
        end
    end
end
