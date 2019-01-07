AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:InitializeAfter()

	self:SetupChair( 
		Vector( 75, 0, 0 ), Angle( 0, 0, 0 ), // chair model
		Vector( 0, 10, 24 ), Angle( 0, 90, 0 ) // actual chair
	)

end

function ENT:SpawnFunction( ply, tr )

    if !tr.Hit then return end

    local SpawnPos = tr.HitPos + tr.HitNormal * 16
    local ent = ents.Create( self.ClassName )
    ent:SetPos( SpawnPos + Vector( 0, 0, 4 ) )
    ent:Spawn()
    ent:Activate()

    return ent

end