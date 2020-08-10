include("shared.lua")

function ENT:Draw()
    render.SetBlend(0.5)
    self:DrawModel()
end
