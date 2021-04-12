-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA


SS_Tab("Upgrades","lock_open")

SS_Heading("Accessory Slots")

local fils = {"TrafficCone001a.mdl"}

if CLIENT then
    local fils2, folds = file.Find("models/props_junk/*.mdl", "GAME")
    fils = fils2
end

local prices = {0, 10000, 15000, 22000, 33000, 50000, 75000, 110000, 175000, 250000, 375000, 560000, 840000, 1000000,}

--2nd item
--6th
--10th
--14th
--[[


{
	0,
	10000, --2nd item
	15000, 
	20000,
	30000, 
	40000, --6th
	60000,
	80000,
	120000,
	160000, --10th
	240000,
	320000,
	480000,
	640000, --14th
	960000,
}



{
	0,
	1000, --2nd item
	2000, 
	4000,
	7000, 
	10000, --6th
	20000,
	40000,
	70000,
	100000, --10th
	200000,
	400000,
	700000,
	1000000, --14th
	1000000,
	1000000,
}]]
for n = 2, 14 do
    PS_ItemProduct({
        class = "accslot_" .. tostring(n),
        price = prices[n],
        name = 'Accessory Slot ' .. tostring(n),
        description = "Allows equipping more accessories at once.",
        model = 'models/props_junk/' .. fils[math.random(#fils)],
        material = 'models/debug/debugwhite',
        invcategory = "Upgrades",
        never_equip = true,
        CanBuyStatus = function(itm, ply)
            if ply:PS_AccessorySlots() < n - 1 then return PS_BUYSTATUS_PREVIOUS_SLOTS end
        end
    })
end