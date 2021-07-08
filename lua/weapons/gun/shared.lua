-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = true
SWEP.CSSWeapon = true

SWEP.WeaponTypeToString = {
    Knife = CS_WEAPONTYPE_KNIFE,
    Pistol = CS_WEAPONTYPE_PISTOL,
    Rifle = CS_WEAPONTYPE_RIFLE,
    Shotgun = CS_WEAPONTYPE_SHOTGUN,
    SniperRifle = CS_WEAPONTYPE_SNIPER_RIFLE,
    SubMachinegun = CS_WEAPONTYPE_SUBMACHINEGUN,
    Machinegun = CS_WEAPONTYPE_MACHINEGUN,
    C4 = CS_WEAPONTYPE_C4,
    Grenade = CS_WEAPONTYPE_GRENADE,
}

--[[
	returns the raw data parsed from the vdf in table form,
	some of this data is already applied to the weapon table ( such as .Slot, .PrintName and etc )
]]
function SWEP:GetWeaponInfo()
    return self._WeaponInfo
end

function SWEP:Reload()
    if self:GetMaxClip1() ~= -1 and not self:InReload() and self:GetNextPrimaryAttack() < CurTime() then
        self:SetShotsFired(0)
        local bCanReload = self:MainReload(self:TranslateViewModelActivity(ACT_VM_RELOAD))

        if (bCanReload) then
            self:HandleReload()
        end

        return bCanReload
    end
end

function SWEP:HandleReload()
end

--Jvs: can't call it DefaultReload because there's already one in the weapon's metatable and I'd rather not cause conflicts
function SWEP:MainReload(act)
    local pOwner = self:GetOwner()
    -- If I don't have any spare ammo, I can't reload
    if pOwner:GetAmmoCount(self:GetPrimaryAmmoType()) <= 0 then return false end
    local bReload = false

    -- If you don't have clips, then don't try to reload them.
    if self:GetMaxClip1() ~= -1 then
        -- need to reload primary clip?
        local primary = math.min(self:GetMaxClip1() - self:Clip1(), pOwner:GetAmmoCount(self:GetPrimaryAmmoType()))

        if primary ~= 0 then
            bReload = true
        end
    end

    if self:GetMaxClip2() ~= -1 then
        -- need to reload secondary clip?
        local secondary = math.min(self:GetMaxClip2() - self:Clip2(), pOwner:GetAmmoCount(self:GetSecondaryAmmoType()))

        if secondary ~= 0 then
            bReload = true
        end
    end

    if not bReload then return false end
    self:WeaponSound("reload")
    self:SendWeaponAnim(act)

    -- Play the player's reload animation
    if pOwner:IsPlayer() then
        pOwner:DoReloadEvent()
    end

    local flSequenceEndTime = CurTime() + self:SequenceDuration()
    self:SetNextPrimaryAttack(flSequenceEndTime)
    self:SetNextSecondaryAttack(flSequenceEndTime)
    self:SetInReload(true)

    return true
end

function SWEP:GetMaxClip1()
    return self.Primary.ClipSize
end

function SWEP:GetMaxClip2()
    return self.Secondary.ClipSize
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Holster()
    self:SetInReload(false)

    return true
end

function SWEP:InReload()
    return self:GetInReload()
end

function SWEP:IsPistol()
    return self:GetWeaponType() == CS_WEAPONTYPE_PISTOL
end

function SWEP:IsSilenced()
    return self:GetHasSilencer()
end

function SWEP:WeaponSound(soundtype)
    if not self:GetWeaponInfo() then return end
    local sndname = self:GetWeaponInfo().SoundData[soundtype]

    if sndname then
        self:EmitSound(sndname, nil, nil, nil, CHAN_AUTO)
    end
end

