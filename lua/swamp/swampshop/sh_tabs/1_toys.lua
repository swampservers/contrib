-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SS_Tab("Toys", "star")
SS_Heading("Free Toys")

SS_WeaponProduct({
    class = "weapon_flappy",
    price = 0,
    name = "Flappy Fedora",
    description = "A dashing rainbow fedora. Tip it (press jump) to take flight.",
    model = 'models/fedora_rainbowdash/fedora_rainbowdash.mdl'
})

SS_WeaponProduct({
    class = "weapon_monster",
    price = 0,
    name = "Monster Zero",
    description = "*sip* yeap, Quake was a good game",
    model = "models/noz/monsterzero.mdl",
    extrapreviewgap = 2
})

SS_WeaponProduct({
    class = "weapon_spraypaint",
    price = 0,
    name = "Spraypaint",
    description = "Deface the server with this handy graffiti tool.",
    model = "models/pyroteknik/w_spraypaint.mdl"
})

SS_WeaponProduct({
    class = "weapon_camera",
    price = 0,
    name = "Cringe Compiler",
    description = "*SNAP*",
    model = 'models/MaxOfS2D/camera.mdl'
})

SS_WeaponProduct({
    class = "weapon_vape",
    price = 0,
    name = "Mouth Fedora",
    description = "The classy alternative to blazing",
    model = 'models/swamponions/vape.mdl'
})

SS_WeaponProduct({
    class = "weapon_anonymous",
    price = 0,
    name = "Anonymous Mask",
    description = "We are 9GAG. We are Legion.",
    model = "models/v/maskhq.mdl"
})

SS_WeaponProduct({
    class = "weapon_autism",
    price = 0,
    name = "Autistic Outbursts",
    description = "HOI WOOWIE",
    model = 'models/props_junk/TrafficCone001a.mdl'
})

SS_WeaponProduct({
    class = "weapon_funnybanana",
    price = 0,
    name = "Funny Banana Picture",
    description = "Save the pic, it\'s all yours my friend :)",
    model = 'models/chev/bananaframe.mdl'
})

SS_WeaponProduct({
    class = "weapon_monke",
    price = 0,
    name = "Return to Monke",
    description = "Reject modernity, Embrace tradition.",
    model = "models/props/cs_italy/bananna.mdl"
})

SS_WeaponProduct({
    class = "weapon_encyclopedia",
    price = 0,
    name = "Bulletproof Book",
    description = "Hold up this encyclopedia to block incoming bullets, just like that one youtube video.",
    model = "models/props_lab/bindergreen.mdl"
})

SS_WeaponProduct({
    class = "weapon_switch",
    price = 0,
    name = "Nintendo Switch",
    description = "Great for photos. Try to contain your excitement!",
    model = "models/swamponions/switchbox.mdl"
})

