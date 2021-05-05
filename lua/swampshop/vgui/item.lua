-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
--Note: CAN BE PRODUCT OR ITEM
function SS_PreviewShopModel(self)
    local min, max = self.Entity:GetRenderBounds()
    local center, radius = (min + max) / 2, min:Distance(max) / 2
    self:SetCamPos(self.Entity:LocalToWorld(center) + ((radius + 1) * Vector(1, 1, 1)))
    self:SetLookAt(self.Entity:LocalToWorld(center))
end

function SS_MouseInsidePanel(panel)
    local x, y = panel:LocalCursorPos()

    return x > 0 and y > 0 and x < panel:GetWide() and y < panel:GetTall()
end

local PANEL = {}

function PANEL:Init()
end

function PANEL:OnRemove()
    if self:IsSelected() then
        self:Deselect()
    end
end

function PANEL:OnMousePressed(b)
    if b ~= MOUSE_LEFT then return end

    if self.product then
        local cantbuy = self.product:CannotBuy(LocalPlayer())

        if cantbuy then
            surface.PlaySound("common/wpn_denyselect.wav")
            LocalPlayerNotify(cantbuy)
        else
            if not self.prebuyclick then
                self.prebuyclick = true

                return
            end

            self.prebuyclick = nil
            surface.PlaySound("UI/buttonclick.wav")
            SS_BuyProduct(self.product.class)
        end
    else
        if self:IsSelected() then
            local status = (not self.item.eq) and self.item:CannotEquip() or nil

            if status then
                surface.PlaySound("common/wpn_denyselect.wav")
                LocalPlayerNotify(status)
            else
                surface.PlaySound("weapons/smg1/switch_single.wav")
                SS_EquipItem(self.item.id, not self.item.eq)
            end
        else
            self:Select()
        end
    end
end

function PANEL:OnCursorEntered()
    self.hovered = true

    if self.product then
        self:Select()
    end
end

function PANEL:OnCursorExited()
    self.hovered = false

    if self.product then
        self:Deselect()
    end
end

function PANEL:Select()
    if IsValid(SS_SelectedPanel) then
        SS_SelectedPanel:Deselect()
    end

    SS_SelectedPanel = self

    -- SS_HoverData = self.data
    -- SS_HoverCfg = (self.item or {}).cfg
    -- SS_HoverItemID = (self.item or {}).id
    if self.product then
        if self.product.sample_item then
            SS_HoverItem = self.product.sample_item
            SS_HoverProduct = nil
        else
            SS_HoverItem = nil
            SS_HoverProduct = self.product
        end
    else
        SS_HoverItem = self.item
    end

    SS_HoverIOP = SS_HoverItem or SS_HoverProduct
    local p = vgui.Create("DLabel", SS_DescriptionPanel)
    p:SetFont("SS_DESCTITLEFONT")
    p:SetText(self.iop.name)
    p:SetColor(SS_SwitchableColor)
    p:SetContentAlignment(5)
    p:SizeToContents()
    p:DockMargin(0, -4, 0, 0)
    p:Dock(TOP)

    if self.iop.description then
        p = vgui.Create("DLabel", SS_DescriptionPanel)
        p:SetFont("SS_DESCFONT")
        p:SetText(self.iop.description)
        p:SetColor(SS_SwitchableColor)

        --HACK
        if string.len(self.iop.description) > 45 then
            p:SetWrap(true)
            p:SetAutoStretchVertical(true)
        else
            p:SetContentAlignment(5)
            p:SizeToContents()
        end

        p:DockMargin(14, 6, 14, 10)
        p:Dock(TOP)
    end

    if self.product then
        local function addline(txt)
            p = vgui.Create("DLabel", SS_DescriptionPanel)
            p:SetFont("SS_DESCINSTFONT")
            p:SetText(txt)
            p:SetContentAlignment(5)
            p:SetColor(SS_SwitchableColor)
            --p:SetWrap(true)
            --bp:SetAutoStretchVertical(true)
            p:SizeToContents()
            p:DockMargin(14, 6, 14, 2)
            p:Dock(TOP)
        end

        addline("Price: " .. (self.product.price == 0 and "Free" or (string.Comma(self.product.price) .. " points")))
        local cannot = self.product:CannotBuy(LocalPlayer())

        if cannot then
            addline(cannot)
        else
            addline("Double-click to " .. (self.product.price == 0 and "get" or "buy"))
        end

        if cannot ~= SS_CANNOTBUY_OWNED then
            if self.product.sample_item then
                local count = LocalPlayer():SS_CountItem(self.product.sample_item.class)

                if count > 0 then
                    addline("You own " .. tostring(count) .. " of these")
                end
            end
        end

        local typetext = nil

        if self.product.keepnotice then
            p = vgui.Create("DLabel", SS_DescriptionPanel)
            p:SetFont("SS_DESCFONT")
            p:SetText(self.product.keepnotice)
            p:SetContentAlignment(5)
            p:SetColor(SS_SwitchableColor)
            p:SizeToContents()
            p:DockMargin(14, 2, 14, 8)
            p:Dock(BOTTOM)
        end
    else
        assert(self.item)

        if self.item.configurable then
            p = vgui.Create('DButton', SS_DescriptionPanel)
            p:SetText("Customize")
            p:SetTextColor(SS_SwitchableColor)
            p:DockMargin(16, 12, 16, 4)
            p:Dock(TOP)

            p.DoClick = function(butn)
                if SS_CustomizerPanel:IsVisible() then
                    SS_CustomizerPanel:Close()
                else
                    SS_CustomizerPanel:Open(self.item)
                end
            end

            p.Paint = function(panel, w, h)
                if panel.Depressed then
                    panel:SetTextColor(SS_ColorWhite)
                    draw.RoundedBox(4, 0, 0, w, h, BrandColorAlternate)
                else
                    panel:SetTextColor(SS_SwitchableColor)
                    draw.RoundedBox(4, 0, 0, w, h, SS_TileBGColor)
                end
            end
        end

        p = vgui.Create('DButton', SS_DescriptionPanel)
        p:SetText("Sell for " .. tostring(self.item:SellValue()) .. " points")
        p:SetTextColor(SS_SwitchableColor)
        p:DockMargin(16, 12, 16, 12)
        p:Dock(TOP)

        p.DoClick = function(butn)
            if butn:GetText() == "CONFIRM?" then
                SS_SellItem(self.item.id)
            else
                butn:SetText("CONFIRM?")
            end
        end

        p.Paint = function(panel, w, h)
            if panel.Depressed then
                panel:SetTextColor(SS_ColorWhite)
                draw.RoundedBox(4, 0, 0, w, h, BrandColorAlternate)
            else
                panel:SetTextColor(SS_SwitchableColor)
                draw.RoundedBox(4, 0, 0, w, h, SS_TileBGColor)
            end
        end
    end
