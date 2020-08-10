include("shared.lua")

KLEINERPORTALMATERIAL = CreateMaterial(cvx_anonymous_name(), "UnlitGeneric", {
    ["$basetexture"] =  "brian/models/flare1c",
    ["$additive"] = 1,
  } )

function ENT:DrawTranslucent()
    render.SetBlend(0.5)
    -- self:DrawModel()

    self:SetRenderBounds(-Vector(100,100,100),Vector(100,100,100)) 

    render.SetMaterial(KLEINERPORTALMATERIAL)
    render.DrawQuadEasy(self:GetPos(), EyePos() - self:GetPos(), 40, 40, Color(255,255,255))
end
