-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")
include("sv_spawning.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
local RELEVANT_KLEINER
ENT.LoseTargetDist = 3000
ENT.SearchRadius = 1500
ENT.KillReward = 100
ENT.KillRewardBased = 10000
ENT.TargetHeight = 2048
ENT.TargetHeightInner = 4096
ENT.TargetHeightInnerRadius = 512
local KleinerNPCTotalPathingBudget = 20000

local function KleinerPathingIterationLimit()
    --if(IsValid(KLEINER_OVERRIDE_TARGET))then return KleinerNPCTotalPathingBudget end
    return (KLEINER_NPCS_CURRENT_NUMBER ~= nil and KLEINER_NPCS_CURRENT_NUMBER > 0 and math.floor(KleinerNPCTotalPathingBudget / KLEINER_NPCS_CURRENT_NUMBER)) or 1000
end

local function KleinerPathingRateHigh()
    return (KLEINER_NPCS_CURRENT_NUMBER ~= nil and KLEINER_NPCS_CURRENT_NUMBER > 0 and math.Clamp(0.5 + (KLEINER_NPCS_CURRENT_NUMBER / 3), 0.5, 20)) or 0.5
end

--util.AddNetworkString("kleinernpc_warning")
function ENT:Initialize()
    self:SetModel("models/kleiner.mdl")
    self:SetGravity(200)
    self:SetSubMaterial(5, "models/kleiner/players_sheet")
    self:SetUseType(SIMPLE_USE)
    self:SetBased(math.random(1, 10) == 1)
    self:SetHealth(self:GetBased() and 200 or 50)

    if (self:GetBased()) then
        self:SetSubMaterial(3, "models/pyroteknik/jokleiner_face")
    else
        --hl2 style kleiner
        if (math.random(1, 100) == 1) then
            self:SetSubMaterial(5, "")
        end

        if (math.random(1, 10) == 1) then
            self:SetSubMaterial(3, "models/pyroteknik/jokleiner_face")
        end
    end

    --remove glasses
    if (math.random(1, 15) == 1) then
        self:SetSubMaterial(2, "engine/occlusionproxy")
        self:SetSubMaterial(6, "engine/occlusionproxy")
        self:SetSubMaterial(7, "engine/occlusionproxy")
    elseif (math.random(1, 15) == 1) then
        --epic sunglasses
        self:SetSubMaterial(7, "tools/toolsblack")
    end

    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
    self:ResetBehavior()
end

function ENT:Use(ply)
end

function ENT:SpawnBait(vel)
    local bait = ents.Create("weapon_kleinerbait")
    if (not IsValid(bait)) then return end
    bait:SetPos(self:GetPos() + Vector(0, 0, 36))
    bait:Spawn()
    bait:EmitSound("Weapon_Bugbait.Splat")
    local phys = bait:GetPhysicsObject()
    phys:SetVelocity(vel or (Vector(0, 0, 233) + VectorRand() * Vector(55, 55, 0)))

    timer.Simple(60, function()
        if (IsValid(self) and not IsValid(self:GetOwner())) then
            self:Remove()
        end
    end)
end

function ENT:Speak(snd)
    if (self.Suicidal) then return end

    if (self.LastSound) then
        self:StopSound(self.LastSound)
    end

    self:EmitSound(snd, 50, nil, nil, nil, nil, 56)
    self.LastSound = snd
    local dur = SoundDuration(snd)
    self:SetTalking(CurTime() + dur - 0.2)

    return dur
end

function ENT:IsTalking()
    return self:GetTalking() > CurTime()
end

function ENT:WaveHands()
    if (self.Suicidal) then return end
    local num = math.random(1, 13)
    self:AddGestureSequence(self:LookupSequence("kgesture" .. (num > 9 and "" or "0") .. num))
end

function ENT:SayStuff(snd)
    if (self:IsTalking()) then return end

    --pull grenades
    if (math.random(1, 100) <= self:GetTargetViolence(self:GetTarget())) then
        snd = "vo/k_lab/kl_initializing.wav"
    end

    local gesture = true
    snd = snd or table.Random(self.Chatter)

    if (math.random(1, 50) == 1) then
        self:Speak("vo/k_lab/kl_ahhhh.wav")
        self:SpawnBait(Vector(0, 0, 0)) --shit out a larvae and scream

        return
    end

    local dur = self:Speak(snd)

    if (snd == "vo/k_lab/kl_initializing.wav") then
        self:PullGrenades()
    end

    local delay = 0

    if (gesture) then
        for i = 1, math.random(1, 3) do
            timer.Simple(delay, function()
                if (IsValid(self)) then
                    self:WaveHands()
                end
            end)

            delay = delay + math.Rand(0.2, 0.8)
        end
    end
end

function ENT:BaitFollow(ply)
    if (self:GetTarget() ~= ply and math.random(1, math.ceil(KLEINER_NPCS_CURRENT_NUMBER / 4)) == 1) then
        self:Speak(table.Random(self.ShortChatter))
    end

    self:SetTarget(ply)
    self.ManualTarget = true
end

--Check for higher priority player and follow them
function ENT:CheckBaitTargeting(ply)
    if (not self:CanBecomeTarget(ply)) then return end
    if (not self:GetTarget() == ply) then return end

    if (IsValid(self:GetTarget())) then
        if (self:GetTargetPriority(ply) >= self:GetTargetPriority(self:GetTarget())) then
            self:ResetBehavior()
            self:SetTarget(ply)
        end
    else
        self:ResetBehavior()
        self:SetTarget(ply)
    end
end

local PainSounds = {"vo/k_lab/kl_ahhhh.wav", "vo/k_lab/kl_hedyno03.wav"}

function ENT:OnInjured(damageinfo)
    if (self.Suicidal) then return end

    if (damageinfo:GetDamage() > self:Health() / 20) then
        local snd = table.Random(PainSounds)
        self:Speak(snd)
        self:AddGestureSequence(self:LookupSequence("fear_reaction_gesture"))
    end

    if (self:Health() < 0 and self.IsAlive ~= true) then
        self:Remove()
    end
end

function ENT:OnKilled(dmginfo)
    self:StopSound(self.LastSound or "")
    self:DropGrenades()

    if (math.random(1, 10) == 1) then
        self:SpawnBait()
    end

    hook.Run("OnNPCKilled", self, dmginfo:GetAttacker(), dmginfo:GetInflictor())
        local attacker = dmginfo:GetAttacker()

        if (IsValid(attacker) and attacker:IsPlayer()) then
            self:AddTargetViolence(attacker)
            local reward = self:GetBased() and self.KillRewardBased or self.KillReward

            if (attacker.PS_GivePoints) then
                attacker:PS_GivePoints(reward)
            end
        end

        self.IsAlive = false

    local rag = self:BecomeRagdoll(dmginfo)
end

function ENT:BodyUpdate()
    local act = ACT_IDLE

    if (self.loco:GetVelocity():Length() > 1) then
        act = ACT_WALK
    end

    if (self.loco:GetVelocity():Length() > 150) then
        act = ACT_RUN
    end

    if (not self:OnGround()) then
        act = ACT_JUMP
    end

    if (self.ClimbDir == 1) then
        act = ACT_IDLE
    end

    if (self.ClimbDir == -1) then
        act = ACT_IDLE
    end

    self.MainActivity = act

    if (self:GetActivity() ~= self.MainActivity) then
        self:StartActivity(self.MainActivity)
    end

    self:BodyMoveXY()
end

function ENT:PullGrenades()
    if (IsValid(self)) then
        self:AddGestureSequence(self:LookupSequence("startleclipboardgesture"))

        timer.Simple(2.4, function()
            if (IsValid(self)) then
                self:AddGestureSequence(self:LookupSequence("blowclipboardgesture"))
            end
        end)

        self.Suicidal = true
        local pos, ang = self:GetBonePosition(self:LookupBone("ValveBiped.Bip01_L_Hand") or 0)
        pos = pos + ang:Right() * 2
        pos = pos + ang:Forward() * 4
        local gren = self:SpawnGrenade()
        gren:SetPos(pos)
        gren:SetAngles(ang)
        gren:SetParent(self, 10)
        self.Grenade1 = gren
        local pos, ang = self:GetBonePosition(self:LookupBone("ValveBiped.Bip01_R_Hand") or 0)
        pos = pos + ang:Right() * 2
        pos = pos + ang:Forward() * 4
        ang:RotateAroundAxis(ang:Right(), 180)
        local gren = self:SpawnGrenade()
        gren:SetPos(pos)
        gren:SetAngles(ang)
        gren:SetParent(self, 11)
        self.Grenade2 = gren

        timer.Simple(1, function()
            if (IsValid(self)) then
                if (IsValid(self:GetTarget())) then
                    self:SetTargetViolence(self:GetTarget(), math.floor((self:GetTargetViolence(self:GetTarget()) - 1) / 1.15))
                end

                if (IsValid(self.Grenade1) and IsValid(self.Grenade1:GetParent())) then
                    self.Grenade1.DamageTriggered = true
                    self.Grenade1:Fire("SetTimer", 3)
                end

                if (IsValid(self.Grenade2) and IsValid(self.Grenade2:GetParent())) then
                    self.Grenade1.DamageTriggered = true
                    self.Grenade2:Fire("SetTimer", 3)
                end
            end
        end)
    end
end

function ENT:SpawnGrenade()
    local gren = ents.Create("npc_grenade_frag")
    gren:Spawn()
    gren:Activate()
    gren:SetMoveType(MOVETYPE_NONE)
    gren:PhysicsDestroy()
    gren:SetCollisionGroup(COLLISION_GROUP_WORLD)
    gren:SetOwner(self)
    gren.Owner = self

    return gren
end

function ENT:DropGrenades()
    for _, gren in ipairs({self.Grenade1, self.Grenade2}) do
        gren:SetParent()
        gren:PhysicsInit(MOVETYPE_VPHYSICS)
        gren:GetPhysicsObject():Wake()

        timer.Simple(60 * 15, function()
            if (IsValid(gren)) then
                gren:Remove()
            end
        end)
    end
end

if (SERVER) then
    KLEINER_BULLIES = KLEINER_BULLIES or {}
end

function ENT:PosInRange(pos)
    local heightlimit = self.TargetHeight * 1
    local horizontalrange = (self:GetPos() * Vector(1, 1, 0)):Distance(pos * Vector(1, 1, 0))
    local heightdiff = math.abs((self:GetPos() - pos).z)

    if (horizontalrange < self.TargetHeightInnerRadius) then
        heightlimit = self.TargetHeightInner
    end

    return horizontalrange <= self.LoseTargetDist and heightdiff <= heightlimit
end

function ENT:CanBeTarget(ent)
    if (not IsValid(ent)) then return false end
    if (ent == self) then return false end
    if (ent:GetMoveType() == MOVETYPE_FLY) then return false end
    if (ent.IsAFK and ent:IsAFK()) then return false end
    if (Safe and Safe(ent) and ent:IsPlayer()) then return false end
    if (self.TargetBlacklist and self.TargetBlacklist[ent] and self.TargetBlacklist[ent] > CurTime()) then return false end
    if (not self:PosInRange(ent:GetPos())) then return false end
    return true
end

--use this if you want to add special requirements for the entity to become a target
function ENT:CanBecomeTarget(ent)
    if (self:GetRangeTo(ent) > self.SearchRadius and self:GetTargetPriority(ent) < 200) then return false end

    return self:CanBeTarget(ent)
end

function ENT:NearTarget()
    if (not IsValid(self:GetTarget())) then return false end

    return self:GetPos():Distance(self:GetTarget():GetPos()) < 90
end

function ENT:GetTargetPriority(ent)
    if (not IsValid(ent)) then return 0 end
    local priority = ent:IsPlayer() and 1 or 0.05 --base amount

    if (ent == KLEINER_OVERRIDE_TARGET) then
        priority = 25
    end

    -- 100 if hit from bait
    if (ent.KleinerBaitPriority and ent.KleinerBaitPriority > CurTime()) then
        priority = 100
    end

    -- gain based on player bounty
    if (GetPlayerBounty and GetPlayerBounty(ent) > 0) then
        priority = priority * (1 + (GetPlayerBounty(ent) / 10000))
    end

    -- 10% gain based on aggression towards kleiner
    if (self:GetTargetViolence(ent) > 0) then
        priority = priority * (1 + (self:GetTargetViolence(ent) / 10))
    end

    priority = priority * (1 + (math.Clamp(self.LoseTargetDist - self:GetRangeTo(ent), 0, self.LoseTargetDist) / self.LoseTargetDist) / 5) --up to 20% gain based on proximity
    if (ent:IsPlayer() and IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon():GetClass() == "weapon_kleinerbait") then return 1 end

    return priority
end

function ENT:GetTargetViolence(ent)
    if (not IsValid(ent)) then return -1 end
    if (ent:GetClass() == "kleiner") then return -1 end
    if (ent:IsPlayer() and IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon():GetClass() == "weapon_kleinerbait") then return 0 end
    if (ent:IsPlayer() and KLEINER_BULLIES[ent:SteamID()]) then return KLEINER_BULLIES[ent:SteamID()] end

    return 0
end

function ENT:SetTargetViolence(ent, amount)
    amount = math.max(amount, 0)
    if (not IsValid(ent)) then return end

    if (ent:IsPlayer()) then
        KLEINER_BULLIES[ent:SteamID()] = amount
        --[[
			net.Start("kleinernpc_warning")
			net.WriteInt(amount,16)
			net.Send(ent)
            ]]
    end
end

function ENT:AddTargetViolence(ent)
    if (not IsValid(ent)) then return end

    if (ent:IsPlayer()) then
        self:SetTargetViolence(ent, self:GetTargetViolence(ent) + 1)
    end
end

function ENT:HaveTarget()
    local target = self:GetTarget()
    if (IsValid(target) and self:CanBeTarget(target)) then return true end

    return self:FindTarget()
end

function ENT:FindTarget()
    if (self.Suicidal) then return true end --while holding grenades, cannot have target changed

    if (self.NextTargetTime and self.NextTargetTime > CurTime()) then
        self:SetTarget(nil)

        return false
    end

    local _ents = KLEINER_NPC_TARGETS
    local targetsum = 0
    local targets = {}
    local targetcount = 0
    local playersum = 0

    for ent, val in pairs(_ents) do
        if (self:CanBecomeTarget(ent) and self:GetTargetPriority(ent) > 0) then
            if (ent:IsPlayer()) then
                playersum = playersum + 1
            end

            table.insert(targets, ent)
            targetsum = targetsum + self:GetTargetPriority(ent)
            targetcount = targetcount + 1
        end
    end

    targetsum = targetsum + (targetcount * 0.5)
    local samplevalue = math.Rand(0, 1) * targetsum

    for key, ent in pairs(targets) do
        samplevalue = samplevalue - self:GetTargetPriority(ent)

        if (samplevalue <= 0) then
            self:SetTarget(ent)

            return true
        end
    end

    --slowly die if they end up somewhere where nobody is
    if (playersum == 0) then
        self:SetHealth(self:Health() - 5)

        if (self:Health() <= 0) then
            self:Remove()

            return
        end
    end

    self.NextTargetTime = CurTime() + 2
    self:SetTarget(nil)

    return false
end

function ENT:ResetBehavior()
    if (self.Suicidal) then return end
    self.shifted = nil

    if (self.path and IsValid(self.path)) then
        self.path:Invalidate()
        self.path = nil
    end

    self.TouchedDoor = nil
    self.ManualTarget = nil
    self.NeedsTarget = true
    --self:FindTarget() 
end

function ENT:WanderToPos(pos)
    self:ResetBehavior()
    self.WanderForcePos = type(vector) and pos
end

function ENT:IgnoreTarget(target)
    self.TargetBlacklist = self.TargetBlacklist or {}
    self.TargetBlacklist[target] = CurTime() + 5
end

function ENT:RunBehaviour()
    -- This function is called when the entity is first spawned, it acts as a giant loop that will run as long as the NPC exists
    while (true) do
        if (self.loco:IsStuck()) then
            self:HandleStuck()
        end

        if (self.NeedsTarget) then
            self:FindTarget()
            self.NeedsTarget = nil
        end

        if (IsValid(self:GetTarget()) and self:CanBeTarget(self:GetTarget())) then
            self.loco:SetDesiredSpeed((self.Suicidal and 350) or (self:GetBased() and 500) or 200)
            self.loco:SetAcceleration(self.Suicidal and 400 or 200)
            self.loco:SetDeceleration(self.Suicidal and 400 or 500)
            self.loco:SetJumpHeight(100)

            if (not self:NearTarget()) then
                local result = self:ChaseTarget()

                --if chasing the target fails somehow, its probably a wise assumption that its redundant to keep trying.
                if (result == "failed") then
                    self:IgnoreTarget(self:GetTarget())
                    self:ResetBehavior()
                end
            end

            if (self:NearTarget()) then
                if (not self:IsTalking()) then
                    self:SayStuff()
                end

                self.loco:FaceTowards(self:GetTarget():GetPos())

                if (not self.shifted) then
                    local result = self:MoveToPos(self:GetTarget():GetPos() + VectorRand() * Vector(1, 1, 0):GetNormalized() * math.Rand(80, 150), {
                        maxage = 50
                    })

                    if (result ~= "ok") then
                        self:ResetBehavior()
                    end

                    --cheap method of keeping kleiners with similar targets from clumping together. i figure it's cheaper than some kind of avoidance.
                    self.shifted = true
                end

                coroutine.wait(0.15)
            else
                self.shifted = nil
            end

            if (self.ManualTarget == nil and math.random(1, 100) == 1) then
                self:ResetBehavior()
            end
        else
            -- no target, so we wander.
            self.loco:SetDesiredSpeed(self.Suicidal and 350 or 200)
            self.loco:SetAcceleration(self.Suicidal and 400 or 200)
            self.loco:SetDeceleration(self.Suicidal and 900 or 900)

            if (math.random(1, 50) == 1) then
                self:ResetBehavior()
            else
                local wanderpos

                if (self.WanderForcePos) then
                    wanderpos = self.WanderForcePos + VectorRand() * Vector(1, 1, 0):GetNormalized() * math.Rand(80, 150)
                end

                wanderpos = wanderpos or self:FindSpot("random", {
                    type = "hiding",
                    pos = self:GetPos(),
                    radius = 4000,
                    stepup = 900,
                    stepdown = 900
                })

                if (wanderpos ~= nil) then
                    self.WanderForcePos = nil

                    self:MoveToPos(wanderpos, {
                        maxage = 5
                    })
                end
            end
        end

        -- At this point in the code the bot has stopped chasing the player or finished walking to a random spot
        -- Using this next function we are going to wait 2 seconds until we go ahead and repeat it 
        coroutine.wait(0.4)
    end
end

function ENT:MoveToPos(pos, options)
    if (pos == nil) then return "failed" end
    local options = options or {}
    local path = Path("Follow")
    path:SetMinLookAheadDistance(options.lookahead or 300)
    path:SetGoalTolerance(options.tolerance or 20)
    path:Compute(self, pos)
    self.path = path

    if (not path:IsValid()) then
        self.path = nil

        return "failed"
    end

    while (path:IsValid()) do
        local shouldpath = self:WhilePathing(path)

        if (shouldpath) then
            path:Update(self)
        end

        -- Draw the path (only visible on listen servers or single player)
        if (options.draw) then
            path:Draw()
        end

        if (self.loco:IsStuck()) then
            self:HandleStuck()

            return "stuck"
        end

        --
        -- If they set maxage on options then make sure the path is younger than it
        --
        if (options.maxage) then
            if (path:GetAge() > options.maxage) then
                self.path = nil

                return "timeout"
            end
        end

        --
        -- If they set repath then rebuild the path every x seconds
        --
        if (options.repath) then
            if (path:GetAge() > options.repath) then
                path:Compute(self, pos)
            end
        end

        coroutine.yield()
    end

    return "ok"
end

function ENT:GetCurrentPathPoint()
    if (self.path and self.path:IsValid()) then
        local start = 1

        for k, v in pairs(self.path:GetAllSegments()) do
            if (k ~= 1 and (v.pos * Vector(1, 1, 0)):Distance(self:GetPos() * Vector(1, 1, 0)) > 32) then
                start = k
                break
            end
        end

        if (start > 1) then
            start = start - 1
        end

        return self.path:GetAllSegments()[start], start
    end

    return nil, -1
end

function ENT:GetNextPathPoint(ahead)
    if (not self.path or not self.path:IsValid()) then return end
    ahead = ahead or 1
    local seg, index = self:GetCurrentPathPoint()
    if (index) then return self.path:GetAllSegments()[index + ahead] end
end

function ENT:HandleStuck()
    local spot = self:GetNextPathPoint()

    if (spot) then
        self:SetHealth(self:Health() - 5)

        if (self:Health() <= 0) then
            self:Remove()

            return
        end

        self:Teleport(spot.pos)
        self.loco:ClearStuck()
    else
        self:SetHealth(self:Health() - 5)

        if (self:Health() <= 0) then
            self:Remove()

            return
        end

        self.loco:Jump()
        self.loco:ClearStuck()
    end
end

function ENT:Teleport(newpos)
    local caneffect = self.NextTeleport == nil or self.NextTeleport < CurTime()

    if (caneffect) then
        -- deleting beam effect for now due to weird visual behavior.
        local effectdata = EffectData()
        effectdata:SetMagnitude(5)
        effectdata:SetNormal(Vector(0, 0, 1))
        effectdata:SetOrigin(self:GetPos() + Vector(0, 0, 40))
        util.Effect("cball_explode", effectdata) --make a cool energy ball explosion
        self:SetPos(newpos)
        effectdata:SetOrigin(self:GetPos() + Vector(0, 0, 40))
        util.Effect("cball_explode", effectdata) -- make another one at the new spot	
        self:EmitSound("Weapon_PhysCannon.Launch")
        self.NextTeleport = CurTime() + 1
    else
        self:SetPos(newpos)
    end
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
    KLPATHGEN_ITERS_BUDGET = KleinerPathingIterationLimit()
    local success = path:Compute(self, self:GetTarget():GetPos(), self.PathGen)
    if (not success) then return "failed" end
    if (not path:IsValid()) then return "failed" end
    local target = self:GetTarget()

    while (path:IsValid() and self:HaveTarget() and not self:NearTarget() and IsValid(target)) do
        self.loco:SetStepHeight(32)
        self.loco:SetDeathDropHeight(5000)
        local range = self:GetRangeTo(self:GetTarget():GetPos()) or self.LoseTargetDist
        local updaterate = math.max(KleinerPathingRateHigh() * (range / self.LoseTargetDist), 0.5)

        if (path:GetAge() > updaterate and target:IsOnGround()) then
            RELEVANT_KLEINER = self -- see ENT.PathGen for explanation
            KLPATHGEN_ITERS = 0
            KLPATHGEN_ITERS_BUDGET = KleinerPathingIterationLimit()
            local success = path:Compute(self, self:GetTarget():GetPos(), self.PathGen)
            if (not success) then return "failed" end
        end

        if (not path:IsValid()) then return "failed" end
        local shouldpath = self:WhilePathing(path)

        if (shouldpath) then
            path:Update(self)
        end

        if (options.draw) then
            path:Draw()
        end

        if (self.loco:IsStuck()) then
            self:HandleStuck()

            return "stuck"
        end

        coroutine.yield()
    end

    return "ok"
end

function ENT:OnContact(ent)
    if (self.path and ent:GetClass() == "prop_door_rotating") then
        self.TouchedDoor = true
    end
end

--this function runs during the path movement. returning false will interrupt path movement, in case other actions are needed.
function ENT:WhilePathing(path)
    if (path == nil or not path:IsValid()) then return true end
    if (self.loco == nil) then return true end
    if (not self:OnGround() and self:GetVelocity().z < -50) then return false end --attempting to move while falling seems to pause falling
    local seg1, index = self:GetCurrentPathPoint() --this returns the first path segment we're closest to.
    local seg2 = path:GetAllSegments()[index + 1]
    local seg3 = path:GetAllSegments()[index + 2]
    local dir = self:GetForward()

    if (seg1 and seg2) then
        dir = (seg2.pos - seg1.pos):GetNormalized()
    end

    -- If a kleiner touches a door while moving along a path, it's more than likely he needs to pass that door. The cheapest method is to teleport hi.
    if (self.TouchedDoor and seg1) then
        self:Teleport((seg3 and seg3.pos) or (seg2 and seg2.pos) or (seg1 and seg1.pos))
        self.TouchedDoor = nil

        return
    end

    -- a quick fix to the broken ladder handling. If they are about to climb a ladder, teleport them instead
    --everything goes wrong when we use ladders so let's try to teleport over them.
    if (seg2 and seg2.ladder:IsValid()) then
        self:Teleport((seg3 and seg3.pos) or (seg2 and seg2.pos))

        return
    end

    --If any nav areas are marked as STOP and AVOID, we automatically teleport over them.
    if (seg2 and seg2.area:HasAttributes(NAV_MESH_JUMP) and seg2.area:HasAttributes(NAV_MESH_AVOID)) then
        --self:Teleport((seg3 and seg3.pos) or (seg2 and seg2.pos))
        if (seg3 and seg3.area ~= seg1.area) then
            self.loco:JumpAcrossGap((seg3 and seg3.pos) or (seg2 and seg2.pos), dir)

            return
        end
    end

    -- if they're on a ladder, their physics have been permanently broken so we'll just delete him.
    if (self.loco:IsUsingLadder()) then
        self:Remove()

        return
    end

    -- Jumping handling
    local ofs = (seg2.pos - self:GetPos())
    local heightdist = ofs.z
    local lendist = (ofs * Vector(1, 1, 0)):Length()
    local jumpdir = (ofs * Vector(1, 1, 0)):GetNormalized()
    local inrange = lendist < 64
    local shouldjump = inrange and (seg3 and (seg3.area:HasAttributes(NAV_MESH_JUMP) or seg3.type == 2 or seg3.type == 3))
    local across = (math.abs(heightdist) < 64)

    if (self:IsOnGround() and shouldjump) then
        if (across) then
            self.loco:JumpAcrossGap((seg3 and seg3.pos) or (seg2 and seg2.pos), dir)
        else
            self.loco:Jump()
        end
    end

    return true
end

ENT.PathGen = function(area, fromArea, ladder, elevator, length)
    KLPATHGEN_ITERS = (KLPATHGEN_ITERS or 0) + 1
    local self = RELEVANT_KLEINER --this is bullshit, i guess this callback doesn't include the entity pathing. 
    if (not IsValid(self)) then return -1 end

    if (not IsValid(fromArea)) then
        return 0
    else
        if (KLPATHGEN_ITERS > KLPATHGEN_ITERS_BUDGET) then return -1 end
        if (not self.loco:IsAreaTraversable(area) and not ladder:IsValid()) then return -1 end
        --if(!self:PosInRange(area:GetCenter()))then return -1 end
        local dist = 0

        if (IsValid(ladder)) then
            dist = ladder:GetLength()
        elseif (length > 0) then
            dist = length
        else
            dist = (area:GetCenter() - fromArea:GetCenter()):Length()
        end

        local cost = dist + fromArea:GetCostSoFar()
        local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange(area)

        if (not ladder:IsValid()) then
            if (deltaZ >= self.loco:GetStepHeight()) then
                if (deltaZ >= self.loco:GetMaxJumpHeight()) then return -1 end
                local jumpPenalty = 2
                cost = cost + jumpPenalty * dist
            elseif (deltaZ < -self.loco:GetDeathDropHeight()) then
                return -1
            end
        end

        if (IsValid(area) and area:HasAttributes(NAV_MESH_AVOID) and area:IsUnderwater()) then return -1 end

        if (IsValid(area) and area:HasAttributes(NAV_MESH_AVOID)) then
            cost = cost + 100
        end

        return cost
    end
end

ENT.ShortChatter = {"vo/k_lab/kl_dearme.wav", "vo/k_lab/kl_excellent.wav", "vo/k_lab/kl_fiddlesticks.wav", "vo/k_lab/kl_mygoodness01.wav", "vo/k_lab/kl_ohdear.wav", "vo/k_lab2/kl_greatscott.wav",}

ENT.Chatter = {"vo/k_lab/kl_almostforgot.wav", "vo/k_lab/kl_barneyhonor.wav", "vo/k_lab/kl_barneysturn.wav", "vo/k_lab/kl_besokind.wav", "vo/k_lab/kl_blast.wav", "vo/k_lab/kl_bonvoyage.wav", "vo/k_lab/kl_cantcontinue.wav", "vo/k_lab/kl_cantwade.wav", "vo/k_lab/kl_careful.wav", "vo/k_lab/kl_charger01.wav", "vo/k_lab/kl_charger02.wav", "vo/k_lab/kl_coaxherout.wav", "vo/k_lab/kl_comeout.wav", "vo/k_lab/kl_credit.wav", "vo/k_lab/kl_dearme.wav", "vo/k_lab/kl_debeaked.wav", "vo/k_lab/kl_delaydanger.wav", "vo/k_lab/kl_diditwork.wav", "vo/k_lab/kl_ensconced.wav", "vo/k_lab/kl_excellent.wav", "vo/k_lab/kl_fewmoments01.wav", "vo/k_lab/kl_fewmoments02.wav", "vo/k_lab/kl_fiddlesticks.wav", "vo/k_lab/kl_finalsequence.wav", "vo/k_lab/kl_finalsequence02.wav", "vo/k_lab/kl_fitglove01.wav", "vo/k_lab/kl_fitglove02.wav", "vo/k_lab/kl_fruitlessly.wav", "vo/k_lab/kl_getinposition.wav", "vo/k_lab/kl_getoutrun01.wav", "vo/k_lab/kl_getoutrun02.wav", "vo/k_lab/kl_getoutrun03.wav", "vo/k_lab/kl_gordongo.wav", "vo/k_lab/kl_gordonthrow.wav", "vo/k_lab/kl_helloalyx01.wav", "vo/k_lab/kl_helloalyx02.wav", "vo/k_lab/kl_heremypet01.wav", "vo/k_lab/kl_heremypet02.wav", "vo/k_lab/kl_hesnotthere.wav", "vo/k_lab/kl_holdup01.wav", "vo/k_lab/kl_holdup02.wav", "vo/k_lab/kl_interference.wav", "vo/k_lab/kl_islamarr.wav", "vo/k_lab/kl_lamarr.wav", "vo/k_lab/kl_masslessfieldflux.wav", "vo/k_lab/kl_modifications01.wav", "vo/k_lab/kl_modifications02.wav", "vo/k_lab/kl_moduli02.wav", "vo/k_lab/kl_mygoodness01.wav", "vo/k_lab/kl_mygoodness02.wav", "vo/k_lab/kl_mygoodness03.wav", "vo/k_lab/kl_nocareful.wav", "vo/k_lab/kl_nonsense.wav", "vo/k_lab/kl_nownow01.wav", "vo/k_lab/kl_nownow02.wav", "vo/k_lab/kl_ohdear.wav", "vo/k_lab/kl_opportunetime01.wav", "vo/k_lab/kl_opportunetime02.wav", "vo/k_lab/kl_packing01.wav", "vo/k_lab/kl_packing02.wav", "vo/k_lab/kl_plugusin.wav", "vo/k_lab/kl_projectyou.wav", "vo/k_lab/kl_redletterday01.wav", "vo/k_lab/kl_redletterday02.wav", "vo/k_lab/kl_relieved.wav", "vo/k_lab/kl_slipin01.wav", "vo/k_lab/kl_slipin02.wav", "vo/k_lab/kl_suitfits01.wav", "vo/k_lab/kl_suitfits02.wav", "vo/k_lab/kl_thenwhere.wav", "vo/k_lab/kl_waitmyword.wav", "vo/k_lab/kl_weowe.wav", "vo/k_lab/kl_whatisit.wav", "vo/k_lab/kl_wishiknew.wav", "vo/k_lab/kl_yourturn.wav", "vo/k_lab2/kl_aroundhere.wav", "vo/k_lab2/kl_atthecitadel01.wav", "vo/k_lab2/kl_atthecitadel01_b.wav", "vo/k_lab2/kl_aweekago01.wav", "vo/k_lab2/kl_blowyoustruck01.wav", "vo/k_lab2/kl_blowyoustruck02.wav", "vo/k_lab2/kl_cantleavelamarr.wav", "vo/k_lab2/kl_cantleavelamarr_b.wav", "vo/k_lab2/kl_comeoutlamarr.wav", "vo/k_lab2/kl_dontgiveuphope02.wav", "vo/k_lab2/kl_dontgiveuphope03.wav", "vo/k_lab2/kl_givenuphope.wav", "vo/k_lab2/kl_greatscott.wav", "vo/k_lab2/kl_howandwhen01.wav", "vo/k_lab2/kl_howandwhen02.wav", "vo/k_lab2/kl_lamarr.wav", "vo/k_lab2/kl_lamarrwary01.wav", "vo/k_lab2/kl_lamarrwary02.wav", "vo/k_lab2/kl_nolongeralone.wav", "vo/k_lab2/kl_nolongeralone_b.wav", "vo/k_lab2/kl_notallhopeless.wav", "vo/k_lab2/kl_notallhopeless_b.wav", "vo/k_lab2/kl_onehedy.wav", "vo/k_lab2/kl_slowteleport01.wav", "vo/k_lab2/kl_slowteleport01_b.wav", "vo/k_lab2/kl_slowteleport02.wav"}