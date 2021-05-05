-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Secret Button"
ENT.Author = "PYROTEKNIK"
ENT.Purpose = "If you find one of these, something magic may happen"
ENT.Category = "PYROTEKNIK"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.PlacementSettings = {}
ENT.PlacementSettings.RequireCeiling = false
ENT.PlacementSettings.AllowFloor = false
--NOTE: Generally the process will be less efficient if both of these are set to false!
ENT.PlacementSettings.CeilingHeight = 400

ENT.PlacementSettings.SurfacePropBlacklist = {"dirt", "grass", "gravel", "rock"}

--**studio** is any model
ENT.PlacementSettings.TextureBlacklist = {"**empty**", "TOOLS/TOOLSBLACK", "**studio**"}

if (SERVER) then
    MAGICBUTTON_ENT_DESIRED_NUMBER = 2

    timer.Create("magicbutton_ent_spawner", 5, 0, function()
        if EntityCount("magicbutton") < MAGICBUTTON_ENT_DESIRED_NUMBER then
            local button = ents.Create("magicbutton")

            if (IsValid(button)) then
                button:Spawn()
                button:Activate()

                if (BotSayGlobal) then
                    BotSayGlobal(";weewoo;[fbc]A new button has spawned!")
                else
                    PrintMessage(HUD_PRINTTALK, "A new button has spawned!")
                end
            end
        end
    end)
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
            local extent = area:GetExtentInfo()
            local toosmall = extent.SizeX < 32 or extent.SizeY < 32
            if (area:IsUnderwater() or area:HasAttributes(NAV_MESH_AVOID) or toosmall) then continue end
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
    self:SetAngles(ang)
    self.HasSpot = true
end

function ENT:Initialize()
    if (SERVER) then
        self.Entity:SetModel("models/pyroteknik/secretbutton.mdl")
        local bmins, bmaxs = Vector(-4.8, -3.1, 0), Vector(4.8, 3.1, 2)
        self:SetCollisionBounds(bmins, bmaxs)
        self.Entity:PhysicsInitBox(bmins, bmaxs)
        self.Entity:SetMoveType(MOVETYPE_NONE)
        self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
        self:SetUseType(SIMPLE_USE)
        self:SetColor(HSVToColor(math.Rand(0, 360), 1, 1))
        local phys = self:GetPhysicsObject()

        if (IsValid(phys)) then
            phys:EnableMotion(false)
        end

        --self:FindHidingSpot()
        if (not self.HasSpot) then
            local trace = self:FindHidingSpot()
            self:MoveToTraceResult(trace)
        end

        timer.Simple(60 * 60, function()
            if (IsValid(self)) then
                self:Remove()
            end
        end)
    end

    if (CLIENT) then
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetEntity(self)
        util.Effect("propspawn", effectdata)
    end
end

function ENT:SpawnFunction(ply, tr, ClassName)
    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos)
    ent:SetAngles(VectorRand():AngleEx(tr.HitNormal))
    local trace = ply:GetEyeTrace()
    ent:MoveToTraceResult(trace)
    ent.HasSpot = true
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:Draw()
    local pos = self:GetPos() + self:GetUp() * 3
    local c = self:GetColor()
    local cvector = (Vector(c.r, c.g, c.b) / 255)
    local lc = render.ComputeLighting(pos, self:GetUp())
    local light1 = {}
    light1.type = MATERIAL_LIGHT_POINT
    light1.color = cvector * 15
    light1.pos = pos
    light1.fiftyPercentDistance = 2.35
    light1.zeroPercentDistance = 4
    render.SuppressEngineLighting(true)

    for i = 0, 5 do
        render.SetModelLighting(i, lc.x, lc.y, lc.z)
    end

    render.SetLocalModelLights({light1})

    render.SetAmbientLight(0.05, 0.05, 0.05)
    --render.SuppressEngineLighting( true )
    self:DrawModel()
    render.SuppressEngineLighting(false)
end

-- this is where we generate a random amount of points to give the player
function ButtonMoneyPrize()
    local min, max = 1000, 300000

    return math.Round(math.pow(math.Rand(0, 1), 4) * (max - min) + min, -3)
