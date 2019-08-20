module( "Location", package.seeall )

Debug = true
Map =
{
	{
		Name="Entrance",
		Min = Vector(-512,-256,-16),
		Max = Vector(512,160,352)
	},
	{
		Name="Lobby",
		Min = Vector(-512,160,-16),
		Max = Vector(512,1264,256)
	},
	{
		Name="Concessions",
		Min = Vector(-512,1264,-16),
		Max = Vector(512,1536,128)
	},
	{ --after lobby, concessions
		Name="Restroom",
		Min = Vector(0,1104,-64),
		Max = Vector(640,1792,128)
	},

	{
		Name="Vapor Lounge",
		Min = Vector(-1536,1280,-16),
		Max = Vector(-768,1792,256),
		Filter = function(pos) return pos.y-pos.x > 2192 end
	},
	{ --after vapor lounge
		Name="West Hallway",
		Min = Vector(-1536,1024,-32),
		Max = Vector(-512,1792,160)
	},
	{
		Name="East Hallway",
		Min = Vector(512,512,-16),
		Max = Vector(2048,1024,256)
	},

	{
		Name="Bomb Shelter",
		Min = Vector(-1535,-1936,-128),
		Max = Vector(-1344,-1792,32),
		Theater = {
			Flags = 0,
			Pos = Vector(-1495.8, -1870.5, -43.4),
			Ang = Angle(0, 90, 0),
			Width = 21,
			Height = 11.8125
		}
	},

	{
		Name="Movie Theater",
		Min = Vector(-2560,640,-144),
		Max = Vector(-1536,1664,384),
		Theater = {
			Flags = 2,
			Pos = Vector(-2523.5, 720, 366),
			Ang = Angle(0, 90, 0),
			Width = 864,
			Height = 486,
			Thumb = "m_thumb"
		}
	},
	{
		Name="Public Theater",
		Min = Vector(-1536,0,-144),
		Max = Vector(-512,1024,256),
		Filter = function(pos) return pos.x+pos.y > -1024 end,
		Theater = {
			Flags = 2,
			Pos = Vector(-1035, 48.5, 244),
			Ang = Angle(0, 135, 0),
			Width = 640,
			Height = 360,
			Thumb = "pub_thumb"
		}
	},

	{
		Name="Private Theater 1",
		Min = Vector(512,0,-16),
		Max = Vector(896,512,256),
		Theater = {
			Flags = 3,
			Pos = Vector(640, 481.2, 166),
			Ang = Angle(0, 0, 0),
			Width = 224,
			Height = 126,
			Thumb = "p1_thumb"
		}
	},
	{
		Name="Private Theater 2",
		Min = Vector(896,0,-16),
		Max = Vector(1280,512,256),
		Theater = {
			Flags = 3,
			Pos = Vector(1024, 481.2, 166),
			Ang = Angle(0, 0, 0),
			Width = 224,
			Height = 126,
			Thumb = "p2_thumb"
		}
	},
	{
		Name="Private Theater 3",
		Min = Vector(1280,0,-16),
		Max = Vector(1664,512,256),
		Theater = {
			Flags = 3,
			Pos = Vector(1408, 481.2, 166),
			Ang = Angle(0, 0, 0),
			Width = 224,
			Height = 126,
			Thumb = "p3_thumb"
		}
	},
	{
		Name="Private Theater 4",
		Min = Vector(1664,0,-16),
		Max = Vector(2048,512,256),
		Theater = {
			Flags = 3,
			Pos = Vector(1792, 481.2, 166),
			Ang = Angle(0, 0, 0),
			Width = 224,
			Height = 126,
			Thumb = "p4_thumb"
		}
	},
	{
		Name="Private Theater 5",
		Min = Vector(640,1024,-48),
		Max = Vector(1152,1824,256),
		Theater = {
			Flags = 3,
			Pos = Vector(670.2, 1056, 166),
			Ang = Angle(0, 90, 0),
			Width = 224,
			Height = 126,
			Thumb = "p5_thumb"
		}
	},
	{
		Name="Private Theater 6",
		Min = Vector(1152,1024,-48),
		Max = Vector(1664,1824,256),
		Theater = {
			Flags = 3,
			Pos = Vector(1182.2, 1056, 166),
			Ang = Angle(0, 90, 0),
			Width = 224,
			Height = 126,
			Thumb = "p6_thumb"
		}
	},
	--before upper caverns
	{
		Name="Miner's Hut",
		Min = Vector(5422,561,-1052),
		Max = Vector(5702,1011,-928),
		Theater = {
			Flags = 1,
			Pos = Vector(5549, 982.8, -977),
			Ang = Angle(0, 0, 0),
			Width = 48,
			Height = 27
		}
	},
	{
		Name="Upper Caverns",
		Min = Vector(686,-2048,-1792),
		Max = Vector(6400,3584,-256)
	},
	{
		Name="Lower Caverns",
		Min = Vector(686,-2048,-4096),
		Max = Vector(8000,3584,-1792)
	},
	{
		Name="Kool Kids Klub",
		Min = Vector(2048,256,-16),
		Max = Vector(2704,1024,208),
		Filter = function(pos) return pos.x<2560 or (pos.y >560 and pos.y < 688 and pos.z< 128) end,
		Theater = {
			Flags = 3,
			Pos = Vector(2313.5, 400.3, 82.9),
			Ang = Angle(0, 0, -10),
			Width = 13,
			Height = (13 * (9.0/16.0))
		}
	},
	{
		Name="Arcade",
		Min = Vector(1664,1024,-48),
		Max = Vector(2432,1536,256)
	},

	{
		Name="Back Room",
		Min = Vector(-512,1536,-16),
		Max = Vector(0,1792,128)
	},
	{
		Name="Treatment Room",
		Min = Vector(-512,1280,-144),
		Max = Vector(-256,1536,-16)
	},
	{
		Name="Server Room",
		Min = Vector(-560,1664,-144),
		Max = Vector(-360,1792,-16)
	},
	{ --after server room
		Name="Basement",
		Min = Vector(-512,1536,-144),
		Max = Vector(0,1792,-16)
	},
	{ --after server room
		Name="Bedroom",
		Min = Vector(-768,1536,-160),
		Max = Vector(-512,2176,-32),
		Theater = {
			Flags = 1,
			Pos = Vector(-578.9, 1972, -101),
			Ang = Angle(0, 270, 0),
			Width = 32,
			Height = 18
		}
	},


	{
		Name="Chromozone",
		Min = Vector(-400,860,-304),
		Max = Vector(-210,1100,-128),
		Theater = {
			Flags = 1,
			Pos = Vector(-250, 861, -204),
			Ang = Angle(0, 180, 0),
			Width = 60,
			Height = (60*9/16)
		}
	},
	{ --after chromozone
		Name="Rat's Lair",
		Min = Vector(-220,440,-304),
		Max = Vector(-72,1100,-128)
	},
	{ --after chromozone and rat's lair
		Name="Sewer Theater",
		Min = Vector(-1024,1024,-1024),
		Max = Vector(0,2560,-64),
		Theater = {
			Flags = 2,
			Pos = Vector(-995, 1320.0100097656, -360),
			Ang = Angle(0, 90, 0),
			Width = 676,
			Height = 376,
			AllowItems = true
		}
	},
	{
		Name="Maintenance Room",
		Min = Vector(-1600,-576,-544),
		Max = Vector(-1280,-224,-384),
		Theater = {
			Flags = 0,
			Pos = Vector(-1536.4499511719, -466, -476),
			Ang = Angle(0, 90, 0),
			Width = 52,
			Height = 28
		}
	},


	{
		Name="Moon Base",
		Min = Vector(3776-168,-704-168,11336),
		Max = Vector(3776+168,-704+168,11464),
		Filter = function(pos) return Vector(3776,-704,0):Distance(Vector(pos.x,pos.y,0)) < 168 end,
		Theater = {
			Flags = 0,
			Pos = Vector(3933, -725.2, 11466),
			Ang = Angle(0, 225, 0),
			Width = 192,
			Height = 108
		}
	},

	{
		Name="Office of the Vice President",
		Min = Vector(-2992,-800,-144),
		Max = Vector(-2784,-560,-16)
	},

	{
		Name="Elevator Shaft",
		Min = Vector(-2784,-688,-144),
		Max = Vector(-2576,-560,2048)
	},

	{ --after office of the vice president & elevator shaft
		Name="Trump Lobby",
		Min = Vector(-3008,-1296,-128),
		Max = Vector(-1952,-496,240)
	},

	{
		Name="Church",
		Min = Vector(-2704,-272,-16),
		Max = Vector(-2096,144,176),
		Theater = {
			Flags = 3,
			Pos = Vector(-2687.2, -160, 228),
			Ang = Angle(0, 90, 0),
			Width = 192,
			Height = 108
		}
	},
	
	{
		Name="Crawl Space",
		Min=Vector(-378, -1983, 354),
		Max=Vector(-156, -1862, 421),
		Theater = {
			Flags = 2,
			Pos = Vector(-377.5, -1964, 405),
			Ang = Angle(0, 90, 0),
			Width = 80,
			Height = 45
		}
	},		
	
	
	{
		Name="The Pit",
		Filter = function(pos) return Vector(0,-1152,0):Distance(Vector(pos.x,pos.y,0)) < 650 or pos.y<-1152 end,
		Min = Vector(-650,-1152-650-1000,-128),
		Max = Vector(650,-1152+650,192+400)
		--[[Filter = function(pos) return Vector(0,-1152,0):Distance(Vector(pos.x,pos.y,0)) < 512 end,
		Min = Vector(-512,-1152-512,-128),
		Max = Vector(512,-1152+512,192)]]
	},

	-- 10 "Mobile" theaters are used by prop_trash_theater
	{
		Name="MOBILE",
	},
	{
		Name="MOBILE",
	},
	{
		Name="MOBILE",
	},
	{
		Name="MOBILE",
	},
	{
		Name="MOBILE",
	},
	{
		Name="MOBILE",
	},
	{
		Name="MOBILE",
	},
	{
		Name="MOBILE",
	},
	{
		Name="MOBILE",
	},
	{
		Name="MOBILE",
	},

	{
		Name="AFK Corral",
		Min = Vector(1680,704,-128),
		Max = Vector(4096,4096,256)
	},

	{
		Name="The Underworld",
		Min = Vector(-9648,-1472,-6352),
		Max = Vector(-7840,1100,-5056),
		Theater = {
			Flags = 0,
			Pos = Vector(-8376.2, -296, -5936),
			Ang = Angle(0, 270, 0),
			Width = 256,
			Height = 144
		}
	},

	{ --after church + movie theater
		Name="Bone Zone",
		Min = Vector(-2976,-160,-128),
		Max = Vector(-2368,2048,192)
	},
	{
		Name="Throne Room",
		Min = Vector(-2592,-1280,784),
		Max = Vector(-2144,-976,1072)
	},

	{ --after throne room
		Name="Trump Tower",
		Min = Vector(-3008,-1296,240),
		Max = Vector(-1952,-496,2048),
		Filter = function(pos) return (pos.x+pos.y) > -4080 and (pos.x+pos.y) < -3136 end,
	},
	
	{
		Name="SportZone",
		Min = Vector(1888,-1616,-40),
		Max = Vector(2176,-1376,160)
	},
	{
		Name="Locker Room",
		Min = Vector(1888,-1792,-40),
		Max = Vector(2176,-1616,160)
	},
	{
		Name="Jacuzzi",
		Min = Vector(1888,-2048,-144),
		Max = Vector(2176,-1792,160),
		Theater = {
			Flags = 0,
			Pos = Vector(1896.2, -1968, 88),
			Ang = Angle(0, 90, 0),
			Width = 128,
			Height = 72
		}
	},
	{
		Name="Gym",
		Min = Vector(640,-2048,-40),
		Max = Vector(1888,-1312,288)
	},

	{ --after jacuzzi
		Name="Pool",
		Min = Vector(2178,-2048,-144),
		Max = Vector(2816,-1056,240)
	},

	--after private theaters, pool
	{
		Name="Golf",
		Min = Vector(896,-1056-128,-256),
		Max = Vector(2816,256,128)
	},
	{
		Name="Tree",
		Min = Vector(768-400,-640-400,224),
		Max = Vector(768+400,-640+400,1024)
	},

	{
		Name="Kamp Kleiner",
		Min = Vector(-2665,-1850,-128),
		Max = Vector(-1890,-1349,172)
	},

	{ --after moon base
		Name="Moon",
		Min = Vector(-4000,-6000,10400),
		Max = Vector(8000,4000,16000)
	},

	{ --after everything except sewer tunnels
		Name="Potassium Palace",
		Min = Vector(-1152-512,960-512,-4000),
		Max = Vector(-1152+512,960+512,-144)
	},

    {
		Name="Hell",
		Min = Vector(-1023,4097,0),
        Max = Vector(0,5119,1203) --[[,
        Theater = {
            Flags = 0,
            Pos = Vector(-1021,4433,184),
            Ang = Angle(0,90,0),
            Width = 320,
            Height = 180
        }]]
    },

	{ --after everything except outside
		Name="Sewer Tunnels",
		Min = Vector(-4000,-4000,-4000),
		Max = Vector(4000,4000,-64)
	},
	{ --after everything
		Name="Outside",
		Min = Vector(-4000,-4000,-4000),
		Max = Vector(4000,4000,16000)
	},
	{ --after everything
		Name="Way Outside",
		Min = Vector(-100000,-100000,-100000),
		Max = Vector(100000,100000,100000)
	}

}

