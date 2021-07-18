-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

-- this is where we generate a random amount of points to give the player
function ButtonMoneyPrize()
    local min, max = 1000, 600000
    local silly = math.random(1, 30) == 1
    if(math.random(1,1000) == 1)then return 1 end
    if(math.random(1,100) == 1)then return math.random(1, 1000) end
    if(math.random(1,69) == 1)then return 69 end
    if(math.random(1,420) == 1)then return 420 end


    return math.Round(math.pow(math.Rand(0, 1), 6) * (max - min) + min, 0)
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
    if (targetply ~= ply) then
        ply:ChatPrint(":banana: [yellow]haha " .. targetply:Nick() .. " got your prize instead of you")
    end

    return "gave [white]" .. targetname .. " [yellow]" .. str .. "!" .. emote
end

local function MagicOutcomeBounty(ply)
    local targetply, targetname = ButtonTarget(ply, 7)
    local amount = ButtonMoneyPrize()
    local add = GetPlayerBounty(targetply) + amount
    SetPlayerBounty(targetply, add)
    local str = string.Comma(amount) .. " point" .. (amount ~= 1 and "s" or "")
    if (targetply ~= ply) then
        ply:ChatPrint(":banana: [yellow]haha " .. targetply:Nick() .. " got your bounty instead of you")
    end

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
    
    if (targetply ~= ply) then
        ply:ChatPrint(":banana: [yellow]haha " .. targetply:Nick() .. " got your points and bounty instead of you")
    end

    return "gave [white]" .. targetname .. " [yellow]" .. str .. " [white]but also placed a [yellow]" .. str .. " [white]bounty on them! ;fingers;"
end

