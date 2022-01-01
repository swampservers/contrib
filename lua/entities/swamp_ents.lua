-- This file is subject to copyright - contact swampservers@gmail.com for more information.
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"

-- has to be copied from autorun to make autorefresh work
Include = function(fn)
    -- print("INCLUDE2",fn)
    include(fn)
end

LoadSwampEntities()
