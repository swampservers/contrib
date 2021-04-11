-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")

function ENT:Draw()
    render.MaterialOverride(self.Material)
    self:DrawModel()
    render.MaterialOverride()
end