end

function PANEL:Deselect()
    if not self:IsSelected() then return end
    SS_SelectedPanel = nil
    SS_HoverProduct = nil
    SS_HoverItem = nil
    SS_HoverIOP = nil

    if IsValid(SS_HoverCSModel) then
        SS_HoverCSModel:Remove()
    end

    if IsValid(SS_DescriptionPanel) then
        for k, v in pairs(SS_DescriptionPanel:GetChildren()) do
            v:Remove()
        end
    end
end

function PANEL:IsSelected()
    return SS_SelectedPanel == self
end

function PANEL:SetProduct(product)
    self.product = product
    self.item = nil
    self.iop = product
    self:Setup()
end

function PANEL:SetItem(item)
    self.item = item
    self.product = nil
    self.iop = item
    self:Setup()
end

function PANEL:Setup()
    local DModelPanel = vgui.Create('DModelPanel', self)
    --DModelPanel:SetModel(self.data.model)
    DModelPanel.model2set = self.iop.model
    DModelPanel:Dock(FILL)

    function DModelPanel:LayoutEntity(ent)
        if self:GetParent().hovered then
            ent:SetAngles(Angle(0, ent:GetAngles().y + (RealFrameTime() * 120), 0))
        end

        SS_PreviewShopModel(self, self:GetParent().iop)
    end

    function DModelPanel:OnMousePressed(b)
        self:GetParent():OnMousePressed(b)
    end

    function DModelPanel:OnCursorEntered()
        self:GetParent():OnCursorEntered()
    end

    function DModelPanel:OnCursorExited()
        self:GetParent():OnCursorExited()
    end

    DModelPanel.Paint = function(dmp, w, h)
        if dmp.model2set then
            -- might be a workshop model, will be an error till user clicks it and it appears in the preview
            -- todo: use placeholder
            dmp:SetModel(dmp.model2set)
            dmp.model2set = nil
        end

        if is_model_undownloaded(dmp:GetModel()) then
            draw.SimpleText("Mouse over", "DermaDefaultBold", w/2,h/2-8, Color( 0,0,0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.SimpleText("to download", "DermaDefaultBold", w/2,h/2+8, Color( 0,0,0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            return
        end

        if (not IsValid(dmp.Entity)) then return end
        dmp.Entity.GetPlayerColor = function() return LocalPlayer():GetPlayerColor() end

        if self.item or self.product.sample_item then
            SS_PreRender(self.item or self.product.sample_item)
        else
            --todo: remove this?
            local mat, col = self.product.material, self.product.color

            if mat then
                render.MaterialOverride(SS_GetMaterial(mat))
            end
            -- if col then
            --     render.SetColorModulation(col.x, col.y, col.z)
            -- end
        end

        local x, y = dmp:LocalToScreen(0, 0)
        dmp:LayoutEntity(dmp.Entity)
        local ang = dmp.aLookAngle or (dmp.vLookatPos - dmp.vCamPos):Angle()
        cam.Start3D(dmp.vCamPos, ang, dmp.fFOV, x, y, w, h, 5, dmp.FarZ)
        render.SuppressEngineLighting(true)
        render.SetLightingOrigin(dmp.Entity:GetPos())
        render.ResetModelLighting(dmp.colAmbientLight.r / 255, dmp.colAmbientLight.g / 255, dmp.colAmbientLight.b / 255)
        render.SetBlend((dmp:GetAlpha() / 255) * (dmp.colColor.a / 255))

        for i = 0, 6 do
            local col = dmp.DirectionalLight[i]

            if col then
                render.SetModelLighting(i, col.r / 255, col.g / 255, col.b / 255)
            end
        end

        dmp:DrawModel()
        render.SuppressEngineLighting(false)
        cam.End3D()
        dmp.LastPaint = RealTime()
        SS_PostRender()
    end
end

local ownedcheckmark = Material("icon16/accept.png")
local visiblemark = Material("icon16/eye.png")

function PANEL:Think()
    if not self.product and self:IsSelected() then
        local c = input.IsMouseDown(MOUSE_LEFT)

        if c and not self.lastc then
            if not SS_MouseInsidePanel(self) and not SS_MouseInsidePanel(SS_PreviewPane) then
                self:Deselect()
            end
        end

        self.lastc = c
    end

    self.fademodel = false
    self.barcolor = nil
    self.barheight = nil
    self.text = nil
    self.textcolor = nil
    self.textfont = nil
    self.icon = nil
    self.icontext = nil
    self.BGColor = SS_TileBGColor

    if self.product then
        local cannot = self.product:CannotBuy(LocalPlayer())

        if cannot then
            self.fademodel = true

            if cannot == SS_CANNOTBUY_AFFORD then
                self.barcolor = Color(112, 0, 0, 160)
            else
                self.barcolor = Color(72, 72, 72, 160)
            end
        else
            self.barcolor = Color(0, 112, 0, 160)
        end

        local c = self.product.sample_item and LocalPlayer():SS_CountItem(self.product.sample_item.class) or 0

        if c > 0 then
            self.icon = ownedcheckmark

            if c > 1 then
                self.icontext = tostring(c) .. "x"
            end
        end

        if self.hovered then
            self.barheight = 30
            self.textfont = "SS_Price"

            if self.prebuyclick then
                self.text = self.product.price == 0 and ">  GET  <" or ">  BUY  <"
            else
                self.text = self.product.price == 0 and "FREE" or "-" .. tostring(self.product.price)
            end
        else
            self.barheight = 20
            self.textfont = "SS_ProductName"
            self.text = self.product.name
        end

        self.textcolor = SS_ColorWhite
    else
        if self.item.eq then
            self.icon = visiblemark
        else
            if not self.item.never_equip then
                self.fademodel = true
            end
        end

        self.barheight = 20
        self.textfont = "SS_ProductName"
        self.text = self.item.name
        local leqc = 0
        local totalc = 0

        for k, otheritem in ipairs(LocalPlayer().SS_Items or {}) do
            if self.item.class == otheritem.class then
                totalc = totalc + 1

                if otheritem.id <= self.item.id then
                    leqc = leqc + 1
                end
            end
        end

        if totalc > 1 then
            self.text = self.text .. " (" .. tostring(leqc) .. ")"
        end

        self.textcolor = SS_SwitchableColor

        if self:IsSelected() then
            self.BGColor = SS_DarkMode and Color(53, 53, 53, 255) or Color(192, 192, 255, 255)

            if self.hovered then
                self.barheight = 30
                self.textfont = "SS_Price"
                self.text = self.item.eq and "HOLSTER" or "EQUIP"
            end
        elseif self.hovered then
            self.BGColor = SS_DarkMode and Color(43, 43, 43, 255) or Color(216, 216, 248, 255)
        end
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(self.BGColor)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:PaintOver(w, h)
    if self.fademodel then
        local c = self.BGColor
        surface.SetDrawColor(Color(c.r, c.g, c.b, 144))
        surface.DrawRect(0, 0, w, h)
    end

    if self.icon then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(self.icon)
        surface.DrawTexturedRect(w - 20, 4, 16, 16)

        if self.icontext then
            draw.SimpleText(self.icontext, "SS_ProductName", self:GetWide() - 22, 11, SS_SwitchableColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end

    if self.barcolor then
        surface.SetDrawColor(self.barcolor)
        surface.DrawRect(0, self:GetTall() - self.barheight, self:GetWide(), self.barheight)
    end

    draw.SimpleText(self.text, self.textfont, self:GetWide() / 2, self:GetTall() - (self.barheight / 2), self.textcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register('DPointShopItem', PANEL, 'DPanel')