-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--- NWP="Networked Private"
-- A table on each player. Values written on server will automatically be replicated to that client. Won't be sent to other players. Read-only on client, read-write on server.
--- ply.NWP = {}
-- TODO: should we use the stringtable for key names?
-- TODO try API_NETWORK_STRING
API_Command("UpdateNWPrivates", {
    {
        [API_NETWORK_STRING] = API_ANY
    },
    {API_NETWORK_STRING}
}, function(change, remove)
    for k, v in pairs(change) do
        NWPrivate[k] = v
        -- print(k,v)
    end

    for i, v in ipairs(remove) do
        NWPrivate[v] = nil
        -- print(v, nil)
    end
end)

if CLIENT then
    NWPrivate = NWPrivate or {}

    -- TODO rename to NWP
    -- NWPrivateListener = NWPrivateListener or {}
    net.Receive("UpdatePrivates", function(len)
        for k, v in pairs(net.ReadTableHD()) do
            NWPrivate[k] = v
            -- if NWPrivateListener[k] then NWPrivateListener[k](Me, v) end
        end

        -- doesnt work
        -- local a,b = net.BytesLeft()
        -- if b>0 then
        for k, _ in pairs(net.ReadTableHD()) do
            NWPrivate[k] = nil
            -- if NWPrivateListener[k] then NWPrivateListener[k](Me, nil) end
        end
    end)

    hook.Add("OnEntityCreated", "NWPrivate", function(ply)
        if ply == Me then
            -- todo maybe just set this to NWPrivate directly to skip extra call
            ply.NWP = setmetatable({}, {
                __index = function(t, k) return NWPrivate[k] end,
                __newindex = function(t, k, v)
                    assert(false)
                end
            })
        end
    end)
end
