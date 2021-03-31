-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

include("shared.lua")
include("sv_spawning.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

local RELEVANT_KLEINER
ENT.LoseTargetDist = 3000
ENT.SearchRadius = 1000
ENT.KillReward = 100
ENT.KillRewardBased = 10000
ENT.TargetHeight = 2048
ENT.TargetHeightInner = 4096
ENT.TargetHeightInnerRadius = 512

local KleinerNPCTotalPathingBudget = 20000
local function KleinerPathingIterationLimit()
	--if(IsValid(KLEINER_OVERRIDE_TARGET))then return KleinerNPCTotalPathingBudget end
	return (KLEINER_NPCS_CURRENT_NUMBER != nil and KLEINER_NPCS_CURRENT_NUMBER > 0 and math.floor(KleinerNPCTotalPathingBudget / KLEINER_NPCS_CURRENT_NUMBER)) or 1000
end


local function KleinerPathingRateHigh()
	return (KLEINER_NPCS_CURRENT_NUMBER != nil and KLEINER_NPCS_CURRENT_NUMBER > 0 and math.Clamp(0.5 + (KLEINER_NPCS_CURRENT_NUMBER / 3),0.5,20)) or 0.5
end

--util.AddNetworkString("kleinernpc_warning")


function ENT:Initialize() 

	self:SetModel( "models/kleiner.mdl" )
	self:SetGravity(200)
	self:SetSubMaterial(5,"models/kleiner/players_sheet")
	self:SetUseType(SIMPLE_USE)
	self:SetBased(math.random(1,10) == 1)
	self:SetHealth(self:GetBased() and 200 or 50)
		if(self:GetBased())then
			self:SetSubMaterial(3,"models/pyroteknik/jokleiner_face")
		else
			if(math.random(1,100) == 1)then --hl2 style kleiner
				self:SetSubMaterial(5,"")
			end	
		end
		if(math.random(1,25) == 1)then --remove glasses
			self:SetSubMaterial(2,"engine/occlusionproxy")
			self:SetSubMaterial(6,"engine/occlusionproxy")
			self:SetSubMaterial(7,"engine/occlusionproxy")
		elseif(math.random(1,25) == 1)then --epic sunglasses
			self:SetSubMaterial(7,"tools/toolsblack")
		end
	
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:ResetBehavior()
end




function ENT:Use(ply)
	if(self.NextUse and self.NextUse > CurTime())then return end
	if(self.Suicidal)then
		self:EmitSound("buttons/button10.wav")
		self.NextUse = CurTime() + 0.5
		return
	end
	if(self:GetTarget() == ply)then  --ResetBehavior will make kleiner select a new target. If the new target is the same, have a different reaction
		self:ResetBehavior()
		if(self:GetTarget() == ply)then
			self:Speak("vo/k_lab/kl_hedyno03.wav")
			self:EmitSound("buttons/button10.wav")
			self.NextUse = CurTime() + 0.5
			self.ManualTarget = true
		else
			self:Speak("vo/k_lab/kl_dearme.wav")
			self:EmitSound("ui/buttonclickrelease.wav")
			self.NextUse = CurTime() + 0.5
		end
	else
		self:ResetBehavior()
		self:SetTarget(ply)
		self:Speak("vo/k_lab/kl_excellent.wav")
		self:EmitSound("ui/buttonclickrelease.wav")
		self.NextUse = CurTime() + 0.5
		self.ManualTarget = true
	end
end

function ENT:Speak(snd)
	if(self.Suicidal)then return end
	if(self.LastSound)then self:StopSound(self.LastSound) end 
	self:EmitSound(snd,60,nil,nil,nil,nil,56)
	self.LastSound = snd
	local dur = SoundDuration(snd)
	self:SetTalking(CurTime() + dur - 0.2)
	return dur
end

function ENT:IsTalking()
return self:GetTalking() > CurTime()
end

function ENT:WaveHands()
	if(self.Suicidal)then return end
	local num = math.random(1,13)
	self:AddGestureSequence(self:LookupSequence("kgesture"..(num > 9 and "" or "0" )..num))
end


function ENT:SayStuff(snd)
	if(self:IsTalking())then return end
	if(math.random(1,100) <= self:GetTargetViolence(self:GetTarget()) + (self:GetBased() and self:GetTargetViolence(self:GetTarget()) > 0 and 20 or 0))then   snd = "vo/k_lab/kl_initializing.wav" end
	local gesture = true
	snd = snd or table.Random(self.Chatter)
	local dur = self:Speak(snd)
	if(snd == "vo/k_lab/kl_initializing.wav")then
		self:PullGrenades()
	end
	
	local delay = 0
	if(gesture)then
		for i=1,math.random(1,3) do
			timer.Simple(delay,function()
				if(IsValid(self))then
					self:WaveHands()
				end
			end)
			delay = delay + math.Rand(0.2,0.8)
		end
	end
end

local PainSounds = {"vo/k_lab/kl_ahhhh.wav","vo/k_lab/kl_hedyno03.wav"}

function ENT:OnInjured( damageinfo )
	if(self.Suicidal)then return end
	if(damageinfo:GetDamage() > self:Health() / 20)then
		local snd = table.Random(PainSounds)
		self:Speak(snd)
		self:AddGestureSequence(self:LookupSequence("fear_reaction_gesture"))
	end
end

function ENT:OnKilled( dmginfo )
	self:StopSound(self.LastSound or "")
	self:DropGrenades()
	
	hook.Run( "OnNPCKilled", self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	if(SERVER)then
		local attacker = dmginfo:GetAttacker()
		
		if(IsValid(attacker) and attacker:IsPlayer())then 
		self:AddTargetViolence(attacker)
			local reward = self:GetBased() and self.KillRewardBased or self.KillReward
			if(attacker.PS_AddPoints)then attacker:PS_AddPoints(reward) end
		end
		self.IsAlive = false
	end
	
	
	
	local rag = self:BecomeRagdoll( dmginfo )	

end


function ENT:BodyUpdate()	
	local act = ACT_IDLE
	if(self.loco:GetVelocity():Length() > 1)then act = ACT_WALK end
	if(self.loco:GetVelocity():Length() > 150)then act = ACT_RUN end
	if(!self:OnGround())then
	act = ACT_JUMP
	end
	if(self.ClimbDir == 1)then act = ACT_IDLE end
	if(self.ClimbDir == -1)then act = ACT_IDLE end
	
	self.MainActivity = act
	if(self:GetActivity() != self.MainActivity)then self:StartActivity(self.MainActivity) end
	self:BodyMoveXY()
end

function ENT:PullGrenades()
	if(IsValid(self))then	
		self:AddGestureSequence(self:LookupSequence("startleclipboardgesture"))
		
		timer.Simple(2.4,function()
			if(IsValid(self) )then
			self:AddGestureSequence(self:LookupSequence("blowclipboardgesture"))
			end
		end)

		self.Suicidal = true
		
		local pos,ang = self:GetBonePosition(self:LookupBone("ValveBiped.Bip01_L_Hand") or 0)
		pos = pos + ang:Right() * 2
		pos = pos + ang:Forward() * 4
		local gren = self:SpawnGrenade()
		gren:SetPos(pos)
		gren:SetAngles(ang)
		gren:SetParent(self,10)
		self.Grenade1 = gren
		local pos,ang = self:GetBonePosition(self:LookupBone("ValveBiped.Bip01_R_Hand") or 0)
		pos = pos + ang:Right() * 2
		pos = pos + ang:Forward() * 4
		ang:RotateAroundAxis(ang:Right(),180)
		local gren = self:SpawnGrenade()
		gren:SetPos(pos)
		gren:SetAngles(ang)
		gren:SetParent(self,11)
		self.Grenade2 = gren
		timer.Simple(1,function()
			if(IsValid(self) )then
			if(IsValid(self:GetTarget()) )then self:SetTargetViolence(self:GetTarget(),math.floor(self:GetTargetViolence(self:GetTarget())/1.15)) end
				if(IsValid(self.Grenade1) and IsValid(self.Grenade1:GetParent()))then self.Grenade1.DamageTriggered = true self.Grenade1:Fire("SetTimer",3) end
				if(IsValid(self.Grenade2) and IsValid(self.Grenade2:GetParent()))then self.Grenade1.DamageTriggered = true self.Grenade2:Fire("SetTimer",3) end
			end
		end)
	end
end

function ENT:SpawnGrenade()
	local gren = ents.Create("npc_grenade_frag")
	gren:Spawn()
	gren:Activate()
	gren:SetMoveType(MOVETYPE_NONE)
	gren:PhysicsDestroy()
	gren:SetCollisionGroup(COLLISION_GROUP_WORLD)
	gren:SetOwner(self)
	gren.Owner = self
	return gren
end

function ENT:DropGrenades()
	if(IsValid(self.Grenade1))then 
		local gren = self.Grenade1
		gren:SetParent() 
		gren:PhysicsInit(MOVETYPE_VPHYSICS) 
		gren:GetPhysicsObject():Wake() 
		timer.Simple(60*15,function()
			if(IsValid(gren))then
			gren:Remove()
			end
		end)
	end
	if(IsValid(self.Grenade2))then 
		local gren = self.Grenade2
		gren:SetParent() 
		gren:PhysicsInit(MOVETYPE_VPHYSICS) 
		gren:GetPhysicsObject():Wake() 
		timer.Simple(60*15,function()
			if(IsValid(gren))then
			gren:Remove()
			end
		end)
	end
end


if(SERVER)then
KLEINER_BULLIES = KLEINER_BULLIES or {}
end
 
 
function ENT:PosInRange(pos)
	local heightlimit = self.TargetHeight*1
	local horizontalrange = (self:GetPos()*Vector(1,1,0)):Distance(pos*Vector(1,1,0))
	local heightdiff = math.abs((self:GetPos() - pos).z)
	if(horizontalrange < self.TargetHeightInnerRadius)then
		heightlimit = self.TargetHeightInner
	end
	return horizontalrange <= self.LoseTargetDist and heightdiff <= heightlimit
end
 
function ENT:CanBeTarget(ent)
	if(!IsValid(ent))then return false end
	if(ent == self)then return false end

	if(ent.InVehicle and ent:InVehicle())then return false end
	if(ent.Alive and !ent:Alive())then return false end
	if(ent:GetMoveType() == MOVETYPE_FLY)then return false end
	if(player.IsAFK and player:IsAFK())then return false end
	if(Safe and Safe(ent) and ent:IsPlayer())then return false end
	if(self.TargetBlacklist and self.TargetBlacklist[ent] and self.TargetBlacklist[ent] > CurTime())then return false end
	if(!self:PosInRange(ent:GetPos()))then return false end
	return true
end

function ENT:CanBecomeTarget(ent) --use this if you want to add special requirements for the entity to become a target
	if(self:GetRangeTo(ent) > self.SearchRadius and self:GetTargetPriority(ent) < 100 )then return false end
	return self:CanBeTarget(ent)
end

function ENT:NearTarget()
	if(!IsValid(self:GetTarget()))then return false end
	return self:GetPos():Distance(self:GetTarget():GetPos()) < 90
end


function ENT:GetTargetPriority(ent)
	if(!IsValid(ent))then return 0 end
	local priority = ent:IsPlayer() and 1 or 0.05 --base amount
	if(ent == KLEINER_OVERRIDE_TARGET)then priority = 100 end
	if(self:GetTargetViolence(ent) > 0)then priority = priority * (1+(self:GetTargetViolence(ent)/10)) end -- 10% gain based on aggression towards kleiner
	priority = priority * (1  + (math.Clamp(self.LoseTargetDist - self:GetRangeTo(ent),0,self.LoseTargetDist) / self.LoseTargetDist)/5) --up to 20% gain based on proximity
	return priority
end

function ENT:GetTargetViolence(ent)
	if(!IsValid(ent))then return -1 end
	if(ent:GetClass() == "kleiner")then return -1 end
	if(ent:IsPlayer() and KLEINER_BULLIES[ent:SteamID()])then return KLEINER_BULLIES[ent:SteamID()] end 
	return 0
end

function ENT:SetTargetViolence(ent,amount)
	if(!IsValid(ent))then return end
	if(ent:IsPlayer())then 		
			KLEINER_BULLIES[ent:SteamID()] = amount
			--[[
			net.Start("kleinernpc_warning")
			net.WriteInt(amount,16)
			net.Send(ent)
			]]
	end
end

function ENT:AddTargetViolence(ent)
	if(!IsValid(ent))then return end
	if(ent:IsPlayer())then self:SetTargetViolence(ent,self:GetTargetViolence(ent) + 1)  end
end

function ENT:HaveTarget()
	local target = self:GetTarget()
	if ( IsValid(target) and self:CanBeTarget(target) ) then
		return true 
	end
	return self:FindTarget()
end

function ENT:GetTargetTable()
	local tab = {}
	if(KLEINER_NPC_TARGETS)then
		for k,v in pairs(KLEINER_NPC_TARGETS)do
			table.insert(tab,k)
		end
	end
	return tab
end

function ENT:FindTarget()
	if(self.Suicidal)then return true end --while holding grenades, cannot have target changed
	if(self.NextTargetTime and self.NextTargetTime > CurTime())then 
		self:SetTarget(nil)
		return false
	end 
	local _ents = KLEINER_NPC_TARGETS
	local targetsum = 0 
	local targets = {} 
	local targetcount = 0
	local playersum = 0
	for ent,val in pairs( _ents ) do
		if ( self:CanBecomeTarget(ent)) then
			if(ent:IsPlayer())then playersum = playersum + 1 end
			table.insert(targets,ent)
			targetsum = targetsum + self:GetTargetPriority(ent)
			targetcount = targetcount + 1
		end 
	end	
	targetsum = targetsum + (targetcount*0.5) 
	local samplevalue = math.Rand(0,1)*targetsum
	for key,ent in pairs(targets)do
		samplevalue = samplevalue - self:GetTargetPriority(ent)
		if(samplevalue <= 0)then
		self:SetTarget(ent)
		return true
		end
	end

	if(playersum == 0)then --slowly die if they end up somewhere where nobody is
		local dmg = DamageInfo()
		dmg:SetDamage(5)
		dmg:SetAttacker(self)
		self:TakeDamageInfo(dmg)
	end
	self.NextTargetTime = CurTime() + 2
	self:SetTarget(nil)
	return false
end

function ENT:ResetBehavior()
	if(self.Suicidal)then return end
	self.shifted = nil
	if(self.path and IsValid(self.path))then 
		self.path:Invalidate() 
		self.path = nil 
	end
	self.ManualTarget = nil
	self:FindTarget()
end



function ENT:IgnoreTarget(target)
	self.TargetBlacklist = self.TargetBlacklist or {}
	self.TargetBlacklist[target] = CurTime() + 1
end

function ENT:RunBehaviour()
	-- This function is called when the entity is first spawned, it acts as a giant loop that will run as long as the NPC exists
	while ( true ) do
		
		if ( IsValid(self:GetTarget()) ) then
				self.loco:SetDesiredSpeed( (self.Suicidal and 350) or (self:GetBased() and 500) or 200 )		
				self.loco:SetAcceleration(self.Suicidal and 400 or 200)
				self.loco:SetDeceleration(self.Suicidal and 400 or 500)
				self.loco:SetJumpHeight(100)
				if(!self:NearTarget())then
					local result = self:ChaseTarget( ) 
					if(result == "failed")then self:IgnoreTarget(self:GetTarget())  self:ResetBehavior() end --if chasing the target fails somehow, its probably a wise assumption that its redundant to keep trying.
				end
				
			
			if(self:NearTarget())then
				if(!self:IsTalking())then 
					self:SayStuff() 	
				end
				self.loco:FaceTowards(self:GetTarget():GetPos())
				if(!self.shifted)then
					local result = self:MoveToPos( self:GetTarget():GetPos() + VectorRand()*Vector(1,1,0):GetNormalized()*math.Rand(80,150), {maxage=5} )
					if(result != "ok")then self:ResetBehavior() end 
					--cheap method of keeping kleiners with similar targets from clumping together. i figure it's cheaper than some kind of avoidance.
					self.shifted = true
				end
				coroutine.wait(0.15)
			else
				self.shifted = nil
			end
			
			if(self.ManualTarget == nil and math.random(1,100) == 1)then
				self:ResetBehavior()
			end
	
		else
			-- no target, so we wander.
			self.loco:SetDesiredSpeed( self.Suicidal and 350 or 200 )		
			self.loco:SetAcceleration(self.Suicidal and 400 or 200)
			self.loco:SetDeceleration(self.Suicidal and 900 or 900)
			local wanderpos = self:FindSpot("random",{type="hiding",pos=self:GetPos(),radius=4000,stepup=900,stepdown=900})
			if(wanderpos != nil)then
			self:MoveToPos( wanderpos, {maxage=5} )
			end
			coroutine.wait(5)
			if ( self.loco:IsStuck() ) then
				self:HandleStuck()
			end
			if(math.random(1,5) == 1)then
				self:ResetBehavior()
			end
			
		end
		-- At this point in the code the bot has stopped chasing the player or finished walking to a random spot
		-- Using this next function we are going to wait 2 seconds until we go ahead and repeat it 
		coroutine.wait(0.4)
		
	end

end


function ENT:MoveToPos( pos, options )
	if(pos == nil)then return "failed" end
	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, pos )
	self.path = path
	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() ) do
		local shouldpath = self:WhilePathing(path)
		if(shouldpath)then 
			path:Update( self ) 
		end
		-- Draw the path (only visible on listen servers or single player)
		if ( options.draw ) then
			path:Draw()
		end
		
		if ( self.loco:IsStuck() ) then

			self:HandleStuck()

			return "stuck"

		end

		--
		-- If they set maxage on options then make sure the path is younger than it
		--
		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then return "timeout" end
		end

		--
		-- If they set repath then rebuild the path every x seconds
		--
		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
		end

		coroutine.yield()

	end

	return "ok"

