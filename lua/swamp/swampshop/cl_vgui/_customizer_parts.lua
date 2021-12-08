-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- name is because of alphabetical include sorting, baseclass has to come first
--NOMINIFY
vgui.Register('DSSCustomizerSection', {
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
            p:DockMargin(0, 0, 0, SS_COMMONMARGIN)
            p:Dock(TOP)
        end)
    end,
    SetText = function(self, txt)
        self.Text:SetText(txt)
    end,
    PerformLayout = function(self)
        self:SizeToChildren(false, true)

        local p = self:GetParent()
        local p2 = IsValid(p) and p:GetParent()

        self:DockMargin(0, 0, ((IsValid(p) and IsValid(p.VBar) and p.VBar:IsVisible()) or (IsValid(p2) and IsValid(p2.VBar) and p2.VBar:IsVisible())) and SS_COMMONMARGIN or 0, SS_COMMONMARGIN)

    end,
}, "DPanel")

-- goes inside a section
vgui.Register('DSSCustomizerCheckBox', {
    Init = function(self)
        self:Dock(TOP)
        self:SetTall(16)
        self:DockMargin(0, SS_COMMONMARGIN, 0, 0)
        self.Paint = noop

        self.CheckBox = vgui("DCheckBox", self, function(p)
            p:Dock(LEFT)
            p:DockMargin(8, 0, 8, 0)
            p:SetWide(16)

            p.OnChange = function(boxself, val)
                self:OnValueChanged(val)
            end
        end)

        self.Label = vgui("DLabel", self, function(p)
            p:Dock(FILL)
        end)
    end,
    OnValueChanged = function(self, b) end,
    SetText = function(self, txt)
        self.Label:SetText(txt)
    end,
    GetValue = function(self) return self.CheckBox:GetChecked() end,
    SetValue = function(self, val)
        self.CheckBox:SetValue(val)
    end
}, "DPanel")

-- local function CheckboxMaker(parent, text)
--     local p2 = vgui.Create("Panel", parent)
--     p2:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
--     p2:Dock(TOP) --retarded wrapper
--     local p3 = vgui.Create("DCheckBox", p2)
--     --p:SetText(text)
--     p3:SetDark(true)
--     p3:SetPos(0, 2)
--     --p:SetTall(24)
--     local p = vgui.Create("DLabel", p2 or parent)
--     p:SetFont("SS_DESCFONT")
--     p:SetText(text)
--     p:SetTextColor(SS_SwitchableColor)
--     p:SetPos(24, 0)
--     p:SizeToContents()
--     return p3
-- end
vgui.Register('DSSCustomizerComboBox', {
    Init = function(self)
        self:SetWide(200)
        self:Dock(TOP)
        self.Paint = SS_PaintBG

        self.UpdateColours = function(pnl)
            pnl:SetTextStyleColor(MenuTheme_TX)
            pnl:SetTextColor(MenuTheme_TX)
        end
    end
}, "DComboBox")

vgui.Register('DSSCustomizerSlider', {
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

        self.TextArea.UpdateColours = function(pnl)
            pnl:SetTextColor(MenuTheme_TX)
            pnl:SetCursorColor(MenuTheme_TX)
        end

        self.TextArea:DockMargin(SS_COMMONMARGIN, 0, 0, 0)

        self.Label.UpdateColours = function(pnl)
            pnl:SetTextColor(MenuTheme_TX)
        end

        -- self.Label:SetContentAlignment(6)
        self.Label:DockMargin(0, 0, SS_COMMONMARGIN, 0)
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
        self.Label:SetWide(self:GetText() == "" and 8 or 80) -- self:GetWide() / 4 )
    end
}, "DNumSlider")

