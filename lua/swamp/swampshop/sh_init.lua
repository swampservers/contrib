-- This file is subject to copyright - contact swampservers@gmail.com for more information.


API_Request("ShownItems", {API_ENTITY})

API_Command("PointOutInventory", {}, function()
    SS_INVENTORY_POINT_OUT = RealTime()
end)


API_Command("Items", {API_STRING}, function(  items)
    MeOnValid(function(ply)
        Me.SS_Items = SS_MakeItems(Me, util.JSONToTable(util.Decompress(items)))
        SS_PostItemsUpdate(Me, false)
    end)
end)


API_Command("ShownItems", {API_ENTITY_HANDLE, API_List(API_STRUCT)}, function(ph,  items)
    ph:OnValid(function(ply)
        ply.SS_ShownItems = SS_MakeItems(ply, items)
        SS_PostItemsUpdate(ply, true)
    end)
end)


-- empty table to delete it
API_Command("UpdateItem", {API_STRUCT}, function(item)

    if Me and Me.SS_Items then
        if item.delete then
            SS_RemoveItemID(Me.SS_Items, item.delete)
        else
            item = SS_MakeItem(Me, item)
            SS_RemoveItemID(Me.SS_Items, item.id)
            table.insert(Me.SS_Items, item)
        end

        SS_InventoryVersion = (SS_InventoryVersion or 0) + 1
    end
        
end)





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
