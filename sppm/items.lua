-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-----------------------------------------------------
--SLOTIDS
-- 0 = HEAD = L1
-- 1 = NECK = L2
-- 2 = FBODY = L3
-- 3 = FLLEG = L4
-- 4 = FRLEG = L5
-- 5 = FLHOOF = L6
-- 6 = FRHOOF = L7 
-- 7 = EYES = R1
-- 8 = NONE = R2
-- 9 = BBODY = R3
--10 = BLLEG = R4
--11 = BRLEG = R5
--12 = BLHOOF = R6
--13 = BRHOOF = R7
PPM.pony_items = {}
PPM.cid = 1

function PPM:AddItem(basemodel, itemname, itemimg, itemBodygroupId, itemBodygroupValue, slot)
    local pitem = {}
    pitem.id = PPM.cid
    pitem.model = basemodel
    pitem.name = itemname
    pitem.img = itemimg
    pitem.bid = itemBodygroupId
    pitem.bval = itemBodygroupValue
    pitem.slot = slot
    pitem.issuit = false
    PPM.pony_items[PPM.cid] = pitem
    PPM.cid = PPM.cid + 1
    local pitem2 = {}
    pitem2.id = PPM.cid
    pitem2.model = basemodel .. "nj"
    pitem2.name = itemname
    pitem2.img = itemimg
    pitem2.bid = itemBodygroupId
    pitem2.bval = itemBodygroupValue
    pitem2.slot = slot
    pitem2.issuit = false
    PPM.pony_items[PPM.cid] = pitem2
    PPM.cid = PPM.cid + 1
    --table.Add(pony_items,pitem)

    return pitem
end

function PPM:AddFakeItem(basemodel, itemname, itemimg, itemBodygroupId, itemBodygroupValue, slot, varslot)
    local pitem = {}
    pitem.id = PPM.cid
    pitem.model = basemodel
    pitem.name = itemname
    pitem.img = itemimg
    pitem.bid = itemBodygroupId
    pitem.bval = itemBodygroupValue
    pitem.slot = slot
    pitem.varslot = varslot
    pitem.issuit = true
    PPM.pony_items[PPM.cid] = pitem
    PPM.cid = PPM.cid + 1
    local pitem2 = {}
    pitem2.id = PPM.cid
    pitem2.model = basemodel .. "nj"
    pitem2.name = itemname
    pitem2.img = itemimg
    pitem2.bid = itemBodygroupId
    pitem2.bval = itemBodygroupValue
    pitem2.slot = slot
    pitem2.varslot = varslot
    pitem2.issuit = true
    PPM.pony_items[PPM.cid] = pitem2
    PPM.cid = PPM.cid + 1
    --table.Add(pony_items,pitem)

    return pitem
end

function PPM:AddPPMEDItem(pitem)
    pitem.id = PPM.cid
    PPM.pony_items[PPM.cid] = pitem
    PPM.cid = PPM.cid + 1
    --table.Add(pony_items,pitem)

    return pitem
end

concommand.Add("test_add_item", function(ply) end)

concommand.Add("test_getall_items", function(ply)
    for i, k in pairs(PPM.pony_items) do
        MsgN(k.id .. " - " .. k.name .. " - " .. k.model .. " " .. k.bid .. " - " .. k.bval)
    end
end)

function PPM:GetAvailItems(playermodel, slotid)
    --MsgN(playermodel)
    local ait = {}

    for i, k in pairs(PPM.pony_items) do
        if (k.model == playermodel) and (table.HasValue(k.slot, slotid)) then
            ait[i] = k
        end
    end

    return ait
end

function PPM:GetEquippedItems(ply, playermodel)
    local ait = {}

    for i, k in pairs(PPM.pony_items) do
        if (k.model == playermodel) then
            for c = 1, 14 do
                --MsgN("FFFF "..c)
                if (k.model == "pony") or (k.model == "ponynj") then
                    --local bvalue = ply.ponydata.clothes1:GetBodygroup(c)
                    --if( k.bid == c and k.bval == bvalue) then
                    --	ait[k.bid] = k
                    --end
                else
                    local bvalue = ply:GetBodygroup(c)

                    if (k.bid == c and k.bval == bvalue) then
                        ait[k.bid] = k
                    end
                end
            end
        end
    end

    return ait
end

function PPM:pi_GetItemByName(itemname)
    for i, k in pairs(PPM.pony_items) do
        if (k.name == itemname) then return k end
    end

    return nil
end

function PPM:pi_GetItemById(itemid)
    return PPM.pony_items[itemid]
end

