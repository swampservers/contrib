-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- this is where we generate a random amount of points to give the player
function ButtonMoneyPrize()
    local min, max = 1000, 300000
    local silly = math.random(1, 30) == 1

    return silly and math.random(1,1000) or math.Round(math.pow(math.Rand(0, 1), 4) * (max - min) + min, -3)
end

--Selects a player to override the default given using the given chance. basically if an outcome should have a chance of affecting a random player.
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

    return defaultply, "them"
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
    local amount = ButtonMoneyPrize()
    ply:SS_GivePoints(amount)
    local str = string.Comma(amount) .. " point" .. (amount ~= 1 and "s" or "")
    local emote = table.Random({";coins;",";swampcoin;"})
    if(amount < 5000)then emote = ";annoyed;" end 
    return "and won [white]" .. str .. "![fbc]"..emote
end

local function MagicOutcomeBountyAndPrize(ply)
    ply:EmitSound("pt/casino/slots/winner.wav")
    local amount = ButtonMoneyPrize()
    if (ply.SS_GivePoints == nil or SetPlayerBounty == nil or GetPlayerBounty == nil) then return nil end
    ply:SS_GivePoints(amount)
    local add = GetPlayerBounty(ply) + amount
    SetPlayerBounty(ply, add)
    local str = string.Comma(amount) .. " point" .. (amount ~= 1 and "s" or "")

    return "and won [red]" .. str .. "[fbc] and also a [red]" .. str .. " bounty[fbc] on themself! ;fingers;"
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

    for k, v in pairs(player.GetAll()) do
        local add = GetPlayerBounty(v) + amount
        SetPlayerBounty(v, add)
    end

    return "and [red]increased everyone's bounty by " .. string.Comma(amount) .. " points! ;dougie;"
end

local function MagicOutcomeKleinerFanclub(ply)
    if (KLEINER_NPCS and table.Count(KLEINER_NPCS) > 0) then
        local targetply, noun = ButtonTarget(ply, 20)
        KLEINER_OVERRIDE_TARGET = targetply

        timer.Create("KLEINER_GOD_EXPIRE", 60 * 15, 1, function()
            KLEINER_OVERRIDE_TARGET = nil
        end)

        return "and it made " .. noun .. " really popular with kleiners! ;kleinerfortnite;"
    end
end

local function MagicOutcomeDecals(ply, button)
    Sound("coomer/splort.ogg")

    local decalrange = {36, 37, 38, 39, 40}

    local navareas = navmesh.GetAllNavAreas()
    local spamcounter = 0
    local pos = button:GetPos() + button:GetUp() * 64
    button:EmitSound("coomer/splort.ogg")

    timer.Create("Splats", 0.01, 10, function()
        local decal = SPRAYPAINT_STENCILS ~= nil and ("stencil_decal" .. table.Random(decalrange)) or (table.Random({"Eye", "Smile", "beersplash"}))

        for g = 1, 100 do
            util.Decal(decal, pos, pos + ((VectorRand() * Vector(1, 1, 0.3)):GetNormalized() * 3000), ply)
        end

        pos = table.Random(navareas):GetCenter() + Vector(0, 0, 40)
    end)

    return "and it sprayed a bunch of funny decals everywhere"
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
    if(IsValid(noz) and !noz:InVehicle())then noz = nil end
    noz = ply

    if (IsValid(noz) ) then
        noz:EmitSound("coomer/splort.ogg")

        for g = 1, 5 do
            local pos = couchpos + VectorRand() * Vector(32, 24, 0)
            util.Decal("beersplash", pos, pos + Vector(0, 0, -128) + VectorRand() * Vector(64, 64, 0), ply)
        end

        return "and it made Noz take a big poopy all over the Noz couch"
    end
end

local function MagicOutcomeExplode(ply, button)
    local explosion = ents.Create("env_explosion") -- The explosion entity
    local targetply, noun = ButtonTarget(ply, 8)
    local pos = targetply:GetPos() + Vector(0, 0, 40)
    explosion:SetPos(pos) -- Put the position of the explosion at the position of the entity
    explosion:Spawn() -- Spawn the explosion
    explosion:SetKeyValue("iMagnitude", "150") -- the magnitude of the explosion
    explosion:Fire("Explode", 0, 0) -- explode

    return "and it exploded " .. noun .. ";crazy;"
end

local function MagicOutcomeKleinerSlur(ply)
    if (KLEINER_NPCS and table.Count(KLEINER_NPCS) > 0) then
        local targetply, noun = ButtonTarget(ply, 15)
        KLEINER_BULLIES[targetply:SteamID()] = 5000

        return "and it sent the kleiner mob after " .. noun .. "! ;antikleiner;"
    end
