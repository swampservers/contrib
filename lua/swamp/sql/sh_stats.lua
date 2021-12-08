-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local Player = FindMetaTable("Player")

function Player:GetStat(name)
    return self.NWPrivate["s_" .. name] or 0
end

function Player:GetFlag(name)
    return self.NWPrivate["f_" .. name] or false
end
