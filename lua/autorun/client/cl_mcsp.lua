local MCSPmodel = "models/milaco/minecraft_pm/minecraft_pm.mdl"

hook.Add("PrePlayerDraw", "MCSPRenderSkin", function(ply) --Material ID 0 is the hat layer, ID 1 is the base layer
	if IsValid(ply) and ply:GetModel() == MCSPmodel and ply:IsPlayer() then
		render.MaterialOverrideByIndex(0, ImgurMaterial(ply:GetNWString("MCSPSkinURL", false), ply, ply:GetPos(), false, "VertexLitGeneric", {
			["$alphatest"] = 1,
			["$halflambert"] = 1,
			["$model"] = 1
		}))
		render.MaterialOverrideByIndex(1, ImgurMaterial(ply:GetNWString("MCSPSkinURL", false), ply, ply:GetPos(), false, "VertexLitGeneric", {
			["$translucent"] = 0,
			["$halflambert"] = 1,
			["$model"] = 1
		}))
	end
end)

hook.Add("PostPlayerDraw", "MCSPRenderSkin", function(ply)
	if IsValid(ply) and ply:GetModel() == MCSPmodel and ply:IsPlayer() then
		render.MaterialOverrideByIndex(0, "")
		render.MaterialOverrideByIndex(1, "")
	end
end)

hook.Add("PostDrawOpaqueRenderables", "DrawMinecraftPlayerRagdolls", function() --Renders the material on the player's ragdoll
	for _, v in pairs(player.GetHumans()) do
		if IsValid(v) and IsValid(v:GetRagdollEntity()) and v:GetRagdollEntity():GetModel() == MCSPmodel then
			local ragent = v:GetRagdollEntity()

			render.MaterialOverrideByIndex(0, ImgurMaterial(v:GetNWString("MCSPSkinURL", false), v, v:GetPos(), false, "VertexLitGeneric", {
				["$alphatest"] = 1,
				["$halflambert"] = 1,
				["$model"] = 1
			}))
			render.MaterialOverrideByIndex(1, ImgurMaterial(v:GetNWString("MCSPSkinURL", false), v, v:GetPos(), false, "VertexLitGeneric", {
				["$translucent"] = 0,
				["$halflambert"] = 1,
				["$model"] = 1
			}))
			ragent:DrawModel()
			ragent:SetNoDraw(true)
			render.MaterialOverrideByIndex(0, "")
			render.MaterialOverrideByIndex(1, "")
		end
	end
end)