function PPM:pi_SetupItem(item, ply, fastignore)
    if not fastignore then
        ply.pi_wear = ply.pi_wear or {}

        for c, SLOT in pairs(item.slot) do
            ply.pi_wear[SLOT] = item
        end
    end

    if (item.model == "pony") or (item.model == "ponynj") then
        if SERVER then
            if not item.issuit then
                PPM.setBodygroupSafe(ply.ponydata.clothes1, item.bid, item.bval)
            end

            for k, v in pairs(item.slot) do
                if item.issuit then
                    ply.ponydata[item.varslot] = item.wearid
                    --PPM.serverPonydata[ply:EntIndex()][item.varslot] = item.wearid // Might be redundent but better safe than sorry
                    --PPM.SendCharToClients( ply )
                    --ply:SetNetworkedFloat("pny_"..item.varslot,item.wearid)
                    --print("setup item at ",item.varslot," to ",item.wearid)
                end
                --ply:SetNetworkedFloat("pny_clothing_slot"..v,item.id)
            end
            --PPM.setPonyValues(ply)
        end
    else
        if not item.issuit then
            --MsgN("bluh")
            PPM.setBodygroupSafe(ply, item.bid, item.bval)
        end
    end
    --MsgN("BODYGROUP CHANGE "..item.bid.."-"..item.bval)
end

function PPM:pi_UnequipAll(ply)
    if (ply.pi_wear ~= nil) then
        for I = 0, 14 do
            ply.pi_wear[I] = nil
            PPM.setBodygroupSafe(ply, I, 0)

            if ply.ponydata.clothes1 ~= nil then
                PPM.setBodygroupSafe(ply.ponydata.clothes1, I, 0)
            end
        end
        --[[
		for I,K in pairs(ply.pi_wear) do
			if(K!=nil)then
				ply:SetBodygroup(K.bid,0) 
				MsgN("Unwear "..I.." - " ..K.name)
				K = nil 
			end
				MsgN("Unwear "..I.." NONE")
		end 
		]]
    end
end

PPM:AddItem("pony", "None", "none", 1, 0, {0})

PPM:AddItem("pony", "None", "none", 2, 0, {1})

PPM:AddItem("pony", "None", "none", 3, 0, {2})

PPM:AddItem("pony", "None", "none", 8, 0, {7})

PPM:AddItem("pony", "Applejack hat", "aj_hat", 1, 1, {0})

PPM:AddItem("pony", "Braeburn hat", "brae_hat", 1, 2, {0})

PPM:AddItem("pony", "Trixie hat", "trix_hat", 1, 3, {0})

PPM:AddItem("pony", "Headphones", "headphones", 1, 4, {0})

PPM:AddItem("pony", "Scarf", "scarf", 2, 1, {1})

PPM:AddItem("pony", "Trixie cape", "trix_cape", 2, 2, {1})

PPM:AddItem("pony", "Tie", "tie", 2, 3, {1})

PPM:AddItem("pony", "Vest", "vest", 3, 1, {2})

PPM:AddItem("pony", "Shirt", "shirt", 3, 2, {2})

PPM:AddItem("pony", "Hoodie", "hoodie", 3, 3, {2})

PPM:AddItem("pony", "Wonderbolt badge", "badge_gold", 3, 4, {2})

PPM:AddItem("pony", "googles_f", "googles", 8, 1, {7})

PPM:AddItem("pony", "googles_m", "googles", 8, 2, {7})

PPM:AddItem("pony", "shades_f", "shades", 8, 3, {7})

PPM:AddItem("pony", "shades_m", "shades", 8, 4, {7})

PPM:AddItem("pony", "mono_l", "monocle", 8, 5, {7})

PPM:AddItem("pony", "mono_r", "monocle", 8, 6, {7})

PPM:AddItem("pony", "eyepatch_l", "eyepatch", 8, 7, {7})

PPM:AddItem("pony", "eyepatch_r", "eyepatch", 8, 8, {7})

PPM:AddFakeItem("pony", "None", "none", 99, 99, {50}, "bodyt0").wearid = 1

PPM:AddFakeItem("pony", "Wonderforce light", "unf_wnd", 99, 99, {50}, "bodyt0").wearid = 2

PPM:AddFakeItem("pony", "Wonderforce", "unf_wnd", 99, 99, {50}, "bodyt0").wearid = 3

PPM:AddFakeItem("pony", "Shadowforce", "unf_sbs", 99, 99, {50}, "bodyt0").wearid = 4

PPM:AddFakeItem("pony", "Shadowforce light", "unf_sbs", 99, 99, {50}, "bodyt0").wearid = 5

PPM:AddFakeItem("pony", "Royal guard captain", "unf_rgc", 99, 99, {50}, "bodyt0").wearid = 6
--[[
PPM:AddPPMEDItem({
	model = basemodel,
	name = itemname,
	img = itemimg,
	bid = itemBodygroupId,
	bval = itemBodygroupValue,
	slot = slot,
	issuit = true
})
]]