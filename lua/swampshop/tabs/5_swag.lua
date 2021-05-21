-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SS_Tab("Swag", "color_swatch")
SS_Heading("Accessories")

SS_Item({
    class = 'trumphatfree',
    price = 0,
    name = 'Unstumpable',
    description = "Bold, vibrant, and exuberates power, much like Trump himself. Does not show blood.",
    model = 'models/swamponions/colorabletrumphat.mdl',
    color = Vector(1.0, 0.1, 0.1),
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 0.76,
        translate = Vector(-1.5, 0, 2.8),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), -90)
            ang:RotateAroundAxis(ang:Forward(), -20)
            ang:RotateAroundAxis(ang:Right(), 5)
        end),
        pony = {
            scale = 1.0,
            translate = Vector(-4, 0, 13),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), -90)
                ang:RotateAroundAxis(ang:Forward(), -20)
                ang:RotateAroundAxis(ang:Right(), 5)
            end),
        }
    }
})

SS_Item({
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
        translate = Vector(4, -1, 0),
        rotate = Angle(0, -30, 90),
        pony = {
            attach = "right_hand",
            scale = 1,
            translate = Vector(-1, 3, 0),
            rotate = Angle(0, 90, -90),
        }
    }
})

SS_Item({
    class = "bigburger",
    price = 100000,
    name = 'Burger',
    description = "Staple food of the American diet.",
    model = 'models/swamponions/bigburger.mdl',
    maxscale = 1,
    wear = {
        attach = "left_hand",
        scale = 0.25,
        translate = Vector(5, -3.5, 0),
        rotate = Angle(0, -40, -90),
        pony = {
            attach = "lower_body",
            scale = 0.3,
            translate = Vector(-3, -5, 0),
            rotate = Angle(0, 0, 90),
        }
    }
})

SS_Item({
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
        translate = Vector(-3.5, 0, 2),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 1.75,
            translate = Vector(-9, 0, 9),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_Item({
    class = "buckethat",
    price = 10000,
    name = 'Bucket Head',
    description = "Did you get this out of the trash?",
    model = 'models/props_junk/MetalBucket01a.mdl',
    maxscale = 1.2,
    wear = {
        attach = "eyes",
        scale = 0.5,
        translate = Vector(-3.3, -1, 6),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Right(), 180)
            ang:RotateAroundAxis(ang:Up(), 195)
            ang:RotateAroundAxis(ang:Forward(), 10)
        end),
        pony = {
            scale = 0.9,
            translate = Vector(-11.1, -3.5, 15.5),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Right(), 190)
                ang:RotateAroundAxis(ang:Up(), 195)
                ang:RotateAroundAxis(ang:Forward(), 14)
            end),
        }
    }
})

SS_Item({
    class = "combinehelmet",
    price = 150000,
    name = 'Combine Helmet',
    description = "Hide your identity while upholding the law.",
    model = 'models/nova/w_headgear.mdl',
    color = Vector(1,1,1),
    maxscale = 2.7,
    wear = {
        attach = "head",
        scale = 1,
        translate = Vector(0, 0, 0),
        rotate = Angle(0, 0, 0),
        pony = {
            attach = "head",
            scale = 2,
            translate = Vector(0, 0, 0),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_Item({
    class = "conehattest",
    price = 1000,
    name = 'Cone Head',
    description = "You put a traffic cone on your head. Very funny.",
    model = 'models/props_junk/TrafficCone001a.mdl',
    maxscale = 1.0,
    wear = {
        attach = "eyes",
        scale = 0.7,
        translate = Vector(-7, 0, 11),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Right(), 20)
        end),
        pony = {
            scale = 0.7,
            translate = Vector(-7, 0, 22),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Right(), 20)
            end),
        }
    }
})

SS_Item({
    class = "kleinerglasses",
    price = 1000000,
    name = "Kleiner's Glasses",
    description = "Sublime and sophisticated. A must-have piece of Garry's Mod fashion.",
    model = 'models/swamponions/kleiner_glasses.mdl',
    maxscale = 3.0,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-1.5, 0, -0.5),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 2.3,
            translate = Vector(-5.5, 0, 2.5),
            rotate = Angle(0, 0, 0),
            nose = true,
        }
    }
})