function SWEP:PlayEmptySound()
    if self:IsPistol() then
        self:EmitSound("Default.ClipEmpty_Pistol", nil, nil, nil, CHAN_AUTO) --an actual undocumented feature!
    else
        self:EmitSound("Default.ClipEmpty_Rifle", nil, nil, nil, CHAN_AUTO)
    end
end

function SWEP:KickBack(up_base, lateral_base, up_modifier, lateral_modifier, up_max, lateral_max, direction_change)
    if not self:GetOwner():IsPlayer() then return end
    local flKickUp
    local flKickLateral

    --[[
		Jvs:
			I implemented the shots fired and direction stuff on the cs base because it would've been dumb to do it
			on the player, since it's reset on a gun basis anyway
	]]
    -- This is the first round fired
    if self:GetShotsFired() == 1 then
        flKickUp = up_base
        flKickLateral = lateral_base
    else
        flKickUp = up_base + self:GetShotsFired() * up_modifier
        flKickLateral = lateral_base + self:GetShotsFired() * lateral_modifier
    end

    local angle = self:GetOwner():GetViewPunchAngles()
    angle.x = angle.x - flKickUp

    if angle.x < -1 * up_max then
        angle.x = -1 * up_max
    end

    if self:GetDirection() == 1 then
        angle.y = angle.y + flKickLateral

        if angle.y > lateral_max then
            angle.y = lateral_max
        end
    else
        angle.y = angle.y - flKickLateral

        if angle.y < -1 * lateral_max then
            angle.y = -1 * lateral_max
        end
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

--[[
	Jvs:
		this function is here to make the player faster or slower depending on the weapon equipped ( and mode of the weapon )
		in CS:S the value here is actually a flat movement speed, but here we still want to replicate the movement speed of when you're zoomed in / use a knife
		and forcing flat movement speeds in other gamemodes is dumb as hell
]]
function SWEP:GetSpeedRatio()
    --Jvs: rare case where the speed might still be undefined
    if self:GetWeaponInfo().MaxPlayerSpeed == 1 then return 1 end

    return self:GetWeaponInfo().MaxPlayerSpeed / 250
end

--BASE ABOVE, BASEGUN BELOW
local function FloatEquals(x, y)
    return math.abs(x - y) < 1.19209290E-07
end

SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = true
SWEP.DropOnGround = true

function SWEP:Initialize()
    self:SetHoldType("normal")
    self:SetDelayFire(true)
    self:SetFullReload(true)
    self:SetWeaponType(self.WeaponTypeToString[self:GetWeaponInfo().WeaponType])
    self:SetLastFire(CurTime())
end

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "NextPrimaryAttack")
    self:NetworkVar("Float", 1, "NextSecondaryAttack")
    self:NetworkVar("Float", 2, "Accuracy")
    self:NetworkVar("Float", 3, "NextIdle")
    self:NetworkVar("Float", 4, "NextDecreaseShotsFired")
    self:NetworkVar("Int", 0, "WeaponType")
    self:NetworkVar("Int", 1, "ShotsFired")
    self:NetworkVar("Int", 2, "Direction")
    self:NetworkVar("Int", 3, "WeaponID")
    self:NetworkVar("Bool", 0, "InReload")
    self:NetworkVar("Bool", 1, "HasSilencer")
    self:NetworkVar("Bool", 2, "DelayFire")
    self:NetworkVar("Bool", 3, "FullReload")
    --Jvs: stuff that is scattered around all the weapons code that I'm going to try and unify here
    self:NetworkVar("Float", 5, "ZoomFullyActiveTime")
    self:NetworkVar("Float", 6, "ZoomLevel")
    self:NetworkVar("Float", 7, "NextBurstFire") --when the next burstfire is gonna happen, same as nextprimaryattack
    self:NetworkVar("Float", 8, "DoneSwitchingSilencer")
    self:NetworkVar("Float", 9, "BurstFireDelay") --the speed of the burst fire itself, 0.5 means two shots every second etc
    self:NetworkVar("Float", 10, "LastFire")
    self:NetworkVar("Float", 11, "TargetFOVRatio")
    self:NetworkVar("Float", 12, "TargetFOVStartTime")
    self:NetworkVar("Float", 13, "TargetFOVTime")
    self:NetworkVar("Float", 14, "CurrentFOVRatio")
    self:NetworkVar("Float", 15, "StoredFOVRatio")
    self:NetworkVar("Float", 16, "LastZoom")
    self:NetworkVar("Bool", 4, "BurstFireEnabled")
    self:NetworkVar("Bool", 5, "ResumeZoom")
    self:NetworkVar("Int", 4, "BurstFires") --goes from X to 0, how many burst fires we're going to do
    self:NetworkVar("Int", 5, "MaxBurstFires")
