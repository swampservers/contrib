-- This file is subject to copyright - contact swampservers@gmail.com for more information.
function CanTapeWhileHandling(ent)
    return ent.AnchorTouchPos and ent:GetPos():Distance(ent.AnchorTouchPos) < 8
end

API_Command("HandleEntity", {API_ANY, API_ANY}, function(ent, touchpos)
    if not ent and IsValid(HandledEntity) then
        HandledEntity.AnchorTouchPos = nil
        HandledEntity:SetRenderAngles()
        HandledEntity:SetRenderOrigin()
    end

    HandledEntity = ent

    if ent then
        HandledEntity.AnchorTouchPos = touchpos
    end
end)

function FindAllTrash()
    local tab = {}

    for i, v in ents.Iterator() do
        if v:GetTrashClass() then
            table.insert(tab, v)
        end
    end

    return tab
end

TRASH_MODEL_CLASSES = TRASH_MODEL_CLASSES or {}
TRASH_SPAWN_COOLDOWN = 3
TRASH_MANAGER_LOAD_RANGE = 1000
TRASH_MANAGER_PROP_LIMIT = 200
-- function GetTrashClass(mdl)
--     return TRASH_MODEL_CLASSES[mdl] or "prop_trash"
-- end
-- function AddTrashClass(class, models)
--     if isstring(models) then
--         TRASH_MODEL_CLASSES[models] = class
--     else
--         for k, v in pairs(models) do
--             if isstring(k) then
--                 TRASH_MODEL_CLASSES[k] = class
--             else
--                 assert(isstring(v))
--                 TRASH_MODEL_CLASSES[v] = class
--             end
--         end
--     end
-- end
TRASHLOC_BUILD = 1
TRASHLOC_NOBUILD = 2
TRASHLOC_NOSPAWN = 3
TRASHACT_TAPE = 1
TRASHACT_UNTAPE = 2
TRASHACT_REMOVE = 3
TRASHACT_PAINT = 4
TRASHACT_UNPAINT = 5

TrashLocationOverrides = {
    ["AFK Corral"] = TRASHLOC_BUILD,
    ["Auditorium"] = TRASHLOC_BUILD,
    ["Basement"] = TRASHLOC_BUILD,
    ["Caverns"] = TRASHLOC_BUILD,
    ["City 17"] = TRASHLOC_BUILD,
    ["Elevator Shaft"] = TRASHLOC_NOSPAWN,
    ["Furnace"] = TRASHLOC_NOSPAWN,
    ["Golf"] = TRASHLOC_NOSPAWN,
    ["Golf Islands"] = TRASHLOC_NOSPAWN,
    ["Graveyard"] = TRASHLOC_BUILD,
    ["Gym"] = TRASHLOC_BUILD,
    ["Janitor's Closet"] = TRASHLOC_BUILD,
    ["Labyrinth of Kek"] = TRASHLOC_NOBUILD,
    ["Locker Room"] = TRASHLOC_BUILD,
    ["Maintenance Room"] = TRASHLOC_BUILD,
    ["Moon Base"] = TRASHLOC_BUILD,
    ["Moon"] = TRASHLOC_BUILD,
    ["Office of the Vice President"] = TRASHLOC_BUILD,
    ["Outside"] = TRASHLOC_BUILD,
    ["Patriot Cockpit"] = TRASHLOC_BUILD,
    ["Patriot Lower Deck"] = TRASHLOC_BUILD,
    ["Patriot Deck"] = TRASHLOC_BUILD,
    ["Pool"] = TRASHLOC_BUILD,
    ["Potassium Abyss"] = TRASHLOC_BUILD,
    ["Power Plant"] = TRASHLOC_BUILD,
    ["Reddit"] = TRASHLOC_BUILD,
    ["Sewer Theater"] = TRASHLOC_BUILD,
    ["Sewer"] = TRASHLOC_BUILD,
    ["Shooting Range"] = TRASHLOC_NOSPAWN,
    ["Situation Monitoring Room"] = TRASHLOC_BUILD,
    ["Sneed's Feed and Seed"] = TRASHLOC_BUILD,
    ["SportZone"] = TRASHLOC_BUILD,
    ["SushiTheater Attic"] = TRASHLOC_BUILD,
    ["SushiTheater Basement"] = TRASHLOC_BUILD,
    ["SushiTheater Second Floor"] = TRASHLOC_BUILD,
    ["SushiTheater First Floor"] = TRASHLOC_BUILD,
    ["The Pit"] = TRASHLOC_BUILD,
    ["The Underworld"] = TRASHLOC_BUILD,
    ["Throne Room"] = TRASHLOC_BUILD,
    ["Tree"] = TRASHLOC_BUILD,
    ["Trump Tower Casino"] = TRASHLOC_NOSPAWN,
    ["Trump Tower Gaymergear"] = TRASHLOC_NOSPAWN,
    ["Trump Tower Hotel"] = TRASHLOC_BUILD,
    ["Trump Tower Lobby"] = TRASHLOC_BUILD,
    ["Trump Tower Throne Room"] = TRASHLOC_BUILD,
    ["Trump Tower X HQ"] = TRASHLOC_BUILD,
    ["Trumppenbunker"] = TRASHLOC_BUILD,
    ["Vapor Lounge"] = TRASHLOC_BUILD,
    ["Void"] = TRASHLOC_BUILD,
    ["Way Outside"] = TRASHLOC_BUILD,
    ["Zen Garden"] = TRASHLOC_BUILD
}

-- Prevent stuff being taped within a sphere around the position
TrashNoFreezeNodes = {
    {Vector(850, 1830, -3180), 768}, -- Sewer trickshot (top)
    {Vector(775, 1785, -740), 256}, -- Sewer trickshot (bottom)
    {Vector(-160, -4256, -1078), 256}, -- Trollcano
    {Vector(1281, -919, 9), 64} -- Gym respawn
    
}
