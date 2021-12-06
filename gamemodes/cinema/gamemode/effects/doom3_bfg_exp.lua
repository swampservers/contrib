-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
function EFFECT:Init(data)
    self.Pos = data:GetOrigin()

    if cvars.Bool("doom3_firelight") then
        local dynlight = DynamicLight(0)
        dynlight.Pos = self.Pos
        dynlight.Size = 1024
        dynlight.Decay = 2048
        dynlight.R = 150
        dynlight.G = 255
        dynlight.B = 100
        dynlight.Brightness = 5
        dynlight.DieTime = CurTime() + 1
    end

    self:SetModel("models/XQM/Rails/gumball_1.mdl")
    self:SetMaterial("models/weapons/doom3/bfg/bfgblast1_w")
    self.Time = 0
    self.Size = 0
end

function EFFECT:Think()
    self.Time = self.Time + FrameTime()
    self.Size = math.max(self.Time * 40 - 5, 0)

    return self.Time < 1
end

function EFFECT:Render()
    if not IsValid(self) then return end
    local col = 600 - (self.Time or 0) * 900
    col = math.Clamp(col, 0, 255)
    self:SetModelScale(self.Size, 0)
    self:DrawModel()
    self:SetColor(Color(col, col, col))
end