end

local function MagicOutcomePrize(ply)
    local amount = ButtonMoneyPrize()
    if (ply.SS_GivePoints == nil) then return nil end
    ply:SS_GivePoints(amount)

    return amount
end

local function MagicOutcomeBountyAndPrize(ply)
    local amount = ButtonMoneyPrize()
    if (ply.SS_GivePoints == nil or SetPlayerBounty == nil or GetPlayerBounty == nil) then return nil end
    ply:SS_GivePoints(amount)
    local add = GetPlayerBounty(ply) + amount
    SetPlayerBounty(ply, add)

    return amount
end

local function MagicOutcomeBountyAll(ply)
    if (SetPlayerBounty == nil or GetPlayerBounty == nil) then return nil end
    local amount = 1000

    if (math.random(1, 20) == 1) then
        amount = math.random(2, 45)
    end

    for k, v in pairs(player.GetAll()) do
        local add = GetPlayerBounty(v) + amount
        SetPlayerBounty(v, add)
    end

    return amount
end

local function MagicOutcomeKleinerFanclub(ply)
    if (KLEINER_NPCS and table.Count(KLEINER_NPCS) > 0) then
        local someoneelse

        if (math.random(1, 20) == 1) then
            ply = table.Random(player.GetAll())
            someoneelse = true
        end

        KLEINER_OVERRIDE_TARGET = ply

        timer.Create("KLEINER_GOD_EXPIRE", 60 * 15, 1, function()
            KLEINER_OVERRIDE_TARGET = nil
        end)

        if (someoneelse) then return "and it made " .. ply:Nick() .. " really popular with kleiners! ;kleinerfortnite;" end

        return "and it made them really popular with kleiners! ;kleinerfortnite;"
    end
end

local function MagicOutcomeExplode(ply, button)
    local explosion = ents.Create("env_explosion") -- The explosion entity
    explosion:SetPos(button:GetPos() + button:GetUp() * 3) -- Put the position of the explosion at the position of the entity
    explosion:Spawn() -- Spawn the explosion
    explosion:SetKeyValue("iMagnitude", "150") -- the magnitude of the explosion
    explosion:Fire("Explode", 0, 0) -- explode

    return ""
end

local function MagicOutcomeKleinerSlur(ply)
    if (KLEINER_NPCS and table.Count(KLEINER_NPCS) > 0) then
        local someoneelse

        if (math.random(1, 20) == 1) then
            ply = table.Random(player.GetAll())
            someoneelse = true
        end

        KLEINER_BULLIES[ply:SteamID()] = 5000
        if (someoneelse) then return "and it sent the kleiner mob after " .. ply:Nick() .. "! ;antikleiner;" end

        return "and it made them accidentally say a anti-kleiner slur! Now you're gonna get it! ;antikleiner;"
    end
end

local function MagicOutcomeKleinerTeleported(ply)
    if (KLEINER_NPCS and table.Count(KLEINER_NPCS) > 0) then
        local someoneelse

        if (math.random(1, 20) == 1) then
            ply = table.Random(player.GetAll())
            someoneelse = true
        end

        for k, v in pairs(ents.FindByClass("kleiner")) do
            v:TeleportSafe(ply:GetPos())
        end

        if (someoneelse) then return "and it teleported all kleiners to the player [white]" .. ply:Nick() .. ";hahaha;" end

        return "and it teleported all kleiners to them! ;kleinerfortnite;"
    end
end

local landmarks = {
    ["Near The Drunken Clam"] = Vector(-2518, -802, 64),
    ["Near Trump Tower"] = Vector(-2528, -66, 64),
    ["Near Sushi Theater"] = Vector(-2537, -1613, 104),
    ["Near The Pit"] = Vector(-126, -1355, 19),
    ["Somewhere on the roof"] = Vector(-1179, 1020, 522),
    ["Somewhere on the roof"] = Vector(-234, 990, 633),
    ["Somewhere on the roof"] = Vector(1616, 810, 606),
    ["Somewhere on the roof"] = Vector(-427, 1352, 688),
    ["Near Mini Golf"] = Vector(2113, -589, 119),
    ["Near AFK Corral"] = Vector(2831, 1062, 129),
    ["Somewhere behind the theater"] = Vector(1780, 1730, 108),
    ["Near the cabin"] = Vector(-107, 2930, 97),
    ["Near SportZone"] = Vector(1667, -1918, 85),
}

