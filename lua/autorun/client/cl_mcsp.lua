-- This file is subject to copyright - contact swampservers@gmail.com for more information.

local MCSPmodel = "models/milaco/minecraft_pm/minecraft_pm.mdl"

hook.Add("PrePlayerDraw", "MCSPRenderSkin", function(ply) --Material ID 0 is the hat layer, ID 1 is the base layer
	if IsValid(ply) and ply:GetModel() == MCSPmodel and ply:IsPlayer() and ply:GetNWString("MCSPSkinURL", false) then
		render.MaterialOverrideByIndex(1, ImgurMaterial(ply:GetNWString("MCSPSkinURL", false), ply, ply:GetPos(), false, "VertexLitGeneric", {
			["$opaque"] = 1,
			["$halflambert"] = 1,
			["$model"] = 1
		}, true))
		render.MaterialOverrideByIndex(0, ImgurMaterial(ply:GetNWString("MCSPSkinURL", false), ply, ply:GetPos(), false, "VertexLitGeneric", {
			["$alphatest"] = 1,
			["$halflambert"] = 1,
			["$model"] = 1
		}, true))
	end
end)

hook.Add("PostPlayerDraw", "MCSPRenderSkin", function(ply)
	if IsValid(ply) and ply:GetModel() == MCSPmodel and ply:IsPlayer() then
		render.MaterialOverrideByIndex(0, "")
		render.MaterialOverrideByIndex(1, "")
	end
end)

hook.Add("CreateClientsideRagdoll", "DrawMinecraftPlayerRagdolls", function(ent, ragdoll)
	if IsValid(ent) and IsValid(ragdoll) and ragdoll:GetModel() == MCSPmodel and ent:GetNWString("MCSPSkinURL", false) then
		ragdoll:SetSubMaterial(1, "!"..ImgurMaterial(ent:GetNWString("MCSPSkinURL", false), ent, ent:GetPos(), false, "VertexLitGeneric", {
			["$opaque"] = 1,
			["$halflambert"] = 1,
			["$model"] = 1
		}, true):GetName())
		ragdoll:SetSubMaterial(0, "!"..ImgurMaterial(ent:GetNWString("MCSPSkinURL", false), ent, ent:GetPos(), false, "VertexLitGeneric", {
			["$alphatest"] = 1,
			["$halflambert"] = 1,
			["$model"] = 1
		}, true):GetName())
	end
end)
