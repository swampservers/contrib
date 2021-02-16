-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

AddCSLuaFile()

PS_Categories = {
	{
		name="Toys",
		icon="star",
		layout = {
			{
				title = "Free Toys",
				products = {
					"weapon_flappy",
					"weapon_anonymous",
					"weapon_autism",
					"weapon_funnybanana",
					"weapon_monke",
					"gmod_camera",
					"weapon_switch",
					"weapon_encyclopedia",
					"weapon_fidget",
					"weapon_vape",
					"weapon_kleiner",
					"weapon_spraypaint",
					"weapon_beans",
					"weapon_monster"
				}
			},
			{
				title = "Expensive Toys",
				products = {
					"weapon_airhorn",
					"weapon_laserpointer",
					"weapon_bodypillow",
					"weapon_magicmissile",
					"wheelchair",
					"rocketwheelchair",
					"mystery",
					"weapon_taser",
					"spacehat",
					"weapon_popcorn_spam",
					"weapon_sandcorn",
					"weapon_physgun"
				}
			}
		}
	},
	{
		name="Weapons",
		icon="bomb",
		layout = {
			{
				products = {
					"weapon_shotgun",
					"weapon_slitter",
					--"weapon_ar2",
					"weapon_peacekeeper",
					"weapon_357",
					"weapon_smg1",
					"weapon_crossbow",
					"weapon_slam",
					"weapon_sniper",
					"weapon_rpg",
					"weapon_gauntlet",
					"weapon_jihad",
					"weapon_doom3_bfg",
					"weapon_bigbomb"
				}
			},
			{
				title = "Ammo",
				products = {
					"ammo_357_6",
					"ammo_SMG1_45",
					"ammo_XBowBolt_5",
					"ammo_sniper_5",
				}
			}
		}
	},
	{
		name="Construction",
		icon="bricks",
		layout = {
			{	
				title = "Tools",
				products = {
					"weapon_trash_tape",
					"weapon_trash_paint",
				}
			},
			{
				title = "Props",
				products = {
					"trash",
					"trashseat",
					"trashlight",
					"trashfield",
					"trashfieldlarge",
					"trashtheatertiny",
					"trashtheater",
					"trashtheaterbig"
				}
			}
		}
	},

	{
		name="Playermodels",
		icon="user_suit",
		layout = {
			{
				title = "Mods",
				products = {
					"inflater",
					"offsetter"
				}
			},
			{
				title = "Permanent",
				products = {
					"ogremodel",
					"jokermodel",
					"neckbeardmodel",
					"crusadermodel",
					"minecraftmodel",
					"ponymodel",
					"outfitter2"
				}
			},
			{
				title = "One-Life, Unique",
				products = {
					"jokerjoker",
					"celestia",
					"billyherrington",
					"doomguy",
					"fatbastard",
					"fox",
					"garfield",
					"hitler",
					"kermit",
					"kim",
					"luna",
					"minion",
					"moonman",
					"nicestmeme",
					"pepsiman",
					"rick",
					"trump",
					"weeaboo",
					"ketchupdemon"
				}
			}
		}
	},

	{
		name="Swag",
		icon="color_swatch",
		layout = {

			{
				title = "Accessories",
				products = {
					"trumphatfree",
					"horsemask",
					"conehattest",
					"turtleplush",
					"catears",
					"buckethat",
					"santahat",
					"swampyhat",
					"sombrero",
					"tinfoilhat",
					"clownshoe",
					"uwumask",
					"bigburger",
					"bicyclehelmet",
					"shrunkenhead",
					"spikecollar",
					"pickelhaube",
					"tophat",
					"headcrabhat",
					"kleinerglasses",
					"trashhattest" --party hat
				}
			},
			{
				title = "Primitives",
				products = {
					"primitive_plane",
					"primitive_tetrahedron",
					"primitive_angle",
					"primitive_cube",
					"primitive_icosahedron",
					"primitive_dome",
					"primitive_cone",
					"primitive_cylinder",
					"primitive_sphere",
					"primitive_torus"
				}
			}
		}
	},

	{
		name="Upgrades",
		icon="lock_open",
		layout = {
			{
				title = "Accessory Slots",
				products = {
					"accslot_2",
					"accslot_3",
					"accslot_4",
					"accslot_5",
					"accslot_6",
					"accslot_7",
					"accslot_8",
					"accslot_9",
					"accslot_10",
					"accslot_11",
					"accslot_12",
					"accslot_13",
					"accslot_14"
				}
			}
		}
	}
}

PS_InvCategories = {
	"Playermodels",
	"Accessories",
	"Mods",
	"Upgrades",
	"Other"
}
