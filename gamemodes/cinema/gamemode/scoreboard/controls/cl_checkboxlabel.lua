-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local PANEL = {}

--[[---------------------------------------------------------
   Name: PerformLayout
-----------------------------------------------------------]]
function PANEL:PerformLayout()
    self.BaseClass.PerformLayout(self)

    if self.Button then
        local x, y = self.Button:GetPos()
        y = (self:GetTall() / 2) - (self.Button:GetTall() / 2)
        self.Button:SetPos(x, y)
    end

    if self.Label then
        local x, y = self.Label:GetPos()
        y = (self:GetTall() / 2) - (self.Label:GetTall() / 2)
        self.Label:SetPos(x, y)
    end
end

--[[---------------------------------------------------------
	SizeToContents
-----------------------------------------------------------]]
function PANEL:SizeToContents()
    self:PerformLayout(true)
    self:SetWide(self.Label.x + self.Label:GetWide())
    self:SetTall(self.Label.y + self.Label:GetTall())
end

local b = 20
local highlightcolor = Color(BrandColorGray.r + b, BrandColorGray.g + b, BrandColorGray.b + b)

function PANEL:Paint()
    self.Button:SetAlpha(0)
    local x, y, w, h = self.Button:GetBounds()
    local cx, cy = self.Button:LocalCursorPos()
    local cl = BrandColorGray

    if cx >= x and cy >= y and cx < x + w and cy < y + h then
        cl = highlightcolor
    end

    if self.RadioButton then
        draw.DrawText("•", "RetardedRadioButtonFont", x + 7, y - 16, cl, TEXT_ALIGN_CENTER)
    else
        surface.SetDrawColor(cl)
        surface.DrawRect(self.Button:GetBounds())
    end

    if self.Button:GetChecked() then
        draw.DrawText(self.RadioButton and "•" or "✔", "LabelFont", x + 7, y - 4, Color(50, 200, 50, 255), TEXT_ALIGN_CENTER)
    end
end

surface.CreateFont("RetardedRadioButtonFont", {
    font = "Lato-Light",
    size = 42,
    weight = 200
})

function radiodrawcircle(x, y, radius, seg)
    local cir = {}

    table.insert(cir, {
        x = x,
        y = y,
        u = 0.5,
        v = 0.5
    })

    for i = 0, seg do
        local a = math.rad((i / seg) * -360)

        table.insert(cir, {
            x = x + math.sin(a) * radius,
            y = y + math.cos(a) * radius,
            u = math.sin(a) / 2 + 0.5,
            v = math.cos(a) / 2 + 0.5
        })
    end

    local a = math.rad(0) -- This is needed for non absolute segment counts

    table.insert(cir, {
        x = x + math.sin(a) * radius,
        y = y + math.cos(a) * radius,
        u = math.sin(a) / 2 + 0.5,
        v = math.cos(a) / 2 + 0.5
    })

    surface.DrawPoly(cir)
end

derma.DefineControl("TheaterCheckBoxLabel", "", PANEL, "DCheckBoxLabel")