vgui.Register('DSSCustomizerColor', {
    Init = function(self)
        self:SetText("Appearance")

        self.BaseColor = vgui("DColorMixer", self, function(p)
            p:SetPalette(true)
            p:SetAlphaBar(false)
            p:SetWangs(true)
            p:SetTall(250)
            p:DockMargin(0, 0, 0, 0)
            p:Dock(TOP)
        end)

        self.Boost = vgui("DSSCustomizerSlider", self, function(p)
            p:SetText("Boost")
            p:SetMinMax(1, 5)
            p:DockMargin(0, SS_COMMONMARGIN, 0, SS_COMMONMARGIN)
            p:Dock(TOP)
        end)

        self.BaseColor.ValueChanged = (function()
            if not self.SUPPRESSVALUECHANGED then
                self:OnValueChanged(self:GetValue())
            end
        end)

        self.Boost.OnValueChanged = self.BaseColor.ValueChanged
    end,
    OnValueChanged = function(self, vec) end,
    GetValue = function(self) return self.BaseColor:GetVector() * self.Boost:GetValue() end,
    SetValue = function(self, cv)
        local cvm = math.max(1, cv.x, cv.y, cv.z)
        self.SUPPRESSVALUECHANGED = true
        self.BaseColor:SetVector(cv / cvm)
        self.SUPPRESSVALUECHANGED = nil
        self.Boost:SetValue(cvm)
    end
}, 'DSSCustomizerSection')

vgui.Register('DSSCustomizerImgur', {
    Init = function(self)
        self:SetText("Custom Material")

        vgui("DLabel", self, function(p)
            p:Dock(TOP)
            p:DockMargin(0, 0, 0, SS_COMMONMARGIN)
            p:SetText("Upload an image to imgur.com and paste the link below. No GIFs!")
            -- p:SetWrap(true)
            p:SetContentAlignment(5)
            p:SizeToContents()
        end)

        -- p:SetAutoStretchVertical(true)
        -- texturebarhelp.UpdateColours = function(pnl)
        --     pnl:SetTextColor(MenuTheme_TX)
        -- end
        vgui("DPanel", self, function(p)
            p:Dock(TOP)
            p.Paint = noop

            vgui("DButton", function(p)
                p:SetText("Show Reference Material")
                p:Dock(RIGHT)
                p:SetWide(160)
                p:SetTextStyleColor(MenuTheme_TX)
                p:DockMargin(SS_COMMONMARGIN, 0, 0, 0)
                p.Paint = SS_PaintButtonBrandHL

                p.UpdateColours = function(btn)
                    btn:SetTextStyleColor(MenuTheme_TX)
                end

                p.DoClick = function()
                    ImageGetterPanel()
                end
            end)

            vgui("DPanel", function(p)
                p:Dock(TOP)
                p.Paint = SS_PaintBG

                self.TextEntry = vgui("DTextEntry", function(p)
                    p:Dock(FILL)
                    p:SetPaintBackground(false)
                    p:SetUpdateOnType(true)
                    p:SetTextColor(MenuTheme_TX)
                    p:SetCursorColor(MenuTheme_TX)
                    p:SetText("")
                    p:SetPlaceholderText("Example: https://imgur.com/a/3AOvcC1")

                    -- p.UpdateColours = function(pnl)
                    --     pnl:SetTextColor(MenuTheme_TX)
                    --     pnl:SetCursorColor(MenuTheme_TX)
                    -- end
                    p.OnValueChange = function()
                        self:OnValueChanged(self:GetValue())
                    end
                end)
            end)
        end)
    end,
    -- vgui("DImageButton", function(p) --     p:SetSize(16, 16) --     p:SetImage("icon16/disk.png") --     p:SetToolTip("Manage Saved Textures") --     p:DockMargin(4, 4, 4, 4) --     p:Dock(RIGHT) --     p.DoClick = function(pnl) --         if (IsValid(SS_CustTextureHistory)) then --             SS_CustTextureHistory:Remove() --             return --         end --         ImageHistoryPanel(pnl) --     end  -- end)
    OnValueChanged = function(self, val) end,
    GetValue = function(self)
        local url = self.TextEntry:GetValue()

        return url ~= "" and {
            url = url
        } or nil
    end,
    SetValue = function(self, val)
        self.TextEntry:SetValue(istable(val) and val.url or "")
    end
}, 'DSSCustomizerSection')

