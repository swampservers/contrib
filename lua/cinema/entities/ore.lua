-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Ore"
ENT.Author = "PYROTEKNIK"
ENT.Purpose = "Mine And Craft"
ENT.Category = "PYROTEKNIK"
ENT.Spawnable = true
ENT.PointsValue = 200
ENT.IsOre = true
ENT.AdminSpawnable = true
local PlacementSettings = {}
PlacementSettings.RequireCeiling = false
PlacementSettings.AllowFloor = false
--NOTE: Generally the process will be less efficient if both of these are set to false!
PlacementSettings.CeilingHeight = 256

PlacementSettings.SurfacePropWhitelist = {"dirt", "grass", "gravel", "rock"}

--**studio** is any model
PlacementSettings.TextureBlacklist = {"**empty**", "TOOLS/TOOLSBLACK"}

local function EntityCount(class)
    return table.Count(ents.FindByClass(class))
end

local function OreTrace(data)
    local org = data
    local dir = (VectorRand() * Vector(1, 1, 0.5)):GetNormalized()

    --handle trace
    if istable(data) and data.HitPos then
        local hitnormal = (data.HitNormal * Vector(1, 1, 0.25)):GetNormalized()
        local dir = data.Normal
        local refdir = (dir - 2 * dir:Dot(hitnormal) * hitnormal)
        org = data.HitPos
        --dir = LerpVector(0.4,refdir,dir):GetNormalized()
        dir = (hitnormal + VectorRand() + dir * 0.5):GetNormalized()
    end

    local tr = {
        start = org,
        endpos = org + dir * 2000,
        mask = MASK_PLAYERSOLID
    }

    local trace = util.TraceLine(tr)

    return trace
end

local function IsOreTraceValid(trace)
    if not trace.Hit then return false end
    local surprop = util.GetSurfacePropName(trace.SurfaceProps)
    if (not table.HasValue(PlacementSettings.SurfacePropWhitelist, surprop)) then return false end
    print(surprop)
    if (table.HasValue(PlacementSettings.TextureBlacklist, trace.HitTexture)) then return false end
    if (not trace.Hit) then return false end
    if (trace.HitSky) then return false end
    if (trace.HitNoDraw) then return false end
    if (IsValid(trace.Entity)) then return false end
    if (trace.AllSolid) then return false end
    if (trace.StartSolid and trace.FractionLeftSolid == 0) then return false end

    return true
end

ORE_CACHED_ORIGINPOINTS = nil
local ore_areas = {}
ore_areas["Caverns"] = true
ore_areas["Nowhere"] = true

local function OreOrigin()
    local hull = Vector(64, 64, 64)
    local navareas = navmesh.GetAllNavAreas()
    local picks

    --Cache good ore points
    if (ORE_CACHED_ORIGINPOINTS == nil) then
        local origins = {}

        for _, area in pairs(navareas) do
            local extent = area:GetExtentInfo()
            if not ore_areas[area:GetPlace()] then continue end
            if area:IsUnderwater() or area:HasAttributes(NAV_MESH_AVOID) or (extent.SizeX < 32 or extent.SizeY < 32) then continue end
            local tr = {}
            tr.start = area:GetCenter() + Vector(0, 0, hull.z / 4)
            tr.endpos = tr.start + Vector(0, 0, -64)
            tr.mask = MASK_PLAYERSOLID
            tr.mins = hull * Vector(1, 1, 0.1) * -0.5
            tr.maxs = hull * Vector(1, 1, 0.1) * 0.5
            local trace = util.TraceHull(tr)
            if (not IsOreTraceValid(trace)) then continue end
            local tr = {}
            tr.start = trace.HitPos
            tr.endpos = tr.start + Vector(0, 0, PlacementSettings.CeilingHeight)
            tr.mask = MASK_PLAYERSOLID
            tr.mins = hull * Vector(1, 1, 0.1) * -0.5
            tr.maxs = hull * Vector(1, 1, 0.1) * 0.5
            trace = util.TraceHull(tr)
            trace.area = area

            if (not PlacementSettings.RequireCeiling or (trace.Hit and IsOreTraceValid(trace))) and not trace.StartSolid or (trace.StartSolid and trace.FractionLeftSolid < 1) then
                table.insert(origins, trace)
                local ext = area:GetExtentInfo()
                local bnds = Vector(ext.SizeX, ext.SizeY, ext.SizeZ + 1)
                debugoverlay.Box(area:GetCenter() + Vector(0, 0, 0.5), bnds * -0.5, bnds * 0.5, 60, Color(0, 0, 255, 16))
                -- else
                --debugoverlay.SweptBox( tr.start, trace.HitPos, tr.mins, tr.maxs, Angle(), 60, Color( 255, 0, 255,0 ) )
            end
        end

        ORE_CACHED_ORIGINPOINTS = origins
        picks = origins
    else
        picks = ORE_CACHED_ORIGINPOINTS
    end

    if (table.Count(picks) > 0) then return table.Random(picks) end
end

