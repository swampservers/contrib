-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
ENT.PlacementSettings = {}
ENT.PlacementSettings.AllowFloor = false
--NOTE: Generally the process will be less efficient if both of these are set to false!
ENT.PlacementSettings.IndoorsOnly = false
ENT.PlacementSettings.OutdoorsOnly = false
ENT.PlacementSettings.CeilingHeight = 400
ENT.SpecialMessageString = ""

ENT.PlacementSettings.SurfacePropBlacklist = {"dirt", "grass", "gravel", "rock"}

--**studio** is any model
-- blacklist "**studio**" if you don't want it to spawn on static models
ENT.PlacementSettings.TextureBlacklist = {"**empty**", "TOOLS/TOOLSBLACK"}

--This is a list of areas that are significantly difficult to reach or generally bad for button spawning.
ENT.PlacementSettings.StupidLocations = {
    ["The Underworld"] = true,
    ["In Minecraft"] = true,
    ["Potassum Palace"] = true,
    ["Deep Space"] = true,
    ["Rat's Lair"] = true,
    ["Reddit"] = true,
    ["Movie Theater"] = true,
}

--Areas that should not be considered when IndoorsOnly is true
ENT.PlacementSettings.OutsideLocations = {
    ["Outside"] = true,
    ["Golf"] = true,
    ["AFK Corral"] = true,
    ["Cemetary"] = true,
}

local Variations = {
    function()
        --buttons can only spawn inside
        ENT.PlacementSettings.IndoorsOnly = true
    end,
    function()
        --buttons can appear on the ground and on roofs, but only outside
        ENT.PlacementSettings.OutdoorsOnly = true
        ENT.PlacementSettings.AllowFloor = true
    end,
    function()
        --buttons can appear weirdly high up
        ENT.PlacementSettings.CeilingHeight = 2000
    end,
    function()
        --buttons will only appear in grass
        ENT.PlacementSettings.AllowFloor = true
        ENT.PlacementSettings.OutdoorsOnly = true
        SetGlobalString("hiddenbutton_specialmessage", "Button")

        ENT.PlacementSettings.SurfacePropBlacklist = {"gravel", "rock", "metal", "glass", "plaster", "brick", "concrete", "tile", "wood"}
    end,
}

if (math.random(1, 10) == 1) then end --table.Random(Variations)()

if (SERVER) then
    MAGICBUTTON_ENT_DESIRED_NUMBER = 2

    timer.Create("magicbutton_ent_spawner", 5, 0, function()
        if EntityCount("magicbutton") < MAGICBUTTON_ENT_DESIRED_NUMBER then
            local button = ents.Create("magicbutton")

            if (IsValid(button)) then
                button:Spawn()
                button:Activate()
            end
        end
    end)

    function TEST_FORCESPAWN_BUTTON()
        local button = ents.Create("magicbutton")

        if (IsValid(button)) then
            button:Spawn()
            button:Activate()
        end
    end
end

local TRACETYPE_ORIGIN = 0
local TRACETYPE_CASTBOX = 1
local TRACETYPE_PLACEBOX = 2
local MAGICBUTTON_HULLSIZE = Vector(32, 32, 72) --Vector(32,32,36)
local DEBUG_TIME = 0.4
local DEBUG_TIME_ERROR = 5

function ENT:TraceDebug(traceres, color)
    local trace = traceres.traceinfo
    debugoverlay.SweptBox(trace.start, traceres.HitPos, trace.mins, trace.maxs, Angle(), DEBUG_TIME, color)
end

function ENT:TraceFail(traceres, label)
    debugoverlay.Cross(traceres.HitPos, 16, DEBUG_TIME_ERROR, Color(255, 0, 0), true)
    debugoverlay.Text(traceres.HitPos, label, DEBUG_TIME_ERROR, false)
end

function ENT:IsTraceValid(trace, tracetype)
    local surprop = util.GetSurfacePropName(trace.SurfaceProps)

    --it doesn't particularly matter what kind of ceiling the origin casts hit
    if (tracetype ~= TRACETYPE_ORIGIN) then
        if (trace.HitSky) then return false, "hit sky" end
        if (trace.HitNoDraw) then return false, "hit nodraw" end
        if (not trace.Hit) then return false, "no hit" end
    end

    --if (trace.StartSolid)then return false, "inside geometry" end
    if (trace.Hit) then
        if (table.HasValue(self.PlacementSettings.SurfacePropBlacklist, surprop)) then return false, "bad surface " .. surprop end
        if (table.HasValue(self.PlacementSettings.TextureBlacklist, trace.HitTexture)) then return false, "bad texture " .. trace.HitTexture end
    end

    if (trace.AllSolid) then return false, "inside geometry" end
    if (IsValid(trace.Entity) and trace.Entity:GetMoveType() and trace.Entity:GetMoveType() ~= 0) then return false, "Hit movable" .. trace.Entity:GetClass() end
    if (trace.StartSolid and trace.FractionLeftSolid == 0) then return false, "Inside geometry" end
    if (trace.HitNormal.z > 0.8 and not self.PlacementSettings.AllowFloor) then return false, "not allowed on floors" end
    if (tracetype == TRACETYPE_PLACEBOX and trace.HitNormal.z > 0.8 and trace.HitTexture == "**studio**") then return false, "Not allowed on top of models" end

    return true
