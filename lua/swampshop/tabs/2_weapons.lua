﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SS_Tab("Weapons", "bomb")

SS_WeaponProduct({
    name = 'Throatneck Slitter',
    description = "A deadly knife capable of killing one person before breaking.",
    price = 2000,
    model = 'models/weapons/w_knife_t.mdl',
    class = 'weapon_slitter'
})

SS_WeaponAndAmmoProduct({
    name = 'Peacekeeper',
    description = "Peacekeeper (Re-buy for more shots)",
    price = 5000,
    model = 'models/weapons/w_sawed-off.mdl',
    class = 'weapon_peacekeeper',
    ammotype = "peaceshot",
    amount = 2
})

SS_WeaponProduct({
    name = 'Crossbow',
    description = "Kills players in one shot, and is capable of hitting distant targets. Also unfreezes props.",
    price = 5000,
    model = 'models/weapons/w_crossbow.mdl',
    class = 'weapon_crossbow'
})

-- SS_WeaponProduct({
--     name = 'Submachine Gun',
--     description = "Effective at killing players at close range, and the ammo is cheap.",
--     price = 5000,
--     model = 'models/weapons/w_smg1.mdl',
--     class = 'weapon_smg1'
-- })
-- SS_WeaponProduct({
--     name = 'Sniper',
--     description = "This powerful rifle kills any player in one shot and has a scope for long distance assassinations. Also unfreezes props.",
--     price = 8000,
--     model = 'models/weapons/w_barrett_m98b.mdl',
--     class = 'weapon_sniper'
-- })
SS_WeaponProduct({
    name = '357 Magnum',
    description = "This gun is convenient for shooting and removing props. It takes 2 bullets to kill a player.",
    price = 4000,
    model = 'models/weapons/w_357.mdl',
    class = 'weapon_357'
})

-- SS_WeaponProduct({
--     name = 'Light Machine Gun',
--     description = "Crouch for better control",
--     price = 12000,
--     model = 'models/weapons/w_mg42bu.mdl',
--     class = 'weapon_spades_lmg'
-- })
SS_WeaponAndAmmoProduct({
    name = 'Big Frickin\' Gun',
    description = "Fires a slow-moving ball, deadly of plasma which kills players in a huge radius.",
    price = 20000,
    ammotype = "doom3_bfg",
    amount = 1,
    model = "models/weapons/doom3/w_bfg.mdl",
    class = 'weapon_doom3_bfg'
})

SS_WeaponProduct({
    name = 'Suicide Bombing',
    description = "A powerful suicide bomb attack capable of killing seated players.",
    price = 16000,
    model = 'models/dav0r/tnt/tnt.mdl',
    class = 'weapon_jihad'
})

SS_WeaponProduct({
    name = 'Big Bomb',
    description = "A large throwable bomb which kills everyone nearby, even seated players.",
    price = 25000,
    model = 'models/dynamite/dynamite.mdl',
    class = 'weapon_bigbomb'
})

SS_WeaponAndAmmoProduct({
    name = 'Infinity Gauntlet',
    description = '*snap*',
    price = 13000,
    model = 'models/swamp/v_infinitygauntlet.mdl',
    ammotype = "infinitygauntlet",
    amount = 1,
    class = 'weapon_gauntlet'
})

-- SS_WeaponAndAmmoProduct({
-- 	name = 'Anti-Kleiner Rifle',
-- 	description = "This specialty weapon is capable of massacring Kleiners, but is harmless to anyone else. Re-purchase for more ammo.",
-- 	price = 2000,
-- 	model = 'models/weapons/w_IRifle.mdl',
-- 	class = 'weapon_ar2',
-- 	ammotype = "AR2",
-- 	amount = 30
-- })
SS_WeaponAndAmmoProduct({
    name = 'S.L.A.M. x3',
    description = "Explosives that can be placed as mines or thrown and detonated.",
    price = 6000,
    model = 'models/weapons/w_slam.mdl',
    class = 'weapon_slam',
    ammotype = "slam",
    amount = 3,
    clip2 = true
})

