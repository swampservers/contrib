AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:SpawnFunction( ply, tr )

    if !tr.Hit then return end

    local SpawnPos = tr.HitPos + tr.HitNormal * 16
    local ent = ents.Create( self.ClassName )
    ent:SetPos( SpawnPos + Vector( 0, 0, 4 ) )
    ent:Spawn()
    ent:Activate()

    return ent

end