-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SS_Tab("Upgrades", "lock_open")
SS_Heading("Accessory Slots")

local prices = {0, 10000, 15000, 22000, 33000, 50000, 75000, 110000, 175000, 250000, 375000, 560000, 840000, 1000000, 1500000}

for n = 2, #prices do
    local slotid = n

    SS_Item({
        class = "accslot_" .. tostring(n),
        price = prices[n],
        name = 'Accessory Slot ' .. tostring(n),
        description = "Allows equipping more accessories at once.",
        model = 'models/props_lab/tpplug.mdl',
        material = 'models/debug/debugwhite',
        invcategory = "Upgrades",
        never_equip = true,
        CanBuyStatus = function(itm, ply)
            if ply:SS_AccessorySlots() < slotid - 1 then return "Buy the previous slots first." end
        end
    })
end
