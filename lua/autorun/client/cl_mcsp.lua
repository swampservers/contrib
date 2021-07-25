-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local MCSPmodel = "models/milaco/minecraft_pm/minecraft_pm.mdl"

--Material ID 0 is the hat layer, ID 1 is the base layer
-- TODO update when the nwstring changes GM:EntityNetworkedVarChanged(
hook.Add("SetPlayerModelMaterials", "minecraftmats", function(ent, ply)
    if ent:GetModel() == MCSPmodel and ply:GetNWString("MCSPSkinURL", false) then
        ent:SetWebSubMaterial(1, {
            id = ply:GetNWString("MCSPSkinURL", false),
            owner = ply,
            stretch = true,
            pointsample = true,
            shader = "VertexLitGeneric",
            params = [[{["$opaque"]=1,["$halflambert"]=1,["$model"]=1}]]
        })

        ent:SetWebSubMaterial(0, {
            id = ply:GetNWString("MCSPSkinURL", false),
            owner = ply,
            stretch = true,
            pointsample = true,
            shader = "VertexLitGeneric",
            params = [[{["$alphatest"]=1,["$halflambert"]=1,["$model"]=1}]]
        })
    end
end)
-- hook.Add("CreateClientsideRagdoll", "DrawMinecraftPlayerRagdolls", function(ent, ragdoll)
--     if IsValid(ent) and IsValid(ragdoll) and ragdoll:GetModel() == MCSPmodel and ent:GetNWString("MCSPSkinURL", false) then
--         ragdoll:SetSubMaterial(1, "!" .. ImgurMaterial({
--             id = ent:GetNWString("MCSPSkinURL", false),
--             owner = ent,
--             pos = ent:GetPos(),
--             stretch = true,
--             pointsample = true,
--             shader = "VertexLitGeneric",
--             params = [[{["$opaque"]=1,["$halflambert"]=1,["$model"]=1}]]
--         }):GetName())
--         ragdoll:SetSubMaterial(0, "!" .. ImgurMaterial({
--             id = ent:GetNWString("MCSPSkinURL", false),
--             owner = ent,
--             pos = ent:GetPos(),
--             stretch = true,
--             pointsample = true,
--             shader = "VertexLitGeneric",
--             params = [[{["$alphatest"]=1,["$halflambert"]=1,["$model"]=1}]]
--         }):GetName())
--     end
-- end)
