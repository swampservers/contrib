-- This file is subject to copyright - contact swampservers@gmail.com for more information.

--Keemstar entity for Swamp Cinema boss battle

AddCSLuaFile()
DEFINE_BASECLASS( "base_gmodentity" )

ENT.Spawnable			= false

local MODEL			= Model( "models/gnome/gardengnome.mdl" )


function ENT:Initialize()

	self.lives = 3

	self:EmitSound("keem/intro.wav")

	if ( SERVER ) then --lights are rolling around even though the model isn't round!!

		self:SetModel( MODEL )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		--self:DrawShadow( false )
	
		local phys = self:GetPhysicsObject()
	
		if (phys:IsValid()) then
			phys:EnableMotion(false)
			phys:Wake()

		end

	end
end


--[[---------------------------------------------------------
   Name: Think
-----------------------------------------------------------]]
function ENT:Think()

	self.BaseClass.Think( self )

	local hasTarget = false

	if CurTime() > (self.TargetThink or 0) then
		self.TargetThink = CurTime()+0.1
		local temp = Location.GetPlayersInLocation(Location.GetLocationIndexByName("Rat's Lair"))
		for k,v in pairs(temp) do
			if !v:Alive() then table.remove(temp,k) end
			--trace here (test this!)
			if v:GetPos():DistToSqr(self:GetPos())>18000 then
				if util.TraceLine({ start= self:GetPos() + Vector(0,0,10), endpos = v:GetPos() + Vector(0,0,32), mask=MASK_SOLID_BRUSHONLY }).Hit then table.remove(temp,k) end
			end
		end
		if math.random(1,8)==1 then self.Target = table.Random(temp) end
		for k,v in pairs(temp) do
			if (((self.NoAttack or 0) < CurTime()) or (((!v:HasWeapon("weapon_flare")) or v:GetPos().y>self:GetPos().y) and (self.NoPunch or 0) < CurTime())) and SERVER then 
				if v:GetPos():DistToSqr(self:GetPos())<18000 then
					self:EmitSound("keem/nigger.wav")
					v:EmitSound("keem/punch.wav")
					v:SetPos(v:GetPos()+Vector(0,0,1))
					v:SetVelocity(Vector(0,-500,500))
					v:TakeDamage( 35, self, self)

					local pos = v:GetPos()
					for i=1,5 do 
						local add = Vector(math.random(-100,100),math.random(-100,100),math.random(-100,10))
						--if add:Dot(trace.HitNormal)<0 then add = add*-1 end
						local tr = util.TraceLine({ start= pos, endpos = pos+add } )
						if tr.Hit then
							local Pos1 = tr.HitPos + (tr.HitNormal*2)
							local Pos2 = tr.HitPos - tr.HitNormal

							local Bone = tr.Entity:GetPhysicsObjectNum( tr.PhysicsBone or 0 )
							if ( !Bone ) then
								Bone = tr.Entity
							end

							Pos1 = Bone:WorldToLocal( Pos1 )
							Pos2 = Bone:WorldToLocal( Pos2 )

							PaintPlaceDecal( ply, tr.Entity, { Pos1 = Pos1, Pos2 = Pos2, bone = tr.PhysicsBone, decal = "Blood" } )
						end
					end

				end
			end
		end
	end

	if self:IsOnFire() then
		self:SetAngles(Angle(0,(CurTime()*-700) %360,0))
	else
		if IsValid(self.Target) and self:GetPos():DistToSqr(self.Target:GetPos())<100000 then
			local temp = self:GetPos()-self.Target:GetPos()
			temp.z = 0
			self:SetAngles(temp:Angle())
			hasTarget = true
		else
			self:SetAngles(Angle(0,90,0))
		end
	end

	if CurTime() > (self.AttackThink or 0) and (!self:IsOnFire()) and SERVER then
		self.AttackThink = CurTime()+0.35
		if hasTarget then
			if math.random(1,6)==1 then
				self:ThrowPopcorn()
			end

			if math.random(1,7)==1 and CurTime() > (self.NextTaunt or 0) then
				local taunt = math.random(1,4)
				if taunt<=1 then
					self:EmitSound("keem/fuckingnigger.wav")
					self.NextTaunt = CurTime()+1.2
				elseif taunt<=2 then
					self:EmitSound("keem/stupidbitch.wav")
					self.NextTaunt = CurTime()+1.8
				elseif taunt<=3 then
					self:EmitSound("keem/report.wav")
					self.NextTaunt = CurTime()+2.2
				else
					self:EmitSound("keem/swingatme.wav")
					self.NextTaunt = CurTime()+3
					self.NoAttack = CurTime()+5.5
				end
			end
		end
	end

end

function ENT:ThrowPopcorn()
	--if (self.NoAttack or 0) > CurTime() then
		--return
	--end
	bucket = ents.Create( "sent_popcorn_thrown" )
	bucket.Damaging = true
    bucket:SetOwner( self )
    bucket:SetPos( self:GetPos() + Vector(0,0,10) )
    bucket:Spawn() 
    bucket:Activate()
	
    phys = bucket:GetPhysicsObject( )
        
    if IsValid( phys ) then
    	local ang = -self:GetAngles():Forward()
    	ang = ang+Vector(0,0,math.Rand(0.22,0.35))
		phys:AddVelocity( ang * (72+math.random(0,24)) * phys:GetMass( ) )
		phys:AddAngleVelocity( VectorRand() * 128 * phys:GetMass( ) )
    end

    if math.random(1,6)==1 then
		timer.Simple(0.2,function() self:ThrowPopcorn() end)
	end
end


function ENT:Draw()
	BaseClass.Draw(self) --, true)
end

--[[---------------------------------------------------------
   Name: OnTakeDamage
-----------------------------------------------------------]]
function ENT:FireAttack( )
	if self:IsOnFire() then return end
	self:Ignite(4,0)
	self:EmitSound("ambient/voices/f_scream1.wav")
	timer.Simple(4, function()
		if IsValid(self) then self:Extinguish() end
	end)
	self.NoPunch = CurTime()+1
	self.lives = self.lives - 1
	if self.lives<1 then
		timer.Simple(3, function()
			local effectdata = EffectData()
		 effectdata:SetOrigin(self:GetPos() )
		 effectdata:SetMagnitude(0)
		util.Effect( "Explosion", effectdata, true, true )
		if SERVER then self:Remove() end
		end)
	end
end