SS_Item({
    class = "santahat",
    price = 25000,
    name = 'Christmas Hat',
    --description = "",
    model = 'models/cloud/kn_santahat.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3.8, 0, -3),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), -90)
            ang:RotateAroundAxis(ang:Forward(), 90)
            ang:RotateAroundAxis(ang:Right(), 15)
        end),
        pony = {
            scale = 1.5,
            translate = Vector(-8, 0, 2),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), -90)
                ang:RotateAroundAxis(ang:Forward(), 90)
                ang:RotateAroundAxis(ang:Right(), 15)
            end),
        }
    }
})

SS_Item({
    class = "shrunkenhead",
    price = 150000,
    name = 'Conjoined Twin',
    --description = "",
    model = 'models/Gibs/HGIBS.mdl',
    maxscale = 2.2,
    wear = {
        attach = "eyes",
        scale = 0.6,
        translate = Vector(-3, -4, 0),
        rotate = Angle(0, 0, -20),
        pony = {
            scale = 1,
            translate = Vector(-8, -7, 0),
            rotate = Angle(0, 0, -20),
        }
    }
})

SS_Item({
    class = "spikecollar",
    price = 200000,
    name = 'Spike Collar',
    --description = "",
    model = 'models/oldbill/spike_collar.mdl',
    maxscale = 3.0,
    wear = {
        attach = "neck",
        scale = 1.05,
        translate = Vector(2.5, -2.1, 0),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), 52)
            ang:RotateAroundAxis(ang:Forward(), 90)
        end),
        pony = {
            scale = 1.56,
            translate = Vector(0, -1.25, 0),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), 52)
                ang:RotateAroundAxis(ang:Forward(), 90)
            end),
        }
    }
})

SS_Item({
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
        translate = Vector(-5, 0, 4.8),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Forward(), 180)
            ang:RotateAroundAxis(ang:Right(), -30)
        end),
        pony = {
            scale = 1.75,
            translate = Vector(-11, 0, 14),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Forward(), 180)
                ang:RotateAroundAxis(ang:Right(), -25)
            end),
        }
    }
})

SS_Item({
    class = "trashhattest",
    price = 10000000,
    name = 'Party Hat',
    description = "It's just a paper hat.",
    model = 'models/noz/partyhat3d.mdl',
    color = Vector(0, 0.06, 0.94),
    maxscale = 3.0,
    wear = {
        attach = "eyes",
        scale = 1.1,
        translate = Vector(-3.3, -0.3, 2.5),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), -60)
            ang:RotateAroundAxis(ang:Forward(), 15)
        end),
        pony = {
            scale = 1.6,
            translate = Vector(-6.3, -0.2, 10),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), 40)
                ang:RotateAroundAxis(ang:Forward(), 10)
            end),
        }
    }
})

SS_Item({
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
        translate = Vector(-3.2, 0, 2),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), -90)
        end),
        pony = {
            scale = 1,
            translate = Vector(-5, 0, 9),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), -90)
                ang:RotateAroundAxis(ang:Forward(), -10)
            end),
        }
    }
})

SS_Item({
    class = "pickelhaube",
    price = 250000,
    name = 'Pickelhaube',
    model = 'models/noz/pickelhaube.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1.05,
        translate = Vector(-3.5, .1, 2.3),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Right(), 17)
        end),
        pony = {
            attach = "head",
            scale = 1.8,
            translate = Vector(-4, -9, .3),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), -20)
                ang:RotateAroundAxis(ang:Forward(), 90)
            end),
        }
    }
})

SS_Item({
    class = "horsemask",
    price = 500,
    name = 'Poverty Pony',
    --	description = "It's just a paper hat.",
    model = 'models/horsie/horsiemask.mdl',
    maxscale = 1.85,
    wear = {
        attach = "eyes",
        scale = 1.0,
        translate = Vector(.6, 0, -1),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), 90)
        end),
        pony = {
            scale = 1.85,
            translate = Vector(-2, 0, 2),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), 90)
            end),
        }
    }
})

