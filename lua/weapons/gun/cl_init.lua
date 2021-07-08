-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")
local cl_crosshaircolor = GetConVar("cl_cs_crosshaircolor")
local cl_dynamiccrosshair = GetConVar("cl_cs_dynamiccrosshair")
local cl_scalecrosshair = GetConVar("cl_cs_scalecrosshair")
local cl_crosshairscale = GetConVar("cl_cs_crosshairscale")
local cl_crosshairalpha = GetConVar("cl_cs_crosshairalpha")
local cl_crosshairusealpha = GetConVar("cl_cs_crosshairusealpha")
local cl_bobcycle = GetConVar("cl_cs_bobcycle")
local cl_bob = GetConVar("cl_cs_bob")
local cl_bobup = GetConVar("cl_cs_bobup")
SWEP.LastAmmoCheck = 0

--Jvs: CSS' viewmodel bobbing code, if it's disabled it'll just return hl2's
function SWEP:CalcViewModelView(vm, origin, angles, newpos, newang)
    if self.CSSBobbing then
        local forward = angles:Forward()
        self:CalcViewModelBob()
        -- Apply bob, but scaled down to 40%
        origin = origin + forward * self.VerticalBob * 0.4
        -- Z bob a bit more
        origin.z = origin.z + self.VerticalBob * 0.1
        -- bob the angles
        angles.r = angles.r + self.VerticalBob * 0.5
        angles.p = angles.p - self.VerticalBob * 0.4
        angles.y = angles.y - self.LateralBob * 0.3

        return origin, angles
    end
end

--Jvs TODO: replace CurTime() with RealTime() to prevent prediction errors from spazzing the viewmodel
function SWEP:CalcViewModelBob()
    local cycle = 0
    local player = self:GetOwner()
    --Assert( player )
    --NOTENOTE: For now, let this cycle continue when in the air, because it snaps badly without it
    if FrameTime() == 0 or cl_bobcycle:GetFloat() <= 0 or cl_bobup:GetFloat() <= 0 or cl_bobup:GetFloat() >= 1 then return end
    --Find the speed of the player
    local speed = player:GetAbsVelocity():Length2D()
    local flmaxSpeedDelta = math.max(0, (CurTime() - self.LastBobTime) * player:GetRunSpeed())
    -- don't allow too big speed changes
    speed = math.Clamp(speed, self.LastSpeed - flmaxSpeedDelta, self.LastSpeed + flmaxSpeedDelta)
    speed = math.Clamp(speed, player:GetRunSpeed() * -1, player:GetRunSpeed())
    self.LastSpeed = speed
    --FIXME: This maximum speed value must come from the server.
    --		 MaxSpeed() is not sufficient for dealing with sprinting - jdw
    local bob_offset = math.Remap(speed, 0, player:GetRunSpeed(), 0, 1)
    self.BobTime = self.BobTime + (CurTime() - self.LastBobTime) * bob_offset
    self.LastBobTime = CurTime()
    --Calculate the vertical bob
    cycle = self.BobTime - (self.BobTime / cl_bobcycle:GetFloat()) * cl_bobcycle:GetFloat()
    cycle = cycle / cl_bobcycle:GetFloat()

    if cycle < cl_bobup:GetFloat() then
        cycle = math.pi * cycle / cl_bobup:GetFloat()
    else
        cycle = math.pi + math.pi * (cycle - cl_bobup:GetFloat()) / (1 - cl_bobup:GetFloat())
    end

    self.VerticalBob = speed * 0.005
    self.VerticalBob = self.VerticalBob * 0.3 + self.VerticalBob * 0.7 * math.sin(cycle)
    self.VerticalBob = math.Clamp(self.VerticalBob, -7.0, 4.0)
    --Calculate the lateral bob
    cycle = self.BobTime - (self.BobTime / cl_bobcycle:GetFloat() * 2) * cl_bobcycle:GetFloat() * 2
    cycle = cycle / (cl_bobcycle:GetFloat() * 2)

    if cycle < cl_bobup:GetFloat() then
        cycle = math.pi * cycle / cl_bobup:GetFloat()
    else
        cycle = math.pi + math.pi * (cycle - cl_bobup:GetFloat()) / (1 - cl_bobup:GetFloat())
    end

    self.LateralBob = speed * 0.005
    self.LateralBob = self.LateralBob * 0.3 + self.LateralBob * 0.7 * math.sin(cycle)
    self.LateralBob = math.Clamp(self.LateralBob, -7, 4)

    return
end

function SWEP:DrawWorldModel()
    self:UpdateWorldModel()
    self:DrawModel()
end

function SWEP:PreDrawViewModel(vm, weapon, ply)
    if self:IsScoped() then return true end
end

function SWEP:GetTracerOrigin()
end

--[[
    if IsValid( self:GetOwner() ) then
        local viewmodel = self:GetOwner():GetViewModel( 0 )
        local attch = viewmodel:GetAttachment( "2" )
        if not attch then return end
        return attch.Pos
    end
    ]]
