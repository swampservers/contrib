-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local PANEL = {}

function PANEL:Close()
    if IsValid(SS_PopupPanel) and IsValid(SS_ShopMenu) then
        SS_ShopMenu:SetParent()
        SS_PopupPanel:Remove()
        SS_ShopMenu:SetKeyboardInputEnabled(false)
    end

    self:SetVisible(false)
    SS_InventoryPanel:SetVisible(true)
end

function PANEL:Open(item)
    for k, v in pairs(self:GetChildren()) do
        v:Remove()
    end

    self.item = item
    item.applied_cfg = table.Copy(item.cfg)
    self.wear = LocalPlayer():IsPony() and "wear_p" or "wear_h"

    if IsValid(SS_PopupPanel) then
        SS_ShopMenu:SetParent()
        SS_PopupPanel:Remove()
    end

    SS_ShopMenu:MakePopup()
    --SS_PaintTileBG
    self.Paint = SS_PaintBG

    --.Paint = SS_PaintGridBG
    --.Paint = SS_PaintTileBG
    SS_PopupPanel = vgui("DFrame", function(p)
        p:SetPos(0, 0)
        p:SetSize(ScrW(), ScrH())
        p:SetDraggable(false)
        p:ShowCloseButton(true)
        p:SetTitle("")
        p:RequestFocus()
        p.Paint = function() end
        p:SetParent(SS_PopupPanel)
    end)

    self:SetVisible(true)
    SS_InventoryPanel:SetVisible(false)

    --main panel
    vgui("DPanel", self, function(p)
        p.Paint = noop
        p:Dock(FILL)
        p:DockMargin(0, 0, 0, 0)

        self.controlzone = vgui("DPanel", function(p)
            p:Dock(FILL)
            p:DockMargin(0, 0, 0, 0)
            p.Paint = SS_PaintBG
        end)

        self:SetupControls()

        vgui("DPanel", function(p)
            p.Paint = SS_PaintFG
            p:DockMargin(0, 0, 0, SS_COMMONMARGIN)
            p:SetTall(SS_CUSTOMIZER_HEADINGSIZE)
            p:Dock(TOP)

            vgui("DLabel", function(p)
                p:SetFont("SS_LargeTitle")
                p:SetText("βUSTOMIZER")

                p.UpdateColours = function(pnl)
                    pnl:SetTextColor(MenuTheme_TX)
                end

                p:SetColor(SS_SwitchableColor)
                p:SetContentAlignment(5)
                p:SizeToContents()
                p:DockMargin(80, 8, 0, 10)
                p:Dock(LEFT)
            end)

            vgui("DLabel", function(p)
                p:SetFont("SS_DESCINSTFONT")
                p:SetText("                                      WARNING:\nPornographic images or builds are not allowed!")

                p.UpdateColours = function(pnl)
                    pnl:SetTextColor(MenuTheme_TX)
                end

                p:SetColor(SS_SwitchableColor)
                p:SetContentAlignment(5)
                p:SizeToContents()
                p:DockMargin(0, 0, 32, 0)
                p:Dock(RIGHT)
            end)
        end)

        --bottom panel
        vgui("DPanel", function(p)
            p.Paint = function() end
            p:SetTall(SS_CUSTOMIZER_HEADINGSIZE)
            p:Dock(BOTTOM)

            vgui("DButton", function(p)
                p:SetText("Reset")
                p:SetFont("SS_DESCTITLEFONT")
                p:SetWide(SS_GetMainGridDivision(4))
                p:DockMargin(0, SS_COMMONMARGIN, SS_COMMONMARGIN, 0)
                p:Dock(LEFT)
                p.Paint = SS_PaintButtonBrandHL

                p.UpdateColours = function(pnl)
                    pnl:SetTextStyleColor(MenuTheme_TX)
                end

                p.DoClick = function(butn)
                    self.item.cfg = {}
                    self:UpdateCfg()
                    self:SetupControls()
                end
            end)

            vgui("DButton", function(p)
                p:SetText("Cancel")
                p:SetFont("SS_DESCTITLEFONT")
                p:SetWide(SS_GetMainGridDivision(4))
                p:DockMargin(0, SS_COMMONMARGIN, 0, 0)
                p:Dock(LEFT)
                p.Paint = SS_PaintButtonBrandHL

                p.UpdateColours = function(pnl)
                    pnl:SetTextStyleColor(MenuTheme_TX)
                end

                p.DoClick = function(butn)
                    self.item.cfg = self.item.applied_cfg
                    self:Close()
                end
            end)

            vgui("DButton", function(p)
                p:SetText("Done")
                p:SetFont("SS_DESCTITLEFONT")
                p:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, 0, 0)
                p:Dock(FILL)
                p.Paint = SS_PaintButtonBrandHL

                p.UpdateColours = function(pnl)
                    pnl:SetTextStyleColor(MenuTheme_TX)
                end

                p.DoClick = function(butn)
                    net.Start('SS_ConfigureItem')
                    net.WriteUInt(self.item.id, 32)
                    net.WriteTableHD(self.item.cfg)
                    net.SendToServer()
                    self:Close()
                end
            end)
        end)
    end)
