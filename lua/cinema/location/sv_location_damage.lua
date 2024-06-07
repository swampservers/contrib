local function IsPlayerDrowning(ply)
    if IsValid(ply.hamsterball) then return ply.hamsterball:WaterLevel() > 0 end

    return ply:WaterLevel() > 0
end

local findfloorvec = Vector(0, 0, -1)

local function GetPlayerGroundSurfaceProp(ply)
    if not ply:IsOnGround() then return false end
    local startpos = ply:GetPos()

    -- TODO(code_gs): Maybe could use GetTouchTrace here
    local tr = {
        start = startpos,
        endpos = startpos + findfloorvec,
        filter = ply,
        mask = MASK_PLAYERSOILD,
        collisiongroup = ply:GetCollisionGroup()
    }

    tr.output = tr
    util.TraceEntity(tr, ply)

    return util.GetSurfacePropName(tr.SurfaceProps)
end

local function IsPlayerOnSlime(ply)
    return GetPlayerGroundSurfaceProp(ply) == "slime"
end

local function IsPlayerOnElectrifiedSurface(ply)
    local surfaceprop = GetPlayerGroundSurfaceProp(ply)

    return surfaceprop == "chainlink" or surfaceprop == "metal"
end

local function ApplyLavaDamage(ply)
    ply:Ignite(0.5, 0) -- Does 1 damage/hit
    local world = game.GetWorld()
    local dissolve = ply:Health() <= 10 -- Player will die with this next hit
    local dmginfo = DamageInfo()
    dmginfo:SetDamagePosition(ply:GetPos())
    dmginfo:SetDamageForce(vector_origin)
    dmginfo:SetInflictor(world)
    dmginfo:SetAttacker(world)
    dmginfo:SetDamageType(dissolve and DMG_DISSOLVE or DMG_BURN)
    dmginfo:SetDamage(10)
    ply:TakeDamageInfo(dmginfo)

    if dissolve then
        ply:EmitSound("NPC_CombineBall.KillImpact") -- TODO(winter): Better sound; we need a sort of dissolve/burning away sound basically
    end
end

