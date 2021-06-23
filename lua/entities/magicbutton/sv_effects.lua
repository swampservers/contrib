-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- this is where we generate a random amount of points to give the player
function ButtonMoneyPrize()
    local min, max = 1000, 300000
    local silly = math.random(1, 30) == 1

    return silly and math.random(1, 1000) or math.Round(math.pow(math.Rand(0, 1), 4) * (max - min) + min, -3)
end

--Selects a player to override the default given using the given chance. basically if an outcome should has a chance of affecting a random player.
local function ButtonTarget(defaultply, chance)
    if (math.random(1, chance) == 1) then
        local victims = {}

        for k, v in pairs(player.GetAll()) do
            if (v ~= ply and not Safe(v) and not v:InVehicle() and not v:IsAFK()) then
                table.insert(victims, v)
                break
            end
        end

        if (#victims > 0) then
            local choice = table.Random(victims)

            return choice, choice:Nick()
        end
    end

    return defaultply, defaultply:Nick()
end

local function GetUnsafePlayers()
    local tbl = {}

    for k, v in pairs(player.GetAll()) do
        if (v ~= ply and not Safe(v) and not v:InVehicle() and not v:IsAFK()) then
            table.insert(tbl, v)
        end
    end

    return tbl
end

local function bademote()
    return table.Random({";dog;", ";cuck;", ";baby;", ";kekw;", ";bad;", ";biggestloser;", ";hmm3;", ";hmmsad;", ";concern;", ";bartcry;", ";bazinga;", ";boohoo;", ";chungus;", ";eating;"})
end

local function goodemote()
    return table.Random({";based;"})
end

local function MagicOutcomePrize(ply)
    ply:EmitSound("pt/casino/slots/winner.wav")
    local targetply, targetname = ButtonTarget(ply, 50)
    local amount = ButtonMoneyPrize()
    ply:SS_GivePoints(amount)
    local str = string.Comma(amount) .. " point" .. (amount ~= 1 and "s" or "")

    local emote = table.Random({";coins;", ";swampcoin;"})

    if (amount < 5000) then
        emote = ";annoyed;"
    end

    return "gave [white]" .. targetname .. " [yellow]" .. str .. "!" .. emote
end

local function MagicOutcomeBounty(ply)
    local targetply, targetname = ButtonTarget(ply, 10)
    local amount = ButtonMoneyPrize()
    local add = GetPlayerBounty(targetply) + amount
    SetPlayerBounty(targetply, add)
    local str = string.Comma(amount) .. " point" .. (amount ~= 1 and "s" or "")

    return "put a [yellow]" .. str .. "[white] bounty on " .. targetname .. "! ;dougie;"
end

local function MagicOutcomeBountyAndPrize(ply)
    local targetply, targetname = ButtonTarget(ply, 10)
    targetply:EmitSound("pt/casino/slots/winner.wav")
    local amount = ButtonMoneyPrize()
    if (targetply.SS_GivePoints == nil or SetPlayerBounty == nil or GetPlayerBounty == nil) then return nil end
    targetply:SS_GivePoints(amount)
    local add = GetPlayerBounty(targetply) + amount
    SetPlayerBounty(targetply, add)
    local str = string.Comma(amount) .. " point" .. (amount ~= 1 and "s" or "")

    return "gave [white]" .. targetname .. " [yellow]" .. str .. " [white]but also placed a [yellow]" .. str .. " [white]bounty on them! ;fingers;"
end

local function MagicOutcomeBountyAll(ply)
    if (SetPlayerBounty == nil or GetPlayerBounty == nil) then return nil end
    local amount = 1000

    if (math.random(1, 20) == 1) then
        amount = math.random(2, 45)
    end

    if (math.random(1, 60) == 1) then
        amount = 5000
    end

    for k, v in pairs(player.GetHumans()) do
        local add = GetPlayerBounty(v) + amount
        SetPlayerBounty(v, add)
    end

    return "has increased everyone's bounty by [yellow]" .. string.Comma(amount) .. " points! ;dougie;"
end

local function MagicOutcomeFreeze(ply)
    local targetply, noun = ButtonTarget(ply, 20)
    ply:Freeze(true)
    ply:EmitSound("physics/glass/glass_impact_bullet1.wav")

    timer.Create(ply:EntIndex() .. "ButtonFreezeExpire", 30, 1, function()
        ply:Freeze(false)
        ply:ViewPunch(AngleRand() / 20)
        ply:EmitSound("physics/glass/glass_sheet_break3.wav")
    end)

    return "froze [white]" .. noun .. " for 30 seconds! ;trollin;"
end

local function MagicOutcomeDecals(ply, button)
    Sound("coomer/splort.ogg")

    local decalrange = {36, 37, 38, 39, 40}

    local navareas = navmesh.GetAllNavAreas()
    local spamcounter = 0
    local pos = button:GetPos() + button:GetUp() * 64
    button:EmitSound("coomer/splort.ogg")

    timer.Create("Splats", 0.05, 10, function()
        local decal = SPRAYPAINT_STENCILS ~= nil and ("stencil_decal" .. table.Random(decalrange)) or (table.Random({"Eye", "Smile", "beersplash"}))

        for g = 1, 15 do
            util.Decal(decal, pos, pos + ((VectorRand() * Vector(1, 1, 0.9)):GetNormalized() * 3000), ply)
        end
    end)

    return ""
end

local function MagicOutcomePoopCouch(ply, button)
    Sound("coomer/splort.ogg")
    local noz
    local nozonserver
    local couchpos = Vector(895, 696, 32)

    for k, v in pairs(player.GetAll()) do
        if (v:SteamID() == "STEAM_0:1:43528204" and v:GetPos():Distance(couchpos) < 128) then
            nozonserver = true
            noz = v
            break
        end
    end

    if (IsValid(noz) and not noz:InVehicle()) then
        noz = nil
    end

    if (IsValid(noz)) then
        noz:EmitSound("coomer/splort.ogg")

        for g = 1, 5 do
            local pos = couchpos + VectorRand() * Vector(32, 24, 0)
            util.Decal("beersplash", pos, pos + Vector(0, 0, -128) + VectorRand() * Vector(32, 32, 0), ply)
        end

        return "made [white]Noz take a big poopy all over the Noz couch"
    end
end

local function MagicOutcomeExplode(ply, button)
    local explosion = ents.Create("env_explosion") -- The explosion entity
    local targetply, noun = ButtonTarget(ply, 8)
    local pos = targetply:GetPos() + Vector(0, 0, 40)
    explosion:SetPos(pos)
    explosion:Spawn()
    explosion:SetKeyValue("iMagnitude", "150") 
    explosion:SetOwner(button)
    explosion:Fire("Explode", 0, 0) 
    return ""
end

local function MagicOutcomeKleinerFanclub(ply)
    if (KLEINER_NPCS and table.Count(KLEINER_NPCS) > 0) then
        local targetply, noun = ButtonTarget(ply, 20)
        KLEINER_OVERRIDE_TARGET = targetply

        timer.Create("KLEINER_GOD_EXPIRE", 60 * 15, 1, function()
            KLEINER_OVERRIDE_TARGET = nil
        end)

        return "made [white]" .. noun .. " really popular with kleiners! ;kleinerfortnite;"
    end
end

local function MagicOutcomeKleinerSlur(ply)
    if (KLEINER_NPCS and table.Count(KLEINER_NPCS) > 0) then
        local targetply, noun = ButtonTarget(ply, 15)
        KLEINER_BULLIES[targetply:SteamID()] = 5000

        return "sent the kleiner mob after [white]" .. noun .. "! ;antikleiner;"
    end
end

local function MagicOutcomeKleinerTeleported(ply)
    if (KLEINER_NPCS and table.Count(KLEINER_NPCS) > 0) then
        local targetply, noun = ButtonTarget(ply, 15)

        for k, v in pairs(ents.FindByClass("kleiner")) do
            v:TeleportSafe(targetply:GetPos())
        end

        return "teleported all kleiners to [white]" .. noun .. ";kleinerfortnite;"
    end
end

MagicButtonLandmarks = {
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
        local hinttype = math.random(1, 2)
        local hint = ""

        if (hinttype == 1) then
            local soundhints = {
                ["keem/gamer.ogg"] = "gamer",
                ["boop.wav"] = "pony",
                ["mowsquee.wav"] = "pony",
                ["mow.ogg"] = "meow",
            }

            local snddesc, sndname = table.Random(soundhints)
            button.HintSound = sndname
            hint = ", making " .. snddesc .. " sounds!"
        elseif (hinttype == 2) then
            if (locname == "Outside") then
                local nearest = 1000000
                local nearestname
                local secondnearestname

                for k, v in pairs(MagicButtonLandmarks) do
                    if (v:Distance(button:GetPos()) < nearest) then
                        secondnearestname = nearestname
                        nearestname = k
                        nearest = v:Distance(button:GetPos())
                    end
                end

                locname = locname .. " (" .. nearestname .. ")"
            end

            hint = " at [white]" .. (locname or "Somewhere autistic") .. "!"
        end

        if (math.random(1, 4) == 1) then
            button.CoolEffectOnly = true
            button:SetColor(Color(255, 240, 0))
        end

        BotSayGlobal("[yellow]A strange flashing button[white] has appeared on the map" .. hint)

        return ""
    end
end

local function MagicOutcomeTeleportRandom(ply, button)
    button:EmitSound("ambient/machines/teleport1.wav")
    ply:EmitSound("ambient/machines/teleport1.wav")
    local targetply, targetname = ButtonTarget(ply, 15)
    targetply:SetPos(button:FindSuitableCastOrigin().StartPos)

    return ""
end

local function MagicOutcomeSpawnObject(ply, button)
    local snd = Sound("Airboat.FireGunRevDown")

    local classes = {
        sent_ball = {
            "Bouncy Ball", math.random(6, 16), function(ent, button)
                ent:SetPos(button:GetPos() + button:GetUp() * 30 + VectorRand() * 20)
                ent:SetBallSize(24)
                ent:SetUseType(SIMPLE_USE)
                ent:GetPhysicsObject():SetVelocity(VectorRand() * 200)
            end
        },
        prop_physics = {
            "Explosive Barrel", 4, function(ent, button)
                ent:SetPos(button:GetPos() + button:GetUp() * 64 + VectorRand() * 32)
                ent:SetModel("models/props_c17/oildrum001_explosive.mdl")
            end,
            true
        },
        npc_headcrab = {
            "Headcrab", math.random(1, 5), function(ent, button)
                local pos = table.Random(navmesh.Find(button:GetPos() + button:GetUp() * 50, 200, 2000, 2000)):GetRandomPoint()
                ent:SetPos(pos)
            end
        },
        npc_grenade_frag = {
            "Live Grenade", math.random(1, 10), function(ent, button)
                ent:GetPhysicsObject():SetVelocity(VectorRand() * 100)
                ent:SetOwner(button)
                ent:Fire("SetTimer", math.random(2, 6))
            end
        },
        item_ammo_smg1 = {
            "SMG Ammo", math.random(1, 10), function(ent, button)
                ent:SetPos(button:GetPos() + button:GetUp() * 64 + VectorRand() * 32)
                ent:GetPhysicsObject():SetVelocity(VectorRand() * 100)
            end
        },
    }

    local dat, class = table.Random(classes)
    local number = dat[2] or 1
    local name = dat[1]
    local func = dat[3]

    for i = 1, number do
        local ent = ents.Create(class)

        if (dat[4] and func) then
            func(ent, button)
        end

        ent:Spawn()
        ent:EmitSound(snd)
        ent:SetPos(button:GetPos() + button:GetUp() * ent:BoundingRadius())
        SafeRemoveEntityDelayed(ent, 60 * 5) --whatever we spawn, make sure it's gone after 5 minutes

        if (not dat[4] and func) then
            func(ent, button)
        end

        if (ent:GetPos():Distance(button:GetPos()) > 16) then
            local effectdata = EffectData()
            effectdata:SetOrigin(ent:GetPos())
            effectdata:SetStart(button:GetPos())
            effectdata:SetAttachment(0)
            effectdata:SetEntity(button)
            util.Effect("ToolTracer", effectdata)
        end
    end

    local what = name or ent.PrintName or ent:GetClass()

    return ""
end

local function MagicOutcomeOverlay(ply, button)
    local overlays = {"models/props_c17/fisheyelens", "effects/combine_binocoverlay", "models/props_combine/stasisshield_sheet", "effects/water_warp01", "effects/distortion_normal001", "effects/tp_eyefx/tpeye"}

    local victim, noun = ButtonTarget(ply, 25)
    victim:EmitSound("coomer/splort.ogg")
    victim:ConCommand("pp_mat_overlay_refractamount -0.04")
    victim:ConCommand("pp_mat_overlay " .. table.Random(overlays))

    timer.Simple(30, function()
        if (IsValid(victim)) then
            victim:ConCommand("pp_mat_overlay ''")
        end
    end)

    return ""
end



local function MagicOutcomeShoot(ply, button)
    local blame = ents.Create("weapon_peacekeeper")
    blame:SetPos(button:GetPos())
    blame:Spawn()
    blame:SetMoveType(MOVETYPE_NONE)
    blame:SetSolid(SOLID_NONE)
    blame:SetNoDraw(true)
    SafeRemoveEntityDelayed(blame, 2)
    button:EmitSound("Double_Barrel.Single", nil, nil, nil, CHAN_WEAPON, nil)
    local bullet = {}
    bullet.Src = button:GetPos() + button:GetUp() * 3
    bullet.Dir = ((ply:GetPos() + Vector(0, 0, 48)) - bullet.Src):GetNormalized()
    bullet.Num = 200
    bullet.Force = 20000
    bullet.Spread = Vector(2, 2, 0)
    bullet.Attacker = button
    bullet.Damage = 18000
    bullet.Tracer = 1
    bullet.TracerName = "Tracer"
    blame:FireBullets(bullet, true)

    return ""
end

local function MagicOutcomeSnap(ply, button)
    if (GauntletFizzlePlayer) then
        button:EmitSound("gauntlet/snap.wav", 100)
        local gaunt = ents.Create("weapon_gauntlet")
        gaunt:SetPos(Vector(0, 0, 32000))
        gaunt:Spawn()
        gaunt:SetMoveType(MOVETYPE_NONE)
        gaunt:SetSolid(SOLID_NONE)
        gaunt:SetNoDraw(true)
        SafeRemoveEntityDelayed(gaunt, 2)
        --yea i know its pretty autistic to spawn a swep just so that we can blame kills, but its better than some autistic chat message imo.
        local victim, noun = ButtonTarget(ply, 2)
        --this function is used by the updated gauntlet
        ply:Fizzle(ply ~= victim and ply or button, gaunt )

        return ""
    end
end

local function MagicOutcomeBigSnap(ply, button)
    --this one should be stupid rare so i made it fail at random
    if (math.random(1, 4) > 1) then return end

    if (GauntletFizzlePlayer) then
        local victims = table.Copy(GetUnsafePlayers())
        local gaunt = ents.Create("weapon_gauntlet")
        gaunt:SetPos(Vector(0, 0, 32000))
        gaunt:Spawn()
        gaunt:SetMoveType(MOVETYPE_NONE)
        gaunt:SetSolid(SOLID_NONE)
        gaunt:SetNoDraw(true)
        SafeRemoveEntityDelayed(gaunt, 11)

        for i = 1, #victims / 2 do
            table.remove(victims, math.random(0, #victims))
        end

        for k, victim in pairs(victims) do
            victim:EmitSound("gauntlet/snap.wav", 100)

            timer.Simple(math.Rand(0, 10), function()
                if (IsValid(victim)) then
                    GauntletFizzlePlayer(gaunt, victim, gaunt)
                end
            end)
        end

        BotSayGlobal("[fbc]*snap* ;snap;;thanos; [fbc]")

        return ""
    end
end

local function MagicOutcomeSoreNeck(ply, button)
    ply:EmitSound("physics/body/body_medium_break" .. math.random(2, 4) .. ".wav")
    local eang = ply:EyeAngles()
    eang.roll = eang.roll + ((math.random(0, 1) and 15) or -15)
    ply:SetEyeAngles(eang)
    local bone = ply:LookupBone("ValveBiped.Bip01_Head1") or ply:LookupBone("LRigScull")
    local bang = ply:GetManipulateBoneAngles(bone)
    bang.pitch = -eang.roll
    ply:ManipulateBoneAngles(bone, bang)
    local timername = ply:UserID() .. "neckpainreset"

    if (timer.Exists(timername)) then
        local reps = timer.RepsLeft(timername)
        timer.Adjust(timername, 8, reps + 1)
    else
        timer.Create(timername, 8, 1, function()
            if (IsValid(ply)) then
                local eang = ply:EyeAngles()
                local val = eang.roll > 0 and 1 or eang.roll < 0 or 0
                eang.roll = eang.roll - 15 * val

                if (val ~= 0) then
                    ply:EmitSound("physics/body/body_medium_break" .. math.random(2, 4) .. ".wav")
                    ply:SetEyeAngles(eang)
                    local bone = ply:LookupBone("ValveBiped.Bip01_Head1") or ply:LookupBone("LRigScull")
                    local bang = ply:GetManipulateBoneAngles(bone)
                    bang.pitch = -eang.roll
                    ply:ManipulateBoneAngles(bone, bang)
                end
            end
        end)
    end

    return ""
end

local function MagicOutcomeNothing(ply, button)
    ply:ChatPrint(";trollin;")

    return ""
end

local function MagicOutcomeMysteryBox(ply, button)
    if (OpenAPresent) then
        local content = OpenAPresent(ply, button:GetPos())

        return "has rewarded [white]" .. ply:Nick() .. " with [white]" .. content .. "! ;alien;"
    end
end

local function MagicOutcomeMysteryBoxSpawn(ply, button)
    local num = math.random(3, 8)

    for i = 1, num do
        local origin = button:FindSuitableCastOrigin()
        local box = ents.Create("mysterybox") --what is the ent name of the mystery box?

        if (IsValid(box)) then
            box:SetPos(origin)
            box:EmitSound("physics/cardboard/cardboard_box_impact_bullet5.wav")
            box:SetAngles(Angle(0, math.Random(0, 360), 0))
            box:Spawn()
        end
    end

    return "has hidden [white]" .. num .. " mystery boxes in random spots in the map!"
end

--yeah i know some of these functions fit in here but it's a pain in the ass to tweak the chances with so much code stuck in the list randomly.
MagicButtonOutcomes = {
    {
        name = "MagicOutcomeNothing",
        func = MagicOutcomeNothing,
        uncool = true,
        weight = 12
    },
    {
        name = "MagicOutcomePrize",
        func = MagicOutcomePrize,
        cool = true,
        weight = 6
    },
    {
        name = "MagicOutcomeBounty",
        func = MagicOutcomeBounty,
        weight = 10
    },
    {
        name = "MagicOutcomeBountyAndPrize",
        func = MagicOutcomeBountyAndPrize,
        cool = true,
        weight = 8,
    },
    {
        name = "MagicOutcomeKleinerFanclub",
        func = MagicOutcomeKleinerFanclub,
        weight = 0,
    },
    {
        name = "MagicOutcomeKleinerTeleported",
        func = MagicOutcomeKleinerTeleported,
        weight = 0,
    },
    {
        name = "MagicOutcomeKleinerSlur",
        func = MagicOutcomeKleinerSlur,
        weight = 0,
    },
    {
        name = "MagicOutcomeOverlay",
        func = MagicOutcomeOverlay,
        weight = 7,
    },
    {
        name = "MagicOutcomeSpawnObject",
        func = MagicOutcomeSpawnObject,
        weight = 18,
    },
    {
        name = "MagicOutcomeTeleportRandom",
        func = MagicOutcomeTeleportRandom,
        weight = 19,
    },
    {
        name = "MagicOutcomeBountyAll",
        func = MagicOutcomeBountyAll,
        cool = true,
        weight = 5,
    },
    {
        name = "MagicOutcomeButtonSpawn",
        func = MagicOutcomeButtonSpawn,
        weight = 25,
    },
    {
        name = "MagicOutcomeFreeze",
        func = MagicOutcomeFreeze,
        weight = 5,
    },
    {
        name = "MagicOutcomeExplode",
        func = MagicOutcomeExplode,
        weight = 28,
    },
    {
        name = "MagicOutcomeShoot",
        func = MagicOutcomeShoot,
        uncool = true,
        weight = 28,
    },
    {
        name = "MagicOutcomeSnap",
        func = MagicOutcomeSnap,
        weight = 27,
    },
    {
        name = "MagicOutcomeBigSnap",
        func = MagicOutcomeBigSnap,
        weight = 1,
    },
    {
        name = "MagicOutcomeDecals",
        func = MagicOutcomeDecals,
        weight = 12,
    },
    {
        name = "MagicOutcomePoopCouch",
        func = MagicOutcomePoopCouch,
        weight = 2,
    },
    {
        name = "MagicOutcomeSoreNeck",
        func = MagicOutcomeSoreNeck,
        uncool = true,
        weight = 15,
    },
    {
        name = "MagicOutcomeMysteryBox",
        func = MagicOutcomeMysteryBox,
        cool = true,
        weight = 40,
    },
    {
        name = "MagicOutcomeMysteryBoxSpawn",
        func = MagicOutcomeMysteryBoxSpawn,
        weight = 3,
    }
}

--super cool code that displays the chances

local total = 0
for k,v in pairs(MagicButtonOutcomes)do
    total = total + v.weight
end

for k,v in pairs(MagicButtonOutcomes)do
    print(v.name," "," - ","("..math.Round((v.weight/total)*100,2).."%)")
end
print(total)