end


function ENT:DoorIsOpen( door )
	if(!IsValid(door))then return true end
	local doorClass = door:GetClass()

	if ( doorClass == "func_door" or doorClass == "func_door_rotating" ) then

		return door:GetInternalVariable( "m_toggle_state" ) == 0

	elseif ( doorClass == "prop_door_rotating" ) then

		return door:GetInternalVariable( "m_eDoorState" ) ~= 0

	else

		return false

	end

end


function ENT:IsOpeningDoor()
	return self.DoorPassage != nil and self.DoorPassage > CurTime()
end

function ENT:GetCurrentPathPoint()
	if(self.path and self.path:IsValid())then
		local start = 1
		for k,v in pairs(self.path:GetAllSegments())do
			if(k != 1 and (v.pos*Vector(1,1,0)):Distance(self:GetPos()*Vector(1,1,0)) > 32)then
				start = k
				break
			end
		end	
		if(start > 1)then start = start - 1 end
		return self.path:GetAllSegments()[start],start
	end
	return nil,-1
end

function ENT:GetNextPathPoint(ahead)
if(!self.path or !self.path:IsValid())then return end
ahead = ahead or 1
local seg,index = self:GetCurrentPathPoint()
if(index)then 
return self.path:GetAllSegments()[index+ahead] 
end


