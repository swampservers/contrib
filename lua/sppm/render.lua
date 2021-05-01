-- This file is subject to copyright - contact swampservers@gmail.com for more information.
function PPM_SetPonyCfg(ent, cfg)
    ent.ponydata = cfg
    -- invalidate caches
    ent.ponymaterials = nil
end

function PPM_UpdateLocalPonyCfg(k, v)
    local ent = LocalPlayer()
    ent.ponydata[k] = v
    ent.ponymaterials = nil
end

PPM_PONIES_NEARBY = {}

function PPM_PrePonyDraw(ent)
    if not ent:IsPPMPony() then return end
    local ply = ent:PonyPlayer() -- conversion shop/editor model and ragdoll
    if not IsValid(ply) then return end

    if not ply.UpdatedPony then
        net.Start("PonyRequest")
        net.WriteEntity(ply)
        net.SendToServer()
        ply.UpdatedPony = true
    end

    PPM_PONIES_NEARBY[ply] = true

    for k, v in ipairs(ply.ponymaterials or {}) do
        ent:SetSubMaterial(k - 1, "!" .. v:GetName())
    end

    if ((ply.ponydata or {}).imgurcmark or "") ~= "" then
        local mat = ImgurMaterial(ply.ponydata.imgurcmark, ent, IsValid(ent) and ent:IsPlayer() and ent:GetPos(), true, "VertexLitGeneric", {
            ["$translucent"] = 1
        })

        ent:SetSubMaterial(9, "!" .. mat:GetName())
    end

    -- Only applies to editor models; ragdolls are handled in hook below and players are handled serverside
    if ent:EntIndex() == -1 then
        PPM_SetBodyGroups(ent)
    end
end

function PPM.PrePonyDraw(ent, localvals)
    -- if true then return end
    -- if ent:IsPlayer() and ent.ponydata ~= nil and IsValid(ent.ponydata.clothes1) then
    --     ent.ponydata.clothes1:SetNoDraw(not ent:Alive())
    -- end
    -- if not PPM.isValidPonyLight(ent) then return end
    -- local pony = PPM.getPonyValues(ent, localvals)
    -- if table.IsEmpty(pony) then return end
    -- if IsValid(LocalPlayer()) and LocalPlayer():Nick() == "Joker Gaming" and NEWPONYZ == nil then
    --     NEWPONYZ = true
    -- end
    -- if NEWPONYZ then
    --     if ent:EntIndex() == -1 then
    --         print("CSMODEL")
    --         ent:SetSubMaterial()
    --         for k, v in pairs(PPM.rendertargettasks) do
    --             v.render(ent, pony)
    --         end
    --         return
    --     else
    --         if ent.ponydata_tex then
    --             for k, v in pairs(PPM.rendertargettasks) do
    --                 -- print(k, ent.ponydata_tex[k.."_mat"])       
    --                 for i, v2 in ipairs(ent.ponydata_tex[k .. "_mat"] or {}) do
    --                     -- print(i)
    --                     ent:SetSubMaterial(v2[2] - 1, "!" .. v2[1]:GetName())
    --                 end
    --             end
    --         end
    --     end
    --     -- material gets updated as it loads so its a special case
    --     if (pony.imgurcmark or "") ~= "" then
    --         -- if ENT.isEditorPony then
    --         --     ENT.imgurcmark = PONY.imgurcmark
    --         --     PONY = ENT
    --         -- end
    --         local mat = ImgurMaterial(pony.imgurcmark, ent, IsValid(ent) and ent:IsPlayer() and ent:GetPos(), true, "VertexLitGeneric", {
    --             ["$translucent"] = 1
    --         })
    --         ent:SetSubMaterial(9, "!" .. mat:GetName())
    --     end
    --     return
    -- end
    -- if PPM.m_hair1 == nil then return end
    -- PPM.m_hair1:SetVector("$color2", pony.haircolor1)
    -- PPM.m_hair2:SetVector("$color2", pony.haircolor2)
    -- PPM.m_wings:SetVector("$color2", pony.coatcolor)
    -- PPM.m_horn:SetVector("$color2", pony.coatcolor)
    -- if ent.ponydata_tex ~= nil then
    --     --NOTE: these are just changing the texture on the same material for each player and it causes all the lag
    --     for k, v in pairs(PPM.rendertargettasks) do
    --         v.render(ent, pony)
    --     end
    -- end
end

-- gets removed when the shop is present
hook.Add("PrePlayerDraw", "PPM_PrePlayerDraw", function(ply)
    if not ply:Alive() then return true end
    ply:SetSubMaterial()
    PPM_PrePonyDraw(ply)
end)