end

function SWEP:SetHoldType(ht)
    self.keepht = ht

    return BaseClass.SetHoldType(self, ht)
end

function SWEP:Deploy()
    self:SetDelayFire(false)
    self:SetZoomFullyActiveTime(-1)
    self:SetAccuracy(0.2)
    self:SetBurstFireEnabled(false)
    self:SetBurstFires(self:GetMaxBurstFires())
    self:SetCurrentFOVRatio(1)
    self:SetTargetFOVRatio(1)
    self:SetStoredFOVRatio(1)
    self:SetTargetFOVStartTime(0)
    self:SetTargetFOVTime(0)
    self:SetResumeZoom(false)

    if self.keepht then
        self:SetHoldType(self.keepht)
    end

    self:SetNextDecreaseShotsFired(CurTime())
    self:SetShotsFired(0)
    self:SetInReload(false)
    self:SendWeaponAnim(self:TranslateViewModelActivity(ACT_VM_DRAW))
    self:SetNextPrimaryAttack(CurTime() + self:SequenceDuration())
    self:SetNextSecondaryAttack(CurTime() + self:SequenceDuration())

    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        self:GetOwner():SetFOV(0, 0)
    end

    return true
end

--Jvs : this function handles the zoom smoothing and decay
function SWEP:HandleZoom()
    --GOOSEMAN : Return zoom level back to previous zoom level before we fired a shot. This is used only for the AWP.
    -- And Scout.
    local pPlayer = self:GetOwner()
    if not pPlayer:IsValid() then return end

    if ((self:GetNextPrimaryAttack() <= CurTime()) and self:GetResumeZoom()) then
        if (self:GetFOVRatio() == self:GetLastZoom()) then
            -- return the fade level in zoom.
            self:SetResumeZoom(false)

            return
        end

        self:SetFOVRatio(self:GetLastZoom(), 0.05)
        self:SetNextPrimaryAttack(CurTime() + 0.05)
        self:SetZoomFullyActiveTime(CurTime() + 0.05) -- Make sure we think that we are zooming on the server so we don't get instant acc bonus
    end
end

function SWEP:FOVThink()
    local fovratio
    local deltaTime = (CurTime() - self:GetTargetFOVStartTime()) / self:GetTargetFOVTime()

    if (deltaTime > 1 or self:GetTargetFOVTime() == 0) then
        fovratio = self:GetTargetFOVRatio()
    else
        fovratio = Lerp(math.Clamp(deltaTime, 0, 1), self:GetStoredFOVRatio(), self:GetTargetFOVRatio())
    end

    self:SetCurrentFOVRatio(fovratio)
end

function SWEP:SetFOVRatio(fov, time)
    if (self:GetFOVRatio() ~= self:GetStoredFOVRatio()) then
        self:SetStoredFOVRatio(self:GetFOVRatio())
    end

    self:SetTargetFOVRatio(fov == 0 and 1 or fov)
    self:SetTargetFOVTime(time)
    self:SetTargetFOVStartTime(CurTime())
end

function SWEP:GetFOVRatio()
    return self:GetCurrentFOVRatio()
end

function SWEP:TranslateFOV(fov)
    return fov * self:GetFOVRatio()
