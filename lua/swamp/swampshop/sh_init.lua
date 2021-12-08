-- This file is subject to copyright - contact swampservers@gmail.com for more information.


function Player:SS_GetDonation()
    return self.SS_Donation or 0
end

--- Number of points
function Player:SS_GetPoints()
    return self.SS_Points or 0
end

--- If the player has at least this many points. Don't use it on the server if you are about to buy something; just do SS_TryTakePoints
function Player:SS_HasPoints(points)
    return (self.SS_Points or 0) >= points
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