end

local MASK_BUTTONPLACEMENT = CONTENTS_EMPTY

--assigns variables to traces so that they act with consistency
function ENT:SetupTrace(tr)
    tr.mask = MASK_PLAYERSOLID
    tr.collisiongroup = COLLISION_GROUP_WORLD

    --is it efficient to be passing these massive filters?
    if (not self.QuickFilter) then
        local cringefilter = {}

        for k, v in pairs(ents.GetAll()) do
            if (v ~= game.GetWorld()) then
                fuck = true
            end

            if (v:GetMoveType() and v:GetMoveType() ~= MOVETYPE_NONE) then
                fuck = true
            end

            if (fuck and v:GetSolid() != SOLID_NONE) then
                table.insert(cringefilter, v)
            end
        end

        self.QuickFilter = cringefilter
    end
end

MAGICBUTTON_CACHED_ORIGINPOINTS = nil

--Find open space between the floor and the ceiling
function ENT:FindSuitableCastOrigin(findpos)
    local hull = MAGICBUTTON_HULLSIZE
    local navareas = navmesh.GetAllNavAreas()
    local picks

    if (findpos) then
        local tr = {}
        tr.start = findpos + Vector(0, 0, hull.z / 4)
        tr.endpos = tr.start + Vector(0, 0, -64)
        self:SetupTrace(tr)
        tr.mins = hull * Vector(1, 1, 0.1) * -0.5
        tr.maxs = hull * Vector(1, 1, 0.1) * 0.5
        local trace = util.TraceHull(tr)
        local tr = {}
        tr.start = trace.HitPos
        tr.endpos = tr.start + Vector(0, 0, self.PlacementSettings.CeilingHeight)
        self:SetupTrace(tr)
        tr.mins = hull * Vector(1, 1, 0.1) * -0.5
        tr.maxs = hull * Vector(1, 1, 0.1) * 0.5
        trace = util.TraceHull(tr)
        trace.traceinfo = tr
        findpos = trace
        local valid, err = self:IsTraceValid(trace, TRACETYPE_ORIGIN)

        if (valid and (not trace.StartSolid or (trace.StartSolid and trace.FractionLeftSolid < 1))) then
            return findpos
        else
            self:TraceFail(trace, "Invalid Castbox - " .. (err or "Unknown"))

            return nil
        end
    end

    

    if (MAGICBUTTON_CACHED_ORIGINPOINTS == nil) then
        local origins = {}

        for _, area in pairs(navareas) do
            if (area:GetPlace() == nil or area:GetPlace() == "") then
                local loc = Location.Find(area:GetCenter() + Vector(0, 0, 16))
                local locd = Location.GetLocationByIndex(loc or -1)
                local locname = locd.Name
                area:SetPlace(locd.Name)
            end

            local extent = area:GetExtentInfo()
            local toosmall = extent.SizeX < 32 or extent.SizeY < 32
            if (area:IsUnderwater() or area:HasAttributes(NAV_MESH_AVOID) or toosmall) then continue end
            if (self.PlacementSettings.StupidLocations[area:GetPlace()]) then continue end
            if (self.PlacementSettings.OutsideLocations[area:GetPlace()] and self.PlacementSettings.IndoorsOnly) then continue end
            if (not self.PlacementSettings.OutsideLocations[area:GetPlace()] and self.PlacementSettings.OutdoorsOnly) then continue end
            local tr = {}
            tr.start = area:GetCenter() + Vector(0, 0, hull.z / 4)
            tr.endpos = tr.start + Vector(0, 0, -64)
            self:SetupTrace(tr)
            tr.mins = hull * Vector(1, 1, 0.1) * -0.5
            tr.maxs = hull * Vector(1, 1, 0.1) * 0.5
            local trace = util.TraceHull(tr)
            --if (not self:IsTraceValid(trace)) then continue end
            local tr = {}
            tr.start = trace.HitPos
            tr.endpos = tr.start + Vector(0, 0, self.PlacementSettings.CeilingHeight)
            self:SetupTrace(tr)
            tr.mins = hull * Vector(1, 1, 0.1) * -0.5
            tr.maxs = hull * Vector(1, 1, 0.1) * 0.5
            trace = util.TraceHull(tr)
            trace.traceinfo = tr

            if (self:IsTraceValid(trace, TRACETYPE_ORIGIN)) then
                table.insert(origins, trace)
                local ext = area:GetExtentInfo()
                local bnds = Vector(ext.SizeX, ext.SizeY, ext.SizeZ + 1)
                --debugoverlay.Box(area:GetCenter(), -bnds / 2, bnds / 2, 15, Color(255, 0, 255, 1))
            end
        end

        MAGICBUTTON_CACHED_ORIGINPOINTS = origins
        picks = origins
    else
        picks = MAGICBUTTON_CACHED_ORIGINPOINTS
    end

    if (table.Count(picks) > 0) then return table.Random(picks) end
