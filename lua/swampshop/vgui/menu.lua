-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local PANEL = {}

net.Receive("SS_PointOutInventory", function()
    SS_INVENTORY_POINT_OUT = RealTime()
end)

--vgui(classname, (parent,)? constructor)
concommand.Add("cleanup", function()
    for k, v in pairs(vgui.GetWorldPanel():GetChildren()) do
        if (v.testval) then
            v:Remove()
        end
    end
end)

function PANEL:Init()
    self:SetSize(math.Clamp(SS_MENUWIDTH, 0, ScrW()), math.Clamp(SS_MENUHEIGHT, 0, ScrH()))
    self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2))
    self.testval = true

    --nav bar
    self.PaintOver = function(pnl, w, h)
        local navbottom = self.navbar:GetTall()
        cam.IgnoreZ(true)
        DisableClipping(true)
        BrandDropDownGradient(0, navbottom, w)
        DisableClipping(false)
        cam.IgnoreZ(false)
    end

    self.navbar = vgui("DPanel", self, function(navbar)
        navbar:SetTall(SS_NAVBARHEIGHT)
        navbar:Dock(TOP)

        navbar.Paint = function(pnl, w, h)
            BrandBackgroundPattern(0, 0, w, h, 0)
        end

        --title text 
        vgui("DLabel", function(p)
            p:SetText("TOY SHOβ")
            p:SetFont('SS_LargeTitle')
            p:SizeToContentsX()
            p:DockMargin(16, 0, 16, 0)
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

        -- help button
        vgui("DButton", function(p)
            p:SetFont('marlett')
            p:SetText('s')
            p.Paint = SS_PaintDarkenOnHover
            p:SetColor(SS_ColorWhite)
            p:SetSize(SS_NAVBARHEIGHT, SS_NAVBARHEIGHT)
            p:Dock(RIGHT)

            p.DoClick = function()
                SS_ToggleMenu()
                ShowMotd("https://swamp.sv/points")
            end
        end)

        -- toggle theme button
        vgui("Panel", function(p)
            p:SetSize(SS_NAVBARHEIGHT, SS_NAVBARHEIGHT)
            p:Dock(RIGHT)

            vgui("DImageButton", function(p)
                p:SetImage("icon16/lightbulb.png")
                p:SetStretchToFit(false)
                p.Paint = SS_PaintDarkenOnHover
                p:SetSize(SS_NAVBARHEIGHT / 2, SS_NAVBARHEIGHT)
                p:SetTooltip("Toggle dark mode/light mode")
                p:Dock(RIGHT)

                p.DoClick = function()
                    GetConVar("ps_darkmode"):SetBool(not GetConVar("ps_darkmode"):GetBool()) --activates the callback function
                end
            end)

            vgui("DImageButton", function(p)
                p:SetImage("icon16/rainbow.png")
                p:SetStretchToFit(false)
                p.Paint = SS_PaintDarkenOnHover
                p:SetSize(SS_NAVBARHEIGHT / 2, SS_NAVBARHEIGHT)
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
    end)

    --bottompane
    vgui("DPanel", self, function(p)
        local xo = p:GetWide() + SS_BOTBARHEIGHT
        p:SetTall(SS_BOTBARHEIGHT)
        p:Dock(BOTTOM)
        p.Paint = SS_PaintMD

        vgui("AvatarImage", function(p)
            p:SetPlayer(LocalPlayer(), 184)
            p:SetSize(SS_BOTBARHEIGHT - (SS_COMMONMARGIN * 2), SS_BOTBARHEIGHT - (SS_COMMONMARGIN * 2))
            p:SetPos(SS_COMMONMARGIN, SS_COMMONMARGIN)
        end)

        vgui("DPanel", function(p)
            p:SetWide(300)
            p:DockMargin(SS_BOTBARHEIGHT, 0, 0, 0)
            p:Dock(LEFT)

            p.Paint = function(pnl, w, h)
                draw.SimpleText(string.Comma(LocalPlayer():SS_GetPoints()) .. ' Points', 'SS_POINTSFONT', 4, (h / 2) - 13, MenuTheme_TX, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("Income: " .. tostring(LocalPlayer():SS_Income()) .. ' Points/Minute', 'SS_INCOMEFONT', 4, (h / 2) + 16, MenuTheme_TX, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end)

        PointshopDollarParticlePoints = -0.2
        PointshopDollarParticles = {}

        --big donate button middle
        vgui("DButton", function(p)
            p:SetWide(SS_MENUWIDTH - (xo * 2))
            p:Dock(FILL)
            p:SetFont("SS_INCOMEFONT")
            p:SetText("")

            p.DoClick = function()
                gui.OpenURL('https://swamp.sv/donate/')
            end

            p.Paint = function(self, w, h)
                SS_PaintDarkenOnHover(self, w, h)
                local alpha = 180
                local mousex, mousey = self:CursorPos()
                local distscale = 250
                alpha = math.max(distscale - (Vector(mousex, mousey, 0):Distance(Vector(w / 2, h / 2, 0))), 0) / distscale
                PointshopDollarParticlePoints = PointshopDollarParticlePoints + (RealFrameTime() * math.max(alpha, 0.02))
                local ytop = -20
                local yfade = 32

                while PointshopDollarParticlePoints > 0 do
                    local sc = math.Rand(0.6, 2.4)

                    table.insert(PointshopDollarParticles, {
                        x = math.Rand(0, w),
                        y = ytop,
                        speed = sc * 30,
                        scale = sc,
                        sinmag = math.Rand(0, 20),
                        sinfreq = math.Rand(1, 2),
                        sinofs = math.Rand(0, 6.3),
                        material = pointshopDollarImage
                    })

                    PointshopDollarParticlePoints = PointshopDollarParticlePoints - 0.12
                end

                for k, v in pairs(PointshopDollarParticles) do
                    v.y = v.y + (RealFrameTime() * v.speed)

                    if v.y > h + 50 then
                        table.remove(PointshopDollarParticles, k)
                    else
                        surface.SetDrawColor(220, 220, 220, math.floor(255 * math.min(1, math.min(v.y - ytop, h - v.y) / yfade)))
                        surface.SetMaterial(v.material)
                        local iw = math.floor(8 * v.scale) * 2
                        local ih = math.floor(8 * v.scale) * 2
                        surface.DrawTexturedRect(math.floor((v.sinmag * math.sin(v.sinofs + (RealTime() * v.sinfreq))) + v.x - (iw / 2)), math.floor(v.y - (ih / 2)), iw, ih)
                    end
                end

                local tc = MenuTheme_TX
                --[[if self:IsHovered() then
                tc = Color(175,230,69)
            end]]
                draw.SimpleText('Need more points?', 'SS_Donate1', w / 2, (h / 2) - 20, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText('Click here to donate!', 'SS_Donate2', w / 2, (h / 2) + 20, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end)

        vgui("DPanel", function(p)
            --draw.SimpleText('Need more points?', 'SS_Donate1', w/2, (h/2)-20, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            p:SetWide(SS_RPANEWIDTH)
            p:Dock(RIGHT)
            p:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
            --p:DockPadding(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
            p.Paint = function() end

            vgui('DButton', function(p)
                p:SetText("Give Points")
                p:SetTextColor(MenuTheme_TX)
                --p:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
                p:Dock(BOTTOM)
                p.Paint = SS_PaintButtonBrandHL

                p.DoClick = function()
                    vgui.Create('DPointShopGivePoints')
                end
            end)
        end)
    end)

    --preview pane
    SS_PREVPANE = vgui("DPanel", self, function(p)
        p:SetWide(SS_RPANEWIDTH)
        p:Dock(RIGHT)
        p:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
        p.Paint = SS_PaintFG
        SS_PreviewPane = p

        vgui("DPointShopPreview", function(p)
            p:Dock(FILL)

            SS_DescriptionPanel = vgui("DPanel", function(p)
                p:Dock(BOTTOM)
                p:SetTall(1)
                p:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)

                p.Think = function()
                    SS_DescriptionPanel:InvalidateParent()
                    SS_DescriptionPanel:InvalidateLayout()
                    SS_DescriptionPanel:SizeToChildren(false, true)
                    SS_DescriptionPanel:PerformLayout()
                end

                p.Paint = noop
            end)
        end)
    end)

    --lpane
    self.lpane = vgui("DPanel", self, function(p)
        p:Dock(FILL)
        p.Paint = noop
    end)

    local btns = {}
    local firstCat = true

    local function NewCategory(catname, icon, align)
        local panel = vgui.Create('DPanel', self.lpane)
        panel:Dock(FILL)
        panel:DockMargin(SS_COMMONMARGIN, 0, 0, SS_COMMONMARGIN)
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
            p:DockMargin(0, SS_COMMONMARGIN, 0, 0)
            p.VBar:DockMargin(0, 0, 0, 0)
            p.VBar:SetWide(SS_SCROLL_WIDTH)
            SS_SetupVBar(p.VBar)

            --the pretty layout kinda just breaks when you take away the scroll bar so let's just leave it there
            function p.VBar:SetUp(_barsize_, _canvassize_)
                self.BarSize = _barsize_
                self.CanvasSize = math.max(_canvassize_ - _barsize_, 0)
                self:SetEnabled(true)
                self.btnGrip:SetEnabled(_canvassize_ > _barsize_)
                self:InvalidateLayout()
            end
        end)

        local btn = vgui.Create("DButton", self.navbar)
        btn:Dock(align or LEFT)
        btn:SetText(catname)
        btn:SetFont("SS_Category")
        btn:SetImage(icon)

        btn.Paint = function(pnl, w, h)
            if pnl:GetActive() then
                surface.SetDrawColor(Color(0, 0, 0, 192))
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

            if IsValid(SS_SelectedPanel) then
                SS_SelectedPanel:Deselect()
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
        padcnt = padcnt + 30
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

        for _, LAYOUT in ipairs(CATEGORY.layout) do
            if (#LAYOUT.products > 0) then
                --we cap off previous ones here
                if (first) then
                    first = false
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
        end
    end

    SS_InventoryPanel = NewCategory("Inventory", 'icon16/basket.png', RIGHT)
    SS_ValidInventory = false

    function SS_InventoryPanel:Think()
        if not SS_ValidInventory then
            -- if #self:GetCanvas():GetChildren() > 0 then
            local scroll2 = self:GetVBar():GetScroll()

            for k, v in pairs(self:GetCanvas():GetChildren()) do
                v:Remove()
            end

            -- return
            -- end
            -- print("Items reloading")
            local itemstemp = table.Copy(LocalPlayer():SS_GetInventory())

            table.sort(itemstemp, function(a, b)
                local i = 0
                local ml = math.min(string.len(a.name), string.len(b.name))

                while i < ml do
                    i = i + 1
                    local a1 = string.byte(a.name, i)
                    local b1 = string.byte(b.name, i)
                    if a1 ~= b1 then return a1 < b1 end
                end

                if string.len(a.name) == string.len(b.name) then return a.id < b.id end

                return string.len(a.name) > string.len(b.name)
            end)

            PrintTable(itemstemp)

            for k, v in pairs(SS_Items) do
                if (v.always_have) then
                    local copy = table.Copy(v)
                    copy.cfg = {}
                    table.insert(itemstemp, copy)
                end
            end

            local categorizeditems = {}

            for _, item in pairs(itemstemp) do
                local invcategory = item.invcategory or "Other"
                categorizeditems[invcategory] = categorizeditems[invcategory] or {}
                table.insert(categorizeditems[invcategory], item)
            end

            local first = true

            for _, cat in ipairs(SS_InvCategories) do
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

            self:InvalidateLayout()
            SS_ValidInventory = true

            timer.Simple(0, function()
                self:GetVBar():SetScroll(scroll2)
            end)
        end
    end

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

function PANEL:Paint(w, h)
    Derma_DrawBackgroundBlur(self)
    SS_PaintBG(self, w, h)
end

SS_INVENTORY_POINT_OUT = -100

function PANEL:PaintOver(w, h)
    local a = math.min(5.0 - ((RealTime() - SS_INVENTORY_POINT_OUT) * 1.0), 1.0, (RealTime() - SS_INVENTORY_POINT_OUT) * 4.0)

    if a > 0 then
        surface.DisableClipping(true)
        draw.SimpleText("access new items here", "DermaLarge", w - 184, -30, Color(255, 255, 255, 255 * a), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText("↓", "SS_LargeTitle", w - 164, (math.sin(RealTime() * 6.0) * 5.0) - 20.0, Color(255, 255, 255, 255 * a), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        surface.DisableClipping(false)
    end
end

function PANEL:OnRemove()
    SS_ValidInventory = false
end

vgui.Register('DPointShopMenu', PANEL, "EditablePanel")