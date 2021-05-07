-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local Player = FindMetaTable('Player')
local Entity = FindMetaTable('Entity')
SS_MaterialCache = {}

function SS_GetMaterial(nam)
    SS_MaterialCache[nam] = SS_MaterialCache[nam] or Material(nam)

    return SS_MaterialCache[nam]
end

function SS_PreRender(item)
    if item.cfg.imgur then
        local imat = ImgurMaterial({
            id = item.cfg.imgur.url,
            owner = item.owner,
            pos = IsValid(item.owner) and item.owner:IsPlayer() and item.owner:GetPos(),
            stretch = true,
            shader = "VertexLitGeneric",
            params = [[{["$alphatest"]=1}]]
        })

        render.MaterialOverride(imat)
        --render.OverrideDepthEnable(true,true)
    else
        local mat = item.cfg.material or item.material

        if mat then
            render.MaterialOverride(SS_GetMaterial(mat))
        end
    end

    local col = item.cfg.color or item.color

    if col then
        render.SetColorModulation(col.x, col.y, col.z)
    end
end

function SS_PostRender()
    render.SetColorModulation(1, 1, 1)
    render.MaterialOverride()
    --render.OverrideDepthEnable(false)
end

hook.Add("PrePlayerDraw", "SS_BoneMods", function(ply)
    -- will be "false" if the model is not mounted yet
    local mounted_model = require_workshop_model(ply:GetModel()) and ply:GetModel()
    if not ply:Alive() then return true end

    if ply.SS_PlayermodelModsLastModel ~= mounted_model then
        ply.SS_PlayermodelModsClean = false
        --seems to have issues if you apply the bone mods as soon as the model changes...
        --timer.Simple(1, function() if IsValid(ply) then ply.SS_PlayermodelModsClean = false end end)
    end

    if not ply.SS_PlayermodelModsClean then
        ply.SS_PlayermodelModsClean = SS_ApplyBoneMods(ply, ply:SS_GetActivePlayermodelMods())
        ply.SS_PlayermodelModsLastModel = mounted_model
    end

    SS_ApplyMaterialMods(ply, ply:SS_GetActivePlayermodelMods())
end)

local function AddScaleRecursive(ent, b, scn, recurse, safety)
    if safety[b] then
        error("BONE LOOP!")
    end

    safety[b] = true
    local sco = ent:GetManipulateBoneScale(b)
    sco.x = sco.x * scn.x
    sco.y = sco.y * scn.y
    sco.z = sco.z * scn.z

    if ent:GetModel() == "models/milaco/minecraft_pm/minecraft_pm.mdl" then
        sco.x = math.min(sco.x, 1)
        sco.y = math.min(sco.y, 1)
        sco.z = math.min(sco.z, 1)
    end

    ent:ManipulateBoneScale(b, sco)

    if recurse then
        for i, v in ipairs(ent:GetChildBones(b)) do
            AddScaleRecursive(ent, v, scn, recurse, safety)
        end
    end
end

