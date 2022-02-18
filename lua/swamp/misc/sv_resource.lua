-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local gm = engine.ActiveGamemode()
-- if gm == "cinema" or gm == "gungame" then
-- shards of contrib
resource.AddWorkshop("2453150484")
resource.AddWorkshop("2453150686")
resource.AddWorkshop("2453150754")
resource.AddWorkshop("2453150824")
resource.AddWorkshop("2453151168")
-- removed additional shards
-- resource.AddWorkshop("2453151259")
-- resource.AddWorkshop("2453151358")
-- resource.AddWorkshop("2453151452")
-- resource.AddWorkshop("2453342540")
-- resource.AddWorkshop("2453342601")
-- resource.AddWorkshop( "821872963" ) -- 10 gigs of crap addon
-- resource.AddWorkshop( "118824086" ) -- cinema gamemode
-- resource.AddWorkshop( "171935748" ) -- Popcorn SWEP
-- resource.AddWorkshop( "348910843" ) -- Rainbowdash fedora
-- resource.AddWorkshop( "104548572" ) -- Playable Piano
-- resource.AddWorkshop( "673698301" ) -- Vape SWEP
-- resource.AddWorkshop( "693834059" ) -- Kleiner's Glasses
-- resource.AddWorkshop( "346465496" ) -- Christmas Props
-- resource.AddWorkshop( "822232922" ) -- UXmas model pack
-- resource.AddWorkshop( "1783952608" ) --HEV KLEINER
resource.AddSingleFile("gamemodes/cinema/logo.png")

-- end
if gm == "fatkid" then
    resource.AddWorkshop("625476776") -- Fat Kid playermodel
    resource.AddWorkshop("205268453") -- pony playermodel
end

if gm == "gungame" then
    resource.AddWorkshop("1524544510")
end

if gm == "spades" then
    resource.AddWorkshop("1326275319") -- AOS content
end
--[[
	resource.AddSingleFile("models/error.mdl") -- FUCK error meme
	resource.AddSingleFile("models/error.dx80.vtx")
	resource.AddSingleFile("models/error.dx90.vtx")
	resource.AddSingleFile("models/error.sw.vtx")
	resource.AddSingleFile("models/error.vvd")
]]