end



function ENT:HandleStuck()
if(self.DoorPassage != nil and self.DoorPassage > CurTime())then
self.loco:ClearStuck()
return 
end

local spot = self:GetNextPathPoint()



if(spot)then
	self:Teleport(spot.pos)
	self.loco:ClearStuck()
else
	self.loco:Jump()
	self.loco:ClearStuck()
end

end

function ENT:Teleport(newpos)
	local caneffect = self.NextTeleport == nil or self.NextTeleport < CurTime() 
	
	if(caneffect)then
	
	local beam = EffectData()
	beam:SetMagnitude(5)
	beam:SetScale(5)
	beam:SetNormal((newpos-self:GetPos()))
	beam:SetStart( self:GetPos() + Vector(0,0,40) )
	beam:SetOrigin( newpos + Vector(0,0,40))
	util.Effect( "ToolTracer", beam ) --make a cool energy ball explosion
	
	
	local effectdata = EffectData()
	effectdata:SetMagnitude(5)
	effectdata:SetNormal(Vector(0,0,1))
	effectdata:SetOrigin( self:GetPos() + Vector(0,0,40) )
	util.Effect( "cball_explode", effectdata ) --make a cool energy ball explosion
	
	
	
	self:SetPos(newpos)
	
	effectdata:SetOrigin( self:GetPos()  + Vector(0,0,40))
	util.Effect( "cball_explode", effectdata ) -- make another one at the new spot
	
	self:EmitSound("Weapon_PhysCannon.Launch")	
	
	
	
	self.NextTeleport = CurTime() + 0.5
	else
		self:SetPos(newpos)
	
	end
	