--only bone scale right now...
--if you do pos/angles, must do a combination override to make it work with emotes, vape arm etc
function SS_ApplyBoneMods(ent, mods)
    for x = 0, (ent:GetBoneCount() - 1) do
        ent:ManipulateBoneScale(x, Vector(1, 1, 1))
        ent:ManipulateBonePosition(x, Vector(0, 0, 0))
    end

    if ent:GetModel() == HumanTeamModel or ent:GetModel() == PonyTeamModel then return end
    local pone = isPonyModel(ent:GetModel())
    local suffix = pone and "_p" or "_h"
    --if pelvis has no children, its not ready!
    local pelvis = ent:LookupBone(pone and "LrigPelvis" or "ValveBiped.Bip01_Pelvis")

    if pelvis then
        if #ent:GetChildBones(pelvis) == 0 then return false end
    end

    for _, item in ipairs(mods) do
        if item.bonemod then
            local bn = item.cfg["bone" .. suffix] or (pone and "LrigScull" or "ValveBiped.Bip01_Head1")
            local x = ent:LookupBone(bn)

            if x then
                if (item.configurable or {}).scale then
                    local scn = item.cfg["scale" .. suffix] or Vector(1, 1, 1.5)
                    AddScaleRecursive(ent, x, scn, item.cfg["scale_children" .. suffix], {})
                end

                if (item.configurable or {}).pos then
                    local psn = item.cfg["pos" .. suffix] or Vector(10, 0, 0)

                    --don't allow moving the root bone
                    if ent:GetBoneParent(x) == -1 then
                        psn.x = 0
                        psn.y = 0
                    end

                    local pso = ent:GetManipulateBonePosition(x)
                    pso = pso + psn
                    ent:ManipulateBonePosition(x, pso)
                end
            end
        end
    end

    --clamp the amount of stacking
    for x = 0, (ent:GetBoneCount() - 1) do
        local old = ent:GetManipulateBoneScale(x)
        local mn = 0.125 --0.5*0.5*0.5
        local mx = 3.375 --1.5*1.5*1.5

        if ent.GetNetData and ent:GetNetData('OF') ~= nil then
            mx = 1.5
        end

        old.x = math.Clamp(old.x, mn, mx)
        old.y = math.Clamp(old.y, mn, mx)
        old.z = math.Clamp(old.z, mn, mx)
        ent:ManipulateBoneScale(x, old)
        old = ent:GetManipulateBonePosition(x)
        old.x = math.Clamp(old.x, -8, 8)
        old.y = math.Clamp(old.y, -8, 8)
        old.z = math.Clamp(old.z, -8, 8)
        ent:ManipulateBonePosition(x, old)
    end

    return true
end

function SS_ApplyMaterialMods(ent, mods)
    ent:SetSubMaterial()

    if SS_PPM_SetSubMaterials then
        SS_PPM_SetSubMaterials(ent)
    end

    if ent:GetModel()==HumanTeamModel or ent:GetModel()==PonyTeamModel then return end

    for _, item in ipairs(mods) do
        if item.materialmod then
            local col = item.cfg.color or Vector(1, 1, 1)

            local mat = ImgurMaterial({
                id = (item.cfg.imgur or {}).url or "EG84dgp.png",
                owner = ent,
                pos = IsValid(ent) and ent:IsPlayer() and ent:GetPos(),
                stretch = true,
                shader = "VertexLitGeneric",
                params = string.format('{["$color2"]="[%f %f %f]"}', col.x, col.y, col.z)
            })

            ent:SetSubMaterial(item.cfg.submaterial or 0, "!" .. mat:GetName())
        end
    end
end

local EntityGetModel = Entity.GetModel