if (SERVER) then
    concommand.Add("ore_showseeds", function()
        OreOrigin()

        for k, v in pairs(ORE_CACHED_ORIGINPOINTS) do
            print(v)
        end
    end)

    ORE_MAXNUMBER = 24

    timer.Create("ore_spawner", 3, 0, function()
        if EntityCount("ore") < ORE_MAXNUMBER then
            local pos = OreOrigin()
            local new_ore = SpawnOre(1, pos.HitPos)
        end
    end)
end

function SpawnOre(size, origin)
    local res
    local viter = 0
    local bt = 5
    local at = 1 / 16
    local org = origin

    local tr = {
        start = org,
        endpos = org + Vector(0, 0, 3000),
        mins = Vector(-16, -16, 0),
        maxs = Vector(16, 16, 0),
        mask = MASK_PLAYERSOLID
    }

    local mtrace = util.TraceHull(tr)

    if mtrace.StartSolid then
        mtrace = util.TraceLine(tr)
    end

    org = LerpVector(math.Rand(0.2, 0.5), org, mtrace.HitPos)

    for i = 1, 100 do
        local dir = VectorRand()
        dir.z = math.abs(dir.z)
        dir = (dir * Vector(1, 1, 0.5)):GetNormalized()

        local tr = {
            start = org,
            endpos = org + dir * 2000,
            mask = MASK_PLAYERSOLID
        }

        local trace = util.TraceLine(tr)
        local valid = IsOreTraceValid(trace)
        debugoverlay.Line(trace.StartPos, trace.HitPos, 1, valid and Color(0, 255, 0) or Color(255, 0, 0))

        if valid then
            local tr = {}
            tr.start = trace.HitPos + trace.HitNormal * 16
            tr.endpos = tr.start + Vector(0, 0, -PlacementSettings.CeilingHeight)
            tr.mask = MASK_PLAYERSOLID
            local ctrace = util.TraceLine(tr)
            local cv = ctrace.Hit
            debugoverlay.Line(ctrace.StartPos, ctrace.HitPos, 1, cv and Color(0, 255, 0) or Color(255, 0, 0), false)

            if cv then
                res = trace
                break
            end
        end
    end

    local pos
    local nrm = VectorRand()

    if istable(res) and res.HitPos then
        pos = res.HitPos
        nrm = res.HitNormal
    end

    if not pos then
        print("fail")

        return
    end

    local ore = ents.Create("ore")
    ore:SetPos(pos)
    ore:SetAngles(AngleRand())
    ore:Spawn()
    ore:Activate()
    ore.PlacementNormal = nrm
    debugoverlay.Box(ore:GetPos(), Vector(1, 1, 1) * -16, Vector(1, 1, 1) * 16, 5, Color(0, 255, 0, 4))

    return ore
end

if SERVER then
    concommand.Add("oretest", function(ply, cmd, args)
        SpawnOre(1, ply:EyePos())
    end)
end

function ENT:Initialize()
    if (SERVER) then
        self.Entity:SetModel("models/props_junk/rock001a.mdl")
        local bmins, bmaxs = Vector(-4.8, -3.1, 0), Vector(4.8, 3.1, 2)
        self:SetCollisionBounds(bmins, bmaxs)
        self.Entity:PhysicsInitBox(bmins, bmaxs)
        self.Entity:SetMoveType(MOVETYPE_NONE)
        self:SetColor(Color(255, 230, 51))
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()

        if (IsValid(phys)) then
            phys:EnableMotion(false)
        end

        timer.Simple(60 * 60, function()
            if (IsValid(self)) then
                self:Remove()
            end
        end)
    end

    self.EmbedDistance = self:BoundingRadius() * 0.7

    if (CLIENT) then
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetEntity(self)
        util.Effect("propspawn", effectdata)
    end
end

function ENT:SpawnFunction(ply, tr, ClassName)
    local ore = SpawnOre(1, tr.HitPos + tr.HitNormal * 32)

    return ore
end

function ENT:Draw()
    self.Rand = self.Rand or math.Rand(0, 1)
    local rand = self.Rand
    local pos = self:GetPos()
    render.SuppressEngineLighting(true)
    local shine = Vector(0.3, 0.18, 0)
    local shm = math.Remap(math.sin(math.rad(rand * 360 + CurTime() * 45)), -1, 1, 0, 1)
    shm = math.pow(shm, 8)
    shine = shine * shm
    local a = render.GetAmbientLightColor() + shine
    render.SetAmbientLight(a.x, a.y, a.z)
    local c = self:GetColor()
    local cvector = (Vector(c.r, c.g, c.b) / 255)
    local lc = render.GetLightColor(pos) + shine

    for i = 0, 5 do
        render.SetModelLighting(i, lc.x, lc.y, lc.z)
    end

    self:DrawModel()
    --render.SuppressEngineLighting( true )
    render.SuppressEngineLighting(false)
end

