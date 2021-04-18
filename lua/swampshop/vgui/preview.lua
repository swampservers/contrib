-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local PANEL = {}

function PANEL:Init()
    self:SetModel(LocalPlayer():GetModel())
end

function PANEL:Paint()
    if (not IsValid(self.Entity)) then return end
    local x, y = self:LocalToScreen(0, 0)
    self:LayoutEntity(self.Entity)
    local ang = self.aLookAngle

    if (not ang) then
        ang = (self.vLookatPos - self.vCamPos):Angle()
    end

    local pos = self.vCamPos

    if SS_CustomizerPanel:IsVisible() then
        if IsValid(SS_HoverCSModel) then
            SS_DrawWornCSModel(SS_HoverData, SS_HoverCfg, SS_HoverCSModel, self.Entity, true)
            pos = LerpVector(0, SS_HoverCSModel:GetPos() - (ang:Forward() * 25), pos)
        end

        if SS_HoverData and SS_HoverData.bonemod then
            pos = pos + (ang:Forward() * 25)
            --positions are wrong
            --[[
			local pone = isPonyModel(self.Entity:GetModel())
			local suffix = pone and "_p" or "_h"

			local bn = SS_HoverCfg["bone"..suffix] or (pone and "LrigScull" or "ValveBiped.Bip01_Head")
			local x = self.Entity:LookupBone(bn)
			if x then
				local pos2,ang2 = self.Entity:GetBonePosition(x)

				pos = LerpVector(0, pos2 - (ang:Forward() * 35), pos)
			end
			]]
        end
    end

    local w, h = self:GetSize()
    cam.Start3D(pos + ang:Forward() * (self.ZoomOffset or 0) * 2.0, ang, self.fFOV, x, y, w, h, 5, 4096)
    cam.IgnoreZ(true)
    render.SuppressEngineLighting(true)
    render.SetLightingOrigin(self.Entity:GetPos())
    render.ResetModelLighting(self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255)
    render.SetBlend(self.colColor.a / 255)

    for i = 0, 6 do
        local col = self.DirectionalLight[i]

        if (col) then
            render.SetModelLighting(i, col.r / 255, col.g / 255, col.b / 255)
        end
    end

    local ply = LocalPlayer()
    local mdl = ply:GetModel()

    if SS_HoverData and (not SS_HoverData.wear) and (not SS_HoverData.bonemod) then
        mdl = SS_HoverData.model
    end

    require_workshop_model(mdl)
    self:SetModelCaching(mdl)

    if isPonyModel(self.Entity:GetModel()) then
        PPM.PrePonyDraw(self.Entity, true)
        PPM.setBodygroups(self.Entity, true)
    end

    if SS_HoverData and (not SS_HoverData.playermodel) and (not SS_HoverData.wear) and (not SS_HoverData.bonemod) then
        SS_PreRender(SS_HoverData, SS_HoverCfg)
        SS_PreviewShopModel(self, SS_HoverData)
        self.Entity:DrawModel()
        SS_PostRender()
    else
        local PrevMins, PrevMaxs = self.Entity:GetRenderBounds()

        if isPonyModel(self.Entity:GetModel()) then
            PrevMins = Vector(-42, -20, -2.5)
            PrevMaxs = Vector(38, 20, 83)
        end

        local center = (PrevMaxs + PrevMins) / 2
        local diam = PrevMins:Distance(PrevMaxs)
        self:SetCamPos(center + (diam * Vector(0.4, 0.4, 0.1)))
        self:SetLookAt(center)
        self.Entity.GetPlayerColor = function() return LocalPlayer():GetPlayerColor() end
        local mods = LocalPlayer():SS_GetActiveBonemods()

        if SS_HoverData and SS_HoverData.bonemod then
            table.insert(mods, {
                itm = SS_HoverData,
                cfg = SS_HoverCfg
            })

            local rm = nil

            for i, v in ipairs(mods) do
                if v.id == SS_HoverItemID then
                    rm = i
                    break
                end
            end

            if rm then
                table.remove(mods, rm)
            end
        end

        SS_ApplyBoneMods(self.Entity, mods)
        self.Entity:DrawModel()
    end

    if SS_HoverData == nil or SS_HoverData.playermodel or SS_HoverData.wear or SS_HoverData.bonemod then
        for _, prop in pairs(ply:SS_GetCSModels()) do
            if SS_HoverItemID == nil or SS_HoverItemID ~= prop.id then
                SS_DrawWornCSModel(prop.itm, prop.cfg, prop.mdl, self.Entity)
            end
        end
    end

    if SS_HoverData and SS_HoverData.wear then
        if not IsValid(SS_HoverCSModel) then
            SS_HoverCSModel = SS_CreateWornCSModel(SS_HoverData, SS_HoverCfg)
        end

        SS_DrawWornCSModel(SS_HoverData, SS_HoverCfg, SS_HoverCSModel, self.Entity)
    end

    -- ForceDrawPlayer(LocalPlayer())
    render.SuppressEngineLighting(false)
    cam.IgnoreZ(false)
    cam.End3D()

    if SS_CustomizerPanel:IsVisible() then
        if ValidPanel(XRSL) then
            if IsValid(SS_HoverCSModel) then
                draw.SimpleText("RMB + drag to rotate", "SS_DESCFONT", self:GetWide() / 2, 14, SS_SwitchableColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end
end

function PANEL:SetModelCaching(sm)
    if sm ~= self.ModelName then
        self.ModelName = sm
        self:SetModel(sm)

        if isPonyModel(sm) then
            self.Entity.isEditorPony = true
            PPM.editor3_pony = self.Entity
            PPM.copyLocalPonyTo(LocalPlayer(), self.Entity)
        end
    end
end

vgui.Register('DPointShopPreview', PANEL, 'DModelPanel')