AddCSLuaFile()
ENT.Base = "base_nextbot"
ENT.Name = "Spooky Skeleton"
ENT.Category = "Swamp Cinema"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.AutomaticFrameAdvance = true

list.Set("NPC", "Skeleton", {
    Name = "Spooky Skeleton",
    Class = "enemy_skeleton",
    Category = "Swamp Cinema"
})

SKELETON = SKELETON or {}
SKELETON_TARGETS = SKELETON_TARGETS or {}
SKELETON_CURRENT_NUMBER = SKELETON_CURRENT_NUMBER or 0
SKELETONS_FILTER = SKELETONS_FILTER or {}
SKELETON_LIMIT = 40

-- Places a skeleton can spawn
SKELETON_SPAWN_WHITELIST = {
    ["Caverns"] = true,
    ["Labyrinth of Kek"] = true,
    ["Maze"] = true,
}

-- Places a skeleton can exist
SKELETON_LOCATION_WHITELIST = {
    ["Caverns"] = true,
    ["Labyrinth of Kek"] = true,
    ["Maze"] = true,
    ["Sewers"] = true,
}

hook.Add("OnEntityCreated", "skeleton_add", function(ent)
    if ent:GetClass() == "enemy_skeleton" then
        SKELETON[ent] = true
        SKELETON_CURRENT_NUMBER = table.Count(SKELETON)
        SKELETONS_FILTER = table.GetKeys(SKELETON)
    elseif ent:IsPlayer() then
        SKELETON_TARGETS[ent] = true
    end
end)

hook.Add("EntityRemoved", "skeleton_remove", function(ent)
    if ent:GetClass() == "enemy_skeleton" then
        SKELETON[ent] = nil
        SKELETON_CURRENT_NUMBER = table.Count(SKELETON)
        SKELETONS_FILTER = table.GetKeys(SKELETON)
    elseif ent:IsPlayer() then
        SKELETON_TARGETS[ent] = nil
    end
end)

if SERVER then
    timer.Create("SpookySpawns", 10, 0, function()
        SKELETON_SPAWNS = {}
        local areas = navmesh.GetAllNavAreas()

        for k, v in pairs(areas) do
            if v:GetPlace() ~= "Caverns" and v:GetPlace() ~= "Sewers" then continue end
            if v:GetSizeX() < 32 or v:GetSizeY() < 32 then continue end
            table.insert(SKELETON_SPAWNS, v)
        end
    end)

    timer.Create("SpookySpawner", 0.25, 0, function()
        if SKELETON_SPAWNS and SKELETON_CURRENT_NUMBER < 30 then
            local spawn = table.Random(SKELETON_SPAWNS)
            assert(spawn ~= nil, "No spawnpoints for skeleton.")
            local boo = ents.Create("enemy_skeleton")
            boo:SetPos(spawn:GetCenter())
            boo:Spawn()
        end
    end)
end

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Target")
    self:NetworkVar("Bool", 0, "Collapsing")
end

function ENT:GetName()
    return "Skeleton"
end

ENT.LoseTargetDist = 5000
ENT.SearchRadius = 3500
ENT.KillReward = 100
ENT.TargetHeight = 2048
ENT.TargetHeightInner = 4096
ENT.TargetHeightInnerRadius = 512
local TotalPathingBudget = 20000

local function PathingIterationLimit()
    --if(IsValid(KLEINER_OVERRIDE_TARGET))then return TotalPathingBudget end
    return (SKELETON_CURRENT_NUMBER ~= nil and SKELETON_CURRENT_NUMBER > 0 and math.floor(TotalPathingBudget / SKELETON_CURRENT_NUMBER)) or 1000
end

local function PathingRateHigh()
    return (SKELETON_CURRENT_NUMBER ~= nil and SKELETON_CURRENT_NUMBER > 0 and math.Clamp(0.5 + (SKELETON_CURRENT_NUMBER / 3), 0.5, 20)) or 0.5
end

function ENT:HandleAnimEvent(event, etime, cycle, type, options)
end

