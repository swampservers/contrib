-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local THEATER_NONE = 0 --default/public theater
local THEATER_PRIVATE = 1 --private theater
local THEATER_REPLICATED = 2 --public theater, shows on the scoreboard
local THEATER_PRIVATEREPLICATED = 3 --private theater, shows on the scoreboard
local WAAB = FindMetaTable("Vector").WithinAABox

Locations = {
    {
        Name = "Entrance",
        Min = Vector(-512, -256, -16),
        Max = Vector(512, 160, 352)
    },
    {
        Name = "Lobby",
        Min = Vector(-512, 160, -16),
        Max = Vector(512, 1264, 256)
    },
    {
        Name = "Concessions",
        Min = Vector(-512, 1264, -16),
        Max = Vector(512, 1536, 128)
    },
    {
        Name = "Restroom",
        Min = Vector(0, 1104, -64),
        Max = Vector(640, 1792, 128)
    },
    --after lobby, concessions
    {
        Name = "Attic",
        Min = Vector(-472, 1344, 152),
        Max = Vector(128, 1504, 192),
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(83, 1491, 178.5),
            Ang = Angle(0, -45, 0),
            Width = 45,
            Height = 25
        }
    },
    --after lobby, concessions
    {
        Name = "Movie Theater",
        Min = Vector(-1776, 1120, -161),
        Max = Vector(-763, 2274, 382),
        Theater = {
            Flags = THEATER_REPLICATED,
            Pos = Vector(-1696, 2250, 366),
            Ang = Angle(0, 0, 0),
            Width = 864,
            Height = 486,
            Thumb = "m_thumb",
            ProtectionTime = 7200,
        },
        Filter = function(pos) return (pos.x < -1538 and pos.z < 328) or pos.y > 1280 end
    },
    {
        Name = "West Hallway",
        Min = Vector(-1536, 1024, -32),
        Max = Vector(-512, 1792, 160)
    },
    --after vapor lounge
    {
        Name = "East Hallway",
        Min = Vector(512, 512, -16),
        Max = Vector(2048, 1024, 256)
    },
    {
        Name = "Public Theater",
        Min = Vector(-1536, 0, -144),
        Max = Vector(-512, 1024, 256),
        Filter = function(pos) return pos.x + pos.y > -1024 end,
        Theater = {
            Flags = THEATER_REPLICATED,
            Pos = Vector(-1035, 48.5, 244),
            Ang = Angle(0, 135, 0),
            Width = 640,
            Height = 360,
            Thumb = "pub_thumb"
        }
    },
    {
        Name = "Private Theater 1",
        Min = Vector(512, 0, -16),
        Max = Vector(896, 512, 256),
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            Pos = Vector(632, 487.2, 173),
            Ang = Angle(0, 0, 0),
            Width = 240,
            Height = 135,
            Thumb = "p1_thumb"
        }
    },
    {
        Name = "Private Theater 2",
        Min = Vector(896, 0, -16),
        Max = Vector(1280, 512, 256),
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            Pos = Vector(1016, 487.2, 173),
            Ang = Angle(0, 0, 0),
            Width = 240,
            Height = 135,
            Thumb = "p2_thumb"
        }
    },
    {
        Name = "Private Theater 3",
        Min = Vector(1280, 0, -16),
        Max = Vector(1664, 512, 256),
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            Pos = Vector(1400, 487.2, 173),
            Ang = Angle(0, 0, 0),
            Width = 240,
            Height = 135,
            Thumb = "p3_thumb"
        }
    },
    {
        Name = "Private Theater 4",
        Min = Vector(1664, 0, -16),
        Max = Vector(2048, 512, 256),
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            Pos = Vector(1784, 487.2, 173),
            Ang = Angle(0, 0, 0),
            Width = 240,
            Height = 135,
            Thumb = "p4_thumb"
        }
    },
    {
        Name = "Private Theater 5",
        Min = Vector(640, 1024, -48),
        Max = Vector(1122, 1804, 232),
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            Pos = Vector(664.2, 1048, 173),
            Ang = Angle(0, 90, 0),
            Width = 240,
            Height = 135,
            Thumb = "p5_thumb"
        }
    },
    {
        Name = "Private Theater 6",
        Min = Vector(1152, 1024, -48),
        Max = Vector(1720, 1490, 256),
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            Pos = Vector(1176.1, 1102, 214),
            Ang = Angle(0, 90, 0),
            Width = 324,
            Height = 184,
            Thumb = "p6_thumb"
        },
        Filter = function(pos) return pos.x < 1584 or pos.y < 1424 end
    },
    {
        Name = "Vapor Lounge",
        Min = Vector(1865, 268, -19),
        Max = Vector(2549, 1524, 242),
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            -- Pos = Vector(2312+36, 1520-37, 210), -- Ang = Angle(0, 315, 0), -- Pos = Vector(2304 + 262.5 / 2, 273, 216), -- Width = 262.5, --21:9; should be 200 for 16:9 -- Height = 112.5,
            Pos = Vector(2304 + 256 / 2, 273 + 8 + 16, 216),
            Width = 256, --21:9; should be 200 for 16:9
            Height = 144,
            Ang = Angle(0, 180, 0),
            AllowItems = true,
            ProtectionTime = 3600,
        },
        Filter = function(pos) return pos.x < 2560 or (pos.y > 560 and pos.y < 688 and pos.z < 128) end
    },
    {
        Name = "Furnace",
        Min = Vector(1759, 1007, 0),
        Max = Vector(1855, 1120, 128)
    },
    {
        Name = "AFK Corral",
        Min = Vector(1680, 512, -128),
        Max = Vector(3008, 1866, 248)
    },
    {
        Name = "Back Room",
        Min = Vector(-512, 1536, -16),
        Max = Vector(0, 1792, 128)
    },
    {
        Name = "Treatment Room",
        Min = Vector(-512, 1280, -144),
        Max = Vector(-256, 1536, -16)
    },
    {
        Name = "Server Room",
        Min = Vector(-560, 1664, -144),
        Max = Vector(-360, 1792, -16)
    },
    {
        Name = "Basement",
        Min = Vector(-512, 1536, -144),
        Max = Vector(0, 1792, -16)
    },
    --after server room
    {
        Name = "Bedroom",
        Min = Vector(-736, 1536, -160),
        Max = Vector(-560, 2052, -32),
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(-578.9, 1972, -101),
            Ang = Angle(0, 270, 0),
            Width = 32,
            Height = 18
        }
    },
    --after server room
    {
        Name = "Reddit",
        Min = Vector(-450, 1210, -304),
        Max = Vector(-210, 1450, -128),
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(-285, 1213, -214),
            Ang = Angle(0, 180, 0),
            Width = 60,
            Height = (60 * 9 / 16)
        }
    },
    {
        Name = "Rat's Lair",
        Min = Vector(-220, 440, -304),
        Max = Vector(-72, 1440, -128)
    },
    --after chromozone
    {
        Name = "Sewer Theater",
        Min = Vector(-1024, 1024, -1024),
        Max = Vector(0, 2220, -64),
        Theater = {
            Flags = THEATER_REPLICATED,
            Pos = Vector(-1016, 1318, -368),
            Ang = Angle(0, 90, 0),
            Width = 676,
            Height = 376,
            AllowItems = true
        }
    },
    --after chromozone and rat's lair
    {
        Name = "Maintenance Room",
        Min = Vector(-1536, -560, -540),
        Max = Vector(-1264, -272, -412),
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(-1510.9, -493, -472),
            Ang = Angle(0, 90, 0),
            Width = 56,
            Height = 32
        }
    },
    {
        Name = "Moon Base",
        Min = Vector(3608, -872, 11336),
        Max = Vector(3944, -536, 11464),
        Filter = function(pos) return Vector(3776, -704, 0):Distance(Vector(pos.x, pos.y, 0)) < 168 end,
        Theater = {
            Flags = THEATER_NONE,
            Pos = Vector(3933, -725.2, 11466),
            Ang = Angle(0, 225, 0),
            Width = 192,
            Height = 108
        }
    },
    {
        Name = "Office of the Vice President",
        Min = Vector(-2480, -208, -320),
        Max = Vector(-2240, 48, -160)
    },
    {
        Name = "Situation Monitoring Room",
        Min = Vector(-2752, 36, -320),
        Max = Vector(-2525, 230, -184)
    },
    {
        Name = "Elevator Shaft",
        Min = Vector(-2768, 160, -144),
        Max = Vector(-2576, 288, 992)
    },
    {
        Name = "Stairwell",
        Min = Vector(-3000, 44 - 64, -320),
        Max = Vector(-2776, 344, -1),
        Filter = function(pos) return pos.y > 120 or pos.z < -176 end
    },
    {
        Name = "Trump Lobby",
        Min = Vector(-2992, -432, 0),
        Max = Vector(-1968, 336, 256)
    },
    --after office of the vice president & elevator shaft
    {
        Name = "Drunken Clam",
        Min = Vector(-2872, -1054, -10),
        Max = Vector(-1974, -560, 176),
        Theater = {
            Flags = THEATER_REPLICATED,
            Pos = Vector(-2372, -1020.9, 142),
            Ang = Angle(0, 180, 0),
            Width = 96,
            Height = 54
        }
    },
    {
        Name = "SushiTheater",
        Min = Vector(-2912, -2008, -16),
        Max = Vector(-2096, -1192, 192)
    },
    {
        Name = "SushiTheater Second Floor",
        Min = Vector(-2832, -1928, 192),
        Max = Vector(-2176, -1272, 376)
    },
    {
        Name = "SushiTheater Third Floor",
        Min = Vector(-2736, -1832, 376),
        Max = Vector(-2272, -1368, 592),
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(-2727.9, -1728, 568),
            Ang = Angle(0, 90, 0),
            Width = 256,
            Height = 128
        }
    },
    {
        Name = "SushiTheater Attic",
        Min = Vector(-2656, -1752, 624),
        Max = Vector(-2352, -1448, 717)
    },
    {
        Name = "Auditorium",
        Min = Vector(-2916, 1040, -144),
        Max = Vector(-2310, 1796, 256),
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            Pos = Vector(-2849.8, 1208, 136),
            Ang = Angle(0, 90, 0),
            Width = 420,
            Height = 235,
            AllowItems = true
        }
    },
    {
        Name = "Bomb Shelter",
        Min = Vector(-1736, 761, -176),
        Max = Vector(-1592, 952, -34),
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(-1658, 800.1, -122),
            Ang = Angle(0, 180, 0),
            Width = 20,
            Height = 12
        }
    },
    "mobiletheaters", {
        Name = "The Pit",
        --Filter = function(pos) return Vector(0,-1152,0):Distance(Vector(pos.x,pos.y,0)) < 650 or pos.y<-1152 end,
        Min = Vector(-1263, -2656, -144),
        Max = Vector(735, -511, 779)
    },
    --[[Filter = function(pos) return Vector(0,-1152,0):Distance(Vector(pos.x,pos.y,0)) < 512 end,
		Min = Vector(-512,-1152-512,-128),
		Max = Vector(512,-1152+512,192)]] -- 10 "Mobile" theaters are used by prop_trash_theater
    {
        Name = "SushiTheater Basement",
        Min = Vector(-2912, -2008, -176),
        Max = Vector(-2096, -1100, -24)
    },
    {
        Name = "Control Room",
        Min = Vector(1423, 3905, -10),
        Max = Vector(1841, 4144, 120)
    },
    {
        Name = "Power Plant",
        Min = Vector(964, 2825, -48),
        Max = Vector(3456, 4608, 512)
    },
    {
        Name = "Kleiner's Lab",
        Min = Vector(5824, 2752, -400),
        Max = Vector(6464, 3712, 92),
        Filter = function(pos) return pos.x > 5887 or pos.y < 3472 end
    },
    {
        Name = "Cemetery",
        Min = Vector(-3264, 2880, -128),
        Max = Vector(-966, 4608, 768)
    },
    {
        Name = "Swamp Hut",
        Min = Vector(-105, 2828, 26),
        Max = Vector(199, 3132, 146),
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(17.5, 3121.7, 95),
            Ang = Angle(0, 0, 0),
            Width = 59,
            Height = 33
        },
        Filter = function(pos) return pos.x > -45 or pos.y > 2888 end
    },
    {
        Name = "The Underworld",
        Min = Vector(-13312, -7168, -9216),
        Max = Vector(-7168, -1024, -3072),
        Theater = {
            Flags = THEATER_NONE,
            Pos = Vector(-9912.4, -4390, -5934),
            Ang = Angle(0, 270, 0),
            Width = 260,
            Height = 148
        }
    },
    {
        Name = "Void",
        Min = Vector(-6144, 1024, 0),
        Max = Vector(-5120, 2048, 1024)
    },
    {
        Name = "The Box",
        Min = Vector(-13554, -242, -1547),
        Max = Vector(-10004, 3315, 1711)
    },
    {
        Name = "Throne Room",
        Min = Vector(-2560, -432, 800),
        Max = Vector(-2128, -112, 992)
    },
    {
        Name = "Trump Tower",
        Min = Vector(-2993, -419, 260),
        Max = Vector(-1958, 346, 992),
    },
    --after throne room --Filter = function(pos) return (pos.x+pos.y) > -4080 and (pos.x+pos.y) < -3136 end,
    {
        Name = "SportZone",
        Min = Vector(1952, -1680, -24),
        Max = Vector(2288, -1376, 128),
        Filter = function(pos) return pos.x < 2142 or pos.y > -1561 end
    },
    {
        Name = "Gym",
        Min = Vector(768, -2048, -24),
        Max = Vector(1952, -1376, 288)
    },
    {
        Name = "Locker Room",
        Min = Vector(2016, -2064, -24),
        Max = Vector(2576, -1536, 128)
    },
    {
        Name = "Janitor's Closet",
        Min = Vector(2288, -1536, -24),
        Max = Vector(2448, -1376, 104)
    },
    {
        Name = "Sauna",
        Min = Vector(2288, -1536, -24),
        Max = Vector(2576, -1104, 128),
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(2573.9, -1168, 96),
            Ang = Angle(0, -90, 0),
            Width = 128,
            Height = 72
        }
    },
    {
        Name = "Outdoor Pool",
        Min = Vector(1216, -1088, -128),
        Max = Vector(1632, -193, 128)
    },
    --after private theaters, pool
    {
        Name = "Golf",
        Min = Vector(1632, -2048, -128),
        Max = Vector(3009, 0, 226),
        Filter = function(pos) return pos.x > 2592 or pos.y > -1087 end
    },
    {
        Name = "In Minecraft",
        Min = Vector(672, -2996, -3000),
        Max = Vector(5844, 2443, -128),
        Filter = function(pos) return pos.x < 5600 or pos.y < 2164 end
    },
    {
        Name = "Tree",
        Min = Vector(555, -1051, 224),
        Max = Vector(1355, -251, 1024)
    },
    {
        Name = "Weapons Testing Range",
        Min = Vector(-2160, -352, -320),
        Max = Vector(-1648, 1084, -180)
    },
    {
        Name = "Trumppenbunker",
        Min = Vector(-3680, -768, -544),
        Max = Vector(-2160, 348, -176),
        Filter = function(pos) return pos.x > -3008 or pos.z < -128 end
    },
    {
        Name = "Temple of Kek",
        Min = Vector(-2304, -5408, -640),
        Max = Vector(-1920, -4896, -384)
    },
    {
        Name = "Labyrinth",
        Min = Vector(-4096, -5407, -959),
        Max = Vector(672, -316, -384),
        Filter = function(pos) return pos.x > 0 or pos.y < -768 end
    },
    {
        Name = "Moon",
        Min = Vector(-4000, -6000, 10400),
        Max = Vector(8000, 4000, 13500)
    },
    --after moon base
    {
        Name = "Deep Space",
        Min = Vector(5952, 4032, 6976),
        Max = Vector(16128, 16256, 16128)
    },
    --after moon
    {
        Name = "Potassium Palace",
        Min = Vector(-1512, 584, -2420),
        Max = Vector(-760, 1336, -144)
    },
    --after everything except sewer tunnels
    {
        Name = "Sewer Tunnels",
        Min = Vector(-4000, -4000, -4000),
        Max = Vector(4000, 4000, -128)
    },
    --after everything except outside
    {
        Name = "Outside",
        Min = Vector(-4000, -4000, -4000),
        Max = Vector(4000, 4700, 16000)
    },
    --after everything
    {
        Name = "Unknown",
        Min = Vector(-100000, -100000, -100000),
        Max = Vector(100000, 100000, 100000),
        Contains = function(self, point) return true end
    }
}

