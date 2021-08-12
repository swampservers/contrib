-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local PANEL = {}

--NOMINIFY
local SnapSettings = {
    ["translate"] = {0, 0.5, 1, 2, 4, 8},
    ["rotate"] = {0, 1, 2.5, 5, 10, 15, 45},
}

local icons = {
    select = "swampshop/tool_select.png",
    translate = "swampshop/tool_move.png",
    rotate = "swampshop/tool_rotate.png",
    scale = "swampshop/tool_scale.png",
    Bone = "swampshop/bone.png",
    Attachment = "swampshop/bone.png",
}

SNAPS_MEMORY = SNAPS_MEMORY or {}





function PANEL:ClearProperties()
    self.CurrentGizmo = nil
    if (IsValid(self.ControlContainer)) then
        for _, v in pairs(self.ControlContainer:GetChildren()) do
            if (not v.Static) then
                v:Remove()
            end
        end
    end
end

function PANEL:AddChoiceProperty(choices, keys, config, label)
    local key = table.concat(keys, ".")
    local cust = SS_CustomizerPanel
    self.Controls[key] = self:AddButton(icons[type] or icons[label] or "icon16/shading.png", label, true)

    if (config.sort) then
        self.Controls[key]:SetZPos(config.sort)
    end

    self.Controls[key].DoClick = function(pnl)
        local w, h = pnl:GetSize()
        local x, y = pnl:LocalToScreen(0, h)
        surface.PlaySound("UI/buttonclick.wav")
        local menu = DermaMenu()

        for k, v in pairs(choices) do
            local inn = 1
            local dval = v

            if (istable(v)) then
                dval = v[inn]
            end

            menu:AddOption(dval, function()
                SetNestedProperty(cust.item, keys, k)
                surface.PlaySound("UI/buttonclick.wav")
            end)
        end

        menu:Open(x, y)
        pnl.Gizmo = gzmo
    end
end

