-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = true
SWEP.CSSWeapon = true
SWEP.DropOnGround = true
SWEP.DrawWeaponInfoBox = false
SWEP.BounceWeaponIcon = false

hook.Add("EntityNetworkedVarChanged", "SetNetworkedProperty", function(ent, name, oldval, newval)
    if name:StartWith("NP_") then
        timer.Simple(0, function()
            if IsValid(ent) then
                ent[name:sub(4)] = newval
            end
        end)
    end
end)

function SWEP:GetSpray()
    local recoverytime = (self:GetOwner():Crouching() and self.RecoveryTimeCrouch or self.RecoveryTimeStand)
    recoverytime = recoverytime * (self.SprayMax / self.SprayIncrement)

    return math.max(0, self:GetLastShotSpray() - math.max(0, CurTime() - self:GetLastFire()) / recoverytime)
end

function SWEP:Reload()
    if self.UseShellReload then return self:ShellReload() end

    if self:GetMaxClip1() ~= -1 and not self:GetInReload() and self:GetNextPrimaryFire() < CurTime() then
        -- self:SetShotsFired(0)
        local can = self:MainReload(self:TranslateViewModelActivity(ACT_VM_RELOAD))

        if can then
            if self:IsScoped() then
                self:SetFOVRatio(1, 0.05)
            end
        end

        return can
    end
end

function SWEP:ShellReload()
    local pPlayer = self.Owner
    if not IsValid(pPlayer) then return end
    if pPlayer:GetAmmoCount(self.Primary.Ammo) <= 0 or self:Clip1() >= self.Primary.ClipSize then return end
    if self:GetNextPrimaryFire() > CurTime() then return end

    if self:GetSpecialReload() == 0 then
        pPlayer:SetAnimation(PLAYER_RELOAD)
        self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
        self:SetSpecialReload(1)
        self:SetNextPrimaryFire(CurTime() + 0.5)
        self:SetNextIdle(CurTime() + 0.5)
        -- DoAnimationEvent( PLAYERANIMEVENT_RELOAD_START ) - Missing event

        return true
    elseif self:GetSpecialReload() == 1 then
        if self:GetNextIdle() > CurTime() then return true end
        self:SetSpecialReload(2)
        self:SendWeaponAnim(ACT_VM_RELOAD)
        self:SetNextIdle(CurTime() + 0.5)

        if self:Clip1() >= self:GetMaxClip1() - 1 then
            pPlayer:DoAnimationEvent(PLAYERANIMEVENT_RELOAD_END)
        else
            pPlayer:DoAnimationEvent(PLAYERANIMEVENT_RELOAD_LOOP)
        end
    else
        self:SetClip1(self:Clip1() + 1)
        pPlayer:DoAnimationEvent(PLAYERANIMEVENT_RELOAD)
        pPlayer:RemoveAmmo(1, self.Primary.Ammo)
        self:SetSpecialReload(1)
    end

    return true
end

function SWEP:ShellReloadThink()
    local pPlayer = self.Owner
    if not IsValid(pPlayer) then return end

    if self:GetNextIdle() < CurTime() then
        if self:Clip1() == 0 and self:GetSpecialReload() == 0 and pPlayer:GetAmmoCount(self.Primary.Ammo) ~= 0 then
            self:ShellReload()
        elseif self:GetSpecialReload() ~= 0 then
            if self:Clip1() ~= self:GetMaxClip1() and pPlayer:GetAmmoCount(self.Primary.Ammo) ~= 0 then
                self:ShellReload()
            else
                self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
                self:SetSpecialReload(0)
                -- self:SetNextIdle(CurTime() + 1)
            end
        else
            self:SendWeaponAnim(ACT_VM_IDLE)
        end
    end
end

function SWEP:HandleReload()
end

--Jvs: can't call it DefaultReload because there's already one in the weapon's metatable and I'd rather not cause conflicts
function SWEP:MainReload(act)
    local owner = self:GetOwner()
    if owner:GetAmmoCount(self:GetPrimaryAmmoType()) <= 0 then return false end
    if not (self:GetMaxClip1() ~= -1 and self:GetMaxClip1() > self:Clip1() and owner:GetAmmoCount(self:GetPrimaryAmmoType()) > 0) then return end
    self:WeaponSound("reload")
    self:SendWeaponAnim(act)
    owner:DoReloadEvent()
    local endtime = CurTime() + self:SequenceDuration()
    self:SetNextPrimaryFire(endtime)
    self:SetNextSecondaryFire(endtime)
    self:SetInReload(true)

    return true
