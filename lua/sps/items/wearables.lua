
PS_ItemProduct({
	class = 'trumphatfree',
	name = 'Unstumpable',
	description = "Daring, vibrant, and exuberates power, much like Trump himself. Does not show blood.",
	model = 'models/swamponions/colorabletrumphat.mdl',
	color = Vector(1.0, 0.1, 0.1),
	maxscale = 2.0,
	wear = {
		attach = "eyes",
		scale = 0.76,
		translate = Vector(-1.5,0,2.8),
		rotate = PS_AngleGen(function(ang) 
			ang:RotateAroundAxis(ang:Up(), -90)
			ang:RotateAroundAxis(ang:Forward(), -20)
			ang:RotateAroundAxis(ang:Right(), 5)
		end),
		pony = {
			scale = 1.0,
			translate = Vector(-4,0,13),
			rotate = PS_AngleGen(function(ang) 
				ang:RotateAroundAxis(ang:Up(), -90)
				ang:RotateAroundAxis(ang:Forward(), -20)
				ang:RotateAroundAxis(ang:Right(), 5)
			end),
		}
	}
})

PS_ItemProduct({
	class = "clownshoe",
	price = 50000,
	name = 'Clown Shoe',
	description = "Goofy clown shoe! Yes, just the one.",
	model = 'models/rockyscroll/clownshoes.mdl',
	color = Vector(0.8, 0.1, 0.1),
	maxscale = 1.8,
	wear = {
		attach = "right_foot",
		scale = 1,
		translate = Vector(4,-1,0),
		rotate = Angle(0,-30,90),
		pony = {
			attach = "right_hand",
			scale = 1,
			translate = Vector(-1,3,0),
			rotate = Angle(0,90,-90),
		}
	}
})

PS_ItemProduct({
	class = "bigburger",
	price = 100000,
	name = 'Burger',
	description = "Staple food of the American diet.",
	model = 'models/swamponions/bigburger.mdl',
	maxscale = 1,
	wear = {
		attach = "left_hand",
		scale = 0.25,
		translate = Vector(5,-3.5,0),
		rotate = Angle(0,-40,-90),
		pony = {
			attach = "lower_body",
			scale = 0.3,
			translate = Vector(-3,-5,0),
			rotate = Angle(0,0,90),
		}
	}
})

PS_ItemProduct({
	class = "bicyclehelmet",
	price = 120000,
	name = 'Safety Helmet',
	description = "Protection from all threats: internal, external, or autismal.",
	model = 'models/swamponions/bicycle_helmet.mdl',
	color = Vector(0.2, 0.3, 1.0),
	maxscale = 2.0,
	wear = {
		attach = "eyes",
		scale = 1,
		translate = Vector(-3.5,0,2),
		rotate = Angle(0,0,0),
		pony = {
			scale = 1.75,
			translate = Vector(-9,0,9),
			rotate = Angle(0,0,0),
		}
	}
})

PS_ItemProduct({
	class = "buckethat",
	price = 10000,
	name = 'Bucket Head',
	description = "Did you get this out of the trash?",
	model = 'models/props_junk/MetalBucket01a.mdl',
	maxscale = 1.2,
	wear = {
		attach = "eyes",
		scale = 0.5,
		translate = Vector(-3.3,-1,6),
		rotate = PS_AngleGen(function(ang) 
			ang:RotateAroundAxis(ang:Right(), 180)
			ang:RotateAroundAxis(ang:Up(), 195)
			ang:RotateAroundAxis(ang:Forward(), 10)
		end),
		pony = {
			scale = 0.9,
			translate = Vector(-11.1,-3.5,15.5),
			rotate = PS_AngleGen(function(ang) 
				ang:RotateAroundAxis(ang:Right(), 190)
				ang:RotateAroundAxis(ang:Up(), 195)
				ang:RotateAroundAxis(ang:Forward(), 14)
			end),
		}
	}
})

PS_ItemProduct({
	class = "conehattest",
	price = 1000,
	name = 'Cone Head',
	description = "You put a traffic cone on your head. Very funny.",
	model = 'models/props_junk/TrafficCone001a.mdl',
	maxscale = 1.0,
	wear = {
		attach = "eyes",
		scale = 0.7,
		translate = Vector(-7,0,11),
		rotate = PS_AngleGen(function(ang) 
			ang:RotateAroundAxis(ang:Right(), 20)
		end),
		pony = {
			scale = 0.7,
			translate = Vector(-7,0,22),
			rotate = PS_AngleGen(function(ang) 
				ang:RotateAroundAxis(ang:Right(), 20)
			end),
		}
	}
})

