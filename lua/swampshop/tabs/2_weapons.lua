-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SS_Tab("Weapons", "bomb")

SS_WeaponProduct({
    name = 'Throatneck Slitter',
    description = "A deadly knife capable of killing one person before breaking.",
    price = 2000,
    model = 'models/weapons/w_knife_t.mdl',
    class = 'weapon_slitter'
})

SS_WeaponProduct({
    name = 'Crossbow',
    description = "Kills players in one shot, and is capable of hitting distant targets. Also unfreezes props.",
    price = 5000,
    model = 'models/weapons/w_crossbow.mdl',
    class = 'weapon_crossbow'
})

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
    name = 'Submachine Gun',
    description = "Effective at killing players at close range, and the ammo is cheap.",
    price = 5000,
    model = 'models/weapons/w_smg1.mdl',
    class = 'weapon_smg1'
})

SS_WeaponProduct({
    name = 'Sniper',
    description = "This powerful rifle kills any player in one shot and has a scope for long distance assassinations. Also unfreezes props.",
    price = 8000,
    model = 'models/weapons/w_barrett_m98b.mdl',
    class = 'weapon_sniper'
})

SS_WeaponProduct({
    name = '357 Magnum',
    description = "This gun is convenient for shooting and removing props. It takes 2 bullets to kill a player.",
    price = 4000,
    model = 'models/weapons/w_357.mdl',
    class = 'weapon_357'
})

SS_WeaponProduct({
    name = 'Light Machine Gun',
    description = "Crouch for better control",
    price = 12000,
    model = 'models/weapons/w_mg42bu.mdl',
    class = 'weapon_spades_lmg'
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

SS_WeaponAndAmmoProduct({
    name = 'Peacekeeper',
    description = "Peacekeeper (Re-buy for more shots)",
    price = 5000,
    model = 'models/weapons/w_sawed-off.mdl',
    class = 'weapon_peacekeeper',
    ammotype = "peaceshot",
    amount = 2
})

if SERVER then
    language = language or {}
    language.GetPhrase = function(s) return s:gsub("#Cstrike_WPNHUD_", "") end
end

SS_WeaponPerkData = {
    -- rating 1
    min = {"Scuffed", "It's just bad (min all stats)"},
    rusted = {"Rusted", "Gets jammed after every shot"},
    cracked = {"Cracked", "Ooops! (crack on scope when zoomed)"},
    --rating 1-2
    lessdamage = {"Less-lethal", "Fires less-lethal rubber bullets"},
    -- rating 2-4
    compliant = {"Libtard-Compliant", "10 round magazine, semi-auto only, and slow to reload."},
    --rating 5-6
    fullauto = {"Full-Auto", "Black market full-auto sear installed"},
    lightweight = {"Lightweight", "Easier to fire on the move"},
    heavyweight = {"Heavyweight", "Less recoil"},
    --rating 5-7
    extended = {"Extended", "Extended mags"},
    skullpiercing = {"Skullpiercing", "1 headshot kill"},
    highvelocity = {"High-velocity", "Longer damage range"},
    -- rating 5-7
    slug = {"Slug", "Fires devastating slug ammunition"},
    -- rating 7-8
    antimaterial = {"Anti-Material", "Does heavy damage to props (for AWP, instaremove anything)"},
    selfloading = {"Self-Loading", "Semi-automatic firepower (AWP/scout)"},
    boomstick = {"Boomstick", "Fires way more pellets, but in a wider cone"},
    moredamage = {"Armor-piercing", "More damage"},
    antikleiner = {},
    antipony = {},
    antihuman = {},
    --rating 8
    explosiveslug = {"Explosive Slug", "Fires devastating slug ammunition"},
    bottomless = {"Bottomless", "Never needs to be reloaded (you still have to buy ammo though!)"},
    dragon = {"Dragon's Breath", "Ignites targets"},
    max = {"Golden", "Worthy of Trump (max all stats)"}
}

SS_Item({
    class = "weapon",
    value = 5000,
    name = "Weapon",
    description = "STATS ARE WORK IN PROGRESS AND WILL CHANGE",
    model = 'models/maxofs2d/logo_gmod_b.mdl',
    GetDescription = function(self)
        local d = self.description

        if self.specs.trophy_winner then
            local p = player.GetBySteamID64(self.specs.trophy_winner)
            local n = IsValid(p) and p:GetName() or self.specs.trophy_winner
            d = d .. "\n\nGranted to " .. n .. " for their service (#" .. self.specs.trophy_rank .. ")"
        end

        return d
    end,
    GetName = function(self)
        local name = (weapons.GetStored(self:FixClass() or "") or {}).PrintName or "Unknown"

        if self.specs.trophy_tag then
            name = self.specs.trophy_tag .. " " .. name
        end

        return name
    end,
    GetModel = function(self) return (weapons.GetStored(self:FixClass() or "") or {}).WorldModel or 'models/error.mdl' end,
    OutlineColor = function(self) return SS_GetRating(self.specs.rating).color end,
    FixClass = function(self)
        if not self.specs.class then return nil end
        if self.specs.class:StartWith("weapon_") then return self.specs.class:gsub("weapon_", "gun_") end

        return self.specs.class
    end,
    SanitizeSpecs = function(self)
        local specs, ch = self.specs, false

        if not specs.rating then
            specs.rating = math.random()
            ch = true
        end

        local cl = self:FixClass()

        if specs.class ~= cl then
            specs.class = cl
            ch = true
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
        return ({
            pistol = 2000,
            heavypistol = 2500,
            smg = 4000,
            shotgun = 3000,
            autoshotgun = 4000,
            ar = 4000,
            autosniper = 6000,
            sniper = 5000,
            lmg = 8000,
        })[(weapons.GetStored(self:FixClass() or "") or {}).GunType] or 9999
    end,
    SellValue = function(self) return 500 * 2 ^ SS_GetRating(self.specs.rating).id end,
    invcategory = "Weapons",
    never_equip = true
})

--NOMINIFY
-- for i, tm in ipairs({"CT", "TERRORIST"}) do
SS_Product({
    class = 'csslootbox', --'csslootbox2' .. tm:lower(),
    price = 100000,
    name = "CS:S Gun Blueprint", --tm == "CT" and "Thin Blue Line Box" or "Jihad Box",
    description = "What is Counter-Strike: Source, anyway?",
    model = 'models/Items/ammocrate_smg1.mdl',
    OnBuy = function(self, ply)
        local options = {}

        for k, v in ipairs(weapons.GetList()) do
            if v.GunType then
                -- if v._WeaponInfo.Team == tm then
                --     table.insert(options, v)
                --     table.insert(options, v)
                -- end
                -- if v._WeaponInfo.Team == "ANY" then
                table.insert(options, v)
                -- end
            end
        end

        local others = {}

        for i = 1, 15 do
            table.insert(others, options[math.random(#options)].WorldModel)
        end

        local chosen = options[math.random(#options)]
        local rating
        local item = SS_GenerateItem(ply, "weapon")
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
                if ply:HasWeapon(w) then
                    ply:StripWeapon(w)
                end

                ply:Give(w)
                ply:GetWeapon(w):SetClip1(ply:GetWeapon(w):GetMaxClip1())
                ply:SelectWeapon(w)
            end)
        end)
    end
})

-- end)
-- end
-- hook.Add("Initialize","ss css setup", function()
--     for k, wep in ipairs(weapons.GetList()) do
--         if wep.Base == "weapon_csbasegun" then
--         end
--     end
-- end)
SS_Heading("To buy ammo, press Undo (default Z)")
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
