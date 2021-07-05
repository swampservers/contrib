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
            if self.item.primaryaction then
                surface.PlaySound("UI/buttonclick.wav")
                self.item.primaryaction.OnClient(self.item)
            else
                print("FIX " .. self.item.class)
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

    -- local p = vgui.Create("DLabel", SS_DescriptionPanel)
    -- p:SetFont("SS_DESCTITLEFONT")
    -- p:SetText(self.iop:GetName())
    -- p:SetColor(MenuTheme_TX)
    -- p:SetContentAlignment(8)
    -- p.UpdateColours = function(pnl)
    --     pnl:SetTextColor(MenuTheme_TX)
    -- end
    -- p:SetAutoStretchVertical(true)
    -- p:Think()
    -- p:DockMargin(0, 4, 0, 4)
    -- p:Dock(TOP)
    -- if self.iop.description then
    --     p = vgui.Create("DLabel", SS_DescriptionPanel)
    --     p:SetFont("SS_DESCFONT")
    --     p:SetText(self.iop.description)
    --     local long = string.len(self.iop.description) > 50
    --     p:SetColor(MenuTheme_TX)
    --     p:SetContentAlignment(long and 7 or 8)
    --     p:SetWrap(long)
    --     p:SetAutoStretchVertical(long and true or false)
    --     p.UpdateColours = function(pnl)
    --         pnl:SetTextColor(MenuTheme_TX)
    --     end
    --     p:SizeToContentsY()
    --     p:Think()
    --     p:DockMargin(4, 4, 4, 4)
    --     p:Dock(TOP)
    -- end
    if self.product then
        local ln = 4

        local function addline(txt)
            p = vgui.Create("DLabel", SS_DescriptionPanel)
            p:SetFont("SS_DESCFONT")
            p:SetText(txt)

            p.UpdateColours = function(pnl)
                pnl:SetTextColor(MenuTheme_TX)
            end

            p:SetContentAlignment(8)
            p:SetColor(SS_SwitchableColor)
            p:DockMargin(14, 6, 14, 6)
            p:Dock(TOP)
        end

        local cannot = self.product:CannotBuy(LocalPlayer())

        if cannot then
            addline(cannot)
        else
            addline("Double-click to " .. (self.product.price == 0 and "get for free" or "buy for " .. self.product.price .. " points"))
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
            local long = string.len(self.product.keepnotice) > 25
            p:SetContentAlignment(long and 7 or 8)
            p:SetWrap(long)

            p.UpdateColours = function(pnl)
                pnl:SetTextColor(MenuTheme_TX)
            end

            p:SetAutoStretchVertical(long and true or false)
            p:SetColor(SS_SwitchableColor)
            p:SizeToContentsY()
            p:DockMargin(14, 6, 14, 6)
            p:Dock(TOP)
        end
    else
        assert(self.item)

        vgui("DPanel", SS_DescriptionPanel, function(p)
            p:Dock(TOP)
            p.Paint = noop
            local orderedactions = {}

            for id, act in pairs(self.item.actions) do
                if not act.primary then
                    table.insert(orderedactions, act)
                end
            end

            table.sort(orderedactions, function(a, b) return (a.sort or 0) > (b.sort or 0) end)

            -- TODO sort by act.sort
            for i, act in ipairs(orderedactions) do
                if act.primary then continue end

                vgui("DButton", function(p)
                    local pat, pi = act.Text, self.item

                    -- sell button changes to confirm so do this
                    p.Think = function(self)
                        self:SetText(pat(pi))
                    end

                    p:Think()

                    p.UpdateColours = function(pnl)
                        pnl:SetTextStyleColor(MenuTheme_TX)
                    end

                    p:Dock(TOP)
                    p:SetTall(24)
                    p:DockMargin(0, 0, 0, SS_COMMONMARGIN)

                    p.DoClick = function(butn)
                        surface.PlaySound("UI/buttonclick.wav")
                        act.OnClient(self.item)
                    end

                    -- todo add Cannot
                    --p:InvalidateLayout(true)
                    p.Paint = SS_PaintButtonBrandHL
                end)
            end

            p:InvalidateLayout(true)
            p:SizeToChildren(false, true)
        end)
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
        SS_HoverCSModel = nil
    end

    if IsValid(SS_DescriptionPanel) then
        for k, v in pairs(SS_DescriptionPanel:GetChildren()) do
            v:Remove()
        end

        SS_DescriptionPanel:SetTall(0)
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
    DModelPanel.model2set = self.iop:GetModel()
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
            draw.SimpleText("Mouse over", "DermaDefaultBold", w / 2, h / 2 - 8, MenuTheme_TX, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("to download", "DermaDefaultBold", w / 2, h / 2 + 8, MenuTheme_TX, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

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
            if not SS_MouseInsidePanel(self) and not SS_MouseInsidePanel(SS_PreviewPane) and not SS_CustomizerPanel:IsVisible() then
                self:Deselect()
            end
        end

        self.lastc = c
    end
end

--NOMINIFY
function PANEL:Paint(w, h)
    SS_PaintFG(self, w, h)

    if (self:IsSelected()) then
        SS_GLOBAL_RECT(0, 0, w, h, ColorAlpha(MenuTheme_Brand, 100))
    end
end

function PANEL:PaintOver(w, h)
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
        self.barheight = self.barheight or 0
        local cannot = ProtectedCall(self.product:CannotBuy(LocalPlayer()))

        if cannot then
            self.fademodel = true

            if cannot == SS_CANNOTBUY_AFFORD then
                self.barcolor = Color(112, 0, 0, 160)
            else
                self.barcolor = Color(72, 72, 72, 160)
            end
        else
            self.barcolor = Color(0, 112, 0, 200)
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
            self.text = self.prebuyclick and (self.product.price == 0 and ">  GET  <" or ">  BUY  <") or (self.product.price == 0 and "FREE" or "-" .. tostring(self.product.price))
        else
            self.barheight = 20
            self.textfont = "SS_ProductName"
            self.text = self.product:GetName()
        end

        self.textcolor = MenuTheme_TXAlt
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
        self.text = self.item:GetName()

        if (self.item.auction_price or 0) == 0 then
            local leqc = 0
            local totalc = 0

            for k, otheritem in ipairs(LocalPlayer().SS_Items or {}) do
                if self.item:GetName() == otheritem:GetName() then
                    totalc = totalc + 1

                    if otheritem.id <= self.item.id then
                        leqc = leqc + 1
                    end
                end
            end

            if totalc > 1 then
                self.text = self.text .. " (" .. tostring(leqc) .. ")"
            end
        end

        self.textcolor = MenuTheme_TX

        if self:IsSelected() then
            self.BGColor = SS_DarkMode and Color(53, 53, 53, 255) or Color(192, 192, 255, 255)
            local labelview = self.hovered and self.item.primaryaction --not self.item.never_equip

            if labelview then
                self.barheight = 30
                self.textfont = "SS_Price"
                self.text = self.item.primaryaction and self.item.primaryaction.Text(self.item) or "FIXME"
            end
        elseif labelview then
            self.BGColor = SS_DarkMode and Color(43, 43, 43, 255) or Color(216, 216, 248, 255)
        end
    end

    if self.fademodel then
        SS_GLOBAL_RECT(0, 0, w, h, ColorAlpha(self:IsSelected() and MenuTheme_Brand or MenuTheme_FG, 64))
    end

    if self.iop.class == "sandbox" then
        local m = ImgurMaterial({
            id = "nrLaHIZ.png",
            shader = "UnlitGeneric",
            params = [[{["$translucent"]=1}]],
            worksafe = true
        })

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(m)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    if self.iop.OutlineColor then
        local c = self.iop:OutlineColor()

        if c then
            surface.SetDrawColor(c)
            -- surface.DrawOutlinedRect(0, 0, w, h + 7, 8)
            surface.DrawRect(0, 0, w, 16)
        end
    end

    if self.icon then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(self.icon)
        surface.DrawTexturedRect(w - 20, 4, 16, 16)

        if self.icontext then
            draw.SimpleText(self.icontext, "SS_ProductName", self:GetWide() - 22, 11, MenuTheme_TX, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end

    if self.barcolor then
        surface.SetDrawColor(self.barcolor)
        surface.DrawRect(0, self:GetTall() - self.barheight, self:GetWide(), self.barheight)
    end

    draw.SimpleText(self.text, self.textfont, self:GetWide() / 2, self:GetTall() - (self.barheight / 2), self.textcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if self.item and self.item.auction_end_t then
        local sex = math.max(self.item.auction_end_t - os.time(), 0)
        local d = math.floor(sex / (3600 * 24))
        local h = math.floor(sex / 3600) % 24
        local m = math.floor(sex / 60) % 60
        local s = math.floor(sex) % 60
        local str = string.format("%02i:%02i:%02i", h, m, s)

        if d > 0 then
            str = d .. "d " .. str
        end

        local font = "CloseCaption_Bold"
        draw.SimpleText(str, font, self:GetWide() / 2, 0, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(string.Comma(self.item.bid_price), font, self:GetWide() / 2, self:GetTall() - self.barheight, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end
end

vgui.Register('DPointShopItem', PANEL, 'DPanel')
