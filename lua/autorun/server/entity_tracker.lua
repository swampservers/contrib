-- This file is subject to copyright - contact swampservers@gmail.com for more information.
function EntityCount(class)
    _CacheEntityCount(class)

    return _entity_counts[class]
end

_entity_counts = _entity_counts or {}

function _CacheEntityCount(class)
    if _entity_counts[class] == nil then
        _entity_counts[class] = #ents.FindByClass(class)

        return false
    end

    return true
end

hook.Add("OnEntityCreated", "_entity_counts_add", function(ent)
    local class = ent:GetClass()

    -- It seems to already be added to ents.FindByClass
    if _CacheEntityCount(class) then
        _entity_counts[class] = _entity_counts[class] + 1
    end
end)

hook.Add("EntityRemoved", "_entity_counts_subtract", function(ent)
    local class = ent:GetClass()

    -- It seems to already be removed from ents.FindByClass
    if _CacheEntityCount(class) then
        _entity_counts[class] = _entity_counts[class] - 1
    end
end)

function _AssertEntityCounts()
    for k, v in pairs(ents.GetAll()) do
        assert(EntityCount(v:GetClass()) == #ents.FindByClass(v:GetClass()))
    end
end
