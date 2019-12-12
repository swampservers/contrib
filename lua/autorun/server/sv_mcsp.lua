local MCSPmodel = "models/milaco/minecraft_pm/minecraft_pm.mdl"

local function MinecraftUpdateURL(ply, url)
	if (ply.SetMCSPTimeout or 0) > CurTime() - 10 then ply:Notify("Cooldown...") return end --cooldown
	ply.SetMCSPTimeout = CurTime()

	if ply:GetModel() != MCSPmodel then return end
	local url = SanitizeImgurId(url)
	if !url then return ply:ChatPrint("[red]Invalid URL!") end

	ply:SetNWString("MCSPSkinURL", url)
	ply:SetPData("MinecraftURL", url)
end

RegisterChatCommand({'minecraftskin','skinpicker','minecrafturl'}, function(ply, arg)
	if ply:GetModel() == MCSPmodel then
		local argtable = string.Explode(" ", arg)
		if argtable[1] then
			MinecraftUpdateURL(ply, argtable[1])
		else
			ply:ChatPrint("[orange]Usage: !minecraftskin (url)")
		end
	else
		ply:ChatPrint("[red]You do not have a steve skin equipped!")
	end
end, {global=false, throttle=true})

RegisterChatCommand({'mcreset','minecraftreset','minecraftskinreset'}, function(ply, arg)
	ply:SetNWString("MCSPSkinURL", false)
	ply:RemovePData("MinecraftURL")
end, {global=false, throttle=true})

hook.Add("PlayerInitialSpawn", "MinecraftFindURL", function(ply)
	ply:SetNWString("MCSPSkinURL", ply:GetPData("MinecraftURL", false))
end)

hook.Add("PlayerDeathSound", "MinecraftDeathSound", function(ply, inf, att)
	if ply:GetModel() == MCSPmodel then
		ply:ExtEmitSound("minecraft/mc_hurt.ogg", {pitch=100})
		return true
	end
end)
