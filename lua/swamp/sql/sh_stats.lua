-- This file is subject to copyright - contact swampservers@gmail.com for more information.

--- Get the value of the stat with the given name. If default isn't given it is 0
function Player:GetStat(name, default)
    local v = self.NWP["s_" .. name]
    if v==nil then v=default end
    if v==nil then v=0 end
    return v
end

-- function Player:GetFlag(name)
--     return self.NWP["f_" .. name] or false
-- end
-- they are strings with 4 bytes for each user (accountid u32)
-- todo LRU?
local partnersetcache = {}

function InPartnerSet(pset, ply)
    if ply:IsBot() then return false end
    local t = partnersetcache[pset]

    if not t then
        t = {}
        local n = #pset

        for i = 1, n, 4 do
            t[pset:sub(i, i + 3)] = true
        end

        partnersetcache[pset] = t
    end

    return t[bit.packu32(ply:AccountID())]
end

function AddToPartnerSet(pset, ply)
    assert(not ply:IsBot())
    if InPartnerSet(pset, ply) then return pset end
    local pid = bit.packu32(ply:AccountID())
    local newpset = pset .. pid
    -- move the cache to make it faster and because we probably dont need it again
    local t = partnersetcache[pset]
    partnersetcache[pset] = nil
    t[pid] = true
    partnersetcache[newpset] = t

    return newpset
end

function PartnerSetSize(pset)
    return pset:len() / 4
end
--NOMINIFY