function ENT:DoHit(ply, tr, dmginfo)
    if CLIENT then
        self:AddSparkle(tr.HitPos, 0.15, 1)
        self:SpawnChunk(1, tr.HitNormal * Lerp(math.pow(math.Rand(0, 1), 3), 5, 50))
    end

    if SERVER then
        self:EmitSound("physics/concrete/concrete_impact_bullet" .. math.random(1, 4) .. ".wav", 150, 80, 100, 1, CHAN_ITEM)
        local tweak_angle = self:GetAngles()
        self.EmbedDistance = self.EmbedDistance or self:BoundingRadius()
        if self.EmbedDistance <= 0 then return end
        local extr_distance = self.EmbedDistance
        local md = dmginfo:GetDamage() * 0.25
        md = math.min(md, extr_distance)
        self.EmbedDistance = self.EmbedDistance - md
        local nv = (self.PlacementNormal or VectorRand()):Angle()
        local ax = VectorRand()
        local bn = math.Rand(-2, 2)
        tweak_angle:RotateAroundAxis(ax, bn)
        nv:RotateAroundAxis(ax, bn)
        self.PlacementNormal = nv:Forward()
        self:SetPos(self:GetPos() + (nv:Forward()) * md * 0.2)
        self:SetAngles(tweak_angle)

        if self.EmbedDistance <= 0 then
            self:PhysicsInit(SOLID_VPHYSICS)

            if ply.GivePoints then
                ply:GivePoints(self.PointsValue)
            end

            self:EmitSound("physics/concrete/concrete_break" .. math.random(2, 3) .. ".wav", 150, 140, 100, 1, CHAN_ITEM)
            self:GetPhysicsObject():Wake()
            self:GetPhysicsObject():SetVelocity(self.PlacementNormal:GetNormalized() * 100)
            self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            --self:GetPhysicsObject():EnableGravity(false)
            --self:GetPhysicsObject():EnableCollisions(false)
            SafeRemoveEntityDelayed(self, 0.03)
        end
    end
end

if CLIENT then
    function ENT:AddSparkle(pos, life, mul)
        pos = pos + (LocalPlayer():EyePos() - pos):GetNormalized() * 6
        local part = self.Sparkle:Add("pyroteknik/sparkle", pos) -- Create a new particle at pos

        if (part) then
            local c = self:GetColor()
            part:SetColor(c.r, c.g, c.b)
            part:SetDieTime(life or 1) -- How long the particle should "live"
            part:SetStartAlpha(255) -- Starting alpha of the particle
            part:SetEndAlpha(255) -- Particle size at the end if its lifetime
            part:SetStartSize(0) -- Starting size
            part:SetEndSize(16) -- Size when removed
            part:SetRollDelta(math.Rand(-4, 4))

            part:SetThinkFunction(function(pa)
                local pc = (pa:GetLifeTime() / pa:GetDieTime())
                local wc = math.sin(math.rad(pc * 180))
                pa:SetStartSize(wc * 16)
                pa:SetEndSize(wc * 16)
                local v = LerpVector(pc, Vector(255, 210, 0), Vector(0, 0, 0))
                pa:SetColor(v.x, v.y, v.z)
                pa:SetNextThink(CurTime())
            end)
        end
    end

    function ENT:Think()
        local pos = self:WorldSpaceCenter() + VectorRand() * 4
        self.Sparkle = self.Sparkle or ParticleEmitter(self:GetPos()) -- Particle emitter in this position
        self:AddSparkle(pos)
        self:SetNextClientThink(CurTime() + math.Rand(0.4, 3))

        return true
    end

    function ENT:SpawnChunk(num, force)
        for i = 1, num do
            local c_Model = ents.CreateClientProp(self:GetModel())
            c_Model:SetPos(self:GetPos() + VectorRand() * self:BoundingRadius() * 0.5)
            c_Model:SetModelScale(self:GetModelScale() * math.Rand(0.2, 0.5), 0)
            c_Model:SetColor(self:GetColor())
            c_Model:SetMaterial(self:GetMaterial())
            c_Model:PhysicsInit(SOLID_VPHYSICS)
            c_Model:SetAngles(AngleRand())
            c_Model:Spawn()
            c_Model:Activate()

            if isnumber(force) then
                force = VectorRand() * force
            end

            c_Model:GetPhysicsObject():SetVelocity(self:GetVelocity() + (force or Vector()))
            c_Model:GetPhysicsObject():SetMass(50 * c_Model:GetModelScale())
            c_Model:GetPhysicsObject():SetDamping(math.Rand(0, 2), 2)
            c_Model:GetPhysicsObject():ApplyTorqueCenter(VectorRand() * 500)
            c_Model:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            local die = math.Rand(1, 3)
            c_Model:SetSaveValue("m_bFadingOut", true)
            SafeRemoveEntityDelayed(c_Model, die)
        end
    end

    function ENT:OnRemove()
        if self.Sparkle then
            self.Sparkle:Finish()
            self.Sparkle = nil
        end

        self:SpawnChunk(math.random(3, 10), VectorRand() * math.Rand(10, 40))
    end
end