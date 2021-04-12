-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

SS_Tab("Toys","star")

SS_Heading("Free Toys")

PS_WeaponProduct({
    class = "weapon_anonymous",
    name = "Anonymous Mask",
    description = "We are 9GAG. We are Legion.",
    model = "models/v/maskhq.mdl"
})

PS_WeaponProduct({
    class = "weapon_autism",
    name = "Autistic Outbursts",
    description = "HOI WOOWIE",
    model = 'models/props_junk/TrafficCone001a.mdl'
})

PS_WeaponProduct({
    class = "weapon_funnybanana",
    name = "Funny Banana Picture",
    description = "Save the pic, it\'s all yours my friend :)",
    model = 'models/chev/bananaframe.mdl'
})

PS_WeaponProduct({
    class = "weapon_monke",
    name = "Return to Monke",
    description = "Reject modernity, Embrace tradition.",
    model = "models/props/cs_italy/bananna.mdl"
})

PS_WeaponProduct({
    class = "gmod_camera",
    name = "Cringe Compiler",
    description = "*SNAP*",
    model = 'models/MaxOfS2D/camera.mdl'
})

PS_WeaponProduct({
    class = "weapon_encyclopedia",
    name = "Bulletproof Book",
    description = "Hold up this encyclopedia to block incoming bullets, just like that one youtube video.",
    model = "models/props_lab/bindergreen.mdl"
})

PS_WeaponProduct({
    class = "weapon_switch",
    name = "Nintendo Switch",
    description = "Great for photos. Try to contain your excitement!",
    model = "models/swamponions/switchbox.mdl"
})

PS_WeaponProduct({
    class = "weapon_fidget",
    name = "Fidget Spinner",
    description = 'The correct term for a person with a fidget spinner is "helicopter tard".',
    model = 'models/props_workshop/fidget_spinner.mdl'
})

PS_WeaponProduct({
    class = "weapon_flappy",
    name = "Flappy Fedora",
    description = "A dashing rainbow fedora. Tip it (press jump) to take flight.",
    model = 'models/fedora_rainbowdash/fedora_rainbowdash.mdl'
})

PS_WeaponProduct({
    class = "weapon_kleiner",
    name = "Dr. Isaac Kleiner",
    description = "Lamarr, get down from there!",
    model = "models/player/kleiner.mdl"
})

PS_WeaponProduct({
    class = "weapon_spraypaint",
    name = "Spraypaint",
    description = "Deface the server with this handy graffiti tool.",
    model = "models/props_junk/propane_tank001a.mdl"
})

PS_WeaponProduct({
    class = "weapon_vape",
    name = "Mouth Fedora",
    description = "The classy alternative to blazing",
    model = 'models/swamponions/vape.mdl'
})

PS_WeaponProduct({
    class = "weapon_beans",
    name = "Baked Beans",
    description = "For eating in theaters while watching Cars 2.",
    model = "models/noz/beans.mdl",
    extrapreviewgap = 1
})

PS_WeaponProduct({
    class = "weapon_monster",
    name = "Monster Zero",
    description = "*sip* yeap, Quake was a good game",
    model = "models/noz/monsterzero.mdl",
    extrapreviewgap = 2
})

PS_WeaponProduct({
    class = "weapon_shotgun",
    name = "Defense Shotgun",
    description = "Use this free, unlimited ammo shotgun to defend your private theater.",
    model = 'models/weapons/w_shotgun.mdl',
    CanBuyStatus = function(self, v)
        if v:GetTheater() and v:GetTheater():IsPrivate() and v:GetTheater():GetOwner() == v and v:GetTheater()._PermanentOwnerID == nil then
        else
            return PS_BUYSTATUS_PRIVATETHEATER
        end
    end,
    OnBuy = function(self, ply)
        ply.didJustShotgun = 4
        shotguncontrolfunc()
    end
})

SS_Heading("Expensive Toys")

PS_WeaponProduct({
    class = "weapon_airhorn",
    price = 100,
    name = "MLG Airhorn",
    description = "We can still drive memes right into the ground.",
    model = "models/rockyscroll/airhorn/airhorn.mdl"
})

PS_WeaponProduct({
    name = 'Magic Missile',
    description = "Is capable of magically removing Kleiners. Unlimited (but recharging) ammo.",
    price = 2000,
    model = 'models/Effects/combineball.mdl',
    class = 'weapon_magicmissile'
})