end

-- function SWEP:GetMaxClip1()
--     return self.Primary.ClipSize
-- end
-- function SWEP:GetMaxClip2()
--     return self.Secondary.ClipSize
-- end
function SWEP:PrimaryAttack()
    self:GunFire()

    if self.UseShellReload then
        self:SetSpecialReload(0)
    end
end

function SWEP:SecondaryAttack()
    if not self.ScopeLevels then return end
    local ply = self:GetOwner()

    -- if (self:GetZoomFullyActiveTime() > CurTime() or self:GetNextPrimaryFire() > CurTime()) then
    --     self:SetNextSecondaryFire(self:GetZoomFullyActiveTime() + 0.15)
    --     return
    -- end
    if self:IsScoped() then
        local nextlevel = 2

        for i = 2, #self.ScopeLevels do
            if math.abs(self.ScopeLevels[i] - self:GetTargetFOVRatio()) < 0.0001 then
                currentlevel = i + 1
            end
        end

        if nextlevel > #self.ScopeLevels then
            self:SetFOVRatio(1, 0.1)
        else
            self:SetFOVRatio(self.ScopeLevels[nextlevel], 0.08)
        end
    else
        self:SetFOVRatio(self.ScopeLevels[1], 0.15)
        self:SetNextPrimaryFire(math.max(CurTime() + 0.1, self:GetNextPrimaryFire()))
    end

    self:EmitSound("Default.Zoom", nil, nil, nil, CHAN_AUTO)
    self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:Holster()
    self:SetInReload(false)

    return true
end

function SWEP:WeaponSound(soundtype)
    local sndname = (self.SoundData or {})[soundtype]

    if sndname then
        self:EmitSound(sndname, nil, nil, nil, CHAN_AUTO)
    end
end

function SWEP:DoKickBack(up_base, lateral_base, up_modifier, lateral_modifier, up_max, lateral_max, direction_change)
    if not self:GetOwner():IsPlayer() then return end
    local spraymodifier = self:GetSpray() * 15
    local flKickUp = up_base + spraymodifier * up_modifier
    local flKickLateral = lateral_base + spraymodifier * lateral_modifier
    --[[
		Jvs:
			I implemented the shots fired and direction stuff on the cs base because it would've been dumb to do it
			on the player, since it's reset on a gun basis anyway
	]]
    -- This is the first round fired
    -- if self:GetShotsFired() == 1 then
    --     flKickUp = up_base
    --     flKickLateral = lateral_base
    -- else
    --     flKickUp = up_base + self:GetShotsFired() * up_modifier
    --     flKickLateral = lateral_base + self:GetShotsFired() * lateral_modifier
    -- end
    local angle = self:GetOwner():GetViewPunchAngles()
    angle.x = math.max(-up_max, angle.x - flKickUp)

    if self:GetDirection() == 1 then
        angle.y = math.min(lateral_max, angle.y + flKickLateral)
    else
        angle.y = math.max(-lateral_max, angle.y - flKickLateral)
    end

    --[[
		Jvs: uhh I don't get this code, so they run a random int from 0 up to direction_change,
		( which varies from 5 to 9 in the ak47 case)
		if the random craps out a 0, they make the direction negative and damp it by 1
		the actual direction in the whole source code is only used above, and it produces a different kick if it's at 1

		I don't know if the guy that made this was a genius or..
	]]
    if math.floor(util.SharedRandom("KickBack", 0, direction_change)) == 0 then
        self:SetDirection(1 - self:GetDirection())
    end

    self:GetOwner():SetViewPunchAngles(angle)
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self:SetDelayFire(true)
    self:SetSpecialReload(0)
    -- self:SetWeaponType(self.WeaponTypeToString[self.WeaponType])
    self:SetLastFire(CurTime())
end

