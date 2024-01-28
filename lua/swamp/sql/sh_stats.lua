-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--- Get the value of the stat with the given name. If default isn't given it is 0
function Player:GetStat(name, default)
    local v = self.NWP["s_" .. name]

    if v == nil then
        v = default
    end

    if v == nil then
        v = 0
    end

    return v
end

-- function Player:GetFlag(name)
--     return self.NWP["f_" .. name] or false
-- end
-- they are strings with 4 bytes for each user (accountid u32)
-- TODO: LRU?
partnersetcache = {}

function InGroupSet(pset, ply)
    if not isnumber(ply) then
        if ply:IsBot() then return false end
        ply = ply:AccountID()
    end

    local t = partnersetcache[pset]

    if not t then
        t = {}
        local n = #pset

        for i = 1, n, 4 do
            t[pset:sub(i, i + 3)] = true
        end

        partnersetcache[pset] = t
    end

    return t[bit.packu32(ply)]
end

function GroupSetSize(pset)
    return pset:len() / 4
end
--NOMINIFY