PS_ItemProduct({
	class = "kleinerglasses",
	price = 1000000,
	name = "Kleiner's Glasses",
	description = "Sublime and sophisticated. A must-have piece of Garry's Mod fashion.",
	model = 'models/swamponions/kleiner_glasses.mdl',
	maxscale = 3.0,
	wear = {
		attach = "eyes",
		scale = 1,
		translate = Vector(-1.5,0,-0.5),
		rotate = Angle(0,0,0),
		pony = {
			scale = 2.3,
			translate = Vector(-5.5,0,2.5),
			rotate = Angle(0,0,0),
			nose = true,
		}
	}
})

PS_ItemProduct({
	class = "santahat",
	price = 25000,
	name = 'Christmas Hat',
	--description = "",
	model = 'models/cloud/kn_santahat.mdl',
	maxscale = 2.0,
	wear = {
		attach = "eyes",
		scale = 1,
		translate = Vector(-3.8,0,-3),
		rotate = PS_AngleGen(function(ang) 
			ang:RotateAroundAxis(ang:Up(), -90)
			ang:RotateAroundAxis(ang:Forward(), 90)
			ang:RotateAroundAxis(ang:Right(), 15)
		end),
		pony = {
			scale = 1.5,
			translate = Vector(-8,0,2),
			rotate = PS_AngleGen(function(ang) 
				ang:RotateAroundAxis(ang:Up(), -90)
				ang:RotateAroundAxis(ang:Forward(), 90)
				ang:RotateAroundAxis(ang:Right(), 15)
			end),
		}
	}
})

PS_ItemProduct({
	class = "shrunkenhead",
	price = 150000,
	name = 'Conjoined Twin',
	--description = "",
	model = 'models/Gibs/HGIBS.mdl',
	maxscale = 2.2,
	wear = {
		attach = "eyes",
		scale = 0.6,
		translate = Vector(-3,-4,0),
		rotate = Angle(0,0,-20),
		pony = {
			scale = 1,
			translate = Vector(-8,-7,0),
			rotate = Angle(0,0,-20),
		}
	}
})

PS_ItemProduct({
	class = "spikecollar",
	price = 200000,
	name = 'Spike Collar',
	--description = "",
	model = 'models/oldbill/spike_collar.mdl',
	maxscale = 3.0,
	wear = {
		attach = "neck",
		scale = 1.05,
		translate = Vector(2.5,-2.1,0),
		rotate = PS_AngleGen(function(ang) 
			ang:RotateAroundAxis(ang:Up(), 52)
			ang:RotateAroundAxis(ang:Forward(), 90)
		end),
		pony = {
			scale = 1.56,
			translate = Vector(0,-1.25,0),
			rotate = PS_AngleGen(function(ang) 
				ang:RotateAroundAxis(ang:Up(), 52)
				ang:RotateAroundAxis(ang:Forward(), 90)
			end),
		}
	}
})

PS_ItemProduct({
	class = "tinfoilhat",
	price = 40000,
	name = "InfoWarrior's Hat",
	description = "Block out the globalist's mind control gay-rays with this fashionable foil headgear.",
	model = 'models/dav0r/thruster.mdl',
	material = 'models/swamponions/tinfoil',
	maxscale = 2.2,
	wear = {
		attach = "eyes",
		scale = 1,
		translate = Vector(-5,0,4.8),
		rotate = PS_AngleGen(function(ang) 
			ang:RotateAroundAxis(ang:Forward(), 180)
			ang:RotateAroundAxis(ang:Right(), -30)
		end),
		pony = {
			scale = 1.75,
			translate = Vector(-11,0,14),
			rotate = PS_AngleGen(function(ang) 
				ang:RotateAroundAxis(ang:Forward(), 180)
				ang:RotateAroundAxis(ang:Right(), -25)
			end),
		}
	}
})

