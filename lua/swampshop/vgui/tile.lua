-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- Note: CAN BE PRODUCT OR ITEM

-- TODO: why does it look down so much on the preview compared to the item?
-- TODO: make camera only change pitch and zoom, object rotates only yaw (because of box lighting)
function SS_PreviewShopModel(self)
    local min, max = self.Entity:GetRenderBounds()
    local center, radius = (min + max) / 2, min:Distance(max) / 2
    self:SetCamPos(self.Entity:LocalToWorld(center) + ((radius + 1) * Vector(1, 1, 1)))
    self:SetLookAt(self.Entity:LocalToWorld(center))
end

local lastmousedown = false

hook.Add("Think", "SS_DeselectTiles", function()
    --and not self.product and self:IsSelected() then
    if SS_SelectedTile then
        local c = input.IsMouseDown(MOUSE_LEFT)

        local function mouse_inside_panel(panel)
            local x, y = panel:LocalCursorPos()

            return x > 0 and y > 0 and x < panel:GetWide() and y < panel:GetTall()
        end

        if c and not lastmousedown then
            if not mouse_inside_panel(SS_SelectedTile) and not mouse_inside_panel(SS_PreviewPane) and not SS_CustomizerPanel:IsVisible() then
                SS_SelectedTile:Deselect()
            end
        end

        lastmousedown = c
    end
end)

local PANEL = {}

function PANEL:Init()
    self:SetFOV(60)
end

function PANEL:Think()
    self.velocity = math.Clamp((self.velocity or 0) + FrameTime() * (self:IsHovered() and 5 or -2), 0, 1)
    self.Yaw = (self.Yaw + self.velocity * FrameTime() * 120) % 360
    self.ZoomOffsetPos = math.Clamp((self.ZoomOffsetPos or 0) + FrameTime() * (self:IsHovered() and 2 or -2), 0, 1)
    self.ZoomOffset = (math.cos(self.ZoomOffsetPos * math.pi) - 1) * 0.1
end

-- Decide a local point on the entity to look at and the default distance
function PANEL:FocalPointAndDistance()
    --LOCAL?
    local min, max = self.Entity:GetRenderBounds()
    local center, radius = (min + max) / 2, min:Distance(max) / 2

    return center, (radius + 1) * 1.8
end

function PANEL:OnRemove()
    if self:IsSelected() then
        self:Deselect()
    end
end

function PANEL:OnCursorEntered()
    SS_HoveredTile = self
end

function PANEL:OnCursorExited()
    if SS_HoveredTile == self then
        SS_HoveredTile = nil
    end
end

function PANEL:IsHovered()
    return SS_HoveredTile == self
end

function PANEL:IsSelected()
    return SS_SelectedTile == self
end

function PANEL:OnMousePressed(b)
    if b ~= MOUSE_LEFT then return end

    if self:IsSelected() then
        self:Deselect()

        if self.product then
            local cantbuy = self.product:CannotBuy(LocalPlayer())

            if cantbuy then
                surface.PlaySound("common/wpn_denyselect.wav")
                LocalPlayerNotify(cantbuy)
            else
                surface.PlaySound("UI/buttonclick.wav")
                SS_BuyProduct(self.product.class)
            end
        else
            if self.item.primaryaction then
                surface.PlaySound("UI/buttonclick.wav")

                if LocalPlayer():SS_FindItem(self.item.id) then
                    RunConsoleCommand("ps", self.item.primaryaction.id, self.item.id)
                else
                    self.item.primaryaction.OnClient(self.item)
                end
            else
                print("FIX " .. self.item.class)
            end
        end
    else
        self:Select()
    end
end

function PANEL:Select()
    if IsValid(SS_SelectedTile) then
        SS_SelectedTile:Deselect()
    end

    SS_SelectedTile = self

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

                        if LocalPlayer():SS_FindItem(self.item.id) then
                            RunConsoleCommand("ps", act.id, self.item.id)
                        else
                            act.OnClient(self.item)
                        end
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
    SS_SelectedTile = nil
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