--after everything
--set up and index mobile theaters
MobileLocations = {}
local i = 1

while i <= #Locations do
    if Locations[i] == "mobiletheaters" then
        table.remove(Locations, i)

        for j = 0, 31 do
            table.insert(MobileLocations, i + j)

            table.insert(Locations, i, {
                MobileLocationIndex = #MobileLocations,
                Name = "MobileTheater" .. tostring(#MobileLocations),
                Min = Vector(-1, -1, -10001),
                Max = Vector(1, 1, -10000),
                Theater = {
                    Flags = 1,
                    Pos = Vector(0, 0, 0),
                    Ang = Angle(0, 0, 0),
                    Width = 32,
                    Height = 18
                },
                Contains = function(self, point) return WAAB(point, self.Min, self.Max) end
            })
        end

        break
    end

    i = i + 1
end

LocationByName = {}

for i, v in ipairs(Locations) do
    v.Index = i
    LocationByName[v.Name] = v

    if not v.Contains then
        local min = v.Min
        local max = v.Max

        if v.Filter then
            local filt = v.Filter
            v.Contains = function(self, point) return WAAB(point, min, max) and filt(point) end
        else
            v.Contains = function(self, point) return WAAB(point, min, max) end
        end
    end
end

function RefreshLocations()
    for k, v in pairs(ents.GetAll()) do
        v.LastLocationCoords = nil
    end
end

-- returns the index of the players current location or 0 if unknown
function FindLocation(pos)
    if isentity(pos) then
        pos = pos:GetPos()
    end

    for k, v in ipairs(Locations) do
        if v:Contains(pos) then return k end
    end

    return #Locations
end

function GetPlayersInLocation(idx)
    local tab = {}

    for _, ply in ipairs(Ents.player) do
        if ply:GetLocation() == idx then
            table.insert(tab, ply)
        end
    end

    return tab
end

local Player = FindMetaTable("Player")
local Entity = FindMetaTable("Entity")

function Player:GetLocation()
    local set = self:GetDTInt(0)

    if Locations[set] == nil then
        print("FUCK")
        set = #Locations
    end

    return set
end

function Entity:GetLocation()
    assert(not self:IsPlayer())
    local pos = self:GetPos()

    if self.LastLocationCoords == nil or self.LastLocationCoords:DistToSqr(pos) > 1 then
        self.LastLocationCoords = pos
        self.LastLocation = FindLocation(self)
    end

    return self.LastLocation
end

function Entity:GetLocationName()
    return self:GetLocationTable().Name or "Unknown"
end

function Entity:GetLocationTable()
    return Locations[self:GetLocation()] or {}
end

function Entity:InTheater()
    return self:GetLocationTable().Theater ~= nil
end

function Entity:GetTheater()
    return theater.GetByLocation(self:GetLocation())
end

if CLIENT then
    print("HI")
    local DebugEnabled = CreateClientConVar("cinema_debug_locations", "0", false, false)

    local function update()
        if DebugEnabled:GetBool() then
            hook.Add("PostDrawTranslucentRenderables", "CinemaDebugLocations", function(depth, sky, sky3d)
                if sky or depth or sky3d then return end

                for k, v in pairs(Locations) do
                    local center = (v.Min + v.Max) / 2
                    Debug3D.DrawBox(v.Min, v.Max)
                    Debug3D.DrawText(center, v.Name, "VideoInfoSmall")
                end
            end)
        else
            hook.Remove("PostDrawTranslucentRenderables", "CinemaDebugLocations")
        end
    end

    cvars.AddChangeCallback("convar name", cinema_debug_locations)
end