PS_ItemProduct({
	class = "trashhattest",
	price = 10000000,
	name = 'Party Hat',
	description = "It's just a paper hat.",
	model = 'models/misc/partyhat3d.mdl',
	color = Vector(0,0.06,0.94),
	maxscale = 3.0,
	wear = {
		attach = "eyes",
		scale = 1.1,
		translate = Vector(-3.3,-0.3,2.5),
		rotate = PS_AngleGen(function(ang) 
			ang:RotateAroundAxis(ang:Up(), -60)
			ang:RotateAroundAxis(ang:Forward(), 15)
		end),
		pony = {
			scale = 1.6,
			translate = Vector(-6.3,-0.2,10),
			rotate = PS_AngleGen(function(ang) 
				ang:RotateAroundAxis(ang:Up(), 40)
				ang:RotateAroundAxis(ang:Forward(), 10)
			end),
		}
	}
})


PS_ItemProduct({
	class = "turtleplush",
	price = 1000,
	name = 'Turtle Plush',
--	description = "It's just a paper hat.",
	model = 'models/props/de_tides/Vending_turtle.mdl',
	material = 'plushturtlehat',
	maxscale = 2.0,
	wear = {
		attach = "eyes",
		scale = 1,
		translate = Vector(-3.2,0,2),
		rotate = PS_AngleGen(function(ang) 
			ang:RotateAroundAxis(ang:Up(), -90)
		end),
		pony = {
			scale = 1,
			translate = Vector(-5,0,9),
			rotate = PS_AngleGen(function(ang) 
				ang:RotateAroundAxis(ang:Up(), -90)
				ang:RotateAroundAxis(ang:Forward(), -10)
			end),
		}
	}
})

PS_ItemProduct({
	class = "pickelhaube",
	price = 250000,
	name = 'Pickelhaube',
	model = 'models/misc/pickelhaube.mdl',
	maxscale = 2.0,
	wear = {
		attach = "eyes",
		scale = 1.05,
		translate = Vector(-3.5,.1,2.3),
		rotate = PS_AngleGen(function(ang) 
			ang:RotateAroundAxis(ang:Right(), 17)
		end),
		pony = {
			attach = "head",
			scale = 1.8,
			translate = Vector(-4,-9,.3),
			rotate = PS_AngleGen(function(ang) 
				ang:RotateAroundAxis(ang:Up(), -20)
				ang:RotateAroundAxis(ang:Forward(), 90)
			end),
		}
	}
})

PS_ItemProduct({
	class = "horsemask",
	price = 500,
	name = 'Poverty Pony',
--	description = "It's just a paper hat.",
	model = 'models/horsie/horsiemask.mdl',
	maxscale = 1.85,
	wear = {
		attach = "eyes",
		scale = 1.0,
		translate = Vector(.6,0,-1),
		rotate = PS_AngleGen(function(ang) 
    		ang:RotateAroundAxis(ang:Up(),90)
		end),
		pony = {
			scale = 1.85,
			translate = Vector(-2,0,2),
			rotate = PS_AngleGen(function(ang) 
				ang:RotateAroundAxis(ang:Up(),90)
			end),
		}
	}
})

PS_ItemProduct({
	class = 'sombrero',
	price = 30000,
	name = 'Sombrero',
	description = "Worn by criminals, rapists, and good people.",
	model = 'models/swamponions/swampcinema/sombrero.mdl',
	maxscale = 1.5,
	wear = {
		attach = "eyes",
		scale = 0.9,
		translate = Vector(-2.5,0,3),
		rotate = Angle(0,0,0),
		pony = {
			scale = 1.0,
			translate = Vector(-6.5,0,11.5),
			rotate = Angle(5,0,0),
		}
	}
})

PS_ItemProduct({
	class = 'headcrabhat',
	price = 600000,
	name = 'Headcrab',
	description = "Llamar! Get down from there!",
	model = 'models/swamponions/swampcinema/headcrabhat.mdl',
	maxscale = 2.0,
	wear = {
		attach = "eyes",
		scale = 0.8,
		translate = Vector(-2,0,3),
		rotate = Angle(0,-90,10),
		pony = {
			scale = 1.2,
			translate = Vector(-7.5,0,11.5),
			rotate = Angle(0,-90,10),
		}
	}
})

PS_ItemProduct({
	class = 'catears',
	price = 600000,
	name = 'Cat Ears',
	description = "Become your favorite neko e-girl gamer!",
	model = 'models/milaco/CatEars/CatEars.mdl',
	maxscale = 2.0,
	wear = {
		attach = "eyes",
		scale = 0.8,
		translate = Vector(-2,0,3),
		rotate = Angle(0,-90,10),
		pony = {
			scale = 1.2,
			translate = Vector(-7.5,0,11.5),
			rotate = Angle(0,-90,10),
		}
	}
})
