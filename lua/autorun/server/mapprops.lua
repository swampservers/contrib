-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
function GetMapPropTable()
    local arcadeanglernd = 3
    local arcadexposrnd = 4
    local arcadeyposrnd = 4
    math.randomseed(1337)

    local stuff = {
        {
            class = "gmt_instrument_piano",
            pos = Vector(-2500, -290, 0),
            ang = Angle(0, 0, 0)
        },
        {
            class = "ent_chess_board",
            pos = Vector(-2445, 220, 0)
        },
        {
            class = "ent_chess_board",
            pos = Vector(-2350, 200, 0)
        },
        {
            class = "ent_draughts_board",
            pos = Vector(-2255, 220, 0)
        },
        {
            class = "ent_draughts_board",
            pos = Vector(-2160, 200, 0)
        },
        {
            class = "prop_physics",
            pos = Vector(-88, 1265, 2),
            ang = Angle(0, -90, 0),
            model = "models/jigsaw/shits'n'giggles/donald_trump_cutout.mdl",
            unfrozen = true
        },
        {
            class = "prop_physics",
            pos = Vector(158, 1752, 2),
            ang = Angle(0, -90, 0),
            model = "models/jigsaw/shits'n'giggles/donald_trump_cutout.mdl",
            unfrozen = true
        },
        {
            class = "prop_physics",
            pos = Vector(724 + (64 * 40), -436 - 1, -2880 + (32 * 40)),
            ang = Angle(0, 180, 0),
            model = "models/swamponions/mineslimits.mdl",
            noshadows = true
        },
        --{class="prop_physics",pos=Vector(724+(64*40),-436,-2880+(32*40)),ang=Angle(0,-90,0),model="models/swamponions/mineslimits.mdl",noshadows=true},
        {
            class = "slotmachine",
            betamt = 1000000,
            pos = Vector(-2600 + math.random(-arcadeyposrnd, arcadeyposrnd), -150 + math.random(-arcadexposrnd, arcadexposrnd), 480),
            ang = Angle(0, -90 + math.random(-arcadeanglernd, arcadeanglernd), 0)
        },
        {
            class = "slotmachine",
            betamt = 1000000,
            pos = Vector(-2650 + math.random(-arcadeyposrnd, arcadeyposrnd), -150 + math.random(-arcadexposrnd, arcadexposrnd), 480),
            ang = Angle(0, -90 + math.random(-arcadeanglernd, arcadeanglernd), 0)
        },
        {
            class = "slotmachine",
            betamt = 100000,
            pos = Vector(-2700 + math.random(-arcadeyposrnd, arcadeyposrnd), -150 + math.random(-arcadexposrnd, arcadexposrnd), 480),
            ang = Angle(0, -90 + math.random(-arcadeanglernd, arcadeanglernd), 0)
        },
        {
            class = "slotmachine",
            betamt = 100000,
            pos = Vector(-2750 + math.random(-arcadeyposrnd, arcadeyposrnd), -150 + math.random(-arcadexposrnd, arcadexposrnd), 480),
            ang = Angle(0, -90 + math.random(-arcadeanglernd, arcadeanglernd), 0)
        },
        {
            class = "slotmachine",
            betamt = 10000,
            pos = Vector(-2600 + math.random(-arcadeyposrnd, arcadeyposrnd), -100 + math.random(-arcadexposrnd, arcadexposrnd), 480),
            ang = Angle(0, 90 + math.random(-arcadeanglernd, arcadeanglernd), 0)
        },
        {
            class = "slotmachine",
            betamt = 10000,
            pos = Vector(-2650 + math.random(-arcadeyposrnd, arcadeyposrnd), -100 + math.random(-arcadexposrnd, arcadexposrnd), 480),
            ang = Angle(0, 90 + math.random(-arcadeanglernd, arcadeanglernd), 0)
        },
        {
            class = "slotmachine",
            betamt = 1000,
            pos = Vector(-2700 + math.random(-arcadeyposrnd, arcadeyposrnd), -100 + math.random(-arcadexposrnd, arcadexposrnd), 480),
            ang = Angle(0, 90 + math.random(-arcadeanglernd, arcadeanglernd), 0)
        },
        {
            class = "slotmachine",
            betamt = 1000,
            pos = Vector(-2750 + math.random(-arcadeyposrnd, arcadeyposrnd), -100 + math.random(-arcadexposrnd, arcadexposrnd), 480),
            ang = Angle(0, 90 + math.random(-arcadeanglernd, arcadeanglernd), 0)
        },
        --[[{class="slotmachine",pos=Vector(-2600+math.random(-arcadeyposrnd,arcadeyposrnd),-414+math.random(-arcadexposrnd,arcadexposrnd),480),ang=Angle(0,0+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",pos=Vector(-2600+math.random(-arcadeyposrnd,arcadeyposrnd),-414+math.random(-arcadexposrnd,arcadexposrnd),480),ang=Angle(0,0+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",pos=Vector(-2600+math.random(-arcadeyposrnd,arcadeyposrnd),-414+math.random(-arcadexposrnd,arcadexposrnd),480),ang=Angle(0,0+math.random(-arcadeanglernd,arcadeanglernd),0)},]] --[[{class="slotmachine",betamt=1000,pos=Vector(2100+math.random(-arcadeyposrnd,arcadeyposrnd),1260+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,180+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=1000,pos=Vector(2100+math.random(-arcadeyposrnd,arcadeyposrnd),1310+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,180+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=1000,pos=Vector(2100+math.random(-arcadeyposrnd,arcadeyposrnd),1360+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,180+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=1000,pos=Vector(2100+math.random(-arcadeyposrnd,arcadeyposrnd),1410+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,180+math.random(-arcadeanglernd,arcadeanglernd),0)}, ]] --{class="arcade_doom",pos=Vector(1720,1320,0),ang=Angle(0,0,0)}, --{class="prop_dynamic",pos=Vector(31, -392, -5),ang=Angle(0,-90,0),model="models/swamponions/dedicationplaque.mdl"},
        {
            class = "prop_physics",
            pos = Vector(-26.000000, -386.343750, 75.5),
            ang = Angle(7.031, -115.884, 38.408),
            model = "models/swamponions/trumphat.mdl",
            noshadows = true
        }
    }

    for _,side in ipairs({-1,1}) do
        for z =0,2 do
            table.insert(stuff, {
                class = "prop_physics",
                pos = Vector(2304 + side*245, 280, 80 + z*55),
                ang = Angle(0,-90-side*5,side*90),
                model = "models/sunabouzu/speaker.mdl",
                noshadows = true
            })
        end

        table.insert(stuff, {
            class = "prop_physics",
            pos = Vector(2304 + side*8, 530 + side*0.1, 23),
            ang = Angle(0,0,0),
            model = "models/props_combine/breenconsole.mdl",
            noshadows = true
        })    
    end

    --{class="prop_dynamic",pos=Vector(-2720, -1601, 24),ang=Angle(0,0,0),model="models/props_fairgrounds/mic_stand.mdl"}, //temporary
    if os.date("%B", os.time()) == "December" then
        table.insert(stuff, {
            class = "prop_physics",
            pos = Vector(0, 576, 0),
            ang = Angle(0, 90, 5),
            model = "models/unconid/xmas/xmas_tree.mdl",
            scale = 1.2
        })

        table.insert(stuff, {
            class = "prop_physics",
            pos = Vector(-340, -330, 14852),
            ang = Angle(0, 35, 0),
            model = "models/unconid/xmas/xmas_tree.mdl"
        })
    end

    math.randomseed(os.time())

    return stuff
end


if MAPPROPS_RERUN then CreateTableMapProps() end
MAPPROPS_RERUN = true