function SWEP:SetupDataTables()
    print(self)
    self:NetworkVar("Float", 0, "LastShotSpray")
    self:NetworkVar("Float", 1, "SprayUpdateTime")
    self:NetworkVar("Float", 2, "Accuracy")
    -- self:NetworkVar("Float", 4, "NextDecreaseShotsFired")
    self:NetworkVar("Int", 0, "WeaponType")
    -- self:NetworkVar("Int", 1, "ShotsFired")
    self:NetworkVar("Int", 2, "Direction")
    self:NetworkVar("Int", 3, "WeaponID")
    self:NetworkVar("Int", 4, "SpecialReload")
    self:NetworkVar("Bool", 0, "InReload")
    self:NetworkVar("Bool", 2, "DelayFire")
    --Jvs: stuff that is scattered around all the weapons code that I'm going to try and unify here
    self:NetworkVar("Float", 5, "ZoomFullyActiveTime")
    self:NetworkVar("Float", 6, "ZoomLevel")
    self:NetworkVar("Float", 7, "NextBurstFire") --when the next burstfire is gonna happen, same as nextprimaryattack
    self:NetworkVar("Float", 9, "BurstFireDelay") --the speed of the burst fire itself, 0.5 means two shots every second etc
    self:NetworkVar("Float", 10, "LastFire")
    self:NetworkVar("Float", 14, "PreviousTargetFOVRatio")
    self:NetworkVar("Float", 11, "TargetFOVRatio")
    self:NetworkVar("Float", 12, "TargetFOVStartTime")
    self:NetworkVar("Float", 13, "TargetFOVEndTime")
    -- self:NetworkVar("Float", 14, "CurrentFOVRatio")
    -- self:NetworkVar("Float", 15, "StoredFOVRatio")
    -- self:NetworkVar("Float", 16, "LastZoom")
    -- self:NetworkVar("Bool", 5, "ResumeZoom")
    self:NetworkVar("Int", 4, "BurstFires") --goes from X to 0, how many burst fires we're going to do
    -- self:NetworkVar("Int", 5, "MaxBurstFires")
end

-- function SWEP:SetHoldType(ht)
--     self.keepht = ht
--     return BaseClass.SetHoldType(self, ht)
-- end
function SWEP:Deploy()
    self:SetHoldType(self.HoldType)
    self:SetDelayFire(false)
    self:SetZoomFullyActiveTime(-1)
    self:SetAccuracy(0.2)
    self:SetBurstFires(self.BurstFire or 0)
    -- self:SetCurrentFOVRatio(1)
    self:SetPreviousTargetFOVRatio(1)
    self:SetTargetFOVRatio(1)
    -- self:SetStoredFOVRatio(1)
    self:SetTargetFOVStartTime(0)
    self:SetTargetFOVEndTime(0)
    -- self:SetResumeZoom(false)
    -- if self.keepht then
    --     self:SetHoldType(self.keepht)
    -- end
    -- self:SetNextDecreaseShotsFired(CurTime())
    -- self:SetShotsFired(0)
    self:SetInReload(false)
    self:SendWeaponAnim(self:TranslateViewModelActivity(ACT_VM_DRAW))
    self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
    self:SetNextSecondaryFire(CurTime() + self:SequenceDuration())

    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        self:GetOwner():SetFOV(0)
    end

    return true
end

-- --Jvs : this function handles the zoom smoothing and decay
-- function SWEP:HandleZoom()
--     --GOOSEMAN : Return zoom level back to previous zoom level before we fired a shot. This is used only for the AWP.
--     -- And Scout.
--     local pPlayer = self:GetOwner()
--     if not pPlayer:IsValid() then return end
--     if ((self:GetNextPrimaryFire() <= CurTime()) and self:GetResumeZoom()) then
--         if (self:GetFOVRatio() == self:GetLastZoom()) then
--             -- return the fade level in zoom.
--             self:SetResumeZoom(false)
--             return
--         end
--         self:SetFOVRatio(self:GetLastZoom(), 0.05)
--         self:SetNextPrimaryFire(CurTime() + 0.05)
--         self:SetZoomFullyActiveTime(CurTime() + 0.05) -- Make sure we think that we are zooming on the server so we don't get instant acc bonus
--     end
-- end
-- function SWEP:FOVThink()
--     local fovratio
--     local deltaTime = (CurTime() - self:GetTargetFOVStartTime()) / self:GetTargetFOVTime()
--     if (deltaTime > 1 or self:GetTargetFOVTime() == 0) then
--         fovratio = self:GetTargetFOVRatio()
--     else
--         fovratio = Lerp(math.Clamp(deltaTime, 0, 1), self:GetStoredFOVRatio(), self:GetTargetFOVRatio())
--     end
--     self:SetCurrentFOVRatio(fovratio)
-- end
function SWEP:SetFOVRatio(fov, time)
    -- if (self:GetFOVRatio() ~= self:GetStoredFOVRatio()) then
    --     self:SetStoredFOVRatio(self:GetFOVRatio())
    -- end
    self:SetPreviousTargetFOVRatio(self:GetTargetFOVRatio())
    self:SetTargetFOVRatio(fov)
    self:SetTargetFOVStartTime(CurTime())
    self:SetTargetFOVEndTime(CurTime() + time)
