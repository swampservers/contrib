local MCSPmodel = "models/milaco/minecraft_pm/minecraft_pm.mdl"

util.AddNetworkString("MCSPToSVBroadcastNewMaterial")
util.AddNetworkString("MCSPToSVResetSkin")
util.AddNetworkString("MCSPToCLUpdateNewMaterial")
util.AddNetworkString("MCSPToCLUpdateOnFirstConnect")
util.AddNetworkString("MCSPToCLResetMaterial")

net.Receive("MCSPToSVBroadcastNewMaterial", function()
	local mcspurl = net.ReadString()
	local mcspent = net.ReadEntity()

	if (ply.SetMCSPTimeout or 0) > CurTime() - 10 then ply:Notify("Cooldown...") return end --cooldown
	ply.SetMCSPTimeout = CurTime()

	if mcspent:GetModel() != MCSPmodel then return end
	if string.len(mcspurl) > 36 then netply:ChatPrint("URL is too long!") return end
	if !string.find(mcspurl, "i%.imgur%.com/%w+%.png") then return end

	mcspent:SetNWString("MCSPSkinURL", mcspurl)

	net.Start("MCSPToCLUpdateNewMaterial")
		net.WriteString(mcspurl)
		net.WriteEntity(mcspent)
		net.Broadcast() --send this to all players, so everyone gets the updated skin
end)

net.Receive("MCSPToSVResetSkin", function()
	local mcspent = net.ReadEntity()
	mcspent:SetNWString("MCSPSkinURL", false)

	net.Start("MCSPToCLResetMaterial")
		net.WriteEntity(mcspent)
		net.Broadcast() --Tell all players that this player reset their skin
end)

hook.Add("PlayerSpawn", "MCSPCheckModel", function(ply) --If a player has changed their model on respawn, reset their material
	if ply:GetModel() == "models/player.mdl" then return end
	timer.Simple(0.01, function()
		if ply:GetModel() != MCSPmodel then
			ply:SetNWString("MCSPSkinURL", false)
			net.Start("MCSPToCLResetMaterial")
				net.WriteEntity(ply)
				net.Broadcast()
		end
	end)
end)

hook.Add("PlayerInitialSpawn", "MCSPSendAllURLs", function(ply)
	timer.Create("DoesPlayerHaveModel", 1, 0, function() --Keep checking if the player has a model
		if ply:GetModel() != "models/player.mdl" then
			timer.Destroy("DoesPlayerHaveModel")
			net.Start("MCSPToCLUpdateOnFirstConnect")
				net.Send(ply)
		else
			timer.Start("DoesPlayerHaveModel")
		end
	end)
end)