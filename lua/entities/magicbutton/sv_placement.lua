-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
ENT.PlacementSettings = {}
ENT.PlacementSettings.RequireCeiling = false
ENT.PlacementSettings.AllowFloor = false
--NOTE: Generally the process will be less efficient if both of these are set to false!

ENT.PlacementSettings.IndoorsOnly = false

ENT.PlacementSettings.CeilingHeight = 400

ENT.PlacementSettings.SurfacePropBlacklist = {"dirt", "grass", "gravel", "rock"}

--**studio** is any model
ENT.PlacementSettings.TextureBlacklist = {"**empty**", "TOOLS/TOOLSBLACK", "**studio**"}

--Areas that should never be considered for button spawning
ENT.PlacementSettings.StupidLocations = {
    ["The Underworld"] = true,
     ["In Minecraft"]=true,
     ["Deep Space"] = true,
    } 

--Areas that should not be considered when IndoorsOnly is true
ENT.PlacementSettings.OutsideLocations = {
    ["Outside"]=true,
    ["Golf"]=true,
    ["AFK Corral"]=true,
    ["Cemetary"]=true,
}
 


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

local MAGICBUTTON_HULLSIZE = Vector(32, 32, 72) --Vector(32,32,36)

function ENT:IsTraceValid(trace, final)
    local surprop = util.GetSurfacePropName(trace.SurfaceProps)
    if (table.HasValue(self.PlacementSettings.SurfacePropBlacklist, surprop)) then return false end
    if (table.HasValue(self.PlacementSettings.TextureBlacklist, trace.HitTexture)) then return false end
    if (not trace.Hit) then return false end
    if (trace.HitSky) then return false end
    if (trace.HitNoDraw) then return false end
    if (IsValid(trace.Entity)) then return false end
    if (trace.AllSolid) then return false end
    if (trace.StartSolid and trace.FractionLeftSolid == 0) then return false end

    if (not self.PlacementSettings.AllowFloor) then
        if (final and trace.HitNormal.z > 0.8) then return false end
    end

    return true
end

--MAGICBUTTON_CACHED_ORIGINPOINTS = nil
function ENT:FindSuitableCastOrigin()
    local hull = MAGICBUTTON_HULLSIZE
    if (IsValid(self:GetOwner())) then end --return self:GetPos() + Vector(0,0,64)
    local navareas = navmesh.GetAllNavAreas()
    local picks

    if (MAGICBUTTON_CACHED_ORIGINPOINTS == nil) then
        local origins = {}
 
        for _, area in pairs(navareas) do
            if(area:GetPlace() == nil or area:GetPlace() == "")then
                local loc = Location.Find(area:GetCenter() + Vector(0,0,16))
                local locd = Location.GetLocationByIndex(loc or -1)
                local locname = locd.Name
                area:SetPlace(locd.Name)
            end
            local extent = area:GetExtentInfo()
            local toosmall = extent.SizeX < 32 or extent.SizeY < 32
            if (area:IsUnderwater() or area:HasAttributes(NAV_MESH_AVOID) or toosmall) then continue end
            if(self.PlacementSettings.StupidLocations[area:GetPlace()])then continue end 
            if(self.PlacementSettings.OutsideLocations[area:GetPlace()] and self.PlacementSettings.IndoorsOnly)then continue end 

            local tr = {}
            tr.start = area:GetCenter() + Vector(0, 0, hull.z / 4)
            tr.endpos = tr.start + Vector(0, 0, -64)
            tr.mask = MASK_PLAYERSOLID
            tr.mins = hull * Vector(1, 1, 0.1) * -0.5
            tr.maxs = hull * Vector(1, 1, 0.1) * 0.5
            local trace = util.TraceHull(tr)
            if (not self:IsTraceValid(trace)) then continue end
            local tr = {}
            tr.start = trace.HitPos
            tr.endpos = tr.start + Vector(0, 0, self.PlacementSettings.CeilingHeight)
            tr.mask = MASK_PLAYERSOLID
            tr.mins = hull * Vector(1, 1, 0.1) * -0.5
            tr.maxs = hull * Vector(1, 1, 0.1) * 0.5
            trace = util.TraceHull(tr)

            if ((not self.PlacementSettings.RequireCeiling or (trace.Hit and self:IsTraceValid(trace))) and not trace.StartSolid or (trace.StartSolid and trace.FractionLeftSolid < 1)) then
                table.insert(origins, trace)
                -- local ext = area:GetExtentInfo()
                -- local bnds = Vector(ext.SizeX, ext.SizeY, ext.SizeZ + 1)
                -- debugoverlay.Box(area:GetCenter() + Vector(0, 0, 0.5), bnds * -0.5, bnds * 0.5, 60, Color(0, 0, 255, 0))
                -- else
                --debugoverlay.SweptBox( tr.start, trace.HitPos, tr.mins, tr.maxs, Angle(), 60, Color( 255, 0, 255,0 ) )
            end
        end

        MAGICBUTTON_CACHED_ORIGINPOINTS = origins
        picks = origins
    else
        picks = MAGICBUTTON_CACHED_ORIGINPOINTS
    end

    if (table.Count(picks) > 0) then return table.Random(picks) end
