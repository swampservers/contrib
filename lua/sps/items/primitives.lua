
local primitives = {
	Plane = 10000,
	Tetrahedron = 10000,
	Angle = 15000,
	Cube = 20000,
	Icosahedron = 30000,
	Dome = 40000,
	Cone = 50000,
	Cylinder = 60000,
	Sphere = 80000,
	Torus = 100000
}

for k,v in pairs(primitives) do
	kl = k:lower()
	local itm = {
		class = 'primitive_'..kl,
		price = v,
		name = k,
		description = "Select these primitives in your inventory and click 'customize' to build more interesting outfits!",
		model = 'models/swamponions/primitives/'..kl..'.mdl',
		maxscale = kl=="plane" and 3 or 2.5,
		wear = {
			attach = "eyes",
			scale = kl=="plane" and 1.5 or 2.0,
			translate = kl=="plane" and Vector(2,0,0) or Vector(0,0,0),
			rotate = kl=="plane" and Angle(90,0,0) or Angle(0,0,0),
			pony = {
				--copy of above
				scale = kl=="plane" and 1.5 or 2.0,
				translate = kl=="plane" and Vector(2,0,0) or Vector(0,0,0),
				rotate = kl=="plane" and Angle(90,0,0) or Angle(0,0,0),
			}
		}
	}
	if kl=="torus" then
		itm.configurable = {wear={xs = {max= 10.0}}}
	end
	if kl=="cone" then
		itm.maxscale = 3.0
	end
	PS_ItemProduct(itm)
end