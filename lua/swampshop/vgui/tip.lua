-- This file is subject to copyright - contact swampservers@gmail.com for more information.

local PANEL = {}

local function CrawlParent(panel)
    local pan = panel
    while pan:GetParent() != vgui.GetWorldPanel() do
        pan = pan:GetParent()
    end
    return pan
end

local function CrawlVisibility(panel)
    local pan = panel
    if(pan:GetParent() == vgui.GetWorldPanel())then return self:IsVisible() end
    
    while pan:GetParent() != vgui.GetWorldPanel() do
        pan = pan:GetParent()
        if(!pan:IsVisible() or pan:GetTall() <= 1)then
            return false
        end
    end

    return true
end



function PANEL:Think()
    local parent = self:GetParent()
    local panel = self.ParentPanel   

    if(self.Identifier and (!IsValid(parent) or !IsValid(panel)))then
        self:Remove()
        return
    end
    if(!self.Identifier)then return end
    local vis = CrawlVisibility(panel)

    self:SetVisible(vis)

    
    if(!self:IsVisible())then return end


    self:PerformLayout()

    

end




function PANEL:ClearDrawover()

end

local triangle = {
	{ x = 12, y = 0 },
	{ x = 4, y = 0 },
	{ x = 8, y = -6 }
}


function PANEL:Paint(w, h)
    DisableClipping(true)
    SS_PaintBrand(self,w,h)

    surface.SetDrawColor(MenuTheme_Brand)
    draw.NoTexture()
	surface.DrawPoly( triangle )
    DisableClipping(false)
end

function PANEL:PaintOver()

end

function PANEL:Init()
    self:SetTall(0)
    self:SizeTo( -1, 24, 0.5,0, 1) 
    self:DockPadding(4,4,4,4)
    self.OKButton = vgui.Create("DButton",self)
    self.OKButton:SetSize(24,16)
    self.OKButton:SetText("OK")
   
    self.OKButton.UpdateColours = function(self)
        self:SetTextColor(MenuTheme_TX)
        self:SetTextStyleColor(MenuTheme_TX)
    end

    self.OKButton:Dock(RIGHT)
    self.OKButton.Paint = SS_PaintButtonBrandHL
    self.OKButton.DoClick = function()
        SetSwampMenuTipChecked(self.Identifier,true)

        self:SizeTo( -1, 0, 0.5,0, 1, function()
        self:Remove()
        end)
    end

    self.Label = vgui.Create("DLabel",self)
    self.Label:Dock(FILL)
    self.Label:DockMargin(4,0,4,0)
    self.Label:SetTextColor(MenuTheme_TX)
    self.Label:SetText("Fuck You!")

    self.Icon = vgui.Create("DImage",self)
    self.Icon:Dock(LEFT)
    self.Icon:DockMargin(0,0,0,0)
    self.Icon:SetWide(16)
    self.Icon:SetKeepAspect(true)
    self.Icon:SetImage("icon16/exclamation.png")

end

function PANEL:SetText(text)
    self.Label:SetText(text)
end



function PANEL:PerformLayout(w,h)
    local par = self.ParentPanel
    local x,y = par:LocalToScreen(par:GetWide()/2,par:GetTall() + 6)
    x,y = self:GetParent():ScreenToLocal(x,y)
    surface.SetFont(self.Label:GetFont())
    local tw = surface.GetTextSize(self.Label:GetText())

    self:SetWide(math.max(tw,128) + self.OKButton:GetWide() + 48)
    self:SetPos(x,y)
    self:SetZPos(32000)
    self:MoveToFront()
end


vgui.Register('SwampMenuTip', PANEL, 'DPanel')

function SwampMenuTipChecked(identifier)
    return LocalPlayer():GetPData("swampmenutip_"..identifier,false)
end

function SetSwampMenuTipChecked(identifier,checked)
     LocalPlayer():SetPData("swampmenutip_"..identifier,checked)
end

function SwampMenuTip(panel,identifier,text)

    if SwampMenuTipChecked(identifier) then return end
    
    local tip = vgui.Create("SwampMenuTip")
    tip.ParentPanel = panel
    tip:SetParent(CrawlParent(panel))
    tip.Identifier = identifier
    --tip:MakePopup()
    tip:NoClipping(true)
    tip:SetText(text)
end