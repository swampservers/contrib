-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local PANEL = {}

function PANEL:Init()
    self:SetModel(LocalPlayer():GetModel())
    self.Angles = Angle(0, 0, 0)
    self.ZoomOffset = 0
    self:SetFOV(30)
end

function PANEL:OnMouseWheeled(amt)
    self.ZoomOffset = self.ZoomOffset + (amt > 0 and 1 or -1)
end

function PANEL:DragMousePress(btn)
    self.PressButton = btn
    self.PressX, self.PressY = gui.MousePos()
    self.Pressed = true
end

function PANEL:DragMouseRelease()
    self.Pressed = false
    self.lastPressed = RealTime()
end

function PANEL:LayoutEntity(thisEntity)
    if (self.bAnimated) then
        self:RunAnimation()
    end

    if (self.Pressed) then
        local mx, my = gui.MousePos()

        --self.Angles = self.Angles - Angle( ( self.PressY or my ) - my, ( self.PressX or mx ) - mx, 0 )
        if self.PressButton == MOUSE_LEFT then
            if SS_CustomizerPanel:IsVisible() then
                local ang = (self:GetLookAt() - self:GetCamPos()):Angle()
                self.Angles:RotateAroundAxis(ang:Up(), (mx - (self.PressX or mx)) * 0.6)
                self.Angles:RotateAroundAxis(ang:Right(), (my - (self.PressY or my)) * 0.6)
                self.SPINAT = 0
            else
                self.Angles.y = self.Angles.y + ((mx - (self.PressX or mx)) * 0.6)
            end
        end

        if self.PressButton == MOUSE_RIGHT then
            if SS_CustomizerPanel:IsVisible() then
                if ValidPanel(XRSL) then
                    if IsValid(SS_HoverCSModel) then
                        clang = Angle(XRSL:GetValue(), YRSL:GetValue(), ZRSL:GetValue())
                        clangm = Matrix()
                        clangm:SetAngles(clang)
                        clangm:Invert()
                        clangi = clangm:GetAngles()
                        cgang = SS_HoverCSModel:GetAngles()
                        crangm = Matrix()
                        crangm:SetAngles(cgang)
                        crangm:Rotate(clangi)
                        rootang = V
                        ngang = Angle()
                        ngang:Set(cgang)
                        local ang = (self:GetLookAt() - self:GetCamPos()):Angle()
                        ngang:RotateAroundAxis(ang:Up(), (mx - (self.PressX or mx)) * 0.3)
                        ngang:RotateAroundAxis(ang:Right(), (my - (self.PressY or my)) * 0.3)
                        ngangm = Matrix()
                        ngangm:SetAngles(ngang)
                        crangm:Invert()
                        nlangm = crangm * ngangm
                        nlang = nlangm:GetAngles()
                        print(nlang)
                        XRSL:SetValue(nlang.x)
                        YRSL:SetValue(nlang.y)
                        ZRSL:SetValue(nlang.z)
                    end
                end
            end
        end

        --[[ this shit isnt ready yet
        if self.PressButton == MOUSE_MIDDLE and SS_CustomizerPanel:IsVisible() and ValidPanel(XSL) and IsValid(SS_HoverCSModel) then
            local ofs = Vector(XSL:GetValue(), YSL:GetValue(), ZSL:GetValue())
            local attach = (SS_CustomizerPanel.item.cfg[SS_CustomizerPanel.wear] or {}).attach or (pone and (SS_CustomizerPanel.item.wear.pony or {}).attach) or SS_CustomizerPanel.item.wear.attach
            local angpos = self.Entity:GetAttachment(self.Entity:LookupAttachment(attach))
            local apos, aang = LocalToWorld(ofs, Angle(), angpos.Pos, angpos.Ang)
            local camang = (self:GetLookAt() - self:GetCamPos()):Angle()
            apos = apos + camang:Right() * (mx + (self.PressX or mx)) * 0.3
            apos = apos + camang:Up() * (my + (self.PressY or my)) * 0.3
            apos, aang = WorldToLocal(apos, aang, angpos.Pos, angpos.Ang)
            XSL:SetValue(apos.x)
            YSL:SetValue(apos.y)
            ZSL:SetValue(apos.z)
        end
        ]]
        self.PressX, self.PressY = gui.MousePos()
    end

    if (RealTime() - (self.lastPressed or 0)) < (self.SPINAT or 0) or self.Pressed or SS_CustomizerPanel:IsVisible() then
        thisEntity:SetAngles(self.Angles)

        if not SS_CustomizerPanel:IsVisible() then
            self.SPINAT = 4
        end
    else
        self.Angles.y = math.NormalizeAngle(self.Angles.y + (RealFrameTime() * 21))
        self.Angles.x = 0
        self.Angles.z = 0
        thisEntity:SetAngles(self.Angles)
    end
