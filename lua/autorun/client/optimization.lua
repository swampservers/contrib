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

timer.Create("VaporVis",0.5,0,function()
	if not LocalPlayer().GetLocationName then return end
	local shouldsee = (LocalPlayer():GetLocationName()=="Vapor Lounge" or LocalPlayer():GetLocationName()=="West Hallway")
	if !IsValid(VaporLoungeVaporEntity) then
		for k,v in pairs(ents.FindByClass('func_smokevolume')) do
			local b1,b2 = v:GetRenderBounds()
			if b1.x==-1505 and b2.x==-799 then
				VaporLoungeVaporEntity=v
			end
		end
	end
	if IsValid(VaporLoungeVaporEntity) then
		if shouldsee then
			VaporLoungeVaporEntity:SetPos(Vector(0,0,0))
		else
			VaporLoungeVaporEntity:SetPos(Vector(0,10000,10000))
		end
	end
end)

DontRenderSkyboxHere = {
	["Private Theater 1"]=true,
	["Private Theater 2"]=true,
	["Private Theater 3"]=true,
	["Private Theater 4"]=true,
	["Movie Theater"]=true,
	["Public Theater"]=true,
	["Vapor Lounge"]=true,
	["Kool Kids Klub"]=true,
	["Miner's Hut"]=true,
	["Upper Caverns"]=true,
	["Lower Caverns"]=true,
	["Basement"]=true,
	["Treatment Room"]=true,
	["Server Room"]=true,
	["Bedroom"]=true,
	["Chromozone"]=true,
	["Rat's Lair"]=true,
	["Sewer Theater"]=true,
	["Maintenance Room"]=true,
	["Potassium Palace"]=true,
	["Hell"]=true,
	["Sewer Tunnels"]=true
}

hook.Add("PreDrawSkyBox", "SkyBoxRenderSkip", function()
	if not LocalPlayer().GetLocationName then return end
	if DontRenderSkyboxHere[LocalPlayer():GetLocationName()] then
		hook.Run("PostDraw2DSkyBox")
		return true
	end
end)
