-- This file is subject to copyright - contact swampservers@gmail.com for more information.

include("shared.lua")

function ENT:Draw()
    render.MaterialOverride(self.Material)
    self:DrawModel()
    render.MaterialOverride()
end