-- alternate path so sps materials stack correctly
function SS_PPM_SetSubMaterials(ent)
    hook.Remove("PrePlayerDraw", "PPM_PrePlayerDraw")
    RP_PUSH("ponydraw")
    PPM_PrePonyDraw(ent)
    RP_POP()
end

-- hook.Add("PostDrawOpaqueRenderables", "test_Redraw", function()
--     if (not PPM.isLoaded) then
--         PPM.LOAD()
--     end
--     --//////////////////RENDER
--     for i, ent in pairs(PPM.ActivePonies) do
--         --and ent:Visible( LocalPlayer() )
--         if (IsValid(ent) and (not ent:GetNoDraw())) then
--             if (not ent:IsPlayer()) then
--                 if (PPM.isValidPonyLight(ent)) then
--                     if (ent:IsNPC()) then
--                         ent:SetNoDraw(true)
--                         PPM.PrePonyDraw(ent, false)
--                         ent:DrawModel()
--                     elseif (table.HasValue(PPM.VALIDPONY_CLASSES, ent:GetClass()) or string.match(ent:GetClass(), "^(npc_)") ~= nil) then
--                         if (not ent.isEditorPony) then
--                             --if(!PPM.isValidPony(ent)) then
--                             --PPM.randomizePony(ent)
--                             --end
--                             ent:SetNoDraw(true)
--                             if (ent.ponydata ~= nil and ent.ponydata.useLocalData) then
--                                 PPM.PrePonyDraw(ent, true)
--                             else
--                                 PPM.PrePonyDraw(ent, false)
--                             end
--                             --ent:SetupBones( )
--                             ent:DrawModel()
--                         end
--                     end
--                 end
--             else --///////////PONY IS PLAYER
--                 local plyrag = ent:GetRagdollEntity()
--                 if (plyrag ~= nil) then
--                     if PPM.isValidPonyLight(plyrag) then
--                         if (not PPM.isValidPony(plyrag)) then
--                             PPM.setupPony(plyrag)
--                             PPM.copyPonyTo(ent, plyrag)
--                             PPM.copyLocalTextureDataTo(ent, plyrag)
--                             plyrag.ponydata.useLocalData = true
--                             PPM.setBodygroups(plyrag, true)
--                             plyrag:SetNoDraw(true)
--                             if ent.ponydata ~= nil then
--                                 if plyrag.clothes1 == nil then
--                                     plyrag.clothes1 = ClientsideModel("models/ppm/player_default_clothes1.mdl", RENDERGROUP_TRANSLUCENT)
--                                     if IsValid(plyrag.clothes1) then
--                                         plyrag.clothes1:SetParent(plyrag)
--                                         plyrag.clothes1:AddEffects(EF_BONEMERGE)
--                                         if IsValid(ent.ponydata.clothes1) then
--                                             for I = 1, 14 do
--                                                 --MsgN(I,ent.ponydata.clothes1:GetBodygroup( I ))
--                                                 PPM.setBodygroupSafe(plyrag.clothes1, I, ent.ponydata.clothes1:GetBodygroup(I))
--                                             end
--                                         end
--                                         plyrag:CallOnRemove("clothing del", function()
--                                             plyrag.clothes1:Remove()
--                                         end)
--                                     end
--                                 end
--                             end
--                         else
--                             PPM.PrePonyDraw(plyrag, true)
--                             plyrag:DrawModel()
--                         end
--                     end
--                 else
--                     if ent.ponydata == nil then
--                         PPM.setupPony(ent)
--                     end
--                     if ent.ponydata.clothes1 == nil or ent.ponydata.clothes1 == NULL then
--                         ent.ponydata.clothes1 = ent:GetNetworkedEntity("pny_clothing")
--                     end
--                 end
--             end
--         end
--     end
-- end)
-- PPM.VALIDPONY_CLASSES = {"player", "prop_ragdoll", "prop_physics", "cpm_pony_npc"}
-- local pony_check_idx = 0
-- hook.Add("PreDrawHUD", "pony_render_textures3", function()
--     pony_check_idx = pony_check_idx + 1
--     local ent = PPM.ActivePonies[math.mod(pony_check_idx, #(PPM.ActivePonies)) + 1]
--     if not IsValid(ent) then return end
--     if PPM.isValidPonyLight(ent) then
--         local pony = PPM.getPonyValues(ent, ent.isEditorPony)
--         if not PPM.isValidPony(ent) then
--             PPM.setupPony(ent)
--         end
--         for k, v in pairs(PPM.rendertargettasks or {}) do
--             if (PPM.TextureIsOutdated(ent, k, v.hash(pony))) then
--                 ent.ponydata_tex = ent.ponydata_tex or {}
--                 PPM.currt_ent = ent
--                 PPM.currt_ponydata = pony
--                 PPM.currt_success = false
--                 ent.ponydata_tex[k] = PPM.CreateTexture(tostring(ent:EntIndex()) .. k, v)
--                 ent.ponydata_tex[k .. "_hash"] = v.hash(pony)
--                 ent.ponydata_tex[k .. "_draw"] = PPM.currt_success
--                 -- if PPM.currt_success then
--                 ent.ponydata_tex[k .. "_mat"] = PPM_CLONE_MATERIALS(v.render(ent, pony))
--                 -- end
--                 -- print(ent, k)
--                 -- once per frame
--                 return
--             end
--         end
--     end
-- end)
-- draw textures
hook.Add("PreDrawHUD", "PPM_PreDrawHUD", function()
    for ply, _ in pairs(PPM_PONIES_NEARBY) do
        if ply.ponydata and not ply.ponymaterials then
            ply.ponydata_tex = {} --todo remove this
            ply.ponymaterials = {}

            for _, v in ipairs(PPM_player_mat) do
                table.insert(ply.ponymaterials, PPM_CLONE_MATERIAL(v))
            end

            for k, v in pairs(PPM.rendertargettasks or {}) do
                PPM.currt_ent = ply
                PPM.currt_ponydata = ply.ponydata
                PPM.currt_success = false
                ply.ponydata_tex[k] = PPM.CreateTexture(tostring(ply:EntIndex()) .. k, v)
                -- ply.ponydata_tex[k .. "_hash"] = v.hash(pony) --remove
                ply.ponydata_tex[k .. "_draw"] = PPM.currt_success --remove
                -- if PPM.currt_success then 
                v.render(ply, ply.ponymaterials)
                -- print(k)
                -- mats = PPM_CLONE_MATERIALS(mats)
                -- for _,v in ipairs(mats) do
                --     ply.ponymaterials[v[2]] = v[1]
                -- end
                -- ent.ponydata_tex[k .. "_mat"] = 
                -- end
                -- print(ent, k)
                -- once per frame
                -- return
                -- end
            end
        end
    end

    PPM_PONIES_NEARBY = {}
end)

PPM_NEXT_CLONE_MAT = PPM_NEXT_CLONE_MAT or 1

function PPM_CLONE_MATERIAL(mat)
    PPM_NEXT_CLONE_MAT = PPM_NEXT_CLONE_MAT + 1
    local kvs = mat:GetKeyValues()
    local junk = {}

    for i, v in ipairs({"$flags", "$flags2", "$flags_defined", "$flags_defined2"}) do
        junk[v] = kvs[v]
        kvs[v] = nil
    end

    for k, v in pairs(kvs) do
        if type(v) == "ITexture" then
            kvs[k] = v:GetName()
        end

        if type(v) == "Vector" then
            kvs[k] = "[" .. tostring(v) .. "]"
        end

        if type(v) == "VMatrix" then
            assert(v:IsIdentity())
            kvs[k] = nil
        end

        if type(v) == "number" then
            kvs[k] = tostring(v)
        end

        if kvs[k] ~= nil then
            assert(type(kvs[k]) == "string")
        end
    end

    -- add os time because of materials getting saved when you rejoin
    local clone = CreateMaterial("PPMCLONE" .. tostring(os.time()) .. "/" .. tostring(PPM_NEXT_CLONE_MAT), mat:GetShader(), kvs)

    for k, v in pairs(junk) do
        clone:SetInt(k, v)
    end

    return clone
end

concommand.Add("ppm_refresh", function(ply, cmd, args)
    for _, ent in ipairs(player.GetAll()) do
        ent.UpdatedPony = nil
        ent.ponydata = nil
        ent.ponymaterials = nil
    end
end)

-- if this causes conflicts maybe just set the materials one time
function PPM_RagdollRender(self)
    PPM_PrePonyDraw(self)
    self:DrawModel()
end

hook.Add("CreateClientsideRagdoll", "PPM_CreateClientsideRagdoll", function(entity, ragdoll)
    if entity:IsPlayer() then
        ragdoll.RagdollSourcePlayer = entity
        PPM_SetBodyGroups(ragdoll)
        ragdoll.RenderOverride = PPM_RagdollRender
    end
end)