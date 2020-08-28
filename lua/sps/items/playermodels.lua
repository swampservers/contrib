-- This file is subject to copyright - contact swampservers@gmail.com for more information.

PS_ItemProduct({
	class = "outfitter",
	price = 1000000,
	name = 'SELL-ONLY Outfitter',
	description = "asdfdf",
	model = 'models/player/pyroteknik/banana.mdl',
	invcategory = "Playermodels",
	never_equip = true
})


PS_ItemProduct({
	class = "outfitter2",
	price = 2000000,
	name = 'Outfitter',
	description = "Allows wearing any model from workshop - type !outfitter",
	model = 'models/player/pyroteknik/banana.mdl',
	invcategory = "Playermodels",
	never_equip = true
})

if SERVER then
timer.Create("syncoutfitter", 1, 0, function()
for k,v in pairs(player.GetAll()) do
	if v:GetNWBool("oufitr") ~= v:PS_HasItem("outfitter2") then
		v:SetNWBool("oufitr", v:PS_HasItem("outfitter2"))
	end
end
end)
end

hook.Add("CanOutfit","ps_outfitter",function(ply,mdl,wsid)
	return ply:GetNWBool("oufitr")
end)



PS_ItemProduct({
	class = "inflater",
	price = 200000,
	name = 'Inflater',
	description = "make bones fatter or skeletoner. MULTIPLE CAN STACK",
	model = 'models/Gibs/HGIBS.mdl', --'models/Gibs/HGIBS_rib.mdl',
	material = 'models/debug/debugwhite',
	invcategory = "Mods",
	maxowned = 25,
	bonemod = true,
	configurable = {
		scale = {
			xs={min=0.5,max=1.5},
			ys={min=0.5,max=1.5},
			zs={min=0.5,max=1.5}
		},
		bone = true,
		scale_children = true
	}
})

PS_ItemProduct({
	class = "offsetter",
	price = 100000,
	name = 'Offsetter',
	description = "moves bones around by using advanced genetic modification",
	model = 'models/Gibs/HGIBS_rib.mdl',
	material = 'models/debug/debugwhite',
	invcategory = "Mods",
	maxowned = 25,
	bonemod = true,
	configurable = {
		pos = {
			x={min=-8,max=8},
			y={min=-8,max=8},
			z={min=-8,max=8}
		},
		bone = true
	}
})

PS_PlayermodelItemProduct({
	class = 'crusadermodel',
	price = 300000,
	name = 'Crusader',
	model = 'models/player/crusader.mdl',
	PlayerSetModel = function(self, ply)
		ply:Give("weapon_deusvult")
		ply:SelectWeapon("weapon_deusvult")
	end
})

PS_PlayermodelItemProduct({
	class = 'jokermodel',
	price = 180000,
	name = 'The Joker',
	description = "Now yuo see...",
	model = 'models/player/bobert/aojoker.mdl',
	PlayerSetModel = function(self, ply) end
})

PS_PlayermodelItemProduct({
	class = 'minecraftmodel',
	price = 400064,
	name = 'Block Man',
	description = "A Minecraft player model capable of applying custom skins.",
	model = 'models/milaco/minecraft_pm/minecraft_pm.mdl',
	PlayerSetModel = function(self, ply) end
})

PS_PlayermodelItemProduct({
	class = 'neckbeardmodel',
	price = 240000,
	name = 'Athiest',
	model = 'models/player/neckbeard.mdl',
	PlayerSetModel = function(self, ply)
		ply:Give("weapon_clopper")
		ply:SelectWeapon("weapon_clopper")
	end
})

PS_PlayermodelItemProduct({
	class = 'ogremodel',
	price = 100000,
	name = 'Ogre',
	description = "IT CAME FROM THE SWAMP",
	model = 'models/player/pyroteknik/shrek.mdl',
	PlayerSetModel = function(self, ply)

	end
})

PS_PlayermodelItemProduct({
	class = 'ponymodel',
	price = 500000,
	name = 'Pony',
	description = "*boop*",
	model = 'models/ppm/player_default_base.mdl',
	PlayerSetModel = function(self, ply)
		ply:Give("weapon_squee")
		ply:SelectWeapon("weapon_squee")
	end
})