end

function PANEL:Paint()
    if (not IsValid(self.Entity)) then return end
    render.SetColorModulation(1, 1, 1) --WTF
    local x, y = self:LocalToScreen(0, 0)
    self:LayoutEntity(self.Entity)
    local ang = self.aLookAngle

    if (not ang) then
        ang = (self.vLookatPos - self.vCamPos):Angle()
    end

    local pos = self.vCamPos

    if SS_CustomizerPanel:IsVisible() then
        if IsValid(SS_HoverCSModel) then
            SS_DrawWornCSModel(SS_HoverItem, SS_HoverCSModel, self.Entity, true)
            pos = LerpVector(0, SS_HoverCSModel:GetPos() - (ang:Forward() * 25), pos)
        end

        if SS_HoverItem and SS_HoverItem.playermodelmod then
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

    if SS_HoverIOP and (not SS_HoverIOP.wear) and (not SS_HoverIOP.playermodelmod) then
        mdl = SS_HoverIOP:GetModel()
    end

    require_workshop_model(mdl)
    self:SetModelCaching(mdl)

    if isPonyModel(self.Entity:GetModel()) then
        -- PPM.PrePonyDraw(self.Entity, true)
        -- PPM.setBodygroups(self.Entity, true)
        -- 
        PPM_SetBodyGroups(self.Entity)
    end

    if SS_HoverIOP and (not SS_HoverIOP.playermodel) and (not SS_HoverIOP.wear) and (not SS_HoverIOP.playermodelmod) then
        if SS_HoverItem then
            SS_PreRender(SS_HoverItem)
        end

        SS_PreviewShopModel(self, SS_HoverIOP)
        self:SetCamPos(self:GetCamPos() * 2)
        
        self.Entity:DrawModel()
        
        if SS_HoverItem then
            SS_PreRender(SS_HoverItem)
        end
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
        local mods = LocalPlayer():SS_GetActivePlayermodelMods()

        if SS_HoverItem and SS_HoverItem.playermodelmod then
            -- local add = true
            for i, v in ipairs(mods) do
                if v.id == SS_HoverItem.id then
                    -- add = false
                    table.remove(mods, i)
                    break
                end
            end

            -- if add then
            table.insert(mods, SS_HoverItem) --TODO why is this different when customizing
            -- end
        end

        SS_ApplyBoneMods(self.Entity, mods)
        SS_ApplyMaterialMods(self.Entity, mods)
        self.Entity:SetEyeTarget(self:GetCamPos())
        self.Entity:DrawModel()
    end

    if SS_HoverIOP == nil or SS_HoverIOP.playermodel or SS_HoverIOP.wear or SS_HoverIOP.playermodelmod then
        for _, prop in pairs(ply:SS_GetCSModels()) do
            if SS_HoverItem == nil or SS_HoverItem.id ~= prop.item.id then
                SS_DrawWornCSModel(prop.item, prop.mdl, self.Entity)
            end
        end
    end

    if SS_HoverItem and SS_HoverItem.wear then
        if not IsValid(SS_HoverCSModel) then
            SS_HoverCSModel = SS_CreateWornCSModel(SS_HoverItem)
        end

        SS_DrawWornCSModel(SS_HoverItem, SS_HoverCSModel, self.Entity)
    end

    -- ForceDrawPlayer(LocalPlayer())
    render.SuppressEngineLighting(false)
    cam.IgnoreZ(false)
    cam.End3D()

    if SS_CustomizerPanel:IsVisible() then
        if ValidPanel(XRSL) then
            if IsValid(SS_HoverCSModel) then
                draw.SimpleText("RMB + drag to rotate", "SS_DESCFONT", self:GetWide() / 2, 14, MenuTheme_TX, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end
end

function PANEL:SetModelCaching(sm)
    if sm ~= self.ModelName then
        self.ModelName = sm
        self:SetModel(sm)
        -- if isPonyModel(sm) then
        --     self.Entity.isEditorPony = true
        --     PPM.editor3_pony = self.Entity
        --     PPM.copyLocalPonyTo(LocalPlayer(), self.Entity)
        -- end
    end
end

vgui.Register('DPointShopPreview', PANEL, 'DModelPanel')