LocationDamageInfo = {
    ["Outside"] = {
        Frequency = 0.5,
        ShouldApplyDamage = IsPlayerDrowning,
        ApplyDamage = function(ply, rep)
            local world = game.GetWorld()
            local dmginfo = DamageInfo()
            dmginfo:SetDamagePosition(ply:GetPos())
            dmginfo:SetDamageForce(vector_origin)
            dmginfo:SetInflictor(world)
            dmginfo:SetAttacker(world)
            dmginfo:SetDamageType(DMG_DROWN) -- The old trigger_hurt used to use DMG_ACID
            dmginfo:SetDamage(5 * (2 ^ rep))
            ply:TakeDamageInfo(dmginfo)

            -- https://github.com/lua9520/source-engine-2018-hl2_src/blob/master/game/server/hl2/hl2_player.cpp#L3601
            -- Technically this doesn't include the ent_watery_leech entities that the real trigger_waterydeath uses, but the less ents the better
            -- Also I didn't know they even existed until looking at the dev wiki, so that's telling about how noticable they are
            if not ply.PlayingWaterDeathSounds then
                ply.m_sndLeeches = CreateSound(ply, "coast.leech_bites_loop")
                ply.m_sndLeeches:Play()
                ply.m_sndWaterSplashes = CreateSound(ply, "coast.leech_water_churn_loop")
                ply.m_sndWaterSplashes:Play()
                ply.PlayingWaterDeathSounds = true
            end
        end
    },
        --[[
    ["Power Plant"] = {
        Frequency = 0.5,
        ShouldApplyDamage = function(ply)
            local pos = ply:GetPos()

            return IsPlayerDrowning(ply) and (pos.y < 3830 and "radiation" or "acid")
        end,
        ApplyDamage = function(ply, rep, applymatch)
            local world = game.GetWorld()
            local dmgamount = applymatch == "radiation" and 0.001 * (2 ^ rep) or 100
            local dmginfo = DamageInfo()
            dmginfo:SetDamagePosition(ply:GetPos())
            dmginfo:SetDamageForce(vector_origin)
            dmginfo:SetInflictor(world)
            dmginfo:SetAttacker(world)
            dmginfo:SetDamageType(applymatch == "radiation" and DMG_RADIATION or DMG_BURN)
            dmginfo:SetDamage(dmgamount)
            ply:TakeDamageInfo(dmginfo)
            local alpha = math.min((dmgamount / 100) * 255, 255)
            local flashcolor = applymatch == "radiation" and Color(255, 255, 255, alpha) or Color(128, 255, 0, alpha)
            ply:ScreenFade(SCREENFADE.IN, flashcolor, 0.25, 0)
        end
    },
    ["Power Plant Substation"] = {
        Frequency = 0.5,
        ShouldApplyDamage = function(ply)
            local pos = ply:GetPos()

            if pos.x > 2820 or pos.y > 3825 or pos.y < 3535 or pos.z > 128 then
                local powerbuttonent = ents.FindByName("pp_power_button")[1]

                if IsValid(powerbuttonent) then
                    local savetable = powerbuttonent:GetSaveTable()
                    if savetable["m_toggle_state"] == 1 then return "electric" end
                else
                    ErrorNoHalt("Missing pp_power_button??\n")
                end
            end
        end,
        ApplyDamage = function(ply, rep)
            local genspark2ents = ents.FindByName("genspark2")

            for _, ent in ipairs(genspark2ents) do
                ent:Fire("SparkOnce")
            end

            local world = game.GetWorld()
            local dmginfo = DamageInfo()
            dmginfo:SetDamagePosition(ply:GetPos())
            dmginfo:SetDamageForce(vector_origin)
            dmginfo:SetInflictor(world)
            dmginfo:SetAttacker(world)
            dmginfo:SetDamageType(DMG_SHOCK)
            dmginfo:SetDamage(1000)
            ply:TakeDamageInfo(dmginfo)
            ply:ScreenFade(SCREENFADE.IN, color_white, 0.25, 0)
            local zapnum = math.random(1, 9)
            zapnum = zapnum == 4 and 3 or zapnum
            ply:EmitSound("ambient/energy/zap" .. tostring(zapnum) .. ".wav", 50)
        end
    },
    ["Private Theater 5"] = {
        Frequency = 0.5,
        ShouldApplyDamage = function(ply)
            local pos = ply:GetPos()

            return pos.y > 1408 and (pos.x > 1104 or (pos.x > 855 and pos.y < 1576) or pos.y > 1786)
        end,
        ApplyDamage = function(ply, rep)
            local gensparkents = ents.FindByName("genspark")

            for _, ent in ipairs(gensparkents) do
                ent:Fire("SparkOnce")
            end

            local world = game.GetWorld()
            local dmginfo = DamageInfo()
            dmginfo:SetDamagePosition(ply:GetPos())
            dmginfo:SetDamageForce(vector_origin)
            dmginfo:SetInflictor(world)
            dmginfo:SetAttacker(world)
            dmginfo:SetDamageType(DMG_SHOCK)
            dmginfo:SetDamage(1000)
            ply:TakeDamageInfo(dmginfo)
            ply:ScreenFade(SCREENFADE.IN, color_white, 0.25, 0)
            local zapnum = math.random(1, 9)
            zapnum = zapnum == 4 and 3 or zapnum
            ply:EmitSound("ambient/energy/zap" .. tostring(zapnum) .. ".wav", 50)
        end
    },
    ["The Underworld"] = {
        Frequency = 0,
        ShouldApplyDamage = function(ply) return ply:GetPos().z < -7300 end,
        ApplyDamage = function(ply)
            local world = game.GetWorld()
            local dmginfo = DamageInfo()
            dmginfo:SetDamagePosition(ply:GetPos())
            dmginfo:SetDamageForce(vector_origin)
            dmginfo:SetInflictor(world)
            dmginfo:SetAttacker(world)
            dmginfo:SetDamageType(DMG_DISSOLVE)
            dmginfo:SetDamage(2 ^ 32 - 1) -- Insta-kill
            ply:TakeDamageInfo(dmginfo)

            -- Make sure it actually killed them
            if ply:Health() <= 0 then
                ply:EmitSound("NPC_CombineBall.KillImpact")
            end
        end
    },
    ["Potassium Abyss"] = {
        Frequency = 0.5,
        ShouldApplyDamage = IsPlayerOnSlime,
        ApplyDamage = ApplyLavaDamage
    },
    ["Potassium Abyss Theater"] = {
        Frequency = 0.5,
        ShouldApplyDamage = IsPlayerOnSlime,
        ApplyDamage = ApplyLavaDamage
    },
    ["Caverns"] = {
        Frequency = 0.5,
        ShouldApplyDamage = IsPlayerOnSlime,
        ApplyDamage = ApplyLavaDamage
    },
    ]]
    ["Church"] = {
        Frequency = 5,
        ShouldApplyDamage = function(ply) return ply:Alive() and ply:IsPony() and not ply:IsAFK() and not tobool(math.random(0, 249)) end,
        ApplyDamage = function(ply, rep, applymatch, locinfo)
            local world = game.GetWorld()
            local dmginfo = DamageInfo()
            dmginfo:SetDamagePosition(ply:GetPos())
            dmginfo:SetDamageForce(vector_origin)
            dmginfo:SetInflictor(world)
            dmginfo:SetAttacker(world)
            dmginfo:SetDamageType(DMG_SHOCK)
            dmginfo:SetDamage(1000)
            ply:TakeDamageInfo(dmginfo)
            local startpos = Vector(math.Rand(locinfo.Min.x, locinfo.Max.x), math.Rand(locinfo.Min.y, locinfo.Max.y), locinfo.Max.z)
            local effect = EffectData()
            effect:SetStart(startpos)
            effect:SetOrigin(ply:GetPos()) -- Aka EndPos
            effect:SetScale(32)
            util.Effect("lightning", effect, true, true)
            ply:ScreenFade(SCREENFADE.IN, color_white, 0.25, 0)
            local zapnum = math.random(1, 9)
            zapnum = zapnum == 4 and 3 or zapnum
            ply:EmitSound("ambient/energy/zap" .. tostring(zapnum) .. ".wav", 75, 100, 0.5)
            -- Running EmitSound locally on the LocalPlayer entity makes it appear as if it's coming from "all around" while still obeying our EntityEmitSound stuff
            local thundersndpath = "ambient/atmosphere/thunder" .. tostring(math.random(1, 4)) .. ".wav"

            for _, locply in ipairs(GetPlayersInLocation(locinfo.Index)) do
                locply:SendLua([[LocalPlayer():EmitSound("]] .. thundersndpath .. [[")]])
            end

            ply:Notify("The Lord smote you for you are condemned.")
        end
    }
}