end

function SWEP:Think()
    self:FOVThink()
    self:UpdateWorldModel()
    self:HandleZoom()
    local pPlayer = self:GetOwner()
    if not IsValid(pPlayer) then return end

    --[[
		Jvs:
			this is where the reload actually ends, this might be moved into its own function so other coders
			can add other behaviours ( such as cs:go finishing the reload with a different delay, based on when the
			magazine actually gets inserted )
	]]
    if self:InReload() and self:GetNextPrimaryAttack() <= CurTime() then
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

    if not plycmd:KeyDown(IN_ATTACK) and not plycmd:KeyDown(IN_ATTACK2) then
        -- no fire buttons down
        -- The following code prevents the player from tapping the firebutton repeatedly
        -- to simulate full auto and retaining the single shot accuracy of single fire
        if self:GetDelayFire() then
            self:SetDelayFire(false)

            if self:GetShotsFired() > 15 then
                self:SetShotsFired(15)
            end

            self:SetNextDecreaseShotsFired(CurTime() + 0.4)
        end

        -- if it's a pistol then set the shots fired to 0 after the player releases a button
        if self:IsPistol() then
            self:SetShotsFired(0)
        else
            if self:GetShotsFired() > 0 and self:GetNextDecreaseShotsFired() < CurTime() then
                self:SetNextDecreaseShotsFired(CurTime() + 0.0225)
                self:SetShotsFired(self:GetShotsFired() - 1)
            end
        end

        self:Idle()
    end

    if not self:InReload() and self:GetBurstFireEnabled() and self:GetNextBurstFire() < CurTime() and self:GetNextBurstFire() ~= -1 then
        if self:GetBurstFires() < (self:GetMaxBurstFires() - 1) then
            if self:Clip1() <= 0 then
                self:SetBurstFires(self:GetMaxBurstFires())
            else
                self:SetNextPrimaryAttack(CurTime() - 1)
                self:PrimaryAttack()
                self:SetNextPrimaryAttack(CurTime() + 0.5) --this artificial delay is inherited from the glock code
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
    if not self:IsSilenced() then
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
        data:SetScale(self:GetWeaponInfo().MuzzleFlashScale)

        if self.CSMuzzleX then
            util.Effect("CS_MuzzleFlash_X", data)
        else
            util.Effect("CS_MuzzleFlash", data)
        end
    end
end

function SWEP:Idle()
    if CurTime() <= self:GetNextIdle() then return end
    if self:GetNextPrimaryAttack() > CurTime() or self:GetNextSecondaryAttack() > CurTime() then return end

    if self:Clip1() ~= 0 then
        self:SetNextIdle(CurTime() + self:GetWeaponInfo().IdleInterval)
        self:SendWeaponAnim(self:TranslateViewModelActivity(ACT_VM_IDLE))
    end
end

function SWEP:TranslateViewModelActivity(act)
    return act
end

function SWEP:IsScoped()
    --Jvs TODO: do something better than the shitty hacks valve does
    return false
end