end

local function GapMaker(parent)
    local GAP = vgui.Create("DPanel", parent)
    GAP:Dock(TOP)
    GAP:SetTall(SS_COMMONMARGIN)
    GAP.Paint = function() end
end

local function LabelMaker(parent, text, top)
    local p2 = nil

    if not top or true then
        p2 = vgui.Create("Panel", parent)
        p2:DockMargin(0, 0, 0, SS_COMMONMARGIN)
        p2:Dock(TOP)
        p2.Paint = noop --SS_PaintBG

        if parent.AddItem then
            parent:AddItem(p2)
        end
    end

    local p = vgui.Create("DLabel", p2 or parent)
    p:SetFont("SS_DESCINSTFONT")
    p:SetText(text)
    p:SetTextColor(SS_SwitchableColor)
    p:SizeToContents()

    p.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
    end

    if top then
        p:SetContentAlignment(5)
        p:DockMargin(0, 0, 0, 0)
        p:Dock(FILL)

        if parent.AddItem then
            parent:AddItem(p)
        end
    else
        p:DockMargin(0, 0, 0, 0)
        p:Dock(LEFT)
    end

    return p2
end

local function SliderMaker(parent, text)
    local p = vgui.Create("DNumSlider", parent)
    p:SetText(text)
    p:SetDecimals(2)
    p:DockMargin(0, 0, 0, SS_COMMONMARGIN)
    p:Dock(TOP)
    p:SetDark(not SS_DarkMode)
    p.TextArea:SetPaintBackground(false)
    p:SetTall(24)
    p.TextArea.BasedPaint = p.TextArea.Paint

    p.TextArea.Paint = function(pnl, w, h)
        SS_PaintBG(pnl, w, h)
        p.TextArea.BasedPaint(pnl, w, h)
    end

    p.TextArea.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
    end

    p.TextArea:DockMargin(SS_COMMONMARGIN, 0, 0, 0)

    p.Label.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
    end

    p.Slider.Knob:SetWide(6)

    p.Slider.Paint = function(pnl, w, h)
        local y = h / 2
        local barh = 2
        SS_GLOBAL_RECT(0, y - barh / 2, w, barh, MenuTheme_BG)
    end

    p.Slider.Knob.Paint = function(pnl, w, h)
        draw.BoxShadow(0, 0, w, h, 8, 1)
        SS_GLOBAL_RECT(0, 0, w, h, MenuTheme_Brand)
    end

    if parent.AddItem then
        parent:AddItem(p)
    end

    return p
end

local function CheckboxMaker(parent, text)
    local p2 = vgui.Create("Panel", parent)
    p2:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
    p2:Dock(TOP) --retarded wrapper
    local p3 = vgui.Create("DCheckBox", p2)
    --p:SetText(text)
    p3:SetDark(true)
    p3:SetPos(0, 2)
    --p:SetTall(24)
    local p = vgui.Create("DLabel", p2 or parent)
    p:SetFont("SS_DESCFONT")
    p:SetText(text)
    p:SetTextColor(SS_SwitchableColor)
    p:SetPos(24, 0)
    p:SizeToContents()

    --p2:SizeToChildren()
    if parent.AddItem then
        parent:AddItem(p2)
    end

    return p3
end