end

function SWEP:GetCurrentFOVRatio()
    local st = self:GetTargetFOVStartTime()

    return Lerp(math.Clamp((CurTime() - st) / (self:GetTargetFOVEndTime() - st), 0, 1), self:GetPreviousTargetFOVRatio(), self:GetTargetFOVRatio())
end

function SWEP:TranslateFOV(fov)
    return fov * self:GetCurrentFOVRatio()
end

--NOMINIFY
function SWEP:Think()
    if self.UseShellReload then return self:ShellReloadThink() end
    -- self:FOVThink()
    -- self:UpdateWorldModel()
    -- self:HandleZoom()
    local pPlayer = self:GetOwner()
    if not IsValid(pPlayer) then return end

    --[[
		Jvs:
			this is where the reload actually ends, this might be moved into its own function so other coders
			can add other behaviours ( such as cs:go finishing the reload with a different delay, based on when the
			magazine actually gets inserted )
	]]
    if self:GetInReload() and self:GetNextPrimaryFire() <= CurTime() then
        -- complete the reload.
        --Jvs TODO: shotgun reloading here
        local j = math.min(self:GetMaxClip1() - self:Clip1(), pPlayer:GetAmmoCount(self:GetPrimaryAmmoType()))
        -- Add them to the clip
        self:SetClip1(self:Clip1() + j)
        pPlayer:RemoveAmmo(j, self:GetPrimaryAmmoType())
        self:SetInReload(false)
    end

    if CLIENT and game.SinglePlayer() then return end
    local plycmd = pPlayer:GetCurrentCommand()

    -- if not plycmd:KeyDown(IN_ATTACK) and not plycmd:KeyDown(IN_ATTACK2) then
    --     -- no fire buttons down
    --     -- The following code prevents the player from tapping the firebutton repeatedly
    --     -- to simulate full auto and retaining the single shot accuracy of single fire
    --     if self:GetDelayFire() then
    --         self:SetDelayFire(false)
    --         if self:GetShotsFired() > 15 then
    --             self:SetShotsFired(15)
    --         end
    --         self:SetNextDecreaseShotsFired(CurTime() + 0.4)
    --     end
    --     -- REMOVED?
    --     -- if self:IsPistol() then
    --     --     self:SetShotsFired(0)
    --     -- else
    --     if self:GetShotsFired() > 0 and self:GetNextDecreaseShotsFired() < CurTime() then
    --         self:SetNextDecreaseShotsFired(CurTime() + 0.0225)
    --         self:SetShotsFired(self:GetShotsFired() - 1)
    --     end
    --     -- end
    --     -- there are no idle animations
    --     -- if CurTime() > self:GetNextIdle() and self:GetNextPrimaryFire() <= CurTime() and self:GetNextSecondaryFire() <= CurTime() and self:Clip1() ~= 0 then
    --     --     self:SetNextIdle(CurTime() + self.IdleInterval)
    --     --     self:SendWeaponAnim(self:TranslateViewModelActivity(ACT_VM_IDLE))
    --     -- end
    -- end
    if not self:GetInReload() and self.BurstFire and self:GetNextBurstFire() < CurTime() and self:GetNextBurstFire() ~= -1 then
        if self:GetBurstFires() < (self.BurstFire - 1) then
            if self:Clip1() <= 0 then
                self:SetBurstFires(self.BurstFire)
            else
                self:SetNextPrimaryFire(CurTime() - 1)
                self:PrimaryAttack()
                self:SetNextPrimaryFire(CurTime() + 0.5) --this artificial delay is inherited from the glock code
                self:SetBurstFires(self:GetBurstFires() + 1)
            end
        else
            if self:GetNextBurstFire() < CurTime() and self:GetNextBurstFire() ~= -1 then
                self:SetBurstFires(0)
                self:SetNextBurstFire(-1)
            end
        end
    end
end

