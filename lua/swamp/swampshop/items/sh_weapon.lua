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

                if r_roll > 1 - SS_WeaponPerkChance[r.id] then
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