local function MagicOutcomeButtonSpawn(ply)
    local button = ents.Create("magicbutton")
    button:Spawn()
    local trace = button:FindHidingSpot()

    if (trace) then
        button:MoveToTraceResult(trace)
    end

    if (IsValid(button)) then
        local loc = Location.Find(button)
        local locd = Location.GetLocationByIndex(loc or -1)
        local locname = locd.Name

        if (locname == "Outside") then
            local nearest = 1000000
            local nearestname
            local secondnearestname

            for k, v in pairs(landmarks) do
                if (v:Distance(button:GetPos()) < nearest) then
                    secondnearestname = nearestname
                    nearestname = k
                    nearest = v:Distance(button:GetPos())
                end
            end

            locname = locname .. " (" .. nearestname .. ")"
        end

        return locname or "Somewhere stupid"
    end
end

local function MagicOutcomeSpawnObject(ply, button)
    local classes = {}

    classes["sent_ball"] = {
        "Bouncy Ball", 10, function(ent)
            ent:SetBallSize(24)
            ent:GetPhysicsObject():SetVelocity(VectorRand() * 20)
        end
    }

    classes["npc_headcrab"] = {
        "Headcrab", math.random(1, 5), function(ent, button)
            local pos = table.Random(navmesh.Find(button:GetPos() + button:GetUp() * 50, 100, 2000, 2000)):GetRandomPoint()
            ent:SetPos(pos)
        end
    }

    classes["npc_grenade_frag"] = {
        "Live Grenade", math.random(1, 10), function(ent, button)
            ent:GetPhysicsObject():SetVelocity(VectorRand() * 100)
            ent:Fire("SetTimer", math.random(2, 6))
        end
    }

    classes["dodgeball"] = {
        "Dodgeball", 1, function(ent, button)
            ent:GetPhysicsObject():SetVelocity(button:GetUp() * 500)
        end
    }

    local dat, class = table.Random(classes)
    local number = dat[2] or 1
    local name = dat[1]
    local func = dat[3]

    for i = 1, number do
        local ent = ents.Create(class)
        ent:Spawn()
        ent:SetPos(button:GetPos() + button:GetUp() * ent:BoundingRadius())
        SafeRemoveEntityDelayed(ent, 60 * 5) --whatever we spawn, make sure it's gone after 5 minutes

        if (func) then
            func(ent, button)
        end
    end

    local what = name or ent.PrintName or ent:GetClass()

    if (number > 1) then
        what = number .. " " .. what .. "s"
    else
        what = "a " .. what
    end

    return what
end

local function MagicOutcomeOverlay(ply, button)
    local overlays = {"models/shadertest/shader4", "models/props_c17/fisheyelens", "effects/combine_binocoverlay", "models/props_combine/stasisshield_sheet", "models/shadertest/shader5", "effects/water_warp01", "effects/distortion_normal001", "effects/tp_eyefx/tpeye"}

    ply:ConCommand("pp_mat_overlay_refractamount -0.06")
    ply:ConCommand("pp_mat_overlay " .. table.Random(overlays))

    timer.Simple(30, function()
        if (IsValid(ply)) then
            ply:ConCommand("pp_mat_overlay ''")
        end
    end)

    return ""
end