end

local function MagicOutcomeKleinerTeleported(ply)
    if (KLEINER_NPCS and table.Count(KLEINER_NPCS) > 0) then
        local targetply, noun = ButtonTarget(ply, 15)

        for k, v in pairs(ents.FindByClass("kleiner")) do
            v:TeleportSafe(targetply:GetPos())
        end

        return "and it teleported all kleiners to the player [white]" .. noun .. ";kleinerfortnite;"
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
        local hinttype = math.random(1, 2)
        local hint = ""

        if (hinttype == 1) then
            local soundhints = {
                ["keem/gamer.ogg"] = "began screaming cool gamer lingo!",
                ["boop.wav"] = "began emitting cute pony noises!",
                ["mowsquee.wav"] = "began emitting funny pony squeaks!",
                ["mow.ogg"] = "began emitting kawaii cat noises!",
                ["weapon_funnybanana/funnysounds01.ogg"] = "began emitting wacky comedy noises!",
            }

            local snddesc, sndname = table.Random(soundhints)
            button.HintSound = sndname
            hint = ", which " .. snddesc .. " keep an ear out!"
        elseif (hinttype == 2) then
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

            hint = ", which appeared somewhere in the location: [white]" .. (locname or "Somewhere autistic") .. "!"
        end

        if (math.random(1, 10) == 1) then
            button.CoolEffectOnly = true
            hint = hint .. "[red] This button is guaranteed to give something good!"
        end

        return "and spawned [rainbow2]another button[fbc]" .. hint
    end
end

local function MagicOutcomeTeleportRandom(ply, button)
    button:EmitSound("ambient/machines/teleport1.wav")
    ply:SetPos(button:FindSuitableCastOrigin().StartPos)

    return "and teleported somewhere mysterious! " .. table.Random({";blackwhat;", ";billhead;", ";crazyhamburger;", ";merchant;"})
end

