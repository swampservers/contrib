-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	local emitter = ParticleEmitter(pos)
	
		local flare = emitter:Add("sprites/glow04_noz", pos-norm)
			flare:SetVelocity(Vector(0,0,0))
			flare:SetAirResistance(0)
			flare:SetGravity(Vector(0, 0, 0))
			flare:SetDieTime(.5)
			flare:SetStartAlpha(255)
			flare:SetEndAlpha(0)
			flare:SetStartSize(160)
			flare:SetEndSize(0)
			flare:SetRoll(math.Rand(-90, 90))
			flare:SetRollDelta(math.Rand(-2, 2))
			flare:SetColor(0, 255, 140)			
		
		for i = 1, 6 do
			local fire = emitter:Add("effects/fire_cloud1", pos)
			fire:SetVelocity(VectorRand() * i * 60)
			fire:SetAirResistance(100)
			fire:SetGravity(Vector(0, 0, 50))
			fire:SetDieTime(math.Rand(.25, 1.25))
			fire:SetStartAlpha(200)
			fire:SetEndAlpha(0)
			fire:SetStartSize(math.Rand(30, 40))
			fire:SetEndSize(math.Rand(200, 220))
			fire:SetRoll(math.Rand(-90, 90))
			fire:SetRollDelta(math.Rand(-.5, .5))
			fire:SetColor(40, 200, 150)
		end

		for i = 0, 8 do
			local particle = emitter:Add("particle/particle_smokegrenade", pos)
			particle:SetVelocity(VectorRand() * 300)
			particle:SetAirResistance(100)
			particle:SetGravity(Vector(0, 0, 50))
			particle:SetDieTime(math.Rand(1, 3))
			particle:SetStartAlpha(140)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 60))
			particle:SetEndSize(math.Rand(130, 200))
			particle:SetRoll(math.Rand(-90, 90))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(20, 140, 80)
		end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