SS_WeaponAndAmmoProduct({
    name = 'Rocket Launcher',
    description = "Two guided rocket-propelled grenades and a launcher. Re-purchase for more rockets.",
    price = 8000,
    model = 'models/weapons/w_rocket_launcher.mdl',
    class = 'weapon_rpg',
    ammotype = "RPG_Round",
    amount = 2
})

SS_WeaponProduct({
    name = 'Crusader Sword',
    description = "A powerful melee weapon. Powers up after a rapid chain of kills.",
    price = 25000,
    model = 'models/aoc_weapon/w_longsword.mdl',
    class = 'weapon_crusadersword'
})

if SERVER then
    language = language or {}
    language.GetPhrase = function(s) return s:gsub("#Cstrike_WPNHUD_", "") end
end

local weaponspecs = {"rating", "roll_rof", "roll_range", "roll_accuracy", "roll_control", "roll_handling", "roll_mobility"}

SS_WeaponPerkData = {
    -- rating 1
    min = {
        name = "Mexican",
        description = "It's just bad (min all stats)",
        minrating = 1,
        maxrating = 1,
    },
    alwaysjam = {
        name = "Rusted",
        description = "Has to be cycled manually",
        -- the deploy animation for these looks like cycling a round
        weapons = {
            gun_p90 = true,
            gun_fiveseven = true,
            gun_usp = true,
            gun_m4a1 = true,
            gun_glock = true,
            gun_p228 = true,
            gun_mp5navy = true,
            gun_ak47 = true
        },
        minrating = 1,
        maxrating = 1,
    },
    crackedscope = {
        name = "Cracked",
        description = "Scope is cracked - Ooops!",
        weapons = {
            sniper = true,
            autosniper = true,
            gun_aug = true,
            gun_sg552 = true
        },
        minrating = 1,
        maxrating = 1,
    },
    airsoft = {
        name = "Airsoft",
        description = "Not a real gun",
        minrating = 1,
        maxrating = 3
    },
    lessdamage = {
        name = "Less-Lethal",
        description = "Fires less-lethal rubber bullets",
        minrating = 1,
        maxrating = 2
    },
    sometimesjam = {
        name = "Dirty",
        description = "Occasionally jams",
        weapons = {
            gun_p90 = true,
            gun_fiveseven = true,
            gun_usp = true,
            gun_m4a1 = true,
            gun_glock = true,
            gun_p228 = true,
            gun_mp5navy = true,
            gun_ak47 = true
        },
        minrating = 1,
        maxrating = 3,
    },
    unstable = {
        name = "Unstable",
        description = "May explode when fired",
        minrating = 1,
        maxrating = 3,
    },
    smoothbore = {
        name = "Smoothbore",
        description = "Not very accurate",
        minrating = 1,
        maxrating = 3,
    },
    chinese = {
        name = "Chinese",
        description = "Less accurate, but quite cheap",
        minrating = 1,
        maxrating = 4,
    },
    compliant = {
        name = "Libtard-Compliant",
        description = "10 round magazine and semi-auto only",
        weapons = {
            ar = true
        },
        minrating = 2,
        maxrating = 4
    },
    highimpact = {
        name = "High Impact",
        description = "Heavy bullets that hit hard (more camera punch to target)",
        minrating = 4,
        maxrating = 6
    },
    fullauto = {
        name = "Full-Auto",
        description = "Black market full-auto sear installed",
        weapons = {
            pistol = true,
            autosniper = true,
            autoshotgun = true
        },
        minrating = 5,
        maxrating = 6
    },
    lightweight = {
        name = "Lightweight",
        description = "Easier to fire on the move",
        minrating = 5,
        maxrating = 6
    },
    compensated = {
        name = "Compensated",
        description = "Reduced recoil",
        weapons = {
            pistol = true,
            autosniper = true,
            ar = true,
            smg = true
        },
        minrating = 5,
        maxrating = 6
    },
    extended = {
        name = "Extended",
        description = "Extended mags",
        minrating = 5,
        maxrating = 7
    },
    skullpiercing = {
        name = "Skullpiercing",
        description = "More damage to the head",
        weapons = {
            ar = true,
            pistol = true
        },
        minrating = 5,
        maxrating = 7
    },
    slug = {
        name = "Slug",
        description = "Fires devastating slug ammunition",
        weapons = {
            shotgun = true,
            autoshotgun = true
        },
        minrating = 5,
        maxrating = 7
    },
    antikleiner = {
        name = "Anti-Kleiner",
        description = "Kleiner Killer",
        minrating = 7,
        maxrating = 7
    },
    antimaterial = {
        name = "Anti-Material",
        description = "Can damage any prop (AWP instaremoves)",
        minrating = 7,
        maxrating = 8
    },
    selfloading = {
        name = "Self-Loading",
        description = "Semi-automatic firepower",
        weapons = {
            sniper = true
        },
        minrating = 7,
        maxrating = 8
    },
    boomstick = {
        name = "Boomstick",
        description = "Fires way more pellets, but in a wider cone",
        weapons = {
            shotgun = true,
            autoshotgun = true
        },
        minrating = 7,
        maxrating = 8
    },
    moredamage = {
        name = "Armor-Piercing",
        description = "More damage",
        minrating = 7,
        maxrating = 8
    },
    -- antipony = {name="Anti-pony", description="Pony blaster",minrating=7,maxrating=8}, -- antihuman = {name="Anti-human", description="Kleiner Killer",minrating=7,maxrating=8}, --rating 8
    explosiveslug = {
        name = "Explosive Slug",
        description = "Fires explosive slug ammunition",
        weapons = {
            shotgun = true,
            autoshotgun = true
        },
        minrating = 8,
        maxrating = 8
    },
    explosive = {
        name = "Hand Cannon",
        description = "Fires 20mm high explosive rounds",
        weapons = {
            gun_awp = true
        },
        minrating = 8,
        maxrating = 8
    },
    bottomless = {
        name = "Bottomless",
        description = "Never needs to be reloaded (you still have to buy ammo though!)",
        minrating = 8,
        maxrating = 8
    },
    dragon = {
        name = "Dragon's Breath",
        description = "Ignites targets",
        minrating = 8,
        maxrating = 8
    },
    shothose = {
        name = "Death Machine",
        description = "Full auto buckshot hose",
        weapons = {
            autoshotgun = true,
            gun_mac10 = true
        },
        minrating = 8,
        maxrating = 8
    },
    max = {
        name = "Golden",
        description = "Worthy of Trump (max all stats)",
        minrating = 8,
        maxrating = 8
    }
}