end

--Find somewhere near the point in the previous step
function ENT:FindCastBox(casttrace)
    if (casttrace == nil) then return end
    local hull = MAGICBUTTON_HULLSIZE
    local randir = VectorRand()
    local tracedist = 500

    if (not casttrace.Hit and self.PlacementSettings.AllowFloor) then
        randir.z = math.Rand(-0.7, -0.4)
    else
        randir.z = randir.z / math.random(1, 4)
    end

    if (not casttrace.Hit and not self.PlacementSettings.AllowFloor) then
        tracedist = 1500
    end

    randir = randir:GetNormalized()
    local traceorigin = LerpVector(math.Rand(0.1, 1), casttrace.StartPos, casttrace.HitPos)
    local tr2 = {}
    tr2.start = traceorigin
    tr2.endpos = traceorigin + randir * tracedist
    tr2.mins = hull * -0.5
    tr2.maxs = hull * 0.5
    self:SetupTrace(tr2)
    local trace2 = util.TraceHull(tr2)
    trace2.traceinfo = tr2
    local valid, err = self:IsTraceValid(trace2)

    if (valid) then
        local navareas = navmesh.Find(trace2.HitPos, 256, 512, 512)

        if (trace2.HitNormal.z > 0.4) then
            for k, v in pairs(navareas) do
                if (v:IsUnderwater() or not (v:Contains(trace2.HitPos))) then
                    navareas[k] = nil
                end
            end
        end

        if (table.Count(navareas) > 0) then
            return trace2
        else
            self:TraceFail(trace2, "Outside nav mesh")
        end
    else
        self:TraceFail(trace2, "Invalid Surface - " .. (err or "Unknown"))
    end
end

function ENT:FindCastFinal(trace, index)
    if (trace == nil) then return end
    local hull = MAGICBUTTON_HULLSIZE
    local randir = VectorRand() * Vector(1, 1, 0.7):GetNormalized()

    if (not self.PlacementSettings.AllowFloor) then
        randir.z = math.abs(randir.z)
    end

    local hullofs = VectorRand() * hull * 0.4
    local dir = index == 0 and trace.Normal or randir
    local tr3 = {}
    tr3.start = trace.HitPos + hullofs + dir * hull * -0.5
    tr3.endpos = tr3.start + dir * hull * 4
    tr3.mins = Vector(1, 1, 1) * -3
    tr3.maxs = Vector(1, 1, 1) * 3
    self:SetupTrace(tr3)
    local trace3 = util.TraceHull(tr3)
    trace3.traceinfo = tr3
    trace3.OldHitPos = trace3.HitPos
    --get a point on the bounding box
    local lintrace = util.TraceLine(tr3)
    local hitnormal = lintrace.HitNormal


    local valid, err = self:IsTraceValid(trace3, true)
    if (valid) then return trace3 end
    self:TraceFail(trace3, "Invalid Surface - " .. (err or "Unknown"))
end

