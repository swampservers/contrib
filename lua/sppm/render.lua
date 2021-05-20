﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
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
        print("REQ", ply)
        net.WriteEntity(ply)
        net.SendToServer()
        ply.UpdatedPony = true
    end

    PPM_PONIES_NEARBY[ply] = true

    for k, v in ipairs(ply.ponymaterials or {}) do
        if k == 10 and ((ply.ponydata or {}).imgurcmark or "") ~= "" then
            -- big TODO: make imgur materials return a single material, and update the texture in think hook, so we dont need to reapply them constantly!!!!
            v = ImgurMaterial({
                id = ply.ponydata.imgurcmark,
                owner = ent,
                pos = IsValid(ent) and ent:IsPlayer() and ent:GetPos(),
                stretch = false,
                shader = "VertexLitGeneric",
                params = [[{["$translucent"]=1}]]
            })
        end

        ent:SetSubMaterial(k - 1, "!" .. v:GetName())
    end

    -- Only applies to editor models; ragdolls are handled in hook below and players are handled serverside
    if ent:EntIndex() == -1 then
        PPM_SetBodyGroups(ent)
    end
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

local UNIQUEVALUE = tostring(os.time())

-- draw textures
hook.Add("PreDrawHUD", "PPM_PreDrawHUD", function()
    for ply, _ in pairs(PPM_PONIES_NEARBY) do
        if ply.ponydata and not ply.ponymaterials then
            ply.ponydata_tex = {} -- todo remove this
            ply.ponymaterials = {}

            for _, v in ipairs(PPM_player_mat) do
                table.insert(ply.ponymaterials, PPM_CLONE_MATERIAL(v))
            end

            for k, v in pairs(PPM.rendertargettasks or {}) do
                PPM.currt_ent = ply
                PPM.currt_ponydata = ply.ponydata
                PPM.currt_success = false
                ply.ponydata_tex[k] = PPM_CreateTexture(UNIQUEVALUE .. tostring(ply:EntIndex()) .. k, v)
                -- ply.ponydata_tex[k .. "_hash"] = v.hash(pony) --remove
                ply.ponydata_tex[k .. "_draw"] = PPM.currt_success -- remove
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

PPM_NEXT_CLONE_MAT = PPM_NEXT_CLONE_MAT or 0

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
    -- IsPPMPony check added because of outfitter issue
    if entity:IsPlayer() and entity:IsPPMPony() then
        ragdoll.RagdollSourcePlayer = entity
        PPM_SetBodyGroups(ragdoll)
        ragdoll.RenderOverride = PPM_RagdollRender
    end
end)