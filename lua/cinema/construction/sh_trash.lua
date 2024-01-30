﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
function CanTapeWhileHandling(ent)
    return ent.AnchorTouchPos and ent:GetPos():Distance(ent.AnchorTouchPos) < 8
end

API_Command("HandleEntity", {API_ANY, API_ANY}, function(ent, touchpos)
    if not ent and IsValid(HandledEntity) then
        HandledEntity.AnchorTouchPos = nil
        HandledEntity:SetRenderAngles()
    end

    print(touchpos)
    HandledEntity = ent

    if ent then
        HandledEntity.AnchorTouchPos = touchpos
    end
end)

function FindAllTrash()
    local tab = {}

    for i, v in ipairs(ents.GetAll()) do
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
    ["Cemetery"] = TRASHLOC_BUILD,
    ["Caverns"] = TRASHLOC_BUILD,
    ["Elevator Shaft"] = TRASHLOC_NOSPAWN,
    ["Furnace"] = TRASHLOC_NOSPAWN,
    ["Golf"] = TRASHLOC_NOSPAWN,
    ["Graveyard"] = TRASHLOC_BUILD,
    ["Gym"] = TRASHLOC_BUILD,
    ["In Minecraft"] = TRASHLOC_BUILD,
    ["Janitor's Closet"] = TRASHLOC_BUILD,
    ["Labyrinth"] = TRASHLOC_BUILD,
    ["Locker Room"] = TRASHLOC_BUILD,
    ["Maintenance Room"] = TRASHLOC_BUILD,
    ["Moon Base"] = TRASHLOC_BUILD,
    ["Moon"] = TRASHLOC_BUILD,
    ["Office of the Vice President"] = TRASHLOC_BUILD,
    ["Outdoor Pool"] = TRASHLOC_BUILD,
    ["Outside"] = TRASHLOC_BUILD,
    ["Potassium Palace"] = TRASHLOC_BUILD,
    ["Power Plant"] = TRASHLOC_BUILD,
    ["Rat's Lair"] = TRASHLOC_BUILD,
    ["Reddit"] = TRASHLOC_BUILD,
    ["Sewer"] = TRASHLOC_BUILD,
    ["Sewer Theater"] = TRASHLOC_BUILD,
    ["Shooting Range"] = TRASHLOC_NOSPAWN,
    ["Situation Monitoring Room"] = TRASHLOC_BUILD,
    ["Sneed's Feed and Seed"] = TRASHLOC_BUILD,
    ["SportZone"] = TRASHLOC_BUILD,
    ["Stairwell"] = TRASHLOC_NOSPAWN,
    ["SushiTheater Attic"] = TRASHLOC_BUILD,
    ["SushiTheater Basement"] = TRASHLOC_BUILD,
    ["SushiTheater Second Floor"] = TRASHLOC_NOSPAWN,
    ["SushiTheater"] = TRASHLOC_BUILD,
    ["Temple of Kek"] = TRASHLOC_BUILD,
    ["The Box"] = TRASHLOC_BUILD,
    ["The Pit"] = TRASHLOC_BUILD,
    ["The Underworld"] = TRASHLOC_BUILD,
    ["Tree"] = TRASHLOC_BUILD,
    ["Trump Lobby"] = TRASHLOC_BUILD,
    ["Trump Taj Mahal"] = TRASHLOC_NOSPAWN,
    ["Trump Tower Lobby"] = TRASHLOC_BUILD,
    ["Trump Tower Hotel"] = TRASHLOC_BUILD,
    ["Trump Tower Casino"] = TRASHLOC_BUILD,
    ["Trump Tower Gaymergear"] = TRASHLOC_BUILD,
    ["Trump Tower X HQ"] = TRASHLOC_BUILD,
    ["Trump Tower Throne Room"] = TRASHLOC_BUILD,
    ["Vapor Lounge"] = TRASHLOC_BUILD,
    ["Void"] = TRASHLOC_BUILD,
    ["Way Outside"] = TRASHLOC_BUILD
}

-- Prevent stuff being taped within a sphere around the position
-- TODO(winter): Is this still used/necessary?
TrashNoFreezeNodes = {} --{Vector(-2040, -60, 80), 120},
