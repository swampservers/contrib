-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")

KLEINERPORTALMATERIAL1 = CreateMaterial(cvx_anonymous_name(), "UnlitGeneric", {
    ["$basetexture"] = "effects/bluemuzzle",
    ["$translucent"] = 1,
    ["$alpha"] = 0.7,
    ["$color2"] = "[ 0.3 0.5 0.3 ]",
})

KLEINERPORTALMATERIAL = CreateMaterial(cvx_anonymous_name(), "UnlitTwoTexture", {
    ["$basetexture"] = "brian/models/flare1c",
    ["$texture2"] = "lights/white",
    ["$additive"] = 1,
    ["$color2"] = "[ 7 7 9 ]",
})

function ENT:DrawTranslucent()
    if not SituationMonitorRT then return end
    -- render.SetBlend(0.5)
    self:SetRenderBounds(-Vector(100, 100, 100), Vector(100, 100, 100))
    render.SetMaterial(KLEINERPORTALMATERIAL1)
    render.DrawQuadEasy(self:GetPos(), EyePos() - self:GetPos(), 60, 60, Color(255, 255, 255), SysTime() * 500)
    local matt = Matrix()
    matt:Translate(Vector(0.5, 0.5, 0))
    matt:Rotate(Angle(0, SysTime() * -1000, 0))
    matt:Translate(Vector(-0.5, -0.5, 0))
    KLEINERPORTALMATERIAL:SetMatrix("$basetexturetransform", matt)
    local matt = Matrix()
    matt:Scale(Vector(-1, -1, 1) + VectorRand(-0.02, 0))
    KLEINERPORTALMATERIAL:SetMatrix("$texture2transform", matt)
    KLEINERPORTALMATERIAL:SetTexture("$texture2", SituationMonitorRT)
    render.SetMaterial(KLEINERPORTALMATERIAL)
    render.DrawQuadEasy(self:GetPos(), EyePos() - self:GetPos(), 110, 110, Color(255, 255, 255))
end
