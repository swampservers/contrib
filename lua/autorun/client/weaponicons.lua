-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- weapons.GetStored("weapon_base").WepSelectIcon 
function ALTDRAWWEAPONSELECTION(self, x, y, wide, tall, alpha)
    y = y + 40
    tall = tall - 40

    if not IsValid(WEAPON_SELECT_ENT) then
        WEAPON_SELECT_ENT = ClientsideModel(self.WorldModel)
        if not IsValid(WEAPON_SELECT_ENT) then return end
        WEAPON_SELECT_ENT:SetNoDraw(true)
    end

    if WEAPON_SELECT_ENT:GetModel() ~= self.WorldModel then
        WEAPON_SELECT_ENT:SetModel(self.WorldModel)
    end

    local min, max = WEAPON_SELECT_ENT:GetRenderBounds()
    local center, radius = (min + max) / 2, min:Distance(max) / 2
    -- WEAPON_SELECT_ENT:SetAngles(Angle(0, math.sin(SysTime()*2)*50 - 45, 0))
    WEAPON_SELECT_ENT:SetAngles(Angle(0, 0, 0))

    local function draww(fov, o1, o2, dm)
        cam.Start3D(WEAPON_SELECT_ENT:LocalToWorld(center) + ((radius + 1) * Vector(2, 2, 1)), Vector(-2, -2, -1):Angle(), fov, x + o1, y + o2, wide, tall)
        render.DepthRange(0, dm)
        WEAPON_SELECT_ENT:DrawModel()
        render.DepthRange(0, 1)
        cam.End3D()
    end

    render.SuppressEngineLighting(true)
    render.MaterialOverride(SWEPCOLORMATERIAL)
    -- render.OverrideDepthEnable(true,false)
    render.SetColorModulation(1, 0.8667, 0)
    local s = 1.5
    draww(60, s, s, 1)
    draww(60, -s, s, 1)
    draww(60, -s, -s, 1)
    draww(60, s, -s, 1)
    render.SetColorModulation(0, 0, 0)
    draww(60, 0, 0, 0) --0.999)
    render.SetColorModulation(1, 1, 1)
    -- render.OverrideDepthEnable(false,false)
    render.MaterialOverride()
    -- render.SetModelLighting(BOX_FRONT, 0.5,0.5,0.5)
    -- render.SetModelLighting(BOX_BACK, 0.5,0.5,0.5)
    -- render.SetModelLighting(BOX_RIGHT, 0.5,0.5,0.5)
    -- render.SetModelLighting(BOX_LEFT, 0.5,0.5,0.5)
    -- render.SetModelLighting(BOX_TOP, 1, 1, 1)
    -- render.SetModelLighting(BOX_BOTTOM, 0, 0, 0)
    -- draww(60,0,0)
    -- render.ResetModelLighting(1,1,1)
    render.SuppressEngineLighting(false)
end

BASEDRAWWEAPONSELECTION = BASEDRAWWEAPONSELECTION or weapons.GetStored("weapon_base").DrawWeaponSelection
SWEPCOLORMATERIAL = Material("models/debug/debugwhite")

weapons.GetStored("weapon_base").DrawWeaponSelection = function(self, x, y, wide, tall, alpha)
    if self.WorldModel == "" then return BASEDRAWWEAPONSELECTION(self, x, y, wide, tall, alpha) end

    return ALTDRAWWEAPONSELECTION(self, x, y, wide, tall, alpha)
end