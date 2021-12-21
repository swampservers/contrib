-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- name is because of alphabetical include sorting, baseclass has to come first
local PANEL = {}

function PANEL:Init()
    self.Pitch = 30
    self.Yaw = 0
end

function PANEL:AlignEntity()
    -- local p,d = self:FocalPointAndDistance()
    self.Entity:SetPos(Vector(0, 0, 0))
    self.Entity:SetAngles(Angle(0, self.Yaw, 0))
    -- self.Entity:SetPos(-self.Entity:LocalToWorld(p))
end

function PANEL:GetCameraTransform()
    local p, d = self:FocalPointAndDistance()
    d = d * (2 ^ (self.ZoomOffset or 0))
    local ang = Angle(self.Pitch, 225, 0)

    return self.Entity:LocalToWorld(p) + ang:Forward() * -d, ang
end

function PANEL:StartCamera(hfraction)
    render.SuppressEngineLighting(true)
    render.ResetModelLighting(0.2, 0.2, 0.2)
    render.SetModelLighting(BOX_TOP, 1, 1, 1)
    render.SetModelLighting(BOX_FRONT, 1, 1, 1)
    local pos, ang = self:GetCameraTransform()
    local x, y = self:LocalToScreen(0, 0)
    local w, h = self:GetSize()
    cam.Start3D(pos, ang, self.fFOV, x, y, w, (hfraction or 1) * h, 2, 2000)
    -- cam.IgnoreZ(true)
end

function PANEL:EndCamera()
    -- cam.IgnoreZ(false)
    cam.End3D()
    render.SuppressEngineLighting(false)
end

function PANEL:PreDrawModel()
    local c = self.Entity:GetColor()
    render.SetColorModulation(c.r / 255, c.g / 255, c.b / 255)
end

function PANEL:PostDrawModel()
    render.SetColorModulation(1, 1, 1)
end

vgui.Register('SwampShopModelBase', PANEL, 'DModelPanel')
