-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include("shared.lua")

--copied from weapon_base, add self.CSMuzzleFlashScale
function SWEP:FireAnimationEvent(pos, ang, event, options)
    if self:HasPerk("airsoft") then return end
    if not self.CSMuzzleFlashes then return end

    if event == 5001 or event == 5011 or event == 5021 or event == 5031 then
        local data = EffectData()
        data:SetFlags(0)
        data:SetEntity(self.Owner:GetViewModel())
        data:SetAttachment(math.floor((event - 4991) / 10))
        data:SetScale(self.CSMuzzleFlashScale)
        util.Effect(self.CSMuzzleX and "CS_MuzzleFlash_X" or "CS_MuzzleFlash", data)

        return true
    end
end

--NOMINIFY
SWEP.ScopeArcTexture = Material("sprites/scope_arc")
SWEP.ScopeDustTexture = Material("overlays/scope_lens.vmt")

function SWEP:DoDrawCrosshair(x, y)
    if self:IsScoped() then return true end --and (self.GunType=="sniper" or self.GunType=="autosniper") then return true end
    local barl = math.ceil(10 + ScrH() / 80)
    local barw = 1
    local barwofs = -math.floor(barw / 2)
    local pixelfix = barw % 2
    local dist = math.Round((EyePos() + EyeAngles():Forward() + EyeAngles():Right() * (self:GetSpread(true) + self.PelletSpread)):ToScreen().x - (ScrW() / 2))
    surface.SetDrawColor(255, 224, 48, 255)
    surface.DrawRect(x - (barl + dist) + pixelfix, y + barwofs, barl, barw)
    surface.DrawRect(x + dist, y + barwofs, barl, barw)
    surface.DrawRect(x + barwofs, y - (barl + dist) + pixelfix, barw, barl)
    surface.DrawRect(x + barwofs, y + dist, barw, barl)

    if self.Owner:SteamID() == "STEAM_0:0:38422842" then
        draw.SimpleText("Spray: " .. math.floor(self:GetSpray(SysTime(), self.LastFireSysTime or 0) * 100), "DermaDefault", x, y + 100, color_white)
    end

    return true
end

local hblurredcrosshair = Material("vgui/gradient-u")
local vblurredcrosshair = Material("vgui/gradient-l")
local crack = Material("decals/glass/shot1")

function SWEP:DrawHUDBackground()
    --and (self.GunType=="sniper" or self.GunType=="autosniper") then
    if self:IsScoped() then
        local x = ScrW() / 2
        local y = ScrH() / 2
        local blur = math.max(0, self:GetSpread(true) - self.SpreadBase)
        local boxsize = math.ceil(blur * ScrH() / 3)

        if blur == 0 then
            surface.SetDrawColor(color_black)
            surface.DrawRect(0, y - boxsize, ScrW(), boxsize * 2 + 1)
            surface.DrawRect(x - boxsize, 0, boxsize * 2 + 1, ScrH())
        else
            surface.SetDrawColor(Color(0, 0, 0, 255 / math.pow(blur * 350, 1 / 3)))
            surface.SetMaterial(hblurredcrosshair)
            surface.DrawTexturedRectUV(0, y - boxsize, ScrW(), boxsize, 1, 1, 0, 0)
            surface.DrawTexturedRectUV(0, y, ScrW(), boxsize, 0, 0, 1, 1)
            surface.SetMaterial(vblurredcrosshair)
            surface.DrawTexturedRectUV(x - boxsize, 0, boxsize, ScrH(), 1, 1, 0, 0)
            surface.DrawTexturedRectUV(x, 0, boxsize, ScrH(), 0, 0, 1, 1)
        end

        if not self.ScopeDustTexture:IsError() then
            surface.SetDrawColor(Color(255, 255, 255, 128))
            surface.SetMaterial(self.ScopeDustTexture)
            surface.DrawTexturedRect(x - (ScrH() / 2), 0, ScrH(), ScrH())
        end

        if self:HasPerk("crackedscope") then
            surface.SetDrawColor(Color(255, 255, 255, 255))
            surface.SetMaterial(crack)
            surface.DrawTexturedRect(x - (ScrH() / 2), 0, ScrH() * 1.5, ScrH() * 1.5)
            surface.DrawTexturedRect(x - (ScrH() / 2), 0, ScrH() * 1.5, ScrH() * 1.5)
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

function SWEP:PrintWeaponInfo(x, y, alpha)
    self.PrintName = self:GetNWString("PrintName", self.PrintName or "unknown")

    -- surface.SetDrawColor(255,255,255,255)
    -- surface.DrawRect(x,y, 100, 100)
    if self.specs and self.dspecs then
        SS_DrawSpecInfo(self, x, y + 50, 250, Color(255, 255, 255, 255), alpha / 255)
    end
end