local function Container(parent, label)
    local pane = vgui.Create("Panel", parent)
    pane:DockMargin(0, 0, 0, 0)
    pane:DockPadding(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
    pane:Dock(TOP) --retarded wrapper
    pane:SetTall(512)
    pane.Paint = SS_PaintFG

    pane.PerformLayout = function(pnl)
        pnl:SizeToChildren(true, true)

        if (IsValid(parent) and parent:GetName() == "DScrollPanel") then
            pnl:DockMargin(0, 0, parent.VBar:IsVisible() and SS_COMMONMARGIN or 0, SS_COMMONMARGIN)
        else
            pnl:DockMargin(0, 0, 0, SS_COMMONMARGIN)
        end
    end

    LabelMaker(pane, label, true)

    return pane
end

function PANEL:SetupControls()
    for k, v in pairs(self.controlzone:GetChildren()) do
        v:Remove()
    end

    local wear_container = vgui.Create("DScrollPanel", self.controlzone)
    wear_container:Dock(LEFT)
    wear_container:SetWide(SS_GetMainGridDivision(2))
    wear_container:DockMargin(0, 0, SS_COMMONMARGIN, 0)
    wear_container.VBar:DockMargin(SS_COMMONMARGIN, 0, SS_COMMONMARGIN, 0)
    SS_SetupVBar(wear_container.VBar)
    wear_container.VBar:SetWide(SS_SCROLL_WIDTH)
    local pone = LocalPlayer():IsPony()
    local suffix = pone and "_p" or "_h"
    local itmcw = self.item.configurable.wear

    if (self.item.configurable or {}).wear then
        --LabelMaker(wearzone, "Position (" .. (pone and "pony" or "human") .. ")", true)
        local pane = Container(wear_container, "Attachment")
        local cnt = vgui.Create("DPanel", pane)
        cnt:Dock(TOP)
        cnt:SetTall(24)
        cnt.Paint = noop
        ATTACHSELECT = vgui.Create("DComboBox", cnt)
        ATTACHSELECT:SetValue((self.item.cfg[self.wear] or {}).attach or (pone and (self.item.wear.pony or {}).attach) or self.item.wear.attach)

        for k, v in pairs(SS_Attachments) do
            ATTACHSELECT:AddChoice(k)
        end

        ATTACHSELECT:SetTall(32)
        ATTACHSELECT:Dock(FILL)
        ATTACHSELECT.Paint = SS_PaintBG

        ATTACHSELECT.UpdateColours = function(pnl)
            pnl:SetTextStyleColor(MenuTheme_TX)
            pnl:SetTextColor(MenuTheme_TX)
        end

        p = vgui.Create("DLabel", cnt)
        p:Dock(LEFT)
        p:SetText("Attach to")

        p.UpdateColours = function(pnl)
            pnl:SetTextColor(MenuTheme_TX)
        end

        ATTACHSELECT.OnSelect = function(panel, index, value)
            self.item.cfg[self.wear] = self.item.cfg[self.wear] or {}
            self.item.cfg[self.wear].attach = value
            self:UpdateCfg()
        end

        local pane = Container(wear_container, "Offset")
        local translate = (self.item.cfg[self.wear] or {}).pos or (pone and (self.item.wear.pony or {}).translate) or self.item.wear.translate
        XSL = SliderMaker(pane, "Forward/Backward")
        XSL:SetMinMax(itmcw.pos.min.x, itmcw.pos.max.x)
        XSL:SetValue(translate.x)
        YSL = SliderMaker(pane, "Left/Right")
        YSL:SetMinMax(itmcw.pos.min.y, itmcw.pos.max.z)
        YSL:SetValue(translate.y)
        ZSL = SliderMaker(pane, "Up/Down")
        ZSL:SetMinMax(itmcw.pos.min.z, itmcw.pos.max.z)
        ZSL:SetValue(translate.z)
        local pane = Container(wear_container, "Angle")
        local rotate = (self.item.cfg[self.wear] or {}).ang or (pone and (self.item.wear.pony or {}).rotate) or self.item.wear.rotate
        XRSL = SliderMaker(pane, "Pitch")
        XRSL:SetMinMax(-180, 180)
        XRSL:SetValue(rotate.p)
        YRSL = SliderMaker(pane, "Yaw")
        YRSL:SetMinMax(-180, 180)
        YRSL:SetValue(rotate.y)
        ZRSL = SliderMaker(pane, "Roll")
        ZRSL:SetMinMax(-180, 180)
        ZRSL:SetValue(rotate.r)
        local pane = Container(wear_container, "Scale")
        local scale = (self.item.cfg[self.wear] or {}).scale or (pone and (self.item.wear.pony or {}).scale) or self.item.wear.scale

        if isnumber(scale) then
            scale = Vector(scale, scale, scale)
        end

        SXSL = SliderMaker(pane, "Length")
        SXSL:SetMinMax(itmcw.scale.min.x, itmcw.scale.max.x)
        SXSL:SetValue(scale.x)
        SYSL = SliderMaker(pane, "Width")
        SYSL:SetMinMax(itmcw.scale.min.y, itmcw.scale.max.y)
        SYSL:SetValue(scale.y)
        SZSL = SliderMaker(pane, "Height")
        SZSL:SetMinMax(itmcw.scale.min.z, itmcw.scale.max.z)
        SZSL:SetValue(scale.z)

        local function transformslidersupdate()
            self.item.cfg[self.wear] = self.item.cfg[self.wear] or {}
            self.item.cfg[self.wear].pos = Vector(XSL:GetValue(), YSL:GetValue(), ZSL:GetValue())
            self.item.cfg[self.wear].ang = Angle(XRSL:GetValue(), YRSL:GetValue(), ZRSL:GetValue())
            self.item.cfg[self.wear].scale = Vector(SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue())
            self:UpdateCfg()
        end

        XSL.OnValueChanged = transformslidersupdate
        YSL.OnValueChanged = transformslidersupdate
        ZSL.OnValueChanged = transformslidersupdate
        XRSL.OnValueChanged = transformslidersupdate
        YRSL.OnValueChanged = transformslidersupdate
        ZRSL.OnValueChanged = transformslidersupdate
        SXSL.OnValueChanged = transformslidersupdate
        SYSL.OnValueChanged = transformslidersupdate
        SZSL.OnValueChanged = transformslidersupdate
        SUSL = SliderMaker(pane, "Scale")
        SUSL:SetMinMax(math.max(itmcw.scale.min.x, itmcw.scale.min.y, itmcw.scale.min.z), math.min(itmcw.scale.max.x, itmcw.scale.max.y, itmcw.scale.max.z))

        SUSL.OnValueChanged = function(self)
            SXSL:SetValue(self:GetValue())
            SYSL:SetValue(self:GetValue())
            SZSL:SetValue(self:GetValue())
        end

        SUSL:SetVisible(false)
        local scalebutton = vgui.Create("DButton", pane)
        scalebutton:SetText("Use Uniform Scaling")
        scalebutton:SetWide(160)
        scalebutton:Dock(TOP)
        scalebutton.Paint = SS_PaintButtonBrandHL

        scalebutton.UpdateColours = function(pnl)
            pnl:SetTextStyleColor(MenuTheme_TX)
        end

        scalebutton.DoClick = function(btn)
            if btn.UniformMode then
                btn.UniformMode = nil
                btn:SetText("Use Uniform Scaling")
                SXSL:SetVisible(true)
                SYSL:SetVisible(true)
                SZSL:SetVisible(true)
                SUSL:SetVisible(false)
            else
                btn.UniformMode = true
                btn:SetText("Use Independent Scaling")
                SXSL:SetVisible(false)
                SYSL:SetVisible(false)
                SZSL:SetVisible(false)
                SUSL:SetVisible(true)

                local v = {SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue()}

                table.sort(v, function(a, b) return a > b end)
                SUSL:SetValue(v[2])
            end
        end

        if scale.x == scale.y and scale.y == scale.z then
            scalebutton:DoClick()
        end
    elseif (self.item.configurable or {}).bone then
        local pane = Container(wear_container, "Mod (" .. (LocalPlayer():IsPony() and "pony" or "human") .. ")")

        local function cleanbonename(bn)
            return bn:Replace("ValveBiped.Bip01_", ""):Replace("Lrig", ""):Replace("_LEG_", "")
        end

        ATTACHSELECT = vgui.Create("DComboBox", pane)
        ATTACHSELECT:SetValue(cleanbonename(self.item.cfg["bone" .. suffix] or (pone and "Scull" or "Head1")))
        ATTACHSELECT:SetTall(24)
        ATTACHSELECT:Dock(TOP)
        ATTACHSELECT.Paint = SS_PaintBG

        ATTACHSELECT.UpdateColours = function(pnl)
            pnl:SetTextStyleColor(MenuTheme_TX)
            pnl:SetTextColor(MenuTheme_TX)
        end

        for x = 0, (LocalPlayer():GetBoneCount() - 1) do
            local bn = LocalPlayer():GetBoneName(x)
            local cleanname = cleanbonename(bn)

            if cleanname ~= "__INVALIDBONE__" then
                ATTACHSELECT:AddChoice(cleanname, bn)
            end
        end

        ATTACHSELECT.OnSelect = function(panel, index, word, value)
            self.item.cfg["bone" .. suffix] = value
            self:UpdateCfg()
        end

        --bunch of copied shit
        local function transformslidersupdate()
            if self.item.configurable.scale then
                self.item.cfg["scale" .. suffix] = Vector(SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue())
            end

            if self.item.configurable.pos then
                self.item.cfg["pos" .. suffix] = Vector(XSL:GetValue(), YSL:GetValue(), ZSL:GetValue())
            end

            self:UpdateCfg()
        end

        local itmcp = self.item.configurable.pos

        if itmcp then
            local pane = Container(wear_container, "Offset")
            local translate = self.item.cfg["pos" .. suffix] or Vector(0, 0, 0)
            XSL = SliderMaker(pane, "X (Along)")
            XSL:SetMinMax(itmcp.min.x, itmcp.max.x)
            XSL:SetValue(translate.x)
            YSL = SliderMaker(pane, "Y")
            YSL:SetMinMax(itmcp.min.y, itmcp.max.y)
            YSL:SetValue(translate.y)
            ZSL = SliderMaker(pane, "Z")
            ZSL:SetMinMax(itmcp.min.z, itmcp.max.z)
            ZSL:SetValue(translate.z)
            XSL.OnValueChanged = transformslidersupdate
            YSL.OnValueChanged = transformslidersupdate
            ZSL.OnValueChanged = transformslidersupdate
        end

        local itmcs = self.item.configurable.scale

        if itmcs then
            local pane = Container(wear_container, "Scale")
            local scale = self.item.cfg["scale" .. suffix] or Vector(1, 1, 1)

            if isnumber(scale) then
                scale = Vector(scale, scale, scale)
            end

            SXSL = SliderMaker(pane, "X (Along)")
            SXSL:SetMinMax(itmcs.min.x, itmcs.max.x)
            SXSL:SetValue(scale.x)
            SYSL = SliderMaker(pane, "Y")
            SYSL:SetMinMax(itmcs.min.y, itmcs.max.y)
            SYSL:SetValue(scale.y)
            SZSL = SliderMaker(pane, "Z")
            SZSL:SetMinMax(itmcs.min.z, itmcs.max.z)
            SZSL:SetValue(scale.z)
            SXSL.OnValueChanged = transformslidersupdate
            SYSL.OnValueChanged = transformslidersupdate
            SZSL.OnValueChanged = transformslidersupdate
            SUSL = SliderMaker(pane, "Scale")
            SUSL:SetMinMax(math.max(itmcs.min.x, itmcs.min.y, itmcs.min.z), math.min(itmcs.max.x, itmcs.max.y, itmcs.max.z))

            SUSL.OnValueChanged = function(self)
                SXSL:SetValue(self:GetValue())
                SYSL:SetValue(self:GetValue())
                SZSL:SetValue(self:GetValue())
            end

            SUSL:SetVisible(false)
            local scalebutton = vgui.Create("DButton", pane)
            scalebutton:SetText("Use Uniform Scaling")
            scalebutton:SetWide(160)
            scalebutton.Paint = SS_PaintButtonBrandHL
            scalebutton:Dock(TOP)

            scalebutton.UpdateColours = function(pnl)
                pnl:SetTextStyleColor(MenuTheme_TX)
            end

            scalebutton.DoClick = function(btn)
                if btn.UniformMode then
                    btn.UniformMode = nil
                    btn:SetText("Use Uniform Scaling")
                    SXSL:SetVisible(true)
                    SYSL:SetVisible(true)
                    SZSL:SetVisible(true)
                    SUSL:SetVisible(false)
                else
                    btn.UniformMode = true
                    btn:SetText("Use Independent Scaling")
                    SXSL:SetVisible(false)
                    SYSL:SetVisible(false)
                    SZSL:SetVisible(false)
                    SUSL:SetVisible(true)

                    local v = {SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue()}

                    table.sort(v, function(a, b) return a > b end)
                    SUSL:SetValue(v[2])
                end
            end

            if scale.x == scale.y and scale.y == scale.z then
                scalebutton:DoClick()
            end
        end

        --end bunch of copied shit
        if self.item.configurable.scale_children then
            CHILDCHECKBOX = CheckboxMaker(pane, "Scale child bones")
            CHILDCHECKBOX:SetValue(self.item.cfg["scale_children" .. suffix] and 1 or 0)

            CHILDCHECKBOX.OnChange = function(checkboxself, ch)
                self.item.cfg["scale_children" .. suffix] = ch
                self:UpdateCfg()
            end
        end
    elseif (self.item.configurable or {}).submaterial then
        local pane = Container(wear_container, "Skin ID")
        ATTACHSELECT = vgui.Create("DComboBox", pane)

        for x = 0, math.min(31, (#(LocalPlayer():GetMaterials()) - 1)) do
            local matname = LocalPlayer():GetMaterials()[x + 1] or ""
            local exp = string.Explode("/", matname)
            local nicename = exp[#exp]
            local sel = tonumber(self.item.cfg.submaterial or 0) == x
            ATTACHSELECT:AddChoice(tostring(x) .. " (" .. nicename .. ")", tostring(x), sel)
        end

        ATTACHSELECT.OnSelect = function(panel, index, word, value)
            self.item.cfg.submaterial = tonumber(value)
            self:UpdateCfg()
        end

        ATTACHSELECT:SetWide(200)
        ATTACHSELECT:Dock(TOP)
        ATTACHSELECT.Paint = SS_PaintBG

        ATTACHSELECT.UpdateColours = function(pnl)
            pnl:SetTextStyleColor(MenuTheme_TX)
            pnl:SetTextColor(MenuTheme_TX)
        end
    end

    local appearance_container = vgui.Create("DScrollPanel", self.controlzone)
    appearance_container:Dock(FILL)
    appearance_container:SetPadding(0)
    appearance_container.VBar:DockMargin(SS_COMMONMARGIN, 0, 0, 0)
    SS_SetupVBar(appearance_container.VBar)
    appearance_container.VBar:SetWide(SS_SCROLL_WIDTH)

    if (self.item.configurable or {}).color then
        local colorzone = Container(appearance_container, "Appearance")
        --[[
    local colorzone = vgui.Create("DPanel", appearance_container)
    colorzone.Paint = SS_PaintFG
    colorzone:Dock(TOP)
    colorzone:DockPadding(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
    colorzone:DockMargin(0,0,0,SS_COMMONMARGIN)

    
    --colorzone:SetTall( SS_GetCustomizerHeight())
    colorzone.PerformLayout = function(pnl)
        
        pnl:SizeToChildren(false, true)
        pnl:InvalidateParent(true)
        pnl:DockMargin(0, 0, appearance_container.VBar:IsVisible() and SS_COMMONMARGIN or 0, SS_COMMONMARGIN)
    end
    ]]
        local cv = Vector()
        cv:Set(self.item.cfg.color or self.item.color or Vector(1, 1, 1))
        local cvm = math.max(1, cv.x, cv.y, cv.z)
        PSCMixer = vgui.Create("DColorMixer", colorzone)
        PSCMixer:SetPalette(true)
        PSCMixer:SetAlphaBar(false)
        PSCMixer:SetWangs(true)
        PSCMixer:SetVector(cv / cvm)
        PSCMixer:SetTall(250)
        PSCMixer:DockMargin(0, 0, 0, 0)
        PSCMixer:Dock(TOP)
        PSBS = SliderMaker(colorzone, "Boost")
        PSBS:SetMinMax(1, self.item.configurable.color.max)
        PSBS:SetValue(cvm)
        PSBS:DockMargin(0, SS_COMMONMARGIN, 0, SS_COMMONMARGIN)

        local function colorchanged()
            self.item.cfg.color = PSCMixer:GetVector() * PSBS:GetValue()
            self:UpdateCfg()
        end

        PSCMixer.ValueChanged = colorchanged
        PSBS.OnValueChanged = colorchanged
    end

    if (self.item.configurable or {}).imgur then
        local texturezone = Container(appearance_container, "Custom Material")
        --[[
        local texturezone = vgui.Create("DPanel", appearance_container)
        texturezone.Paint = SS_PaintFG
        texturezone:Dock(TOP)
        texturezone:DockMargin(0,SS_COMMONMARGIN*2,0,0)
        texturezone:DockPadding(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
        texturezone.PerformLayout = function(pnl)
            pnl:SizeToChildren(false, true)
            pnl:InvalidateParent(true)
            pnl:DockMargin(0, 0, appearance_container.VBar:IsVisible() and SS_COMMONMARGIN or 0, SS_COMMONMARGIN)
        end
        

        LabelMaker(texturezone, "Custom Material", true)
        ]]
        local texturebarhelp = vgui.Create("DLabel", texturezone)
        texturebarhelp:Dock(TOP)
        texturebarhelp:DockMargin(0, 0, 0, SS_COMMONMARGIN)
        texturebarhelp:SetText("Upload an image to imgur.com and enter the link into the field below.\nFor example: https://imgur.com/a/3AOvcC1\nNo videos or GIFs!")
        texturebarhelp:SetWrap(true)
        texturebarhelp:SetTall(128)
        texturebarhelp:SetAutoStretchVertical(true)

        texturebarhelp.UpdateColours = function(pnl)
            pnl:SetTextColor(MenuTheme_TX)
        end

        local texturec = vgui.Create("DPanel", texturezone)
        texturec:Dock(TOP)
        texturec.Paint = noop
        local texturedl = vgui.Create("DButton", texturec)
        texturedl:SetText("Show Reference Material")
        texturedl:Dock(RIGHT)
        texturedl:SetWide(180)
        texturedl:SetTextColor(MenuTheme_TX)
        texturedl:DockMargin(SS_COMMONMARGIN, 0, 0, 0)
        texturedl.Paint = SS_PaintButtonBrandHL

        texturedl.UpdateColours = function(pnl)
            pnl:SetTextStyleColor(MenuTheme_TX)
        end

        texturedl.DoClick = function()
            ImageGetterPanel()
        end

        local texturebarc = vgui.Create("DPanel", texturec)
        texturebarc:Dock(TOP)
        texturebarc.Paint = SS_PaintBG
        local texturebar = vgui.Create("DTextEntry", texturebarc)
        texturebar:Dock(FILL)
        self.TextureBar = texturebar
        texturebar:SetPaintBackground(false)
        texturebar:SetUpdateOnType(true)
        texturebar:SetTextColor(MenuTheme_TX)
        texturebar:SetText(self.item and self.item.cfg and self.item.cfg.imgur and self.item.cfg.imgur.url or "")

        texturebar.UpdateColours = function(pnl)
            pnl:SetTextColor(MenuTheme_TX)
            pnl:SetCursorColor(MenuTheme_TX)
        end

        texturebar.OnValueChange = function(textself, new)
            self.item.cfg.imgur = new and {
                url = new,
                nsfw = nsfw
            } or nil

            self:UpdateCfg()
        end

        local savebutton = vgui.Create("DImageButton", texturebarc)
        savebutton:SetSize(16, 16)
        savebutton:SetImage("icon16/disk.png")
        savebutton:SetToolTip("Manage Saved Textures")
        savebutton:DockMargin(4, 4, 4, 4)
        savebutton:Dock(RIGHT)

        savebutton.DoClick = function(pnl)
            if (IsValid(SS_CustTextureHistory)) then
                SS_CustTextureHistory:Remove()

                return
            end

            ImageHistoryPanel(pnl)
        end
    end

    local rawzone = vgui.Create("DCollapsibleCategory", appearance_container)
    rawzone:Dock(TOP)
    rawzone:SetTall(256)
    rawzone:DockMargin(0, 0, 0, 0)
    rawzone:DockPadding(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
    rawzone.BasedPerformLayout = rawzone.PerformLayout

    rawzone.PerformLayout = function(pnl)
        pnl:SizeToChildren(false, true)
        pnl:InvalidateParent(true)
        pnl:DockMargin(0, 0, appearance_container.VBar:IsVisible() and SS_COMMONMARGIN or 0, SS_COMMONMARGIN)
        pnl:BasedPerformLayout(pnl:GetWide(), pnl:GetTall())
    end

    rawzone:SetLabel("Raw Data")
    rawzone.Header:SetFont("SS_DESCINSTFONT")

    rawzone.Header.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
    end

    rawzone.Header:SetContentAlignment(8)
    rawzone.Header:SetTall(26)
    rawzone.Paint = SS_PaintFG
    rawzone:SetExpanded(false)
    rawzone:SetKeyboardInputEnabled(true)
    RAWENTRY_c = vgui.Create("DPanel", rawzone)
    RAWENTRY_c:Dock(FILL)
    RAWENTRY_c.Paint = SS_PaintBG

    RAWENTRY_c.PerformLayout = function(pnl)
        pnl:SizeToChildren(false, true)
        pnl:InvalidateParent(true)
    end

    RAWENTRY = vgui.Create("DTextEntry", RAWENTRY_c)
    RAWENTRY:SetMultiline(true)
    RAWENTRY:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
    RAWENTRY:SetTall(256)
    RAWENTRY:Dock(FILL)
    RAWENTRY:SetPaintBackground(false)
    RAWENTRY:SetTextColor(MenuTheme_TX)
    RAWENTRY:SetEditable(true)
    RAWENTRY:SetKeyboardInputEnabled(true)

    RAWENTRY.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
        pnl:SetCursorColor(MenuTheme_TX)
    end

    RAWENTRY.PerformLayout = function(pnl)
        pnl:SizeToContentsY()
        pnl:InvalidateParent(true)
    end

    RAWENTRY.OnValueChange = function(textself, new)
        textself:InvalidateLayout(true)

        if not textself.RECIEVE then
            self.item.cfg = util.JSONToTable(new) or {}
            self:UpdateCfg(true) -- TODO: sanitize input like on the server
        end
    end

    RAWENTRY:SetUpdateOnType(true)
    --RAWENTRY:SetValue("unset") --(self.item.cfg.imgur or {}).url or "")
    self:UpdateCfg()
end

local function TexDownloadHook()
    if (SS_REQUESTED_TEX and not SS_REQUESTED_TEX:IsError()) then
        local mat = SS_REQUESTED_TEX

        local matcopy = CreateMaterial(mat:GetName() .. "copy", "UnlitGeneric", {
            ["$basetexture"] = mat:GetString("$basetexture")
        })

        local RT = GetRenderTarget(mat:GetName() .. "download", mat:Width(), mat:Height())
        render.PushRenderTarget(RT)
        cam.Start2D()
        render.Clear(0, 0, 0, 0, true, true)
        render.SetMaterial(matcopy)
        render.DrawScreenQuad()
        cam.End2D()
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
        render.PopRenderTarget()
        local parts = string.Explode("/", mat:GetName() or "")
        local imagename = parts[#parts] or "temp_image"
        file.CreateDir("swampshop_temp")
        local fname = "swampshop_temp/" .. imagename .. ".png"
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
SS_REQUESTED_TEX = nil
SS_REQUESTED_TEX_CALLBACK = nil

local function DownloadTexture(mat, callback)
    SS_REQUESTED_TEX = mat
    SS_REQUESTED_TEX_CALLBACK = callback

    hook.Add("PostRender", "SS_TexDownload", function()
        TexDownloadHook()
    end)
end

concommand.Add("CleanUp", function()
    for k, v in pairs(vgui.GetWorldPanel():GetChildren()) do
        if (v:GetName() == "SwampChat") then continue end
        if (v:GetName() == "GModMouseInput") then continue end
        if (v:GetName() == "DMenuBar") then continue end
        v:Remove()
    end
end)

function ImageHistoryPanel(button)
    if IsValid(SS_CustTextureHistory) then
        SS_CustTextureHistory:Remove()

        return
    end

    local sz = 512
    local Menu = DermaMenu()
    local container = Container(nil, "Saved Textures")
    container.Paint = noop
    container:SetSize(512, 512)
    Menu:AddPanel(container)
    local textures = vgui.Create("DImgurManager", container)
    textures:SetMultiline(true)
    textures:Dock(TOP)
    textures:SetTall(256)
    textures:SetSize(512, 512)

    Menu.Paint = function(pnl, w, h)
        DisableClipping(true)
        local border = 8
        draw.BoxShadow(-2, -2, w + 4, h + 4, border, 1)
        DisableClipping(false)
        SS_PaintBG(pnl, w, h)
    end

    SS_CustTextureHistory = Menu
    textures:SetColumns(4)
    textures:Load()
    local img = SS_CustomizerPanel.TextureBar:GetText()
    textures.AddField:SetText(img)

    textures.OnChoose = function(pnl, img)
        SingleAsyncSanitizeImgurId(img, function(id)
            if not IsValid(pnl) then return end

            if (id) then
                SS_CustomizerPanel.TextureBar:SetText(id)
            end

            SS_CustomizerPanel.item.cfg.imgur = id and {
                url = id,
                nsfw = false
            } or nil

            SS_CustomizerPanel:UpdateCfg()
        end)
    end

    local x, y = button:LocalToScreen(button:GetWide() + SS_COMMONMARGIN, 0)
    Menu:Open(x, y)
    Menu.BaseLayout = Menu.PerformLayout

    Menu.PerformLayout = function(pnl, w, h)
        Menu.BaseLayout(pnl, w, h)
        local x, y = pnl:GetPos()
        x = math.Clamp(x, 0, ScrW() - w)
        y = math.Clamp(y, 0, ScrH() - h)
        Menu:SetPos(x, y)
    end
end

function ImageGetterPanel()
    local mat
    local mdl = IsValid(SS_HoverCSModel) and SS_HoverCSModel or LocalPlayer()

    if IsValid(SS_HoverCSModel) then
        mat = SS_HoverCSModel:GetMaterials()[1]
    else
        mat = LocalPlayer():GetMaterials()[(SS_CustomizerPanel.item.cfg.submaterial or 0) + 1]
    end

    local mat_inst = Material(mat)
    local dispmax = 512
    local tw, th = mat_inst:Width(), mat_inst:Height()
    local big = math.max(tw, th)
    tw = tw / big * dispmax
    th = th / big * dispmax

    if mat then
        local Frame = vgui.Create("DFrame")
        Frame:SetSize(tw + 10, th + 30 + 24)
        Frame:DockPadding(SS_COMMONMARGIN, SS_COMMONMARGIN + 24, SS_COMMONMARGIN, SS_COMMONMARGIN)
        Frame:Center()
        Frame:SetTitle(mat)
        Frame:MakePopup()
        Frame.btnMaxim:SetVisible(false)
        Frame.btnMinim:SetVisible(false)
        local DLButton = vgui.Create("DButton", Frame)
        DLButton:SetPos(128, 0)
        DLButton:Dock(BOTTOM)
        DLButton:DockMargin(0, SS_COMMONMARGIN, 0, 0)
        DLButton:SetText("Download Image")
        DLButton.Paint = SS_PaintButtonBrandHL
        DLButton:SetTextColor(MenuTheme_TX)

        DLButton.DoClick = function()
            Frame:SetTitle("Downloading...")

            DownloadTexture(Material(mat), function(fname, data)
                if (fname) then
                    Frame:SetTitle("Downloaded! Look for file: garrysmod/data/" .. fname)
                else
                    Frame:SetTitle("Couldn't Download!")
                end
            end)
        end

        Frame.BasedPaint = Frame.Paint

        Frame.Paint = function(pnl, w, h)
            DisableClipping(true)
            local border = 8
            draw.BoxShadow(-2, -2, w + 4, h + 4, border, 1)
            DisableClipping(false)
            SS_PaintBG(pnl, w, h)
            BrandBackgroundPattern(0, 0, w, 24, 0)
        end

        local img = vgui.Create("DImage", Frame)
        img:Dock(FILL)
        img:SetImage(mat)
        img:GetMaterial():SetInt("$flags", 0)
        img.BasedPaint = img.Paint

        function img:Paint(w, h)
            cam.IgnoreZ(true)
            self:BasedPaint(w, h)
            cam.IgnoreZ(false)
        end
    else
        LocalPlayerNotify("Couldn't find the material, sorry.")
    end
end

function PANEL:UpdateCfg(skiptext)
    self.item:Sanitize()

    if IsValid(RAWENTRY) and not skiptext then
        RAWENTRY.RECIEVE = true
        RAWENTRY:SetValue(util.TableToJSON(self.item.cfg, true))
        RAWENTRY.RECIEVE = nil
    end
end

vgui.Register('DPointShopCustomizer', PANEL, 'DPanel')