-- Entity.SS_True_LookupAttachment = Entity.SS_True_LookupAttachment or Entity.LookupAttachment
-- Entity.SS_True_LookupBone = Entity.SS_True_LookupBone or Entity.LookupBone
-- function Entity:LookupAttachment(id)
--     local mdl = EntityGetModel(self)
--     if self.LookupAttachmentCacheModel ~= mdl then
--         self.LookupAttachmentCache={}
--     end
--     if not self.LookupAttachmentCache[id] then self.LookupAttachmentCache[id] = Entity.SS_True_LookupAttachment(self, id) end
--     return self.LookupAttachmentCache[id]
-- end
-- function Entity:LookupBone(id)
--     local mdl = EntityGetModel(self)
--     if self.LookupBoneCacheModel ~= mdl then
--         self.LookupBoneCache={}
--     end
--     if not self.LookupBoneCache[id] then self.LookupBoneCache[id] = Entity.SS_True_LookupBone(self, id) end
--     return self.LookupBoneCache[id]
-- end
-- function SWITCHH()
--     Entity.LookupAttachment = Entity.SS_True_LookupAttachment
--     Entity.LookupBone = Entity.SS_True_LookupBone
-- end
--TODO: add "defaultcfg" as a standard field in items rather than this hack!
--TODO this is lag causin
function SS_DrawWornCSModel(item, mdl, ent, dontactually)
    local pone = isPonyModel(EntityGetModel(ent))
    local attach = item.wear.attach
    local scale = item.wear.scale
    local translate = item.wear.translate
    local rotate = item.wear.rotate

    if pone and item.wear.pony then
        attach = item.wear.pony.attach or attach
        scale = item.wear.pony.scale or scale
        translate = item.wear.pony.translate or translate
        rotate = item.wear.pony.rotate or rotate
    end

    local cfgk = pone and "wear_p" or "wear_h"

    if item.cfg[cfgk] then
        attach = item.cfg[cfgk].attach or attach
        scale = item.cfg[cfgk].scale or scale
        translate = item.cfg[cfgk].pos or translate
        rotate = item.cfg[cfgk].ang or rotate
    end

    local pos, ang

    if attach == "eyes" then
        local fn = FrameNumber()

        if ent.attachcacheframe ~= fn then
            ent.attachcacheframe = fn
            local attach_id = ent:LookupAttachment("eyes")

            if attach_id then
                local attacht = ent:GetAttachment(attach_id)

                if attacht then
                    ent.attachcache = attacht
                    pos = attacht.Pos
                    ang = attacht.Ang
                end
            end
        else
            local attacht = ent.attachcache

            if attacht then
                pos = attacht.Pos
                ang = attacht.Ang
            end
        end
    else
        local bone_id = ent:LookupBone(SS_Attachments[attach][pone and 2 or 1])

        if bone_id then
            pos, ang = ent:GetBonePosition(bone_id)
        end
    end

    if not pos then
        pos = ent:GetPos()
        ang = ent:GetAngles()
    end

    pos, ang = LocalToWorld(translate, rotate, pos, ang)

    if mdl.scaleapplied ~= scale then
        mdl.scaleapplied = scale

        if isnumber(scale) then
            mdl.matrix = Matrix({
                {scale, 0, 0, 0},
                {0, scale, 0, 0},
                {0, 0, scale, 0},
                {0, 0, 0, 1}
            })
        else
            mdl.matrix = Matrix({
                {scale.x, 0, 0, 0},
                {0, scale.y, 0, 0},
                {0, 0, scale.z, 0},
                {0, 0, 0, 1}
            })
        end

        mdl:EnableMatrix("RenderMultiply", mdl.matrix)
    end

    mdl:SetPos(pos)
    mdl:SetAngles(ang)
    mdl:SetupBones()

    if not dontactually then
        SS_PreRender(item, ent)
        mdl:DrawModel()
        SS_PostRender()
    end
end

hook.Add("DrawOpaqueAccessories", 'SS_DrawPlayerAccessories', function(ply)
    if ply.SS_Items == nil and ply.SS_ShownItems == nil then return end
    if not ply:Alive() then return end
    if EyePos():DistToSqr(ply:GetPos()) > 2000000 then return end
    -- and (GetConVar('thirdperson') and GetConVar('thirdperson'):GetInt() == 0)
    --if ply == LocalPlayer() and GetViewEntity():GetClass() == 'player' then return end
    if GAMEMODE.FolderName == "fatkid" and ply:Team() ~= TEAM_HUMAN then return end

    --in SPADES, the renderboost.lua is disabled!
    for _, prop in ipairs(ply:SS_GetCSModels()) do
        SS_DrawWornCSModel(prop.item, prop.mdl, ply)
    end
end)

SS_GibProps = {}

hook.Add('CreateClientsideRagdoll', 'SS_CreateClientsideRagdoll', function(ply, rag)
    if IsValid(ply) and ply:IsPlayer() then
        --print(rag:GetPhysicsObjectNum(0):GetVelocity())
        local counter = 0

        for k, v in pairs(SS_CSModels[ply] or {}) do
            counter = counter + 1
            if counter > 8 then return end
            vm = v.mdl
            local gib = GibClientProp(vm:GetModel(), vm:GetPos(), vm:GetAngles(), ply:GetVelocity(), 1, 6)

            if vm.matrix then
                gib:EnableMatrix("RenderMultiply", vm.matrix)
            end

            gib.csmodel = v
            gib:SetNoDraw(true)
            table.insert(SS_GibProps, gib)
        end
    end
end)