function PANEL:SetProduct(product)
    self.product = product
    self.item = nil
    self.iop = product
end

function PANEL:SetItem(item)
    self.item = item
    self.product = nil
    self.iop = item
end

local ownedcheckmark = Material("icon16/accept.png")
local visiblemark = Material("icon16/eye.png")
-- TODO: make the background be part of the item/product, and show it in the preview
local blueprint = Material("gui/dupe_bg.png")

-- local orangeprint = CreateMaterial("orangeprint"..CurTime(),"g_colourmodify",{
-- 	[ "$pp_colour_addr" ] = 0.0,
-- 	[ "$pp_colour_addg" ] = 0.0,
-- 	[ "$pp_colour_addb" ] = 0,
-- 	[ "$pp_colour_brightness" ] = 0,
-- 	[ "$pp_colour_contrast" ] = 0.8,
-- 	[ "$pp_colour_colour" ] = -1,
-- 	[ "$pp_colour_mulr" ] = 0,
-- 	[ "$pp_colour_mulg" ] = 0,
-- 	[ "$pp_colour_mulb" ] = 0
-- })
-- orangeprint:SetTexture("$fbtexture",blueprint:GetTexture("$basetexture"))
--NOMINIFY
function PANEL:Paint(w, h)
    SS_PaintFG(self, w, h)

    if self.iop.background then
        surface.SetMaterial(blueprint)
        -- surface.SetDrawColor(shade,shade,shade, 255)
        surface.SetDrawColor(160, 120, 128, 255)

        if not (self.iop.class == "prop" or self.iop.class == "sandbox") then
            -- surface.SetMaterial(orangeprint)
            surface.SetDrawColor(120, 150, 128, 140, 255)
        end

        surface.DrawTexturedRect(0, 0, w, h)
    end

    if self:IsSelected() then
        SS_GLOBAL_RECT(0, 0, w, h, ColorAlpha(MenuTheme_Brand, 100))
    end

    local mdl = self.iop:GetModel()

    -- todo: show workshop preview panel
    if is_model_undownloaded(mdl) then
        draw.SimpleText("Mouse over", "DermaDefaultBold", w / 2, h / 2 - 8, MenuTheme_TX, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("to download", "DermaDefaultBold", w / 2, h / 2 + 8, MenuTheme_TX, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        if self.modelapplied ~= mdl then
            self:SetModel(mdl)
            self.modelapplied = mdl

            if IsValid(self.Entity) then
                self.Entity.GetPlayerColor = function() return LocalPlayer():GetPlayerColor() end
                local item = self.item or self.product.sample_item

                if item then
                    SS_SetItemMaterialToEntity(item, self.Entity, true)
                elseif self.product.material then
                    self.Entity:SetMaterial(self.product.material)
                end
            end
        end

        if not IsValid(self.Entity) then return end
        self:AlignEntity()
        self:StartCamera()
        self:DrawModel()
        self:EndCamera()
    end
end

function PANEL:PaintOver(w, h)
    local fademodel = false
    local barcolor = nil
    local barheight = nil
    local text = nil
    local textcolor = nil
    local textfont = nil
    local icon = nil
    local icontext = nil
    local BGColor = SS_TileBGColor

    if self.product then
        barheight = barheight or 0
        local cannot = ProtectedCall(self.product:CannotBuy(LocalPlayer()))

        if cannot then
            fademodel = true

            if cannot == SS_CANNOTBUY_AFFORD then
                barcolor = Color(100, 20, 20, 255) --Color(112, 0, 0, 160)
            else
                barcolor = Color(72, 72, 72, 255) --Color(72, 72, 72, 160)
            end
        else
            barcolor = Color(20, 100, 20, 255) --Color(0, 112, 0, 160)
        end

        local c = self.product.sample_item and LocalPlayer():SS_CountItem(self.product.sample_item.class) or 0

        if c > 0 then
            icon = ownedcheckmark

            if c > 1 then
                icontext = tostring(c) .. "x"
            end
        end

        if self:IsHovered() then
            barheight = 30
            textfont = "SS_Price"
            text = self:IsSelected() and (self.product.price == 0 and ">  GET  <" or ">  BUY  <") or (self.product.price == 0 and "FREE" or "-" .. tostring(self.product.price))
        else
            barheight = 20
            textfont = "SS_ProductName"
            text = self.product:GetName()
        end

        textcolor = MenuTheme_TXAlt
    else
        if self.item.eq then
            icon = visiblemark
        else
            if not self.item.never_equip then
                fademodel = true
            end
        end

        barheight = 20
        textfont = "SS_ProductName"
        text = self.item:GetName()

        if (self.item.auction_price or 0) == 0 then
            local leqc = 0
            local totalc = 0

            for k, otheritem in pairs(LocalPlayer().SS_Items or {}) do
                if self.item:GetName() == otheritem:GetName() then
                    totalc = totalc + 1

                    if otheritem.id <= self.item.id then
                        leqc = leqc + 1
                    end
                end
            end

            if totalc > 1 then
                text = text .. " (" .. tostring(leqc) .. ")"
            end
        end

        textcolor = MenuTheme_TX

        if self:IsSelected() then
            BGColor = SS_DarkMode and Color(53, 53, 53, 255) or Color(192, 192, 255, 255)
            local labelview = self:IsHovered() and self.item.primaryaction --not self.item.never_equip

            if labelview then
                barheight = 30
                textfont = "SS_Price"
                text = self.item.primaryaction and self.item.primaryaction.Text(self.item) or "FIXME"
                surface.SetFont(textfont)
                local tw, th = surface.GetTextSize(text)

                if tw > w then
                    textfont = "SS_PriceSmaller"
                    barheight = th
                end
            end
        elseif labelview then
            BGColor = SS_DarkMode and Color(43, 43, 43, 255) or Color(216, 216, 248, 255)
        end
    end

    if fademodel then
        SS_GLOBAL_RECT(0, 0, w, h, ColorAlpha(self:IsSelected() and MenuTheme_Brand or MenuTheme_FG, 64))
    end

    -- if self.iop.class == "sandbox" or self.iop.class == "csslootbox" then
    --     local m = WebMaterial({
    --         id = "nrLaHIZ.png",
    --         shader = "UnlitGeneric",
    --         params = [[{["$translucent"]=1}]]
    --     })
    --     surface.SetDrawColor(255, 255, 255, 255)
    --     surface.SetMaterial(m)
    --     surface.DrawTexturedRect(0, 0, w, h)
    -- end
    if self.iop.OutlineColor then
        local c = self.iop:OutlineColor()

        if c then
            surface.SetDrawColor(c)
            -- surface.DrawOutlinedRect(0, 0, w, h + 7, 8)
            surface.DrawRect(0, 0, w, 16)
        end
    end

    if icon then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(icon)
        surface.DrawTexturedRect(w - 20, 4, 16, 16)

        if icontext then
            draw.SimpleText(icontext, "SS_ProductName", self:GetWide() - 22, 11, MenuTheme_TX, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end

    if barcolor then
        surface.SetDrawColor(barcolor)
        surface.DrawRect(0, self:GetTall() - barheight, self:GetWide(), barheight)
    end

    if textfont == "SS_ProductName" then
        draw.WrappedText(text, textfont, self:GetWide() / 2, self:GetTall() - 1, self:GetWide(), textcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    else
        draw.SimpleText(text, textfont, self:GetWide() / 2, self:GetTall() - (barheight / 2), textcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

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
        draw.SimpleText(string.Comma(self.item.bid_price), font, self:GetWide() / 2, self:GetTall() - barheight, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end
end

vgui.Register('DPointShopItem', PANEL, 'SwampShopModelBase')
