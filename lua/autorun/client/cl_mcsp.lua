local MCSPmodel = "models/milaco/minecraft_pm/minecraft_pm.mdl"
CreateClientConVar("mcsp_url", "", true, true)

local function MCSPRenderNewMaterial(url, ply) --This is where the magic happens, baby
	ply.MCSPSkinMaterial = ImgurMaterial(url, ply, ply:GetPos(), false, "VertexLitGeneric", {
		["$alphatest"] = 1,
		["$halflambert"] = 1,
		["$nodecal"] = 1,
		["$model"] = 1
	})
end

RegisterChatCommand({'mcsp','skinpicker'}, function(ply, arg)
	if ply:GetModel() == MCSPmodel then
		if IsValid(srderma) then return end
		local srderma = Derma_StringRequest("Minecraft Skin Changer","Input an Imgur URL to change your playermodel to that skin.","",function(dermatext)
			if string.len(dermatext) > 36 then
				ply:ChatPrint("URL is too long!")
			elseif string.find(dermatext, "i%.imgur%.com/%w+%.png") then
				net.Start("MCSPToSVBroadcastNewMaterial")
					net.WriteString(dermatext)
					net.WriteEntity(ply)
					net.SendToServer()
				RunConsoleCommand("mcsp_url", dermatext)
			else
				ply:ChatPrint("Invalid URL!")
			end
		end,function() end,"Change skin","Cancel")
		--local srdx, srdy = srderma:GetSize()
		--local srdermacredits = Label("Minecraft Skin Picker by Milaco and Chev", srderma) --Leave this out for now until we KNOW it's working
		--srdermacredits:Dock(BOTTOM)
		--srdermacredits:SetContentAlignment(2)
		--srderma:SetSize(srdx, srdy + 15)
		srderma:SetIcon("icon16/user.png")
	else
		ply:ChatPrint("[red]You do not have a steve skin equipped!")
	end
end, {global=false, throttle=true})

RegisterChatCommand({'mcspreset','mcreset'}, function(ply, arg)
	RunConsoleCommand("mcsp_url", "")
		net.Start("MCSPToSVResetSkin")
		net.WriteEntity(ply)
		net.SendToServer()
end, {global=false, throttle=true})

hook.Add("PrePlayerDraw", "MCSPRenderSkin", function(ply)
	if ply:GetModel() == MCSPmodel and ply.MCSPSkinMaterial and ply:IsPlayer() then
		render.MaterialOverrideByIndex(0, ply.MCSPSkinMaterial)
	end
end)

hook.Add("PostPlayerDraw", "MCSPRenderSkin", function(ply)
	if ply:GetModel() == MCSPmodel and ply.MCSPSkinMaterial and ply:IsPlayer() then
		render.MaterialOverrideByIndex(0, "")
	end
end)

hook.Add("PostDrawOpaqueRenderables", "DrawMinecraftPlayerRagdolls", function() --Renders the material on the player's ragdoll
	for _, v in pairs(player.GetHumans()) do
		if IsValid(v) and IsValid(v:GetRagdollEntity()) and v:GetRagdollEntity():GetModel() == MCSPmodel and v.MCSPSkinMaterial then
			local ragent = v:GetRagdollEntity()

			render.MaterialOverrideByIndex(0, v.MCSPSkinMaterial)
			ragent:DrawModel()
			ragent:SetNoDraw(true)
			render.MaterialOverrideByIndex(0, "")
		end
	end
end)

net.Receive("MCSPToCLUpdateNewMaterial", function() --Received from server after a player sends their skin URL query to the server
	local mcspurl = net.ReadString()
	local mcspent = net.ReadEntity()

	MCSPRenderNewMaterial(mcspurl, mcspent)
end)

net.Receive("MCSPToCLUpdateOnFirstConnect", function()
	for k, v in pairs(player.GetHumans()) do --Find other client's skins and update their own client
		local mcspurl = v:GetNWString("MCSPSkinURL", false)
		if IsValid(v) and mcspurl then
			MCSPRenderNewMaterial(mcspurl, v)
		end
	end
	if GetConVar("mcsp_url"):GetString() != "" and LocalPlayer():GetModel() == MCSPmodel then --If the client has a minecraft model on connecting, update their skin
		print("Client joined. Setting skin...")
		net.Start("MCSPToSVBroadcastNewMaterial")
			net.WriteString(GetConVar("mcsp_url"):GetString())
			net.WriteEntity(LocalPlayer())
			net.SendToServer()
	end
end)

net.Receive("MCSPToCLResetMaterial", function()
	local mcspent = net.ReadEntity()
	mcspent.MCSPSkinMaterial = false
end)