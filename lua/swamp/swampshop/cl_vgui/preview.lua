-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local PANEL = {}
local pitchtarget = 15

--NOMINIFY
function PANEL:Init()
    -- self:SetModel(Me:GetModel())
    -- self.Angles = Angle(0, 0, 0)
    -- self.ZoomOffset = 0
    -- HORIZONTAL FOV
    self:SetFOV(45)
    self.Pitch = pitchtarget
    self.Yaw = 0
    self.LastInteractionTime = 0
    SS_PreviewPanel = self
end

function PANEL:Think()
    local animate = RealTime() - self.LastInteractionTime > 5 and not (IsValid(SS_CustomizerPanel) and SS_CustomizerPanel:IsVisible())

    -- self.velocity = math.Clamp((self.velocity or 0) + FrameTime() * (self:IsHovered() and 5 or -2), 0, 1)
    -- self.Yaw = (self.Yaw + self.velocity * FrameTime() * 120) % 360
    if animate then
        if not self.LastAnimated then
            self.StartPitch = self.Pitch
            self.StartYaw = self.Yaw
            self.StartTime = RealTime()
        end

        local function coslerp(t, a, b)
            t = math.Clamp(t, 0, 1)
            t = (1 - math.cos(t * math.pi)) * 0.5

            return Lerp(t, a, b)
        end

        self.Pitch = coslerp(RealTime() - self.StartTime, self.StartPitch, pitchtarget)
        self.Yaw = coslerp(RealTime() - self.StartTime, (135 + self.StartYaw) % 360, (135 + (math.sin(RealTime() * 0.5) + 1) * 45) % 360) - 135
        -- self.Yaw = 
    end

    self.LastAnimated = animate
end

-- returns model and if its a playermodel (false means its a prop)
function PANEL:GetDesiredModel()
    if SS_HoverIOP and not SS_HoverIOP.wear and not SS_HoverIOP.playermodelmod then
        local m, w = SS_HoverIOP:GetModel(), SS_HoverIOP:GetWorkshop()

        if w then
            require_model(m, w)
        end

        return m, SS_HoverIOP.PlayerSetModel ~= nil
    else
        return Me:GetModel(), true
    end
end

function PANEL:OnMouseWheeled(amt)
    self.ZoomOffset = (self.ZoomOffset or 0) + (amt > 0 and -0.1 or 0.1)
end

function PANEL:DragMousePress(btn)
    self.PressButton = btn
    self.PressX, self.PressY = gui.MousePos()
    self.Pressed = true
end

function PANEL:DragMouseRelease()
    self.Pressed = false
end

function PANEL:LayoutEntity(thisEntity)
    if self.bAnimated then
        self:RunAnimation()
    end

    if self.Pressed then
        local mx, my = gui.MousePos()

        --self.Angles = self.Angles - Angle( ( self.PressY or my ) - my, ( self.PressX or mx ) - mx, 0 )
        if self.PressButton == MOUSE_LEFT then
            -- if SS_CustomizerPanel:IsVisible() then
            --     local ang = (self:GetLookAt() - self:GetCamPos()):Angle()
            --     self.Angles:RotateAroundAxis(ang:Up(), (mx - (self.PressX or mx)) * 0.6)
            --     self.Angles:RotateAroundAxis(ang:Right(), (my - (self.PressY or my)) * 0.6)
            --     self.SPINAT = 0
            -- else
            --     self.Angles.y = self.Angles.y + ((mx - (self.PressX or mx)) * 0.6)
            -- end
            self.Pitch = math.Clamp(self.Pitch + (my - (self.PressY or my)), -90, 90)
            self.Yaw = (self.Yaw + (mx - (self.PressX or mx))) % 360
            self.LastInteractionTime = RealTime()
        end

        if self.PressButton == MOUSE_RIGHT then
            if SS_CustomizerPanel:IsVisible() then
                if ValidPanel(SS_CustomizerPanel.Angle) and IsValid(SS_HoverCSModel) then
                    local clang = SS_CustomizerPanel.Angle:GetValueAngle()
                    local clangm = Matrix()
                    clangm:SetAngles(clang)
                    clangm:Invert()
                    local clangi = clangm:GetAngles()
                    local cgang = SS_HoverCSModel:GetAngles()
                    local crangm = Matrix()
                    crangm:SetAngles(cgang)
                    crangm:Rotate(clangi)
                    local ngang = Angle()
                    ngang:Set(cgang)
                    -- local ang = (self:GetLookAt() - self:GetCamPos()):Angle()
                    local _, ang = self:GetCameraTransform()
                    ngang:RotateAroundAxis(ang:Up(), (mx - (self.PressX or mx)) * 0.3)
                    ngang:RotateAroundAxis(ang:Right(), (my - (self.PressY or my)) * 0.3)
                    local ngangm = Matrix()
                    ngangm:SetAngles(ngang)
                    crangm:Invert()
                    local nlangm = crangm * ngangm
                    SS_CustomizerPanel.Angle:SetValue(nlangm:GetAngles())
                end
            end
        end

        if self.PressButton == MOUSE_MIDDLE and SS_CustomizerPanel:IsVisible() and ValidPanel(SS_CustomizerPanel.Position) and IsValid(SS_HoverCSModel) then
            local clang = SS_CustomizerPanel.Angle:GetValueAngle()
            local clangm = Matrix()
            clangm:SetAngles(clang)
            clangm:Invert()
            local clangi = clangm:GetAngles()
            local cgang = SS_HoverCSModel:GetAngles()
            local crangm = Matrix()
            crangm:SetAngles(cgang)
            crangm:Rotate(clangi)
            local _, ang = self:GetCameraTransform()
            local wshift = ang:Right() * (mx - (self.PressX or mx)) - ang:Up() * (my - (self.PressY or my))
            local vo, _ = WorldToLocal(wshift * 0.05, Angle(0, 0, 0), Vector(0, 0, 0), crangm:GetAngles())
            SS_CustomizerPanel.Position:SetValue(SS_CustomizerPanel.Position:GetValue() + vo)
        end

        self.PressX, self.PressY = gui.MousePos()
    end
    -- if (RealTime() - (self.lastPressed or 0)) < (self.SPINAT or 0) or self.Pressed or SS_CustomizerPanel:IsVisible() then
    --     -- Uh, you have to do this or the hovered model won't follow the animation
    --     self.Angles.y = self.Angles.y + 0.0001
    --     thisEntity:SetAngles(self.Angles)
    --     if not SS_CustomizerPanel:IsVisible() then
    --         self.SPINAT = 4
    --     end
    -- else
    --     self.Angles.y = math.NormalizeAngle(self.Angles.y + (RealFrameTime() * 21))
    --     self.Angles.x = 0
    --     self.Angles.z = 0
    --     thisEntity:SetAngles(self.Angles)
    -- end
