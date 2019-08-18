
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
