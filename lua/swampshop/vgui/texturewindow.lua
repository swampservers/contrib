-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA


local rt_drawover = GetRenderTargetEx( "ss_mat_drawover"..math.Round(CurTime()), 512, 512, RT_SIZE_LITERAL, MATERIAL_RT_DEPTH_NONE, 0, 0, IMAGE_FORMAT_DEFAULT )

local mat_drawover = CreateMaterial("ss_mat_drawover"..math.Round(CurTime()), "UnlitGeneric", {
    ["$basetexture"] = rt_drawover,
    ["$translucent"] = 1,
})
mat_drawover:SetTexture("$basetexture",rt_drawover)
mat_drawover:SetInt("$translucent",1)
mat_drawover:SetInt("$alphatest",0)
mat_drawover:SetInt("$additive",0)

mat_drawover:SetInt("$vertexcolor",1)
mat_drawover:SetInt("$vertexalpha",1)

mat_drawover:Recompute()

SS_MAT_DRAWOVER = mat_drawover
SS_TEX_DRAWOVER = rt_drawover


SS_REQUESTED_TEX = nil
SS_REQUESTED_TEX_CALLBACK = nil



function TexDownloadHook()
    if (SS_REQUESTED_TEX and not SS_REQUESTED_TEX:IsError()) then
        local mat = SS_REQUESTED_TEX

        local matcopy = CreateMaterial(mat:GetName() .. "copy", "UnlitGeneric", {
            ["$basetexture"] = mat:GetString("$basetexture"),
            ["$flags"] = 0,
        })

        local RT = GetRenderTarget(mat:GetName() .. "download", mat:Width(), mat:Height())
        render.PushRenderTarget(RT)
        render.SuppressEngineLighting(true)
        render.ResetModelLighting(1, 1, 1)
        render.SetLightingMode(1)
        cam.Start2D()
        render.Clear(0, 0, 0, 0, true, true)
        render.SetMaterial(matcopy)
        render.DrawScreenQuad()
        cam.End2D()

        if (SS_MAT_DRAWOVER) then
            cam.Start2D()
            render.SetMaterial(SS_MAT_DRAWOVER)
            render.DrawScreenQuad()
            cam.End2D()
        end

        render.SetWriteDepthToDestAlpha(false)

        local data = render.Capture({
            format = "png",
            x = 0,
            y = 0,
            alpha = false,
            w = ScrW(),
            h = ScrH()
        })

        render.SetWriteDepthToDestAlpha(true)
        render.SuppressEngineLighting(false)
        render.SetLightingMode(0)
        render.PopRenderTarget()
        local parts = string.Explode("/", mat:GetName() or "")
        local imagename = parts[#parts] or "temp_image"
        local fname = imagename .. ".png"
        file.Write(fname, data)

        if (SS_REQUESTED_TEX_CALLBACK) then
            SS_REQUESTED_TEX_CALLBACK(fname, data)
        end
    else
        if (SS_REQUESTED_TEX_CALLBACK) then
            SS_REQUESTED_TEX_CALLBACK()
        end
    end

    SS_REQUESTED_TEX = nil
    SS_REQUESTED_TEX_CALLBACK = nil
    hook.Remove("PostRender", "SS_TexDownload")
end

hook.Remove("PostRender", "SS_TexDownload")

function SS_DownloadTexture(mat, callback)
    SS_REQUESTED_TEX = mat
    SS_REQUESTED_TEX_CALLBACK = callback

    hook.Add("PostRender", "SS_TexDownload", function()
        TexDownloadHook()
    end)
end


--------------------------------------------------------------------
local PANEL = {}

function PANEL:Think()
    if (not IsValid(SS_CustomizerPanel) or not SS_CustomizerPanel.item) then
        self:Remove()

        return
    end
end

function PANEL:ClearDrawover()
    render.PushRenderTarget(SS_TEX_DRAWOVER)
render.Clear(0, 0, 0, 0, false, flase)
render.PopRenderTarget()

end

function PANEL:Paint(w, h)

    local mat

    if IsValid(SS_HoverCSModel) then
        mat = SS_HoverCSModel:GetMaterials()[1]
    else
        mat = SS_PreviewPane.Entity:GetMaterials()[(SS_CustomizerPanel.item.cfg.submaterial or 0) + 1]
    end

    mat = Material(mat)

    local mat_inst = CreateMaterial(mat:GetName() .. "copy", "UnlitGeneric", {
        ["$basetexture"] = mat:GetString("$basetexture"),
        ["$flags"] = 0,
    })

    local dispmax = 512
    local tw, th = mat_inst:Width(), mat_inst:Height()
    local big = math.max(tw, th)
    tw = tw / big * dispmax
    th = th / big * dispmax

    if (mat_inst) then
        cam.IgnoreZ(true)
        cam.IgnoreZ(false)
        surface.SetMaterial(mat_inst)
        surface.DrawTexturedRect(0, 0, w, h)
        render.OverrideAlphaWriteEnable(true, true)
        if (SS_MAT_DRAWOVER) then
            surface.SetDrawColor(Color(255, 255, 255, 255))
            surface.SetMaterial(SS_MAT_DRAWOVER)
            surface.DrawTexturedRect(0, 0, w, h)
        end
        render.OverrideAlphaWriteEnable(false)
    end
end

function PANEL:PaintOver()

    if (SS_TEX_DRAWOVER and input.IsMouseDown(MOUSE_LEFT)) then
        local col = HSVToColor(180+math.NormalizeAngle(CurTime()*360),1,1)
        local x, y = self:ScreenToLocal(gui.MouseX(), gui.MouseY())
        render.ClearRenderTarget(SS_TEX_DRAWOVER, Color(255,255,255,1) )

        render.PushRenderTarget(SS_TEX_DRAWOVER)
        render.OverrideAlphaWriteEnable(true, true)
        local size = 16
        cam.Start2D()
		surface.SetDrawColor( col )
		surface.DrawRect( x-(size/2), y-(size/2), size, size )
	    cam.End2D()

        render.OverrideAlphaWriteEnable(false, true)
        render.PopRenderTarget()
    end

end

function PANEL:Init()
    self:ClearDrawover()
end

vgui.Register('DPointshopTexture', PANEL, 'DPanel')