function SWEP:BaseGunFire(spread, cycletime, primarymode)
    -- ADDED
    if self._WeaponInfo.WeaponType == "SubMachinegun" then
        cycletime = cycletime * 5 / 6
    end

    local pPlayer = self:GetOwner()
    if not pPlayer:IsValid() then return false end -- this happens with certain addons
    local pCSInfo = self:GetWeaponInfo()
    self:SetDelayFire(true)
    self:SetShotsFired(self:GetShotsFired() + 1)

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
        self:PlayEmptySound()
        self:SetNextPrimaryAttack(CurTime() + 0.2)

        return false
    end

    self:SendWeaponAnim(self:TranslateViewModelActivity(ACT_VM_PRIMARYATTACK))
    self:SetClip1(self:Clip1() - 1)

    if SERVER and (self.Owner.GetLocationName and self.Owner:GetLocationName() == "Weapons Testing Range") then
        self.Owner:GiveAmmo(1, self:GetPrimaryAmmoType())
    end

    -- player "shoot" animation
    pPlayer:DoAttackEvent()
    spread = self:MyBuildSpread()
    -- self:FireCSSBullet(pPlayer:GetAimVector():Angle() + 2 * pPlayer:GetViewPunchAngles(), primarymode, spread)
    self:FireCSSBullet(pPlayer:EyeAngles() + pPlayer:GetViewPunchAngles(), primarymode, spread)
    self:DoFireEffects()
    self:SetNextPrimaryAttack(CurTime() + cycletime)
    self:SetNextSecondaryAttack(CurTime() + cycletime)
    self:SetNextIdle(CurTime() + pCSInfo.TimeToIdle)

    if self:GetBurstFireEnabled() then
        self:SetNextBurstFire(CurTime() + self:GetBurstFireDelay())
    else
        self:SetNextBurstFire(-1)
    end

    self:SetLastFire(CurTime())

    return true
end

function SWEP:ToggleBurstFire()
    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        if self:GetBurstFireEnabled() then
            self:GetOwner():PrintMessage(HUD_PRINTCENTER, tobool(tonumber(self:GetWeaponInfo().FullAuto)) and "#Cstrike_TitlesTXT_Switch_To_FullAuto" or "#Cstrike_TitlesTXT_Switch_To_SemiAuto")
        else
            self:GetOwner():PrintMessage(HUD_PRINTCENTER, "#Cstrike_TitlesTXT_Switch_To_BurstFire")
        end
    end

    self:SetBurstFireEnabled(not self:GetBurstFireEnabled())
end

function SWEP:FireCSSBullet(ang, primarymode, spread)
    local ply = self:GetOwner()
    local pCSInfo = self:GetWeaponInfo()
    local iDamage = pCSInfo.Damage
    local flRangeModifier = pCSInfo.RangeModifier
    local soundType = "single_shot"

    --Valve's horrible hacky balance
    --Jvs: TODO , implement this either in the parser or directly on the weapon itself
    if self:GetClass() == "gun_glock" then
        if not primarymode then
            iDamage = 18 -- reduced power for burst shots
            flRangeModifier = 0.9
        end
    elseif self:GetClass() == "gun_m4a1" then
        if not primarymode then
            flRangeModifier = 0.95 -- slower bullets in silenced mode
            soundType = "special1"
        end
    elseif self:GetClass() == "gun_usp" then
        if not primarymode then
            iDamage = 30 -- reduced damage in silenced mode
            soundType = "special1"
        end
    end

    self:WeaponSound(soundType)

    for iBullet = 1, pCSInfo.Bullets do
        local r = util.SharedRandom("Spread", 0, 2 * math.pi)
        local x = math.sin(r) * util.SharedRandom("SpreadX" .. iBullet, 0, 0.5)
        local y = math.cos(r) * util.SharedRandom("SpreadY" .. iBullet, 0, 1)
        local dir = ang:Forward() + x * spread * ang:Right() + y * spread * ang:Up()
        dir:Normalize()
        local flDistance = self:GetWeaponInfo().Range
        local iPenetration = self:GetWeaponInfo().Penetration
        local flRangeModifier = self:GetWeaponInfo().RangeModifier
        self:PenetrateBullet(dir, ply:GetShootPos(), flDistance, iPenetration, iDamage, flRangeModifier, self:GetPenetrationFromBullet())
    end
end

