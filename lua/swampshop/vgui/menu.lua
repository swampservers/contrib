-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
surface.CreateFont('SS_Heading', {
    font = 'coolvetica',
    size = 64
})

surface.CreateFont('SS_Heading2', {
    font = 'coolvetica',
    size = 24
})

surface.CreateFont('SS_Heading3', {
    font = 'coolvetica',
    size = 19
})

surface.CreateFont('SS_Heading4', {
    font = 'Arial',
    size = 14
})

surface.CreateFont('SS_POINTSFONT', {
    font = 'Righteous',
    size = 42
})

surface.CreateFont('SS_INCOMEFONT', {
    font = 'Lato',
    size = 22
})

surface.CreateFont('SS_JOINFONT', {
    font = 'Lato',
    size = 18
})

surface.CreateFont('SS_DESCTITLEFONT', {
    font = 'Righteous',
    size = 32
})

surface.CreateFont('SS_DESCFONT', {
    font = 'Lato',
    size = 18
})

surface.CreateFont('SS_DESCINSTFONT', {
    font = 'Lato',
    size = 20
})

pointshopDollarImage = Material("icon16/money_dollar.png")
pointshopMoneyImage = Material("icon16/money.png")

surface.CreateFont("SS_Default", {
    font = system.IsLinux() and "Arial" or "Tahoma",
    size = 13,
    weight = 500,
    antialias = true,
})

surface.CreateFont("SS_Donate1", {
    font = "Roboto",
    size = 36,
    weight = 800,
    antialias = true,
})

surface.CreateFont("SS_Donate2", {
    font = "Roboto",
    size = 28,
    weight = 800,
    antialias = true,
})

surface.CreateFont("SS_Models", {
    font = "Roboto",
    size = 24,
    weight = 800,
    antialias = true,
})

surface.CreateFont("SS_DefaultBold", {
    font = system.IsLinux() and "Arial" or "Tahoma",
    size = 13,
    weight = 800,
    antialias = true,
})

surface.CreateFont("SS_Heading1", {
    font = system.IsLinux() and "Arial" or "Tahoma",
    size = 18,
    weight = 500,
    antialias = true,
})

surface.CreateFont("SS_Heading1Bold", {
    font = system.IsLinux() and "Arial" or "Tahoma",
    size = 18,
    weight = 800,
    antialias = true,
})

surface.CreateFont("SS_ButtonText1", {
    font = "Roboto",
    size = 22,
    weight = 700,
    antialias = true,
})

surface.CreateFont("SS_ItemText", {
    font = system.IsLinux() and "Arial" or "Tahoma",
    size = 11,
    weight = 500,
    antialias = true,
})

surface.CreateFont("SS_LargeTitle", {
    font = "Righteous",
    size = 48,
    weight = 900,
    antialias = true,
})

surface.CreateFont("SS_SubCategory", {
    font = "Righteous",
    size = 36,
})

surface.CreateFont('SS_ProductName', {
    font = 'Lato',
    size = 17
})

surface.CreateFont("SS_Price", {
    font = "Righteous",
    size = 31,
    weight = 900,
    antialias = true,
})

surface.CreateFont("SS_Category", {
    font = "Lato",
    size = 18,
    weight = 200,
    antialias = true,
})

local ALL_ITEMS = 1
local OWNED_ITEMS = 2
local UNOWNED_ITEMS = 3
SS_ColorWhite = Color(255, 255, 255)
SS_ColorBlack = Color(0, 0, 0)

SS_PaintTileBG = function(pnl, w, h)
    surface.SetDrawColor(SS_TileBGColor)
    surface.DrawRect(0, 0, w, h)
end

SS_PaintGridBG = function(pnl, w, h)
    surface.SetDrawColor(SS_GridBGColor)
    surface.DrawRect(0, 0, w, h)
end

SS_PaintDarkenOnHover = function(pnl, w, h)
    if pnl:IsHovered() then
        surface.SetDrawColor(Color(0, 0, 0, 100))
        surface.DrawRect(0, 0, w, h)
    end
end