local function MagicOutcomeBountyAll(ply)
    if (SetPlayerBounty == nil or GetPlayerBounty == nil) then return nil end
    local amount = 1000 + math.Round(ButtonMoneyPrize()/25,-2)
    --with this value, the highest possible bounty it can set everyone to is 25,000. 


    local set = player.GetHumans()
    local whose = "every player's"
    local scatterbots
    local hidingspots = {}

    --bounty only kleiners


    if(math.random(1,5) == 1)then
        set = player.GetBots()
        whose = "every kleiner's"
        if(math.random(1,4) == 1)then
            amount = amount * 3
            scatterbots = true
            hidingspots = navmesh.GetAllNavAreas()
        end
    elseif ( math.random(1,5) == 1)then
        set = player.GetAll()
        whose = "every player and kleiner's"
    end

    for k, v in pairs(set) do
        local add = GetPlayerBounty(v) + amount
        SetPlayerBounty(v, add)
    end

    local msg = "increased "..whose.." bounty by [yellow]" .. string.Comma(amount) .. " points"

    if(scatterbots)then
        for k, v in pairs(set) do
            v:SetPos(table.Random(hidingspots):GetCenter() + Vector(0,0,16))
            --v:Unstick()
        end
        msg = msg .. " [white]and spread them around the map"
    end
    
    

    return msg .. "!;dougie;"
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
    if(math.random(1,4) == 1)then
        decalrange = {14,9,7,7,5,18}
    end

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
        local hint = ""

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

        if (math.random(1, 4) == 1) then
            button.CoolEffectOnly = true
            button:SetColor(Color(255, 240, 0))
        end

        BotSayGlobal("[yellow]A strange flashing button[white] has appeared" .. hint)

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
        npc_manhack = {
            "Manhack", math.random(1, 2), function(ent, button)
                local pos = table.Random(navmesh.Find(button:GetPos() + button:GetUp() * 50, 200, 2000, 2000)):GetRandomPoint()
                ent:SetPos(pos + Vector(0,0,16))
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
    bullet.Num = 50
    bullet.Force = 20000
    bullet.Spread = Vector(1, 1, 0)
    bullet.Attacker = button
    bullet.Damage = 18000
    bullet.Tracer = 1
    bullet.TracerName = "Tracer"
    blame:FireBullets(bullet, true)

    return ""
end

local function MagicOutcomeBFG(ply, button)
    button:EmitSound("weapons/doom3/bfg/bfg_explode" .. math.random(1, 4) .. ".wav", 100, 100)
    local ent = ents.Create("doom3_bfg")
    if(IsValid(ent))then
        ent:SetAngles(button:GetUp():Angle())
        ent:SetPos(button:GetPos() + button:GetUp() * 32)
        ent:SetOwner(button)
        ent:SetDamage(200,100)
        ent:Spawn()
        ent:Activate()
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetVelocity(button:GetUp() * 350)
        end
    end
    return ""
end

local function MagicOutcomeSnap(ply, button)
    if (ply.Fizzle) then
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
        ply:Fizzle(ply ~= victim and ply or button, gaunt)

        return ""
    end
end

local function MagicOutcomeBigSnap(ply, button)
    --if (math.random(1, 2) > 1) then return end
    if (ply.Fizzle ~= nil) then
        local targetply, noun = ButtonTarget(ply, 15)
        targetply:Give("weapon_gauntlet")
        local gaunt = targetply:GetWeapon("weapon_gauntlet")
        --ok i guess fail?
        if (not IsValid(gaunt)) then return end
        targetply:SetHealth(300)
        local bty = GetPlayerBounty(targetply)
        local incb = 100000
        SetPlayerBounty(targetply, bty + incb)
        gaunt:TimerSimple(0.1,function()
        gaunt:GetOwner():GiveAmmo(49, "infinitygauntlet", true)
        end)
        return "[fbc]granted [white]" .. noun .. " [fbc] an extra powerful gauntlet, and a bounty of [white]" .. string.Comma(incb) .. "[fbc] points. ;snap;;thanos;[fbc]"
    end
end

local function MagicOutcomeSoreNeck(ply, button)
    ply:EmitSound("physics/body/body_medium_break" .. math.random(2, 4) .. ".wav")
    local eang = ply:EyeAngles()
    local amount = 15
    if(math.random(1,10)==1)then amount = 180 end

    eang.roll = eang.roll + ((math.random(0, 1) and amount) or -amount)
    ply:SetEyeAngles(eang)
    local bone = ply:LookupBone("ValveBiped.Bip01_Head1") or ply:LookupBone("LRigScull")
    local bang = ply:GetManipulateBoneAngles(bone)
    bang.pitch = -eang.roll
    ply:ManipulateBoneAngles(bone, bang)
    local timername = ply:UserID() .. "neckpainreset"

        timer.Create(timername, 5, 0, function()
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
                    if(eang.roll == 0)then
                        timer.Destroy(timername)
                    end
                end
            end
        end)


    return ""
end

local function MagicOutcomeNothing(ply, button)
    local check = 0
    local randomsound

    while randomsound == nil and check < 100000 do
        check = check + 1
        local checksound = table.Random(sound.GetTable())
        local dat = sound.GetProperties(checksound)
        local snd = istable(dat.sound) and dat.sound[1] or isstring(dat.sound) and dat.sound
        snd = string.TrimLeft(snd, "*")

        if (file.Exists("sound/" .. snd, "GAME")) then
            randomsound = checksound
        end
    end
    ply:ChatPrint(":banana: [yellow]haha here's a cool sound for you, it's called \""..randomsound.."\".")

    button:EmitSound(randomsound, 65, math.Rand(80, 120), nil, nil, nil, 56)
    button.playingsound = randomsound
    button.playedpresssound = true
    button.OverrideDieTime = 30

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
    local made

    for i = 1, num do
        local origin = button:FindSuitableCastOrigin()
        local box = ents.Create("mysterybox") --what is the ent name of the mystery box?

        if (IsValid(box)) then
            box:SetPos(origin)
            box:EmitSound("physics/cardboard/cardboard_box_impact_bullet5.wav")
            box:SetAngles(Angle(0, math.Random(0, 360), 0))
            box:Spawn()
            made = true
        end
    end

    if (made) then return "has hidden [white]" .. num .. " mystery boxes in random spots in the map!" end
end

local function MagicOutcomeSandboxLootbox(ply, button)
    if (SS_Products and SS_Products["sandbox"]) then
        local targetply, noun = ButtonTarget(ply, 25)
        targetply:SS_GivePoints(SS_Products["sandbox"].price)
        SS_Products["sandbox"]:OnBuy(targetply)

        if (targetply ~= ply) then
            ply:ChatPrint(":banana: [yellow]haha " .. targetply:Nick() .. " got a prop lootbox instead of you")
        end

        return ""
    end
end

local function MagicOutcomeWeaponLootbox(ply, button)
    if (SS_Products and SS_Products["csslootbox"]) then
        local targetply, noun = ButtonTarget(ply, 25)
        targetply:SS_GivePoints(SS_Products["csslootbox"].price)
        SS_Products["csslootbox"]:OnBuy(targetply)

        if (targetply ~= ply) then
            ply:ChatPrint(":banana: [yellow]haha " .. targetply:Nick() .. " got a weapon lootbox instead of you")
        end

        return ""
    end
end

local function MagicOutcomeTempModel(ply, button)
    local tempmodels = {}
    local found

    for k, v in pairs(SS_Products) do
        if (v.SS_UniqueModelProduct_CannotBuy) then
            local used

            for _, pv in pairs(player.GetAll()) do
                if pv:GetNWString("uniqmodl") == v:GetName() and pv:Alive() then
                    used = true
                end
            end

            if (not used) then
                table.insert(tempmodels, k)
                found = true
            end
        end
    end

    if (not found) then return end
    local tmpick = table.Random(tempmodels)

    if (SS_Products and SS_Products[tmpick]) then
        local targetply, noun = ButtonTarget(ply, 25)
        SS_Products[tmpick]:OnBuy(targetply)

        if (targetply ~= ply) then
            ply:ChatPrint(":banana: [yellow]haha you just changed " .. targetply:Nick() .. " into " .. SS_Products[tmpick].name)
        end

        return ""
    end
end

--teleport all kleiners to player
local function MagicOutcomeKleinerTeleBot(ply, button)
    local snd = Sound("Airboat.FireGunRevDown")

    if (table.Count(player.GetBots()) > 0) then
        local targetply, noun = ButtonTarget(ply, 25)
        local navmf = navmesh.Find(targetply:GetPos(), 233, 256, 2560)
        if (table.Count(navmf) == 0) then return nil end

        if (targetply ~= ply) then
            ply:ChatPrint(":banana: [yellow]haha you sent every kleiner on the map to " .. targetply:Nick())
        end

        targetply:ChatPrint(":banana: [yellow]haha here have some kleiners")

        for k, v in pairs(player.GetBots()) do
            v:SetPos(table.Random(navmf):GetCenter() + Vector(0, 0, 16))
            v:EmitSound(snd)
        end

        return ""
    end
end

function MagicOutcomeSlowMode(ply,button)
    local val = table.Random({0.1,0.25,0.5,0.75,1.50,2,2.5})

    if(ply.slowscream)then
        ply.slowscream:Stop()
        ply.slowscream = nil
    end

    ply.slowscream = CreateSound( ply, "vo/k_lab/kl_ahhhh.wav" )
    ply.slowscream:ChangePitch(ply:GetLaggedMovementValue() , 0)
    ply.slowscream:Play()
    ply.slowscream:ChangePitch(val*100 , 1)

    ply:SetLaggedMovementValue( val )
    ply:TimerCreate("magicoutcomeslowmode_expire",60,1,function()
    ply:SetLaggedMovementValue(1)
    end)
    ply:ChatPrint(":banana: [yellow]haha your heart rate has changed "..math.Round(val*100).."% of normal for 1 minute" )
    return ""
end

function MagicOutcomeHealth(ply,button)
    ply:SetHealth(table.Random({125,150,150,200,200,500}))
    return ""
end

--yeah i know some of these functions fit in here but it's a pain in the ass to tweak the chances with so much code stuck in the list randomly.
MagicButtonOutcomes = {
    {
        name = "Nothing",
        func = MagicOutcomeNothing,
        uncool = true,
        weight = 19
    },
    {
        name = "MoneyPrize",
        func = MagicOutcomePrize,
        cool = true,
        weight = 6
    },
    {
        name = "Bounty",
        func = MagicOutcomeBounty,
        weight = 6
    },
    {
        name = "BountyAndPrize",
        func = MagicOutcomeBountyAndPrize,
        cool = true,
        weight = 9,
    },
    {
        name = "BountyAll",
        func = MagicOutcomeBountyAll,
        cool = true,
        weight = 4,
    },
    {
        name = "KleinerFanclub",
        func = MagicOutcomeKleinerFanclub,
        weight = 0,
    },
    {
        name = "KleinerTele",
        func = MagicOutcomeKleinerTeleported,
        weight = 0,
    },
    {
        name = "KleinerSlur",
        func = MagicOutcomeKleinerSlur,
        weight = 0,
    },
    {
        name = "Overlay",
        func = MagicOutcomeOverlay,
        weight = 8,
    },
    {
        name = "SpawnObject",
        func = MagicOutcomeSpawnObject,
        weight = 18,
    },
    {
        name = "TeleportRandom",
        func = MagicOutcomeTeleportRandom,
        weight = 17,
    },
    {
        name = "ButtonSpawn",
        func = MagicOutcomeButtonSpawn,
        weight = 20,
    },
    {
        name = "Freeze",
        func = MagicOutcomeFreeze,
        weight = 5,
    },
    {
        name = "Explode",
        func = MagicOutcomeExplode,
        weight = 25,
    },
    {
        name = "Shoot",
        func = MagicOutcomeShoot,
        uncool = true,
        weight = 10,
    },
    {
        name = "BFG",
        func = MagicOutcomeBFG,
        uncool = true,
        weight = 6,
    },
    {
        name = "Snap",
        func = MagicOutcomeSnap,
        weight = 24,
    },
    {
        name = "BigSnap",
        func = MagicOutcomeBigSnap,
        weight = 2,
    },
    {
        name = "Decals",
        func = MagicOutcomeDecals,
        weight = 12,
    },
    {
        name = "PoopCouch",
        func = MagicOutcomePoopCouch,
        weight = 2,
    },
    {
        name = "SoreNeck",
        func = MagicOutcomeSoreNeck,
        uncool = true,
        weight = 7,
    },
    {
        name = "MysteryBox",
        func = MagicOutcomeMysteryBox,
        cool = true,
        weight = 32,
    },
    {
        name = "MysteryBoxSpawn",
        func = MagicOutcomeMysteryBoxSpawn,
        weight = 4,
    },
    {
        name = "SandboxLootbox",
        func = MagicOutcomeSandboxLootbox,
        weight = 2,
    },
    {
        name = "WeaponLootbox",
        func = MagicOutcomeWeaponLootbox,
        weight = 2,
    },
    {
        name = "TempModel",
        func = MagicOutcomeTempModel,
        weight = 15,
    },
    {
        name = "Slow",
        func = MagicOutcomeSlowMode,
        weight = 4,
    },
    {
        name = "HealthBoost",
        func = MagicOutcomeHealth,
        weight = 7,
    },
    {
        name = "KleinerTele_Bots",
        func = MagicOutcomeKleinerTeleBot,
        weight = 5,
    },
}

if(CLIENT)then return end

function MagicButton_SeeChances()
    --super cool code that displays the chances
    print("BUTTON CHANCES =======")
    local total = 0

    for k, v in pairs(MagicButtonOutcomes) do
        total = total + v.weight
    end

    local pointchance = 0
    local lenmax = 0
    local tb = {}

    for k, v in pairs(MagicButtonOutcomes) do
        table.insert(tb, {
            name = v.name,
            chance = v.weight / total
        })

        lenmax = math.max(string.len(v.name), lenmax)
        local name = v.name

        if (name == "MoneyPrize" or name == "BountyAndPrize") then
            pointchance = pointchance + v.weight / total
        end
    end

    table.SortByMember(tb, "chance", false)

    for k, v in pairs(tb) do
        local fnum = string.format("%.2f", math.Round((v.chance) * 100, 2))
        local str = v.name .. string.rep(" ", 4 + lenmax - string.len(v.name))
        local barchar = 50
        str = str .. "[" .. string.rep("█", math.Round(v.chance * barchar, 0)) .. string.rep("░", math.Round((1 - v.chance) * barchar, 0)) .. "]"
        str = str .. "(" .. fnum .. "%)"
        print(str)
    end

    BUTTONSTAT_POINTS_CHANCE = pointchance

    print(total .. " total roll size")

    BtnFindMoneyAverage()

end


function BtnCollectMoneyAverage()
    print("testing average point prize output...")
    local gather = 0
    local staticcount = 0
    local lastav = 0
    local lasttime = os.clock()
    local timesample = 0
    local iter = 0
    local prizepeak = 0
    --we end the test if the average is the same 25,000 times in a row
    local staticlimit = 500000
    while staticcount < staticlimit do
        
        if (math.Rand(0, 1) <= BUTTONSTAT_POINTS_CHANCE) then
            local prize = ButtonMoneyPrize()
            gather = gather + prize
            prizepeak = math.max(prizepeak,prize)
        end
        BUTTONSTAT_MONEYAVERAGE_TESTS = BUTTONSTAT_MONEYAVERAGE_TESTS + 1
        local average = math.Round(gather / BUTTONSTAT_MONEYAVERAGE_TESTS)
        if(lastav == average and BUTTONSTAT_MONEYAVERAGE_TESTS >= 10000)then
            staticcount = staticcount + 1
        else
            staticcount = 0
        end

        lastav = average
        timesample = timesample + (os.clock() - lasttime)
        iter = iter + 1
        if(timesample > 1/300)then
           
            coroutine.yield()
            --print("tested "..iter.. " times...",staticcount,lastav)
            --stop for now and do more next frame
            timesample = 0
            iter = 0
        end
        lasttime = os.clock()

    end
    print("Done!")
    coroutine.yield()
    print("Okay here's the result:")
    coroutine.yield()
    print("I tested point output for "..string.Comma(BUTTONSTAT_MONEYAVERAGE_TESTS).." button presses.")
    print("This test concluded after the average remained the same after "..string.Comma(staticlimit).." presses.")

    coroutine.yield()
    print("Pressing a button will reward on average " .. string.Comma(math.Round(lastav)) .. " points. is this ideal?")
    print("Of all of these tests, the highest prize given out was "..string.Comma(math.Round(prizepeak)).." points.")


    coroutine.yield()
    return "done"
end

function BtnFindMoneyAverage()
    BUTTONSTAT_MONEYAVERAGE_TESTS = 0
    local mproc = coroutine.create(BtnCollectMoneyAverage)
    timer.Create("button_mproc",0,0,function()
    if(mproc)then coroutine.resume(mproc) 
    local stat = coroutine.status(mproc)
    if(stat == "dead")then
        mproc = nil
    end
    end
    end)
    timer.Create("button_mproc2",1,0,function()
        if(mproc)then print("thinking...") end
    end)
end





--MagicButton_SeeChances()