local MagicButtonOutcomes = {
    {
        func = MagicOutcomePrize,
        message = "and won [white]%s points![fbc];coins;",
        weight = 1
    },
    {
        func = MagicOutcomeBountyAndPrize,
        message = "and won [red]%s points[fbc] and also a [red]%s point bounty[fbc] on themself! ;fingers;",
        weight = 3
    },
    {
        func = MagicOutcomeKleinerFanclub,
        message = "%s",
        weight = 5
    },
    {
        func = MagicOutcomeKleinerTeleported,
        message = "%s",
        weight = 4,
    },
    {
        func = MagicOutcomeKleinerSlur,
        message = "%s",
        weight = 3
    },
    {
        func = MagicOutcomeOverlay,
        message = "and had their screen fucked up %s ;billhead;",
        weight = 2
    },
    --[[
    { 
        func = MagicOutcomeSpawnObject,
        message = "and it spawned %s",
        weight = 2000
    },
    ]]
    {
        func = function(ply, button)
            ply:SetPos(button:FindSuitableCastOrigin().StartPos)

            return table.Random({";blackwhat;", "", "", ""})
        end,
        message = "and teleported somewhere mysterious! %s",
        weight = 2
    },
    {
        func = MagicOutcomeBountyAll,
        message = "and [red]increased everyone's bounty by %s points! ;dougie;",
        weight = 2
    },
    {
        func = MagicOutcomeButtonSpawn,
        message = "and spawned [rainbow2];weewoo;another button;weewoo;[fbc], which appeared somewhere in the location:[white] %s",
        weight = 3
    },
    {
        func = MagicOutcomeExplode,
        message = "it exploded haha ;crazy;",
        weight = 2
    },
    {
        func = function(ply, button)
            ply:EmitSound("physics/flesh/flesh_strider_impact_bullet1.wav")
            local eang = ply:EyeAngles()
            eang.roll = eang.roll + 15
            ply:SetEyeAngles(eang)
            local bone = ply:LookupBone("ValveBiped.Bip01_Head1") or ply:LookupBone("LRigScull")
            local bang = ply:GetManipulateBoneAngles(bone)
            bang.pitch = -eang.roll
            ply:ManipulateBoneAngles(bone, bang)

            return ""
        end,
        message = "and got a sore neck",
        weight = 3
    },
    {
        func = function(ply, button)
            return table.Random({";baby;", ";bad;", ";biggestloser;", ";concern;", ";bartcry;", ";bazinga;", ";boohoo;", ";chungus;", ";eating;"})
        end,
        message = "but nothing happened! %s",
        weight = 2
    },
    {
        func = function(ply, button)
            if (OpenAPresent) then return OpenAPresent(ply, button:GetPos()) end
        end,
        message = "and got [white]%s[fbc]! ;alien;",
        weight = 8
    }
}

--NOTE: On these functions, please return a string if there was a success, and nil if there was not.
function ENT:Effect(ply)
    local effect
    local item
    local outcometable = {}

    for k, v in pairs(MagicButtonOutcomes) do
        for i = 1, v.weight or 1 do
            table.insert(outcometable, math.random(1, #outcometable + 1), k)
        end
    end

    for _, index in pairs(outcometable) do
        effect = MagicButtonOutcomes[index]

        if (effect.func ~= nil) then
            item = effect.func(ply, self)
        end

        if (item ~= nil) then break end
    end

    if (type(item) == "number") then
        item = string.Comma(item)
    end

    return string.format(effect.message, item, item)
end

function ENT:Use(activator)
    if (not self.Pressed) then
        self.Pressed = true

        timer.Simple(5, function()
            if (IsValid(self)) then
                self:SetModelScale(0.01, 3)

                timer.Simple(3, function()
                    if (IsValid(self)) then
                        self:Remove()
                    end
                end)
            end
        end)

        local message = self:Effect(activator)
        assert(message ~= nil)
        message = "[white]" .. activator:Nick() .. "[fbc] pressed a hidden button " .. message

        if (BotSayGlobal) then
            BotSayGlobal(";clap;[fbc]" .. message)
        else
            PrintMessage(HUD_PRINTTALK, message)
        end

        local c2 = self:GetColor()
        c2.r = c2.r / 5
        c2.g = c2.g / 5
        c2.b = c2.b / 5
        self:SetColor(c2)
        self:ManipulateBonePosition(1, Vector(0, 0, -0.5))
        activator:EmitSound("buttons/button9.wav")
    end
end