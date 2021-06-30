-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
DEFINE_BASECLASS("prop_trash")

-- AddTrashClass("prop_trash_wheelchair", "models/props_wasteland/controlroom_chair001a.mdl")
function ENT:Initialize()
    self:SetModel("models/props_wasteland/controlroom_chair001a.mdl")
    BaseClass.Initialize(self, true)

    if SERVER then
        SetupWheelchairProp(self)
    end
end

function ENT:OnRemove()
    if SERVER then
        if IsValid(self.BackWheel) then
            self.BackWheel:Remove()
        end

        if IsValid(self.FrontWheel) then
            self.FrontWheel:Remove()
        end
    end
end

function ENT:CanTape(userid)
    return false
end