function ENT:Initialize()
    --self.CalcIdeal = ACT_TERROR_IDLE_NEUTRAL
    self:SetSequence(13)

    if SERVER then
        self:SetModel("models/pyroteknik/swamp/npc_skeleton.mdl")
        self:SetBloodColor(BLOOD_COLOR_YELLOW)
        self:SetUseType(SIMPLE_USE)
        self:SetHealth(3)
        --self.loco:SetJumpGapsAllowed(true)
        self.loco:SetGravity(1000)
        self.loco:SetAvoidAllowed(true)
        self.loco:SetClimbAllowed(true)
        self.loco:SetJumpGapsAllowed(true)
        self:SetGravity(1000)
        self:DrawShadow(true)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
        --self:SetCollisionBounds(Vector(-8, -8, 0), Vector(8, 8, 72))
        self:ResetBehavior()
    end

    if CLIENT then
        local ef = EffectData()
        ef:SetOrigin(self:GetPos())
        ef:SetEntity(self)
        local fx = util.Effect("RagdollImpact", ef)
        local ef = EffectData()
        ef:SetOrigin(self:GetPos())
        ef:SetAngles(self:GetAngles())
        ef:SetEntity(self)
        local fx = util.Effect("skeleton_form", ef)
    end
end

if CLIENT then
    language.Add("enemy_skeleton", "Spooky Skeleton")
end

function ENT:OnRemove()
end

function ENT:OnInjured(dmginfo)
end

function ENT:Shatter(dmginfo)
    self:SetHealth(0)
    local ef = EffectData()
    ef:SetOrigin(self:GetPos())
    ef:SetAngles(self:GetAngles())
    ef:SetStart(self:GetVelocity() + (dmginfo and dmginfo:GetDamageForce() / 10 or Vector(0, 0, 50)))
    ef:SetEntity(self)
    self:SetSolid(SOLID_NONE)
    util.Effect("skeleton_Splatter", ef)
end

function ENT:CommitSuicide()
    local d = DamageInfo()
    d:SetDamage(self:Health() + 1)
    d:SetAttacker(self)
    d:SetInflictor(self)
    d:SetDamageType(DMG_SLASH)
    d:SetDamageForce(self:GetVelocity())
    self:TakeDamageInfo(d)
end

function ENT:OnKilled(dmginfo)
    self:SetCollapsing(true)
    self:Shatter(dmginfo)
    self:EmitSound("skeleton/bones_drop01.wav", 130, math.Rand(90, 110), 1, CHAN_BODY)
    local attacker = dmginfo:GetAttacker()

    if IsValid(attacker) and attacker:IsPlayer() then
        attacker:GivePoints(self.KillReward)
        attacker:Notify("You killed a skeleton for " .. tostring(self.KillReward) .. " Points!")
    end

    SafeRemoveEntityDelayed(self, 3)
end

function ENT:Draw(flags)
    self:DrawModel(flags)
end

function ENT:Dead()
    return self:Health() <= 0
end

function ENT:BodyUpdate()
    --self:Shatter()
    if self:Dead() then return true end
    local act = ACT_HL2MP_IDLE_ZOMBIE
    self.FootstepTimer = self.FootstepTimer or 0
    local spd = 0

    if self.loco:GetVelocity():Length() > 1 then
        act = ACT_HL2MP_WALK_ZOMBIE_01
    end

    if self.loco:GetVelocity():Length() > 150 then
        act = ACT_HL2MP_RUN_ZOMBIE

        if self:AlmostNearTarget() then
            local gest = ACT_GMOD_GESTURE_RANGE_FRENZY
            self:AddGesture(gest, true)
        end
    end

    spd = self.loco:GetVelocity():Length() / 150

    if not self:OnGround() then
        act = ACT_HL2MP_JUMP_ZOMBIE
    end

    if self.ClimbDir == 1 then end --act = ACT_IDLE
    if self.ClimbDir == -1 then end --act = ACT_IDLE

    if self:NearTarget() then
        self:DoSlapAttack()
        spd = 2
    end

    self.FootstepTimer = self.FootstepTimer - spd

    if self.FootstepTimer <= 0 then
        self.FootstepTimer = 1
        self:EmitSound("skeleton/bones_step0" .. math.random(1, 4) .. ".wav", 60, math.Rand(90, 110), math.Rand(0.4, 0.6), CHAN_BODY)
    end

    self.MainActivity = act

    if self:GetActivity() ~= self.MainActivity or self:GetCycle() >= 1 then
        self:StartActivity(self.MainActivity)
    end

    self:BodyMoveXY()
end