function SWEP:MyBuildSpread()
    local pCSInfo = self:GetWeaponInfo()
    local pPlayer = self:GetOwner()
    if not pPlayer:IsValid() then return end
    local spread
    local movepenalty = math.Clamp((pPlayer:GetAbsVelocity():Length2D() - 10) / 100, 0, 1)

    --added
    if pCSInfo.WeaponType == "Rifle" or pCSInfo.WeaponType == "SniperRifle" then
        movepenalty = movepenalty * 2
    end

    if (not self:IsScoped() and not self:GetBurstFireEnabled() and not self:IsSilenced()) then
        spread = pCSInfo.Spread + (pPlayer:Crouching() and pCSInfo.InaccuracyCrouch or pCSInfo.InaccuracyStand)

        if (pPlayer:GetMoveType() == MOVETYPE_LADDER) then
            spread = spread + pCSInfo.InaccuracyLadder
        end

        -- if (pPlayer:GetAbsVelocity():Length2D() > 50) then
        spread = spread + pCSInfo.InaccuracyMove * movepenalty

        -- end
        if (pPlayer:IsOnFire()) then
            spread = spread + pCSInfo.InaccuracyFire
        end

        if (not pPlayer:IsOnGround()) then
            spread = spread + pCSInfo.InaccuracyJump
        end
    else
        spread = pCSInfo.SpreadAlt + (pPlayer:Crouching() and pCSInfo.InaccuracyCrouchAlt or not pPlayer:IsOnGround() and pCSInfo.InaccuracyJumpAlt or pCSInfo.InaccuracyStandAlt)

        if (pPlayer:GetMoveType() == MOVETYPE_LADDER) then
            spread = spread + pCSInfo.InaccuracyLadderAlt
        end

        -- if (pPlayer:GetAbsVelocity():Length2D() > 50) then
        spread = spread + pCSInfo.InaccuracyMoveAlt * movepenalty

        -- end
        if (pPlayer:IsOnFire()) then
            spread = spread + pCSInfo.InaccuracyFireAlt
        end

        if (not pPlayer:IsOnGround()) then
            spread = spread + pCSInfo.InaccuracyJumpAlt
        end
    end

    --added
    spread = spread * 1.5
    local accuracy = 0.2
    local pCSInfo = self:GetWeaponInfo()

    -- These modifications feed back into flSpread eventually.
    if pCSInfo.AccuracyDivisor ~= -1 then
        local iShotsFired = self:GetShotsFired()

        if pCSInfo.AccuracyQuadratic then
            iShotsFired = iShotsFired * iShotsFired
        else
            iShotsFired = iShotsFired * iShotsFired * iShotsFired
        end

        accuracy = math.min((iShotsFired / pCSInfo.AccuracyDivisor) + pCSInfo.AccuracyOffset, pCSInfo.MaxInaccuracy)
    end

    -- print("AC9", accuracy, spread)
    if self.GunType == "pistol" or self.GunType == "sniper" then
        accuracy = (1 - accuracy)
    end
    --(1 - self:GetAccuracy())

    return spread * accuracy
end

function SWEP:BuildSpread()
    local pCSInfo = self:GetWeaponInfo()
    local pPlayer = self:GetOwner()
    if not pPlayer:IsValid() then return end
    local spread

    if (not self:IsScoped() and not self:GetBurstFireEnabled() and not self:IsSilenced()) then
        spread = pCSInfo.Spread + (pPlayer:Crouching() and pCSInfo.InaccuracyCrouch or pCSInfo.InaccuracyStand)

        if (pPlayer:GetMoveType() == MOVETYPE_LADDER) then
            spread = spread + pCSInfo.InaccuracyLadder
        end

        if (pPlayer:GetAbsVelocity():Length2D() > 5) then
            spread = spread + pCSInfo.InaccuracyMove
        end

        if (pPlayer:IsOnFire()) then
            spread = spread + pCSInfo.InaccuracyFire
        end

        if (not pPlayer:IsOnGround()) then
            spread = spread + pCSInfo.InaccuracyJump
        end
    else
        spread = pCSInfo.SpreadAlt + (pPlayer:Crouching() and pCSInfo.InaccuracyCrouchAlt or not pPlayer:IsOnGround() and pCSInfo.InaccuracyJumpAlt or pCSInfo.InaccuracyStandAlt)

        if (pPlayer:GetMoveType() == MOVETYPE_LADDER) then
            spread = spread + pCSInfo.InaccuracyLadderAlt
        end

        if (pPlayer:GetAbsVelocity():Length2D() > 5) then
            spread = spread + pCSInfo.InaccuracyMoveAlt
        end

        if (pPlayer:IsOnFire()) then
            spread = spread + pCSInfo.InaccuracyFireAlt
        end

        if (not pPlayer:IsOnGround()) then
            spread = spread + pCSInfo.InaccuracyJumpAlt
        end
    end

    return spread * (1 - self:GetAccuracy())
