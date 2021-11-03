-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA


--NOMINIFY


vgui.Register('DSSCustomizerSlider',{
    Init = function(self)


        self:SetDecimals(2)
        self:DockMargin(0, 0, 0, SS_COMMONMARGIN)
        self:Dock(TOP)
        self:SetDark(false)
        self.TextArea:SetPaintBackground(false)
        self:SetTall(24)
        self.TextArea.BasedPaint = self.TextArea.Paint
    
        self.TextArea.Paint = function(pnl, w, h)
            SS_PaintBG(pnl, w, h)
            self.TextArea.BasedPaint(pnl, w, h)
        end
    
        -- p.TextArea.UpdateColours = function(pnl)
        --     pnl:SetTextColor(MenuTheme_TX)
        -- end
    
        self.TextArea:DockMargin(SS_COMMONMARGIN, 0, 0, 0)
    
        -- p.Label.UpdateColours = function(pnl)
        --     pnl:SetTextColor(MenuTheme_TX)
        -- end
    
        self.Slider.Knob:SetWide(6)
    
        self.Slider.Paint = function(pnl, w, h)
            local y = h / 2
            local barh = 2
            SS_GLOBAL_RECT(0, y - barh / 2, w, barh, MenuTheme_BG)
        end
    
        self.Slider.Knob.Paint = function(pnl, w, h)
            draw.BoxShadow(0, 0, w, h, 8, 1)
            SS_GLOBAL_RECT(0, 0, w, h, MenuTheme_Brand)
        end
    end,

    PerformLayout = function(self)
            self.Label:SetWide(self:GetText()=="" and 0 or self:GetWide() / 4 )
        end
}, "DNumSlider")



