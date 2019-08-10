local MCSPmodel = "models/milaco/minecraft_pm/minecraft_pm.mdl"

RegisterChatCommand({'minecraftskin','skinpicker','minecrafturl'}, function(ply, arg)
	if ply:GetModel() == MCSPmodel then
		local argtable = string.Explode(" ", arg)
		if argtable[1] then
			if (ply.SetMCSPTimeout or 0) > CurTime() - 10 then ply:Notify("Cooldown...") return end --cooldown
			ply.SetMCSPTimeout = CurTime()

			if ply:GetModel() != MCSPmodel then return end
			local url = SanitizeImgurId(argtable[1])
			if !url then return ply:ChatPrint("[red]Invalid URL!") end

			ply:SetNWString("MCSPSkinURL", url)
		else
			ply:ChatPrint("[orange]Usage: !minecraftskin (url)")
		end
	else
		ply:ChatPrint("[red]You do not have a steve skin equipped!")
	end
end, {global=false, throttle=true})

RegisterChatCommand({'mcreset','minecraftreset','minecraftskinreset'}, function(ply, arg)
	ply:SetNWString("MCSPSkinURL", false)
end, {global=false, throttle=true})