for _, locInfo in ipairs(Locations) do
    local locDamageInfo = LocationDamageInfo[locInfo.Name]

    if locDamageInfo then
        locInfo.Damage = locDamageInfo
    end
end

local function StopWaterDeathSounds(ply)
    if ply.PlayingWaterDeathSounds then
        ply.m_sndLeeches:FadeOut(0.5)
        ply.m_sndWaterSplashes:FadeOut(0.5)
        ply.PlayingWaterDeathSounds = nil
    end
end

-- TODO(winter): Use PlayerTick instead?
timer.Create("Location.DamageTick", 0, 0, function()
    for _, ply in player.HumanIterator() do
        if ply:Alive() then
            local locinfo = ply:GetLocationTable()
            local locdmginfo = locinfo.Damage

            if locdmginfo then
                local curtime = CurTime()
                local applymatch = locdmginfo.ShouldApplyDamage(ply)
                ply.NextLocDamageTime = ply.NextLocDamageTime or 0

                if curtime > ply.NextLocDamageTime then
                    if applymatch then
                        local rep = ply.DamageSourceRepeats or 0
                        locdmginfo.ApplyDamage(ply, rep, applymatch, locinfo)
                        ply.DamageSourceRepeats = rep + 1
                    else
                        ply.DamageSourceRepeats = 0
                        StopWaterDeathSounds(ply)
                    end

                    ply.NextLocDamageTime = curtime + locdmginfo.Frequency
                end
            else
                ply.DamageSourceRepeats = 0
                StopWaterDeathSounds(ply)
            end
        else
            StopWaterDeathSounds(ply)
        end
    end
end)