-- PS_WeaponProduct({
-- 	name = 'Admin Abuse',
-- 	description = "The physgun. You can pick up and fling around players. If you get killed while you own it, your killer will get 10,000 points.",
-- 	price = 25000,
-- 	model = 'models/weapons/w_physics.mdl',
-- 	class = 'weapon_physgun'
-- })
PS_WeaponProduct({
    name = 'Sandcorn',
    description = "Creates a sandstorm of popcorn. Very obnoxious.",
    price = 12000,
    model = 'models/props_lab/huladoll.mdl',
    class = 'weapon_sandcorn'
})

PS_WeaponProduct({
    name = 'Spamcorn',
    description = "Full-Auto popcorn throwing",
    price = 6000,
    model = 'models/teh_maestro/popcorn.mdl',
    class = 'weapon_popcorn_spam'
})

PS_WeaponProduct({
    name = 'Companion Pillow',
    description = "*boof*",
    price = 1000,
    model = 'models/swamponions/bodypillow.mdl',
    class = 'weapon_bodypillow'
})

PS_WeaponProduct({
    name = 'Police Taser',
    description = "An electroshock weapon capable of paralyzing other players for up to 20 seconds.",
    price = 4000,
    model = 'models/weapons/cg_ocrp2/w_taser.mdl',
    class = 'weapon_taser'
})

PS_WeaponAndAmmoProduct({
    name = 'Laser Pointer',
    description = "Makes a funny dot. Keep away from eyes. Right click for lethal beam. Re-buy for battery refill.",
    price = 500,
    ammotype = "laserpointer",
    model = 'models/brian/laserpointer.mdl',
    class = 'weapon_laserpointer',
    amount = 1000
})

PS_GenericProduct({
    class = 'mystery',
    price = (os.date("%B", os.time()) == "December" and 3000) or 5000, --5000,3000
    name = (os.date("%B", os.time()) == "December" and 'Present') or 'Mystery Box', --'Mystery Box','Present'
    description = "Contains a random weapon or other item.",
    model = (os.date("%B", os.time()) == "December" and 'models/katharsmodels/present/type-2/big/present2.mdl') or 'models/Items/ammocrate_ar2.mdl', --'models/Items/ammocrate_ar2.mdl','models/katharsmodels/present/type-2/big/present2.mdl'
    OnBuy = function(self, ply)
        if ply.cantmakepresent then
            ply:PS_GivePoints(self.price)
            ply:PS_Notify("Cooldown...")

            return
        end

        ply.cantmakepresent = true

        timer.Simple(3, function()
            ply.cantmakepresent = false
        end)

        ply:PS_Notify("Press use (E) to open your crate!")
        local presentCount = 0

        for k, v in pairs(ents.FindByClass("ent_mysterybox")) do
            presentCount = presentCount + 1

            if presentCount > 20 then
                v:Remove()
            end
        end

        local e = ents.Create("ent_mysterybox")
        local pos = ply:GetPos() + (Vector(ply:GetAimVector().x, ply:GetAimVector().y, 0):GetNormalized() * 50) + Vector(0, 0, 10)
        e:SetPos(pos)
        e:SetAngles(Angle(0, math.random(0, 360), 0))
        e:Spawn()
        e:Activate()
    end
})

PS_GenericProduct({
    class = 'wheelchair',
    price = 3000,
    name = 'Wheelchair',
    description = "A treatment for crippling depression. Quickly tap WASD to drive.",
    model = 'models/props_junk/Wheebarrow01a.mdl',
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_wheelchair")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        if tryMakeTrash(ply) then
            e = makeTrashWheelchair(ply, false)
        else
            ply:PS_GivePoints(self.price)
        end
    end
})

PS_GenericProduct({
    class = 'rocketwheelchair',
    price = 10000,
    name = 'Rocket Wheelchair',
    description = "Press shift to boost (WIP)",
    model = 'models/props_junk/Wheebarrow01a.mdl',
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_wheelchair")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        if tryMakeTrash(ply) then
            e = makeTrashWheelchair(ply, true)
            e.FrontWheel:SetColor(Color(255, 0, 0))
            e.BackWheel:SetColor(Color(255, 0, 0))
        else
            ply:PS_GivePoints(self.price)
        end
    end
})

PS_GenericProduct({
    class = 'spacehat',
    price = 5000,
    name = 'Space Helmet',
    description = "Allows you to survive on the moon. Lasts for one life.",
    model = 'models/XQM/Rails/gumball_1.mdl',
    material = 'models/props_combine/portalball001_sheet',
    OnBuy = function(self, ply)
        ply:SetNWBool("spacehat", true)
        ply:PS_Notify("This item lasts for one life!")
    end,
    CanBuyStatus = function(self, ply)
        if ply:GetNWBool("spacehat") then return PS_BUYSTATUS_OWNED end
    end
})