SS_Item({
    class = "weapon",
    background = true,
    value = 5000,
    GetDescription = function(self)
        local d = (weapons.GetStored(self.specs.class or "") or {}).Purpose or "" --self.description

        if (self.specs.perk or "") ~= "" then
            local pk = SS_WeaponPerkData[self.specs.perk]

            if pk then
                d = d .. "\nPerk: " .. pk.name .. ": " .. pk.description
            end
        end

        if self.specs.trophy_winner then
            local p = player.GetBySteamID64(self.specs.trophy_winner)
            local n = IsValid(p) and p:GetName() or util.SteamIDFrom64(self.specs.trophy_winner)
            n = self.specs.trophy_winner_name_cache or n
            d = d .. "\n\nGranted to " .. n .. " for their service (#" .. self.specs.trophy_rank .. ")"
        end

        return d
    end,
    GetName = function(self)
        local name = (weapons.GetStored(self.specs.class or "") or {}).PrintName or "Unknown"

        if (self.specs.perk or "") ~= "" then
            name = SS_WeaponPerkData[self.specs.perk].name .. " " .. name
        end

        if self.specs.trophy_tag then
            name = self.specs.trophy_tag .. " " .. name
        end

        return name
    end,
    GetModel = function(self) return (weapons.GetStored(self.specs.class or "") or {}).WorldModel or 'models/error.mdl' end,
    OutlineColor = function(self) return SS_GetRating(self.specs.rating).color end,
    SanitizeSpecs = function(self)
        local specs, ch = self.specs, false

        for i, spec in ipairs(weaponspecs) do
            if not specs[spec] then
                specs[spec] = math.random()
                ch = true
            end
        end

        local r = SS_GetRating(self.specs.rating)
        local cl = self.specs.class

        -- class may not be set yet, dont choose a perk til it is
        if cl then
            local ct = weapons.GetStored(cl) or {}
            local validperks = {}

            for k, v in pairs(SS_WeaponPerkData) do
                if v.minrating <= r.id and r.id <= v.maxrating then
                    if v.weapons == nil or v.weapons[cl] or v.weapons[ct.GunType or ""] then
                        validperks[k] = true
                    end
                end
            end

            if specs.perk and specs.perk ~= "" and validperks[specs.perk] == nil then
                specs.perk = nil
            end

            -- specs.perk=nil
            if specs.perk == nil then
                local r_roll = (self.specs.rating - r.min) / (r.max - r.min)

                -- perks at rank <= 4 are "bad"
                if r.id <= 4 then
                    r_roll = 1 - r_roll
                end

                if r_roll > (1 - SS_WeaponPerkChance[r.id]) then
                    specs.perk = table.Random(table.GetKeys(validperks))

                    -- reroll if non specific perk (todo remove this after a while)
                    if SS_WeaponPerkData[specs.perk].weapons == nil then
                        specs.perk = table.Random(table.GetKeys(validperks))
                    end
                else
                    specs.perk = ""
                end

                ch = true
            end
        end

        if specs.trophy_winner then
            local p = player.GetBySteamID64(specs.trophy_winner)
            local n = IsValid(p) and p:GetName()

            if n and n ~= specs.trophy_winner_name_cache then
                specs.trophy_winner_name_cache = n
                ch = true
            end
        end

        return ch
    end,
    actions = {
        spawnweapon = {
            Text = function(item) return "MAKE (-" .. tostring(item:SpawnPrice()) .. ")" end,
            primary = true,
        }
    },
    SpawnPrice = function(self)
        local swep = weapons.GetStored(self.specs.class or "") or {}
        local perk = GunPerkOverrides(swep, self.specs.perk)

        local baseprice = swep.SpawnPrice or ({
            pistol = 1000,
            heavypistol = 1500,
            smg = 2000,
            shotgun = 2000,
            autoshotgun = 3000,
            ar = 3000,
            autosniper = 4000,
            sniper = 4000,
            lmg = 3000,
        })[swep.GunType] or 10000

        local ratingmod = 1.5 ^ (self.specs.rating - 0.5)

        -- it comes with ammo, add that to the price :^)
        return math.Round(baseprice * (perk.SpawnPriceMod or swep.SpawnPriceMod or 1) * ratingmod, -2) + SS_GunAmmoPrice(self)
    end,
    SellValue = function(self) return 1000 * 2 ^ SS_GetRating(self.specs.rating).id end,
    invcategory = "Weapons",
    never_equip = true
})