end


 local KLPATHGEN_ITERS
 local KLPATHGEN_ITERS_BUDGET
 
function ENT:ChaseTarget( options )
	local options = options or {}
	local path = Path( "Chase" )
	path:SetMinLookAheadDistance( options.lookahead or 100 )
	path:SetGoalTolerance( options.tolerance or 32 )
	self.path = path
	RELEVANT_KLEINER = self -- see ENT.PathGen for explanation
	KLPATHGEN_ITERS = 0
	KLPATHGEN_ITERS_BUDGET = KleinerPathingIterationLimit()
	local success = path:Compute( self, self:GetTarget():GetPos() ,self.PathGen)
	if(!success)then return "failed" end
	if ( !path:IsValid() ) then return "failed" end
	local target = self:GetTarget()
	while ( path:IsValid() and self:HaveTarget() and !self:NearTarget() and IsValid(target) ) do
		self.loco:SetStepHeight(32)
		self.loco:SetDeathDropHeight(5000)
		local range = self:GetRangeTo(self:GetTarget():GetPos()) or self.LoseTargetDist
		
		local updaterate = math.max(KleinerPathingRateHigh()*(range / self.LoseTargetDist),0.5)
		
		
		if ( path:GetAge() > updaterate and target:IsOnGround()) then	
			RELEVANT_KLEINER = self -- see ENT.PathGen for explanation
			KLPATHGEN_ITERS = 0
			KLPATHGEN_ITERS_BUDGET = KleinerPathingIterationLimit()
			local success = path:Compute(self, self:GetTarget():GetPos(),self.PathGen)
			if(!success)then return "failed" end
		end
		if ( !path:IsValid() ) then return "failed" end
		local shouldpath = self:WhilePathing(path)
		if(shouldpath)then 
			path:Update( self ) 
		end
		if ( options.draw) then path:Draw() end
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end
		coroutine.yield()
	end
	return "ok"
