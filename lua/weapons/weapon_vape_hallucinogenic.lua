-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- weapon_vape_hallucinogenic.lua
-- Defines a vape which makes hallucinogenic effects on the user's screen
-- Vape SWEP by Swamp Onions - http://steamcommunity.com/id/swamponions/
if CLIENT then
    include('weapon_vape/cl_init.lua')
else
    include('weapon_vape/init.lua')
end

SWEP.PrintName = "Hallucinogenic Vape"
SWEP.Instructions = "LMB: Rip Fat Clouds\n (Hold and release)\nRMB & Reload: Play Sounds\n\nThis juice contains hallucinogens (don't worry, they're healthy and all-natural)"
SWEP.VapeAccentColor = Vector(0.1, 0.5, 0.4)
SWEP.VapeTankColor = Vector(0.4, 0.25, 0.1)
SWEP.VapeID = 5

if CLIENT then

    local matt = CreateMaterial("screenrefracter", "Refract", {
        ["$refracttint"] = "[1 1 1]"
    })

    local hallucinate1 = CreateMaterial("hallucinate5", "UnlitGeneric", {
        ["$basetexture"]  = "stone/stonewall004a_normal",
        -- ["$refracttint"] = "[1 1 1]"
        -- ["$alpha"] = "255",
    })

    function DrawSelfRefract(str)
        if not HALLUCINOGENICVAPERT or HALLUCINOGENICVAPERT:Width() < ScrW() or HALLUCINOGENICVAPERT:Height() < ScrH() then
            local w, h = math.power2(ScrW()), math.power2(ScrH())
            HALLUCINOGENICVAPERT = GetRenderTargetEx("HALLUCINOGENICVAPERT" .. tostring(w) .. "x" .. tostring(h), w, h, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, 1, 0, IMAGE_FORMAT_RGB888)
        end

        render.CopyRenderTargetToTexture( render.GetScreenEffectTexture() )
        render.CopyRenderTargetToTexture( HALLUCINOGENICVAPERT )

        render.PushRenderTarget(HALLUCINOGENICVAPERT)
        render.BlurRenderTarget(HALLUCINOGENICVAPERT, 6*(1+math.sin(SysTime()*0.7)), 6*(1+math.sin(SysTime()*0.6)), 2)
        -- surface.SetMaterial(hallucinate1)
        -- surface.DrawTexturedRect(0,0,ScrW(),ScrH())
        render.PopRenderTarget()

        matt:SetTexture("$basetexture", render.GetScreenEffectTexture())
        matt:SetTexture("$normalmap", HALLUCINOGENICVAPERT)
    
        -- local inverter = math.sin(SysTime()*0.3)
        -- if inverter > 0 then inverter = inverter^0.2 else inverter=-((-inverter)^0.2) end
        -- print(inverter)

        matt:SetFloat("$refractamount", str )
    
        render.SetMaterial( matt )
        render.DrawScreenQuad()
    end

    hook.Add("RenderScreenspaceEffects", "HallucinogenicVape", function()
        if (vapeHallucinogen or 0) > 0 then
            if vapeHallucinogen > 100 then
                vapeHallucinogen = 100
            end


            local eyeang = LocalPlayer():EyeAngles()
            eyeang.p = eyeang.p + FrameTime() * math.sin(SysTime()*0.6) * 0.3
            eyeang.y = eyeang.y + FrameTime() * math.sin(SysTime()*0.5) * 0.3
            LocalPlayer():SetEyeAngles(eyeang)

            

            local alpha = vapeHallucinogen / 100

            local coloralpha = alpha ^ 0.5
            local distortalpha = math.min(1, ( (alpha*1.1) ^ 3))

            DrawMotionBlur(0.05, alpha, 0)
            
            DrawSelfRefract(distortalpha * 0.04)

            local tab = {}
            tab["$pp_colour_colour"] = 1 + (coloralpha * 0.25)
            tab["$pp_colour_contrast"] = 1 + (coloralpha * 0.8)
            tab["$pp_colour_brightness"] = -0.1 * coloralpha
            DrawColorModify(tab)
        end
    end)

    render.GetScreenEffectTexture(1)

    timer.Create("HallucinogenicVapeCounter", 1, 0, function()
        if (vapeHallucinogen or 0) > 0 then
            vapeHallucinogen = vapeHallucinogen - 1
        end
    end)
end
