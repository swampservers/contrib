-- This file is subject to copyright - contact swampservers@gmail.com for more information.
function GetMapPropTable()
    local arcadeanglernd = 3
    local arcadexposrnd = 4
    local arcadeyposrnd = 4
    math.randomseed(1337)

    local stuff = {
                --[[
        {
            class = "prop_physics",
            pos = Vector(724 + 64 * 40, -436 - 1, -2880 + 32 * 40),
            ang = Angle(0, 180, 0),
            model = "models/swamponions/mineslimits.mdl",
            noshadows = true
        },
        ]] --{class="prop_physics",pos=Vector(724+(64*40),-436,-2880+(32*40)),ang=Angle(0,-90,0),model="models/swamponions/mineslimits.mdl",noshadows=true},
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
        {
            class = "prop_dynamic_override",
            model = "models/props_phx/rt_screen.mdl",
            pos = Vector(-2396, -432, 542),
            ang = Angle(0, 90, 0)
        }
    }

    --[[{class="slotmachine",pos=Vector(-2600+math.random(-arcadeyposrnd,arcadeyposrnd),-414+math.random(-arcadexposrnd,arcadexposrnd),480),ang=Angle(0,0+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",pos=Vector(-2600+math.random(-arcadeyposrnd,arcadeyposrnd),-414+math.random(-arcadexposrnd,arcadexposrnd),480),ang=Angle(0,0+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",pos=Vector(-2600+math.random(-arcadeyposrnd,arcadeyposrnd),-414+math.random(-arcadexposrnd,arcadexposrnd),480),ang=Angle(0,0+math.random(-arcadeanglernd,arcadeanglernd),0)},]]
    --[[{class="slotmachine",betamt=1000,pos=Vector(2100+math.random(-arcadeyposrnd,arcadeyposrnd),1260+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,180+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=1000,pos=Vector(2100+math.random(-arcadeyposrnd,arcadeyposrnd),1310+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,180+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=1000,pos=Vector(2100+math.random(-arcadeyposrnd,arcadeyposrnd),1360+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,180+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=1000,pos=Vector(2100+math.random(-arcadeyposrnd,arcadeyposrnd),1410+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,180+math.random(-arcadeanglernd,arcadeanglernd),0)}, ]]
    --{class="arcade_doom",pos=Vector(1720,1320,0),ang=Angle(0,0,0)}, --{class="prop_dynamic",pos=Vector(31, -392, -5),ang=Angle(0,-90,0),model="models/swamponions/dedicationplaque.mdl"}, -- { --     class = "prop_physics", --     pos = Vector(-26.000000, -386.343750, 75.5), --     ang = Angle(7.031, -115.884, 38.408), --     model = "models/swamponions/trumphat.mdl", --     noshadows = true -- },
    if not War then
        table.Add(stuff, {
            {
                class = "pcasino_blackjack_table",
                data = {
                    bet = {
                        default = 1000,
                        iteration = 1000,
                        max = 10000000,
                        min = 100
                    },
                    general = {
                        betPeriod = 15
                    },
                    payout = {
                        blackjack = 2.5,
                        win = 2
                    },
                    turn = {
                        timeout = 30
                    }
                },
                pos = Vector(-2550 + math.random(-arcadeyposrnd, arcadeyposrnd), -280 + math.random(-arcadexposrnd, arcadexposrnd), 481),
                ang = Angle(0, 90 + math.random(-arcadeanglernd, arcadeanglernd), 0)
            },
            {
                class = "pcasino_roulette_table",
                data = {
                    bet = {
                        betLimit = 10000000,
                        default = 1000,
                        iteration = 1000,
                        max = 50000,
                        min = 100
                    },
                    general = {
                        betPeriod = 15
                    }
                },
                pos = Vector(-2700 + math.random(-arcadeyposrnd, arcadeyposrnd), -280 + math.random(-arcadexposrnd, arcadexposrnd), 499),
                ang = Angle(0, 90 + math.random(-arcadeanglernd, arcadeanglernd), 0)
            },
            {
                class = "floppa_npc",
                pos = Vector(-2554, -325, 482),
                ang = Angle(0, 90, 0)
            },
            {
                class = "texasholdem",
                pos = Vector(-2400 + math.random(-arcadeyposrnd, arcadeyposrnd), -280 + math.random(-arcadexposrnd, arcadexposrnd), 480),
                ang = Angle(0, 90 + math.random(-arcadeanglernd, arcadeanglernd), 0)
            },
            {
                class = "texasholdem",
                pos = Vector(-2200 + math.random(-arcadeyposrnd, arcadeyposrnd), 50 + math.random(-arcadexposrnd, arcadexposrnd), 0),
                ang = Angle(0, 270 + math.random(-arcadeanglernd, arcadeanglernd), 0)
            },
            {
                class = "texasholdem",
                pos = Vector(-2400 + math.random(-arcadeyposrnd, arcadeyposrnd), 50 + math.random(-arcadexposrnd, arcadexposrnd), 0),
                ang = Angle(0, 270 + math.random(-arcadeanglernd, arcadeanglernd), 0)
            },
        })
    end

    --IN VAPOR LOUNGE
    for _, side in ipairs({-1, 1}) do
        table.insert(stuff, {
            class = "prop_physics",
            pos = MapTargets["lounge_console"][1]["origin"] + Vector(side * 8, side * 0.1, 0),
            ang = MapTargets["lounge_console"][1]["angles"],
            model = "models/props_combine/breenconsole.mdl",
            noshadows = true
        })
    end

    if os.date("%B", os.time()) == "December" then
        for _, targetInfo in ipairs(MapTargets["xmas_tree"]) do
            table.insert(stuff, {
                class = "prop_physics",
                pos = targetInfo["origin"],
                ang = targetInfo["angles"],
                model = "models/unconid/xmas/xmas_tree.mdl",
                scale = targetInfo["modelscale"]
            })
        end
    end

    math.randomseed(os.time())

    return stuff
end

if MAPPROPS_RERUN then
    CreateTableMapProps()
end

MAPPROPS_RERUN = true

--move this somewhere else
hook.Add("OnEntityCreated", "TripminePositionValidator", function(ent)
    if ent:GetClass() == "npc_tripmine" then
        ent:TimerSimple(0, function()
            if not util.IsInWorld(ent:GetPos()) then
                ent:TakeDamage(1) --more fun than simply removing it
            end
        end)
    end
end)