--set up and index mobile theaters
MobileLocations = {}
for k, v in pairs(Map) do
	if v.Name == "MOBILE" then
		table.insert(MobileLocations, k)
		v.MobileLocationIndex = #MobileLocations
		v.Name = "MobileTheater"..tostring(v.MobileLocationIndex)
		v.Min = Vector(-1,-1,-10001)
		v.Max = Vector(1,1,-10000)
		v.Theater = {
			Flags = 1,
			Pos = Vector(0,0,0),
			Ang = Angle(0,0,0),
			Width = 32,
			Height = 18
		}
	end
end

function RefreshPositions()
	for k,v in pairs(ents.GetAll()) do
		if v.LastLocationCoords != nil then
			v.LastLocationCoords = nil
		end
	end
end

// returns a table of locations for the specified map, or the current map if nil
function GetLocations()
	return Map
end

// returns the location string of the index
function GetLocationNameByIndex( iIndex )
	local temp = Map[iIndex]
	return temp and temp.Name or "Unknown"
end

// find a location by name
-- note: this can be optimized with a second data structure
function GetLocationIndexByName( strName )
	local locations = GetLocations()
	if !locations then return end
	for k, v in pairs( locations ) do
		if ( v.Name == strName ) then return k end
	end
end

// find a location by index
function GetLocationByIndex( iIndex )
	return Map[iIndex]
end

// find a location by name
-- note: this can be optimized with a second data structure
function GetLocationByName( strName )
	local locations = GetLocations()
	if !locations then return end
	for k, v in pairs( locations ) do
		if ( v.Name == strName ) then return v end
	end
end

// returns the index of the players current location or 0 if unknown
function Find( ply )

	local pos = ply:GetPos()
	
	if ( Map==nil ) then return 0 end
	
	for k, v in next,Map do
		if ( pos:InBox( v.Min, v.Max ) ) then
			if v.Filter then
				if v.Filter(pos) then
					return k
				end
			else
				return k
			end
		end
	end

	return 0
	
end

function GetPlayersInLocation( iIndex )

	local players = {}

	for _, ply in pairs( player.GetAll() ) do
		if ply:GetLocation() == iIndex then
			table.insert( players, ply )
		end
	end

	return players

end
