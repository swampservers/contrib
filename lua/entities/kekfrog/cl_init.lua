-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")


local mat = Material("models/swamponions/kekfrog_gold")

function ENT:Draw()
    render.MaterialOverride(mat)
    self:DrawModel()
    render.MaterialOverride()
end

local keksaytime = -100

function SaidKek()
    keksaytime = CurTime()
end

hook.Add( "PreDrawHalos", "AddPropHalos", function()
    local alpha = math.sin(CurTime()*10)*0.25 + 0.75
    local td = CurTime() - keksaytime
    if td < 8 then 
        alpha  = alpha * math.Clamp(td,0,1) * math.Clamp(8-td,0,1)
	    halo.Add(Ents.kekfrog, Color(255,255,255,255*alpha), 5, 5, 16,true,true )
    end
end )


