-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- function PPM.TextureIsOutdated(ent, name, newhash)
--     if not PPM.isValidPony(ent) then return true end
--     if ent.ponydata_tex == nil then return true end
--     if ent.ponydata_tex[name] == nil then return true end
--     if ent.ponydata_tex[name .. "_hash"] == nil then return true end
--     if ent.ponydata_tex[name .. "_hash"] ~= newhash then return true end

--     return false
-- end

-- function PPM.GetBodyHash(ponydata)
--     return tostring(ponydata.bodyt0) .. tostring(ponydata.bodyt1) .. tostring(ponydata.coatcolor) .. tostring(ponydata.bodyt1_color)
-- end

function FixVertexLitMaterial(Mat)
    local strImage = Mat:GetName()

    if (string.find(Mat:GetShader(), "VertexLitGeneric") or string.find(Mat:GetShader(), "Cable")) then
        local t = Mat:GetString("$basetexture")

        if (t) then
            local params = {}
            params["$basetexture"] = t
            params["$vertexcolor"] = 1
            params["$vertexalpha"] = 1
            Mat = CreateMaterial(strImage .. "_DImage", "UnlitGeneric", params)
        end
    end

    return Mat
end

function PPM.CreateTexture(tname, data)
    local w, h = ScrW(), ScrH()
    local rttex = nil
    local size = data.size or 512
    rttex = GetRenderTarget(tname, size, size)

    -- ,  RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, bit.bor(2, 256), 0, IMAGE_FORMAT_BGR888)
    if data.predrawfunc ~= nil then
        data.predrawfunc()
    end

    local OldRT = render.GetRenderTarget()
    render.SetRenderTarget(rttex)
    render.SuppressEngineLighting(true)
    cam.IgnoreZ(true)
    render.SetBlend(1)
    render.SetViewPort(0, 0, size, size)
    render.Clear(0, 0, 0, 255, true)
    cam.Start2D()
    render.SetColorModulation(1, 1, 1)

    if data.drawfunc ~= nil then
        data.drawfunc()
    end

    cam.End2D()
    render.SetRenderTarget(OldRT)
    render.SetViewPort(0, 0, w, h)
    render.SetColorModulation(1, 1, 1)
    render.SetBlend(1)
    render.SuppressEngineLighting(false)

    return rttex
end