local function MagicOutcomeSpawnObject(ply, button)
    local snd = Sound("Airboat.FireGunRevDown")
    button:EmitSound(snd)

    local classes = {
        sent_ball = {
            "Bouncy Ball", 10, function(ent, button)
                ent:SetPos(button:GetPos() + button:GetUp() * 30 + VectorRand() * 20)
                ent:SetBallSize(24)
                ent:GetPhysicsObject():SetVelocity(VectorRand() * 20)
            end
        },
        npc_headcrab = {
            "Headcrab", math.random(1, 5), function(ent, button)
                local pos = table.Random(navmesh.Find(button:GetPos() + button:GetUp() * 50, 100, 2000, 2000)):GetRandomPoint()
                ent:SetPos(pos)
            end
        },
        npc_grenade_frag = {
            "Live Grenade", math.random(1, 10), function(ent, button)
                ent:GetPhysicsObject():SetVelocity(VectorRand() * 100)
                ent:Fire("SetTimer", math.random(2, 6))
            end
        },
        dodgeball = {
            "Dodgeball", 1, function(ent, button)
                ent:SetPos(button:GetPos() + button:GetUp() * 32)
                ent:GetPhysicsObject():SetVelocity(button:GetUp() * 500)
            end
        },
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
        return "and it spawned " .. number .. " " .. what .. "s!"
    else
        return "and it spawned a " .. what .. "!"
    end
end

local function MagicOutcomeOverlay(ply, button)
    local overlays = {"models/shadertest/shader4", "models/props_c17/fisheyelens", "effects/combine_binocoverlay", "models/props_combine/stasisshield_sheet", "models/shadertest/shader5", "effects/water_warp01", "effects/distortion_normal001", "effects/tp_eyefx/tpeye"}

    ply:EmitSound("coomer/splort.ogg")
    ply:ConCommand("pp_mat_overlay_refractamount -0.06")
    ply:ConCommand("pp_mat_overlay " .. table.Random(overlays))

    timer.Simple(30, function()
        if (IsValid(ply)) then
            ply:ConCommand("pp_mat_overlay ''")
        end
    end)

    return "and had their screen fucked up ;billhead;"
end

local function MagicOutcomeHealth(ply)
    local amount = 10000
    ply:SetHealth(amount)
    ply:EmitSound("items/medshot4.wav")

    return "and received [white]" .. string.Comma(amount) .. " Health! " .. table.Random({";doomguy;", ";blink;", ";doomdance;"})
end

local function MagicOutcomeShoot(ply, button)
    button:EmitSound("Weapon_Shotgun.Double", nil, nil, nil, CHAN_WEAPON, nil)
    local bullet = {}
    bullet.Src = button:GetPos() + button:GetUp() * 3
    bullet.Dir = ((ply:GetPos() + Vector(0, 0, 48)) - bullet.Src):GetNormalized()
    bullet.Num = 200
    bullet.Force = 20000
    bullet.Spread = Vector(2, 2, 0)
    bullet.Attacker = ply
    bullet.Damage = 18000
    bullet.Tracer = 1
    bullet.TracerName = "AR2Tracer"
    button:FireBullets(bullet, true)

    return "and it fired out a shotgun blast ;doomguy;"
end

local function MagicOutcomeSnap(ply, button)
    if (GauntletFizzlePlayer) then
        local victim, noun = ButtonTarget(ply, 2)
        GauntletFizzlePlayer(button, victim, ply)

        return "and it snapped " .. noun .. " out of existence! ;thanos;"
    end
end

local function MagicOutcomeBigSnap(ply, button)
    if (GauntletFizzlePlayer) then
        local victims = table.Copy(GetUnsafePlayers())

        for i = 1, #victims / 2 do
            table.remove(victims, math.random(0, #victims))
        end

        for k, victim in pairs(victims) do
            timer.Simple(math.Rand(0, 10), function()
                if (IsValid(victim)) then
                    GauntletFizzlePlayer(game.GetWorld(), victim, ply)
                end
            end)
        end

        return "[red]and it wiped out half the players on the server! ;thanos;"
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
        timer.Adjust(timername, 15, reps + 1)
    else
        timer.Create(timername, 15, 1, function()
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

    return "and got a sore neck" .. table.Random({";eating;", ";flopspin;", ";handycapp;", ";hidethepain;"})
end

local function MagicOutcomeNothing(ply, button)
    return "but nothing happened!" .. bademote()
end

local function MagicOutcomeMysteryBox(ply, button)
    if (OpenAPresent) then
        local content = OpenAPresent(ply, button:GetPos())

        return "and got [white]" .. content .. "[fbc]! ;alien;"
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

    return "and spawned " .. num .. " mystery boxes in random spots in the map!"
end

--yeah i know some of these functions fit in here but it's a pain in the ass to tweak the chances with so much code stuck in the list randomly.
MagicButtonOutcomes = {
    {
        func = MagicOutcomeNothing,
        uncool = true,
        weight = 50
    },
    {
        func = MagicOutcomePrize,
        cool = true,
        weight = 50
    },
    {
        func = MagicOutcomeBountyAndPrize,
        cool = true,
        weight = 50,
    },
    {
        func = MagicOutcomeKleinerFanclub,
        weight = 50,
    },
    {
        func = MagicOutcomeKleinerTeleported,
        weight = 50,
    },
    {
        func = MagicOutcomeKleinerSlur,
        weight = 50,
    },
    {
        func = MagicOutcomeOverlay,
        weight = 50,
    },
    {
        func = MagicOutcomeSpawnObject,
        weight = 50,
    },
    {
        func = MagicOutcomeTeleportRandom,
        weight = 50,
    },
    {
        func = MagicOutcomeBountyAll,
        cool = true,
        weight = 50,
    },
    {
        func = MagicOutcomeButtonSpawn,
        weight = 50,
    },
    {
        func = MagicOutcomeExplode,
        weight = 50,
    },
    {
        func = MagicOutcomeShoot,
        uncool = true,
        weight = 50,
    },
    {
        func = MagicOutcomeSnap,
        weight = 50,
    },
    {
        func = MagicOutcomeBigSnap,
        weight = 2,
    },
    {
        func = MagicOutcomeHealth,
        cool = true,
        weight = 50,
    },
    {
        func = MagicOutcomeDecals,
        weight = 50,
    },
    {
        func = MagicOutcomePoopCouch,
        weight = 2,
    },
    {
        func = MagicOutcomeSoreNeck,
        uncool = true,
        weight = 50,
    },
    {
        func = MagicOutcomeMysteryBox,
        cool = true,
        weight = 50,
    },
    {
        func = MagicOutcomeMysteryBoxSpawn,
        weight = 50,
    }
}

--spawn a number of mystery boxes around the map
local function AlterMagicButtonBehavior()
    for k, v in pairs(MagicButtonOutcomes) do
        MagicButtonOutcomes[k].weightbonus = nil
    end

    local varval, varkey = table.Random(MagicButtonOutcomes)
    MagicButtonOutcomes[varkey].weightbonus = math.random(1, 3) --let's goof around a little and make a random outcome more likely
end

AlterMagicButtonBehavior()
timer.Create("buttonvariation", 60 * 60, 0, AlterMagicButtonBehavior)