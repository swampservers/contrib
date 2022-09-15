-- This file is subject to copyright - contact swampservers@gmail.com for more information.
BrandColorGrayDarker = Color(32, 32, 32) --(26, 30, 38)
BrandColorGrayDark = Color(48, 48, 48) --(38, 41, 49)
BrandColorGray = Color(60, 60, 60)
BrandColorGrayLight = Color(128, 128, 128)
BrandColorGrayLighter = Color(172, 172, 172)
BrandColorGrayLighterer = Color(216, 216, 216)
BrandColorWhite = Color(255, 255, 255)
BrandColorPrimary = Color(104, 28, 25)
BrandColorAlternate = Color(40, 96, 104) --Color(36, 56, 26) --Color(40, 96, 104)
-- Color(104, 28, 25)
local red = Color(96, 28, 25) --Color(104, 28, 25)
BrandColors = {}

for i = 0, 11 do
    local h, s, v = ColorToHSV(red)
    table.insert(BrandColors, HSVToColor((h + i * 30) % 360, s, v))
end

table.Add(BrandColors, {Color(0, 0, 0), Color(36, 36, 36)})

--{Color(104, 28, 25), Color(120, 60, 0), Color(36, 68, 24), Color(40, 96, 104), Color(91, 40, 104), Color(192, 90, 23), Color(187, 162, 78), Color(36, 36, 41), Color(197, 58, 77),}
CreateClientConVar("ps_themecolor", "1", true)

function ReloadStyle(color)
    color = color or GetConVar("ps_themecolor"):GetInt()
    MenuTheme_Brand = BrandColors[color] or BrandColors[1]
    MenuTheme_BrandDarker = Color(MenuTheme_Brand.r * 0.7, MenuTheme_Brand.g * 0.7, MenuTheme_Brand.b * 0.7)
    MenuTheme_BG = BrandColorGrayDarker
    MenuTheme_FG = BrandColorGrayDark
    MenuTheme_MD = BrandColorGray
    MenuTheme_TX = Color(200, 200, 200)
    MenuTheme_TXAlt = Color(255, 255, 255)
end

ReloadStyle()

cvars.AddChangeCallback("ps_themecolor", function(cvar, old, new)
    ReloadStyle(tonumber(new))
end)

ShopColorWhite = Color(255, 255, 255)
ShopColorBlack = Color(0, 0, 0)

ShopPaintButtonBrandHL = function(pnl, w, h)
    UI_DrawPanelShadow(pnl, 0, 0, w, h)

    if pnl.Depressed then
        pnl:SetTextColor(ShopColorWhite)
        surface.SetDrawColor(MenuTheme_Brand)
        draw.Box(0, 0, w, h, MenuTheme_Brand)
    else
        pnl:SetTextColor(ShopSwitchableColor)
        draw.Box(0, 0, w, h, MenuTheme_FG)
    end
end

ShopPaintFG = function(pnl, w, h)
    --surface.SetDrawColor(MenuTheme_FG)
    --surface.DrawRect(0, 0, w, h)
    UI_DrawPanelShadow(pnl, 0, 0, w, h)
    draw.Box(0, 0, w, h, MenuTheme_FG)
end

ShopPaintBG = function(pnl, w, h)
    draw.Box(0, 0, w, h, MenuTheme_BG)
end

ShopPaintTileInset = function(pnl, w, h)
    ShopPaintDiry(0, 0, w, h)
end

ShopPaintMD = function(pnl, w, h)
    UI_DrawPanelShadow(pnl, 0, 0, w, h)
    draw.Box(0, 0, w, h, MenuTheme_MD)
end

ShopPaintDarkenOnHover = function(pnl, w, h)
    if pnl:IsHovered() then
        draw.Box(0, 0, w, h, Color(0, 0, 0, 100))
    end
end

ShopPaintShaded = function(pnl, w, h, alpha)
    --surface.SetDrawColor(Color(0, 0, 0, 100))
    --surface.DrawRect(0, 0, w, h)
    draw.Box(0, 0, w, h, Color(0, 0, 0, alpha or 100))
end

ShopPaintFGAlpha = function(pnl, w, h, alpha)
    --surface.SetDrawColor(Color(0, 0, 0, 100))
    --surface.DrawRect(0, 0, w, h)
    draw.Box(0, 0, w, h, ColorAlpha(MenuTheme_FG, alpha or 100))
end

ShopPaintBrandStripes = function(pnl, w, h)
    UI_DrawPanelShadow(pnl, 0, 0, w, h)
    surface.SetDrawColor(MenuTheme_Brand)
    surface.DrawRect(0, 0, w, h)
    BrandBackgroundPattern(0, 0, w, h, 0)
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
local patternMat = Material("vgui/swamptitlebar.png", "noclamp")

function BrandBackgroundPatternOverlay(x, y, w, h, px)
    if h > 64 then
        y = y + (h - 64)
        h = 64
    end

    if patternMat:IsError() then return end
    surface.SetDrawColor(Color(255, 255, 255, 64))
    surface.SetMaterial(patternMat)
    surface.DrawTexturedRectUV(x, y, w, h, (px or 0) / 1024, 0, (w + (px or 0)) / 1024, h / 64)
end

function BrandBackgroundPattern(x, y, w, h, px)
    surface.SetDrawColor(MenuTheme_Brand)
    surface.DrawRect(x, y, w, h)
    BrandBackgroundPatternOverlay(x, y, w, h, px)
end

function BrandGrayBackgroundPattern(x, y, w, h, px)
    BrandGrayBackground(x, y, w, h)
    BrandBackgroundPatternOverlay(x, y, w, h, px)
end

function BrandGrayBackground(x, y, w, h)
    surface.SetDrawColor(BrandColorGray)
    surface.DrawRect(x, y, w, h)
end

function BrandDropDownGradient(x, y, w)
    draw.GradientShadowDown(x, y, w, 8, 0.65)
end

function BrandUpGradient(x, y, w)
    draw.GradientShadowUp(x, y - 8, w, 8, 0.65)
end

BrandTitleBarHeight = 64

surface.CreateFont('SHOP_DESCFONT', {
    font = 'Lato',
    size = 18,
    weight = 700
})

surface.CreateFont('SHOP_DESCFONTBIG', {
    font = 'Lato',
    size = 24,
    weight = 700
})

surface.CreateFont('SHOP_DESCINSTFONT', {
    font = 'Lato',
    size = 20
})

pointshopDollarImage = Material("icon16/money_dollar.png")
pointshopMoneyImage = Material("icon16/money.png")
