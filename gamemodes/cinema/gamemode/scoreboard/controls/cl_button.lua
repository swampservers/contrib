-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
--[[   _                                
	( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DButton
	
	Default Button

--]]
local PANEL = {}
local b = 20
PANEL.BackgroundColor = BrandColorGrayDark
PANEL.HoverColor = Color(BrandColorGrayDark.r + b, BrandColorGrayDark.g + b, BrandColorGrayDark.b + b)
PANEL.DepressedColor = Color(BrandColorGrayDark.r - b, BrandColorGrayDark.g - b, BrandColorGrayDark.b - b)
PANEL.DisabledColor = Color(16, 16, 16)
PANEL.TextColor = Color(255, 255, 255)

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:Init()
    self.BaseClass.Init(self)
    self:SetTall(28)
    self:SetFont("LabelFont")
end

function PANEL:Paint(w, h)
    if not self.m_bBackground then return end

    if (self.Depressed or self:IsSelected() or self:GetToggle()) then
        surface.SetDrawColor(self.DepressedColor)
        surface.DrawRect(0, 0, w, h)

        return
    end

    if (self:GetDisabled()) then
        surface.SetDrawColor(self.DisabledColor)
        surface.DrawRect(0, 0, w, h)

        return
    end

    if (self:IsMouseOver()) then
        surface.SetDrawColor(self.HoverColor)
        surface.DrawRect(0, 0, w, h)

        return
    end

    surface.SetDrawColor(self.BackgroundColor)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:UpdateColours(skin)
    return self:SetTextStyleColor(self.TextColor)
end

function PANEL:IsMouseOver()
    local x, y = self:CursorPos()

    return x >= 0 and y >= 0 and x <= self:GetWide() and y <= self:GetTall()
end

derma.DefineControl("TheaterButton", "", PANEL, "DButton")
