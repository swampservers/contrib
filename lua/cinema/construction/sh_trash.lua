-- This file is subject to copyright - contact swampservers@gmail.com for more information.



API_Command("SetHandledEntity", {API_ANY, API_ANY}, function(ent, touchpos)
    if not ent and IsValid(HandledEntity) then
        HandledEntity:SetRenderAngles()
    end

    HandledEntity = ent
    HandledEntityTouchPos = touchpos
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
TRASH_MANAGER_PROP_LIMIT = 50
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
    ['Vapor Lounge'] = TRASHLOC_BUILD,
    ['Furnace'] = TRASHLOC_NOSPAWN,
    ['AFK Corral'] = TRASHLOC_BUILD,
    ['Reddit'] = TRASHLOC_BUILD,
    ['Maintenance Room'] = TRASHLOC_BUILD,
    ['Rat\'s Lair'] = TRASHLOC_BUILD,
    ['Sewer Theater'] = TRASHLOC_BUILD,
    ['Moon Base'] = TRASHLOC_BUILD,
    ['Office of the Vice President'] = TRASHLOC_BUILD,
    ['Situation Monitoring Room'] = TRASHLOC_BUILD,
    ['Stairwell'] = TRASHLOC_NOSPAWN,
    ['Elevator Shaft'] = TRASHLOC_NOSPAWN,
    ['Trump Lobby'] = TRASHLOC_BUILD,
    ['SushiTheater'] = TRASHLOC_NOSPAWN,
    ['SushiTheater Basement'] = TRASHLOC_BUILD,
    ['SushiTheater Second Floor'] = TRASHLOC_NOSPAWN,
    ['SushiTheater Attic'] = TRASHLOC_BUILD,
    ['Auditorium'] = TRASHLOC_BUILD,
    ['The Pit'] = TRASHLOC_BUILD,
    ['Control Room'] = TRASHLOC_BUILD,
    ['Cemetery'] = TRASHLOC_BUILD,
    ['Power Plant'] = TRASHLOC_BUILD,
    ['The Underworld'] = TRASHLOC_BUILD,
    ['Void'] = TRASHLOC_BUILD,
    ['The Box'] = TRASHLOC_BUILD,
    ['Throne Room'] = TRASHLOC_BUILD,
    ['Trump Tower'] = TRASHLOC_BUILD,
    ['SportZone'] = TRASHLOC_BUILD,
    ['Gym'] = TRASHLOC_BUILD,
    ['Locker Room'] = TRASHLOC_BUILD,
    ['Janitor\'s Closet'] = TRASHLOC_BUILD,
    ['Outdoor Pool'] = TRASHLOC_BUILD,
    ['Golf'] = TRASHLOC_NOSPAWN,
    ['In Minecraft'] = TRASHLOC_BUILD,
    ['Tree'] = TRASHLOC_BUILD,
    ['Shooting Range'] = TRASHLOC_NOSPAWN,
    ['Temple of Kek'] = TRASHLOC_BUILD,
    ['Labyrinth'] = TRASHLOC_BUILD,
    ['Moon'] = TRASHLOC_BUILD,
    ['Deep Space'] = TRASHLOC_BUILD,
    ['Potassium Palace'] = TRASHLOC_BUILD,
    ['Sewer Tunnels'] = TRASHLOC_BUILD,
    ['Outside'] = TRASHLOC_BUILD,
    ['Way Outside'] = TRASHLOC_BUILD
}

TrashNoFreezeNodes = {
    {Vector(-2040, -60, 80), 120},
    {Vector(-1970, -1120, 100), 150}
}
