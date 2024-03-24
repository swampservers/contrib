-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local THEATER_NONE = 0 --default/public theater
local THEATER_PRIVATE = 1 --private theater
local THEATER_REPLICATED = 2 --public theater, shows on the scoreboard
local THEATER_PRIVATEREPLICATED = 3 --private theater, shows on the scoreboard
local WAAB = FindMetaTable("Vector").WithinAABox

if NewLocations then
    Locations = table.Copy(NewLocations) -- New func_location BASED system
    LocationsDebug = table.Copy(NewLocationsDebug)
else
    ErrorNoHalt("No NewLocations!")
    Locations = {}
    LocationsDebug = {}
end

LocationTheaterInfo = {
    ["Attic"] = {
        Flags = THEATER_PRIVATE,
        Pos = Vector(83, 1491, 178.5),
        Ang = Angle(0, -45, 0),
        Width = 45,
        Height = 25
    },
    ["Movie Theater"] = {
        --Filter = function(pos) return pos.x < -1538 and pos.z < 328 or pos.y > 1280 end,
        Flags = THEATER_REPLICATED,
        Pos = Vector(-1696, 2250, 366),
        Ang = Angle(0, 0, 0),
        Width = 864,
        Height = 486,
        Thumb = "m_thumb",
        ProtectionTime = 7200,
    },
    ["Public Theater"] = {
        --Filter = function(pos) return pos.x + pos.y > -1024 end,
        Flags = THEATER_REPLICATED,
        Pos = Vector(-1036, 50, 252),
        Ang = Angle(0, 135, 0),
        Width = 640,
        Height = 360,
        Thumb = "pub_thumb"
    },
    ["Private Theater 1"] = {
        Flags = THEATER_PRIVATEREPLICATED,
        Pos = Vector(632, 487.2, 173),
        Ang = Angle(0, 0, 0),
        Width = 240,
        Height = 135,
        Thumb = "p1_thumb"
    },
    ["Private Theater 2"] = {
        Flags = THEATER_PRIVATEREPLICATED,
        Pos = Vector(1016, 487.2, 173),
        Ang = Angle(0, 0, 0),
        Width = 240,
        Height = 135,
        Thumb = "p2_thumb"
    },
    ["Private Theater 3"] = {
        Flags = THEATER_PRIVATEREPLICATED,
        Pos = Vector(1400, 487.2, 173),
        Ang = Angle(0, 0, 0),
        Width = 240,
        Height = 135,
        Thumb = "p3_thumb"
    },
    ["Private Theater 4"] = {
        Flags = THEATER_PRIVATEREPLICATED,
        Pos = Vector(1784, 487.2, 173),
        Ang = Angle(0, 0, 0),
        Width = 240,
        Height = 135,
        Thumb = "p4_thumb"
    },
    ["Private Theater 5"] = {
        Flags = THEATER_PRIVATEREPLICATED,
        Pos = Vector(664.2, 1048, 173),
        Ang = Angle(0, 90, 0),
        Width = 240,
        Height = 135,
        Thumb = "p5_thumb"
    },
    ["Private Theater 6"] = {
        --Filter = function(pos) return pos.x < 1584 or pos.y < 1424 end,
        Flags = THEATER_PRIVATEREPLICATED,
        Pos = Vector(1176.5, 1102, 214),
        Ang = Angle(0, 90, 0),
        Width = 324,
        Height = 184,
        Thumb = "p6_thumb"
    },
    ["Vapor Lounge"] = {
        --Filter = function(pos) return pos.x < 2560 or pos.y > 560 and pos.y < 688 and pos.z < 128 end,
        Flags = THEATER_PRIVATEREPLICATED,
        Pos = Vector(2424, 281, 198),
        Width = 240,
        Height = 135,
        Ang = Angle(0, 180, 0),
        AllowItems = true,
        ProtectionTime = 3600,
    },
    ["Bedroom"] = {
        Flags = THEATER_PRIVATE,
        Pos = Vector(-578.9, 1972, -101),
        Ang = Angle(0, 270, 0),
        Width = 32,
        Height = 18
    },
    ["Reddit"] = {
        Flags = THEATER_PRIVATE,
        Pos = Vector(209, 1152.5, -400),
        Ang = Angle(0, 180, 0),
        Width = 60,
        Height = 60 * 9 / 16
    },
    ["Sewer Theater"] = {
        Flags = THEATER_REPLICATED,
        Pos = Vector(-1020, 1344, -384),
        Ang = Angle(0, 90, 0),
        Width = 640,
        Height = 360,
        AllowItems = true
    },
    ["Maintenance Room"] = {
        Flags = THEATER_PRIVATE,
        Pos = Vector(-1486.5, -493, -532),
        Ang = Angle(0, 90, 0),
        Width = 56,
        Height = 32
    },
    ["Moon Base"] = {
        --Filter = function(pos) return Vector(3776, -704, 0):Distance(Vector(pos.x, pos.y, 0)) < 168 end,
        Flags = THEATER_NONE,
        Pos = Vector(3933, -725.2, 11466),
        Ang = Angle(0, 225, 0),
        Width = 192,
        Height = 108
    },
    ["SushiTheater Third Floor"] = {
        Flags = THEATER_PRIVATE,
        Pos = Vector(-2640, -1352.5, 536),
        Ang = Angle(0, 0, 0),
        Width = 256,
        Height = 128
    },
    ["Auditorium"] = {
        Flags = THEATER_PRIVATEREPLICATED,
        Pos = Vector(-2849.8, 1208, 136),
        Ang = Angle(0, 90, 0),
        Width = 420,
        Height = 235,
        AllowItems = true
    },
    ["Survival Bunker"] = {
        Flags = THEATER_PRIVATE,
        Pos = Vector(-1658, 800.1, -106.5),
        Ang = Angle(0, 180, 0),
        Width = 20,
        Height = 12
    },
    ["Swamp Hut"] = {
        --Filter = function(pos) return pos.x > -45 or pos.y > 2888 end,
        Flags = THEATER_PRIVATE,
        Pos = Vector(17.5, 3121.7, 85),
        Ang = Angle(0, 0, 0),
        Width = 59,
        Height = 33
    },
    ["The Underworld"] = {
        Flags = THEATER_NONE,
        Pos = Vector(-10016, -5083, -6304),
        Ang = Angle(0, 180, 0),
        Width = 448,
        Height = 252
    },
    ["Sauna"] = {
        Flags = THEATER_PRIVATEREPLICATED,
        Pos = Vector(2083, -1296, 96),
        Ang = Angle(0, 90, 0),
        Width = 128,
        Height = 72
    },
    ["Power Plant"] = {
        Flags = THEATER_REPLICATED,
        Pos = Vector(1842, 3240, 295),
        Ang = Angle(0, 90, 0),
        Width = 336,
        Height = 189
    },
    ["Church"] = {
        Flags = THEATER_REPLICATED,
        Pos = Vector(-906.5, 3872, 176),
        Ang = Angle(0, 270, 0),
        Width = 192,
        Height = 108
    },
    ["Potassium Abyss Theater"] = {
        Flags = THEATER_NONE,
        Pos = Vector(-976, -239.5, -2426),
        Ang = Angle(0, 180, 0),
        Width = 352,
        Height = 198
    },
    ["Basement Den"] = {
        Flags = THEATER_PRIVATEREPLICATED,
        Pos = Vector(2405, 633, -116),
        Ang = Angle(0, 277, 0),
        Width = 54,
        Height = 32
    }
}

