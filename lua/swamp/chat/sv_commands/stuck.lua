-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local function AppropriateNavArea(ply, area)
    if not IsValid(area) then return false end
    local mins, maxs = ply:GetCollisionBounds()
    if area:GetSizeX() < maxs.x * 2 or area:GetSizeY() < maxs.z * 2 then return false end
    local mins, maxs = ply:GetCollisionBounds()
    local tr = {}
    tr.start = area:GetCenter() + Vector(0, 0, 1)
    tr.endpos = area:GetCenter()

    tr.filter = function(ent)
        if ent == ply then return false end
        local should = hook.Call("ShouldCollide", nil, ply, ent) or true

        return should
    end

    tr.mins = mins
    tr.maxs = maxs
    local trace = util.TraceHull(tr)
    if trace.StartSolid then return false end

    return true
end

-- multiply disance along an axis, so we can  
local function biasdist(pos1, pos2, biasvec)
    return (pos1 * biasvec):Distance(pos2 * biasvec)
end

function Player:IsStuck()
    if self:InVehicle() then return false end
    local mins, maxs = self:GetCollisionBounds()
    local tr = {}
    tr.start = self:GetPos()
    tr.endpos = tr.start + self:GetVelocity() * FrameTime()

    tr.filter = function(ent)
        if ent == self then return false end
        local should = hook.Call("ShouldCollide", nil, self, ent) or true

        return should
    end

    tr.mins = mins
    tr.maxs = maxs
    local trace = util.TraceHull(tr)
    if trace.StartSolid then return true end

    return false
end

function Player:UnStick()
    --reuse the last spot they were placed if this happens frequently
    if self.LastUnstickSpot and self:GetPos():Distance(self.LastUnstickSpot) < 200 then
        self:SetPos(self.LastUnstickSpot)
        self.LastUnstickSpot = nil

        return true
    end

    if not self:IsStuck() then return end
    local areas
    local testedareas = 0
    local bestarea
    local bestareapos = Vector(0, 0, 160000)
    --least aggressive
    bestarea = navmesh.GetNearestNavArea(self:GetPos(), false, 1000, true, true)

    if IsValid(bestarea) and not AppropriateNavArea(self, bestarea) then
        bestarea = nil
    end

    --more aggressive
    if not IsValid(bestarea) then
        areas = navmesh.Find(self:GetPos(), 512, 512, 64)

        for k, area in pairs(areas) do
            if AppropriateNavArea(self, area) then
                if bestarea == nil or biasdist(self:GetPos(), area:GetCenter(), Vector(1, 1, 8)) < biasdist(self:GetPos(), bestareapos, Vector(1, 1, 8)) then
                    bestarea = area
                    bestareapos = area:GetCenter()
                end
            else
                testedareas = testedareas + 1
            end
        end
    end

    --most aggressive
    if not IsValid(bestarea) then
        areas = navmesh.GetAllNavAreas()

        for k, area in pairs(areas) do
            if AppropriateNavArea(self, area) then
                if bestarea == nil or self:GetPos():Distance(area:GetCenter()) < self:GetPos():Distance(bestareapos) then
                    bestarea = area
                    bestareapos = area:GetCenter()
                end
            else
                testedareas = testedareas + 1
            end
        end
    end

    if bestarea then
        self:SetPos(bestarea:GetCenter() + Vector(0, 0, 16))
        self.LastUnstickSpot = bestarea:GetCenter() + Vector(0, 0, 16)
        self:DropToFloor()

        return true
    else
        return false
    end
end

RegisterChatCommand({'stuck', 'unstuck', 'unstick'}, function(ply, arg)
    if IsValid(ply) and not ply:InVehicle() and ply:Alive() then
        local worked = ply:UnStick()
        local msg = worked == true and "Unstuck!" or worked == false and "Couldn't Unstick! Try to /tp to another player!" or worked == nil and "You don't appear to be stuck."
        ply:ChatPrint(msg)
    end
end, {
    global = false,
    throttle = true
})
