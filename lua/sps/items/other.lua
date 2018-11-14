PS_ProductlessItem({
 	class="whiteeyestest",
 	name="white eyes",
 	description="does nothing. sell me.",
 	price=2000000,
 	model="models/error.mdl",
 	material="models/debug/debugwhite",
})

PS_WeaponProduct({
	name = 'Magic Missile',
	description = "Is capable of magically removing Kleiners. Unlimited (but recharging) ammo.",
	price = 2000,
	model = 'models/Effects/combineball.mdl',
	class = 'weapon_magicmissile'
})

PS_WeaponProduct({
	name = 'Admin Abuse',
	description = "The physgun. You can pick up and fling around players. If you get killed while you own it, your killer will get 10,000 points.",
	price = 25000,
	model = 'models/weapons/w_physics.mdl',
	class = 'weapon_physgun'
})

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

PS_GenericProduct({
	class = 'mystery',
	price = 3000, --5000,
	name = 'Present', --'Mystery Box',
	description = "Contains a random weapon or other item.",
	model = 'models/katharsmodels/present/type-2/big/present2.mdl', --'models/Items/ammocrate_ar2.mdl',
	OnBuy = function(self, ply)
		if ply.cantmakepresent then
			ply:PS_GivePoints(self.price)
			ply:PS_Notify("Cooldown...")
			return
		end

		ply.cantmakepresent=true
		timer.Simple(3,function() ply.cantmakepresent=false end)

		ply:PS_Notify("Press use (E) to open your crate!")

		local presentCount = 0
		for k,v in pairs(ents.FindByClass("ent_mysterybox")) do
			presentCount = presentCount+1
			if presentCount > 20 then
				v:Remove()
			end
		end

		local e = ents.Create("ent_mysterybox")
		local pos = ply:GetPos() + (Vector(ply:GetAimVector().x, ply:GetAimVector().y, 0):GetNormalized() * 50) + Vector(0, 0, 10)
		e:SetPos(pos)
		e:SetAngles(Angle(0,math.random(0,360),0))
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
		for k,v in pairs(ents.FindByClass("prop_trash_wheelchair")) do
			if v:GetOwnerID()==ply:SteamID() then
				v:Remove()
			end
		end
		if tryMakeTrash(ply) then
			e = makeTrashWheelchair(ply,false)
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
		for k,v in pairs(ents.FindByClass("prop_trash_wheelchair")) do
			if v:GetOwnerID()==ply:SteamID() then
				v:Remove()
			end
		end
		if tryMakeTrash(ply) then
			e = makeTrashWheelchair(ply,true)
			e.FrontWheel:SetColor(Color(255,0,0))
			e.BackWheel:SetColor(Color(255,0,0))
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
		ply:SetNWBool("spacehat",true)
		ply:PS_Notify("This item lasts for one life!")
	end,
	CanBuyStatus=function(self,ply)
		if ply:GetNWBool("spacehat") then
			return PS_BUYSTATUS_OWNED
		end
	end
})