end

function ENT:FindCastBox(casttrace)
    if (casttrace == nil) then return end
    local hull = MAGICBUTTON_HULLSIZE
    -- debugoverlay.SweptBox(casttrace.StartPos, casttrace.HitPos, hull * Vector(1, 1, 0.1) * -0.5, hull * Vector(1, 1, 0.1) * 0.5, Angle(), 60, Color(255, 0, 0, 0))
    local randir = VectorRand()

    if (not casttrace.Hit) then
        randir.z = math.Rand(-0.5, -0.1)
    else
        randir.z = randir.z / 4
        randir = randir:GetNormalized()
    end

    if (not self.PlacementSettings.AllowFloor and self.PlacementSettings.RequireCeiling) then
        randir.z = math.abs(randir.z)
    end

    randir = randir:GetNormalized()
    local traceorigin = LerpVector(math.Rand(0.1, 0.4), casttrace.StartPos, casttrace.HitPos)
    local tr2 = {}
    tr2.start = traceorigin
    tr2.endpos = traceorigin + randir * 500
    tr2.mins = hull * -0.5
    tr2.maxs = hull * 0.5
    tr2.mask = MASK_PLAYERSOLID
    local trace2 = util.TraceHull(tr2)

    if (self:IsTraceValid(trace2)) then
        local navareas = navmesh.Find(trace2.HitPos, 128, 256, 256)

        for k, v in pairs(navareas) do
            if (v:IsUnderwater() or not v:Contains(trace2.HitPos)) then
                navareas[k] = nil
            end
        end

        if (table.Count(navareas) > 0) then return trace2 end -- debugoverlay.SweptBox(tr2.start, trace2.HitPos, tr2.mins, tr2.maxs, Angle(), 60, Color(0, 255, 0, 0)) -- else -- debugoverlay.SweptBox(tr2.start, trace2.HitPos, tr2.mins, tr2.maxs, Angle(), 60, Color(0, 128, 0, 0))
    else
        -- debugoverlay.SweptBox(tr2.start, trace2.HitPos, tr2.mins, tr2.maxs, Angle(), 60, Color(0, 128, 0, 0))
    end
end

function ENT:FindCastFinal(trace, index)
    if (trace == nil) then return end
    local hull = MAGICBUTTON_HULLSIZE
    local randir = VectorRand() * Vector(1, 1, 0.7):GetNormalized()

    if (not self.PlacementSettings.AllowFloor and self.PlacementSettings.RequireCeiling) then
        randir.z = math.abs(randir.z)
    end

    local hullofs = VectorRand() * hull * 0.4
    local dir = index == 0 and trace.Normal or randir
    local tr3 = {}
    tr3.start = trace.HitPos + hullofs + dir * hull * -0.5
    tr3.endpos = tr3.start + dir * hull * 4
    tr3.mask = MASK_PLAYERSOLID
    local trace3 = util.TraceLine(tr3)
    if (self:IsTraceValid(trace3, true)) then return trace3 end -- debugoverlay.SweptBox(tr3.start, trace3.HitPos, Vector(1, 1, 1) * -1, Vector(1, 1, 1), Angle(), 60, Color(0, 0, 255, 0)) -- else --     debugoverlay.SweptBox(tr3.start, trace3.HitPos, Vector(1, 1, 1) * -1, Vector(1, 1, 1), Angle(), 60, Color(0, 0, 128, 0))
end

function ENT:FindHidingSpot()
    local ATTEMPTS_TOTAL = 0
    local TRACE_COUNTER = 0
    local ORIGIN_FAILURES = 0
    local TRACE1_FAILURES = 0
    local TOTAL_FAILURES = 0
    local startpoint
    local trace1
    local trace2

    while (trace2 == nil and ATTEMPTS_TOTAL < 10000) do
        ATTEMPTS_TOTAL = ATTEMPTS_TOTAL + 1

        if (startpoint == nil or ORIGIN_FAILURES > 10) then
            ORIGIN_FAILURES = 0
            startpoint = self:FindSuitableCastOrigin() --returns a random area spot to test from
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

    if (trace1 and trace2) then return trace2, trace1 end
    Error()
end

function ENT:MoveToTraceResult(trace)
    self:SetPos(trace.HitPos)
    local ang = trace.HitNormal:Angle()
    ang:RotateAroundAxis(ang:Right(), -90)
    ang:RotateAroundAxis(ang:Up(), 180)
    self.PlacementTrace = trace
    self:SetAngles(ang)
    self.HasSpot = true
end