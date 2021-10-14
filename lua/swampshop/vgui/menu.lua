-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local PANEL = {}
local froggy = Material("vgui/frog.png")

surface.CreateFont("SwampShop1", {
    font = "averiaserif-bold",
    weight = 1000,
    size = 40
})

surface.CreateFont("SwampShop2", {
    font = "averiaserif-bold",
    weight = 1000,
    size = 36
})

-- The fatkid gamemode has a no-moneymaking-allowed license
-- Of course, I made the gamemode, so I don't have to follow my own license,
-- but still don't advertise donations to not look like a hypocrite.
local showdonatebutton = true

timer.Simple(0, function()
    showdonatebutton = GAMEMODE.FolderName ~= "fatkid"
end)

function PANEL:Init()
    self:SetSize(math.Clamp(SS_MENUWIDTH, 0, ScrW()), math.Clamp(SS_MENUHEIGHT, 0, ScrH()))
    self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2))

    self.topbar = vgui("DPanel", self, function(navbar)
        navbar:SetTall(SS_NAVBARHEIGHT)
        navbar:Dock(TOP)
        navbar:SetZPos(32767)
        navbar.Paint = SS_PaintBrandStripes

        --title text 
        vgui("DLabel", function(p)
            p:SetText("SWAMP SHOP") --SHOβ") ⮩ \n  
            p:SetFont('ScoreboardTitleSmall') --SS_LargeTitle') --ScoreboardTitleSmall
            p:SizeToContentsX()
            p:DockMargin(16, 0, 8, 0)
            -- p:DockMargin(16, 0, 0, 0)
            p:SetColor(SS_ColorWhite)
            --p:SetPaintBackground(false)
            p:Dock(LEFT)
        end)

        -- close button
        vgui("DButton", function(p)
            p:SetFont('marlett')
            p:SetText('r')
            p.Paint = SS_PaintDarkenOnHover
            p:SetColor(SS_ColorWhite)
            p:SetSize(SS_NAVBARHEIGHT, SS_NAVBARHEIGHT)
            p:Dock(RIGHT)

            p.DoClick = function()
                SS_ToggleMenu()
            end
        end)

        -- toggle theme button
        vgui("DImageButton", function(p)
            p:SetImage("icon16/palette.png")
            p:SetStretchToFit(false)
            p.Paint = SS_PaintDarkenOnHover
            p:SetSize(SS_NAVBARHEIGHT, SS_NAVBARHEIGHT)
            p:SetTooltip("Change UI Color")
            p:Dock(RIGHT)

            p.DoClick = function()
                if (IsValid(p.menu)) then
                    p.menu:Remove()

                    return
                end

                local menu = DermaMenu()
                p.menu = menu
                menu:SetMinimumWidth(24)
                menu.Paint = SS_PaintShaded

                -- local p2 = vgui.Create("DImageButton", menu)
                -- p2:SetImage("icon16/lightbulb.png")
                -- p2:SetStretchToFit(false)
                -- p2.Paint = SS_PaintDarkenOnHover
                -- -- p:SetSize(SS_NAVBARHEIGHT / 2, SS_NAVBARHEIGHT)
                -- p2:SetTooltip("Toggle dark mode/light mode")
                -- -- p:Dock(RIGHT)
                -- p2.DoClick = function()
                --     GetConVar("ps_darkmode"):SetBool(not GetConVar("ps_darkmode"):GetBool())
                -- end
                -- menu:AddPanel(p2)
                -- p2:SetSize(24, 24)
                for k, v in pairs(BrandColors) do
                    local ColorChoice = vgui.Create("DButton", menu)
                    ColorChoice:SetText("")

                    ColorChoice.Paint = function(pnl, w, h)
                        surface.SetDrawColor(GetConVar("ps_themecolor"):GetInt() == k and Color(255, 255, 255) or Color(64, 64, 64))
                        surface.DrawRect(2, 2, w - 4, w - 4)
                        surface.SetDrawColor(v)
                        surface.DrawRect(4, 4, w - 8, w - 8)
                    end

                    ColorChoice.DoClick = function(pnl)
                        GetConVar("ps_themecolor"):SetInt(k)
                        menu:Remove()
                    end

                    menu:AddPanel(ColorChoice)
                    ColorChoice:SetSize(24, 24)
                end

                local w, h = p:GetSize()
                local x, y = p:LocalToScreen((w / 2) - 12, (h / 2) + 12)
                menu:Open(x, y)
            end
        end)
    end)

    --bottompane
    self.botbar = vgui("DPanel", self, function(p)
        p:SetTall(SS_BOTBARHEIGHT)
        p:SetZPos(32767)
        p:Dock(BOTTOM)

        function p:Paint(w, h)
            SS_PaintMD(self, w, h)
            -- BrandBackgroundPatternOverlay(0,h-SS_BOTBARSUBHEIGHT,w,SS_BOTBARSUBHEIGHT,500)
            BrandBackgroundPatternOverlay(0, 0, w, h - SS_BOTBARSUBHEIGHT, 500)
            -- BrandBackgroundPattern(0,40,w,h-40,500)
            -- surface.SetDrawColor(BrandColorGray)
            -- surface.DrawRect(0,0,w,h-SS_BOTBARSUBHEIGHT)
            -- -- SS_PaintMD(self, w,h-SS_BOTBARSUBHEIGHT)
            BrandDropDownGradient(0, h - SS_BOTBARSUBHEIGHT, w)
        end

        -- avatar/points area
        vgui("DPanel", function(p)
            p:DockPadding(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
            p:Dock(LEFT)
            p:SetWide(420)
            p.Paint = noop

            local av = vgui("AvatarImage", function(p)
                p:Dock(LEFT)
                p:SetPlayer(LocalPlayer(), 184)
                p:SetSize(SS_BOTBARHEIGHT - (SS_COMMONMARGIN * 2), SS_BOTBARHEIGHT - (SS_COMMONMARGIN * 2))
                p:SetPos(SS_COMMONMARGIN, SS_COMMONMARGIN)
            end)

            vgui("DPanel", function(p)
                p:SetWide(384 - av:GetWide() - SS_COMMONMARGIN * 2)
                p:DockMargin(SS_COMMONMARGIN, 0, 0, 0)
                p:Dock(FILL)
                p:InvalidateLayout(true)

                local helpbutton = vgui('DImageButton', function(p)
                    p:SetSize(16, 16)
                    p:SetTooltip("Info")
                    p:SetTextColor(MenuTheme_TX)
                    p:SetImage("icon16/help.png")

                    p.DoClick = function()
                        SS_ToggleMenu()
                        ShowMotd("https://swamp.sv/points")
                    end
                end)

                -- vgui("DButton", function(p)
                --     p:SetFont('DermaDefault')
                --     p:SetText('(?)')
                --     p.Paint = SS_PaintDarkenOnHover
                --     p:SetColor(SS_ColorWhite)
                --     p:SetSize(20,20)
                --     p:SetContentAlignment(5)
                --     p.DoClick = function()
                --         SS_ToggleMenu()
                --         ShowMotd("https://swamp.sv/points")
                --     end
                -- end)
                local givebutton = vgui('DImageButton', function(p)
                    p:SetSize(16, 16)
                    p:SetTooltip("Give Points")
                    p:SetTextColor(MenuTheme_TX)
                    p:SetImage("icon16/group_go.png")

                    p.DoClick = function()
                        vgui.Create('DPointShopGivePoints')
                    end
                end)

                p.Paint = function(pnl, w, h)
                    local x, y = 4, (h / 2)
                    draw.SimpleText(string.Comma(LocalPlayer():SS_GetPoints()) .. ' Points', 'SS_POINTSFONT', x, y - 15, MenuTheme_TXAlt, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    local newoffset = 5
                    local w2, h2 = draw.SimpleText("Income: " .. tostring(LocalPlayer():SS_Income()) .. ' Points/Minute', 'SS_INCOMEFONT', x, y + 16 + newoffset, MenuTheme_TXAlt, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    helpbutton:SetPos(x + w2 + 7, y + 11 + newoffset)
                    givebutton:SetPos(x + w2 + 28, y + 10 + newoffset)
                end
            end)
        end)

        vgui("DPanel", function(p)
            p:Dock(FILL)
            p.Paint = noop

            self.invbar = vgui("DPanel", function(p)
                -- p:SetWide(SS_RPANEWIDTH)
                p:Dock(FILL)
                -- p:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
                p.Paint = noop

                vgui("DPanel", function(p)
                    p.Paint = noop
                    p:Dock(LEFT)

                    function p:Think()
                        local pp = self:GetParent()
                        local cw = 0

                        for i, v in ipairs(pp:GetChildren()) do
                            if v ~= self then
                                cw = cw + v:GetWide()
                            end
                        end

                        self:SetWide((pp:GetWide() - cw) / 2)
                    end
                end)
            end)

            vgui("DLabel", function(p)
                p:Dock(BOTTOM)
                p:SetText("Inventory")
                p:SetColor(color_white)
                p:SetFont('SS_Donate2')
                p:SetContentAlignment(5)
                p:SetTall(SS_BOTBARSUBHEIGHT)
            end)
        end)

        --donate button
        vgui("DButton", function(p)
            p:Dock(RIGHT)
            p:SetFont("SS_INCOMEFONT")
            p:SetText("")
            p:SetWide(420)

            p.DoClick = function()
                if not showdonatebutton then return end
                gui.OpenURL('https://swamp.sv/donate/')
            end

            local DollarParticlePoints = -0.2
            local DollarParticles = {}

            p.Paint = function(self, w, h)
                if not showdonatebutton then return end
                SS_PaintDarkenOnHover(self, w, h)
                local alpha = 180
                local mousex, mousey = self:CursorPos()
                local distscale = 250
                alpha = math.max(distscale - (Vector(mousex, mousey, 0):Distance(Vector(w / 2, h / 2, 0))), 0) / distscale
                DollarParticlePoints = DollarParticlePoints + (RealFrameTime() * math.max(alpha, 0.02))
                local ytop = -20
                local yfade = 32

                while DollarParticlePoints > 0 do
                    local sc = math.Rand(0.6, 2.4)

                    table.insert(DollarParticles, {
                        x = math.Rand(0, w),
                        y = ytop,
                        speed = sc * 30,
                        scale = sc,
                        sinmag = math.Rand(0, 20),
                        sinfreq = math.Rand(1, 2),
                        sinofs = math.Rand(0, 6.3),
                        material = pointshopDollarImage
                    })

                    DollarParticlePoints = DollarParticlePoints - 0.12
                end

                for k, v in pairs(DollarParticles) do
                    v.y = v.y + (RealFrameTime() * v.speed)

                    if v.y > h + 50 then
                        table.remove(DollarParticles, k)
                    else
                        surface.SetDrawColor(220, 220, 220, math.floor(255 * math.min(1, math.min(v.y - ytop, h - v.y) / yfade)))
                        surface.SetMaterial(v.material)
                        local iw = math.floor(8 * v.scale) * 2
                        local ih = math.floor(8 * v.scale) * 2
                        surface.DrawTexturedRect(math.floor((v.sinmag * math.sin(v.sinofs + (RealTime() * v.sinfreq))) + v.x - (iw / 2)), math.floor(v.y - (ih / 2)), iw, ih)
                    end
                end

                local tc = MenuTheme_TXAlt

                --[[if self:IsHovered() then
                tc = Color(175,230,69)
            end]]
                if showdonatebutton then
                    draw.SimpleText('Need more points?', 'SS_Donate1', w - 180, (h / 2) - 18 + 2, tc, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    draw.SimpleText('Click here to donate!', 'SS_Donate2', w - 180, (h / 2) + 18 + 8, tc, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
            end
        end)
    end)

    --whole page contents
    vgui("DPanel", self, function(p)
        p:DockPadding(SS_COMMONMARGIN, 0, SS_COMMONMARGIN, 0)
        p:Dock(FILL)
        p.Paint = noop

        --preview pane
        -- SS_PreviewPane = vgui("DPanel", function(p)
        --     p:SetWide(SS_RPANEWIDTH)
        --     p:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, 0, SS_COMMONMARGIN)
        --     p:Dock(RIGHT)
        --     p.Paint = SS_PaintFG
        SS_PreviewPane = vgui("DPointShopPreview", function(p)
            p:SetWide(SS_RPANEWIDTH)
            p:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, 0, SS_COMMONMARGIN)
            p:Dock(RIGHT)

            -- if you want to make the background a tile, do it in preview.lua
            -- p:Dock(FILL)
            SS_DescriptionPanel = vgui("DPanel", function(p)
                p:Dock(BOTTOM)
                p:SetTall(1)

                -- p:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
                -- p:DockMargin(0,0,0,32)
                p.PerformLayout = function()
                    SS_DescriptionPanel:InvalidateParent()
                    SS_DescriptionPanel:SizeToChildren(false, true)
                end

                p.Paint = noop
            end)
        end)

        -- end)
        self.leftpane = vgui("DPanel", function(p)
            p:Dock(FILL)
            p.Paint = noop
        end)
    end)

    local btns = {}
    local firstCat = true

    local function NewCategory(catname, icon, inv)
        local panel = vgui.Create('DPanel', self.leftpane)
        panel:Dock(FILL)
        panel:DockMargin(0, 0, 0, 0)
        panel.Paint = function() end

        if firstCat then
            panel:SetZPos(100)
            panel:SetVisible(true)
        else
            panel:SetZPos(1)
            panel:SetVisible(false)
        end

        --add item list
        local DScrollPanel = vgui('DScrollPanel', panel, function(p)
            p:Dock(FILL)
            p:DockMargin(0, 0, 0, 0)
            p:DockPadding(0, 0, 0, 0)
            --p.Paint = SS_PaintDirty
            --p.VBar:DockMargin(0, 0, 0, 0)
            p.VBar:SetWide(SS_SCROLL_WIDTH)
            SS_SetupVBar(p.VBar)
            p.VBar:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, 0, SS_COMMONMARGIN)

            --the pretty layout kinda just breaks when you take away the scroll bar so let's just leave it there
            function p.VBar:SetUp(_barsize_, _canvassize_)
                self.BarSize = _barsize_
                self.CanvasSize = math.max(_canvassize_ - _barsize_, 0)
                self:SetEnabled(true)
                self.btnGrip:SetEnabled(_canvassize_ > _barsize_)
                self:InvalidateLayout()
            end
        end)

        local btn = vgui.Create("DButton", inv and self.invbar or self.topbar)
        btn:Dock(LEFT)
        btn:SetText(catname)
        btn:SetFont("SS_Category")
        btn:SetImage(icon)

        btn.Paint = function(pnl, w, h)
            if pnl:GetActive() then
                surface.SetDrawColor(Color(0, 0, 0, 144))
                surface.DrawRect(0, 0, w, h)
                --gradient drop down?
            else
                SS_PaintDarkenOnHover(pnl, w, h)
            end
        end

        btn.UpdateColours = function(pnl)
            pnl:SetTextColor(BrandColorWhite)
        end

        btn.PerformLayout = function(pnl)
            pnl:SizeToContents()
            pnl:SetWide(pnl:GetWide() + 24)
            pnl:SetTall(pnl:GetParent():GetTall())
            DLabel.PerformLayout(pnl)
            local txt_inset = -8
            pnl.m_Image:SetSize(16, 16)
            pnl.m_Image:SetPos((pnl:GetWide() - 16) * 0.5, pnl:GetTall() + txt_inset - (16 + 20))
            pnl:SetContentAlignment(2)
            pnl:SetTextInset(0, txt_inset)
        end

        btn.GetActive = function(pnl) return pnl.Active or false end

        btn.SetActive = function(pnl, state)
            pnl.Active = state
        end

        if firstCat then
            firstCat = false
            btn:SetActive(true)
        end

        btn.DoClick = function(pnl)
            --patch
            SS_CustomizerPanel:Close()

            if IsValid(SS_SelectedTile) then
                SS_SelectedTile:Deselect()
            end

            for k, v in pairs(btns) do
                v:SetActive(false)
                v:OnDeactivate()
            end

            pnl:SetActive(true)
            pnl:OnActivate()
        end

        btn.OnDeactivate = function()
            panel:SetVisible(false)
            panel:SetZPos(1)
        end

        btn.OnActivate = function()
            panel:SetVisible(true)
            panel:SetZPos(100)
        end

        table.insert(btns, btn)

        return DScrollPanel
    end

    local padcnt = 0

    local function Pad(DScrollPanel)
        local pad = vgui.Create('DPanel', DScrollPanel)
        pad.Paint = noop
        pad:SetTall(SS_COMMONMARGIN)
        pad:Dock(TOP)
        DScrollPanel:AddItem(pad)
    end

    local function NewSubCategoryTitle(DScrollPanel, txt)
        vgui("DPanel", DScrollPanel, function(p)
            p:Dock(TOP)
            p:DockMargin(0, 0, SS_COMMONMARGIN, 0)
            p:SetPaintBackground(true)
            p:SetTall(SS_SUBCATEGORY_HEIGHT)
            p.Paint = SS_PaintFG

            vgui("DLabel", function(p)
                p:SetText(txt)
                p:SetFont('SS_SubCategory')
                p:Dock(FILL)
                p:SetContentAlignment(4)
                p:DockMargin(SS_COMMONMARGIN, 0, SS_COMMONMARGIN, 0)
                p:SetColor(MenuTheme_TX)

                p.UpdateColours = function(pnl)
                    pnl:SetTextColor(MenuTheme_TX)
                end

                p:SizeToContentsY()
            end)
        end)
    end

    local function NewSubCategory(DScrollPanel)
        local ShopCategoryTabLayout = vgui.Create('DIconLayout', DScrollPanel)
        ShopCategoryTabLayout:Dock(TOP)
        ShopCategoryTabLayout:DockMargin(0, 0, 0, 0)
        ShopCategoryTabLayout:SetBorder(0)
        ShopCategoryTabLayout:SetSpaceX(SS_COMMONMARGIN)
        ShopCategoryTabLayout:SetSpaceY(SS_COMMONMARGIN)
        DScrollPanel:AddItem(ShopCategoryTabLayout)

        return ShopCategoryTabLayout
    end

    local function FinishCategory(DScrollPanel)
        Pad(DScrollPanel)
    end

    for _, CATEGORY in ipairs(SS_Layout) do
        local cat = NewCategory(CATEGORY.name, 'icon16/' .. CATEGORY.icon .. '.png')
        local first = true
        Pad(cat)

        for _, LAYOUT in ipairs(CATEGORY.layout) do
            --we cap off previous ones here
            if (first) then
                if (#LAYOUT.products > 0) then
                    first = false
                end
            else
                Pad(cat)
            end

            if LAYOUT.title then
                NewSubCategoryTitle(cat, LAYOUT.title)
                Pad(cat)
            end

            local scat = NewSubCategory(cat)

            for _, product in ipairs(LAYOUT.products) do
                local model = vgui.Create('DPointShopItem')
                model:SetProduct(product)
                model:SetSize(SS_TILESIZE, SS_TILESIZE)
                scat:Add(model)
            end
        end

        Pad(cat)
    end

    SS_AuctionPanel = NewCategory("Auctions", 'icon16/house.png')
    SS_AuctionPanel.DesiredSearch = 1
    Pad(SS_AuctionPanel)

    -- todo: DO this for inventory?
    function SS_AuctionPanel:VisibleThink()
        if self.LatestSearch ~= self.DesiredSearch then
            net.Start('SS_SearchAuctions')
            net.WriteUInt(self.DesiredSearch, 16) --page
            net.WriteUInt(0, 32) -- minprice
            net.WriteUInt(0, 32) --maxprice
            net.WriteBool(false) --mineonly
            net.SendToServer()
            self.LatestSearch = self.DesiredSearch
        end
    end

    SS_AuctionPanel.controls = vgui("DPanel", SS_AuctionPanel, function(p)
        p:Dock(TOP)
        p:DockMargin(0, 0, SS_COMMONMARGIN, 0)
        p:SetPaintBackground(true)
        p:SetTall(SS_SUBCATEGORY_HEIGHT)

        function p:Paint(w, h)
            SS_PaintFG(self, w, h)
            SS_AuctionPanel:VisibleThink()
            -- Control the search. do it in paint so we arent updating when the panel isnt shown
        end

        vgui("DLabel", function(p)
            p:SetText("Auctions (WIP)")
            p:SetFont('SS_SubCategory')
            p:Dock(FILL)
            p:SetContentAlignment(4)
            p:DockMargin(SS_COMMONMARGIN, 0, SS_COMMONMARGIN, 0)
            p:SetColor(MenuTheme_TX)

            p.UpdateColours = function(pnl)
                pnl:SetTextColor(MenuTheme_TX)
            end

            p:SizeToContentsY()
        end)

        p.results = vgui("DLabel", function(p)
            p:SetText("test")
            p:SetFont('SS_SubCategory')
            p:Dock(RIGHT)
            p:SetContentAlignment(4)
            p:DockMargin(SS_COMMONMARGIN, 0, SS_COMMONMARGIN, 0)
            p:SetColor(MenuTheme_TX)

            p.UpdateColours = function(pnl)
                pnl:SetTextColor(MenuTheme_TX)
            end

            p:SizeToContentsY()
        end)

        vgui("DButton", function(p)
            p:Dock(RIGHT)
            p:SetText(">")
            p:SetColor(MenuTheme_TX)
            p:SetFont("SS_SubCategory")
            p.Paint = SS_PaintDarkenOnHover

            p.DoClick = function()
                SS_AuctionPanel.DesiredSearch = SS_AuctionPanel.DesiredSearch + 1
            end
        end)

        vgui("DButton", function(p)
            p:Dock(RIGHT)
            p:SetText("<")
            p:SetColor(MenuTheme_TX)
            p:SetFont("SS_SubCategory")
            p.Paint = SS_PaintDarkenOnHover

            p.DoClick = function()
                SS_AuctionPanel.DesiredSearch = math.max(1, SS_AuctionPanel.DesiredSearch - 1)
            end
        end)
    end)

    --CONTROLS HERE...
    Pad(SS_AuctionPanel)
    SS_AuctionPanel.results = NewSubCategory(SS_AuctionPanel)

    function SS_AuctionPanel:ReceiveSearch(items, totalitems)
        for i, v in ipairs(SS_AuctionPanel.results:GetChildren()) do
            v:Remove()
        end

        self.controls.results:SetText(tostring(totalitems) .. " total results")
        self.controls.results:SizeToContents()
        items = SS_MakeItems(SS_SAMPLE_ITEM_OWNER, items)

        for _, item in pairs(items) do
            local mine = (item.seller == LocalPlayer():SteamID64())
            local mybid = (item.auction_bidder == LocalPlayer():SteamID64())
            local sn = item.seller_name
            local bn = item.bidder_name

            if mine then
                sn = sn .. " (You)"
            end

            if mybid then
                bn = bn .. " (You)"
            end

            -- Hmm, lets override metatable keys on the item instance
            item.primaryaction = false
            local desc = item:GetDescription() or ""
            desc = desc .. "\n(Item class: " .. item.class .. ")"
            desc = desc .. "\n\nSold by " .. sn

            if item.auction_bidder == "0" then
                desc = desc .. "\nNo bidders"
            else
                desc = desc .. "\nHighest bidder is " .. bn .. " (" .. item.auction_price .. ")"
            end

            -- if item.seller == LocalPlayer():SteamID64() then
            if mine then
                if item.auction_bidder == "0" then
                    item.actions = {
                        cancel = {
                            Text = function(item) return "Cancel Auction" end,
                            OnClient = function(item)
                                net.Start("SS_CancelAuction")
                                net.WriteUInt(item.id, 32)
                                net.SendToServer()
                            end
                        }
                    }
                else
                    desc = desc .. "\n\nCan't cancel a bidded auction."
                    item.actions = {}
                end
            else
                if mybid then
                    item.actions = {}
                else
                    item.actions = {
                        bid = {
                            Text = function(item) return "Bid (" .. tostring(item.bid_price) .. " minimum)" end,
                            OnClient = function(item)
                                Derma_StringRequest("Bid on this " .. item:GetName(), "Enter your bid - minimum is " .. tostring(item.bid_price), tostring(item.bid_price), function(text)
                                    text = tonumber(text)

                                    if text then
                                        net.Start("SS_BidAuction")
                                        net.WriteUInt(item.id, 32)
                                        net.WriteUInt(math.max(0, text), 32)
                                        net.SendToServer()
                                    end
                                end, function(text) end, "Bid", "Cancel")
                            end
                        }
                    }
                end
            end

            item.GetDescription = function() return desc end
            local model = vgui.Create('DPointShopItem')
            model:SetItem(item)
            model:SetSize(SS_TILESIZE, SS_TILESIZE)
            SS_AuctionPanel.results:Add(model)
        end
    end

    local function inventorythink(pnl, categories)
        pnl.Think = function(self)
            if self.validtick ~= SS_ValidInventoryTick then
                -- if #self:GetCanvas():GetChildren() > 0 then
                local scroll2 = self:GetVBar():GetScroll()

                for k, v in pairs(self:GetCanvas():GetChildren()) do
                    v:Remove()
                end

                Pad(self)
                -- TODO sort the items on recipt, then store sortedindex on them
                local itemstemp = table.Copy(LocalPlayer().SS_Items or {}) --GetInventory())

                table.sort(itemstemp, function(a, b)
                    local ar, br = SS_GetRatingID(a.specs.rating), SS_GetRatingID(b.specs.rating)

                    if ar == br then
                        local an, bn = a:GetName(), b:GetName()
                        local i = 0
                        local ml = math.min(string.len(an), string.len(bn))

                        while i < ml do
                            i = i + 1
                            local a1 = string.byte(an, i)
                            local b1 = string.byte(bn, i)
                            if a1 ~= b1 then return a1 < b1 end
                        end

                        if string.len(an) == string.len(bn) then return a.id < b.id end

                        return string.len(an) > string.len(bn)
                    else
                        return ar > br
                    end
                end)

                for k, v in pairs(SS_Items) do
                    if v.clientside_fake then
                        table.insert(itemstemp, SS_GenerateItem(LocalPlayer(), v.class))
                    end
                end

                local categorizeditems = {}

                for _, item in pairs(itemstemp) do
                    local invcategory = item.invcategory or "Other"
                    categorizeditems[invcategory] = categorizeditems[invcategory] or {}
                    table.insert(categorizeditems[invcategory], item)
                end

                local first = true

                for _, cat in ipairs(categories) do
                    if categorizeditems[cat] and table.Count(categorizeditems[cat]) > 0 then
                        if (first) then
                            first = false
                        else
                            Pad(self)
                        end

                        NewSubCategoryTitle(self, cat)
                        Pad(self)
                        local sc = NewSubCategory(self)

                        for _, item in pairs(categorizeditems[cat]) do
                            local model = vgui.Create('DPointShopItem')
                            model:SetItem(item)
                            model:SetSize(SS_TILESIZE, SS_TILESIZE)
                            sc:Add(model)
                        end
                    end
                end

                Pad(self)
                self:InvalidateLayout()
                self.validtick = SS_ValidInventoryTick

                timer.Simple(0, function()
                    self:GetVBar():SetScroll(scroll2)
                end)

                timer.Simple(0.1, function()
                    self:GetVBar():SetScroll(scroll2)
                end)
            end
        end
    end

    inventorythink(NewCategory("Weapons", 'icon16/gun.png', true), {"Weapons", "Skins"})

    inventorythink(NewCategory("Props", 'icon16/book.png', true), {"Props"})

    SS_InventoryPanel = NewCategory("Cosmetics", 'icon16/status_online.png', true)

    inventorythink(SS_InventoryPanel, {"Playermodels", "Accessories", "Mods", "Upgrades", "Other"})

    -- --title text 
    -- vgui("DLabel", self.topbar, function(p)
    --     p:SetText(" ← Store       Inventory →")
    --     p:SetFont('SS_Category') --ScoreboardTitleSmall
    --     p:SizeToContentsX()
    --     p:DockMargin(16, 0, 16, 0)
    --     p:SetColor(SS_ColorWhite)
    --     p:Dock(RIGHT)
    -- end)
    SS_ValidInventoryTick = (SS_ValidInventoryTick or 0) + 1
    SS_CustomizerPanel = vgui.Create('DPointShopCustomizer', SS_InventoryPanel:GetParent():GetParent():GetParent())
    SS_CustomizerPanel:Dock(FILL)
    SS_CustomizerPanel:Close()

    if (IN_STEAMGROUP or 0) <= 0 then
        p = vgui.Create("DButton", self)
        p:SetZPos(1000)
        p:SetPos(-20, self:GetTall() - (76 + SS_BOTBARHEIGHT))
        p:SetSize(360, 72 + 50)
        p:SetWrap(true)
        p:SetTextInset(16, 0)
        -- p:SetFont("SS_JOINFONT")
        -- p:SetText("Click here to join our Discord for double income!")
        p:SetText("")
        p:NoClipping(true)
        local STEAMMATERIAL = Material("vgui/steamlogo.png")

        function p:Paint(w, h)
            local l = (math.sin(SysTime() * 3) + 1) * 0.1
            local c = Color(Lerp(l, 27, 255), Lerp(l, 40, 255), Lerp(l, 56, 255))
            draw.RoundedBox(16, 0, 0, w, h - 50, c)
            local x1, y1 = 100, 40

            local triangle = {
                {
                    x = x1,
                    y = y1
                },
                {
                    x = x1 + 100,
                    y = y1
                },
                {
                    x = x1 + 50,
                    y = y1 + 50
                },
            }

            surface.SetDrawColor(c.r, c.g, c.b, 255)
            draw.NoTexture()
            surface.DrawPoly(triangle)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(STEAMMATERIAL) -- Use our cached material
            surface.DrawTexturedRect(4, 3, 64, 64)

            if self.clicked then
                draw.DrawText("Nothing happen?\nClick again", 'SS_JOINFONT', 72, 4)
            else
                draw.DrawText("Join our Steam chat for\n2x income & 20,000 points!", 'SS_JOINFONT', 72, 4)
            end
            -- draw.DrawText("2x income & 20,000 points!", 'SS_JOINFONTBIG', 70, 38)
        end

        -- p.Think = function(pnl)
        --     -- pnl:SetVisible(IN_DISCORD~=1)
        --     if IN_STEAMGROUP > 0 then
        --         pnl:Remove()
        --     end
        -- end
        p.DoClick = function(pnl)
            -- if IN_DISCORD~=1 then
            -- gui.OpenURL('http://swamp.sv/discord')
            -- if pnl.clicked then 
            gui.OpenURL('https://steamcommunity.com/groups/swampservers')
        end
        -- return end
        -- local frame = vgui.Create( "DFrame" )
        -- frame:SetTitle("")
        -- frame:SetSize( 100,100)
        -- frame:SetAlpha(0)
        -- frame:Center()
        -- frame:MakePopup()
        -- local html = vgui.Create("DHTML", frame)
        -- html:Dock(FILL)
        -- html:OpenURL("https://s.team/chat/LzFgkFD4")
        -- timer.Simple(2, function() if IsValid(frame) then frame:Remove() pnl.clicked = true end end)
    end
    -- end 
end

net.Receive("SS_SearchAuctions", function(len)
    if len == 0 then
        if IsValid(SS_AuctionPanel) then
            SS_AuctionPanel.LatestSearch = nil
        end

        return
    end

    local items = net.ReadTable()
    local total = net.ReadUInt(32)

    if IsValid(SS_AuctionPanel) then
        SS_AuctionPanel:ReceiveSearch(items, total)
    end
end)

function PANEL:Paint(w, h)
    --Derma_DrawBackgroundBlur(self)
    DisableClipping(true)
    local border = 8
    draw.BoxShadow(-2, -2, w + 4, h + 4, border, 1)
    DisableClipping(false)
    SS_PaintBG(self, w, h)
end

SS_INVENTORY_POINT_OUT = -100

net.Receive("SS_PointOutInventory", function()
    SS_INVENTORY_POINT_OUT = RealTime()
end)

function PANEL:PaintOver(w, h)
    local navbottom = self.topbar:GetTall()
    BrandDropDownGradient(0, navbottom, w)
    local bottom = self.botbar:GetTall()
    BrandUpGradient(0, h - bottom, w)
    local frogsize = 212 --208
    local edge = 308
    ofs = (edge / 512) * frogsize
    surface.SetDrawColor(Color(255, 255, 255, 255))

    if not froggy:IsError() then
        surface.SetMaterial(froggy)
        DisableClipping(true)
        render.ClearDepth()
        cam.IgnoreZ(true)
        local frac = 0.8
        surface.DrawTexturedRectUV(w - (frogsize * frac), h - ofs, (frogsize * frac), frogsize, 0, 0, frac, 1)
        cam.IgnoreZ(false)
        DisableClipping(false)
    end

    -- draw.SimpleText("SWAMP", "SwampShop1", w - 300, h - 82)
    -- draw.SimpleText("SHOP", "SwampShop2", w - 270, h - 48)
    local a = math.min(5.0 - ((RealTime() - SS_INVENTORY_POINT_OUT) * 1.0), 1.0, (RealTime() - SS_INVENTORY_POINT_OUT) * 4.0)

    if a > 0 then
        surface.DisableClipping(true)
        draw.SimpleText("access new items here", "DermaLarge", w / 2 + 5, h + 12, Color(255, 255, 255, 255 * a), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("↑", "SS_LargeTitle", w / 2 - 20, h + (math.sin(RealTime() * 6.0) * 5.0), Color(255, 255, 255, 255 * a), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.DisableClipping(false)
    end
end

function PANEL:OnRemove()
    SS_ValidInventoryTick = (SS_ValidInventoryTick or 0) + 1
end

vgui.Register('DPointShopMenu', PANEL, "EditablePanel")
