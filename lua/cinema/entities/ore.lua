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

local function OreOrigin()
    local hull = Vector(32, 32, 32)
    local navareas = navmesh.GetAllNavAreas()
    local picks

    --Cache good ore points
    if (ORE_CACHED_ORIGINPOINTS == nil) then
        local origins = {}

        for _, area in pairs(navareas) do
            local extent = area:GetExtentInfo()
            if not ore_areas[area:GetPlace()] then continue end
            if area:IsUnderwater() or area:HasAttributes(NAV_MESH_AVOID) or (extent.SizeX < hull.x or extent.SizeY < hull.y) then continue end


            --perform a trace to check if we have room here
            local tr = {}
            tr.start = area:GetCenter() + Vector(0, 0, hull.z / 4)
            tr.endpos = tr.start + Vector(0, 0, -64)
            tr.mask = MASK_PLAYERSOLID
            tr.mins = hull * Vector(1, 1, 0.1) * -0.5
            tr.maxs = hull * Vector(1, 1, 0.1) * 0.5
            local trace = util.TraceHull(tr)

            if (not trace.Hit or trace.StartSolid) then continue end
            --cast up towards ceiling
            local tr = {}
            tr.start = trace.HitPos + Vector(0,0,hull.z/2)
            tr.endpos = tr.start + Vector(0, 0, 3000)
            tr.mask = MASK_PLAYERSOLID
            tr.mins = hull * Vector(1, 1, 0.1) * -0.5
            tr.maxs = hull * Vector(1, 1, 0.1) * 0.5
            trace = util.TraceHull(tr)
            if trace.StartSolid then
                trace = util.TraceLine(tr)
            end

            local ep = (trace.Hit or trace.HitPos) or tr.endpos

            if not trace.StartSolid or (trace.StartSolid and trace.FractionLeftSolid < 1) then
                local cpos = LerpVector(0.5,tr.start,ep)
                table.insert(origins, cpos)
                local ext = area:GetExtentInfo()
                local bnds = Vector(ext.SizeX, ext.SizeY, ext.SizeZ + 1)

                debugoverlay.Box(area:GetCenter() + Vector(0, 0, 0.5), bnds * -0.5, bnds * 0.5, 60, Color(0, 0, 255, 16))
                debugoverlay.Line(area:GetCenter(),cpos,60,Color(0,255,255,16),false)
                debugoverlay.Box(cpos, hull * -0.5, hull * 0.5, 60, Color(0, 255, 0, 16))
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

    ORE_MAXNUMBER = 24
    timer.Create("ore_spawner", 1, 0, function()

        if Ents and table.Count(Ents.ore) < ORE_MAXNUMBER then
            local pos = OreOrigin()
            if pos then
                local new_ore = SpawnOre(1, pos)
            else
                ErrorNoHalt("Ore Spawner Failed! Empty Ore Origin Table")
            end
        end
    end)
end

function SpawnOre(size, origin)
    local res
    local org = origin

    --we start at a seed, and make 100 attempts to raycast onto a rock wall that's at most [CeilingHeight] from the ground
    local attemptlimit = 100
    for i = 1, attemptlimit do
        local dir = VectorRand()
        dir = (dir * Vector(1, 1, 1 - math.abs(i/attemptlimit)*0.5 )):GetNormalized()

        local tr = {
            start = org,
            endpos = org + dir * 2000,
            mask = MASK_PLAYERSOLID
        }

        local trace = util.TraceLine(tr)
        local valid = IsOreTraceValid(trace)
        debugoverlay.Line(trace.StartPos, trace.HitPos, valid and 5 or 1, valid and Color(0, 255, 0) or Color(255, 0, 0))

        if valid then
            local tr = {}
            tr.start = trace.HitPos + trace.HitNormal * 16
            tr.endpos = tr.start + Vector(0, 0, -PlacementSettings.CeilingHeight)
            tr.mask = MASK_PLAYERSOLID
            local ctrace = util.TraceLine(tr)
            local cv = ctrace.Hit
            debugoverlay.Line(ctrace.StartPos, ctrace.HitPos, cv and 5 or 1, cv and Color(0, 255, 0) or Color(255, 0, 0), false)

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

        timer.Simple(60 * 60, function() --remove nugget if nobody finds it in an hour
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

        if ply.GivePoints then
            ply:GivePoints(self.PointsValue)
        end

        if self.EmbedDistance <= 0 then
            self:PhysicsInit(SOLID_VPHYSICS)

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
                
                pa:SetStartSize(wc * 32)
                pa:SetEndSize(wc * 32)

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

        self:SpawnChunk(math.random(3, 5), VectorRand() * math.Rand(10, 40))
    end
end