end

function ENT:WhilePathing(path) --this function runs during the path movement. returning false will interrupt path movement, in case other actions are needed.
if(path == nil or !path:IsValid() )then return true end
if(self.loco == nil )then return true end
if(!self:OnGround() and self:GetVelocity().z < -50)then return false end --attempting to move while falling seems to pause falling
	local seg1,index = self:GetCurrentPathPoint() --this returns the first path segment we're closest to.
	local seg2 = path:GetAllSegments()[index + 1]
	local seg3 = path:GetAllSegments()[index + 2]

	local dir = self:GetForward()
	if(seg1 and seg2)then
		dir =(seg2.pos  - seg1.pos):GetNormalized()
	end


	-- a quick fix to the broken ladder handling. If they are about to climb a ladder, teleport them instead
	if(seg2 and seg2.ladder:IsValid())then --everything goes wrong when we use ladders so let's try to teleport over them.
		self:Teleport((seg3 and seg3.pos) or (seg2 and seg2.pos))
		self.loco:ClearStuck()
		return
	end
	
	if(seg2 and seg2.area:HasAttributes(NAV_MESH_JUMP) and seg2.area:HasAttributes(NAV_MESH_AVOID))then --If any nav areas are marked as STOP and AVOID, we automatically teleport over them.
		--self:Teleport((seg3 and seg3.pos) or (seg2 and seg2.pos))
		if(seg3 and seg3.area != seg1.area)then
		self.loco:JumpAcrossGap((seg3 and seg3.pos) or (seg2 and seg2.pos),dir)
		self.loco:ClearStuck()
		return
		end
	end
	
	-- if they're on a ladder, their physics have been permanently broken so we'll just delete him.
	if(self.loco:IsUsingLadder())then
		self:Remove()
	end
	
	
	--ladder handling [CURRENTLY BROKEN]
	--[[
	self.ClimbDir = 0
	if(seg2 and self.loco:IsUsingLadder())then
		
		if(seg2.how == 4)then --should climb up
			self:SetPos(self:GetPos() + Vector(0,0,400*FrameTime()))
			self.ClimbDir = 1
			self.loco:ClearStuck()
			return false
		end
		if(seg2.how == 5)then --should climb down
			self:SetPos(self:GetPos() + Vector(0,0,-400*FrameTime()))
			self.ClimbDir = -1
			self.loco:ClearStuck()
		return false
		end
		if(seg2.how <= 3)then 
			self:SetMoveType(MOVETYPE_CUSTOM)
			self.loco:JumpAcrossGap(seg2.pos,self:GetForward()) 
			self.loco:ClearStuck()
			return true
		end
	end
	]]

	-- Jumping handling
	local ofs = (seg2.pos-self:GetPos())
	local heightdist = ofs.z
	local lendist = (ofs*Vector(1,1,0)):Length()
	local jumpdir = (ofs*Vector(1,1,0)):GetNormalized()
	local inrange = lendist < 64
	local shouldjump = inrange and (seg3 and (seg3.area:HasAttributes(NAV_MESH_JUMP) or seg3.type == 2 or seg3.type == 3))
	local across = (math.abs(heightdist) < 64)	
	if(self:IsOnGround() and shouldjump)then 
		if(across)then
			self.loco:JumpAcrossGap((seg3 and seg3.pos) or (seg2 and seg2.pos),dir)
			
		else
			self.loco:Jump() 
		end
	end
	
	--NOTE: door use seems to be pretty expensive due to the tracing, i would like to optimize this so that it doesn't run unless the path contains a doorway.
	--Disabling the following function will just make them get stuck and teleport past the door instead
	--[[
	if(seg1 and seg2)then -- door handling
		if(self.DoorPassage != nil and self.DoorPassage > CurTime())then --back away from doors if we just tried to open them
			local dir = (seg2.pos  - seg1.pos):GetNormalized()
	
			self.loco:FaceTowards( IsValid(self.CurrentDoor) and self.CurrentDoor:GetPos()  )
			self.loco:Approach(seg1.pos + dir*-32,1)
			return false
		end
		local dir = (seg2.pos  - seg1.pos):GetNormalized()
		local tr = {}
		tr.start = self:GetPos() + Vector(0,0,32)
		tr.endpos = tr.start + dir*64
		tr.filter = KLEINER_NPCS_FILTER
		tr.mask = MASK_PLAYERSOLID
		local trace = util.TraceLine(tr)
		debugoverlay.Line( tr.start, trace.HitPos, 0.2, Color( 255, 0, 255,0 ) ,true)
		local blocking = trace.Entity
		local isdoor = IsValid(blocking) and string.sub(blocking:GetClass(),6,9) == "door"
		
		if(IsValid(blocking) and isdoor and (!self:IsOpeningDoor() or !self:DoorIsOpen( blocking )))then
			if(blocking.kleinerdoortime == nil or blocking.kleinerdoortime <= CurTime())then 
				if(!self:DoorIsOpen( blocking ) )then 
					if(blocking:HasSpawnFlags( 256 ) or string.sub(blocking:GetClass(),1,4) == "prop")then
						blocking:Use(self,nil,SIMPLE_USE)
					else
						self:Teleport(seg2.pos)
					end
				end
				blocking.kleinerdoortime = CurTime() + 1
			end
			
			self.DoorPassage = CurTime() + 1 --stop moving path and clear doorway for a sec
			self.CurrentDoor = blocking
		end
	end
	]]
