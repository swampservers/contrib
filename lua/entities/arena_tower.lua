AddCSLuaFile()
DEFINE_BASECLASS( "base_gmodentity" )

function ENT:Initialize()

    self:SetModel( "models/swamp_cinema/sharktemplarbarricadertowerv3.mdl" )
    self:SetMoveType( MOVETYPE_NONE )
	self:PhysicsInitStatic(SOLID_VPHYSICS)
	
--	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
    --	phys:Wake()
        phys:EnableMotion(false)
	end
end

local boxnormlz = {
    Vector(1,0,0),
    Vector(-1,0,0),
    Vector(0,1,0),
    Vector(0,-1,0),
    Vector(0,0,1),
    Vector(0,0,-1)
}

function ENT:Draw()
    render.SuppressEngineLighting(true)

    local uplight = render.ComputeLighting(self:GetPos(), Vector(0,0,1)) - render.ComputeDynamicLighting(self:GetPos(), Vector(0,0,1))
    local dnlight = render.ComputeLighting(self:GetPos(), Vector(0,0,-1)) - render.ComputeDynamicLighting(self:GetPos(), Vector(0,0,-1))

    --uplight = LerpVector(0, uplight, Vector(1,1,1))
    --dnlight = LerpVector(0, dnlight, Vector(1,1,1))
    uplight = uplight + Vector(0.01,0.01,0.01)
    dnlight = dnlight + Vector(0.03,0.03,0.03)

    local m = 1.5
    render.SetColorModulation(m,m,m)

    render.SetModelLighting(4, uplight.x, uplight.y, uplight.z)
    render.SetModelLighting(5, dnlight.x, dnlight.y, dnlight.z)

    for boxx=0,3 do
        local sampld = LerpVector(0.35 + 0.1*boxx, uplight, dnlight)
        render.SetModelLighting(boxx, sampld.x, sampld.y, sampld.z)
    end

    self:DrawModel()
    render.SuppressEngineLighting(false)

    render.SetColorModulation(1,1,1)
end

if SERVER then
    hook.Add("InitPostEntity", "spawntower", function()
        local e = ents.Create("arena_tower")
        e:SetPos(Vector(-300,-1862,256))
        e:SetAngles(Angle(0,-90,0))
        e:Spawn()
        e:Activate()
    end)
end
