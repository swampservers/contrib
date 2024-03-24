-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    if not self.Putters then
        self.Putters = {}
        local entPos = self:GetPos()
        local entAngles = self:GetAngles()
        local entForward = entAngles:Forward()
        local entRight = entAngles:Right()
        local entUp = entAngles:Up()

        for i = 1, 3 do
            local putterEnt = ClientsideModel(self.PutterModel)
            --putterEnt:SetParent(self)
            --putterEnt:DrawShadow(false)
            putterEnt:SetNoDraw(true)
            putterEnt:SetPos(entPos + entForward * 0.5 + entRight * -21.1 + entRight * i * 12.4 + entUp * 41) --i * 6.2
            putterEnt:SetAngles(Angle(0, entAngles.y + 90 + math.random(-15, 15), 180))
            putterEnt:Spawn()
            self.Putters[i] = putterEnt
        end
    end

    for _, putterEnt in ipairs(self.Putters) do
        putterEnt:DrawModel()
    end
end