hook.Add("PlayerSpawn", "Location.Damage.ResetDamageTimeOnRespawn", function(ply)
    ply.NextLocDamageTime = CurTime() + 1
end)

--[[
local lastppdoorcheck = 0

hook.Add("PlayerUse", "Location.PowerPlant.ElectrifiedDoor", function(ply, ent)
    if ply:IsPlayer() and ent:GetName() == "doors_powerpf_east" then
        local powerbuttonent = ents.FindByName("pp_power_button")[1]

        if IsValid(powerbuttonent) then
            local savetable = powerbuttonent:GetSaveTable()

            if savetable["m_toggle_state"] == 1 then
                if RealTime() > lastppdoorcheck then
                    timer.Simple(0, function()
                        -- HACK: Stupid workaround for the bug in EntityEmitSound/CinemaMuteGame with GetPredictionPlayer...
                        if IsValid(ply) then
                            LocationDamageInfo["Power Plant Substation"].ApplyDamage(ply, 0, "electric")
                        end
                    end)

                    lastppdoorcheck = RealTime() + 0.5
                end

                return false
            end
        else
            ErrorNoHalt("Missing pp_power_button??\n")
        end
    end
end)
]]
hook.Add("EntityTakeDamage", "Location.TriggerDamageEffects", function(ent, dmg)
    if not IsValid(ent) or not ent:IsPlayer() then return end
    local inflictor = dmg:GetInflictor()
    if not IsValid(inflictor) or dmg:GetInflictor():GetClass() ~= "trigger_hurt" then return end

    -- HACK(winter): The trigger_hurt for the reactor water uses DMG_GENERIC, since we don't want geiger sounds playing ALL THE TIME nearby
    if ent:GetLocationName() == "Power Plant" and ent:WaterLevel() > 0 and ent:GetPos().z < -48 then
        dmg:SetDamageType(DMG_RADIATION)
    end

    local dmgtype = dmg:GetDamageType()

    if dmgtype == DMG_SHOCK then
        ent:ScreenFade(SCREENFADE.IN, color_white, 0.25, 0)
        local zapnum = math.random(1, 9)
        zapnum = zapnum == 4 and 3 or zapnum
        ent:EmitSound("ambient/energy/zap" .. tostring(zapnum) .. ".wav", 50)
    elseif dmgtype == DMG_RADIATION then
        local alpha = math.min((dmg:GetDamage() / 100) * 255, 255)
        local flashcolor = Color(255, 255, 255, alpha)
        ent:ScreenFade(SCREENFADE.IN, flashcolor, 0.25, 0)
    elseif dmgtype == DMG_BURN then
        -- Burning should light them on fire too
        ent:Ignite(0.5, 0) -- Does 1 damage/hit

        -- If this burning will kill them, make it dissolve them too
        if dmg:GetDamage() >= ent:Health() then
            dmg:SetDamageType(DMG_DISSOLVE)
        end
    end
end)

hook.Add("PostEntityTakeDamage", "Location.TriggerPostDamageEffects", function(ent, dmg, took)
    if not took then return end
    if not IsValid(ent) or not ent:IsPlayer() then return end
    local inflictor = dmg:GetInflictor()
    if not IsValid(inflictor) or dmg:GetInflictor():GetClass() ~= "trigger_hurt" then return end
    -- Make sure it actually killed them
    local dmgtype = dmg:GetDamageType()

    if dmgtype == DMG_DISSOLVE and ent:Health() <= 0 then
        ent:EmitSound("NPC_CombineBall.KillImpact")
    end
end)
