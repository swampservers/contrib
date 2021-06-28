-- This file is subject to copyright - contact swampservers@gmail.com for more information.

BrandColorGrayDarker = Color(32, 32, 32) --(26, 30, 38)
BrandColorGrayDark = Color(48, 48, 48) --(38, 41, 49)
BrandColorGray = Color(69, 69, 69)
BrandColorGrayLight = Color(144, 144, 144)
BrandColorGrayLighter = Color(180, 180, 180)

BrandColorWhite = Color(255, 255, 255)

BrandColorPrimary = Color(104, 28, 25)
BrandColorAlternate = Color(40, 96, 104) --Color(36, 56, 26) --Color(40, 96, 104)

BrandColors = {
    Color(104, 28, 25),
    Color(40, 96, 104),
    Color(91, 40, 104),
    Color(27, 100, 43),
    Color(192, 90, 23),
    Color(187, 162, 78),
} 

CreateClientConVar("ps_darkmode", "0", true)
CreateClientConVar("ps_themecolor", "1", true)

local function SearchUpdateColors(pnl)
    
    if(pnl.UpdateColours)then pnl:UpdateColours(pnl:GetSkin()) end
    for k,v in pairs(pnl:GetChildren()) do 
    SearchUpdateColors(v)
    end
end


function ReloadStyle(darkmode,color)
    darkmode = darkmode or GetConVar("ps_darkmode"):GetBool()
    color = color or GetConVar("ps_themecolor"):GetInt()

    MenuTheme_Brand = BrandColors[color] or BrandColors[2]
    MenuTheme_BrandDark = Color(MenuTheme_Brand.r*0.5,MenuTheme_Brand.g*0.5,MenuTheme_Brand.b*0.5,MenuTheme_Brand.a)
    if darkmode then
        MenuTheme_BG = BrandColorGrayDarker
        MenuTheme_FG = BrandColorGrayDark
        MenuTheme_MD = BrandColorGray
        MenuTheme_TX = Color(200, 200, 200)
    else
        MenuTheme_BG = BrandColorGrayLighter
        MenuTheme_FG = BrandColorWhite 
        MenuTheme_MD = BrandColorGrayLight
        MenuTheme_TX = Color(0, 0, 0)
    end 

    if IsValid(SS_ShopMenu) then
        --SS_ShopMenu:Remove()
        --SS_ToggleMenu()

        SearchUpdateColors(SS_ShopMenu)
    end
end

ReloadStyle()

cvars.AddChangeCallback("ps_darkmode", function(cvar, old, new)
    ReloadStyle(tobool(new))
end)

cvars.AddChangeCallback("ps_themecolor", function(cvar, old, new)
    ReloadStyle(nil,tonumber(new))
end)

SS_ColorWhite = Color(255, 255, 255)
SS_ColorBlack = Color(0, 0, 0)

SS_CORNERCOMMON = 4

--if you want to change how every single rectangle is drawn
SS_GLOBAL_RECT = function(x,y,w,h,color)
    surface.SetDrawColor(color)
    surface.DrawRect(0, 0, w, h)
    --draw.RoundedBox( SS_CORNERCOMMON, 0,0, w,h, color )
end

--extra function if i need a particular visual to stand out for debugging
SS_PaintDirty = function(pnl, w, h)
    surface.SetDrawColor(Color(255,0,255))
    SS_GLOBAL_RECT(0,0,w,h,Color(255,0,255))
end

SS_PaintBrand = function(pnl, w, h)

    SS_GLOBAL_RECT(0,0,w,h,MenuTheme_Brand)
end
SS_PaintBrandDark = function(pnl, w, h)
    SS_GLOBAL_RECT(0,0,w,h,MenuTheme_BrandDark)
end

SS_PaintButtonBrandHL = function(pnl, w, h)
    if pnl.Depressed then
        pnl:SetTextColor(SS_ColorWhite)
        surface.SetDrawColor(MenuTheme_Brand)
        SS_GLOBAL_RECT(0,0,w,h,MenuTheme_Brand)
    else
        pnl:SetTextColor(SS_SwitchableColor)
        SS_GLOBAL_RECT(0,0,w,h,MenuTheme_FG)
    end
