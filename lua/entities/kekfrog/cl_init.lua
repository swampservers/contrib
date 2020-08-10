include("shared.lua")

function ENT:Draw()
    render.MaterialOverride(self.Material)
    self:DrawModel()
    render.MaterialOverride()
end