--copied straight from weapon_base
function SWEP:FireAnimationEvent(pos, ang, event, options)
    if not self:GetOwner():IsValid() then return end

    if event == 5001 or event == 5011 or event == 5021 or event == 5031 then
        if self:IsSilenced() or self:IsScoped() then return true end
        local data = EffectData()
        data:SetFlags(0)
        data:SetEntity(self:GetOwner():GetViewModel())
        data:SetAttachment(math.floor((event - 4991) / 10))
        data:SetScale(self:GetWeaponInfo().MuzzleFlashScale)

        if self.CSMuzzleX then
            util.Effect("CS_MuzzleFlash_X", data)
        else
            util.Effect("CS_MuzzleFlash", data)
        end

        return true
    end
end

SWEP.ScopeArcTexture = Material("sprites/scope_arc")
SWEP.ScopeDustTexture = Material("overlays/scope_lens.vmt")
SWEP.ScopeFallback = true
--[[
    m_iScopeArcTexture = vgui::surface()->CreateNewTextureID()
    vgui::surface()->DrawSetTextureFile(m_iScopeArcTexture, "sprites/scope_arc", true, false)

    m_iScopeDustTexture = vgui::surface()->CreateNewTextureID()
    vgui::surface()->DrawSetTextureFile(m_iScopeDustTexture, "overlays/scope_lens", true, false)
]]
SWEP.CrosshairDistance = 0
local cl_crosshaircolor = CreateConVar("cl_cs_crosshaircolor", "0", FCVAR_ARCHIVE)
local cl_dynamiccrosshair = CreateConVar("cl_cs_dynamiccrosshair", "1", FCVAR_ARCHIVE)
local cl_scalecrosshair = CreateConVar("cl_cs_scalecrosshair", "1", FCVAR_ARCHIVE)
local cl_crosshairscale = CreateConVar("cl_cs_crosshairscale", "0", FCVAR_ARCHIVE)
local cl_crosshairalpha = CreateConVar("cl_cs_crosshairalpha", "200", FCVAR_ARCHIVE)
local cl_crosshairusealpha = CreateConVar("cl_cs_crosshairusealpha", "0", FCVAR_ARCHIVE)
SWEP.CSSBobbing = false
SWEP.LateralBob = 0
SWEP.VerticalBob = 0
SWEP.BobTime = 0
SWEP.LastBobTime = 0
SWEP.LastSpeed = 0
local cl_bobcycle = CreateConVar("cl_cs_bobcycle", "0.8", FCVAR_ARCHIVE + FCVAR_CHEAT)
local cl_bob = CreateConVar("cl_cs_bob", "0.002", FCVAR_ARCHIVE + FCVAR_CHEAT)
local cl_bobup = CreateConVar("cl_cs_bobup", "0.5", FCVAR_ARCHIVE + FCVAR_CHEAT)

