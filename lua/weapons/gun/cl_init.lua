-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")
-- function SWEP:DrawWorldModel()
--     self:UpdateWorldModel()
--     self:DrawModel()
-- end
SWEP.FireAnimationEvent = nil
--copied straight from weapon_base
-- function SWEP:FireAnimationEvent(pos, ang, event, options)
--     if not self:GetOwner():IsValid() then return end
--     if event == 5001 or event == 5011 or event == 5021 or event == 5031 then
--         if self:IsSilenced() or self:IsScoped() then return true end
--         local data = EffectData()
--         data:SetFlags(0)
--         data:SetEntity(self:GetOwner():GetViewModel())
--         data:SetAttachment(math.floor((event - 4991) / 10))
--         data:SetScale(self.MuzzleFlashScale)
--         if self.CSMuzzleX then
--             util.Effect("CS_MuzzleFlash_X", data)
--         else
--             util.Effect("CS_MuzzleFlash", data)
--         end
--         return true
--     end
-- end
--NOMINIFY
SWEP.ScopeArcTexture = Material("sprites/scope_arc")
SWEP.ScopeDustTexture = Material("overlays/scope_lens.vmt")

function SWEP:DoDrawCrosshair(x, y)
    if self:IsScoped() then return true end --and (self.GunType=="sniper" or self.GunType=="autosniper") then return true end
    local barl = math.ceil(10 + ScrH() / 80)
    local barw = 1
    local barwofs = -math.floor(barw / 2)
    local pixelfix = barw % 2
    local dist = math.Round((EyePos() + EyeAngles():Forward() + EyeAngles():Right() * self:GetSpread()):ToScreen().x - (ScrW() / 2))
    surface.SetDrawColor(255, 224, 48, 255)
    surface.DrawRect(x - (barl + dist) + pixelfix, y + barwofs, barl, barw)
    surface.DrawRect(x + dist, y + barwofs, barl, barw)
    surface.DrawRect(x + barwofs, y - (barl + dist) + pixelfix, barw, barl)
    surface.DrawRect(x + barwofs, y + dist, barw, barl)

    return true
end

function SWEP:DrawHUDBackground()
    --and (self.GunType=="sniper" or self.GunType=="autosniper") then
    if self:IsScoped() then
        local x = ScrW() / 2
        local y = ScrH() / 2
        local blur = math.max(0, self:GetSpread() - 0.003)
        -- TODO use a gradient
        local boxsize = blur * ScrH() / 6
        surface.SetDrawColor(Color(0, 0, 0, math.max(0, 255 - blur * 3000)))
        surface.DrawRect(0, y - boxsize, ScrW(), boxsize * 2 + 1)
        surface.DrawRect(x - boxsize, 0, boxsize * 2 + 1, ScrH())

        if not self.ScopeDustTexture:IsError() then
            surface.SetDrawColor(Color(255, 255, 255, 128))
            surface.SetMaterial(self.ScopeDustTexture)
            surface.DrawTexturedRect(x - (ScrH() / 2), 0, ScrH(), ScrH())
        end

        surface.SetDrawColor(color_black)

        if not self.ScopeArcTexture:IsError() then
            surface.SetMaterial(self.ScopeArcTexture)
            surface.DrawTexturedRectUV(x, 0, ScrH() / 2, ScrH() / 2, 0, 1, 1, 0)
            surface.DrawTexturedRectUV(x - ScrH() / 2, 0, ScrH() / 2, ScrH() / 2, 1, 1, 0, 0)
            surface.DrawTexturedRectUV(x - ScrH() / 2, ScrH() / 2, ScrH() / 2, ScrH() / 2, 1, 0, 0, 1)
            surface.DrawTexturedRect(x, ScrH() / 2, ScrH() / 2, ScrH() / 2)
        end

        surface.DrawRect(0, 0, math.ceil(x - ScrH() / 2), ScrH())
        surface.DrawRect(0, 0, math.ceil(x - ScrH() / 2), ScrH())
        surface.DrawRect(math.floor(x + ScrH() / 2), 0, math.ceil(x - ScrH() / 2), ScrH())
    end
end
