function GetMapPropTable()
	local arcadeanglernd = 3
	local arcadexposrnd = 4
	local arcadeyposrnd = 4

    math.randomseed(1337)

	local stuff = {
        --{class="prop_physics",pos=Vector(0,576,0),ang=Angle(0,90,5),model="models/unconid/xmas/xmas_tree.mdl", scale=1.2},

        --{class="prop_physics",pos=Vector(-562, -5264, 0),ang=Angle(0,0,0),model="models/unconid/xmas/xmas_tree.mdl"},
        {class="gmt_instrument_piano",pos=Vector(-2480,-700,0),ang=Angle(0,0,0)},
        {class="gmt_instrument_piano",pos=Vector(500,1680,160),ang=Angle(0,0,0)},
        
        {class="ent_chess_board",pos=Vector(-2340,-600,0),unfrozen=true},
        {class="ent_chess_board",pos=Vector(-2245,-620,0),unfrozen=true},
        {class="ent_draughts_board",pos=Vector(-2150,-640,0),unfrozen=true},
        {class="prop_physics",pos=Vector(-88,1265,2),ang=Angle(0,-90,0),model="models/jigsaw/shits'n'giggles/donald_trump_cutout.mdl",unfrozen=true},
        {class="prop_physics",pos=Vector(158,1752,2),ang=Angle(0,-90,0),model="models/jigsaw/shits'n'giggles/donald_trump_cutout.mdl",unfrozen=true},

        {class="slotmachine",betamt=1000,pos=Vector(1710+math.random(-arcadeyposrnd,arcadeyposrnd),1250+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,0+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=1000,pos=Vector(1710+math.random(-arcadeyposrnd,arcadeyposrnd),1300+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,0+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=1000,pos=Vector(1710+math.random(-arcadeyposrnd,arcadeyposrnd),1350+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,0+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=1000,pos=Vector(1710+math.random(-arcadeyposrnd,arcadeyposrnd),1400+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,0+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=10000,pos=Vector(1710+math.random(-arcadeyposrnd,arcadeyposrnd),1450+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,0+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",pos=Vector(1710+math.random(-arcadeyposrnd,arcadeyposrnd),1200+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,0+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",pos=Vector(1710+math.random(-arcadeyposrnd,arcadeyposrnd),1150+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,0+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",pos=Vector(1710+math.random(-arcadeyposrnd,arcadeyposrnd),1100+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,0+math.random(-arcadeanglernd,arcadeanglernd),0)},
        
    --[[	{class="slotmachine",betamt=1000,pos=Vector(2100+math.random(-arcadeyposrnd,arcadeyposrnd),1260+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,180+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=1000,pos=Vector(2100+math.random(-arcadeyposrnd,arcadeyposrnd),1310+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,180+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=1000,pos=Vector(2100+math.random(-arcadeyposrnd,arcadeyposrnd),1360+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,180+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=1000,pos=Vector(2100+math.random(-arcadeyposrnd,arcadeyposrnd),1410+math.random(-arcadexposrnd,arcadexposrnd),0),ang=Angle(0,180+math.random(-arcadeanglernd,arcadeanglernd),0)}, ]]

        {class="slotmachine",betamt=100000,pos=Vector(1950+math.random(-arcadexposrnd,arcadexposrnd),1500+math.random(-arcadeyposrnd,arcadeyposrnd),0),ang=Angle(0,270+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=100000,pos=Vector(1900+math.random(-arcadexposrnd,arcadexposrnd),1500+math.random(-arcadeyposrnd,arcadeyposrnd),0),ang=Angle(0,270+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=10000,pos=Vector(1850+math.random(-arcadexposrnd,arcadexposrnd),1500+math.random(-arcadeyposrnd,arcadeyposrnd),0),ang=Angle(0,270+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=10000,pos=Vector(1800+math.random(-arcadexposrnd,arcadexposrnd),1500+math.random(-arcadeyposrnd,arcadeyposrnd),0),ang=Angle(0,270+math.random(-arcadeanglernd,arcadeanglernd),0)},
        {class="slotmachine",betamt=1000000,pos=Vector(2000+math.random(-arcadexposrnd,arcadexposrnd),1500+math.random(-arcadeyposrnd,arcadeyposrnd),0),ang=Angle(0,270+math.random(-arcadeanglernd,arcadeanglernd),0)},

        --{class="arcade_doom",pos=Vector(1720,1320,0),ang=Angle(0,0,0)},
	}

    math.randomseed(os.time())
    
    return stuff
end