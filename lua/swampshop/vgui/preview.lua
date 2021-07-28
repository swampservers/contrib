-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local PANEL = {}

--NOMINIFY
local SnapSettings = {
    ["translate"] = {0, 0.5, 1, 2, 4, 8},
    ["rotate"] = {0, 1, 2.5, 5, 10, 15, 45},
}

SNAPS_MEMORY = SNAPS_MEMORY or {}

function PANEL:Init()
    self:SetModel(LocalPlayer():GetModel())
    self.Angles = Angle(0, 0, 0)
    self.ZoomOffset = 0
    self:SetFOV(30)
    self.ViewAngles = Angle(15, 0, 0)
    self.ControlContainer = self:Add("DPanel")
    self.ControlContainer:Dock(TOP)
    self.ControlContainer:SetTall(0)
    self.ControlContainer.Paint = noop --SS_PaintFG
    self.Controls = {}


    self.SelectButton = self:AddButton("swampshop/tool_select.png", "Select")
    
    self.SelectButton.DoClick = function()
        local tab = {}
        

        local acc = SS_CreatedAccessories and SS_CreatedAccessories[self.Entity]
        if(acc)then
            tab = acc
        end
    
        self:SetupSelectGizmo(tab)
        self:SetupSnaps()
    end

    self.TranslateButton = self:AddButton("swampshop/tool_move.png", "Offset")

    self.TranslateButton.DoClick = function()
        self:SetupTranslateGizmo()
        self:SetupSnaps()
    end

    self.RotateButton = self:AddButton("swampshop/tool_rotate.png", "Rotation")

    self.RotateButton.DoClick = function()
        self:SetupRotatorGizmo()
        self:SetupSnaps()
    end

    self.ScaleButton = self:AddButton("swampshop/tool_scale.png", "Scale")

    self.ScaleButton.DoClick = function()
        self:SetupScaleGizmo()
        self:SetupSnaps()
    end

    self.CameraButton = self:AddButton("icon16/shading.png", "Camera", true)

    self.CameraButton.DoClick = function()
        SS_EDITOR_ALIGNZ = not SS_EDITOR_ALIGNZ
        self.CameraButton:SetImage(SS_EDITOR_ALIGNZ and "swampshop/view_lock.png" or "swampshop/view_tilt.png")
    end
    self.CameraButton:SetImage(SS_EDITOR_ALIGNZ and "swampshop/view_lock.png" or "swampshop/view_tilt.png")

    self.SnapsButton = self:AddButton("icon16/shading.png", "Snaps", true)

    self.SnapsButton.PaintOver = function(self)
        local cgizmo = self.CurrentGizmo

        if (IsValid(cgizmo)) then
            local name = cgizmo.type
            local snaptable = SnapSettings[name]

            if (snaptable) then
                local snapv = SNAPS_MEMORY[name]

                if (snapv) then
                    local w, h = self:GetSize()
                    draw.SimpleText(snapv, "DermaDefault", w / 2 + 1, h / 2 + 1, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(snapv, "DermaDefault", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end
    end

    self.SetupSnaps = function()
        local cgizmo = self.CurrentGizmo
        local name = cgizmo.type
        local snaptable = SnapSettings[name]

        if (snaptable) then
            cgizmo:SetSnaps(SNAPS_MEMORY[name])
        end

        local img = {
            translate = "swampshop/snaps_move.png",
            rotate = "swampshop/snaps_rotate.png",
        }

        self.SnapsButton:SetImage(img[name] or "icon16/shading.png")
        self.SnapsButton:SetVisible(snaptable ~= nil)

        self.SnapsButton.DoClick = function()
            if (snaptable) then
                local menu = DermaMenu()

                for k, snap in pairs(snaptable) do
                    if (snap == 0) then
                        snap = nil
                    end

                    menu:AddOption(snap or "Off", function()
                        cgizmo:SetSnaps(snap)
                        SNAPS_MEMORY[name] = snap
                    end)
                end

                menu:Open()
            end
        end
    end

    self:SetupTranslateGizmo()
    self:SetupSnaps()
end

function PANEL:AddGizmoOption(property)

end

function PANEL:GetShopAccessoryItems()
    local a = {}

    if SS_HoverItem then
        table.insert(a, SS_HoverItem)
    end

    if IsValid(LocalPlayer()) then
        for _, item in ipairs(LocalPlayer().SS_ShownItems or {}) do
            if SS_HoverItem == nil or SS_HoverItem.id ~= item.id then
                table.insert(a, item)
            end
        end
    end

    return a
end


function PANEL:AddButton(icon, propname, right)
    local button = self.ControlContainer:Add("DImageButton")
    button:Dock(right and RIGHT or LEFT)
    button:SetWide(96)
    button:SetImage(icon)
    button:SetStretchToFit(false)
    button:SetText(propname .. "  ")
    button:SetContentAlignment(6)
    button:DockMargin(right and SS_COMMONMARGIN or 0, 0, right and 0 or SS_COMMONMARGIN, 0)
    button:SetDepressImage(false)

    button.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
        pnl:SetTextStyleColor(MenuTheme_TX)
        pnl.m_Image:SetImageColor(MenuTheme_TX)
    end

    function button:PerformLayout()
        self.m_Image:SizeToContents()
        self.m_Image:Center()
        self.m_Image:AlignLeft(SS_SMALLMARGIN)
    end

    button.Paint = SS_PaintButtonBrandHL

    return button
end

function PANEL:SetupSelectGizmo(choices)
    local cgizmo = gizmo.MakeSelector(choices)
    cgizmo:SetupForModelPanel(self)
     
    function cgizmo:OnUpdate(value)
        print(value)
    end

    self.CurrentGizmo = cgizmo
end



function PANEL:SetupTranslateGizmo()
    local cgizmo = gizmo.MakeTranslater(true)
    cgizmo:SetupForModelPanel(self)

    --cgizmo:SetSnaps(self.TRANSLATE_SNAPS[self.TranslateSnap or 0])
    function cgizmo:GetPos()
        local ent = SS_HoverCSModel

        if (IsValid(ent)) then
            local pos = ent:GetPos()

            return pos
        end

        return Vector()
    end

    function cgizmo:GetAngles()
        local ent = SS_HoverCSModel

        if (IsValid(ent)) then
            local par, att = ent:GetParent(), ent:GetParentAttachment()
            local bone = ent._FollowedBone
            local bpos, bang

            if (bone) then
                local mat = par:GetBoneMatrix(bone)
                bpos, bang = mat:GetTranslation(), mat:GetAngles()
            end

            if (att) then
                local angpos = par:GetAttachment(att)

                if (angpos) then
                    bpos = angpos.Pos
                    bang = angpos.Ang
                end
            end

            local ang = bang

            return ang
        end

        return Angle()
    end

    function cgizmo:GetScale()
        return 1
    end

    function cgizmo:OnUpdate(value)
        local ent = SS_HoverCSModel
        local cust = SS_CustomizerPanel
        cust.item.cfg.wear_h = cust.item.cfg.wear_h or {}
        self._GrabbedHandleOffset = self._GrabbedHandleOffset + value
        local setting = cust.item.cfg.wear_h.pos or Vector()
        setting = setting - value
        setting.x = math.Clamp(setting.x, -20, 20)
        setting.y = math.Clamp(setting.y, -20, 20)
        setting.z = math.Clamp(setting.z, -20, 20)
        cust.item.cfg.wear_h.pos = setting
        SS_CustomizerPanel:UpdateCfg()
    end

    self.CurrentGizmo = cgizmo
end

function PANEL:SetupRotatorGizmo()
    local cgizmo = gizmo.MakeRotater(true)
    cgizmo:SetupForModelPanel(self)
    local panel = self

    function cgizmo:GetPos()
        local ent = panel.Entity

        if (IsValid(SS_HoverCSModel)) then
            ent = SS_HoverCSModel
        end

        local pos = ent:GetPos()

        return pos
    end

    function cgizmo:GetAngles()
        local ent = SS_HoverCSModel

        if (IsValid(ent)) then
            local par, att = ent:GetParent(), ent:GetParentAttachment()
            local bone = ent._FollowedBone
            local bpos, bang

            if (bone) then
                local mat = par:GetBoneMatrix(bone)
                bpos, bang = mat:GetTranslation(), mat:GetAngles()
            end

            if (att) then
                local angpos = par:GetAttachment(att)
                bpos = angpos.Pos
                bang = angpos.Ang
            end

            local ang = ent:GetAngles()

            return ang
        end

        return Angle()
    end

    function cgizmo:GetScale()
        return 1
    end

    function cgizmo:OnUpdate(value)
        local ang = value
        local cust = SS_CustomizerPanel
        cust.item.cfg.wear_h = cust.item.cfg.wear_h or {}
        local setting = cust.item.cfg.wear_h.ang or Angle()
        _, setting = LocalToWorld(Vector(), value, Vector(), setting)
        cust.item.cfg.wear_h.ang = setting
        SS_CustomizerPanel:UpdateCfg()
    end

    self.CurrentGizmo = cgizmo
end

function PANEL:SetupScaleGizmo()
    local cgizmo = gizmo.MakeScaler(true)
    cgizmo:SetupForModelPanel(self)

    function cgizmo:GetPos()
        if (IsValid(SS_HoverCSModel)) then
            local pos = SS_HoverCSModel:GetPos()

            return pos
        end

        return Vector()
    end

    function cgizmo:GetAngles()
        if (IsValid(SS_HoverCSModel)) then
            local ang = SS_HoverCSModel:GetAngles()

            return ang
        end

        return Angle()
    end

    function cgizmo:GetScale()
        return 1
    end

    function cgizmo:OnGrabbed()
        local cust = SS_CustomizerPanel
        cust.item.cfg.wear_h = cust.item.cfg.wear_h or {}
        local scale = cust.item.cfg.wear_h.scale or Vector(1, 1, 1)
        self._ScaleBasis = scale
    end

    function cgizmo:OnUpdate(value)
        local cust = SS_CustomizerPanel
        cust.item.cfg.wear_h = cust.item.cfg.wear_h or {}
        local scale = cust.item.cfg.wear_h.scale or Vector(1, 1, 1)
        scale = self._ScaleBasis * value
        cust.item.cfg.wear_h.scale = scale
        SS_CustomizerPanel:UpdateCfg()
    end

    self.CurrentGizmo = cgizmo
end

hook.Add("PostDrawTranslucentRenderables", "shahaa", function()
    if (IsValid(TESTGIZMO)) then end --TESTGIZMO:Draw()
end)

function PANEL:Think()
    if (IsValid(self.CurrentGizmo)) then
        self.CurrentGizmo:Think()
    end
end

function PANEL:OnMouseWheeled(amt)
    self.ZoomOffset = self.ZoomOffset + (amt > 0 and 1 or -1)
end

function PANEL:DragMousePress(btn)
    local cust = SS_CustomizerPanel

    if (IsValid(self.CurrentGizmo) and cust and cust.item) then
        local grabbed = self.CurrentGizmo:Grab()
        if (grabbed) then return end
    end

    self.PressButton = btn
    self.PressX, self.PressY = gui.MousePos()
    self.Pressed = true
end

function PANEL:DragMouseRelease()
    if (IsValid(self.CurrentGizmo)) then
        self.CurrentGizmo:Release()
    end

    self.Pressed = false
    self.lastPressed = RealTime()
end

function PANEL:LayoutEntity(thisEntity)
    local gzmo = self.CurrentGizmo
    local grabbing = IsValid(gzmo) and IsValid(gzmo:GetGrabbedHandle())
    thisEntity:SetPlaybackRate(grabbing and 0 or 1)

    if (self.bAnimated and not grabbing) then
        self:FrameAdvance()
    end

    if not SS_CustomizerPanel:IsVisible() then
        for i = 0, FrameTime() * 30 do
            self.ViewAngles.pitch = ((self.ViewAngles.pitch - 15) / 1.05) + 15
            self.ViewAngles.roll = self.ViewAngles.roll / 1.05
        end
    end

    if (self.Pressed) then
        local mx, my = gui.MousePos()

        if self.PressButton == MOUSE_LEFT then
            if SS_CustomizerPanel:IsVisible() then
                self.ViewAngles:RotateAroundAxis(-self.ViewAngles:Right(), (my - (self.PressY or my)) * 0.6)

                if (SS_EDITOR_ALIGNZ) then
                    self.ViewAngles:RotateAroundAxis(Vector(0, 0, -1), (mx - (self.PressX or mx)) * 0.6)
                else
                    self.ViewAngles:RotateAroundAxis(-self.ViewAngles:Up(), (mx - (self.PressX or mx)) * 0.6)
                end

                self.SPINAT = 0
            else
                self.ViewAngles:RotateAroundAxis(Vector(0, 0, -1), (mx - (self.PressX or mx)) * 0.6)
            end
        end

        self.PressX, self.PressY = gui.MousePos()

        if (RealTime() - (self.lastPressed or 0)) < (self.SPINAT or 0) or self.Pressed or SS_CustomizerPanel:IsVisible() then
            if not SS_CustomizerPanel:IsVisible() then
                self.SPINAT = 4
            end
        else
            self.ViewAngles:RotateAroundAxis(Vector(0, 0, 1), FrameTime() * 5)
        end
    end

    if (SS_CustomizerPanel:IsVisible() and SS_EDITOR_ALIGNZ) then
        self.ViewAngles.pitch = math.Clamp(self.ViewAngles.pitch, -80, 80)

        for i = 0, FrameTime() * 30 do
            self.ViewAngles.roll = self.ViewAngles.roll / 1.05
        end
    end
end

function PANEL:GetCamFocus()
    local pos = Vector(0, 0, 0)
    local ent = self.Entity
    local PrevMins, PrevMaxs = self.Entity:GetRenderBounds()

    if isPonyModel(self.Entity:GetModel()) then
        PrevMins = Vector(-42, -20, -2.5)
        PrevMaxs = Vector(38, 20, 83)
    end

    local center = (PrevMaxs + PrevMins) / 2
    local diam = PrevMins:Distance(PrevMaxs)

    if IsValid(SS_HoverCSModel) then
        ent = SS_HoverCSModel

        return SS_HoverCSModel:GetPos()
    end

    return center
end

function PANEL:GetCamPos()
    local pos = self:GetCamFocus()
    local ang = self:GetLookAng()
    local ent = self.Entity
    local dist = 150

    if IsValid(SS_HoverCSModel) then
        ent = SS_HoverCSModel
        dist = 100
    end

    dist = dist * (1 + ((-self.ZoomOffset or 0) / 10))

    if SS_HoverItem and SS_HoverItem.playermodelmod then
        dist = dist + 25
    end

    pos = pos - ang:Forward() * dist

    return pos
end

function PANEL:GetLookAng()
    return self.ViewAngles
end

function PANEL:GetFOV()
    return self.fFOV
end

function PANEL:Paint()
    if (not IsValid(self.Entity)) then return end
    render.SetColorModulation(1, 1, 1) --WTF
    local x, y = self:LocalToScreen(0, 0)
    self:LayoutEntity(self.Entity)
    local w, h = self:GetSize()
    cam.Start3D(self:GetCamPos(), self:GetLookAng(), self:GetFOV(), x, y, w, h, 5, 4096)
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
        SS_ApplyMaterialMods(self.Entity, LocalPlayer())
        self.Entity:SetEyeTarget(self:GetCamPos())
        self.Entity:DrawModel()
    end

    -- print("HOVER", SS_HoverItem)
    if SS_HoverIOP == nil or SS_HoverIOP.playermodel or SS_HoverIOP.wear or SS_HoverIOP.playermodelmod then
        

        if not SS_ShopAccessoriesClean then
            -- remake every frame lol
            self.Entity:SS_AttachAccessories()
            SS_ShopAccessoriesClean = true
            -- print("REMAKE")
        end

        SS_FORCE_LOAD_WEBMATERIAL = true
        self.Entity:SS_AttachAccessories(self:GetShopAccessoryItems())
        SS_FORCE_LOAD_WEBMATERIAL = nil
        local acc = SS_CreatedAccessories[self.Entity]
        SS_HoverCSModel = SS_HoverItem and SS_HoverItem.wear and acc[1] or nil

        for _, prop in pairs(acc) do
            -- print(prop:GetMaterial())
            prop:DrawModel() --self.Entity)
        end

        local gzmo = self.CurrentGizmo
        local cust = SS_CustomizerPanel
        render.SetColorModulation(1, 1, 1)
        render.SetBlend(1)
        if (IsValid(gzmo) and cust and cust.item) then
            gzmo:Draw()
        end
    end

    -- if SS_HoverItem and SS_HoverItem.wear then
    --     if not IsValid(SS_HoverCSModel) then
    --         SS_HoverCSModel = SS_CreateCSModel(SS_HoverItem)
    --     end
    --     -- SS_HoverCSModel:DrawInShop(self.Entity)
    -- end
    -- ForceDrawPlayer(LocalPlayer())
    render.SuppressEngineLighting(false)
    cam.IgnoreZ(false)
    cam.End3D()
end

function PANEL:PaintOver(w, h)
    if IsValid(SS_DescriptionPanel) then
        _, h = SS_DescriptionPanel:GetPos()
    end

    -- print(w,h)
    -- surface.SetDrawColor(255,0,0,255)
    -- surface.DrawRect(0,h-10,w,10)
    if SS_HoverIOP then
        SS_DrawIOPInfo(SS_HoverIOP, 0, h, w, MenuTheme_TX, 1)
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

function SS_RefreshShopAccessories()
    SS_ShopAccessoriesClean = false
end

vgui.Register('DPointShopPreview', PANEL, 'DModelPanel')