return true
end 


ENT.PathGen = function( area, fromArea, ladder, elevator, length )
	KLPATHGEN_ITERS = (KLPATHGEN_ITERS or 0) + 1
	
	local self = RELEVANT_KLEINER --this is bullshit, i guess this callback doesn't include the entity pathing. 
	if(!IsValid(self))then return -1 end
	if ( !IsValid( fromArea ) ) then

		// first area in path, no cost
		return 0
	
	else
		if(KLPATHGEN_ITERS > KLPATHGEN_ITERS_BUDGET)then
			return -1
		end
	
		if ( !self.loco:IsAreaTraversable( area ) and !ladder:IsValid()) then
			// our locomotor says we can't move here
			return -1
		end
		
		--if(!self:PosInRange(area:GetCenter()))then return -1 end
		// compute distance traveled along path so far
		local dist = 0

		if ( IsValid( ladder ) ) then
			dist = ladder:GetLength()
		elseif ( length > 0 ) then
			// optimization to avoid recomputing length
			dist = length
		else
			dist = ( area:GetCenter() - fromArea:GetCenter() ):Length()
		end

		local cost = dist + fromArea:GetCostSoFar()
		// check height change
		local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange( area )
		if(!ladder:IsValid())then
			if ( deltaZ >= self.loco:GetStepHeight() ) then
				if ( deltaZ >= self.loco:GetMaxJumpHeight() ) then
					// too high to reach
					return -1
				end

				// jumping is slower than flat ground
				local jumpPenalty = 2
				cost = cost + jumpPenalty * dist
			elseif ( deltaZ < -self.loco:GetDeathDropHeight() ) then
				// too far to drop
				return -1
			end
		end
			if(IsValid(area) and area:HasAttributes(NAV_MESH_AVOID) and area:IsUnderwater())then
				return -1
			end
			if(IsValid(area) and area:HasAttributes(NAV_MESH_AVOID))then
				cost = cost + 100
			end
		return cost
	end
