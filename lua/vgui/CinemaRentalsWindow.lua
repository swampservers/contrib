local PANEL = {}

local CloseTexture = Material("theater/close.png")
--local TitleBackground = Material("theater/bannernew2.png")

function PANEL:Init()
	self:SetFocusTopLevel(true)
	
	self.titleHeight = 36
	
	self.title = vgui.Create("DLabel", self)
	self.title:SetFont("ScoreboardTitleSmall")
	self.title:SetColor(Color(255, 255, 255))
	self.title:SetText("Window")
	
	self.closeButton = vgui.Create("DButton", self)
	self.closeButton:SetZPos(5)
	self.closeButton:NoClipping(true)
	self.closeButton:SetText("")
	self.closeButton.DoClick = function(btn)
		self:Remove()
	end
	self.closeButton.Paint = function(btn, w, h)
		DisableClipping(true)
		
		surface.SetDrawColor(48, 55, 71)
		surface.DrawRect(2, 2, w - 4, h - 4)
		
		surface.SetDrawColor(26, 30, 38)
		surface.SetMaterial(CloseTexture)
		surface.DrawTexturedRect(0, 0, w, h)
		
		DisableClipping(false)
	end
end

function PANEL:SetTitle(title)
	self.title:SetText(title)
end

function PANEL:PerformLayout()
	self.title:SizeToContents()
	self.title:SetTall(self.titleHeight)
	self.title:SetPos(1, 1)
	self.title:CenterHorizontal()

	self.closeButton:SetSize(32, 32)
	self.closeButton:SetPos(self:GetWide() - 34, 2)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(26, 30, 38, 255)
	surface.DrawRect(0, 0, w, h)
	
	surface.SetDrawColor(141, 38, 33, 255)
	surface.DrawRect(0, 0, w, self.title:GetTall())
	
	surface.SetDrawColor(255, 255, 255, 255)
	--surface.SetMaterial(TitleBackground)
	surface.DrawTexturedRect(0, -1, 512, self.title:GetTall() + 1)
	if w > 512 then
		surface.DrawTexturedRect(460, -1, 512, self.title:GetTall() + 1)
	end
end

vgui.Register("CinemaRentalsWindow", PANEL, "Panel")