function PPM.CreateBodyTexture(ent, pony)
    if not PPM.isValidPony(ent) then return end
    local w, h = ScrW(), ScrH()

    --val/512*w end
    local function tW(val)
        return val
    end

    --val/512*h end
    local function tH(val)
        return val
    end

    local rttex = nil
    ent.ponydata_tex = ent.ponydata_tex or {}

    if (ent.ponydata_tex.bodytex ~= nil) then
        rttex = ent.ponydata_tex.bodytex
    else
        rttex = GetRenderTargetEx(tostring(ent) .. "body", tW(512), tH(512), RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, bit.bor(2, 256), 0, IMAGE_FORMAT_BGR888)
    end

    local OldRT = render.GetRenderTarget()
    render.SetRenderTarget(rttex)
    render.SuppressEngineLighting(true)
    cam.IgnoreZ(true)
    render.SetLightingOrigin(Vector(0, 0, 0))
    render.ResetModelLighting(1, 1, 1)
    render.SetColorModulation(1, 1, 1)
    render.SetBlend(1)
    render.SetModelLighting(BOX_TOP, 1, 1, 1)
    render.SetViewPort(0, 0, tW(512), tH(512))
    render.Clear(0, 255, 255, 255, true)
    cam.Start2D()
    render.SetColorModulation(1, 1, 1)

    if (pony.gender == 1) then
        render.SetMaterial(FixVertexLitMaterial(Material("models/ppm/base/render/bodyf")))
    else
        render.SetMaterial(FixVertexLitMaterial(Material("models/ppm/base/render/bodym")))
    end

    render.DrawQuadEasy(Vector(tW(256), tH(256), 0), Vector(0, 0, -1), tW(512), tH(512), Color(pony.coatcolor.x * 255, pony.coatcolor.y * 255, pony.coatcolor.z * 255, 255), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees

    if (pony.bodyt1 > 1) then
        render.SetMaterial(FixVertexLitMaterial(PPM.m_bodydetails[pony.bodyt1 - 1][1]))
        render.SetBlend(1)
        local colorbl = pony.bodyt1_color or Vector(1, 1, 1)
        render.DrawQuadEasy(Vector(tW(256), tH(256), 0), Vector(0, 0, -1), tW(512), tH(512), Color(colorbl.x * 255, colorbl.y * 255, colorbl.z * 255, 255), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees
    end

    if (pony.bodyt0 > 1) then
        render.SetMaterial(FixVertexLitMaterial(PPM.m_bodyt0[pony.bodyt0 - 1][1]))
        render.SetBlend(1)
        render.DrawQuadEasy(Vector(tW(256), tH(256), 0), Vector(0, 0, -1), tW(512), tH(512), Color(255, 255, 255, 255), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees
    end

    cam.End2D()
    render.SetRenderTarget(OldRT) -- Resets the RenderTarget to our screen
    render.SetViewPort(0, 0, w, h)
    render.SetColorModulation(1, 1, 1)
    render.SetBlend(1)
    render.SuppressEngineLighting(false)
    --	cam.IgnoreZ( false )
    ent.ponydata_tex.bodytex = rttex
    --MsgN("HASHOLD: "..tostring(ent.ponydata_tex.bodytex_hash)) 
    -- ent.ponydata_tex.bodytex_hash = PPM.GetBodyHash(pony)
    --MsgN("HASHNEW: "..tostring(ent.ponydata_tex.bodytex_hash)) 
    --MsgN("HASHTAR: "..tostring(PPM.GetBodyHash(outpony))) 

    return rttex
end

function PPM_CheckTexture(ent, k)
    if ent.ponydata_tex and ent.ponydata_tex[k] ~= nil and ent.ponydata_tex[k] ~= NULL and ent.ponydata_tex[k .. "_draw"] and type(ent.ponydata_tex[k]) == "ITexture" and not ent.ponydata_tex[k]:IsError() then
        return true
    else
        return false
    end
end

PPM.currt_success = false
PPM.currt_ent = nil
PPM.currt_ponydata = nil
PPM.rendertargettasks = {}

PPM.rendertargettasks.bodytex = {
    render = function(ent,  mats)
        if PPM_CheckTexture(ent, "bodytex") then
            mats[PPMMAT_BODY]:SetVector("$color2", Vector(1, 1, 1))
            mats[PPMMAT_BODY]:SetTexture("$basetexture", ent.ponydata_tex.bodytex)
        else
            mats[PPMMAT_BODY]:SetVector("$color2", ent.ponydata.coatcolor)

            if (ent.ponydata.gender == 1) then
                mats[PPMMAT_BODY]:SetTexture("$basetexture", PPM.m_bodyf:GetTexture("$basetexture"))
            else
                mats[PPMMAT_BODY]:SetTexture("$basetexture", PPM.m_bodym:GetTexture("$basetexture"))
            end
        end

        -- PPM.m_hair1:SetVector("$color2", ent.ponydata.haircolor1)
        -- PPM.m_hair2:SetVector("$color2", ent.ponydata.haircolor2)
        mats[PPMMAT_WINGS]:SetVector("$color2", ent.ponydata.coatcolor)
        mats[PPMMAT_HORN]:SetVector("$color2", ent.ponydata.coatcolor)
    end,
    drawfunc = function()
        local pony = PPM.currt_ponydata

        if (pony.gender == 1) then
            render.SetMaterial(FixVertexLitMaterial(Material("models/ppm/base/render/bodyf")))
        else
            render.SetMaterial(FixVertexLitMaterial(Material("models/ppm/base/render/bodym")))
        end

        render.DrawQuadEasy(Vector(256, 256, 0), Vector(0, 0, -1), 512, 512, Color(pony.coatcolor.x * 255, pony.coatcolor.y * 255, pony.coatcolor.z * 255, 255), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees

        --MsgN("render.body.prep")
        for C = 1, 8 do
            local detailvalue = pony["bodydetail" .. C] or 1
            local detailcolor = pony["bodydetail" .. C .. "_c"] or Vector(0, 0, 0)

            if (detailvalue > 1) then
                local mat = PPM.m_bodydetails[detailvalue - 1]

                if mat then
                    mat = mat[1]
                end

                if not mat then continue end
                render.SetMaterial(mat)
                render.SetBlend(1)
                render.DrawQuadEasy(Vector(256, 256, 0), Vector(0, 0, -1), 512, 512, Color(detailcolor.x * 255, detailcolor.y * 255, detailcolor.z * 255, 255), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees
            end
        end

        local pbt = pony.bodyt0 or 1

        if (pbt > 1) then
            local mmm = PPM.m_bodyt0[pbt - 1]

            if (mmm ~= nil) then
                render.SetMaterial(FixVertexLitMaterial(mmm)) --Material("models/ppm/base/render/clothes_sbs_full")) 
                --surface.SetTexture( surface.GetTextureID( "models/ppm/base/render/horn" ) )
                render.SetBlend(1)
                render.DrawQuadEasy(Vector(256, 256, 0), Vector(0, 0, -1), 512, 512, Color(255, 255, 255, 255), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees
            end
        end

        PPM.currt_success = true
    end
    -- ,
    -- hash = function(ponydata)
    --     local hash = tostring(ponydata.bodyt0) .. tostring(ponydata.coatcolor) .. tostring(ponydata.gender)

    --     for C = 1, 8 do
    --         local detailvalue = ponydata["bodydetail" .. C] or 1
    --         local detailcolor = ponydata["bodydetail" .. C .. "_c"] or Vector(0, 0, 0)
    --         hash = hash .. tostring(detailvalue) .. tostring(detailcolor)
    --     end

    --     return hash
    -- end
}

local _cleantexture = Material("models/ppm/partrender/clean.png"):GetTexture("$basetexture")

PPM.rendertargettasks.hairtex1 = {
    render = function(ent, mats)
        if PPM_CheckTexture(ent, "hairtex1") then
            mats[PPMMAT_HAIR1]:SetVector("$color2", Vector(1, 1, 1))
            mats[PPMMAT_HAIR1]:SetTexture("$basetexture", ent.ponydata_tex.hairtex1)
        else
            mats[PPMMAT_HAIR1]:SetVector("$color2", ent.ponydata.haircolor1)
            mats[PPMMAT_HAIR1]:SetTexture("$basetexture", _cleantexture)
        end

    end,
    --PPM.m_hair2:SetTexture("$basetexture",Material("models/ppm/partrender/clean.png"):GetTexture("$basetexture")) 
    drawfunc = function()
        local pony = PPM.currt_ponydata
        render.Clear(pony.haircolor1.x * 255, pony.haircolor1.y * 255, pony.haircolor1.z * 255, 255, true)
        PPM.tex_drawhairfunc(pony, "up", false)
    end
    -- ,
    -- hash = function(ponydata) return tostring(ponydata.haircolor1) .. tostring(ponydata.haircolor2) .. tostring(ponydata.haircolor3) .. tostring(ponydata.haircolor4) .. tostring(ponydata.haircolor5) .. tostring(ponydata.haircolor6) .. tostring(ponydata.mane) .. tostring(ponydata.manel) end
}

PPM.rendertargettasks.hairtex2 = {
    render = function(ent, mats)
        if PPM_CheckTexture(ent, "hairtex2") then
            mats[PPMMAT_HAIR2]:SetVector("$color2", Vector(1, 1, 1))
            mats[PPMMAT_HAIR2]:SetTexture("$basetexture", ent.ponydata_tex.hairtex2)
        else
            mats[PPMMAT_HAIR2]:SetVector("$color2", ent.ponydata.haircolor2)
            mats[PPMMAT_HAIR2]:SetTexture("$basetexture", _cleantexture)
        end

    end,
    drawfunc = function()
        local pony = PPM.currt_ponydata
        PPM.tex_drawhairfunc(pony, "dn", false)
    end
    -- ,
    -- hash = function(ponydata) return tostring(ponydata.haircolor1) .. tostring(ponydata.haircolor2) .. tostring(ponydata.haircolor3) .. tostring(ponydata.haircolor4) .. tostring(ponydata.haircolor5) .. tostring(ponydata.haircolor6) .. tostring(ponydata.mane) .. tostring(ponydata.manel) end
}

PPM.rendertargettasks.tailtex = {
    render = function(ent, mats)
        if PPM_CheckTexture(ent, "tailtex") then
            print("TAILTEX", ent)
            mats[PPMMAT_TAIL1]:SetVector("$color2", Vector(1, 1, 1))
            mats[PPMMAT_TAIL2]:SetVector("$color2", Vector(1, 1, 1))
            mats[PPMMAT_TAIL1]:SetTexture("$basetexture", ent.ponydata_tex.tailtex)
        else
            print("TAIL", ent, ent.ponydata.haircolor1,ent.ponydata.haircolor2)
            mats[PPMMAT_TAIL1]:SetVector("$color2", ent.ponydata.haircolor1)
            mats[PPMMAT_TAIL2]:SetVector("$color2", ent.ponydata.haircolor2)
            mats[PPMMAT_TAIL1]:SetTexture("$basetexture", _cleantexture)
            mats[PPMMAT_TAIL2]:SetTexture("$basetexture", _cleantexture)
        end
    end,
    drawfunc = function()
        local pony = PPM.currt_ponydata
        PPM.tex_drawhairfunc(pony, "up", true)
    end
    -- ,
    -- hash = function(ponydata) return tostring(ponydata.haircolor1) .. tostring(ponydata.haircolor2) .. tostring(ponydata.haircolor3) .. tostring(ponydata.haircolor4) .. tostring(ponydata.haircolor5) .. tostring(ponydata.haircolor6) .. tostring(ponydata.tail) end
}

PPM.rendertargettasks.eyeltex = {
    render = function(ent, mats)
        if PPM_CheckTexture(ent, "eyeltex") then
            mats[PPMMAT_EYEL]:SetTexture("$Iris", ent.ponydata_tex.eyeltex)
        else
            mats[PPMMAT_EYEL]:SetTexture("$Iris", _cleantexture)
        end
    end,
    drawfunc = function()
        local pony = PPM.currt_ponydata
        PPM.tex_draweyefunc(pony, false)
    end
    -- ,
    -- hash = function(ponydata) return tostring(ponydata.eyecolor_bg) .. tostring(ponydata.eyecolor_iris) .. tostring(ponydata.eyecolor_grad) .. tostring(ponydata.eyecolor_line1) .. tostring(ponydata.eyecolor_line2) .. tostring(ponydata.eyecolor_hole) .. tostring(ponydata.eyeirissize) .. tostring(ponydata.eyeholesize) .. tostring(ponydata.eyejholerssize) .. tostring(ponydata.eyehaslines) end
}

PPM.rendertargettasks.eyertex = {
    render = function(ent, mats)
        if PPM_CheckTexture(ent, "eyertex") then
            mats[PPMMAT_EYER]:SetTexture("$Iris", ent.ponydata_tex.eyertex)
        else
            mats[PPMMAT_EYER]:SetTexture("$Iris", _cleantexture)
        end

    end,
    drawfunc = function()
        local pony = PPM.currt_ponydata
        PPM.tex_draweyefunc(pony, true)
    end
    -- ,
    -- hash = function(ponydata) return tostring(ponydata.eyecolor_bg) .. tostring(ponydata.eyecolor_iris) .. tostring(ponydata.eyecolor_grad) .. tostring(ponydata.eyecolor_line1) .. tostring(ponydata.eyecolor_line2) .. tostring(ponydata.eyecolor_hole) .. tostring(ponydata.eyeirissize) .. tostring(ponydata.eyeholesize) .. tostring(ponydata.eyejholerssize) .. tostring(ponydata.eyehaslines) end
}

PPM.tex_drawhairfunc = function(pony, UPDN, TAIL)
    local hairnum = pony.mane

    if UPDN == "dn" then
        hairnum = pony.manel
    elseif TAIL then
        hairnum = pony.tail
    end

    PPM.hairrenderOp(UPDN, TAIL, hairnum)
    local colorcount = PPM.manerender[UPDN .. hairnum]

    if TAIL then
        colorcount = PPM.manerender["tl" .. hairnum]
    end

    if colorcount ~= nil then
        local coloroffset = colorcount[1]

        if UPDN == "up" then
            coloroffset = 0
        end

        local prephrase = UPDN .. "mane_"

        if TAIL then
            prephrase = "tail_"
        end

        colorcount = colorcount[2]
        local backcolor = pony["haircolor" .. (coloroffset + 1)] or PPM.defaultHairColors[coloroffset + 1]
        render.Clear(backcolor.x * 255, backcolor.y * 255, backcolor.z * 255, 255, true)

        for I = 0, colorcount - 1 do
            local color = pony["haircolor" .. (I + 2 + coloroffset)] or PPM.defaultHairColors[I + 2 + coloroffset] or Vector(1, 1, 1)
            local material = Material("models/ppm/partrender/" .. prephrase .. hairnum .. "_mask" .. I .. ".png")
            render.SetMaterial(material)
            render.DrawQuadEasy(Vector(256, 256, 0), Vector(0, 0, -1), 512, 512, Color(color.x * 255, color.y * 255, color.z * 255, 255), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees
        end
    else
        if TAIL then end

        if UPDN == "dn" then
            render.Clear(pony.haircolor2.x * 255, pony.haircolor2.y * 255, pony.haircolor2.z * 255, 255, true)
        else
            render.Clear(pony.haircolor1.x * 255, pony.haircolor1.y * 255, pony.haircolor1.z * 255, 255, true)
        end
    end
end

PPM.tex_draweyefunc = function(pony, isR)
    local prefix = "l"

    if (not isR) then
        prefix = "r"
    end

    local backcolor = pony.eyecolor_bg or Vector(1, 1, 1)
    local color = 1.3 * pony.eyecolor_iris or Vector(0.5, 0.5, 0.5)
    local colorg = 1.3 * pony.eyecolor_grad or Vector(1, 0.5, 0.5)
    local colorl1 = 1.3 * pony.eyecolor_line1 or Vector(0.6, 0.6, 0.6)
    local colorl2 = 1.3 * pony.eyecolor_line2 or Vector(0.7, 0.7, 0.7)
    local holecol = 1.3 * pony.eyecolor_hole or Vector(0, 0, 0)
    render.Clear(backcolor.x * 255, backcolor.y * 255, backcolor.z * 255, 255, true)
    local material = Material("models/ppm/partrender/eye_oval.png")
    render.SetMaterial(material)
    local drawlines = pony.eyehaslines == 1 -- or true
    local holewidth = pony.eyejholerssize or 1
    local irissize = pony.eyeirissize or 0.6
    local holesize = (pony.eyeirissize or 0.6) * (pony.eyeholesize or 0.7)
    render.DrawQuadEasy(Vector(256, 256, 0), Vector(0, 0, -1), 512 * irissize, 512 * irissize, Color(color.x * 255, color.y * 255, color.z * 255, 255), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees
    --grad 
    local material = Material("models/ppm/partrender/eye_grad.png")
    render.SetMaterial(material)
    render.DrawQuadEasy(Vector(256, 256, 0), Vector(0, 0, -1), 512 * irissize, 512 * irissize, Color(colorg.x * 255, colorg.y * 255, colorg.z * 255, 255), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees

    if drawlines then
        --eye_line_l1
        local material = Material("models/ppm/partrender/eye_line_" .. prefix .. "2.png")
        render.SetMaterial(material)
        render.DrawQuadEasy(Vector(256, 256, 0), Vector(0, 0, -1), 512 * irissize, 512 * irissize, Color(colorl2.x * 255, colorl2.y * 255, colorl2.z * 255, 255), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees
        local material = Material("models/ppm/partrender/eye_line_" .. prefix .. "1.png")
        render.SetMaterial(material)
        render.DrawQuadEasy(Vector(256, 256, 0), Vector(0, 0, -1), 512 * irissize, 512 * irissize, Color(colorl1.x * 255, colorl1.y * 255, colorl1.z * 255, 255), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees
    end

    --hole
    local material = Material("models/ppm/partrender/eye_oval.png")
    render.SetMaterial(material)
    render.DrawQuadEasy(Vector(256, 256, 0), Vector(0, 0, -1), 512 * holesize * holewidth, 512 * holesize, Color(holecol.x * 255, holecol.y * 255, holecol.z * 255, 255), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees
    local material = Material("models/ppm/partrender/eye_effect.png")
    render.SetMaterial(material)
    render.DrawQuadEasy(Vector(256, 256, 0), Vector(0, 0, -1), 512 * irissize, 512 * irissize, Color(255, 255, 255, 255), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees
    local material = Material("models/ppm/partrender/eye_reflection.png")
    render.SetMaterial(material)
    render.DrawQuadEasy(Vector(256, 256, 0), Vector(0, 0, -1), 512 * irissize, 512 * irissize, Color(255, 255, 255, 255 * 0.5), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees
    PPM.currt_success = true
end

PPM.hairrenderOp = function(UPDN, TAIL, hairnum)
    if TAIL then
        if PPM.manerender["tl" .. hairnum] ~= nil then
            PPM.currt_success = true
        end
    else
        if PPM.manerender[UPDN .. hairnum] ~= nil then
            PPM.currt_success = true
        end
    end
end

-- print(UPDN, TAIL, hairnum, PPM.currt_success) 
--/PPM.currt_success =true
--MsgN(UPDN,TAIL,hairnum," = ",PPM.currt_success)
PPM.manerender = {
up5 = {0, 1}
,up6 = {0, 1}
,up8 = {0, 2}
,up9 = {0, 3}
,up10 = {0, 1}
,up11 = {0, 3}
,up12 = {0, 1}
,up13 = {0, 1}
,up14 = {0, 1}
,up15 = {0, 1}
,dn5 = {0, 1}
,dn8 = {3, 2}
,dn9 = {3, 2}
,dn10 = {0, 3}
,dn11 = {0, 2}
,dn12 = {0, 1}
,tl5 = {0, 1}
,tl8 = {0, 5}
,tl10 = {0, 1}
,tl11 = {0, 3}
,tl12 = {0, 2}
,tl13 = {0, 1}
,tl14 = {0, 1}
}
PPM.manecolorcounts = {1, 1, 1, 1, 1, 1}
PPM.defaultHairColors = {Vector(252, 92, 82) / 256, Vector(254, 134, 60) / 256, Vector(254, 241, 160) / 256, Vector(98, 188, 80) / 256, Vector(38, 165, 245) / 256, Vector(124, 80, 160) / 256}

PPM.rendertargettasks.ccmarktex = {
    size = 256,
    render = function(ent, mats)
        if PPM_CheckTexture(ent, "ccmarktex") then
            mats[PPMMAT_CMARK]:SetTexture("$basetexture", ent.ponydata_tex.ccmarktex)
        else
            if (ent.ponydata == nil) then return  end
            if (ent.ponydata.cmark == nil) then return  end
            if (PPM.m_cmarks[ent.ponydata.cmark] == nil) then return  end
            if (PPM.m_cmarks[ent.ponydata.cmark][2] == nil) then return  end
            if (PPM.m_cmarks[ent.ponydata.cmark][2]:GetTexture("$basetexture") == nil) then return  end
            if (PPM.m_cmarks[ent.ponydata.cmark][2]:GetTexture("$basetexture") == NULL) then return  end
            mats[PPMMAT_CMARK]:SetTexture("$basetexture", PPM.m_cmarks[ent.ponydata.cmark][2]:GetTexture("$basetexture"))
        end

    end,
    drawfunc = function()
        local pony = PPM.currt_ponydata

        if pony.custom_mark then
        else
            render.Clear(0, 0, 0, 0)
            PPM.currt_success = false
        end
    end
    -- ,
    -- hash = function(ponydata) return tostring(ponydata._cmark[1] ~= nil) end
}