-- also used to set ammo purchase options for non-item guns (TODO cleanup)
GUNTYPE_BASE_REFILL_PRICE = {
    pistol = 500,
    heavypistol = 500,
    smg = 1500,
    shotgun = 1500,
    autoshotgun = 1500,
    ar = 2000,
    autosniper = 2500,
    sniper = 2500,
    lmg = 5000,
}

function SS_GunAmmoPrice(item)
    local swep = weapons.GetStored(item.specs.class or "") or {}
    local perk = GunPerkOverrides(swep, item.specs.perk)
    local baseprice = swep.AmmoPrice or GUNTYPE_BASE_REFILL_PRICE[swep.GunType] or 1000
    local ratingmod = 1 --1.5 ^ (item.specs.rating - 0.5)

    return math.Round(baseprice * (perk.AmmoPriceMod or swep.AmmoPriceMod or 1) * ratingmod, -2)
end

SS_Item({
    class = 'knifeskin',
    value = 100000,
    GetName = function(self)
        return (SlitterModels[self.specs.model] or {
            name = "unknown"
        }).name
    end,
    GetDescription = function(self) return "WIP: A skin for the throatneck slitter. Equip to use." end,
    GetModel = function(self) return self.specs.model end,
    SanitizeSpecs = function(self)
        local specs, ch = self.specs, false

        if not specs.model then
            specs.model = table.Random(table.GetKeys(SlitterModels))
            specs.rating = 0.999
            ch = true
        end

        return ch
    end,
    settings = {
        color = {
            max = 5
        },
        imgur = true
    },
    invcategory = "Skins"
})