end

function SWEP:GetPenetrationFromBullet()
    local iBulletType = self.Primary.Ammo
    local fPenetrationPower, flPenetrationDistance

    if iBulletType == "BULLET_PLAYER_50AE" then
        fPenetrationPower = 30
        flPenetrationDistance = 1000.0
    elseif iBulletType == "BULLET_PLAYER_762MM" then
        fPenetrationPower = 39
        flPenetrationDistance = 5000.0
    elseif iBulletType == "BULLET_PLAYER_556MM" or iBulletType == "BULLET_PLAYER_556MM_BOX" then
        fPenetrationPower = 35
        flPenetrationDistance = 4000.0
    elseif iBulletType == "BULLET_PLAYER_338MAG" then
        fPenetrationPower = 45
        flPenetrationDistance = 8000.0
    elseif iBulletType == "BULLET_PLAYER_9MM" then
        fPenetrationPower = 21
        flPenetrationDistance = 800.0
    elseif iBulletType == "BULLET_PLAYER_BUCKSHOT" then
        fPenetrationPower = 0
        flPenetrationDistance = 0.0
    elseif iBulletType == "BULLET_PLAYER_45ACP" then
        fPenetrationPower = 15
        flPenetrationDistance = 500.0
    elseif iBulletType == "BULLET_PLAYER_357SIG" then
        fPenetrationPower = 25
        flPenetrationDistance = 800.0
    elseif iBulletType == "BULLET_PLAYER_57MM" then
        fPenetrationPower = 30
        flPenetrationDistance = 2000.0
    else
        assert(false)
        fPenetrationPower = 0
        flPenetrationDistance = 0.0
    end

    return fPenetrationPower, flPenetrationDistance
end

function SWEP:TraceToExit(start, dir, endpos, stepsize, maxdistance)
    local flDistance = 0
    local last = start

    while (flDistance < maxdistance) do
        flDistance = flDistance + stepsize
        endpos:Set(start + flDistance * dir)
        if bit.band(util.PointContents(endpos), MASK_SOLID) == 0 then return true, endpos end
    end

    return false
end

-- TODO: Make this not do this????
local PenetrationValues = {}

local function set(values, ...)
    for i = 1, select("#", ...) do
        PenetrationValues[select(i, ...)] = values
    end
end

-- flPenetrationModifier, flDamageModifier
-- flDamageModifier should always be less than flPenetrationModifier
set({0.3, 0.1}, MAT_CONCRETE, MAT_METAL)

set({0.8, 0.7}, MAT_FOLIAGE, MAT_SAND, MAT_GRASS, MAT_DIRT, MAT_FLESH, MAT_GLASS, MAT_COMPUTER, MAT_TILE, MAT_WOOD, MAT_PLASTIC, MAT_SLOSH, MAT_SNOW)

set({0.5, 0.45}, MAT_FLESH, MAT_ALIENFLESH, MAT_ANTLION, MAT_BLOODYFLESH, MAT_SLOSH, MAT_CLIP)

set({1, 0.99}, MAT_GRATE)

set({0.5, 0.45}, MAT_DEFAULT)

