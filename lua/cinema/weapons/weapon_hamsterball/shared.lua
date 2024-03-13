-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SWEP.PrintName = "Hamster Ball (WIP)"
SWEP.Slot = 4
SWEP.ViewModel = Model("")
SWEP.WorldModel = Model("")
SWEP.CannotDrop = true

--NOMINIFY
function SWEP:PrimaryAttack()
    if CLIENT then return end

    -- self:ExtEmitSound("npc/headcrab/attack1.wav", {
    --     speech = 0.7,
    --     shared = true
    -- })
    self:ExtEmitSound(table.Random(headcrabsounds), {
        speech = 0.7,
    })
    -- shared = true
end

function SWEP:SecondaryAttack()
    if CLIENT then return end

    -- self:ExtEmitSound("npc/barnacle/barnacle_gulp1.wav", {
    --     speech = 0.7,
    --     shared = true
    -- })
    self:ExtEmitSound(table.Random(headcrabsounds3), {
        speech = 0.7,
    })
    -- shared = true
end

function SWEP:Reload()
    if CLIENT then return end
    if (self.Owner.NextGamerWord or 0) > CurTime() then return end
    self.Owner.NextGamerWord = CurTime() + 2

    self:ExtEmitSound("keem/stupidbitch.ogg", {
        speech = 0.7,
        pitch = 190,
    })
end

-- models/props_phx/ball.mdl
-- models/props_phx/cannonball.mdl
-- models/props_phx/cannonball_solid.mdl
-- models/shadertest/shader3
-- models/hunter/misc/sphere075x075.mdl
-- models/hunter/misc/sphere1x1.mdl
-- models/hunter/misc/cone4x2mirrored.mdl
function SWEP:Deploy()
    self.IsHolstered = false

    if SERVER then
        BroadcastLua([[
            local wep = Entity(]] .. self:EntIndex() .. [[)
            if IsValid(wep) and wep.Deploy then
                wep:Deploy(wep)
            end
        ]])
    end

    return true
end

local vector_hull_mins = Vector(-16, -16, 0)
local vector_hull_maxs = Vector(16, 16, 72)

function SWEP:Holster()
    if self.IsHolstered then return true end
    self.IsHolstered = true

    if SERVER then
        local owner = self:GetOwner()
        if not IsValid(owner) then return true end
        --owner:UnSpectate()
        owner:SetModelScale(1)
        owner:DrawShadow(true) -- TODO: Shadow from playermodel appears, disconnected from the hamsterball model...because we don't have proper working prediction
        -- Fix owner position on exit (they'll be clipped into things otherwise, or get themselves out of the map)
        -- TODO: Improve the PLAYER.UnStick function with this (just using UnStick leads to us being teleported out of the sewers entirely, for example)
        -- NOTE(winter): Disabled because people want it to be buggy as a "feature"
        --[[
        local pos = owner:GetPos()
        local newpos = Vector(pos.x, pos.y, navmesh.GetGroundHeight(pos))

        local tracedata = {
            start = newpos,
            endpos = newpos,
            filter = player.GetAll(),
            collisiongroup = COLLISION_GROUP_PLAYER,
            mins = vector_hull_mins,
            maxs = vector_hull_maxs
        }

        local tr = util.TraceHull(tracedata)

        if tr.Hit then
            local navarea = navmesh.GetNearestNavArea(pos, false, 256)

            if navarea then
                local randpos = navarea:GetRandomPoint()
                local _, groundnormal = navmesh.GetGroundHeight(randpos)

                for i = 0, 16 do
                    local testpos = randpos + groundnormal * i
                    tracedata.start = testpos
                    tracedata.endpos = testpos
                    tr = util.TraceHull(tracedata)

                    if not tr.Hit then
                        newpos = testpos
                        break
                    end
                end
            end
        end

        owner:SetPos(newpos)
        ]]
        -- Fix owner velocity being fucked up after exiting (spams prediction errors and shakes camera)
        owner:SetVelocity(Vector(0, 0, 1))

        if IsValid(self.Ball) then
            self.Ball:Remove()
        end

        BroadcastLua([[
            local wep = Entity(]] .. self:EntIndex() .. [[)
            if IsValid(wep) and wep.Holster then
                wep:Holster(wep)
            end
        ]])
    end

    return true
end