function PANEL:AddGizmoProperty(type, keys, config, label)
    local gtype = keys[#keys]

    if (keys[1] == "wear_p") then
        gtype = "wear." .. gtype
    end

    if (keys[1] == "wear_h") then
        gtype = "wear." .. gtype
    end

    if (config.gizmohandler) then
        gtype = config.gizmohandler
    end

    local key = table.concat(keys, ".")
    self.Controls[key] = self:AddButton(icons[type] or "icon16/shading.png", label)

    if (config.sort) then
        self.Controls[key]:SetZPos(config.sort)
    end

    self.Controls[key].DoClick = function(pnl)
        surface.PlaySound("UI/buttonclick.wav")
        local gzmo = self.SetupGizmo[gtype](self)
        gzmo.propkeys = keys
        self.CurrentGizmo = gzmo
        self:SetupSnaps()
        pnl.Gizmo = gzmo
    end
end

function PANEL:Init()
    self:SetModel(LocalPlayer():GetModel())
    self.Angles = Angle(0, 0, 0)
    self.ZoomOffset = 0
    self:SetFOV(30)
    self.ViewAngles = Angle(15, 0, 0)
    self.ControlContainer = self:Add("DPanel")
    self.ControlContainer:Dock(TOP)
    self.ControlContainer:SetTall(0)
    self.ControlContainer:SetZPos(500)
    self.ControlContainer.Paint = noop --SS_PaintFG

    self.ControlContainer2 = self:Add("DPanel")
    self.ControlContainer2:Dock(BOTTOM)
    self.ControlContainer2:SetTall(0)
    self.ControlContainer2:SetZPos(500)
    self.ControlContainer2.Paint = noop --SS_PaintFG


    self.Controls = {}

    --[[
    self.SelectButton = self:AddButton("swampshop/tool_select.png", "Select")
    self.SelectButton.Static = true

    self.SelectButton.DoClick = function(pnl)
        surface.PlaySound("UI/buttonclick.wav")
        local gzmo = self.SetupGizmo.select(self)
        pnl.Gizmo = gzmo
        self.CurrentGizmo = gzmo
        self:SetupSnaps()
    end
    ]]


    self.CameraButton = self:AddButton("icon16/shading.png", "Camera", true)
    self.CameraButton.Static = true

    self.CameraButton.DoClick = function()
        surface.PlaySound("UI/buttonclick.wav")
        SS_EDITOR_ALIGNZ = not SS_EDITOR_ALIGNZ
        self.CameraButton:SetImage(SS_EDITOR_ALIGNZ and "swampshop/view_lock.png" or "swampshop/view_tilt.png")
    end

    self.CameraButton:SetImage(SS_EDITOR_ALIGNZ and "swampshop/view_lock.png" or "swampshop/view_tilt.png")


    self.BackButton = self:AddButton(nil, "Done", true,true)
    self.BackButton.Static = true

    self.BackButton.DoClick = function()
        surface.PlaySound("UI/buttonclick.wav")
        local cust = SS_CustomizerPanel
        SS_ItemServerAction(cust.item.id, "configure", cust.item.cfg)
        SS_CustomizerPanel:Close()  
    end

    self.SaveButton = self:AddButton("icon16/disk.png", "Save Changes", false,true)
    self.SaveButton.Static = true
    self.SaveButton.DoClick = function()
        surface.PlaySound("UI/buttonclick.wav")
        SS_ItemServerAction(SS_CustomizerPanel.item.id, "configure", SS_CustomizerPanel.item.cfg)
    end
    self.SaveButton.Think = function(pnl)
        local cust = SS_CustomizerPanel
        local needsave = cust.item and cust.item._modified
        local img = needsave and "icon16/exclamation.png" or "icon16/disk.png"
        if(pnl:GetImage() != img)then
            pnl:SetImage(img)
        end
    end



    self.RevertButton = self:AddButton(nil, "Undo Changes", false,true)
    self.RevertButton.Static = true
    self.RevertButton.DoClick = function()
        local cust = SS_CustomizerPanel
        surface.PlaySound("UI/buttonclick.wav")
        if( cust.item._modified and cust.item._cachedcfg)then
            cust.item.cfg = table.Copy(cust.item._cachedcfg)
            cust.item._cachedcfg = nil
            cust.item._modified = nil
            cust:UpdateCfg()
            cust:SetupControls(cust.controlzone)
        end
    end

    self.ResetButton = self:AddButton(nil, "Reset Item", false,true)
    self.ResetButton.Static = true
    self.ResetButton.DoClick = function()
        local cust = SS_CustomizerPanel
        surface.PlaySound("UI/buttonclick.wav")
        cust.item.cfg = {}
        cust:UpdateCfg()
        cust:SetupControls(cust.controlzone)
    end

    
    self.SetupSnaps = function()
        if (IsValid(self.SnapsButton)) then
            self.SnapsButton:Remove()
        end

        local cgizmo = self.CurrentGizmo
        if (not IsValid(cgizmo)) then return end
        local name = cgizmo.gizmotype
        local snaptable = SnapSettings[name]

        if (snaptable) then
            self.SnapsButton = self:AddButton("icon16/shading.png", "Snaps", true)

            self.SnapsButton.PaintOver = function(self)
                local cgizmo = self.CurrentGizmo

                if (IsValid(cgizmo)) then
                    local name = cgizmo.gizmotype
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

            cgizmo:SetSnaps(SNAPS_MEMORY[name])

            local img = {
                translate = "swampshop/snaps_move.png",
                rotate = "swampshop/snaps_rotate.png",
            }

            if (IsValid(self.SnapsButton)) then
                self.SnapsButton:SetImage(img[name] or "icon16/shading.png")

                self.SnapsButton.DoClick = function()
                    if (not IsValid(cgizmo)) then return end
                    local name = cgizmo.gizmotype
                    local snaptable = SnapSettings[name]
                    surface.PlaySound("UI/buttonclick.wav")

                    if (snaptable) then
                        local menu = DermaMenu()

                        for k, snap in pairs(snaptable) do
                            if (snap == 0) then
                                snap = nil
                            end

                            menu:AddOption(snap or "Off", function()
                                surface.PlaySound("UI/buttonclick.wav")
                                cgizmo:SetSnaps(snap)
                                print("Snaps!" ,snap)
                                SNAPS_MEMORY[name] = snap
                            end)
                        end

                        menu:Open()
                    end
                end
            end
        end
    end
end

function PANEL:AddButton(icon, propname, right,bottom)
    local cont = bottom and self.ControlContainer2 or self.ControlContainer
    local button = cont:Add(icon and "DImageButton" or "DButton")
    button:Dock(right and RIGHT or LEFT)
    button:SetWide(96)
    button:SetText(propname .. (icon and "  " or ""))
    if(icon)then
    button:SetImage(icon)
    button:SetStretchToFit(false)
    
    button:SetContentAlignment(6)
    button:SetDepressImage(false)
    end
    button:DockMargin(right and SS_COMMONMARGIN or 0, 0, right and 0 or SS_COMMONMARGIN, 0)
    


    local prev = self

    button.UpdateColours = function(pnl)
        local enabled = pnl:IsEnabled()

        local clr = enabled and MenuTheme_TX or ColorAlpha(MenuTheme_TX,64)
        pnl:SetTextColor(clr)
        pnl:SetTextStyleColor(clr)
        if(IsValid(pnl.m_Image))then
        pnl.m_Image:SetImageColor(clr)
        end
    end
    function button:Think() 
        button:UpdateColours()
    end
    function button:PerformLayout() 
        if(IsValid(self.m_Image))then
        self.m_Image:SizeToContents()
        self.m_Image:Center()
        self.m_Image:AlignLeft(SS_SMALLMARGIN)
        end
    end
    button:UpdateColours()

    function button:Paint(w, h)
        local gzmo = self.Gizmo
        local currentgizmo = prev.CurrentGizmo
        local active = gzmo ~= nil and currentgizmo == gzmo
        SS_DrawPanelShadow(self, w, h)
        SS_GLOBAL_RECT(0, 0, w, h, active and MenuTheme_Brand or MenuTheme_FG)
    end

    return button
end

PANEL.SetupGizmo = {}

PANEL.SetupGizmo["paint"] = function(self)
    local cgizmo = gizmo.Create("paint")
    cgizmo:SetupForModelPanel(self)
    local panel = self

    function cgizmo:GetEnt()
        return SS_HoverCSModel
    end
    function cgizmo:GetClickableEnts(value)

    end

    function cgizmo:OnUpdate(value)

    end

    return cgizmo
end


PANEL.SetupGizmo["select"] = function(self)
    local cgizmo = gizmo.Create("select")
    cgizmo:SetupForModelPanel(self)
    local panel = self

    function cgizmo:GetClickableEnts(value)
        local tab = {}
        local acc = SS_CreatedAccessories and SS_CreatedAccessories[panel.Entity]

        if (acc) then
            tab = acc
        end

        return tab
    end

    function cgizmo:OnUpdate(value)
        local itemstemp = table.Copy(LocalPlayer().SS_Items or {})
        local itemid = value.id
        local itemkey 
        for k,v in pairs(itemstemp)do
            if v.id == value.id then
                itemkey = k
                break
            end
        end

        assert(itemkey,"Selection is invalid item id "..value.id)

        if (itemid == SS_CustomizerPanel.item.id) then return end
        surface.PlaySound("UI/buttonclick.wav")
        SS_CustomizerPanel:Open(itemstemp[itemkey])
    end

    return cgizmo
end

PANEL.SetupGizmo["wear.pos"] = function(self)
    local cgizmo = gizmo.Create("translate")
    cgizmo._IsLocalSpace = true
    cgizmo:SetupForModelPanel(self)

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

                if (mat) then
                    bpos, bang = mat:GetTranslation(), mat:GetAngles()
                end
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
        local item = cust.item 
        
        local nestkeys = {"wear_h", "pos"}

        local cur = GetNestedProperty(item, nestkeys,TYPE_VECTOR)
        if(!isvector(cur))then cur = Vector() end
        --self._GrabbedHandleOffset = self._GrabbedHandleOffset + value
        cur = cur + value
        SetNestedProperty(cust.item, nestkeys, cur)
    end

    return cgizmo
end

PANEL.SetupGizmo["wear.ang"] = function(self)
    local cgizmo = gizmo.Create("rotate")
    cgizmo._IsLocalSpace = true
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

                if (mat) then
                    bpos, bang = mat:GetTranslation(), mat:GetAngles()
                end
            end

            if (att) then
                local angpos = par:GetAttachment(att)

                if (angpos) then
                    bpos = angpos.Pos or Vector()
                    bang = angpos.Ang or Angle()
                end
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
        local nestkeys = self.propkeys
        local cur = GetNestedProperty(cust.item, nestkeys,TYPE_ANGLE)
        if(!isangle(cur))then cur = Angle() end
        _, cur = LocalToWorld(Vector(), value, Vector(), cur)
        
        SetNestedProperty(cust.item, nestkeys, cur)
    end

    return cgizmo
end

PANEL.SetupGizmo["wear.scale"] = function(self)
    local cgizmo = gizmo.Create("scale")
    cgizmo._IsLocalSpace = true
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
        local nestkeys = self.propkeys
        local cur = GetNestedProperty(cust.item, nestkeys,{TYPE_VECTOR,TYPE_NUMBER})
        --cur = isvector(cur) and cur or Vector(1,1,1) --we shouldn't need this
        self._ScaleBasis = cur
    end

    function cgizmo:OnUpdate(value)
        local cust = SS_CustomizerPanel
        local nestkeys = self.propkeys
        local cur = GetNestedProperty(cust.item, nestkeys,{TYPE_VECTOR,TYPE_NUMBER})
        --cur = isvector(cur) and cur or Vector(1,1,1) --we shouldn't need this
        cur = self._ScaleBasis * value
        SetNestedProperty(cust.item, nestkeys, cur)
    end

    return cgizmo
end

PANEL.SetupGizmo["bone.pos"] = function(self)
    local cgizmo = gizmo.Create("translate")
    cgizmo._IsLocalSpace = true
    cgizmo:SetupForModelPanel(self)
    local panel = self
    function cgizmo:GetEnt()
        return panel.Entity
    end

    function cgizmo:GetBoneInfo()
        local ent = self:GetEnt()
        local item = SS_GetEditedItem()
        local suf = "_h"
    
        local nestkeys = self.propkeys
        local nestkeys2 = table.Copy(nestkeys)
        nestkeys2[#nestkeys2] = "bone"..suf
        local bone = GetNestedProperty(item, nestkeys2,TYPE_STRING)
        --if(!isstring(bone))then bone = 0 end
        bone = isstring(bone) and ent:LookupBone(bone)

        local bonepar = ent:GetBoneParent(bone or 0)
        if(bonepar == -1)then bonepar = 0 end

        local offset = GetNestedProperty(item, nestkeys,TYPE_VECTOR) or Vector()
        if(!isvector(offset))then offset = Vector() end
        
        return item,bone,bonepar,offset
    end

    function cgizmo:GetPos()
        local ent = self:GetEnt()
        local item, bone,bonepar,offset = self:GetBoneInfo()
        local bpos, bang = ent:GetBonePosition(bone or 0)
        if (bpos) then return bpos end

        return Vector()
    end

    function cgizmo:GetAngles()
        local ent = self:GetEnt()
        local item, bone,bonepar,offset = self:GetBoneInfo()
        local bpos, bang = ent:GetBonePosition(bonepar or 0)
        if (bang) then return bang end

        return Angle()
    end

    function cgizmo:GetScale()
        return 1
    end

    function cgizmo:OnUpdate(value)
        local ent = SS_HoverCSModel
        local cust = SS_CustomizerPanel
        local item = cust.item
        local nestkeys = self.propkeys
        local cur = GetNestedProperty(cust.item, nestkeys,TYPE_VECTOR) 
        --if(!isvector(cur))then cur = Vector() end
        self._GrabbedHandleOffset = self._GrabbedHandleOffset + value
        cur = cur + value
        SetNestedProperty(cust.item, nestkeys, cur)
    end

    return cgizmo
end

PANEL.SetupGizmo["bone.ang"] = function(self)
    local cgizmo = gizmo.Create("rotate")
    cgizmo._IsLocalSpace = true
    cgizmo:SetupForModelPanel(self)
    local panel = self

    function cgizmo:GetEnt()
        return panel.Entity
    end

    function cgizmo:GetBoneInfo()
        local ent = self:GetEnt()
        local item = SS_GetEditedItem()
        local suf = "_h"
    
        local nestkeys = self.propkeys
        local nestkeys2 = table.Copy(nestkeys)
        nestkeys2[#nestkeys2] = "bone"..suf
        local bone = GetNestedProperty(item, nestkeys2,TYPE_STRING)
        bone = isstring(bone) and ent:LookupBone(bone)

        local bonepar = ent:GetBoneParent(bone) or 0
        

        return item,bone,bonepar
    end

    function cgizmo:GetPos()
        local ent = self:GetEnt()
        local item, bone,bonepar = self:GetBoneInfo()
        local bpos, bang = ent:GetBonePosition(bone or 0)
        if (bpos) then return bpos end

        return Vector()
    end

    function cgizmo:GetAngles()
        local ent = self:GetEnt()
        local item, bone,bonepar = self:GetBoneInfo()
        local bpos, bang = ent:GetBonePosition(bone or 0)
        if (bang) then return bang end

        return Angle()
    end


    function cgizmo:GetScale()
        return 1
    end

    function cgizmo:OnUpdate(value)
        local ang = value
        local cust = SS_CustomizerPanel
        local nestkeys = self.propkeys
        local cur = GetNestedProperty(cust.item, nestkeys,TYPE_ANGLE)
        _, cur = LocalToWorld(Vector(), value, Vector(), cur)
        SetNestedProperty(cust.item, nestkeys, cur)
    end

    return cgizmo
end

PANEL.SetupGizmo["bone.scale"] = function(self)
    local cgizmo = gizmo.Create("scale")
    cgizmo._IsLocalSpace = true
    cgizmo:SetupForModelPanel(self)
    local panel = self
    function cgizmo:GetEnt()
        return panel.Entity
    end
    function cgizmo:GetBoneInfo()
        local ent = self:GetEnt()
        local item = SS_GetEditedItem()
        local suf = "_h"
        local nestkeys = self.propkeys
        local nestkeys2 = table.Copy(nestkeys)
        nestkeys2[#nestkeys2] = "bone"..suf
        local bone = GetNestedProperty(item, nestkeys2,TYPE_STRING)

        bone = isstring(bone) and ent:LookupBone(bone)

        return item,bone
    end


    function cgizmo:GetPos()
        local ent = self:GetEnt()
        local item, bone = self:GetBoneInfo()
        local bpos, bang = ent:GetBonePosition(bone or 0)
        if(bpos)then return bpos end
        return Vector()
    end

    function cgizmo:GetAngles()
        local ent = self:GetEnt()
        local item, bone = self:GetBoneInfo()
        local bpos, bang = ent:GetBonePosition(bone or 0)
        if (bang) then return bang end

        return Angle()
    end


    function cgizmo:GetScale()
        return 1
    end

    function cgizmo:OnGrabbed()
        local cust = SS_CustomizerPanel
        local nestkeys = self.propkeys
        local cur = GetNestedProperty(cust.item, nestkeys,TYPE_VECTOR)
        --cur = isvector(cur) and cur or Vector(1,1,1)
        self._ScaleBasis = cur
    end

    function cgizmo:OnUpdate(value)
        local cust = SS_CustomizerPanel
        local nestkeys = self.propkeys
        local cur = GetNestedProperty(cust.item, nestkeys,TYPE_VECTOR)
        --cur = isvector(cur) and cur or Vector(1,1,1)
        cur = self._ScaleBasis * value
        SetNestedProperty(cust.item, nestkeys, cur)
    end

    return cgizmo
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
    if (self.bAnimated) then
        self:RunAnimation()
    end

    local gzmo = self.CurrentGizmo
    local grabbing = IsValid(gzmo) and IsValid(gzmo:GetGrabbedHandle())
    self.Entity:SetPlaybackRate(0.01)
    for i=0,6 do
        self.Entity:SetLayerPlaybackRate( i,0.01 )
    end

    if not SS_CustomizerPanel:IsVisible() then
        for i = 0, FrameTime() * 30 do
            self.ViewAngles.pitch = ((self.ViewAngles.pitch - 15) / 1.05) + 15
            self.ViewAngles.roll = self.ViewAngles.roll / 1.05
        end
    end

    if (self.Pressed) then
        local mx, my = gui.MousePos()
        local dx, dy = (mx - (self.PressX or mx)) , (my - (self.PressY or my))
        if self.PressButton == MOUSE_LEFT then
            if SS_CustomizerPanel:IsVisible() then
                if (SS_EDITOR_ALIGNZ) then
                    self.ViewAngles.pitch = math.Clamp(self.ViewAngles.pitch + dy * 0.6,-89,89)
                    self.ViewAngles:RotateAroundAxis(Vector(0, 0, -1), dx * 0.6)
                else
                    self.ViewAngles:RotateAroundAxis(-self.ViewAngles:Right(), dy * 0.6)
                    self.ViewAngles:RotateAroundAxis(-self.ViewAngles:Up(), dx * 0.6)
                end

                self.SPINAT = 0
            else
                self.ViewAngles:RotateAroundAxis(Vector(0, 0, -1), (dx) * 0.6)
            end
        end

        if self.PressButton == MOUSE_RIGHT then
            if SS_CustomizerPanel:IsVisible() then
                
                    self.ViewOffset = self.ViewOffset or Vector()
                    self.ViewOffset = self.ViewOffset + self.ViewAngles:Right()*dx*0.2
                    self.ViewOffset = self.ViewOffset + self.ViewAngles:Up()*dy*-0.2


                    if (SS_EDITOR_ALIGNZ) then

                    else

                    end

                    self.SPINAT = 0
            end
        end


        input.SetCursorPos(self.PressX, self.PressY)
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
    local mainent = ent
    local PrevMins, PrevMaxs = self.Entity:GetRenderBounds()

    if isPonyModel(self.Entity:GetModel()) then
        PrevMins = Vector(-42, -20, -2.5)
        PrevMaxs = Vector(38, 20, 83)
    end

    local center = (PrevMaxs + PrevMins) / 2
    center = center * Vector(0, 0, 1)
    local diam = PrevMins:Distance(PrevMaxs)
    pos = center
    
    if IsValid(SS_HoverCSModel) then
        ent = SS_HoverCSModel
        pos =  SS_HoverCSModel:GetPos()
        local cust = SS_CustomizerPanel
        if(IsValid(cust))then
            local item = cust.item
            if(item and item.wear)then
                local pone = isPonyModel(mainent:GetModel())
                local attach, translate, rotate, scale = item:AccessoryTransform(pone)
                local bpos,bang 
                if attach == "eyes" then
                    local attach_id = mainent:LookupAttachment("eyes")
                    local angpos = mainent:GetAttachment(attach_id or 0)
                        if(angpos)then
                            bpos,bang = angpos.Pos,angpos.Ang
                        end
                else
                    local bone_id = mainent:LookupBone(SS_Attachments[attach][pone and 2 or 1])
                    bpos,bang = mainent:GetBonePosition(bone_id or 0)
                end
                if(bpos)then
                    pos = bpos
                end
            end
        end
    end


    pos = pos + (self.ViewOffset or Vector())
    
    

    return pos
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

    if SS_GetSelectedItem() and SS_GetSelectedItem().playermodelmod then
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
    local isplayer = true
    local drawplayer = true
    local hide_accessory --hide accessories if not drawing single product?
    local iop = SS_HoverIOP
    local cust = SS_CustomizerPanel
   
    if(iop)then
        local equipped = iop.cfg and !iop.never_equip and iop.eq
        if iop.wear and !equipped and IsValid(cust) then drawplayer = false end
        if iop.playermodel then drawplayer = false end
        if iop.playermodelmod then drawplayer = equipped end
    end

    if !drawplayer then
        mdl = iop:GetModel()
    end

    require_workshop_model(mdl)
    self:SetModelCaching(mdl)

    if isPonyModel(self.Entity:GetModel()) then
        -- PPM.PrePonyDraw(self.Entity, true)
        -- PPM.setBodygroups(self.Entity, true)
        PPM_SetBodyGroups(self.Entity)
    end

    if drawplayer then
        render.MaterialOverride()
        self.Entity.GetPlayerColor = function() return LocalPlayer():GetPlayerColor() end
        local mods = LocalPlayer():SS_GetShownPlayermodelMods(true)
        SS_ApplyBoneMods(self.Entity, mods)
        SS_ApplyMaterialMods(self.Entity, LocalPlayer())
        self.Entity:SetEyeTarget(self:GetCamPos())

        self.Entity:DrawModel()

        local function GetShopAccessoryItems()
            local a = {}


            if IsValid(LocalPlayer()) then
                for _, item in pairs(LocalPlayer():SS_GetShownAccessories(true)) do
                    if(!item.eq)then continue end
                    table.insert(a, item)
                end
            end

            return a
        end

        if not SS_ShopAccessoriesClean then
            -- remake every frame lol
            --self.Entity:SS_AttachAccessories(GetShopAccessoryItems())
            --SS_ShopAccessoriesClean = true
            -- print("REMAKE")
        end

        SS_FORCE_LOAD_WEBMATERIAL = true
        self.Entity:SS_AttachAccessories(GetShopAccessoryItems())
        SS_FORCE_LOAD_WEBMATERIAL = nil
        local acc = SS_CreatedAccessories[self.Entity] or {}

        
        SS_HoverCSModel = nil
        if(cust.item)then
        for k,prop in pairs(acc)do
            if(prop.id == cust.item.id)then
                SS_HoverCSModel = prop
                break
            end
        end
        end

        for _, prop in pairs(acc) do
            -- print(prop:GetMaterial())
            prop:DrawModel() --self.Entity)
        end



    else
        --draw single item
        if SS_GetSelectedItem() then
            SS_PreRender(iop)
        end

        SS_PreviewShopModel(self, iop)
        self:SetCamPos(self:GetCamPos() * 2)
        self.Entity:DrawModel()

        if SS_GetSelectedItem() then
            SS_PreRender(iop)
        end
    end
    --[[
    if(SS_MAT_DRAWOVER and IsValid(SS_HoverCSModel))then
        render.MaterialOverride(SS_MAT_DRAWOVER)

        SS_HoverCSModel:DrawModel()
    end    
    ]]

    -- if in editor, draw our gizmos
    local cust = SS_CustomizerPanel
    local gzmo = self.CurrentGizmo
    if IsValid(cust) and iop then
        render.SetColorModulation(1, 1, 1)
        render.SetBlend(1)

        if (IsValid(gzmo) and cust and cust.item) then
            gzmo:Draw()
        end
        --while right clicking, draw the axis so the user knows where the camera will orbit around
        if self.Pressed and self.PressButton == MOUSE_RIGHT then
            local cent = self:GetCamFocus()
            local size = 16
            for k,v in pairs({Vector(0,0,1),Vector(1,0,0),Vector(0,1,0)})do
                local cl = v:ToColor()
                cl.a = 64
                render.DrawLine( cent - v*size, cent + v*size, cl,true)
            end
        end
    end

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
    local ply = LocalPlayer()




    local cust = SS_CustomizerPanel
    local custopen = IsValid(cust) and cust.item
    if SS_HoverIOP and not custopen then
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