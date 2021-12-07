-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- Similar to GetNW* but only works on players and is not sent to other players. Use ply:SetPrivate on server
local Player = FindMetaTable("Player")
NWPrivates = NWPrivates or {}

net.Receive("UpdatePrivates", function(len)
    table.Merge(NWPrivates, net.ReadTable())
end)

function Player:GetPrivate(k, default)
    assert(self == LocalPlayer())

    return NWPrivates[k] or default
end