end

SS_PaintFG = function(pnl, w, h)
    --surface.SetDrawColor(MenuTheme_FG)
    --surface.DrawRect(0, 0, w, h)
    SS_GLOBAL_RECT(0,0,w,h,MenuTheme_FG)
end 

SS_PaintBG = function(pnl, w, h)
    SS_GLOBAL_RECT(0,0,w,h,MenuTheme_BG)
end
 
SS_PaintTileInset = function(pnl, w, h)
    SS_PaintDiry(0,0,w,h)
end

SS_PaintMD = function(pnl, w, h)
    SS_GLOBAL_RECT(0,0,w,h,MenuTheme_MD)
end

SS_PaintDarkenOnHover = function(pnl, w, h)
    if pnl:IsHovered() then
        SS_GLOBAL_RECT(0,0,w,h,Color(0, 0, 0, 100))
    end
end

SS_PaintShaded = function(pnl, w, h,alpha)
    --surface.SetDrawColor(Color(0, 0, 0, 100))
    --surface.DrawRect(0, 0, w, h)
    SS_GLOBAL_RECT(0,0,w,h,Color(0, 0, 0, alpha or  100))
end

SS_PaintFGAlpha = function(pnl, w, h,alpha)
        --surface.SetDrawColor(Color(0, 0, 0, 100))
        --surface.DrawRect(0, 0, w, h)
        SS_GLOBAL_RECT(0,0,w,h,ColorAlpha(MenuTheme_FG,alpha or 100) )
end 

SS_PaintBrandStripes = function(pnl, w, h)
    surface.SetDrawColor(MenuTheme_Brand)
    surface.DrawRect(0, 0, w, h)

    BrandBackgroundPattern(0, 0, w, h, 0)
end
 
SS_SetupVBar = function(vbar)
    vbar:SetHideButtons(true)
    vbar.btnGrip.Paint = SS_PaintBrand
    vbar.btnUp:SetTall(1) 
    vbar.btnDown:SetTall(1)
    vbar.Paint = SS_PaintFG
end

SS_COMMONMARGIN = 4
SS_SMALLMARGIN = 4
SS_TILESIZE = 156
SS_RPANEWIDTH = 344
SS_SCROLL_WIDTH = 16

SS_SUBCATEGORY_HEIGHT = 36

SS_NAVBARHEIGHT = 56
SS_BOTBARHEIGHT = 88

SS_ROOM_TILES_W = 5
SS_ROOM_TILES_H = 4
SS_ROOM_SUBCAT = 1
SS_CUSTOMIZER_HEADINGSIZE = 64

SS_MENUWIDTH = SS_RPANEWIDTH*1
SS_MENUWIDTH = SS_MENUWIDTH + (SS_TILESIZE * SS_ROOM_TILES_W)
SS_MENUWIDTH = SS_MENUWIDTH + (SS_COMMONMARGIN * (SS_ROOM_TILES_W))
SS_MENUWIDTH = SS_MENUWIDTH + SS_SCROLL_WIDTH
SS_MENUWIDTH = SS_MENUWIDTH + (SS_COMMONMARGIN * (3))


SS_MENUHEIGHT = SS_NAVBARHEIGHT*1 
SS_MENUHEIGHT = SS_MENUHEIGHT +  ((SS_SUBCATEGORY_HEIGHT + SS_COMMONMARGIN) *SS_ROOM_SUBCAT)
SS_MENUHEIGHT = SS_MENUHEIGHT +  ((SS_TILESIZE + SS_COMMONMARGIN) * SS_ROOM_TILES_H)
SS_MENUHEIGHT = SS_MENUHEIGHT +  (SS_COMMONMARGIN * 1)
SS_MENUHEIGHT = SS_MENUHEIGHT +  SS_BOTBARHEIGHT



function SS_GetMainGridSpace() --get the width of usable space in the left side panel
return SS_MENUWIDTH - SS_COMMONMARGIN*2 - SS_RPANEWIDTH 
end