end

function PANEL:FocalPointAndDistance()
    local mdl, playermodel = self:GetDesiredModel()

    local function model_center_radius(ent)
        local min, max = ent:GetRenderBounds()

        return (min + max) * 0.5, min:Distance(max) * 0.5
    end

    if playermodel then
        if IsValid(SS_HoverCSModel) then
            -- local p2, a2 = SS_GetItemWorldPos(SS_HoverItem, self.Entity)
            -- local p2 = SS_HoverCSModel:GetPos()
            -- pos = p2 - (ang:Forward() * 50)
            local center, radius = model_center_radius(SS_HoverCSModel)
            center = self.Entity:WorldToLocal(SS_HoverCSModel:LocalToWorld(center))

            return center, (radius + 1) * 2
        end

        if SS_HoverItem and SS_HoverItem.bonemod then
            local pone = IsPonyModel(self.Entity:GetModel())
            local suffix = pone and "_p" or "_h"
            local bn = SS_HoverItem.cfg["bone" .. suffix] or (pone and "LrigScull" or "ValveBiped.Bip01_Head1")
            local x = self.Entity:LookupBone(bn)

            if x then
                local v, a = self.Entity:GetBonePosition(x)
                local center = self.Entity:WorldToLocal(v)

                return center, 60
            end
        end

        return Vector(0, 0, 36), 75
    else
        local center, radius = model_center_radius(self.Entity)

        return center, (radius + 1) * 1.5
    end
end

