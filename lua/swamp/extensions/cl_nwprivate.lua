-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- Similar to GetNW* but only works on players and is not sent to other players. Use ply:SetPrivate on server
local Player = FindMetaTable("Player")
NWPrivate = NWPrivate or {}

--NOMINIFY
-- NWPrivateListener = NWPrivateListener or {}
net.Receive("UpdatePrivates", function(len)
    for k, v in pairs(net.ReadTable()) do
        NWPrivate[k] = v
        -- if NWPrivateListener[k] then NWPrivateListener[k](Me, v) end
    end

    -- doesnt work
    -- local a,b = net.BytesLeft()
    -- if b>0 then
    for k, _ in pairs(net.ReadTable()) do
        NWPrivate[k] = nil
        -- if NWPrivateListener[k] then NWPrivateListener[k](Me, nil) end
    end
end)

-- end
hook.Add("OnEntityCreated", "NWPrivate", function(ply)
    if ply == Me then
        ply.NWPrivate = setmetatable({}, {
            __index = function(t, k) return NWPrivate[k] end,
            __newindex = function(t, k, v)
                assert(false)
            end
        })
    end
end)