function SWEP:DoFireEffects()
    if not self.Silenced then
        --Jvs: on the client, we don't want to show this muzzle flash on the owner of this weapon if he's in first person
        --TODO: spectator support? who even gives a damn but ok
        if CLIENT then
            if self:IsCarriedByLocalPlayer() and not self:GetOwner():ShouldDrawLocalPlayer() then return end
        end

        --Jvs NOTE: prediction should already prevent this from sending the effect to the owner's client side
        local data = EffectData()
        data:SetFlags(0)
        data:SetEntity(self)
        data:SetAttachment(self:LookupAttachment("muzzle"))
        data:SetScale(self.MuzzleFlashScale)

        if self.CSMuzzleX then
            util.Effect("CS_MuzzleFlash_X", data)
        else
            util.Effect("CS_MuzzleFlash", data)
        end
    end
end

function SWEP:TranslateViewModelActivity(act)
    return act
end

function SWEP:AdjustMouseSensitivity()
    local r = self:GetCurrentFOVRatio()
    if r < 1 then return r * GetConVar("zoom_sensitivity_ratio"):GetFloat() end
end

function SWEP:IsScoped()
    return self:GetCurrentFOVRatio() < 1
end

function SWEP:GunFire()
    local scoped = self:IsScoped()
    local ply = self:GetOwner()
    -- print("GF",cycletime)
    -- cycletime=cycletime*10 
    self:SetDelayFire(true)

    -- self:SetShotsFired(self:GetShotsFired() + 1)
    -- -- These modifications feed back into flSpread eventually.
    -- if pCSInfo.AccuracyDivisor ~= -1 then
    -- 	local iShotsFired = self:GetShotsFired()
    -- 	if pCSInfo.AccuracyQuadratic then
    -- 		iShotsFired = iShotsFired * iShotsFired
    -- 	else
    -- 		iShotsFired = iShotsFired * iShotsFired * iShotsFired 
    -- 	end
    -- 	self:SetAccuracy(( iShotsFired / pCSInfo.AccuracyDivisor) + pCSInfo.AccuracyOffset )
    -- 	if self:GetAccuracy() > pCSInfo.MaxInaccuracy then
    -- 		self:SetAccuracy( pCSInfo.MaxInaccuracy )
    -- 	end
    -- end
    -- Out of ammo?
    if self:Clip1() <= 0 then
        self:EmitSound((self.GunType == "pistol" or self.GunType == "heavypistol") and "Default.ClipEmpty_Pistol" or "Default.ClipEmpty_Rifle", nil, nil, nil, CHAN_AUTO)
        self:SetNextPrimaryFire(CurTime() + 0.2)

        return false
    end

    self:SendWeaponAnim(self:TranslateViewModelActivity(ACT_VM_PRIMARYATTACK))
    self:SetClip1(self:Clip1() - 1)

    if SERVER and (ply.GetLocationName and ply:GetLocationName() == "Weapons Testing Range") then
        ply:GiveAmmo(1, self:GetPrimaryAmmoType())
    end

    -- player "shoot" animation
    ply:DoAttackEvent()
    spread = self:GetSpread()
    -- self:FireCSSBullet(pPlayer:GetAimVector():Angle() + 2 * pPlayer:GetViewPunchAngles(), primarymode, spread)
    local ang = ply:EyeAngles() + ply:GetViewPunchAngles()
    --use "special1" for silenced m4 and usp
    self:WeaponSound("single_shot")

    for i = 1, self.Bullets do
        local r = util.SharedRandom("Spread", 0, 2 * math.pi)
        local x = math.sin(r) * util.SharedRandom("SpreadX" .. i, 0, 0.5)
        local y = math.cos(r) * util.SharedRandom("SpreadY" .. i, 0, 1)
        local dir = ang:Forward() + x * spread * ang:Right() + y * spread * ang:Up()
        dir:Normalize()
        self:PenetrateBullet(dir, ply:GetShootPos(), self.Range, self.Penetration, self.Damage, self.RangeModifier) --, self:GetPenetrationFromBullet())
    end

    self:DoFireEffects()
    self:SetNextPrimaryFire(CurTime() + self.CycleTime)
    self:SetNextSecondaryFire(CurTime() + self.CycleTime)

    -- self:SetNextIdle(CurTime() + self.TimeToIdle)
    if self.BurstFire then
        self:SetNextBurstFire(CurTime() + self:GetBurstFireDelay())
    else
        self:SetNextBurstFire(-1)
    end

    if self.KickSimple then
        local a = self:GetOwner():GetViewPunchAngles()
        a.p = a.p - self.KickSimple
        self:GetOwner():SetViewPunchAngles(a)
    elseif self:GetOwner():GetAbsVelocity():Length2DSqr() > 25 or not self:GetOwner():OnGround() then
        self:DoKickBack(unpack(self.KickMoving))
    elseif self:GetOwner():Crouching() then
        self:DoKickBack(unpack(self.KickCrouching))
    else
        self:DoKickBack(unpack(self.KickStanding))
    end

    -- spray affects kickback, so update after
    self:SetLastShotSpray(math.min(self.SprayMax, self:GetSpray() + self.SprayIncrement))
    self:SetLastFire(CurTime())

    return true