concommand.Add("ps_proptest", function()
    for j, itm in pairs(SS_Items) do
        local mdl = itm.model
        local gib = GibClientProp(mdl, LocalPlayer():EyePos(), Angle(0, 0, 0), LocalPlayer():GetVelocity(), 1, 6)
        gib = gib:GetPhysicsObject():GetMesh()
        local mins = nil
        local maxs = nil

        for k, v in pairs(gib) do
            local p = v.pos

            if mins then
                mins = Vector(math.min(mins.x, p.x), math.min(mins.y, p.y), math.min(mins.z, p.z))
                maxs = Vector(math.max(maxs.x, p.x), math.max(maxs.y, p.y), math.max(maxs.z, p.z))
            else
                mins = p
                maxs = p
            end
        end

        print(mdl)
        maxs = (maxs - mins)
        print("Vector(" .. tostring(math.Round(maxs.x, 0)) .. ", " .. tostring(math.Round(maxs.y, 0)) .. ", " .. tostring(math.Round(maxs.z, 0)) .. ")")
    end
end)

hook.Add("PostDrawOpaqueRenderables", "SS_RenderGibs", function(depth, sky)
    if sky or depth then return end
    local nextgibs = {}

    while #SS_GibProps > 0 do
        local gib = table.remove(SS_GibProps)

        if IsValid(gib) then
            SS_PreRender(gib.csmodel.item)
            gib:DrawModel()
            SS_PostRender()
            table.insert(nextgibs, gib)
        end
    end

    SS_GibProps = nextgibs
end)

SS_CSModels = SS_CSModels or {}

hook.Add('Think', 'SS_Cleanup', function()
    for ply, mdls in pairs(SS_CSModels) do
        if not IsValid(ply) then
            for k, v in pairs(mdls) do
                v.mdl:Remove()
            end

            SS_CSModels[ply] = nil
        end
    end
end)

--makes a CSModel for a worn item
function SS_CreateWornCSModel(item)
    if item.wear == nil then return end

    return SS_CreateCSModel(item)
end

--makes a CSModel for a product or item
function SS_CreateCSModel(item)
    local mdlname = item.model or item.cfg.model
    if mdlname == nil then return end
    local mdl = ClientsideModel(mdlname, RENDERGROUP_OPAQUE)

    if IsValid(mdl) then
        mdl:SetNoDraw(true)

        return mdl
    end
end

function Player:SS_ClearCSModels()
    for k, v in pairs(SS_CSModels[self] or {}) do
        v.mdl:Remove()
    end

    SS_CSModels[self] = nil
end

function Player:SS_GetCSModels()
    if SS_CSModels[self] == nil then
        SS_CSModels[self] = {}

        for k, item in pairs(self.SS_ShownItems or {}) do
            local mdl = SS_CreateWornCSModel(item)

            if mdl then
                table.insert(SS_CSModels[self], {
                    mdl = mdl,
                    item = item
                })
            end
        end
    end

    return SS_CSModels[self]
end

function Player:SS_GetActivePlayermodelMods()
    local mods = {}

    for k, item in pairs(self.SS_ShownItems or {}) do
        if item.playermodelmod then
            table.insert(mods, item)
        end
    end

    return mods
end
-- function Player:SS_GetActiveMaterialMods()
--     --{[5]="https://i.imgur.com/Ue1qUPf.jpg"}
--     return {}
-- end
-- function thinga()
--     TTT1 = FindMetaTable("Entity")
--     TTT2 = FindMetaTable("Player")
--     TTT2.SetMaterial = function(a, b)
--         TTT1.SetMaterial(a, b)
--         print(a, b)
--     end
-- end