end 




ENT.Chatter = {
"vo/k_lab/kl_almostforgot.wav",
"vo/k_lab/kl_barneyhonor.wav",
"vo/k_lab/kl_barneysturn.wav",
"vo/k_lab/kl_besokind.wav",
"vo/k_lab/kl_blast.wav",
"vo/k_lab/kl_bonvoyage.wav",
"vo/k_lab/kl_cantcontinue.wav",
"vo/k_lab/kl_cantwade.wav",
"vo/k_lab/kl_careful.wav",
"vo/k_lab/kl_charger01.wav",
"vo/k_lab/kl_charger02.wav",
"vo/k_lab/kl_coaxherout.wav",
"vo/k_lab/kl_comeout.wav",
"vo/k_lab/kl_credit.wav",
"vo/k_lab/kl_dearme.wav",
"vo/k_lab/kl_debeaked.wav",
"vo/k_lab/kl_delaydanger.wav", 
"vo/k_lab/kl_diditwork.wav",
"vo/k_lab/kl_ensconced.wav",
"vo/k_lab/kl_excellent.wav",
"vo/k_lab/kl_fewmoments01.wav",
"vo/k_lab/kl_fewmoments02.wav",
"vo/k_lab/kl_fiddlesticks.wav",
"vo/k_lab/kl_finalsequence.wav",
"vo/k_lab/kl_finalsequence02.wav",
"vo/k_lab/kl_fitglove01.wav",
"vo/k_lab/kl_fitglove02.wav",
"vo/k_lab/kl_fruitlessly.wav",
"vo/k_lab/kl_getinposition.wav",
"vo/k_lab/kl_getoutrun01.wav",
"vo/k_lab/kl_getoutrun02.wav",
"vo/k_lab/kl_getoutrun03.wav",
"vo/k_lab/kl_gordongo.wav",
"vo/k_lab/kl_gordonthrow.wav",
"vo/k_lab/kl_helloalyx01.wav",
"vo/k_lab/kl_helloalyx02.wav",
"vo/k_lab/kl_heremypet01.wav",
"vo/k_lab/kl_heremypet02.wav",
"vo/k_lab/kl_hesnotthere.wav",
"vo/k_lab/kl_holdup01.wav",
"vo/k_lab/kl_holdup02.wav",
"vo/k_lab/kl_interference.wav",
"vo/k_lab/kl_islamarr.wav",
"vo/k_lab/kl_lamarr.wav",
"vo/k_lab/kl_masslessfieldflux.wav",
"vo/k_lab/kl_modifications01.wav",
"vo/k_lab/kl_modifications02.wav",
"vo/k_lab/kl_moduli02.wav",
"vo/k_lab/kl_mygoodness01.wav",
"vo/k_lab/kl_mygoodness02.wav",
"vo/k_lab/kl_mygoodness03.wav",
"vo/k_lab/kl_nocareful.wav",
"vo/k_lab/kl_nonsense.wav",
"vo/k_lab/kl_nownow01.wav",
"vo/k_lab/kl_nownow02.wav",
"vo/k_lab/kl_ohdear.wav",
"vo/k_lab/kl_opportunetime01.wav",
"vo/k_lab/kl_opportunetime02.wav",
"vo/k_lab/kl_packing01.wav",
"vo/k_lab/kl_packing02.wav",
"vo/k_lab/kl_plugusin.wav",
"vo/k_lab/kl_projectyou.wav",
"vo/k_lab/kl_redletterday01.wav",
"vo/k_lab/kl_redletterday02.wav",
"vo/k_lab/kl_relieved.wav",
"vo/k_lab/kl_slipin01.wav",
"vo/k_lab/kl_slipin02.wav",
"vo/k_lab/kl_suitfits01.wav",
"vo/k_lab/kl_suitfits02.wav",
"vo/k_lab/kl_thenwhere.wav",
"vo/k_lab/kl_waitmyword.wav",
"vo/k_lab/kl_weowe.wav",
"vo/k_lab/kl_whatisit.wav",
"vo/k_lab/kl_wishiknew.wav",
"vo/k_lab/kl_yourturn.wav",
"vo/k_lab2/kl_aroundhere.wav",
"vo/k_lab2/kl_atthecitadel01.wav",
"vo/k_lab2/kl_atthecitadel01_b.wav",
"vo/k_lab2/kl_aweekago01.wav",
"vo/k_lab2/kl_blowyoustruck01.wav",
"vo/k_lab2/kl_blowyoustruck02.wav",
"vo/k_lab2/kl_cantleavelamarr.wav",
"vo/k_lab2/kl_cantleavelamarr_b.wav",
"vo/k_lab2/kl_comeoutlamarr.wav",
"vo/k_lab2/kl_dontgiveuphope02.wav",
"vo/k_lab2/kl_dontgiveuphope03.wav",
"vo/k_lab2/kl_givenuphope.wav",
"vo/k_lab2/kl_greatscott.wav",
"vo/k_lab2/kl_howandwhen01.wav",
"vo/k_lab2/kl_howandwhen02.wav",
"vo/k_lab2/kl_lamarr.wav",
"vo/k_lab2/kl_lamarrwary01.wav",
"vo/k_lab2/kl_lamarrwary02.wav",
"vo/k_lab2/kl_nolongeralone.wav",
"vo/k_lab2/kl_nolongeralone_b.wav",
"vo/k_lab2/kl_notallhopeless.wav",
"vo/k_lab2/kl_notallhopeless_b.wav",
"vo/k_lab2/kl_onehedy.wav",
"vo/k_lab2/kl_slowteleport01.wav",
"vo/k_lab2/kl_slowteleport01_b.wav",
"vo/k_lab2/kl_slowteleport02.wav"}
