PS_GenericProduct({
	class = 'trash',
	name = 'Trash',
	description = "Spawn a random piece of junk for building stuff with",
	model = 'models/props_junk/cardboard_box001b.mdl',
	OnBuy = function(self, ply)
		if tryMakeTrash(ply) then
			e = makeTrash(ply,trashlist[ math.random( 1, #trashlist ) ])
		end
	end
})

PS_GenericProduct({
	class = 'trashfield',
	price = 200,
	name = 'Medium Protection Field',
	description = "While taped, prevents other players from building in your space",
	model = 'models/maxofs2d/hover_classic.mdl',
	OnBuy = function(self, ply)
		for k,v in pairs(ents.FindByClass("prop_trash_field")) do
			if v:GetOwnerID()==ply:SteamID() then
				v:Remove()
			end
		end
		--Delay 1 tick
		timer.Simple(0,function() timer.Simple(0.001,function() 
			if tryMakeTrash(ply) then
				makeForcefield(ply, self.model)
			else
				ply:PS_GivePoints(self.price)
			end
		end) end)
	end
})

PS_GenericProduct({
	class = 'trashfieldlarge',
	price = 3000,
	name = 'Large Protection Field',
	description = "While taped, prevents other players from building in your space",
	model = 'models/dav0r/hoverball.mdl',
	OnBuy = function(self, ply)
		for k,v in pairs(ents.FindByClass("prop_trash_field")) do
			if v:GetOwnerID()==ply:SteamID() then
				v:Remove()
			end
		end
		--Delay 1 tick
		timer.Simple(0,function() timer.Simple(0.001,function() 
			if tryMakeTrash(ply) then
				makeForcefield(ply, self.model)
			else
				ply:PS_GivePoints(self.price)
			end
		end) end)
	end
})

PS_GenericProduct({
	class = 'trashlight',
	price = 2000,
	name = 'Lights',
	description = "Lights up while taped",
	model = 'models/maxofs2d/light_tubular.mdl',
	OnBuy = function(self, ply)
		if tryMakeTrash(ply) then
			local nxt = {}
			for k,v in pairs(trashlist) do
				if PropTrashLightData[v] then
					table.insert(nxt,v)
				end
			end
			e = makeTrash(ply,nxt[ math.random( 1, #nxt ) ])
		else
			ply:PS_GivePoints(self.price)
		end
	end
})

PS_GenericProduct({
	class = 'trashseat',
	price = 2000,
	name = 'Chairs',
	description = "Can be sat on",
	model = 'models/props_c17/furniturechair001a.mdl',
	OnBuy = function(self, ply)
		if tryMakeTrash(ply) then
			local nxt = {}
			for k,v in pairs(trashlist) do
				if ChairOffsets[v] then
					table.insert(nxt,v)
				end
			end
			e = makeTrash(ply,nxt[ math.random( 1, #nxt ) ])
		else
			ply:PS_GivePoints(self.price)
		end
	end
})

PS_GenericProduct({
	class = 'trashtheater',
	price = 8000,
	name = 'Medium Theater Screen',
	description = "Create your own private theater anywhere! You'll remain owner even if you walk away.",
	model = 'models/props_phx/rt_screen.mdl',
	OnBuy = function(self, ply)
		for k,v in pairs(ents.FindByClass("prop_trash_theater")) do
			if v:GetOwnerID()==ply:SteamID() then
				v:Remove()
			end
		end
		--Delay 1 tick
		timer.Simple(0,function() timer.Simple(0.001,function() 
			if tryMakeTrash(ply) then
				makeTrashTheater(ply, self.model)
			else
				ply:PS_GivePoints(self.price)
			end
		end) end)
	end
})

PS_GenericProduct({
	class = 'trashtheatertiny',
	price = 4000,
	name = "Tiny Theater Screen",
	description = "Create your own private theater anywhere! You'll remain owner even if you walk away.",
	model = "models/props_c17/tv_monitor01.mdl",
	OnBuy = function(self, ply)
		for k,v in pairs(ents.FindByClass("prop_trash_theater")) do
			if v:GetOwnerID()==ply:SteamID() then
				v:Remove()
			end
		end
		--Delay 1 tick
		timer.Simple(0,function() timer.Simple(0.001,function() 
			if tryMakeTrash(ply) then
				makeTrashTheater(ply, self.model)
			else
				ply:PS_GivePoints(self.price)
			end
		end) end)
	end
})

PS_GenericProduct({
	class = 'trashtheaterbig',
	price = 16000,
	name = 'Large Theater Screen',
	description = "Create your own private theater anywhere! You'll remain owner even if you walk away.",
	model = "models/hunter/plates/plate1x2.mdl",
	material = "tools/toolsblack",
	OnBuy = function(self, ply)
		for k,v in pairs(ents.FindByClass("prop_trash_theater")) do
			if v:GetOwnerID()==ply:SteamID() then
				v:Remove()
			end
		end
		--Delay 1 tick
		timer.Simple(0,function() timer.Simple(0.001,function() 
			if tryMakeTrash(ply) then
				makeTrashTheater(ply, self.model)
			else
				ply:PS_GivePoints(self.price)
			end
		end) end)
	end
})

PS_WeaponProduct({
	class="weapon_trash_paint",
	name='Paint Tool',
	description = "Paint a solid color onto props. Also changes the color of lights.",
	model='models/props_junk/metal_paintcan001a.mdl',
	price=2000
})

PS_WeaponProduct({
	class="weapon_trash_tape",
	name='Tape Tool',
	description = "Use this to tape (freeze) and un-tape props.",
	model='models/swamponions/ducktape.mdl'
})