vgui.Register('DSSCustomizerVectorSection', {
    Init = function(self) end,
    OnValueChanged = function(self, vec) end,
    MakeSlider = function(self, text, min, max, val, valuefunction)
        return vgui("DSSCustomizerSlider", self, function(p)
            --TODO: MOVE SOME OF THIS TO DSSCustomizerSlider
            p:SetText(text)
            p:SetMinMax(min, max)
            p:SetValue(val)

            p.OnValueChanged = valuefunction or (function()
                if not self.SUPPRESSVALUECHANGED then
                    self:OnValueChanged(self:GetValue())
                end
            end)
        end)
    end,
    GetValue = function(self) return Vector(self.XS:GetValue(), self.YS:GetValue(), self.ZS:GetValue()) end,
    GetValueAngle = function(self) return Angle(self.XS:GetValue(), self.YS:GetValue(), self.ZS:GetValue()) end,
    SetValue = function(self, vec)
        if isnumber(vec) then
            vec = Vector(vec, vec, vec)
        end

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
        if isnumber(min) then
            min = Vector(min, min, min)
        end

        if isnumber(max) then
            max = Vector(max, max, max)
        end

        if isnumber(default) then
            default = Vector(default, default, default)
        end

        self:SetText("Scale")
        self.XS = self:MakeSlider("Length", min.x, max.x, default.x)
        self.YS = self:MakeSlider("Width", min.y, max.y, default.y)
        self.ZS = self:MakeSlider("Height", min.z, max.z, default.z)

        self.US = self:MakeSlider("", min.x, max.x, default.x, function(slider)
            local v = slider:GetValue()
            self:SetValue(Vector(v, v, v))
        end)

        self.US:SetVisible(false)

        local scalebutton = vgui("DButton", self, function(p)
            p:SetText("Use Uniform Scaling")
            p:SetWide(160)
            p:Dock(TOP)
            p.Paint = SS_PaintButtonBrandHL

            p.UpdateColours = function(btn)
                btn:SetTextStyleColor(MenuTheme_TX)
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
                    self.US:SetValue((v.x + v.y + v.z) / 3)
                end
            end
        end)

        if default.x == default.y and default.y == default.z then
            scalebutton:DoClick()
        end
    end
}, 'DSSCustomizerSection')

-- TODO: weird ass issue with the dnumberscratch handles not being in the right place...
vgui.Register('DSSCustomizerBone', {
    Init = function(self)
        self:SetText("Mod (" .. (Me:IsPony() and "pony" or "human") .. ")")

        self.ComboBox = vgui("DComboBox", self, function(p)
            p:SetTall(24)
            p:Dock(TOP)
            p.Paint = SS_PaintBG

            p.UpdateColours = function(pnl)
                pnl:SetTextStyleColor(MenuTheme_TX)
                pnl:SetTextColor(MenuTheme_TX)
            end

            for x = 0, (Me:GetBoneCount() - 1) do
                local bn = Me:GetBoneName(x)
                local cleanname = SS_CleanBoneName(bn)

                if cleanname ~= "__INVALIDBONE__" then
                    p:AddChoice(cleanname, bn)
                end
            end

            p.OnSelect = function(panel, index, word, value)
                self:OnValueChanged(value)
            end
        end)
    end,
    OnValueChanged = function(self, val) end,
    GetValue = function(self) return self.ComboBox:GetValue() end,
    SetValue = function(self, val)
        -- self.TextEntry:SetValue(istable(val) and val.url or "")
        self.ComboBox:SetValue(SS_CleanBoneName(val))
    end
}, 'DSSCustomizerSection')

function SS_CleanBoneName(bn)
    if bn == "__INVALIDBONE__" then return end

    return bn:Replace("ValveBiped.Bip01_", ""):Replace("Lrig", ""):Replace("_LEG_", "")
end