--NOMINIFY
-- for i, tm in ipairs({"CT", "TERRORIST"}) do
SS_Product({
    class = 'csslootbox',
    background = true,
    price = 100000,
    name = "Gun Blueprint", --tm == "CT" and "Thin Blue Line Box" or "Jihad Box",
    description = "Contains a blueprint for a random gun.\nToo expensive? Try the \"Auctions\" tab!\nNew: knife skins (rare)",
    model = 'models/Items/ammocrate_smg1.mdl',
    Options = function(self)
        local options = {}

        for k, v in ipairs(weapons.GetList()) do
            if v.GunType then
                table.insert(options, v)
            end
        end

        return options
    end,
    GetModel = function(self)
        local options = self:Options()

        return options[(math.floor(SysTime() * 2.5) % #options) + 1].WorldModel
    end,
    OnBuy = function(self, ply)
        local options = self:Options()
        local others = {}

        for i = 1, 15 do
            table.insert(others, options[math.random(#options)].WorldModel)
        end

        local chosen = options[math.random(#options)]
        local rating
        local item = SS_GenerateItem(ply, math.random() > 0.01 and "weapon" or "knifeskin")
        item.specs.class = chosen.ClassName
        item:Sanitize()
        rating = item.specs.rating

        ply:SS_GiveNewItem(item, function(item)
            net.Start("LootBoxAnimation")
            net.WriteUInt(item.id, 32)
            net.WriteTable(others)
            net.Send(ply)
            local w = chosen.ClassName

            timer.Simple(5, function()
                if not IsValid(ply) then return end
                GiveWeaponItem(ply, item)
            end)
        end)
    end
})

SS_Panel(function(parent)
    vgui("DSSAuctionPreview", parent, function(p)
        p:SetCategory("Weapons")
    end)
end)

SS_Heading("To buy ammo, press Undo (default Z)")
-- SS_Heading("You can get a cheaper gun blueprint in 'Auctions'")
-- -- TODO make it show auctions here
-- SS_Product({
--     class = 'cssammo',
--     price = 2000, --5000,3000
--     name = 'CS:S gun magazine',
--     description = "1 mag for CSS gun from mystery box (Free ammo in the shooting range!!)",
--     model = 'models/Items/sniper_round_box.mdl',
--     OnBuy = function(self, ply)
--         local w = ply:GetActiveWeapon()
--         ply:GiveAmmo(w:GetMaxClip1(), w:GetPrimaryAmmoType())
--     end,
--     CanBuyStatus = function(self, ply)
--         local w = ply:GetActiveWeapon()
--         if not IsValid(w) or w.Base ~= "weapon_csbasegun" then return "Equip a CS:S gun (from the lootbox)" end
--     end
-- })
-- SS_AmmoProduct({
--     name = 'Crossbow bolt x5',
--     price = 1500,
--     model = 'models/Items/CrossbowRounds.mdl',
--     ammotype = "XBowBolt",
--     amount = 5
-- })
-- SS_AmmoProduct({
--     name = 'SMG Magazine',
--     description = "45 rounds",
--     price = 1000,
--     model = 'models/Items/BoxSRounds.mdl',
--     ammotype = "SMG1",
--     amount = 45
-- })
-- SS_AmmoProduct({
--     name = 'Sniper Ammo x 5',
--     price = 2500,
--     model = 'models/Items/sniper_round_box.mdl',
--     ammotype = "sniper",
--     amount = 5
-- })
-- SS_AmmoProduct({
--     name = '357 Ammo x 6',
--     price = 500,
--     model = 'models/Items/357ammo.mdl',
--     ammotype = "357",
--     amount = 6
-- })
-- SS_AmmoProduct({
--     name = 'LMG x 100',
--     model = 'models/weapons/w_mg42bu.mdl',
--     price = 5000,
--     ammotype = "lmg",
--     amount = 100
-- })
-- asdf