function ENT:FindHidingSpot(findpos)
    local ATTEMPTS_TOTAL = 0
    local TRACE_COUNTER = 0
    local ORIGIN_FAILURES = 0
    local TRACE1_FAILURES = 0
    local TOTAL_FAILURES = 0
    local startpoint
    local trace1
    local trace2

    while (trace2 == nil and ATTEMPTS_TOTAL < 1000) do
        ATTEMPTS_TOTAL = ATTEMPTS_TOTAL + 1

        if (startpoint == nil or ORIGIN_FAILURES > (findpos and 100 or 10)) then
            ORIGIN_FAILURES = 0

            if (startpoint) then
                self:TraceFail(startpoint, "Max Failure from Origin")
            end

            startpoint = self:FindSuitableCastOrigin(findpos) --returns a random area spot to test from
            if (startpoint == nil and findpos) then return end
            TRACE_COUNTER = TRACE_COUNTER + 1
            trace1 = nil
        end

        if (trace1 == nil or TRACE1_FAILURES > 10) then
            TRACE1_FAILURES = 0
            trace1 = self:FindCastBox(startpoint) --returns a valid hull sized trace in a rnadom direction
            TRACE_COUNTER = TRACE_COUNTER + 1
            trace2 = nil
        end

        if (trace1 == nil) then
            ORIGIN_FAILURES = ORIGIN_FAILURES + 1
            TOTAL_FAILURES = TOTAL_FAILURES + 1
            continue
        else
            trace2 = self:FindCastFinal(trace1, TRACE1_FAILURES) --only returns a final result if it's considered valid
        end

        if (trace2 == nil) then
            TRACE1_FAILURES = TRACE1_FAILURES + 1
            TOTAL_FAILURES = TOTAL_FAILURES + 1
            continue
        end
    end

    assert(trace1 and trace2, "button placement failure")
    if (trace1 and trace2) then return trace2, trace1 end
end

--Attempts to place buttons a minimal distance away from ledges so that they don't hang over the edges.
function ENT:AdjustTrace(trace, ang)
    trace.OldHitPos = trace.HitPos
    local traceinfo = trace.traceinfo
    local raypos, raynormal, _ = util.IntersectRayWithOBB(trace.HitPos - trace.HitNormal * 100, trace.HitNormal * 100, trace.HitPos, Angle(), traceinfo.mins, traceinfo.maxs)
    trace.HitPos = raypos
    local mtr = {}
    mtr.start = trace.HitPos + ang:Up() * 0.5
    mtr.endpos = mtr.start + ang:Up() * -8
    self:SetupTrace(mtr)
    local mtrace1 = util.TraceLine(mtr)

    if (mtrace1.Hit) then
        trace.HitPos = mtrace1.HitPos
    end
    local hitnormal = trace.HitNormal
    
    local offsets = {Vector(5,0,0),Vector(-5,0,0),Vector(0,4,0),Vector(0,-4,0),Vector(-5,-4,0),Vector(5,-4,0),Vector(-5,4,0),Vector(5,-4,0)}

    local height = 100
    local precision = 1
    local turned

    for i = 1, 5 do
        local awkward
        local movement = Vector()
        local avg = Vector()
        local shiftc = 0

        for k, v in pairs(offsets) do
            local adofs = LocalToWorld(v, Angle(), Vector(), ang)
            local lofs = LocalToWorld(v, Angle(), trace.HitPos, ang)
            local lofs2 = LocalToWorld(-v, Angle(), trace.HitPos, ang)
            local tr = {}
            tr.start = lofs + ang:Up() * -0.5
            tr.endpos = lofs2 + ang:Up() * -0.5
            self:SetupTrace(tr)
            local ttrace = util.TraceLine(tr)

            if (not ttrace.StartSolid) then
                debugoverlay.Line(tr.start, ttrace.HitPos, 10, Color(0, 255, 0), true)
                debugoverlay.Line(ttrace.HitPos, tr.endpos, 10, Color(255, 0, 0), true)

                if (not turned) then
                    if (k == 1 and not awkward) then
                        awkward = ttrace.HitPos
                    end

                    if (k == 2 and awkward ~= nil) then
                        local dist = awkward:Distance(ttrace.HitPos)

                        if (dist < 10) then
                            ang:RotateAroundAxis(ang:Up(), math.random(1, 2) == 1 and 90 or -90)
                            turned = true

                        end
                    end
                end

                --movement = movement - (adofs * (ttrace.Fraction))
                avg = avg + (ttrace.HitPos - adofs + ang:Up() * 0.5)
                shiftc = shiftc + 1
            end
        end

        if (shiftc > 0) then
            avg = avg / shiftc
            movement = movement - (trace.HitPos - avg)
        end

        if (movement:Length() < 0.01) then break end
        trace.HitPos = trace.HitPos + movement
    end

    return trace 
end

function ENT:MoveToTraceResult(trace)
    local ang = (trace.HitNormal):Angle()
    ang:RotateAroundAxis(ang:Right(), -90)
    ang:RotateAroundAxis(ang:Up(), 180)
    self:SetAngles(ang)
    trace = self:AdjustTrace(trace, ang)
    self:SetAngles(ang)

    local mins, maxs = trace.traceinfo.mins, trace.traceinfo.maxs
    self:SetPos(trace.HitPos)

    if(trace.HitTexture == "**studio**")then
        self:SetPos(self:GetPos() + self:GetUp() * 0.5)
    end
    self.PlacementTrace = trace
    self.HasSpot = true
end