-- NOTE(winter): We're moving stuff around a little bit here. It goes Theaters, then MobileTheaters, then The Underworld, then all normal Locations
-- This is so MobileTheaters will always work, except when intersecting map theater locations (priority order)
local lastTheaterLocID = 1
local underworldLocID = nil

for locID = 1, #Locations do
    local locInfo = Locations[locID]
    local locTheaterInfo = LocationTheaterInfo[locInfo.Name]

    if locTheaterInfo then
        locInfo.Theater = locTheaterInfo
        table.remove(Locations, locID)
        table.insert(Locations, lastTheaterLocID, locInfo)

        if locInfo.Name == "The Underworld" then
            underworldLocID = lastTheaterLocID
        end

        lastTheaterLocID = lastTheaterLocID + 1
    end
end

-- Set up and index mobile theaters
MobileLocations = {}

for mobileLocOffset = 0, 31 do
    table.insert(MobileLocations, lastTheaterLocID + mobileLocOffset - 1)

    table.insert(Locations, lastTheaterLocID + mobileLocOffset, {
        MobileLocationIndex = #MobileLocations,
        Name = "MobileTheater" .. tostring(#MobileLocations),
        Min = Vector(-1, -1, -10001),
        Max = Vector(1, 1, -10000),
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(0, 0, 0),
            Ang = Angle(0, 0, 0),
            Width = 32,
            Height = 18
        },
        Contains = function(self, point) return WAAB(point, self.Min, self.Max) end
    })

    -- Just so indexes stay in sync
    table.insert(LocationsDebug, lastTheaterLocID - 1, "mobiletheater")