local PANEL = {}
SS_MENUWIDTH = 1203
SS_MENUHEIGHT = 808
SS_NAVBARHEIGHT = 56
SS_BOTBARHEIGHT = 88
SS_RPANEWIDTH = 360
SS_PREVIEWHEIGHT = 470
SS_TILESIZE = 156
SS_AVATARPAD = 5
SS_INVENTORY_POINT_OUT = -100

net.Receive("SS_PointOutInventory", function()
    SS_INVENTORY_POINT_OUT = RealTime()
end)

function PANEL:Init()
    self:SetSize(math.Clamp(SS_MENUWIDTH, 0, ScrW()), math.Clamp(SS_MENUHEIGHT, 0, ScrH()))
    self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2))
    self.navbar = vgui.Create("DPanel", self)
    self.navbar:SetTall(SS_NAVBARHEIGHT)
    self.navbar:Dock(TOP)
    self.navbar:SetBackgroundColor(BrandColorAlternate)
    self.botbar = vgui.Create("DPanel", self)
    self.botbar:SetTall(SS_BOTBARHEIGHT)
    self.botbar:Dock(BOTTOM)
    self.botbar:SetBackgroundColor(SS_BotBGColor)
    self.rpane = vgui.Create('DPanel', self)
    self.rpane:SetWide(SS_RPANEWIDTH)
    self.rpane:Dock(RIGHT)
    self.rpane:SetBackgroundColor(SS_TileBGColor)
    SS_PreviewPane = self.rpane
    self.lpane = vgui.Create('DPanel', self)
    self.lpane:Dock(FILL)
    self.lpane:SetBackgroundColor(SS_GridBGColor)
    local p = vgui.Create("DLabel", self.navbar)
    p:SetText("TOY SHOβ")
    p:SetFont('SS_LargeTitle')
    p:SizeToContentsX()
    p:DockMargin(16, 0, 16, 0)
    p:SetColor(SS_ColorWhite)
    --p:SetPaintBackground(false)
    p:Dock(LEFT)
    -- close button
    p = vgui.Create('DButton', self.navbar)
    p:SetFont('marlett')
    p:SetText('r')
    p.Paint = SS_PaintDarkenOnHover
    p:SetColor(SS_ColorWhite)
    p:SetSize(SS_NAVBARHEIGHT, SS_NAVBARHEIGHT)
    p:Dock(RIGHT)

    p.DoClick = function()
        SS_ToggleMenu()
    end

    -- help button
    p = vgui.Create('DButton', self.navbar)
    p:SetFont('marlett')
    p:SetText('s')
    p.Paint = SS_PaintDarkenOnHover
    p:SetColor(SS_ColorWhite)
    p:SetSize(SS_NAVBARHEIGHT, SS_NAVBARHEIGHT)
    p:Dock(RIGHT)

    p.DoClick = function()
        SS_ToggleMenu()
        ShowMotd("https://swampservers.net/points")
    end

    -- toggle theme button
    p = vgui.Create('DImageButton', self.navbar)
    p:SetImage("icon16/lightbulb.png")
    p:SetStretchToFit(false)
    p.Paint = SS_PaintDarkenOnHover
    p:SetSize(SS_NAVBARHEIGHT, SS_NAVBARHEIGHT)
    p:SetTooltip("Toggle dark mode/light mode")
    p:Dock(RIGHT)

    p.DoClick = function()
        GetConVar("ps_darkmode"):SetBool(not SS_DarkMode) --activates the callback function
    end

    local btns = {}
    local firstCat = true

    local function NewCategory(catname, icon, align)
        local panel = vgui.Create('DPanel', self.lpane)
        panel:Dock(FILL)
        panel.Paint = function() end

        if firstCat then
            panel:SetZPos(100)
            panel:SetVisible(true)
        else
            panel:SetZPos(1)
            panel:SetVisible(false)
        end

        local DScrollPanel = vgui.Create('DScrollPanel', panel)
        DScrollPanel:Dock(FILL)
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
            pnl:SetTextColor(SS_ColorWhite)
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

    local function NewSubCategoryTitle(DScrollPanel, txt)
        local p2 = vgui.Create("DPanel", DScrollPanel)
        p2:Dock(TOP)
        p2:SetPaintBackground(true)

        p2.Paint = function(p, w, h)
            surface.SetDrawColor(SS_TileBGColor)
            surface.DrawRect(0, 0, w, h)
        end

        p2:DockMargin(8, 8, 8, 0)
        local p = vgui.Create("DLabel", p2)
        p:SetText(txt)
        p:SetFont('SS_SubCategory')
        p:Dock(TOP)
        local lp = 2
        p:DockMargin(lp * 2, lp, lp, lp)
        p:SetColor(SS_SwitchableColor)
        p:SizeToContentsY()
        p2:SetTall(p:GetTall() + lp * 2)
    end

    local function NewSubCategory(DScrollPanel)
        local ShopCategoryTabLayout = vgui.Create('DIconLayout', DScrollPanel)
        ShopCategoryTabLayout:DockMargin(8, 8, 0, 0)
        ShopCategoryTabLayout:Dock(TOP)
        ShopCategoryTabLayout:SetBorder(0)
        ShopCategoryTabLayout:SetSpaceX(8)
        ShopCategoryTabLayout:SetSpaceY(8)
        DScrollPanel:AddItem(ShopCategoryTabLayout)

        return ShopCategoryTabLayout
    end

    local function FinishCategory(DScrollPanel)
        local pad = vgui.Create('DPanel', DScrollPanel)
        pad.Paint = function() end
        pad:SetTall(8)
        pad:Dock(TOP)
        DScrollPanel:AddItem(pad)
    end

    -- items
    for _, CATEGORY in pairs(SS_Layout) do
        local cat = NewCategory(CATEGORY.name, 'icon16/' .. CATEGORY.icon .. '.png')

        for _, LAYOUT in pairs(CATEGORY.layout) do
            if LAYOUT.title then
                NewSubCategoryTitle(cat, LAYOUT.title)
            end

            local scat = NewSubCategory(cat)

            for _, PRODUCT in pairs(LAYOUT.products) do
                pdata = SS_Products[PRODUCT]

                if pdata == nil then
                    print("Undefined product: " .. PRODUCT)
                    continue
                end

                local model = vgui.Create('DPointShopItem')
                model:SetProduct(pdata)
                model:SetSize(SS_TILESIZE, SS_TILESIZE)
                scat:Add(model)
            end
        end

        FinishCategory(cat)
    end

    SS_InventoryPanel = NewCategory("My Inventory", 'icon16/basket.png', RIGHT)
    SS_ValidInventory = false

    function SS_InventoryPanel:Think()
        if not SS_ValidInventory then
            if #self:GetCanvas():GetChildren() > 0 then
                for k, v in pairs(self:GetCanvas():GetChildren()) do
                    v:Remove()
                end

                return
            end

            print("Items reloading")
            local itemstemp = LocalPlayer().SS_Items or {}

            table.sort(itemstemp, function(a, b)
                local a2 = a
                local b2 = b
                a = a.class
                b = b.class

                if SS_Items[a] then
                    a = SS_Items[a].name
                end

                if SS_Items[b] then
                    b = SS_Items[b].name
                end

                local i = 0
                local ml = math.min(string.len(a), string.len(b))

                while i < ml do
                    i = i + 1
                    local a1 = string.byte(a, i)
                    local b1 = string.byte(b, i)
                    if a1 ~= b1 then return a1 < b1 end
                end

                if string.len(a) == string.len(b) then return a2.id < b2.id end

                return string.len(a) > string.len(b)
            end)

            categorizeditems = {}

            for _, ITEM in pairs(itemstemp) do
                pdata = SS_Items[ITEM.class]
                if pdata == nil then continue end --print("Undefined item: "..ITEM.class)
                local invcategory = pdata.invcategory or "Other"
                categorizeditems[invcategory] = categorizeditems[invcategory] or {}
                table.insert(categorizeditems[invcategory], ITEM)
            end

            for _, cat in ipairs(SS_InvCategories) do
                if categorizeditems[cat] then
                    NewSubCategoryTitle(self, cat)
                    local sc = NewSubCategory(self)

                    for _, ITEM in pairs(categorizeditems[cat]) do
                        local model = vgui.Create('DPointShopItem')
                        model:SetItem(SS_Items[ITEM.class], ITEM)
                        model:SetSize(SS_TILESIZE, SS_TILESIZE)
                        sc:Add(model)
                    end
                end
            end

            FinishCategory(self)
            self:InvalidateLayout()
            SS_ValidInventory = true
        end
    end

    SS_CustomizerPanel = vgui.Create('DPointShopCustomizer', SS_InventoryPanel:GetParent():GetParent():GetParent())
    SS_CustomizerPanel:Dock(FILL)
    SS_CustomizerPanel:Close()
    local previewpanel = vgui.Create('DPointShopPreview', self.rpane)
    previewpanel:SetTall(SS_PREVIEWHEIGHT)
    previewpanel:Dock(TOP)
    --- Drag Rotate
    previewpanel.Angles = Angle(0, 0, 0)
    previewpanel.ZoomOffset = 0

    function previewpanel:OnMouseWheeled(amt)
        self.ZoomOffset = self.ZoomOffset + (amt > 0 and 1 or -1)
    end

    function previewpanel:DragMousePress(btn)
        self.PressButton = btn
        self.PressX, self.PressY = gui.MousePos()
        self.Pressed = true
    end

    function previewpanel:DragMouseRelease()
        self.Pressed = false
        self.lastPressed = RealTime()
    end

    function previewpanel:LayoutEntity(thisEntity)
        if (self.bAnimated) then
            self:RunAnimation()
        end

        if (self.Pressed) then
            local mx, my = gui.MousePos()

            --self.Angles = self.Angles - Angle( ( self.PressY or my ) - my, ( self.PressX or mx ) - mx, 0 )
            if self.PressButton == MOUSE_LEFT then
                if SS_CustomizerPanel:IsVisible() then
                    local ang = (self:GetLookAt() - self:GetCamPos()):Angle()
                    self.Angles:RotateAroundAxis(ang:Up(), (mx - (self.PressX or mx)) * 0.6)
                    self.Angles:RotateAroundAxis(ang:Right(), (my - (self.PressY or my)) * 0.6)
                    self.SPINAT = 0
                else
                    self.Angles.y = self.Angles.y + ((mx - (self.PressX or mx)) * 0.6)
                end
            end

            if self.PressButton == MOUSE_RIGHT then
                if SS_CustomizerPanel:IsVisible() then
                    if ValidPanel(XRSL) then
                        if IsValid(SS_HoverCSModel) then
                            clang = Angle(XRSL:GetValue(), YRSL:GetValue(), ZRSL:GetValue())
                            clangm = Matrix()
                            clangm:SetAngles(clang)
                            clangm:Invert()
                            clangi = clangm:GetAngles()
                            cgang = SS_HoverCSModel:GetAngles()
                            crangm = Matrix()
                            crangm:SetAngles(cgang)
                            crangm:Rotate(clangi)
                            rootang = V
                            ngang = Angle()
                            ngang:Set(cgang)
                            local ang = (self:GetLookAt() - self:GetCamPos()):Angle()
                            ngang:RotateAroundAxis(ang:Up(), (mx - (self.PressX or mx)) * 0.3)
                            ngang:RotateAroundAxis(ang:Right(), (my - (self.PressY or my)) * 0.3)
                            ngangm = Matrix()
                            ngangm:SetAngles(ngang)
                            crangm:Invert()
                            nlangm = crangm * ngangm
                            nlang = nlangm:GetAngles()
                            print(nlang)
                            XRSL:SetValue(nlang.x)
                            YRSL:SetValue(nlang.y)
                            ZRSL:SetValue(nlang.z)
                        end
                    end
                end
            end

            self.PressX, self.PressY = gui.MousePos()
        end

        if (RealTime() - (self.lastPressed or 0)) < (self.SPINAT or 0) or self.Pressed or SS_CustomizerPanel:IsVisible() then
            thisEntity:SetAngles(self.Angles)

            if not SS_CustomizerPanel:IsVisible() then
                self.SPINAT = 4
            end
        else
            self.Angles.y = math.NormalizeAngle(self.Angles.y + (RealFrameTime() * 21))
            self.Angles.x = 0
            self.Angles.z = 0
            thisEntity:SetAngles(self.Angles)
        end
    end

    SS_DescriptionPanel = vgui.Create('DPanel', self.rpane)
    SS_DescriptionPanel:Dock(FILL)
    SS_DescriptionPanel.Paint = function() end
    p = vgui.Create("AvatarImage", self.botbar)
    p:SetPlayer(LocalPlayer(), 184)
    p:SetSize(SS_BOTBARHEIGHT - (SS_AVATARPAD * 2), SS_BOTBARHEIGHT - (SS_AVATARPAD * 2))
    p:SetPos(SS_AVATARPAD, SS_AVATARPAD)
    p = vgui.Create("DPanel", self.botbar)
    p:SetWide(300)
    p:DockMargin(SS_BOTBARHEIGHT, 0, 0, 0)
    p:Dock(LEFT)

    p.Paint = function(pnl, w, h)
        draw.SimpleText(string.Comma(LocalPlayer():SS_GetPoints()) .. ' Points', 'SS_POINTSFONT', 4, (h / 2) - 13, SS_ColorWhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Income: " .. tostring(SS_Income(LocalPlayer())) .. ' Points/Minute', 'SS_INCOMEFONT', 4, (h / 2) + 16, SS_ColorWhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local xo = p:GetWide() + SS_BOTBARHEIGHT

    if LocalPlayer().HasHalfPoints then
        p = vgui.Create("DButton", self)
        p:SetZPos(1000)
        p:SetPos(6, self:GetTall() - (52 + SS_BOTBARHEIGHT))
        p:SetSize(200, 48)
        p:SetWrap(true)
        p:SetTextInset(16, 0)
        p:SetFont("SS_JOINFONT")
        p:SetText("Click here to join our Steam group for double income!")

        p.UpdateColours = function(pnl)
            pnl:SetTextColor(SS_ColorBlack)
        end

        p.Think = function(pnl)
            if not LocalPlayer().HasHalfPoints then
                pnl:Remove()
            end
        end

        p.DoClick = function()
            gui.OpenURL('https://steamcommunity.com/groups/swampservers')
        end
    end

    PointshopDollarParticlePoints = -0.2
    PointshopDollarParticles = {}
    p = vgui.Create("DButton", self.botbar)
    p:SetWide(SS_MENUWIDTH - (xo * 2))
    p:Dock(LEFT)
    p:SetFont("SS_INCOMEFONT")
    p:SetText("")

    p.DoClick = function()
        gui.OpenURL('https://swampservers.net/donate/')
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

        local tc = SS_ColorWhite
        --[[if self:IsHovered() then
			tc = Color(175,230,69)
		end]]
        draw.SimpleText('Need more points?', 'SS_Donate1', w / 2, (h / 2) - 20, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText('Click here to donate!', 'SS_Donate2', w / 2, (h / 2) + 20, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    --draw.SimpleText('Need more points?', 'SS_Donate1', w/2, (h/2)-20, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    local cont = vgui.Create("DPanel", self.botbar)
    cont:SetWide(SS_RPANEWIDTH)
    cont:Dock(RIGHT)
    cont.Paint = function() end
    -- give points button
    p = vgui.Create('DButton', cont)
    p:SetText("Give Points")
    p:SetTextColor(SS_SwitchableColor)
    p:DockMargin(12, 12, 12, 12)
    p:Dock(BOTTOM)

    p.Paint = function(panel, w, h)
        if panel.Depressed then
            panel:SetTextColor(SS_ColorWhite)
            draw.RoundedBox(4, 0, 0, w, h, BrandColorAlternate)
        else
            panel:SetTextColor(SS_SwitchableColor)
            draw.RoundedBox(4, 0, 0, w, h, SS_TileBGColor)
        end
    end

    p.DoClick = function()
        vgui.Create('DPointShopGivePoints')
    end

    p = vgui.Create('DButton', cont)

    p.Think = function(p)
        if LocalPlayer():IsPony() then
            p:SetText("Customize Pony")
        elseif LocalPlayer():GetModel() == "models/milaco/minecraft_pm/minecraft_pm.mdl" then
            p:SetText("Customize Minecraft Skin")
        else
            p:SetText("Customize Playermodel")
        end
    end

    p:SetTextColor(SS_SwitchableColor)
    p:DockMargin(12, 12, 12, 12)
    p:Dock(TOP)

    p.Paint = function(panel, w, h)
        if panel.Depressed then
            panel:SetTextColor(SS_ColorWhite)
            draw.RoundedBox(4, 0, 0, w, h, BrandColorAlternate)
        else
            panel:SetTextColor(SS_SwitchableColor)
            draw.RoundedBox(4, 0, 0, w, h, SS_TileBGColor)
        end
    end

    p.DoClick = function()
        SS_ToggleMenu()

        if LocalPlayer():IsPony() then
            RunConsoleCommand("ppm_chared3")
        elseif LocalPlayer():GetModel() == "models/milaco/minecraft_pm/minecraft_pm.mdl" then
            local mderma = Derma_StringRequest("Minecraft Skin Picker", "Enter an Imgur URL to change your Minecraft skin.", "", function(text)
                RunConsoleCommand("say", "!minecraftskin " .. text)
            end, function() end, "Change Skin", "Cancel")

            local srdx, srdy = mderma:GetSize()
            local mdermacredits = Label("Minecraft Skins by Milaco and Chev for Swamp Servers", mderma)
            mdermacredits:Dock(BOTTOM)
            mdermacredits:SetContentAlignment(2)
            mderma:SetSize(srdx, srdy + 15)
            mderma:SetIcon("icon16/user.png")
        else
            RunConsoleCommand("customize")
        end
    end
end

--[[
local function BuildItemMenu(menu, ply, itemstype, callback)
	local plyitems = ply:SS_GetItems()
	
	for category_id, CATEGORY in pairs(SS_Layout) do
		
		local catmenu = menu:AddSubMenu(CATEGORY.Name)
		
		for item_id, ITEM in pairs(SS_Items) do
			if ITEM.Category == CATEGORY.Name then
				if itemstype == ALL_ITEMS or (itemstype == OWNED_ITEMS and plyitems[item_id]) or (itemstype == UNOWNED_ITEMS and not plyitems[item_id]) then
					catmenu:AddOption(ITEM.Name, function() callback(item_id) end)
				end
			end
		end
	end
end
]]
--[[
only used by admin area
function PANEL:Think()
	if self.ClientsList then
		local lines = self.ClientsList:GetLines()
		
		for _, ply in pairs(player.GetAll()) do
			local found = false
			
			for _, line in pairs(lines) do
				if line.Player == ply then
					found = true
				end
			end
			
			if not found then
				self.ClientsList:AddLine(ply:GetName(), ply:SS_GetPoints(), table.Count(ply:SS_GetItems())).Player = ply
			end
		end
		
		for i, line in pairs(lines) do
			if IsValid(line.Player) then
				local ply = line.Player
				
				line:SetValue(1, ply:GetName())
				line:SetValue(2, ply:SS_GetPoints())
				line:SetValue(3, table.Count(ply:SS_GetItems()))
			else
				self.ClientsList:RemoveLine(i)
			end
		end
	end
end
]]
function PANEL:Paint(w, h)
    Derma_DrawBackgroundBlur(self)
end

function PANEL:PaintOver(w, h)
    local a = math.min(5.0 - ((RealTime() - SS_INVENTORY_POINT_OUT) * 1.0), 1.0, (RealTime() - SS_INVENTORY_POINT_OUT) * 4.0)

    if a > 0 then
        surface.DisableClipping(true)
        draw.SimpleText("access new items here", "DermaLarge", w - 184, -30, Color(255, 255, 255, 255 * a), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText("↓", "SS_LargeTitle", w - 164, (math.sin(RealTime() * 6.0) * 5.0) - 20.0, Color(255, 255, 255, 255 * a), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        surface.DisableClipping(false)
    end
end

vgui.Register('DPointShopMenu', PANEL)