function ENT:DoSlapAttack()
    if self:Dead() then return true end
    local gest = ACT_GMOD_GESTURE_RANGE_FRENZY
    self:AddGesture(gest, true)
    local tr = {}
    tr.start = self:GetPos() + Vector(0, 0, 36)
    tr.endpos = tr.start + self:GetForward() * 32
    tr.mins = Vector(1, 1, 1) * -8
    tr.maxs = Vector(1, 1, 1) * 8
    tr.filter = SKELETONS_FILTER
    local trace = util.TraceHull(tr)

    if trace.Hit and trace.Entity:Health() > 0 then
        local d = DamageInfo()
        d:SetDamage(math.random(1, 2))
        d:SetAttacker(self)
        d:SetInflictor(self)
        d:SetDamageType(DMG_SLASH)
        d:SetDamageForce(self:GetForward() * 5000)
        trace.Entity:TakeDamageInfo(d)
        trace.Entity:ViewPunch(Angle(math.Rand(0, 5), math.Rand(-2, 2), math.Rand(-1, 1)))
        trace.Entity:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random(1, 6) .. ".wav", 45, 100, 0.2, CHAN_BODY)
    end
end

function ENT:PosInRange(pos)
    local heightlimit = self.TargetHeight * 1
    local horizontalrange = (self:GetPos() * Vector(1, 1, 0)):Distance(pos * Vector(1, 1, 0))
    local heightdiff = math.abs((self:GetPos() - pos).z)

    if horizontalrange < self.TargetHeightInnerRadius then
        heightlimit = self.TargetHeightInner
    end

    return horizontalrange <= self.LoseTargetDist and heightdiff <= heightlimit
end

function ENT:CanBeTarget(ent)
    if not IsValid(ent) then return false end
    if ent == self then return false end
    if ent:GetMoveType() == MOVETYPE_FLY then return false end
    if ent.IsAFK and ent:IsAFK() then return false end
    if Safe and Safe(ent) and ent:IsPlayer() then return false end
    if ent:IsPlayer() and not ent:Alive() then return false end
    if ent:IsPlayer() and not SKELETON_LOCATION_WHITELIST[ent:GetLocationName()] then return false end
    if self.TargetBlacklist and self.TargetBlacklist[ent] and self.TargetBlacklist[ent] > CurTime() then return false end
    if not self:PosInRange(ent:GetPos()) then return false end

    return true
end

-- Use this if you want to add special requirements for the entity to become a target
function ENT:CanBecomeTarget(ent)
    if not IsValid(ent) or self:GetRangeTo(ent) > self.SearchRadius then return false end

    return self:CanBeTarget(ent)
end

function ENT:AlmostNearTarget()
    if not IsValid(self:GetTarget()) then return false end

    return self:GetPos():Distance(self:GetTarget():GetPos()) < 129
end

function ENT:NearTarget()
    if not IsValid(self:GetTarget()) then return false end

    return self:GetPos():Distance(self:GetTarget():GetPos()) < 64
end

function ENT:GetTargetPriority(ent)
    if not IsValid(ent) then return 0 end
    local priority = ent:IsPlayer() and 100 or 0.05 -- Base amount
    priority = priority * (1 + (math.Clamp(self.LoseTargetDist - self:GetRangeTo(ent), 0, self.LoseTargetDist) / self.LoseTargetDist) / 5) -- Up to 20% gain based on proximity

    return priority
end

function ENT:HaveTarget()
    local target = self:GetTarget()
    if IsValid(target) and self:CanBeTarget(target) then return true end

    return self:FindTarget()
end

function ENT:FindTarget()
    if self.NextTargetTime and self.NextTargetTime > CurTime() then end --self:SetTarget(nil) --return false
    local _ents = SKELETON_TARGETS
    local targetsum = 0
    local targets = {}
    local targetcount = 0
    local playersum = 0

    for ent, val in pairs(_ents) do
        if self:CanBecomeTarget(ent) and self:GetTargetPriority(ent) > 0 then
            if ent:IsPlayer() then
                playersum = playersum + 1
            end

            table.insert(targets, ent)
            targetsum = targetsum + self:GetTargetPriority(ent)
            targetcount = targetcount + 1
        end
    end

    if targetcount == 1 then
        self:SetTarget(targets[1])

        return true
    end

    local samplevalue = math.Rand(0, 1) * targetsum

    for key, ent in pairs(targets) do
        samplevalue = samplevalue - self:GetTargetPriority(ent)

        if samplevalue <= 0 then
            self:SetTarget(ent)

            return true
        end
    end

    -- Slowly die if they end up somewhere where nobody is
    if playersum == 0 then
        self.WasteCounter = (self.WasteCounter or 1000) - 1
        self.NextTargetTime = CurTime() + 1

        if self.WasteCounter <= 0 then
            self:Remove()

            return
        end
    else
        self.WasteCounter = 10
    end

    self.NextTargetTime = CurTime() + 2
    self:SetTarget(nil)

    return false
end

function ENT:ResetBehavior()
    self.shifted = nil

    if self.path then
        if IsValid(self.path) then
            self.path:Invalidate()
        end

        self.path = nil
    end

    self.NeedsTarget = true
    --self:FindTarget()
