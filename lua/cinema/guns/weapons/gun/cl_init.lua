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

local color_cvar = CreateClientConVar("crosshair_color", "default", true, false, "For Swamp guns. Enter 3 numbers with spaces in between or 'default'.") 
local additive_cvar =CreateClientConVar("crosshair_additive", "0.33", true, false, "For Swamp guns. Can be a fraction to blend", 0, 1)
local dotw_cvar = CreateClientConVar("crosshair_dot_scale", "1", true, false, "For Swamp guns.", 0, 10) 
local barw_cvar =CreateClientConVar("crosshair_bar_scale", "1", true, false, "For Swamp guns.", 0, 10)
local barl_cvar =CreateClientConVar("crosshair_bar_length_scale", "1", true, false, "For Swamp guns.", 0, 10)
local gap_cvar =CreateClientConVar("crosshair_static_gap", "-1", true, false, "For Swamp guns. If > 0 the crosshair bars will not move to show spread.", -1, 100)
local shadow_cvar = CreateClientConVar("crosshair_shadow", "0.33", true, false, "For Swamp guns. Opacity 0-1", 0, 1) 
local shadowsize_cvar = CreateClientConVar("crosshair_shadow_padding", "0", true, false, "For Swamp guns.", 0, 1) 
local shadowpos_cvar = CreateClientConVar("crosshair_shadow_offset", "1", true, false, "For Swamp guns. Move the shadow diagonally", 0, 1) 


function SWEP:DoDrawCrosshair(x, y)
    if self:IsScoped() then return true end --and (self.GunType=="sniper" or self.GunType=="autosniper") then return true end
    
    local basew = ScrH()/1500

    local barl = math.ceil( (10 + ScrH() / 80) * barl_cvar:GetFloat() )
    local barw = math.ceil(basew * barw_cvar:GetFloat())
    local dotw = math.ceil(basew * dotw_cvar:GetFloat())

    local barwofs = -math.floor(barw / 2)
    local pixelfix = barw % 2
    local dist = math.ceil(gap_cvar:GetFloat()*basew)
    if dist<=0 then dist= math.Round((EyePos() + EyeAngles():Forward() + EyeAngles():Right() * (self:GetSpread(true) + self.PelletSpread)):ToScreen().x - ScrW() / 2) end

    local col = color_cvar:GetString()
    col = col=="default" and Vector(255, 224, 48) or Vector(col)*255


    local function draw(p, e2)

        if barw>0 then
        surface.DrawRect(x - (barl + dist) + pixelfix +p, y + barwofs +p, barl+e2, barw+e2)
        surface.DrawRect(x + dist +p, y + barwofs +p, barl+e2, barw+e2)
        surface.DrawRect(x + barwofs +p, y - (barl + dist) + pixelfix +p, barw+e2, barl+e2)
        surface.DrawRect(x + barwofs +p, y + dist +p, barw+e2, barl+e2)
        end

        
        if dotw>0 then
            local dotwofs = -math.floor(dotw / 2)
            surface.DrawRect(x + dotwofs +p, y + dotwofs +p, dotw +e2, dotw+e2)
        end
    end

    -- black backing
    local alpha = 1-additive_cvar:GetFloat()
    if alpha>0 then
        surface.SetDrawColor(0,0,0, alpha*255)
        draw(0,0)
    end

    -- extra shadow
    local alpha = shadow_cvar:GetFloat()
    if alpha>0 then
        surface.SetDrawColor(0,0,0, alpha*255)
        local pad = math.ceil(shadowsize_cvar:GetFloat() * basew)
        draw(shadowpos_cvar:GetInt() - math.floor(pad/2), pad)
    end

    render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD)
    surface.SetDrawColor(col.x,col.y,col.z, 255)
    draw(0,0)
    render.OverrideBlend(false)

    -- draw.SimpleText("Spray: " .. math.floor(self:GetSpray(SysTime(), self.LastFireSysTime or 0) * 100), "DermaDefault", x, y + 100, color_white)
    return true
end

local hblurredcrosshair = Material("vgui/gradient-u")
local vblurredcrosshair = Material("vgui/gradient-l")
local scope_arc_tex = Material("sprites/scope_arc")
local scope_dust_tex = Material("overlays/scope_lens.vmt")
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

        if not scope_dust_tex:IsError() then
            surface.SetDrawColor(Color(255, 255, 255, 128))
            surface.SetMaterial(scope_dust_tex)
            surface.DrawTexturedRect(x - ScrH() / 2, 0, ScrH(), ScrH())
        end

        if self:HasPerk("crackedscope") then
            surface.SetDrawColor(Color(255, 255, 255, 255))
            surface.SetMaterial(crack)
            surface.DrawTexturedRect(x - ScrH() / 2, 0, ScrH() * 1.5, ScrH() * 1.5)
            surface.DrawTexturedRect(x - ScrH() / 2, 0, ScrH() * 1.5, ScrH() * 1.5)
        end

        surface.SetDrawColor(color_black)

        if not scope_arc_tex:IsError() then
            surface.SetMaterial(scope_arc_tex)
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
    -- self.PrintName = self:GetItem():GetName()self:GetNWString("PrintName", self.PrintName or "unknown")
    -- surface.SetDrawColor(255,255,255,255)
    -- surface.DrawRect(x,y, 100, 100)
    if self:GetItem() then
        -- self.PrintName = self:GetItem():GetName()
        SS_DrawSpecInfo(self:GetItem(), x, y + 50, 250, Color(255, 255, 255, 255), alpha / 255)
    end
end
