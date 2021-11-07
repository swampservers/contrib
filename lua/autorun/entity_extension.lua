-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local Entity = FindMetaTable("Entity")

function isPonyModel(modelName)
    modelName = modelName:sub(1, 17)
    if modelName == "models/ppm/player" then return true end
    if modelName == "models/mlp/player" then return true end

    return false
end

IsPonyModel = isPonyModel

function Entity:IsPony()
    return isPonyModel(self:GetModel())
end

function Entity:PonyNoseOffsetBone(ang)
    if self.IsPPMPony and self:IsPPMPony() then
        if (self.ponydata or {}).gender == 2 then return ang:Forward() * 1.9 + ang:Right() * 1.2 end
    end

    return Vector(0, 0, 0)
end

function Entity:PonyNoseOffsetAttach(ang)
    if self.IsPPMPony and self:IsPPMPony() then
        if (self.ponydata or {}).gender == 2 then return ang:Forward() * 1.8 + ang:Up() * 0.8 end
    end

    return Vector(0, 0, 0)
end


