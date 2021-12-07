-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local PANEL = {}
local froggy = Material("vgui/frog.png")

--NOMINIFY
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

function PANEL:Init()
    SS_ShopMenu = self
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

            p.DoRightClick = function()
                RunConsoleCommand("ps_destroymenu")
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

            -- The fatkid gamemode has a no-moneymaking-allowed license
            -- Of course, I made the gamemode, so I don't have to follow my own license,
            -- but still don't advertise donations to not look like a hypocrite.
            if GAMEMODE.FolderName == "fatkid" then
                p.Paint = noop

                return
            end

            p.DoClick = function()
                gui.OpenURL('https://swamp.sv/donate/')
            end

            local DollarParticlePoints = -0.2
            local DollarParticles = {}

            p.Paint = function(self, w, h)
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
                draw.SimpleText('Need more points?', 'SS_Donate1', w - 180, (h / 2) - 18 + 2, tc, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                draw.SimpleText('Click here to donate!', 'SS_Donate2', w - 180, (h / 2) + 18 + 8, tc, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end)
    end)

    local unopened = true

    local function MakeCategoryButton(cat, catname, icon, inv, dock)
        vgui("DButton", inv and self.invbar or self.topbar, function(p)
            p.ModePanel = cat
            p:Dock(dock or LEFT)
            p:SetText(catname)
            p:SetFont("SS_Category")
            p:SetImage(icon)
            p:SetTextColor(BrandColorWhite)

            function p:Paint(w, h)
                if SS_ActiveMode == self.ModePanel then
                    surface.SetDrawColor(Color(0, 0, 0, 144))
                    surface.DrawRect(0, 0, w, h)
                else
                    SS_PaintDarkenOnHover(self, w, h)
                end
            end

            function p:PerformLayout()
                self:SizeToContents()
                self:SetWide(self:GetWide() + 24)
                self:SetTall(self:GetParent():GetTall())
                DLabel.PerformLayout(self)
                local txt_inset = -8
                self.m_Image:SetSize(16, 16)
                self.m_Image:SetPos((self:GetWide() - 16) * 0.5, self:GetTall() + txt_inset - (16 + 20))
                self:SetContentAlignment(2)
                self:SetTextInset(0, txt_inset)
            end

            function p:DoClick()
                p.ModePanel:Open()
            end
        end)

        if unopened then
            unopened = false
            cat:Open()
        end
    end

    --whole page contents
    self.mainpane = vgui("DPanel", self, function(p)
        p:DockPadding(SS_COMMONMARGIN, 0, SS_COMMONMARGIN, 0)
        p:Dock(FILL)
        p.Paint = noop

        SS_PreviewPane = vgui("DPointShopPreview", function(p)
            p:SetWide(SS_RPANEWIDTH)
            p:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, 0, SS_COMMONMARGIN)
            p:Dock(RIGHT)

            SS_DescriptionPanel = vgui("DPanel", function(p)
                p:Dock(BOTTOM)
                p:SetTall(1)

                p.PerformLayout = function()
                    SS_DescriptionPanel:InvalidateParent()
                    SS_DescriptionPanel:SizeToChildren(false, true)
                end

                p.Paint = noop
            end)
        end)
    end)

    for _, CATEGORY in ipairs(SS_Layout) do
        vgui("DSSScrollableMode", self.mainpane, function(p)
            for _, LAYOUT in ipairs(CATEGORY.layout) do
                if LAYOUT.title then
                    vgui("DSSSubtitle", function(p)
                        p:SetText(LAYOUT.title)
                    end)
                end

                if #LAYOUT.products > 0 then
                    vgui("DSSTileGrid", function(p)
                        for _, product in ipairs(LAYOUT.products) do
                            p:AddProduct(product)
                        end
                    end)
                end

                if LAYOUT.constructor then
                    LAYOUT.constructor(p)
                end
            end

            MakeCategoryButton(p, CATEGORY.name, 'icon16/' .. CATEGORY.icon .. '.png')
        end)
    end

    SS_AuctionPanel = vgui("DSSAuctionMode", self.mainpane)
    MakeCategoryButton(SS_AuctionPanel, "Auctions", 'icon16/house.png')

    vgui("DSSInventoryMode", self.mainpane, function(p)
        p:SetCategories({"Weapons", "Skins"})

        MakeCategoryButton(p, "Weapons", 'icon16/gun.png', true)
    end)

    vgui("DSSInventoryMode", self.mainpane, function(p)
        p:SetCategories({"Props"})

        MakeCategoryButton(p, "Props", 'icon16/book.png', true)
    end)

    vgui("DSSInventoryMode", self.mainpane, function(p)
        p:SetCategories({"Playermodels", "Accessories", "Mods", "Upgrades", "Other"})

        MakeCategoryButton(p, "Cosmetics", 'icon16/status_online.png', true)
    end)

    vgui('DSSCustomizerMode', self.mainpane)

    vgui("DSSPlayerSettingsMode", self.mainpane, function(p)
        MakeCategoryButton(p, "Titles", 'icon16/rosette.png', false, RIGHT)
    end)

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
    --Derma_DrawBackgroundBlur(self)
    DisableClipping(true)
    local border = 8
    draw.BoxShadow(-2, -2, w + 4, h + 4, border, 1)
    DisableClipping(false)
    SS_PaintBG(self, w, h)
end

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
    local a = math.min(5.0 - ((RealTime() - (SS_INVENTORY_POINT_OUT or -100)) * 1.0), 1.0, (RealTime() - (SS_INVENTORY_POINT_OUT or -100)) * 4.0)

    if a > 0 then
        surface.DisableClipping(true)
        draw.SimpleText("access new items here", "DermaLarge", w / 2 + 5, h + 12, Color(255, 255, 255, 255 * a), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("↑", "SS_LargeTitle", w / 2 - 20, h + (math.sin(RealTime() * 6.0) * 5.0), Color(255, 255, 255, 255 * a), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.DisableClipping(false)
    end
end

vgui.Register('DSSMenu', PANEL, "EditablePanel")
