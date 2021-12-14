-- This file is subject to copyright - contact swampservers@gmail.com for more information.

API_Command("PointOutInventory", {}, function()
    SS_INVENTORY_POINT_OUT = RealTime()
end)

API_Command("ShownItems", {API_ENTITY_HANDLE, API_UINT, API_LIST}, function(ph, itemsversion, items)
    ph:OnValid(function(ply)
        print(ply, itemsversion)
        ply.ShownItemsVersion = itemsversion
        ply.SS_ShownItems = SS_MakeItems(ply, items)
        SS_PostItemsUpdate(ply, true)
    end)
end)


API_Request("ShownItems", {API_ENTITY})

if SERVER then
    API_HandleRequest("ShownItems",function(ply, other)
        other.ShownItemsVersionSent = other.ShownItemsVersionSent or {}
        if IsValid(other) and other:IsPlayer() and other.ShownItemsVersionSent[ply]~=other.NW.ShownItemsVersion then
            other.ShownItemsVersionSent[ply] = other.NW.ShownItemsVersion
            ply:CommandShownItems(other, other.NW.ShownItemsVersion, other.SS_ShownItems)
        end
    end)
end



--- Number of points
function Player:SS_GetPoints()
    return self.NWP.points or 0
end

--- If the player has at least this many points. Don't use it on the server if you are about to buy something; just do SS_TryTakePoints
function Player:SS_HasPoints(points)
    return self:SS_GetPoints() >= points
end

function Player:SS_FindItem(item_id)
    for k, v in pairs(self.SS_Items or {}) do
        if v.id == item_id then
            assert(v.owner == self)

            return v
        end
    end

    return false
end

function Player:SS_HasItem(item_class)
    return self:SS_CountItem(item_class) > 0
end

function Player:SS_CountItem(item_class)
    local c = 0

    for k, v in pairs(self.SS_Items or {}) do
        if v.class == item_class then
            c = c + 1
        end
    end

    return c
end

function Player:SS_AccessorySlots()
    local c = 1
    local cfound = {}

    for k, v in pairs(self.SS_Items or {}) do
        if v.class:StartWith("accslot_") and not cfound[v.class] then
            cfound[v.class] = true
            c = c + 1
        end
    end

    return c
end