end

function SWEP:MovementPenalty(clientsmoothing)
    -- softplus: ln(1+exp x)
    local x = math.Clamp((self:GetOwner():GetAbsVelocity():Length2D() - 10) / 100, 0, 1)

    if clientsmoothing then
        local t = engine.TickInterval()
        self.RunningAverageMovementPenalties = self.RunningAverageMovementPenalties or {}

        table.insert(self.RunningAverageMovementPenalties, {x, CurTime()})

        while self.RunningAverageMovementPenalties[1][2] <= CurTime() - engine.TickInterval() do
            table.remove(self.RunningAverageMovementPenalties, 1)
        end

        local sum = 0

        for i, v in ipairs(self.RunningAverageMovementPenalties) do
            sum = sum + v[1]
        end

        return sum / (#self.RunningAverageMovementPenalties)
    end

    return x
end

function SWEP:GetSpread(clientsmoothing)
    local ply = self:GetOwner()
    if not ply:IsValid() then return end
    local spread
    local movepenalty = self:MovementPenalty(clientsmoothing)

    --added
    if self.WeaponType == "Rifle" or self.WeaponType == "SniperRifle" then
        movepenalty = movepenalty * 2
    end

    --and not self:GetBurstFireEnabled()) then
    if not self:IsScoped() then
        spread = self.Spread + (ply:Crouching() and self.InaccuracyCrouch or self.InaccuracyStand)

        if (ply:GetMoveType() == MOVETYPE_LADDER) then
            spread = spread + self.InaccuracyLadder
        end

        -- if (ply:GetAbsVelocity():Length2D() > 50) then
        spread = spread + self.InaccuracyMove * movepenalty

        -- end
        if (not ply:IsOnGround()) then
            spread = spread + self.InaccuracyJump
        end
    else
        spread = self.SpreadAlt + (ply:Crouching() and self.InaccuracyCrouchAlt or not ply:IsOnGround() and self.InaccuracyJumpAlt or self.InaccuracyStandAlt)

        if (ply:GetMoveType() == MOVETYPE_LADDER) then
            spread = spread + self.InaccuracyLadderAlt
        end

        -- if (ply:GetAbsVelocity():Length2D() > 50) then
        spread = spread + self.InaccuracyMoveAlt * movepenalty

        -- end
        if (not ply:IsOnGround()) then
            spread = spread + self.InaccuracyJumpAlt
        end
    end

    --added
    spread = spread * 1.5
    -- local accuracy = 0.2
    -- -- These modifications feed back into flSpread eventually.
    -- if self.AccuracyDivisor ~= -1 then
    --     local iShotsFired = self:GetShotsFired()
    --     if self.AccuracyQuadratic then
    --         iShotsFired = iShotsFired * iShotsFired
    --     else
    --         iShotsFired = iShotsFired * iShotsFired * iShotsFired
    --     end
    --     accuracy = math.min((iShotsFired / self.AccuracyDivisor) + self.AccuracyOffset, self.MaxInaccuracy)
    -- end
    -- -- print("AC9", accuracy, spread)
    -- if self.GunType == "pistol" or self.GunType == "sniper" then
    --     accuracy = (1 - accuracy)
    -- end
    --(1 - self:GetAccuracy())
    -- print("SPRAY", self:GetSpray(), self.SprayMax)
    local sprayfactor = (self:GetSpray() ^ self.SprayExponent) + self.SprayBase
    -- print("NEW")
    -- sprayfactor = accuracy

    return spread * sprayfactor
end

