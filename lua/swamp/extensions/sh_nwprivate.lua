-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--- NWP="Networked Private"
-- A table on each player. Values written on server will automatically be replicated to that client. Won't be sent to other players. Read-only on client, read-write on server.
--- ply.NWP = {}
--NOMINIFY
-- TODO: should we use the stringtable for key names?
-- TODO try API_NETWORK_STRING
API_NETWORK_STRING_TABLE_UPDATE = {
    function()
        local out, nvals = {{}}, net.ReadLength()

        for i = 1, nvals do
            local st = API_NETWORK_STRING[1]()
            out[st] = API_ANY[1]()

            if out[st] == nil then
                out[1][st] = true
            end
        end

        return out
    end,
    function(val)
        local removals = val[1]
        local count = table.Count(val)

        if removals then
            -- Remove the [1] entry from the count
            count = count - 1

            if not table.IsEmpty(removals) then
                -- Add whatever number of strings is in removals
                count = count + table.Count(removals)
            end
        end

        net.WriteLength(count)

        for k, v in pairs(val) do
            if k ~= 1 then
                API_NETWORK_STRING[2](k)
                API_ANY[2](v)
            end
        end

        -- Test case for removals: lua_run local ply = player.GetHumans()[1] ply.NWP.valentine_t = 0 timer.Simple(1, function() ply.NWP.valentine_t = nil end)
        if removals and not table.IsEmpty(removals) then
            for k in pairs(removals) do
                API_NETWORK_STRING[2](k)
                API_ANY[2](nil)
            end
            -- TODO(winter): The below implementation of removals breaks the net api, so I've rewritten it
            -- API_Set is a total unreadable mess. Somebody else can unfuck it if they want
            --API_NETWORK_STRING[2](nil)
            --API_Set(API_NETWORK_STRING)[2](removals)
        end
    end
}

function ApplyNetworkStringTableUpdate(tab, update)
    local remove = update[1]
    update[1] = nil

    for k, v in pairs(update) do
        tab[k] = v
    end

    for k in pairs(remove) do
        tab[k] = nil
    end
end

API_Command("UpdateNW", {API_ENTITY_HANDLE, API_NETWORK_STRING_TABLE_UPDATE}, function(eh, update)
    eh:OnValid(function(ent)
        ent.NW = ent.NW or {}
        ApplyNetworkStringTableUpdate(ent.NW, update)

        if CLIENT and (update and (update["ValentineName"] or (update[1] and update[1]["ValentineName"]))) then
            ShopProducts["valentine"]:Update()

            if IsValid(ShopPanel) then
                ShopPanel:RefreshInventory()
            end
        end
    end)
end)

API_Command("UpdateNWP", {API_NETWORK_STRING_TABLE_UPDATE}, function(update)
    ApplyNetworkStringTableUpdate(NWPrivate, update)
end)

API_Command("UpdateNWG", {API_NETWORK_STRING_TABLE_UPDATE}, function(update)
    ApplyNetworkStringTableUpdate(NWGlobal, update)
end)

if CLIENT then
    NWGlobal = NWGlobal or {}
    NWPrivate = NWPrivate or {}

    hook.Add("OnEntityCreated", "NWPrivate", function(ent)
        ent.NW = ent.NW or {}

        if ent == LocalPlayer() then
            ent.NWP = NWPrivate
        end
    end)
end