function SS_GetCustomizerHeight() --get the height
    return SS_MENUHEIGHT - SS_BOTBARHEIGHT - SS_NAVBARHEIGHT - SS_CUSTOMIZER_HEADINGSIZE*2 - (SS_COMMONMARGIN*4)
end 

function SS_GetMainGridDivision(div) --get the of 1/div of the usable grid space, taking into account the spaces between
return (SS_GetMainGridSpace() - (SS_COMMONMARGIN * math.max(div - 1,0)) ) / div
end
 
-- 24381a
--[[
@gray-base:              #000;
@gray-darker:            #222;
@gray-dark:              #333;
@gray:                   #454545;
@gray-light:             #999;
@gray-lighter:           #EBEBEB;

@brand-primary:         #206068;
@brand-success:         #10c090;
@brand-info:            #3498DB;
@brand-warning:         #F39C12;
@brand-danger:          #E74C3C;
]]
--10c090
function BrandBackgroundPattern(x, y, w, h, px, special)
    surface.SetDrawColor(MenuTheme_Brand)
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(0, 0, 0, 40)
    draw.NoTexture()
    local stripewidth = 20
    local stripepos = -(px % (2 * stripewidth))

    if special then
        stripepos = stripepos - stripewidth
    end

    while stripepos < w + h do
        local triangle = {
            {
                x = x + stripepos,
                y = y
            },
            {
                x = x + stripepos + stripewidth,
                y = y
            },
            {
                x = x + stripepos + stripewidth - h,
                y = y + h
            },
            {
                x = x + stripepos - h,
                y = y + h
            }
        }

        surface.DrawPoly(triangle)
        stripepos = stripepos + (2 * stripewidth)
    end
end

function BrandDropDownGradient(x, y, w)
    draw.GradientShadowDown(x, y, w, 8, 0.65)
end

BrandTitleBarHeight = 64

--------------------------------------stuff taken from the shop code below

surface.CreateFont("LabelFont", {
    font = "Lato-Light",
    size = 21,
    weight = 200
})

surface.CreateFont("SmallFont", {
    font = "Lato",
    size = 16,
    weight = 200
})



local cornerMat = Material("vgui/box_corner_shadow")

local function predrawshadow(alpha)
    cornerMat:SetFloat("$alpha", alpha)
    surface.SetDrawColor(Color(255, 255, 255))
    surface.SetMaterial(cornerMat)
end

function draw.BoxShadow(x, y, w, h, blur, alpha)
    if cornerMat:IsError() then return end
    local hblur = blur / 2
    x = x - hblur
    y = y - hblur
    w = (w / 2) + hblur
    h = (h / 2) + hblur
    local cx, cy = x + w / 2, y + h / 2
    local wb, hb = w / blur, h / blur
    predrawshadow(alpha)
    surface.DrawTexturedRectUV(x, y, w, h, 0, 0, wb, hb)
    surface.DrawTexturedRectUV(x, y + h, w, h, 0, hb, wb, 0)
    surface.DrawTexturedRectUV(x + w, y, w, h, wb, 0, 0, hb)
    surface.DrawTexturedRectUV(x + w, y + h, w, h, wb, hb, 0, 0)
end

function draw.GradientShadowDown(x, y, w, h, alpha)
    if cornerMat:IsError() then return end
    predrawshadow(alpha)
    surface.DrawTexturedRectUV(x, y, w, h, 1, 1, 1, 0)
end

function draw.GradientShadowUp(x, y, w, h, alpha)
    if cornerMat:IsError() then return end
    predrawshadow(alpha)
    surface.DrawTexturedRectUV(x, y, w, h, 1, 0, 1, 1)
end

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
    size = 28,
    weight = 700
})

-- surface.CreateFont('SS_JOINFONTBIG', {
--     font = 'Lato',
--     size = 28,
--     weight = 700
-- })
surface.CreateFont('SS_DESCTITLEFONT', {
    font = 'Righteous',
    size = 32
})

surface.CreateFont('SS_DESCFONT', {
    font = 'Lato',
    size = 18,
    weight = 700
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
    size = 17,
    weight = 1000,
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