end

function ENT:WanderToPos(pos)
    self:ResetBehavior()
    self:MoveToPos(pos, {})
end

function ENT:RunBehaviour()
    -- This function is called when the entity is first spawned, it acts as a giant loop that will run as long as the NPC exists
    while true do
        if self:Dead() then
            -- Kill the behavior coroutine
            self.BehaveThread = nil

            return true
        end

        if self.loco:IsStuck() then
            self:HandleStuck()
        end

        if self.NeedsTarget then
            self:FindTarget()
            self.NeedsTarget = nil
        end

        self.loco:SetGravity(1000)

        if IsValid(self:GetTarget()) and self:CanBeTarget(self:GetTarget()) then
            self.loco:SetDesiredSpeed(200)
            self.loco:SetAcceleration(150)
            self.loco:SetDeceleration(500)
            self.loco:SetJumpHeight(900)

            if not self:NearTarget() then
                local result = self:ChaseTarget()

                -- If chasing the target fails somehow, its probably a wise assumption that its redundant to keep trying.
                if result == "failed" then
                    self:ResetBehavior()
                end
            end

            if self:NearTarget() then
                self.loco:SetDesiredSpeed(220)
                self.loco:SetAcceleration(150)
                self.loco:SetDeceleration(2000)
                self.loco:SetJumpHeight(900)
                self.loco:FaceTowards(self:GetTarget():GetPos())
                coroutine.wait(0.15)
            end
        else
            -- No target, so we wander
            self.NeedsTarget = true
            local rand = table.Random(navmesh.Find(self:GetPos(), 256, 64, 64))

            if IsValid(rand) then
                self:WanderToPos(rand:GetCenter())
            end

            self.loco:SetDesiredSpeed(200)
            self.loco:SetAcceleration(150)
            self.loco:SetDeceleration(300)
        end

        -- At this point in the code the bot has stopped chasing the player or finished walking to a random spot
        -- Using this next function we are going to wait 2 seconds until we go ahead and repeat it
        coroutine.wait(0.1)
    end
end

function ENT:MoveToPos(pos, options)
    if pos == nil then return "failed" end
    options = options or {}
    local path = Path("Follow")
    path:SetMinLookAheadDistance(options.lookahead or 300)
    path:SetGoalTolerance(options.tolerance or 20)
    path:Compute(self, pos)
    self.path = path

    if not IsValid(path) then
        self.path = nil

        return "failed"
    end

    while IsValid(path) do
        local shouldpath = self:WhilePathing(path)

        if shouldpath then
            path:Update(self)
        end

        -- Draw the path (only visible on listen servers or single player)
        if options.draw then end --path:Draw()

        if self.loco:IsStuck() then
            self:HandleStuck()

            return "stuck"
        end

        -- If they set maxage on options then make sure the path is younger than it
        if options.maxage and path:GetAge() > options.maxage then
            self.path = nil

            return "timeout"
        end

        -- If they set repath then rebuild the path every x seconds
        if options.repath and path:GetAge() > options.repath then
            path:Compute(self, pos)
        end

        coroutine.yield()
    end

    return "ok"
end

function ENT:GetCurrentPathPoint()
    if IsValid(self.path) then
        local start = 1

        for k, v in pairs(self.path:GetAllSegments()) do
            if k ~= 1 and (v.pos * Vector(1, 1, 0)):Distance(self:GetPos() * Vector(1, 1, 0)) > 32 then
                start = k
                break
            end
        end

        if start > 1 then
            start = start - 1
        end

        return self.path:GetAllSegments()[start], start
    end

    return nil, -1
end

function ENT:GetNextPathPoint(ahead)
    if not IsValid(self.path) then return end
    ahead = ahead or 1
    local seg, index = self:GetCurrentPathPoint()
    if index then return self.path:GetAllSegments()[index + ahead] end
end

-- TODO(winter/pyro): Better solution than just teleporting through doors and shit
function ENT:HandleStuck()
    local spot = self:GetNextPathPoint()

    if spot then
        self:Teleport(spot.pos)
        self.loco:ClearStuck()
    else
        self:TeleportSafe()
        self.loco:ClearStuck()
    end
end

function ENT:Teleport(newpos)
    self:SetPos(newpos)
end

-- Attempt to teleport somewhere safe
function ENT:TeleportSafe(tpos, radius)
    local pos = table.Random(navmesh.Find(tpos or self:GetPos(), radius or 500, 128, 64)):GetCenter()
    self:Teleport(pos or tpos or self:GetPos())