-- models/props_combine/portalball.mdl
-- SS_Product({
--     class = "transmogrifier",
--     price = 0,
--     name = "Transmogrifier",
--     description = "It changes you into a different form... for one life.",
--     model = 'models/props_combine/combine_mine01.mdl',
--     CannotBuy = function(self, ply)
--         if SERVER and ply:CheckRateLimit("transmogrify", 60) then return "Please wait a bit" end
--     end,
--     OnBuy = function(self, ply)
--         if ply:RateLimit("transmogrify", 60) then return end --ply:Notify("Please wait a bit") 
--         local m = SS_ValidRandomPlayermodels[math.random(#SS_ValidRandomPlayermodels)]
--         outfitter.SHNetworkOutfit(ply, m[2], tonumber(m[1]))
--         -- ply:Notify("You have been transformed into "..SS_PrettyMDLName(m[2]))
--         ply:PrintMessage(HUD_PRINTTALK, "You have been transformed into [red]" .. SS_PrettyMDLName(m[2]) .. " ;kleinerfortnite;")
--         ply:SendLua("THIRDPERSON=true timer.Simple(5, function() if THIRDPERSON then chat.AddText('Press F4 to return to first person.') end end)")
--     end
-- })
SS_WeaponProduct({
    class = "weapon_fidget",
    price = 0,
    name = "Fidget Spinner",
    description = 'The correct term for a person with a fidget spinner is "helicopter tard".',
    model = 'models/props_workshop/fidget_spinner.mdl'
})

SS_WeaponProduct({
    class = "weapon_kleiner",
    price = 0,
    name = "Dr. Isaac Kleiner",
    description = "Lamarr, get down from there!",
    model = "models/player/kleiner.mdl"
})

SS_WeaponProduct({
    class = "weapon_beans",
    price = 0,
    name = "Baked Beans",
    description = "For eating in theaters while watching Cars 2.",
    model = "models/noz/beans.mdl",
    extrapreviewgap = 1
})

function ProtectionShotgunAllowed(v)
    return (v:GetTheater() and v:GetTheater():IsPrivate() and v:GetTheater():GetOwner() == v and v:GetTheater()._PermanentOwnerID == nil)
end

SS_WeaponProduct({
    class = "weapon_shotgun",
    price = 0,
    name = "Defense Shotgun",
    description = "Use this free, unlimited ammo shotgun to defend your private theater.",
    model = 'models/weapons/w_shotgun.mdl',
    CannotBuy = function(self, v)
        if not ProtectionShotgunAllowed(v) then return "You must own a private theater to use this." end
    end
})

SS_Heading("Expensive Toys")

SS_WeaponProduct({
    class = "weapon_hamsterball",
    price = 2000,
    name = "Hamster Ball",
    description = "They see me rollin'",
    model = "models/props_phx/ball.mdl"
})

-- material = "models/shadertest/shader3"
SS_WeaponProduct({
    class = "weapon_stencilpaint",
    price = 500,
    name = "Stencil Paint",
    description = "Like the spraypaint, but prints single shapes.",
    model = "models/pyroteknik/w_spraypaint.mdl"
})

SS_WeaponProduct({
    name = 'Companion Pillow',
    description = "*boof*",
    price = 1000,
    model = 'models/swamponions/bodypillow.mdl',
    class = 'weapon_bodypillow'
})

SS_WeaponProduct({
    name = 'Spamcorn',
    description = "Full-Auto popcorn throwing",
    price = 6000,
    model = 'models/teh_maestro/popcorn.mdl',
    class = 'weapon_popcorn_spam'
})

SS_WeaponProduct({
    name = 'Sandcorn',
    description = "Creates a sandstorm of popcorn. Very obnoxious.",
    price = 12000,
    model = 'models/props_lab/huladoll.mdl',
    class = 'weapon_sandcorn'
})

SS_WeaponProduct({
    class = "weapon_airhorn",
    price = 100,
    name = "MLG Airhorn",
    description = "We can still drive memes right into the ground.",
    model = "models/rockyscroll/airhorn/airhorn.mdl"
})

SS_WeaponProduct({
    name = 'Magic Missile',
    description = "Is capable of magically removing Kleiners. Unlimited (but recharging) ammo.",
    price = 2000,
    model = 'models/Effects/combineball.mdl',
    class = 'weapon_magicmissile'
})

-- SS_WeaponProduct({
-- 	name = 'Admin Abuse',
-- 	description = "The physgun. You can pick up and fling around players. If you get killed while you own it, your killer will get 10,000 points.",
-- 	price = 25000,
-- 	model = 'models/weapons/w_physics.mdl',
-- 	class = 'weapon_physgun'
-- })
SS_WeaponProduct({
    name = 'Police Taser',
    description = "An electroshock weapon capable of paralyzing other players for up to 20 seconds.",
    price = 20000,
    model = 'models/weapons/cg_ocrp2/w_taser.mdl',
    class = 'weapon_taser'
})

SS_WeaponAndAmmoProduct({
    name = 'Laser Pointer',
    description = "Makes a funny dot. Keep away from eyes. Right click for lethal beam. Re-buy for battery refill.",
    price = 1000,
    ammotype = "laserpointer",
    amount = 1000,
    model = 'models/brian/laserpointer.mdl',
    class = 'weapon_laserpointer'
})

SS_Product({
    class = 'mystery',
    price = (os.date("%B", os.time()) == "December" and 3000) or 5000, --5000,3000
    name = (os.date("%B", os.time()) == "December" and 'Present') or 'Mystery Box', --'Mystery Box','Present'
    description = "Contains a random weapon or other item.",
    model = (os.date("%B", os.time()) == "December" and 'models/katharsmodels/present/type-2/big/present2.mdl') or 'models/Items/ammocrate_ar2.mdl', --'models/Items/ammocrate_ar2.mdl','models/katharsmodels/present/type-2/big/present2.mdl'
    OnBuy = function(self, ply)
        if ply.cantmakepresent then
            ply:SS_GivePoints(self.price)
            ply:Notify("Cooldown...")

            return
        end

        ply.cantmakepresent = true

        timer.Simple(3, function()
            ply.cantmakepresent = false
        end)

        ply:Notify("Press use (E) to open your crate!")
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

local function CannotBuyTrash(self, ply)
    if SERVER then return CannotMakeTrash(ply) end
end

SS_Product({
    class = 'wheelchair',
    price = 3000,
    name = 'Wheelchair',
    description = "A treatment for crippling depression. Quickly tap WASD to drive.",
    model = 'models/props_junk/Wheebarrow01a.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_wheelchair")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        e = makeTrashWheelchair(ply, false)
    end
})

SS_Product({
    class = 'rocketwheelchair',
    price = 10000,
    name = 'Rocket Wheelchair',
    description = "Press shift to boost (WIP)",
    model = 'models/props_junk/Wheebarrow01a.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_wheelchair")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        e = makeTrashWheelchair(ply, true)
        e.FrontWheel:SetColor(Color(255, 0, 0))
        e.BackWheel:SetColor(Color(255, 0, 0))
    end
})

SS_Product({
    class = 'spacehat',
    price = 5000,
    name = 'Space Helmet',
    description = "Allows you to survive on the moon. Lasts for one life.",
    model = 'models/XQM/Rails/gumball_1.mdl',
    material = 'models/props_combine/portalball001_sheet',
    CannotBuy = function(self, ply)
        if ply:GetNWBool("spacehat") then return SS_CANNOTBUY_OWNED end
    end,
    OnBuy = function(self, ply)
        ply:SetNWBool("spacehat", true)
        ply:Notify("This item lasts for one life!")
    end
})

if CLIENT then
    -- it might be cool to make this piggyback off the shop accessories (ply:GetExtraAccessories...?) and just attach another model?
    hook.Add("PrePlayerDraw", "DrawSpacehat", function(ply)
        if ply:GetNWBool("spacehat", false) and ply:Alive() then
            if not IsValid(SpaceHatCSModel) then
                local prod = SS_Products['spacehat']
                SpaceHatCSModel = ClientsideModel(prod.model, RENDERGROUP_OPAQUE)
                SpaceHatCSModel:SetMaterial(prod.material)
                SpaceHatCSModel:SetNoDraw(true)
            end

            local attach_id = ply:LookupAttachment('eyes')

            if attach_id then
                local attacht = ply:GetAttachment(attach_id)

                if attacht then
                    pos = attacht.Pos
                    ang = attacht.Ang
                    SpaceHatCSModel:SetAngles(ang)

                    if ply:IsPony() then
                        SpaceHatCSModel:SetPos(pos + ang:Up() * 4 + ang:Forward() * -4)
                        SpaceHatCSModel:SetModelScale(1.0)
                    else
                        SpaceHatCSModel:SetPos(pos)
                        SpaceHatCSModel:SetModelScale(0.7)
                    end

                    SpaceHatCSModel:SetupBones()
                    SpaceHatCSModel:DrawModel()
                end
            end
        end
    end)
end

SS_WeaponProduct({
    class = "weapon_pickaxe_diamond",
    price = 10000,
    name = "Diamond Pickaxe",
    description = "Be the coolest kid on the server.",
    model = "models/staticprop/props_mining/pickaxe01.mdl",
    material = "models/props_mining/pickaxe01_diamond"
})