-- -- OLD
-- function SWEP:BuildSpread()
--     -- local pPlayer = self:GetOwner()
--     -- if not pPlayer:IsValid() then return end
--     -- local spread
--     -- --and not self:GetBurstFireEnabled() and not self:IsSilenced()) then
--     -- if (not self:IsScoped()) then
--     --     spread = self.Spread + (pPlayer:Crouching() and self.InaccuracyCrouch or self.InaccuracyStand)
--     --     if (pPlayer:GetMoveType() == MOVETYPE_LADDER) then
--     --         spread = spread + self.InaccuracyLadder
--     --     end
--     --     if (pPlayer:GetAbsVelocity():Length2D() > 5) then
--     --         spread = spread + self.InaccuracyMove
--     --     end
--     --     if (not pPlayer:IsOnGround()) then
--     --         spread = spread + self.InaccuracyJump
--     --     end
--     -- else
--     --     spread = self.SpreadAlt + (pPlayer:Crouching() and self.InaccuracyCrouchAlt or not pPlayer:IsOnGround() and self.InaccuracyJumpAlt or self.InaccuracyStandAlt)
--     --     if (pPlayer:GetMoveType() == MOVETYPE_LADDER) then
--     --         spread = spread + self.InaccuracyLadderAlt
--     --     end
--     --     if (pPlayer:GetAbsVelocity():Length2D() > 5) then
--     --         spread = spread + self.InaccuracyMoveAlt
--     --     end
--     --     if (not pPlayer:IsOnGround()) then
--     --         spread = spread + self.InaccuracyJumpAlt
--     --     end
--     -- end
--     -- return spread * (1 - self:GetAccuracy())
--     return 0
-- end
-- function SWEP:GetPenetrationFromBullet()
--     local iBulletType = self.Primary.Ammo
--     local fPenetrationPower, flPenetrationDistance
--     if iBulletType == "BULLET_PLAYER_50AE" then
--         fPenetrationPower = 30
--         flPenetrationDistance = 1000.0
--     elseif iBulletType == "BULLET_PLAYER_762MM" then
--         fPenetrationPower = 39
--         flPenetrationDistance = 5000.0
--     elseif iBulletType == "BULLET_PLAYER_556MM" or iBulletType == "BULLET_PLAYER_556MM_BOX" then
--         fPenetrationPower = 35
--         flPenetrationDistance = 4000.0
--     elseif iBulletType == "BULLET_PLAYER_338MAG" then
--         fPenetrationPower = 45
--         flPenetrationDistance = 8000.0
--     elseif iBulletType == "BULLET_PLAYER_9MM" then
--         fPenetrationPower = 21
--         flPenetrationDistance = 800.0
--     elseif iBulletType == "BULLET_PLAYER_BUCKSHOT" then
--         fPenetrationPower = 0
--         flPenetrationDistance = 0.0
--     elseif iBulletType == "BULLET_PLAYER_45ACP" then
--         fPenetrationPower = 15
--         flPenetrationDistance = 500.0
--     elseif iBulletType == "BULLET_PLAYER_357SIG" then
--         fPenetrationPower = 25
--         flPenetrationDistance = 800.0
--     elseif iBulletType == "BULLET_PLAYER_57MM" then
--         fPenetrationPower = 30
--         flPenetrationDistance = 2000.0
--     else
--         assert(false)
--         fPenetrationPower = 0
--         flPenetrationDistance = 0.0
--     end
--     return fPenetrationPower, flPenetrationDistance
-- end
-- function SWEP:TraceToExit(start, dir, endpos, stepsize, maxdistance)
--     local flDistance = 0
--     local last = start
--     while (flDistance < maxdistance) do
--         flDistance = flDistance + stepsize
--         endpos:Set(start + flDistance * dir)
--         if bit.band(util.PointContents(endpos), MASK_SOLID) == 0 then return true, endpos end
--     end
--     return false
-- end
-- -- TODO: Make this not do this????
-- local PenetrationValues = {}
-- local function set(values, ...)
--     for i = 1, select("#", ...) do
--         PenetrationValues[select(i, ...)] = values
--     end
-- end
-- -- flPenetrationModifier, flDamageModifier
-- -- flDamageModifier should always be less than flPenetrationModifier
-- set({0.3, 0.1}, MAT_CONCRETE, MAT_METAL)
-- set({0.8, 0.7}, MAT_FOLIAGE, MAT_SAND, MAT_GRASS, MAT_DIRT, MAT_FLESH, MAT_GLASS, MAT_COMPUTER, MAT_TILE, MAT_WOOD, MAT_PLASTIC, MAT_SLOSH, MAT_SNOW)
-- set({0.5, 0.45}, MAT_FLESH, MAT_ALIENFLESH, MAT_ANTLION, MAT_BLOODYFLESH, MAT_SLOSH, MAT_CLIP)
-- set({1, 0.99}, MAT_GRATE)
-- set({0.5, 0.45}, MAT_DEFAULT)
-- function SWEP:ImpactTrace(tr)
--     local e = EffectData()
--     e:SetOrigin(tr.HitPos)
--     e:SetStart(tr.StartPos)
--     e:SetSurfaceProp(tr.SurfaceProps)
--     e:SetDamageType(DMG_BULLET)
--     e:SetHitBox(0)
--     if CLIENT then
--         e:SetEntity(game.GetWorld())
--     else
--         e:SetEntIndex(0)
--     end
--     util.Effect("Impact", e)
-- end
function SWEP:PenetrateBullet(dir, vecStart, flDistance, iPenetration, iDamage, flRangeModifier, fPenetrationPower, flPenetrationDistance, flCurrentDistance)
    flCurrentDistance = flCurrentDistance or 0

    self:GetOwner():FireBullets{
        AmmoType = self.Primary.Ammo,
        Distance = flDistance,
        Tracer = 1,
        Damage = iDamage,
        Src = vecStart,
        Dir = dir,
        Spread = vector_origin,
        Callback = function(hitent, trace, dmginfo)
            dmginfo:SetInflictor(self)

            --TODO: penetration
            --unfortunately this can't be done with a static function or we'd need to set global variables for range and shit
            if flRangeModifier then
                --Jvs: the damage modifier valve actually uses
                local flCurrentDistance = trace.Fraction * flDistance
                dmginfo:SetDamage(dmginfo:GetDamage() * math.pow(flRangeModifier, (flCurrentDistance / 500)))
            end

            if trace.HitGroup == HITGROUP_HEAD then
                dmginfo:ScaleDamage(self.HeadshotMultiplier or 1)
            end
        end
    }
    -- if (trace.Fraction == 1) then return end
    -- -- TODO: convert this to physprops? there doesn't seem to be a way to get penetration from those
    -- local flPenetrationModifier, flDamageModifier = unpack(PenetrationValues[trace.MatType] or PenetrationValues[MAT_DEFAULT])
    -- flCurrentDistance = flCurrentDistance + trace.Fraction * (trace.HitPos - vecStart):Length()
    -- iDamage = iDamage * flRangeModifier ^ (flCurrentDistance / 500)
    -- if (flCurrentDistance > flPenetrationDistance and iPenetration > 0) then
    --     iPenetration = 0
    -- end
    -- if iPenetration == 0 and not trace.MatType == MAT_GRATE then return end
    -- if iPenetration < 0 then return end
    -- local penetrationEnd = Vector()
    -- if not self:TraceToExit(trace.HitPos, dir, penetrationEnd, 24, 128) then return end
    -- local hitent_already = false
    -- local tr = util.TraceLine{
    --     start = penetrationEnd,
    --     endpos = trace.HitPos,
    --     mask = MASK_SHOT,
    --     filter = function(e)
    --         local ret = e:IsPlayer()
    --         if (ret and not hitent_already) then
    --             hitent_already = true
    --             return false
    --         end
    --         return true
    --     end
    -- }
    -- bHitGrate = tr.MatType == MAT_GRATE and bHitGrate
    -- local iExitMaterial = tr.MatType
    -- if (iExitMaterial == trace.MatType) then
    --     if (iExitMaterial == MAT_WOOD or iExitMaterial == MAT_METAL) then
    --         flPenetrationModifier = flPenetrationModifier * 2
    --     end
    -- end
    -- local flTraceDistance = tr.HitPos:Distance(trace.HitPos)
    -- if (flTraceDistance > (fPenetrationPower * flPenetrationModifier)) then return end
    -- self:ImpactTrace(tr)
    -- fPenetrationPower = fPenetrationPower - flTraceDistance / flPenetrationModifier
    -- flCurrentDistance = flCurrentDistance + flTraceDistance
    -- vecStart = tr.HitPos
    -- flDistance = (flDistance - flCurrentDistance) * .5
    -- iDamage = iDamage * flDamageModifier
    -- iPenetration = iPenetration - 1
    -- Disabled lmao
    -- self:PenetrateBullet(dir, vecStart, flDistance, iPenetration, iDamage, flRangeModifier, fPenetrationPower, flPenetrationDistance, flCurrentDistance)
end

function SWEP:GetSpeedRatio()
    if (self:IsScoped()) then return self.ScopedSpeedRatio or 0.5 end

    return 1
end