function SWEP:DoDrawCrosshair(x, y)
    if self:GetWeaponType() == CS_WEAPONTYPE_SNIPER_RIFLE then return true end
    local iDistance = self:GetWeaponInfo().CrosshairMinDistance -- The minimum distance the crosshair can achieve...
    local iDeltaDistance = self:GetWeaponInfo().CrosshairDeltaDistance -- Distance at which the crosshair shrinks at each step

    if cl_dynamiccrosshair:GetBool() then
        if not self:GetOwner():OnGround() then
            iDistance = iDistance * 2.0
        elseif self:GetOwner():Crouching() then
            iDistance = iDistance * 0.5
        elseif self:GetOwner():GetAbsVelocity():Length() > 100 then
            iDistance = iDistance * 1.5
        end
    end

    if self:GetShotsFired() > self.LastAmmoCheck then
        self.CrosshairDistance = math.min(15, self.CrosshairDistance + iDeltaDistance)
    elseif self.CrosshairDistance > iDistance then
        self.CrosshairDistance = 0.1 + self.CrosshairDistance * 0.013
    end

    self.LastAmmoCheck = self:GetShotsFired()

    if self.CrosshairDistance < iDistance then
        self.CrosshairDistance = iDistance
    end

    --scale bar size to the resolution
    local crosshairScale = cl_crosshairscale:GetInt()

    if crosshairScale < 1 then
        if ScrH() <= 600 then
            crosshairScale = 600
        elseif ScrH() <= 768 then
            crosshairScale = 768
        else
            crosshairScale = 1200
        end
    end

    local scale

    if not cl_scalecrosshair:GetBool() then
        scale = 1
    else
        scale = ScrH() / crosshairScale
    end

    local iCrosshairDistance = math.ceil(self.CrosshairDistance * scale)
    local iBarSize = ScreenScale(5) + (iCrosshairDistance - iDistance) / 2
    iBarSize = math.max(1, iBarSize * scale)
    local iBarThickness = math.max(1, math.floor(scale + 0.5))
    local r, g, b

    if cl_crosshaircolor:GetInt() == 0 then
        r = 50
        g = 250
        b = 50
    elseif cl_crosshaircolor:GetInt() == 1 then
        r = 250
        g = 50
        b = 50
    elseif cl_crosshaircolor:GetInt() == 2 then
        r = 50
        g = 50
        b = 250
    elseif cl_crosshaircolor:GetInt() == 3 then
        r = 250
        g = 250
        b = 50
    elseif cl_crosshaircolor:GetInt() == 4 then
        r = 50
        g = 250
        b = 250
    else
        r = 50
        g = 250
        b = 50
    end

    local alpha = math.Clamp(cl_crosshairalpha:GetInt(), 0, 255)
    surface.SetDrawColor(r, g, b, alpha)

    if not cl_crosshairusealpha:GetBool() then
        surface.SetDrawColor(r, g, b, 200)
        draw.NoTexture()
    end

    if self.MyBuildSpread then
        iCrosshairDistance = (EyePos() + EyeAngles():Forward() + EyeAngles():Right() * self:MyBuildSpread()):ToScreen().x - (ScrW() / 2)
    end

    -- print(3, (EyePos() + LocalPlayer():EyeAngles():Forward()):ToScreen().y ) 
    -- local realaim = (EyePos() + LocalPlayer():EyeAngles():Forward()):ToScreen()
    -- x = realaim.x
    -- y = realaim.y
    local iHalfScreenWidth = 0
    local iHalfScreenHeight = 0
    local iLeft = iHalfScreenWidth - (iCrosshairDistance + iBarSize)
    local iRight = iHalfScreenWidth + iCrosshairDistance + iBarThickness
    local iFarLeft = iBarSize
    local iFarRight = iBarSize

    if not cl_crosshairusealpha:GetBool() then
        -- Additive crosshair
        surface.DrawTexturedRect(x + iLeft, y + iHalfScreenHeight, iFarLeft, iHalfScreenHeight + iBarThickness)
        surface.DrawTexturedRect(x + iRight, y + iHalfScreenHeight, iFarRight, iHalfScreenHeight + iBarThickness)
    else
        -- Alpha-blended crosshair
        surface.DrawRect(x + iLeft, y + iHalfScreenHeight, iFarLeft, iHalfScreenHeight + iBarThickness)
        surface.DrawRect(x + iRight, y + iHalfScreenHeight, iFarRight, iHalfScreenHeight + iBarThickness)
    end

    local iTop = iHalfScreenHeight - (iCrosshairDistance + iBarSize)
    local iBottom = iHalfScreenHeight + iCrosshairDistance + iBarThickness
    local iFarTop = iBarSize
    local iFarBottom = iBarSize

    if not cl_crosshairusealpha:GetBool() then
        -- Additive crosshair
        surface.DrawTexturedRect(x + iHalfScreenWidth, y + iTop, iHalfScreenWidth + iBarThickness, iFarTop)
        surface.DrawTexturedRect(x + iHalfScreenWidth, y + iBottom, iHalfScreenWidth + iBarThickness, iFarBottom)
    else
        -- Alpha-blended crosshair
        surface.DrawRect(x + iHalfScreenWidth, y + iTop, iHalfScreenWidth + iBarThickness, iFarTop)
        surface.DrawRect(x + iHalfScreenWidth, y + iBottom, iHalfScreenWidth + iBarThickness, iFarBottom)
    end

    return true
end

function SWEP:DrawHUDBackground()
    if self:IsScoped() and self:GetWeaponType() == CS_WEAPONTYPE_SNIPER_RIFLE then
        local screenWide, screenTall = ScrW(), ScrH()
        -- calculate the bounds in which we should draw the scope
        local inset = screenTall / 16
        local y1 = inset
        local x1 = (screenWide - screenTall) / 2 + inset
        local y2 = screenTall - inset
        local x2 = screenWide - x1
        local x = screenWide / 2
        local y = screenTall / 2
        local uv1 = 0.5 / 256
        local uv2 = 1.0 - uv1
        surface.SetDrawColor(color_black)
        --Draw the reticle with primitives
        surface.DrawLine(0, y, screenWide, y)
        surface.DrawLine(x, 0, x, screenTall)
        -- scope dust
        --surface.SetMaterial(self.ScopeDustTexture)
        --surface.DrawTexturedRect(x - ( ScrH() / 2 ) , 0 , ScrH() , ScrH())
        -- scope arc
        surface.SetMaterial(self.ScopeArcTexture)
        -- top right
        surface.DrawTexturedRectUV(x, 0, ScrH() / 2, ScrH() / 2, 0, 1, 1, 0)
        -- top left
        surface.DrawTexturedRectUV(x - ScrH() / 2, 0, ScrH() / 2, ScrH() / 2, 1, 1, 0, 0)
        -- bottom left
        surface.DrawTexturedRectUV(x - ScrH() / 2, ScrH() / 2, ScrH() / 2, ScrH() / 2, 1, 0, 0, 1)
        -- bottom right
        surface.DrawTexturedRect(x, ScrH() / 2, ScrH() / 2, ScrH() / 2)
        surface.DrawRect(0, 0, math.ceil(x - ScrH() / 2), ScrH())
        surface.DrawRect(0, 0, math.ceil(x - ScrH() / 2), ScrH())
        surface.DrawRect(math.floor(x + ScrH() / 2), 0, math.ceil(x - ScrH() / 2), ScrH())
    end
end
