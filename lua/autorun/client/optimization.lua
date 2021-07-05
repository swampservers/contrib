-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
--[[ DETAILS_RENDER_ALL = 1200
DETAILS_RENDER_SKYBOX = 200

DETAIL_RENDER_TABLE = {
["Entrance"]=DETAILS_RENDER_ALL,
["Lobby"]=DETAILS_RENDER_ALL,
["Concessions"]=DETAILS_RENDER_ALL,
["East Hallway"]=DETAILS_RENDER_SKYBOX,
["The Pit"]=DETAILS_RENDER_ALL,
["Der Fuhrerbunker"]=DETAILS_RENDER_ALL,
["Auditorium"]=DETAILS_RENDER_ALL,
["Private Theater 5"]=DETAILS_RENDER_SKYBOX,
["Private Theater 6"]=DETAILS_RENDER_SKYBOX,
["Gym"]=DETAILS_RENDER_ALL,
["Pool"]=DETAILS_RENDER_ALL,
["SportZone"]=DETAILS_RENDER_ALL,
["Golf"]=DETAILS_RENDER_ALL,
["Outside"]=DETAILS_RENDER_ALL,
["Way Outside"]=DETAILS_RENDER_ALL,
}

timer.Create("cl detail controller",0.1,0,function()
	RunConsoleCommand("cl_detaildist","0") --DETAIL_RENDER_TABLE[LocalPlayer().GetLocationName and LocalPlayer():GetLocationName()] or 0)
end) ]]
DontRenderSkyboxHere = {
    ["Private Theater 1"] = true,
    ["Private Theater 2"] = true,
    ["Private Theater 3"] = true,
    ["Private Theater 4"] = true,
    ["Vapor Lounge"] = true,
    ["Treatment Room"] = true,
    ["Server Room"] = true,
    ["Bedroom"] = true,
    ["Reddit"] = true,
    ["Rat's Lair"] = true,
    ["Maintenance Room"] = true,
    ["Potassium Palace"] = true,
    ["Void"] = true,
    ["Sewer Theater"] = true,
    ["Sewer Tunnels"] = true,
    ["Sushi Theater Second Floor"] = true,
    ["Sushi Theater Third Floor"] = true,
    ["Sauna"] = true,
    ["Underworld"] = true,
    ["Maze"] = true,
    ["Temple"] = true,
    ["The Box"] = true
}

hook.Add("PreDrawSkyBox", "SkyBoxRenderSkip", function() end)
--[[if not LocalPlayer().GetLocationName then return end
	if DontRenderSkyboxHere[LocalPlayer():GetLocationName()] then
		hook.Run("PostDraw2DSkyBox")
		return true
	end]]