vgui.Register('DSSCustomizerSection', 
{
    Init = function(self)
        self:DockMargin(0, 0, 0, 0)
        self:DockPadding(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
        self:Dock(TOP)

        self.Paint = SS_PaintFG
    
        self.Text = vgui("DLabel", self, function(p)
            p:SetFont("SS_DESCINSTFONT")
            p:SetText("")
            p:SetTextColor(SS_SwitchableColor)
            p:SizeToContents()
            p:SetContentAlignment(5)
            p:DockMargin(0, 0, 0, 0)
            p:Dock(TOP)
        end)
    end,
    SetText = function(self,txt)
        self.Text:SetText(txt)
    end,
    PerformLayout = function(self)
        self:SizeToChildren(false, true)
    
        if IsValid(parent) and parent:GetName() == "DScrollPanel" then
            self:DockMargin(0, 0, parent.VBar:IsVisible() and SS_COMMONMARGIN or 0, SS_COMMONMARGIN)
        else
            self:DockMargin(0, 0, 0, SS_COMMONMARGIN)
        end
    end,
},"DPanel")






vgui.Register('DSSCustomizerVector', 
{
    Init = function(self)

    end,
    OnValueChanged = function(vec)
        print("DEFAULTONVALCHANGED", vec)
    end,
    MakeSlider = function(self, text, min, max, val, valuefunction)
        return vgui("DSSCustomizerSlider", self, function(p)

            --TODO: MOVE SOME OF THIS TO DSSCustomizerSlider

            

            p:SetText(text)
            p:SetMinMax(min, max)
            p:SetValue(val)

            p.OnValueChanged = valuefunction or (function() if not self.SUPPRESSVALUECHANGED then self:OnValueChanged(self:GetValue()) end end)

            
        end)
    end,
    GetValue = function(self)
        return Vector(self.XS:GetValue(), self.YS:GetValue(), self.ZS:GetValue())
    end,
    GetValueAngle = function(self)
        return Angle(self.XS:GetValue(), self.YS:GetValue(), self.ZS:GetValue())
    end,
    SetValue = function(self, vec)
        if isnumber(vec) then vec=Vector(vec,vec,vec) end
        self.XS:SetValue(vec[1])
        self.YS:SetValue(vec[2])
        
        self.ZS:SetValue(vec[3])
    end,
    SetForPosition = function(self, min, max, default)
        self:SetText("Offset")
        self.XS = self:MakeSlider("Forward/Back", min.x, max.x, default.x)
        self.YS = self:MakeSlider("Left/Right", min.y, max.y, default.y)
        self.ZS = self:MakeSlider("Up/Down", min.z, max.z, default.z)

    end,
    SetForAngle = function(self, default)
        self:SetText("Angle")
        self.XS = self:MakeSlider("Pitch", -180, 180, default.p)
        self.YS = self:MakeSlider("Yaw", -180, 180, default.y)
        self.ZS = self:MakeSlider("Roll", -180, 180, default.r)
    end,
    SetForScale = function(self, min, max, default)
        if isnumber(vec) then vec=Vector(vec,vec,vec) end

        self:SetText("Scale")
        self.XS = self:MakeSlider("Length", min.x, max.x, default.x)
        self.YS = self:MakeSlider("Width", min.y, max.y, default.y)
        self.ZS = self:MakeSlider("Height", min.z, max.z, default.z)

        self.US = self:MakeSlider("", min.x, max.x, default.x, function(slider)
            local v = slider:GetValue()
            self:SetValue(Vector(v,v,v))
        end)

        self.US:SetVisible(false)

        local scalebutton = vgui("DButton", self, function(p)

            p:SetText("Use Uniform Scaling")
            p:SetWide(160)
            p:Dock(TOP)
            p.Paint = SS_PaintButtonBrandHL
    
            p.UpdateColours = function(pnl)
                pnl:SetTextStyleColor(MenuTheme_TX)
            end
    
            p.DoClick = function(btn)
                if self.US:IsVisible() then

                    btn:SetText("Use Uniform Scaling")
                    self.XS:SetVisible(true)
                    self.YS:SetVisible(true)
                    self.ZS:SetVisible(true)
                    self.US:SetVisible(false)
                else
                    btn:SetText("Use Independent Scaling")
                    self.XS:SetVisible(false)
                    self.YS:SetVisible(false)
                    self.ZS:SetVisible(false)
                    self.US:SetVisible(true)

                    local v = self:GetValue()
                    self.US:SetValue( (v.x+v.y+v.z)/3)
                end
            end

        end)
        
        if default.x == default.y and default.y == default.z then
            scalebutton:DoClick()
        end

    end

}, 'DSSCustomizerSection')


local PANEL = {}

PANEL.NeedsKeyboard = true

function PANEL:Init()
    SS_CustomizerPanel = self
end

function PANEL:OpenItem(item)
    self:OpenOver()

    for k, v in pairs(self:GetChildren()) do
        v:Remove()
    end

    self.item = item
    item.applied_cfg = table.Copy(item.cfg)
    self.wear = LocalPlayer():IsPony() and "wear_p" or "wear_h"

    self.Paint = SS_PaintBG

    self:SetVisible(true)

    --main panel
    vgui("DPanel", self, function(p)
        p.Paint = noop
        p:Dock(FILL)
        p:DockMargin(0, SS_COMMONMARGIN, 0, SS_COMMONMARGIN)

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
                    SS_ItemServerAction(self.item.id, "configure", self.item.cfg)
                    self:Close()
                end
            end)
        end)
    end)
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
    p:SetDark(false)
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


        vgui("DSSCustomizerSection", wear_container, function(p)
            p:SetText("Attachment (" .. (pone and "pony" or "human") .. ")")

            vgui("DPanel", function(p)
                p:Dock(TOP)
                p:SetTall(24)
                p.Paint = noop
            
                vgui("DComboBox", function(p)
                    p:SetValue((self.item.cfg[self.wear] or {}).attach or (pone and (self.item.wear.pony or {}).attach) or self.item.wear.attach)
            
                    for k, v in pairs(SS_Attachments) do
                        p:AddChoice(k)
                    end
                    
                    p:Dock(FILL)
                    p.Paint = SS_PaintBG
            
                    p.UpdateColours = function(pnl)
                        pnl:SetTextStyleColor(MenuTheme_TX)
                        pnl:SetTextColor(MenuTheme_TX)
                    end
                end)

                vgui("DLabel", function(p)
                    p:Dock(LEFT)
                    p:SetText("Attach to")
            
                    p.UpdateColours = function(pnl)
                        pnl:SetTextColor(MenuTheme_TX)
                    end
            
                    p.OnSelect = function(panel, index, value)
                        self.item.cfg[self.wear] = self.item.cfg[self.wear] or {}
                        self.item.cfg[self.wear].attach = value
                        self:UpdateCfg()
                    end         
                end)

                -- p:SizeToChildren(true,true)
            end)

            -- p:SizeToChildren(true,true)
        end)

  
        local translate = (self.item.cfg[self.wear] or {}).pos or (pone and (self.item.wear.pony or {}).translate) or self.item.wear.translate
        local rotate = (self.item.cfg[self.wear] or {}).ang or (pone and (self.item.wear.pony or {}).rotate) or self.item.wear.rotate
        local scale = (self.item.cfg[self.wear] or {}).scale or (pone and (self.item.wear.pony or {}).scale) or self.item.wear.scale

        self.Position = vgui('DSSCustomizerVector', wear_container, function(p)
            p:SetForPosition(
                itmcw.pos.min,
                itmcw.pos.max,
                translate
            )
        end)

        self.Angle = vgui('DSSCustomizerVector', wear_container, function(p)
            p:SetForAngle(
                rotate
            )
        end)


        self.Scale = vgui('DSSCustomizerVector', wear_container, function(p)
            p:SetForScale(
                itmcw.scale.min* self.item:ScaleLimitOffset(), itmcw.scale.max * self.item:ScaleLimitOffset(),
                scale
            )
        end)

        local function transformslidersupdate()
            self.item.cfg[self.wear] = self.item.cfg[self.wear] or {}
            self.item.cfg[self.wear].pos = self.Position:GetValue()
            self.item.cfg[self.wear].ang = self.Angle:GetValueAngle()
            self.item.cfg[self.wear].scale = self.Scale:GetValue()
            self:UpdateCfg()
        end

        self.Position.OnValueChanged = transformslidersupdate
        self.Angle.OnValueChanged = transformslidersupdate
        self.Scale.OnValueChanged = transformslidersupdate

    elseif (self.item.configurable or {}).bone then

        vgui("DSSCustomizerSection", wear_container, function(p)

            p:SetText( "Mod (" .. (LocalPlayer():IsPony() and "pony" or "human") .. ")" )

            local function cleanbonename(bn)
                return bn:Replace("ValveBiped.Bip01_", ""):Replace("Lrig", ""):Replace("_LEG_", "")
            end
    
            vgui("DComboBox", function(p)
                p:SetValue(cleanbonename(self.item.cfg["bone" .. suffix] or (pone and "Scull" or "Head1")))
                p:SetTall(24)
                p:Dock(TOP)
                p.Paint = SS_PaintBG
        
                p.UpdateColours = function(pnl)
                    pnl:SetTextStyleColor(MenuTheme_TX)
                    pnl:SetTextColor(MenuTheme_TX)
                end
        
                for x = 0, (LocalPlayer():GetBoneCount() - 1) do
                    local bn = LocalPlayer():GetBoneName(x)
                    local cleanname = cleanbonename(bn)
        
                    if cleanname ~= "__INVALIDBONE__" then
                        p:AddChoice(cleanname, bn)
                    end
                end
        
                p.OnSelect = function(panel, index, word, value)
                    self.item.cfg["bone" .. suffix] = value
                    self:UpdateCfg()
                end
            end)
           
        end)

       
        --bunch of copied shit
        local function transformslidersupdate()
            if self.item.configurable.scale then
                self.item.cfg["scale" .. suffix] = self.Scale:GetValue()
            end

            if self.item.configurable.pos then
                self.item.cfg["pos" .. suffix] = self.Position:GetValue()
            end

            self:UpdateCfg()
        end

        local itmcp = self.item.configurable.pos

        if itmcp then
            self.Position = vgui('DSSCustomizerVector', wear_container, function(p)
                p:SetForPosition(
                    itmcp.min,
                    itmcp.max,
                    translate
                )
            end)
        end

        local itmcs = self.item.configurable.scale

        if itmcs then
            self.Scale = vgui('DSSCustomizerVector', wear_container, function(p)
                p:SetForScale(
                    itmcw.scale.min* self.item:ScaleLimitOffset(), itmcw.scale.max * self.item:ScaleLimitOffset(),
                    scale
                )
            end)
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

        vgui("DSSCustomizerSection", wear_container, function(p)
            p:SetText("Skin ID")

            vgui("DComboBox", function(p)
                for x = 0, math.min(31, (#(LocalPlayer():GetMaterials()) - 1)) do
                    local matname = LocalPlayer():GetMaterials()[x + 1] or ""
                    local exp = string.Explode("/", matname)
                    local nicename = exp[#exp]
                    local sel = tonumber(self.item.cfg.submaterial or 0) == x
                    p:AddChoice(tostring(x) .. " (" .. nicename .. ")", tostring(x), sel)
                end
    
                p.OnSelect = function(panel, index, word, value)
                    self.item.cfg.submaterial = tonumber(value)
                    self:UpdateCfg()
                end
    
                p:SetWide(200)
                p:Dock(TOP)
                p.Paint = SS_PaintBG
    
                p.UpdateColours = function(pnl)
                    pnl:SetTextStyleColor(MenuTheme_TX)
                    pnl:SetTextColor(MenuTheme_TX)
                end
            end)
        end)
    end


    local appearance_container = vgui.Create("DScrollPanel", self.controlzone)
    appearance_container:Dock(FILL)
    appearance_container:SetPadding(0)
    appearance_container.VBar:DockMargin(SS_COMMONMARGIN, 0, 0, 0)
    SS_SetupVBar(appearance_container.VBar)
    appearance_container.VBar:SetWide(SS_SCROLL_WIDTH)


    local limit = self.item:CanCfgColor()

    if limit then
        vgui("DSSCustomizerSection", appearance_container, function(p)

            p:SetText("Appearance")

            local cv = Vector()
            cv:Set(self.item.cfg.color or self.item.color or Vector(1, 1, 1))
            local cvm = math.max(1, cv.x, cv.y, cv.z)
            
            
            
            local c1 = vgui("DColorMixer", function(p)
                p:SetPalette(true)
                p:SetAlphaBar(false)
                p:SetWangs(true)
                p:SetVector(cv / cvm)
                p:SetTall(250)
                p:DockMargin(0, 0, 0, 0)
                p:Dock(TOP)
            end)

            PSBS = SliderMaker(colorzone, "Boost")
            PSBS:SetMinMax(1, limit.max)
            PSBS:SetValue(cvm)
            PSBS:DockMargin(0, SS_COMMONMARGIN, 0, SS_COMMONMARGIN)
    
            local function colorchanged()
                self.item.cfg.color = c1:GetVector() * PSBS:GetValue()
                self:UpdateCfg()
            end
    
            c1.ValueChanged = colorchanged
            PSBS.OnValueChanged = colorchanged


        end)

    end

    if self.item:CanCfgImgur() then
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
                textures.AddField:SetText(id)
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
        mat = SS_PreviewPane.Entity:GetMaterials()[(SS_CustomizerPanel.item.cfg.submaterial or 0) + 1]
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

vgui.Register('DSSCustomizeMode', PANEL, 'DSSMode')
