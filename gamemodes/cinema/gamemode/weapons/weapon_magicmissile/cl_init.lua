-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")
SWEP.Instructions = "Primary: Fire\nVaporizes Kleiners\nSecondary: Play sound"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

function SWEP:DrawHUD()
    draw.SimpleText("Mana: " .. tostring(self:GetNWInt("mana")), "CloseCaption_Bold", ScrW() / 2, ScrH() - 40, Color(255, 255, 255, 255))
end

hook.Add("Think", "magicmissilelight", function()
    for k, pBall in pairs(Ents.prop_combine_ball) do
        local dlight = DynamicLight(pBall:EntIndex())

        if dlight then
            local c = pBall:GetColor()
            dlight.Pos = pBall:GetPos()
            dlight.r = c.r
            dlight.g = c.g
            dlight.b = c.b
            dlight.Brightness = 5 --self:GetBrightness()
            dlight.Decay = 1250 --self:GetLightSize() * 5
            dlight.Size = 250 --self:GetLightSize()
            dlight.DieTime = CurTime() + 1
        end
    end
end)