SS_Item({
    class = 'sombrero',
    price = 30000,
    name = 'Sombrero',
    description = "Worn by criminals, rapists, and good people.",
    model = 'models/swamponions/swampcinema/sombrero.mdl',
    maxscale = 1.5,
    wear = {
        attach = "eyes",
        scale = 0.9,
        translate = Vector(-2.5, 0, 3),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 1.0,
            translate = Vector(-6.5, 0, 11.5),
            rotate = Angle(5, 0, 0),
        }
    }
})

SS_Item({
    class = 'headcrabhat',
    price = 600000,
    name = 'Headcrab',
    description = "Llamar! Get down from there!",
    model = 'models/swamponions/swampcinema/headcrabhat.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 0.8,
        translate = Vector(-2, 0, 3),
        rotate = Angle(0, -90, 10),
        pony = {
            scale = 1.2,
            translate = Vector(-7.5, 0, 11.5),
            rotate = Angle(0, -90, 10),
        }
    }
})

SS_Item({
    class = 'catears',
    price = 1450,
    name = 'Cat Ears',
    description = "Become your favorite neko e-girl gamer!",
    model = 'models/milaco/catears/catears.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1.0,
        translate = Vector(-2.859, 0, -2.922),
        rotate = Angle(0, 90, 0),
        pony = {
            scale = 1.0,
            translate = Vector(-16, 0, -4),
            rotate = Angle(0, 90, 0),
        }
    }
})

SS_Item({
    class = 'uwumask',
    price = 50000,
    name = 'Mask',
    description = "No one cared who I was until I put on the mask.",
    model = 'models/milaco/owomask/owomask.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 0.4,
        translate = Vector(0, 0, -3.665),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 1.025,
            translate = Vector(-12, 0, -2),
            rotate = Angle(10, 0, 0),
        }
    }
})

SS_Item({
    class = 'tophat',
    price = 300000,
    name = 'Top Hat',
    description = "Feel like a sir",
    model = 'models/quattro/tophat/tophat.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1.0,
        translate = Vector(-2, 0, 6),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 1.0,
            translate = Vector(-15.299, 0.008, 16.79),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_Item({
    class = 'swampyhat',
    price = 25000,
    name = 'Krusty Hat',
    description = "Crubsty fcrab beemschugger fri",
    model = 'models/milaco/swampyhat/swampyhat.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1.0,
        translate = Vector(0, 0, 0),
        rotate = Angle(0, -90, 0),
        pony = {
            scale = 1.0,
            translate = Vector(0, 0, 0),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_Item({
    class = "commandercap",
    price = 1933000,
    name = 'Commander Hat',
    description = "Look like a real commander",
    model = 'models/ccap/ccap.mdl',
    color = Vector(0.5, 0, 0),
    maxscale = 1.25,
    wear = {
        attach = "eyes",
        scale = 0.39,
        translate = Vector(-2.2, -0, 4.),
        rotate = Angle(180, 90, 188),
        pony = {
            scale = 0.69,
            translate = Vector(-4.9, -0, 13),
            rotate = Angle(180, 90, 190),
        }
    }
})

SS_Heading("Primitives")

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

for k, v in pairs(primitives) do
    kl = k:lower()

    local itm = {
        class = 'primitive_' .. kl,
        price = v,
        name = k,
        description = "Select these primitives in your inventory and click 'customize' to build more interesting outfits!",
        model = 'models/swamponions/primitives/' .. kl .. '.mdl',
        maxscale = kl == "plane" and 3 or 2.5,
        wear = {
            attach = "eyes",
            scale = kl == "plane" and 1.5 or 2.0,
            translate = kl == "plane" and Vector(2, 0, 0) or Vector(0, 0, 0),
            rotate = kl == "plane" and Angle(90, 0, 0) or Angle(0, 0, 0),
            pony = {
                --copy of above
                scale = kl == "plane" and 1.5 or 2.0,
                translate = kl == "plane" and Vector(2, 0, 0) or Vector(0, 0, 0),
                rotate = kl == "plane" and Angle(90, 0, 0) or Angle(0, 0, 0),
            }
        }
    }

    if kl == "torus" then
        itm.configurable = {
            wear = {
                xs = {
                    max = 10.0
                }
            }
        }
    end

    if kl == "cone" then
        itm.maxscale = 3.0
    end

    if kl == "plane" then
        itm.description = "Two per slot! Lots can be used."
        itm.perslot = 2
    end

    SS_Item(itm)
end
