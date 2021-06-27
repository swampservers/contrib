-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SS_Tab("Weapons", "bomb")

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
    name = 'Throatneck Slitter',
    description = "A deadly knife capable of killing one person before breaking.",
    price = 2000,
    model = 'models/weapons/w_knife_t.mdl',
    class = 'weapon_slitter'
})

SS_WeaponProduct({
    name = '357 Magnum',
    description = "This gun is convenient for shooting and removing props. It takes 2 bullets to kill a player.",
    price = 4000,
    model = 'models/weapons/w_357.mdl',
    class = 'weapon_357'
})

SS_WeaponAndAmmoProduct({
    name = 'Light Machine Gun',
    description = "Crouch for better control",
    ammotype = "lmg",
    amount = 60,
    price = 10000,
    model = 'models/weapons/w_mg42bu.mdl',
    class = 'weapon_spades_lmg'
})

SS_WeaponProduct({
    name = 'Suicide Bombing',
    description = "A powerful suicide bomb attack capable of killing seated players.",
    price = 15000,
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
    amount = 3
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

SS_Heading("Ammo")

SS_AmmoProduct({
    name = 'Crossbow bolt x5',
    price = 1500,
    model = 'models/Items/CrossbowRounds.mdl',
    ammotype = "XBowBolt",
    amount = 5
})

SS_AmmoProduct({
    name = 'SMG Magazine',
    description = "45 rounds",
    price = 1000,
    model = 'models/Items/BoxSRounds.mdl',
    ammotype = "SMG1",
    amount = 45
})

SS_AmmoProduct({
    name = 'Sniper Ammo x 5',
    price = 2500,
    model = 'models/Items/sniper_round_box.mdl',
    ammotype = "sniper",
    amount = 5
})

SS_AmmoProduct({
    name = '357 Ammo x 6',
    price = 500,
    model = 'models/Items/357ammo.mdl',
    ammotype = "357",
    amount = 6
})

SS_AmmoProduct({
    name = 'LMG x 100',
    model = 'models/weapons/w_mg42bu.mdl',
    price = 5000,
    ammotype = "lmg",
    amount = 100
})