function PANEL:Paint(w, h)
    local ply = Me
    local mdl, playermodel = self:GetDesiredModel() --TODO set the model first so theres not 1 frame flicker

    if mdl ~= self.appliedmodel then
        self:SetModel(mdl)
        self.appliedmodel = mdl

        --SS_HoverIOP and (SS_HoverIOP.PlayerSetModel == nil) and (not SS_HoverIOP.wear) and (not SS_HoverIOP.playermodelmod) then
        if IsValid(self.Entity) and not playermodel then
            local item = SS_HoverItem or SS_HoverProduct.sample_item

            if item then
                SS_SetItemMaterialToEntity(item, self.Entity)
            elseif SS_HoverProduct and SS_HoverProduct.material then
                self.Entity:SetMaterial(SS_HoverProduct.material)
            end
        end

        self.ZoomOffset = 0
    end

    if not IsValid(self.Entity) then return end
    -- render.SetColorModulation(1, 1, 1) --WTF
    -- local x, y = self:LocalToScreen(0, 0)
    self:LayoutEntity(self.Entity)
    -- local ang = self.aLookAngle
    -- if not ang then
    --     ang = (self.vLookatPos - self.vCamPos):Angle()
    -- end
    -- local pos = self.vCamPos
    -- -- if SS_CustomizerPanel:IsVisible() then
    -- -- TODO
    -- if IsValid(SS_HoverCSModel) then
    --     -- local p2, a2 = SS_GetItemWorldPos(SS_HoverItem, self.Entity)
    --     local p2 = SS_HoverCSModel:GetPos()
    --     pos = p2 - (ang:Forward() * 50)
    -- end
    -- if SS_HoverItem and SS_HoverItem.playermodelmod then
    --     pos = pos + (ang:Forward() * 25)
    --     -- TODO: focus camera on bone
    -- end
    local hextent = h

    -- make space for the statbars
    if SS_HoverIOP and SS_HoverIOP.class == "weapon" then
        hextent = 0.6 * hextent
    end

    self:AlignEntity()
    self:StartCamera()

    if IsPonyModel(self.Entity:GetModel()) then
        -- PPM.PrePonyDraw(self.Entity, true)
        -- PPM.setBodygroups(self.Entity, true)
        -- 
        PPM_SetBodyGroups(self.Entity)
    end

    if SS_HoverIOP and SS_HoverIOP.PlayerSetModel == nil and not SS_HoverIOP.wear and not SS_HoverIOP.playermodelmod then
        -- SS_PreviewShopModel(self, SS_HoverIOP)
        -- self:SetCamPos(self:GetCamPos() * 2)
        self.Entity:DrawModel()
    else
        local PrevMins, PrevMaxs = self.Entity:GetRenderBounds()

        if IsPonyModel(self.Entity:GetModel()) then
            PrevMins = Vector(-42, -20, -2.5)
            PrevMaxs = Vector(38, 20, 83)
        end

        local center = (PrevMaxs + PrevMins) / 2
        local diam = PrevMins:Distance(PrevMaxs)
        self:SetCamPos(center + diam * Vector(0.4, 0.4, 0.1))
        self:SetLookAt(center)
        self.Entity.GetPlayerColor = function() return Me:GetPlayerColor() end
        local mods = Me.SS_ShownItems
        -- retarded stopgap fix for customizer, for some reason hoveritem and customizer's item are different tables referring to the same item
        local hoveritem = IsValid(SS_CustomizerPanel) and SS_CustomizerPanel:IsVisible() and SS_CustomizerPanel.item or SS_HoverItem

        if hoveritem and hoveritem.playermodelmod then
            -- local add = true
            local mods1 = mods
            mods = {}

            for i, v in pairs(mods1) do
                if v.id ~= hoveritem.id then
                    table.insert(mods, v)
                end
            end

            -- if add then
            table.insert(mods, hoveritem) --TODO why is this different when customizing
            -- end
        end

        if not SS_HoverIOP or not SS_HoverIOP.PlayerSetModel then
            SS_ApplyMods(self.Entity, mods)
        end

        self.Entity:SetEyeTarget(self:GetCamPos())
        self.Entity:DrawModel()
    end

    -- print("HOVER", SS_HoverItem)
    if SS_HoverIOP == nil or SS_HoverIOP.PlayerSetModel or SS_HoverIOP.wear or SS_HoverIOP.playermodelmod then
        local function GetShopAccessoryItems()
            local a = {}
            local hoveritem = SS_HoverItem

            -- retarded stopgap fix for customizer, for some reason hoveritem and customizer's item are different tables referring to the same item
            if IsValid(SS_CustomizerPanel) and SS_CustomizerPanel:IsVisible() then
                hoveritem = SS_CustomizerPanel.item
            end

            if hoveritem then
                table.insert(a, hoveritem)
            end

            if IsValid(Me) then
                for _, item in ipairs(Me.SS_ShownItems or {}) do
                    -- prefer hoveritem because it has the updated config, shownitems are worn on the server
                    if hoveritem == nil or hoveritem.id ~= item.id then
                        table.insert(a, item)
                    end
                end
            end

            return a
        end

        if not SS_ShopAccessoriesClean then
            -- remake every frame lol
            self.Entity:SS_AttachAccessories()
            -- SS_ShopAccessoriesClean = true
            -- print("REMAKE")
        end

        self.Entity:SS_AttachAccessories(GetShopAccessoryItems(), true)
        local acc = SS_CreatedAccessories[self.Entity]
        SS_HoverCSModel = SS_HoverItem and SS_HoverItem.wear and acc[1] or nil

        for _, prop in pairs(acc) do
            -- print(prop:GetMaterial())
            prop:DrawModel() --self.Entity)
        end
    end

    self:EndCamera()

    if SS_CustomizerPanel:IsVisible() then
        if IsValid(SS_HoverCSModel) then
            draw.SimpleText("RMB + drag to rotate", "SS_DESCFONTBIG", self:GetWide() / 2, 14, MenuTheme_TX, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("MMB + drag to move", "SS_DESCFONTBIG", self:GetWide() / 2, 14 + 32, MenuTheme_TX, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    if SS_TitlesPanel:IsVisible() then
        draw.SimpleText(Me:Nick(), "SS_POINTSFONT", self:GetWide() / 2, 26, MenuTheme_TX, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(Me:GetTitle() ~= "" and Me:GetTitle() or "No title", "SS_DESCFONTBIG", self:GetWide() / 2, 64, MenuTheme_TX, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if IsValid(SS_DescriptionPanel) then
        _, h = SS_DescriptionPanel:GetPos()
    end

    if SS_HoverIOP then
        SS_DrawIOPInfo(SS_HoverIOP, 0, h - 6, w, MenuTheme_TX, 1)
    end
end

function SS_RefreshShopAccessories()
    SS_ShopAccessoriesClean = false
end

vgui.Register('DPointShopPreview', PANEL, 'SwampShopModelBase')