end

-- Put Underworld after MobileTheaters so they work in there
table.insert(Locations, lastTheaterLocID + 31, table.remove(Locations, underworldLocID))

-- After everything
Locations[#Locations + 1] = {
    Name = "Unknown",
    Min = Vector(-16384, -16384, -16384),
    Max = Vector(16384, 16384, 16384),
    Contains = function(self, point) return true end
}

LocationByName = {}

for i, v in ipairs(Locations) do
    if LocationByName[v.Name] then
        ErrorNoHalt("[Locations] Duplicate with name: " .. v.Name .. "\n")
    end

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

-- Tell us about any theaters that didn't have matching locations
-- (The Theater either needs to be removed or the Location needs to be added)
for locName in pairs(LocationTheaterInfo) do
    if not LocationByName[locName] then
        print("[Locations] Couldn't find Location for Theater: " .. locName)
    end
end

function RefreshLocations()
    for _, ent in pairs(ents.GetAll()) do
        ent.LastLocationCoords = nil
    end
end

--- Global function to compute a location ID (avoid this, it doesn't cache)
function FindLocation(ent_or_pos)
    if isentity(ent_or_pos) then
        ent_or_pos = ent_or_pos:GetPos()
    end

    for id, info in ipairs(Locations) do
        if info:Contains(ent_or_pos) then return id end
    end

    return #Locations
end

function GetLocationCenterByName(locName)
    local locInfo = LocationByName[locName]

    return (locInfo.Min + locInfo.Max) / 2
end

function GetPlayersInLocation(idx)
    local tab = {}

    for _, ply in ipairs(Ents.player) do
        if ply:GetLocation() == idx then
            tab[#tab + 1] = ply
        end
    end

    return tab
end

function Player:GetLocation()
    local set = self:GetDTInt(0)

    if Locations[set] == nil then
        print("FUCK NO LOCATION")
        set = #Locations
    end

    return set
end

--- Int location ID
function Entity:GetLocation()
    assert(not self:IsPlayer())
    local pos = self:WorldSpaceCenter()

    if self.LastLocationCoords == nil or self.LastLocationCoords:DistToSqr(pos) > 1 then
        self.LastLocationCoords = pos
        self.LastLocation = FindLocation(pos)
    end

    return self.LastLocation
end

--- String
function Entity:GetLocationName()
    return self:GetLocationTable().Name or "Unknown"
end

--- Location table
function Entity:GetLocationTable()
    return Locations[self:GetLocation()] or {}
end

--- Bool
function Entity:InTheater()
    return self:GetLocationTable().Theater ~= nil
end

--- Theater table
function Entity:GetTheater()
    return theater.GetByLocation(self:GetLocation())
end

if CLIENT then
    local DebugEnabled = CreateClientConVar("cinema_debug_locations", "0", false, false)
    local colorGreen = Color(0, 255, 0)

    local function update()
        if DebugEnabled:GetBool() then
            hook.Add("PostDrawTranslucentRenderables", "CinemaDebugLocations", function(depth, sky, sky3d)
                if sky or depth or sky3d then return end

                for locID, locInfo in ipairs(Locations) do
                    local debugLocInfo = LocationsDebug[locID]

                    if debugLocInfo and debugLocInfo ~= "mobiletheater" then
                        for _, solid in ipairs(debugLocInfo) do
                            for _, plane in ipairs(solid) do
                                Debug3D.DrawPlane(plane, nil, locInfo.Name)
                            end
                        end
                    end

                    if locInfo.Min and locInfo.Max then
                        local center = (locInfo.Min + locInfo.Max) / 2
                        Debug3D.DrawBox(locInfo.Min, locInfo.Max, colorGreen)
                        Debug3D.DrawText(center, locInfo.Name, "DermaLarge")
                    elseif not debugLocInfo then
                        print("[CinemaDebugLocations] Skipping " .. locInfo.Name .. ", no info to render with!")
                    end
                end
            end)

            hook.Add("HUDPaint", "CinemaDebugLocations_HUD", function()
                local w, h = ScrW(), ScrH()
                local localPly = LocalPlayer()
                draw.SimpleTextOutlined(localPly:GetLocationName() .. " = " .. localPly:GetLocation(), "DermaLarge", w / 2, h, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
            end)
        else
            hook.Remove("PostDrawTranslucentRenderables", "CinemaDebugLocations")
            hook.Remove("HUDPaint", "CinemaDebugLocations_HUD")
        end
    end

    cvars.AddChangeCallback("cinema_debug_locations", update)
    update()
end