function SWEP:ImpactTrace(tr)
    local e = EffectData()
    e:SetOrigin(tr.HitPos)
    e:SetStart(tr.StartPos)
    e:SetSurfaceProp(tr.SurfaceProps)
    e:SetDamageType(DMG_BULLET)
    e:SetHitBox(0)

    if CLIENT then
        e:SetEntity(game.GetWorld())
    else
        e:SetEntIndex(0)
    end

    util.Effect("Impact", e)
end

function SWEP:PenetrateBullet(dir, vecStart, flDistance, iPenetration, iDamage, flRangeModifier, fPenetrationPower, flPenetrationDistance, flCurrentDistance)
    flCurrentDistance = flCurrentDistance or 0

    self:GetOwner():FireBullets{
        AmmoType = self.Primary.Ammo,
        Distance = flDistance,
        Tracer = 1,
        Attacker = self:GetOwner(),
        Damage = iDamage,
        Src = vecStart,
        Dir = dir,
        Spread = vector_origin,
        Callback = function(hitent, trace, dmginfo)
            --TODO: penetration
            --unfortunately this can't be done with a static function or we'd need to set global variables for range and shit
            if flRangeModifier then
                --Jvs: the damage modifier valve actually uses
                local flCurrentDistance = trace.Fraction * flDistance
                dmginfo:SetDamage(dmginfo:GetDamage() * math.pow(flRangeModifier, (flCurrentDistance / 500)))
            end

            --extra
            if trace.HitGroup == HITGROUP_HEAD then
                dmginfo:ScaleDamage(1.2)
            else
                dmginfo:ScaleDamage(0.8)
            end

            if self:GetClass() == "gun_awp" then
                dmginfo:ScaleDamage(2)
            end

            if (trace.Fraction == 1) then return end
            -- TODO: convert this to physprops? there doesn't seem to be a way to get penetration from those
            local flPenetrationModifier, flDamageModifier = unpack(PenetrationValues[trace.MatType] or PenetrationValues[MAT_DEFAULT])
            flCurrentDistance = flCurrentDistance + trace.Fraction * (trace.HitPos - vecStart):Length()
            iDamage = iDamage * flRangeModifier ^ (flCurrentDistance / 500)

            if (flCurrentDistance > flPenetrationDistance and iPenetration > 0) then
                iPenetration = 0
            end

            if iPenetration == 0 and not trace.MatType == MAT_GRATE then return end
            if iPenetration < 0 then return end
            local penetrationEnd = Vector()
            if not self:TraceToExit(trace.HitPos, dir, penetrationEnd, 24, 128) then return end
            local hitent_already = false

            local tr = util.TraceLine{
                start = penetrationEnd,
                endpos = trace.HitPos,
                mask = MASK_SHOT,
                filter = function(e)
                    local ret = e:IsPlayer()

                    if (ret and not hitent_already) then
                        hitent_already = true

                        return false
                    end

                    return true
                end
            }

            bHitGrate = tr.MatType == MAT_GRATE and bHitGrate
            local iExitMaterial = tr.MatType

            if (iExitMaterial == trace.MatType) then
                if (iExitMaterial == MAT_WOOD or iExitMaterial == MAT_METAL) then
                    flPenetrationModifier = flPenetrationModifier * 2
                end
            end

            local flTraceDistance = tr.HitPos:Distance(trace.HitPos)
            if (flTraceDistance > (fPenetrationPower * flPenetrationModifier)) then return end
            self:ImpactTrace(tr)
            fPenetrationPower = fPenetrationPower - flTraceDistance / flPenetrationModifier
            flCurrentDistance = flCurrentDistance + flTraceDistance
            vecStart = tr.HitPos
            flDistance = (flDistance - flCurrentDistance) * .5
            iDamage = iDamage * flDamageModifier
            iPenetration = iPenetration - 1
        end
    }
    -- Disabled lmao
    -- self:PenetrateBullet(dir, vecStart, flDistance, iPenetration, iDamage, flRangeModifier, fPenetrationPower, flPenetrationDistance, flCurrentDistance)
end

function SWEP:UpdateWorldModel()
end
