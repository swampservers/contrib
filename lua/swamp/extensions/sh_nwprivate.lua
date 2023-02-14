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

            if st then
                out[st] = API_ANY[1]()
            else
                out[1] = API_List(API_NETWORK_STRING).Read()
            end
        end

        return out
    end,
    function(val)
        local removals = val[1]
        local count = table.Count(val)

        if removals and table.IsEmpty(removals) then
            count = count - 1
        end

        net.WriteLength(count)

        for k, v in pairs(val) do
            if k ~= 1 then
                API_NETWORK_STRING[2](k)
                API_ANY[2](v)
            end
        end

        if removals and not table.IsEmpty(removals) then
            API_NETWORK_STRING[2](nil)
            API_Set(API_NETWORK_STRING).Write(removals)
        end
    end
}

function ApplyNetworkStringTableUpdate(tab, update)
    local remove = update[1]
    update[1] = nil

    for k, v in pairs(update) do
        tab[k] = v
    end

    for i, v in ipairs(remove) do
        tab[v] = nil
    end
end

API_Command("UpdateNW", {API_ENTITY_HANDLE, API_NETWORK_STRING_TABLE_UPDATE}, function(eh, update)
    eh:OnValid(function(ent)
        ent.NW = ent.NW or {}
        ApplyNetworkStringTableUpdate(ent.NW, update)
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
