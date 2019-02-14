
PS_UniqueModelProduct({
	class = 'celestia',
	name = 'Sun Princess',
	model = 'models/mlp/player_celestia.mdl',
	CanBuyStatus = function(self, ply)
		if not ply:PS_HasItem("ponymodel") then
			return PS_BUYSTATUS_PONYONLY
		end
	end
})

PS_UniqueModelProduct({
	class = 'luna',
	name = 'Moon Princess',
	model = 'models/mlp/player_luna.mdl',
	CanBuyStatus = function(self, ply)
		if not ply:PS_HasItem("ponymodel") then
			return PS_BUYSTATUS_PONYONLY
		end
	end
})

PS_UniqueModelProduct({
	class = 'billyherrington',
	name = 'Billy Herrington',
	description = "Rest in peace Billy Herrington, you will be missed.",
	model = 'models/vinrax/player/billy_herrington.mdl'
})

PS_UniqueModelProduct({
	class = 'ketchupdemon',
	name = 'Mortally Challenged',
	description = '"Demon" is an offensive term.',
	model = 'models/momot/momot.mdl'
})

PS_UniqueModelProduct({
	class = 'fatbastard',
	name = 'Fat Bastard',
	model = 'models/obese_male.mdl'
})

PS_UniqueModelProduct({
	class = 'fox',
	name = 'Furball',
	description = "Furries are proof that God has abandoned us.",
	model = 'models/player/ztp_nickwilde.mdl'
})

PS_UniqueModelProduct({
	class = 'garfield',
	name = 'Lasagna Cat',
	description ="I gotta have a good meal.",
	model = 'models/garfield/garfield.mdl'
})

PS_UniqueModelProduct({
	class = 'hitler',
	name = 'Der Fuhrer',
	model = 'models/minson97/hitler/hitler.mdl'
})

PS_UniqueModelProduct({
	class = 'kermit',
	name = 'Frog',
	model = 'models/player/kermit.mdl'
})

PS_UniqueModelProduct({
	class = 'kim',
	name = 'Rocket Man',
	description = "Won't be around much longer.",
	model = 'models/player/hhp227/kim_jong_un.mdl'
})

PS_UniqueModelProduct({
	class = 'minion',
	name = 'Comedy Pill',
	model = 'models/player/minion/minion5/minion5.mdl'
})

PS_UniqueModelProduct({
	class = 'moonman',
	name = 'Mac Tonight',
	model = 'models/player/moonmankkk.mdl'
})

PS_UniqueModelProduct({
	class = 'nicestmeme',
	name = 'Thanks, Lori.',
	description = 'John, haha. Where did you find this one?',
	model = 'models/player/pyroteknik/banana.mdl'
})

PS_UniqueModelProduct({
	class = 'rick',
	name = 'Intellectual',
	description = 'To be fair, you have to have a very high IQ to understand Rick and Morty.',
	model = 'models/player/rick/rick.mdl'
})

PS_UniqueModelProduct({
	class = 'trump',
	name = 'God Emperor',
	description = "Donald J. Trump is the President-for-life of the United States of America, destined savior of Kekistan, and slayer of Hillary the Crooked.",
	model = 'models/omgwtfbbq/the_ship/characters/trump_playermodel.mdl'
})

PS_UniqueModelProduct({
	class = 'weeaboo',
	name = 'Weeaboo Trash',
	description = "Two nukes wasn't enough.",
	model = 'models/tsumugi.mdl'
})
