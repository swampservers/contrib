-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--- NWP="Networked Private"
-- A table on each player. Values written on server will automatically be replicated to that client. Won't be sent to other players. Read-only on client, read-write on server.
--- ply.NWP = {}
-- TODO: should we use the stringtable for key names?
-- TODO try API_NETWORK_STRING
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