end

local KLPATHGEN_ITERS
local KLPATHGEN_ITERS_BUDGET

function ENT:ChaseTarget(options)
    local options = options or {}
    local path = Path("Chase")
    path:SetMinLookAheadDistance(options.lookahead or 100)
    path:SetGoalTolerance(options.tolerance or 32)
    self.path = path
    RELEVANT_KLEINER = self -- see ENT.PathGen for explanation
    KLPATHGEN_ITERS = 0
    KLPATHGEN_ITERS_BUDGET = PathingIterationLimit()
    local success = path:Compute(self, self:GetTarget():GetPos(), self.PathGen)
    if not success then return "failed" end
    if not IsValid(path) then return "failed" end
    local target = self:GetTarget()

    while IsValid(path) and self:HaveTarget() and not self:NearTarget() and IsValid(target) do
        --self.loco:SetStepHeight(64)
        --self.loco:SetDeathDropHeight(5000)
        local range = self:GetRangeTo(self:GetTarget():GetPos()) or self.LoseTargetDist
        local updaterate = math.max(PathingRateHigh() * (range / self.LoseTargetDist), 0.5)

        if path:GetAge() > updaterate and target:IsOnGround() then
            RELEVANT_KLEINER = self -- see ENT.PathGen for explanation
            KLPATHGEN_ITERS = 0
            KLPATHGEN_ITERS_BUDGET = PathingIterationLimit()
            local success = path:Compute(self, self:GetTarget():GetPos(), self.PathGen)
            if not success then return "failed" end
        end

        if not IsValid(path) then return "failed" end
        local shouldpath = self:WhilePathing(path)

        if shouldpath then
            path:Update(self)
        end

        if options.draw then end --path:Draw()

        if self.loco:IsStuck() then
            self:HandleStuck()

            return "stuck"
        end

        coroutine.yield()
    end

    return "ok"
end

local mt = {"WALK", "FALL", "CLIMB", "GAP", "LADDERUP", "LADDERDOWN"}

function ENT:OnNavAreaChanged(old, new)
    local goal = IsValid(self.path) and self.path:GetCurrentGoal()

    if not SKELETON_LOCATION_WHITELIST[new:GetPlace()] then
        self:CommitSuicide()
    end

    if goal and (old:HasAttributes(NAV_MESH_JUMP) or new:HasAttributes(NAV_MESH_JUMP) or goal.type == 2 or goal.type == 3) then
        self.loco:JumpAcrossGap(goal.area:GetCenter(), goal.area:GetCenter() - self:GetPos())
    end
end

function ENT:WhilePathing(path)
    if path == nil or not IsValid(path) then return true end
    if self.loco == nil then return true end
    --if not self.loco:IsOnGround() and self:GetVelocity().z < -50 then return false end -- attempting to move while falling seems to pause falling
    local seg1, index = self:GetCurrentPathPoint() -- This returns the first path segment we're closest to.

    return true
end

ENT.PathGen = function(area, fromArea, ladder, elevator, length)
    KLPATHGEN_ITERS = (KLPATHGEN_ITERS or 0) + 1
    local self = RELEVANT_KLEINER -- This is bullshit, i guess this callback doesn't include the entity pathing.
    if not IsValid(self) then return -1 end

    if not IsValid(fromArea) then
        return 0
    else
        if KLPATHGEN_ITERS > KLPATHGEN_ITERS_BUDGET then return -1 end
        if not self.loco:IsAreaTraversable(area) and not IsValid(ladder) then return -1 end
        --if(not self:PosInRange(area:GetCenter()))then return -1 end
        local dist = 0

        if IsValid(ladder) then
            dist = ladder:GetLength()
        elseif length > 0 then
            dist = length
        else
            dist = (area:GetCenter() - fromArea:GetCenter()):Length() -- TODO(winter): Length is expensive! Don't use it!
        end

        local cost = dist + fromArea:GetCostSoFar()
        local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange(area)

        if not IsValid(ladder) then
            if deltaZ >= self.loco:GetStepHeight() then
                if deltaZ >= self.loco:GetMaxJumpHeight() then return -1 end
                local jumpPenalty = 2
                cost = cost + jumpPenalty * dist
            elseif deltaZ < -self.loco:GetDeathDropHeight() then
                return -1
            end
        end

        if IsValid(area) and area:HasAttributes(NAV_MESH_AVOID) and area:IsUnderwater() then return -1 end

        if IsValid(area) and area:HasAttributes(NAV_MESH_AVOID) then
            cost = cost + 100
        end

        return cost
    end
end
