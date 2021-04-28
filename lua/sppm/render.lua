-- This file is subject to copyright - contact swampservers@gmail.com for more information.
if CLIENT then
    --TODO remove this shit entirely (conflicts with pointshop)
    -- function PPM:RescaleRIGPART(ent, part, scale)
    --     for k, v in pairs(part) do
    --         --ent:ManipulateBoneScale( v,scale )   --DISABLED CUZ POINTSHOP
    --     end
    -- end

    -- function PPM:RescaleMRIGPART(ent, part, scale)
    --     for k, v in pairs(part) do
    --         --ent:ManipulateBonePosition( v, scale )
    --     end
    -- end

    -- PPM.TailBoneOffsets = {
    --     [39] = Vector(-16.302101, -1.011261, 0),
    --     [40] = Vector(25.726456, -0.000069, 0),
    --     [41] = Vector(40.078480, 0, 0)
    -- }

    -- function PPM:RescaleOFFCETRIGPART(ent, part, scale)
    --     for k, v in pairs(part) do
    --         local thispos = PPM.TailBoneOffsets[v + 1]
    --         --ent:ManipulateBonePosition( v, thispos *(scale-Vector(1,1,1)) )
    --     end
    -- end 

    function PPM.PrePonyDraw(ent, localvals)
        if not PPM.isValidPonyLight(ent) then return end 
        local pony = PPM.getPonyValues(ent, localvals)
        if table.IsEmpty(pony) then return end
        
        -- local SCALEVAL0 = math.Clamp(pony.bodyweight or 1, 0.5, 2)
        -- local SCALEVAL1 = math.Clamp(pony.gender - 1, 0, 1)
        -- PPM:RescaleRIGPART(ent, PPM.rig.leg_FL, Vector(1, 1, 1) * SCALEVAL0)
        -- PPM:RescaleRIGPART(ent, PPM.rig.leg_FR, Vector(1, 1, 1) * SCALEVAL0)
        -- PPM:RescaleRIGPART(ent, PPM.rig.leg_BL, Vector(1, 1, 1) * SCALEVAL0)
        -- PPM:RescaleRIGPART(ent, PPM.rig.leg_BR, Vector(1, 1, 1) * SCALEVAL0)
        --local breathoffs = (math.sin(CurTime())/4)
        -- PPM:RescaleRIGPART(ent, PPM.rig.rear, Vector(1, 1, 1) * (SCALEVAL0 - (SCALEVAL1) * 0.2))
        -- PPM:RescaleRIGPART(ent, PPM.rig.neck, Vector(1, 1, 1) * SCALEVAL0)

        -- PPM:RescaleRIGPART(ent, {3}, Vector(1, 1, 0) * ((SCALEVAL0 - 1) + SCALEVAL1 * 0.1 + 0.9) + Vector(0, 0, 1))

        -- PPM:RescaleMRIGPART(ent, {18}, Vector(0, 0, SCALEVAL1 / 2))

        -- PPM:RescaleMRIGPART(ent, {24}, Vector(0, 0, -SCALEVAL1 / 2))

        -- local SCALEVAL_tail = math.Clamp(pony.tailsize or 1, 0.8, 1.5)
        -- local svts = (SCALEVAL_tail - 1) * 2 + 1
        -- local svtc = (SCALEVAL_tail - 1) / 2 + 1

        -- PPM:RescaleOFFCETRIGPART(ent, {38}, Vector(svtc, svtc, svtc))

        -- PPM:RescaleRIGPART(ent, {38}, Vector(svts, svts, svts))

        -- PPM:RescaleOFFCETRIGPART(ent, {39, 40}, Vector(SCALEVAL_tail, SCALEVAL_tail, SCALEVAL_tail))

        -- PPM:RescaleRIGPART(ent, {39, 40}, Vector(svts, svts, svts))

        if PPM.m_hair1 == nil then return end
        PPM.m_hair1:SetVector("$color2", pony.haircolor1)
        PPM.m_hair2:SetVector("$color2", pony.haircolor2)
        PPM.m_wings:SetVector("$color2", pony.coatcolor)
        PPM.m_horn:SetVector("$color2", pony.coatcolor)
        -- PPM.m_eyel:SetFloat("$ParallaxStrength", 0.2)
        -- PPM.m_eyer:SetFloat("$ParallaxStrength", 0.1)

        if ent.ponydata_tex ~= nil then
            for k, v in pairs(PPM.rendertargettasks) do
                if ent.ponydata_tex[k] ~= nil and ent.ponydata_tex[k] ~= NULL and ent.ponydata_tex[k .. "_draw"] and type(ent.ponydata_tex[k]) == "ITexture" and not ent.ponydata_tex[k]:IsError() then
                    v.renderTrue(ent, pony) --NOTE: these are just changing the texture on the same material for each player and it causes all the lag
                else
                    v.renderFalse(ent, pony) --NOTE: these are just changing the texture on the same material for each player and it causes all the lag
                end
            end
        end
    end

    function HOOK_PrePlayerDraw(PLY)
        if PLY.ponydata ~= nil and IsValid(PLY.ponydata.clothes1) then
                    PLY.ponydata.clothes1:SetNoDraw((not PLY:Alive()) or PLY:GetNoDraw())
        end

        if PLY:GetNoDraw() then return end
        PPM.PrePonyDraw(PLY, false)
        if not PLY:Alive() then return true end
    end

    -- No overrides are being used, no need to unset
    -- function HOOK_PostPlayerDraw(PLY)
    --     if not IsValid(PLY) then return end
    --     if PLY:GetNoDraw() then return end

    --     if (PPM.isLoaded) then
    --         if not PPM.isValidPonyLight(PLY) then return end
    --         if PPM.m_hair1 == nil then return end
    --         --PPM.m_hair1:SetVector( "$color2", Vector(0,0,0) ) 
    --         --PPM.m_hair2:SetVector( "$color2", Vector(0,0,0) )  
    --         PPM.m_body:SetVector("$color2", Vector(1, 1, 1))
    --         PPM.m_wings:SetVector("$color2", Vector(1, 1, 1))
    --         PPM.m_horn:SetVector("$color2", Vector(1, 1, 1))
    --         --PPM.m_eyel:SetFloat( "$ParallaxStrength", 0.1) 
    --         --PPM.m_eyer:SetFloat( "$ParallaxStrength", 0.1) 
    --         --local textureTest = PPM.t_eyes[1][1]:GetTexture("$basetexture")
    --         --if textureTest == nil then return end
    --         --PPM.m_eyel:SetTexture( "$Iris", textureTest )
    --         --PPM.m_eyer:SetTexture( "$Iris", PPM.t_eyes[1][1]:GetTexture("$detail") )
    --         PPM.m_cmark:SetTexture("$basetexture", PPM.m_cmarks[1][2]:GetTexture("$basetexture"))
    --         PPM.m_body:SetTexture("$basetexture", PPM.m_bodyf:GetTexture("$basetexture"))
    --     end
    -- end

    function HOOK_PostDrawOpaqueRenderables()
        if (not PPM.isLoaded) then
            PPM.LOAD()
        end

        --//////////////////RENDER
        for i, ent in pairs(PPM.ActivePonies) do
            --and ent:Visible( LocalPlayer() )
            if (IsValid(ent) and (not ent:GetNoDraw())) then
                if (not ent:IsPlayer()) then
                    if (PPM.isValidPonyLight(ent)) then
                        if (ent:IsNPC()) then
                            ent:SetNoDraw(true)
                            PPM.PrePonyDraw(ent, false)
                            ent:DrawModel()
                        elseif (table.HasValue(PPM.VALIDPONY_CLASSES, ent:GetClass()) or string.match(ent:GetClass(), "^(npc_)") ~= nil) then
                            if (not ent.isEditorPony) then
                                --if(!PPM.isValidPony(ent)) then
                                --PPM.randomizePony(ent)
                                --end
                                ent:SetNoDraw(true)

                                if (ent.ponydata ~= nil and ent.ponydata.useLocalData) then
                                    PPM.PrePonyDraw(ent, true)
                                else
                                    PPM.PrePonyDraw(ent, false)
                                end

                                --ent:SetupBones( )
                                ent:DrawModel()
                            end
                        end
                    end
                else --///////////PONY IS PLAYER
                    local plyrag = ent:GetRagdollEntity()

                    if (plyrag ~= nil) then
                        if PPM.isValidPonyLight(plyrag) then
                            if (not PPM.isValidPony(plyrag)) then
                                PPM.setupPony(plyrag)
                                PPM.copyPonyTo(ent, plyrag)
                                PPM.copyLocalTextureDataTo(ent, plyrag)
                                plyrag.ponydata.useLocalData = true
                                PPM.setBodygroups(plyrag, true)
                                plyrag:SetNoDraw(true)

                                if ent.ponydata ~= nil then
                                    if plyrag.clothes1 == nil then
                                        plyrag.clothes1 = ClientsideModel("models/ppm/player_default_clothes1.mdl", RENDERGROUP_TRANSLUCENT)

                                        if IsValid(plyrag.clothes1) then
                                            plyrag.clothes1:SetParent(plyrag)
                                            plyrag.clothes1:AddEffects(EF_BONEMERGE)

                                            if IsValid(ent.ponydata.clothes1) then
                                                for I = 1, 14 do
                                                    --MsgN(I,ent.ponydata.clothes1:GetBodygroup( I ))
                                                    PPM.setBodygroupSafe(plyrag.clothes1, I, ent.ponydata.clothes1:GetBodygroup(I))
                                                end
                                            end

                                            plyrag:CallOnRemove("clothing del", function()
                                                plyrag.clothes1:Remove()
                                            end)
                                        end
                                    end
                                end
                            else
                                PPM.PrePonyDraw(plyrag, true)
                                plyrag:DrawModel()
                            end
                        end
                    else
                        if ent.ponydata == nil then
                            PPM.setupPony(ent)
                        end

                        if ent.ponydata.clothes1 == nil or ent.ponydata.clothes1 == NULL then
                            ent.ponydata.clothes1 = ent:GetNetworkedEntity("pny_clothing")
                        end
                    end
                end
            end
        end
    end

    PPM.VALIDPONY_CLASSES = {"player", "prop_ragdoll", "prop_physics", "cpm_pony_npc"}

    local pony_check_idx = 0

    hook.Add("PreDrawHUD", "pony_render_textures3", function()
        pony_check_idx = pony_check_idx + 1
        local ent = PPM.ActivePonies[math.mod(pony_check_idx, #(PPM.ActivePonies)) + 1]
        if not IsValid(ent) then return end

        if (PPM.isValidPonyLight(ent)) then
            local pony = PPM.getPonyValues(ent, ent.isEditorPony)

            if (not PPM.isValidPony(ent)) then
                PPM.setupPony(ent)
            end

            local texturespreframe = 1
            if not PPM.rendertargettasks then return end

            for k, v in pairs(PPM.rendertargettasks) do
                if (PPM.TextureIsOutdated(ent, k, v.hash(pony))) then
                    if texturespreframe > 0 then
                        ent.ponydata_tex = ent.ponydata_tex or {}
                        PPM.currt_ent = ent
                        PPM.currt_ponydata = pony
                        PPM.currt_success = false
                        ent.ponydata_tex[k] = PPM.CreateTexture(tostring(ent:EntIndex()) .. k, v)
                        ent.ponydata_tex[k .. "_hash"] = v.hash(pony)
                        ent.ponydata_tex[k .. "_draw"] = PPM.currt_success
                        texturespreframe = texturespreframe - 1
                    end
                end
            end
        end
    end)

    hook.Add("PostDrawOpaqueRenderables", "test_Redraw", HOOK_PostDrawOpaqueRenderables)
    hook.Add("PrePlayerDraw", "pony_draw", HOOK_PrePlayerDraw)
    -- hook.Add("PostPlayerDraw", "pony_postdraw", HOOK_PostPlayerDraw)
    -- CreateClientConVar("ppm_oldeyes", "0", true, false)
    concommand.Add("ppm_regen", function(ply, cmd, args)
        print("REGENERATING TEXTURES")

        for i, ent in pairs(PPM.ActivePonies) do
            ent.ponydata_tex = nil
        end
    end)
end