------------------------------// General Settings \\------------------------------------------------------------|
SWEP.Author 			= "PYROTEKNIK / Horatio"                           -- Your name.
SWEP.Contact 			= ""                     		-- How People could contact you.
SWEP.base 				= "weapon_base"							-- What base should the swep be based on.
SWEP.ViewModel 			= "models/aoc_weapon/v_longsword.mdl" 									-- The viewModel, the model you see when you are holding it.
SWEP.WorldModel 		= "models/aoc_weapon/w_longsword.mdl" 									-- The world model, The model you when it's down on the ground.
SWEP.HoldType 			= "melee2"                            		-- How the swep is hold Pistol smg grenade melee.
SWEP.PrintName 			= "Crusader Sword"                         			-- your sweps name.
SWEP.Category 			= "PYROTEKNIK"                					-- Make your own category for the swep.
SWEP.Instructions 		= "Left Click: Slash / Chop (Hold R or jump)\nRight Click: Charge\nReload:Taunt\nPower up your blade by constantly killing infidels in rapid succession. While powered up, your blade cuts through multiple infidels effortlessly, and is not stopped by walls."              						-- How do people use your swep.
SWEP.Purpose 			= ""          							-- What is the purpose with this.
SWEP.AdminSpawnable 	= true                          		-- Is the swep spawnable for admin.
SWEP.ViewModelFlip 		= false									-- If the model should be flipped when you see it.
SWEP.UseHands			= false									-- Weather the player model should use its hands.
SWEP.AutoSwitchTo 		= false                           		-- when someone walks over the swep, should it automatically change to your swep.
SWEP.Spawnable 			= true                               	-- Can everybody spawn this swep.
SWEP.AutoSwitchFrom 	= false                         		-- Does the weapon get changed by other sweps if you pick them up.
SWEP.FiresUnderwater 	= true                       			-- Does your swep fire under water.
SWEP.DrawCrosshair 		= true                           		-- Do you want it to have a crosshair.
SWEP.DrawAmmo 			= true                                 	-- Does the ammo show up when you are using it.
SWEP.ViewModelFOV 		= 50                            			-- How much of the weapon do you see.
SWEP.Weight 			= 0                                   	-- Chose the weight of the Swep.
SWEP.SlotPos 			= 0                                    	-- Decide which slot you want your swep do be in.
SWEP.Slot 				= 0                                     -- Decide which slot you want your swep do be in.

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Damage = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"


SWEP.Primary.Automatic 			= true    	-- Do We Have To Click Or Hold Down The Click
SWEP.Primary.Ammo 				= "none"  	-- What Ammo Does This SWEP Use (If Melee Then Use None)                			-- How Much Jump After An Attack        
SWEP.Primary.ClipSize			= -1      	-- Size Of The Clip
SWEP.Primary.DefaultClip 		= -1
SWEP.Primary.Force 				= 100000    -- damage force to apply
SWEP.Primary.Distance 			= 60		-- full range of swing

SWEP.Primary.SlashRatio 		= 0.5		-- If hit distance is under this percentage of range, stop the blade. Otherwise scrape through.

SWEP.SwingSound					= "aof/weapons/longsword_attack2.wav"
SWEP.WallSound 					= "aof/weapons/block_shield5.wav"
SWEP.FleshSound 				= "aof/weapons/hitbod6.wav"
SWEP.BigSwingSound 				= "physics/nearmiss/whoosh_large1.wav"

SWEP.SlashDamage 			= 60 	-- Initial Damage for Horizontal Slash
SWEP.SlashDamageAfter 		= 20 	-- Damage to subsequent hit from slash
SWEP.SlashDelay 			= 1	-- Delay between completed slash attacks
SWEP.SlashDelayHit 	= 0.4  	 		-- How long after the blade is stopped by a wall we can attack again.


SWEP.ChopDamage 			= 70 	-- Initial Damage For Overhead Chop
SWEP.ChopDamageAfter  		= 50 	-- Damage to subsequent hit from chop
SWEP.ChopDelay = 	  1.1			-- How long after chop is completed before we can hit again
SWEP.ChopDelayHit 	= 1.1  	 		-- How long after chop interrupted we can chop again

SWEP.ChargeAttackVelocity = 100		     --Velocity to apply during charge
SWEP.ChargeAttackDamagePeak = 65		 --Damage to apply when moving at peak units per second
SWEP.ChargeAttackVelocityPeak = 800		 --Peak speed for charge damage
SWEP.ChargeDuration = 1					--Time to charge before stopping	

SWEP.ChargeDelay = 3 --Time before charging again
SWEP.ChargeFOV = 120 -- Camera FOV while charging

SWEP.RenderGroup = RENDERGROUP_BOTH

--NOTE: Holy mode can be set with SetHoly(true), In this mode, the blade cannot be stopped by hard surfaces, and damage won't be reduced on subsequent hits in the same slash


SWEP.Offset = {
Pos = {Up = -20, Right = 1, Forward = 49, },
Ang = {Up =90, Right = 0, Forward = 180,}
}


local glow_mat
if(CLIENT)then
glow_mat = CreateMaterial("crusader_glow", "UnlitGeneric", {
	["$basetexture"] = "sprites/physgun_glow",
	["$model"] = 1,
	["$additive"] = 1,
	["$translucent"] = 1,
	["$color2"] = Vector(4, 4, 4),
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1
})
end
function SWEP:DrawGlow(pos,ang,flags)
	if(!self:GetHoly() or pos:Distance(EyePos()) > 500)then return end
	local steps = 30
	local length = 52
	
	local color = Color(255,230,128)
	
	render.SetMaterial( glow_mat )

	
	local size = 9 + math.sin(math.rad(CurTime()*1280))
	local viewnormal = (EyePos() - pos):GetNormal()
	render.DrawBeam(pos + viewnormal*2, pos + ang:Forward()*length, size, 0.44, 0.9, color)

	
end

function SWEP:DrawWorldModelTranslucent()
	local matr = self:GetBoneMatrix(0)
	local pos = matr:GetTranslation()
	local ang = matr:GetAngles()
	
	ang:RotateAroundAxis(ang:Right(),-95)
	ang:RotateAroundAxis(ang:Up(),-4)
	if(self:GetChargeEnd() > CurTime())then
		ang:RotateAroundAxis(ang:Right(),90)
	end
	pos = pos + ang:Right()*1.5
	pos = pos + ang:Up()*4
	pos = pos + ang:Forward()*2.7

	self:DrawGlow(pos,ang,flags)
end

function SWEP:PreDrawViewModel(vm,ply,wep)
	if(self:GetHoly())then
		render.SuppressEngineLighting( true)
		render.ResetModelLighting( 1,0.8,0.3 )
	end

end

function SWEP:PostDrawViewModel(vm,ply,wep)
	if(self:GetHoly())then

		local pos,ang = vm:GetBonePosition(vm:LookupBone("ValveBiped.Bip01_R_Hand") or 0)
		
		ang:RotateAroundAxis(ang:Right(),-85)
		ang:RotateAroundAxis(ang:Up(),2)
		pos = pos + ang:Right()*1.5
		pos = pos + ang:Up()*4
		pos = pos + ang:Forward()*2.7
		
		for i=0,128 do
		--print(i,vm:GetBoneName(i))
		end
		self:DrawGlow(pos,ang)

		render.SuppressEngineLighting( false)
	end

end

function SWEP:IsCharging()
	return CurTime() < self:GetChargeEnd()
end

function SWEP:DrawWorldModel( )

	self:ManipulateBoneAngles(1,self:IsCharging() and Angle(-90,0,0) or Angle())
	if(self:GetHoly())then
		render.SuppressEngineLighting( true)
		render.ResetModelLighting( 1,0.8,0.3 )
	end
	local hand, offset, rotate
	local pl = self:GetOwner()
	if IsValid( pl ) then
		local boneIndex = pl:LookupBone( "ValveBiped.Bip01_R_Hand" )
			if boneIndex then
				local charging = self:IsCharging()
				local pos, ang = pl:GetBonePosition( boneIndex )
				local offset = self.Offset
				pos = pos + ang:Forward() * offset.Pos.Forward + ang:Right() * offset.Pos.Right + ang:Up() * offset.Pos.Up
				ang:RotateAroundAxis( ang:Up(),    	offset.Ang.Up)
				ang:RotateAroundAxis( ang:Right(), 	offset.Ang.Right )
				ang:RotateAroundAxis( ang:Forward(),  offset.Ang.Forward )
				
				self:SetRenderOrigin( pos )
				self:SetRenderAngles( ang )
				self:SetupBones()
				self:DrawModel()
				
			end
	else
		self:SetRenderOrigin( nil )
		self:SetRenderAngles( nil )
		self:DrawModel()
	end
	render.SuppressEngineLighting( false)
end

function SWEP:Initialize()
	if ( SERVER ) then
	self:SetHoldType(self.HoldType)
	end
end
--------------

function SWEP:Deploy()
	self.Owner:DrawViewModel(true)
	self:SetHoldType(self.HoldType)
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "HitNext" )
	self:NetworkVar( "Float", 1, "ChargeEnd" )
	self:NetworkVar( "Float", 2, "NextTaunt" )
	self:NetworkVar( "Int", 0, "HitCount" )
	self:NetworkVar( "Bool", 0, "Overhead" )
	self:NetworkVar( "Bool", 1, "Holy" )
	if ( SERVER ) then
		self:NetworkVarNotify( "Holy", self.OnVarChanged )

	end

	
end

function SWEP:OnVarChanged(name,old,new)
	if(old == new)then return end
	if(name == "Holy")then
	local ent = self
	if(IsValid(self:GetOwner()))then
		ent = self:GetOwner()
	end
	ent:EmitSound(new == true and "friends/friend_online.wav" or new == false and "friends/friend_join.wav",60,80)
	end
end


function SWEP:Reload()
	if(self:GetNextTaunt() > CurTime() or !self:GetOwner():KeyPressed(IN_RELOAD))then return end
	if(SERVER)then
	local taunt = "deus_vult_infidel"
	self:GetOwner():EmitSound("aof/weapons/"..taunt..".wav")
	end

	self:SetNextTaunt(CurTime() + 2)
end



function SWEP:PrimaryAttack()
	local ply = self:GetOwner()
	local holy = self:GetHoly()
	local vm = ply:GetViewModel()
	self:SetChargeEnd(CurTime() -1)
	self.Weapon:EmitSound(self.SwingSound,100,math.random(90,120))
	if(holy)then
	
	self.Weapon:EmitSound(self.BigSwingSound ,100,math.random(177,200))
	
	end
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.SwingFilter = {ply,self}
	self.HitFirstTarget = nil
	self.LastHit = nil
		local overhead = !ply:OnGround() or ply:KeyDown(IN_RELOAD)


		self:SetOverhead(overhead)

		vm:SendViewModelMatchingSequence( vm:LookupSequence( overhead and "swing2" or "swing1" ) )
		vm:SetPlaybackRate(overhead and 1.2 or 2)
		ply:ViewPunch(overhead and Angle(-20,0,0) or Angle(0,-10,0))
		local delay = overhead and self.ChopDelay or self.SlashDelay
		self.Weapon:SetNextPrimaryFire( CurTime() + delay)
		--self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
		self:SetHitCount(20)
		self:SetHitNext(CurTime() + 0.15)
end



function SWEP:Think()
	
	local delta = CurTime() - (self.LastThink or CurTime()) 
	--print(delta)
	local ply = self:GetOwner()
	self.SwingFilter = self.SwingFilter or {ply,self}
	local overhead = self:GetOverhead()
	local holy = self:GetHoly()
	local vm = ply:GetViewModel()
	local charging = self:IsCharging()
	if(overhead and ply:OnGround())then
		--vm:SendViewModelMatchingSequence( vm:LookupSequence( "swing1" ) )
		vm:SetPlaybackRate(1.7)
	end

	if(charging)then
		local tr = {}
		local trace 
		tr.filter = self.SwingFilter
		tr.start = ply:GetShootPos()
		tr.endpos = tr.start + ply:GetAimVector()*30
		tr.mask = MASK_SHOT
		tr.mins = Vector(1,1,1)*-16
		tr.maxs = Vector(1,1,1)*16
		local trace = util.TraceHull(tr)
		if(trace.Hit)then
			local flesh = util.GetSurfacePropName(trace.SurfaceProps) == "flesh"
			local dmg = DamageInfo()
			dmg:SetDamage(ply:GetVelocity():Length() / self.ChargeAttackVelocityPeak * self.ChargeAttackDamagePeak)
			dmg:SetDamageType(holy and DMG_DISSOLVE or DMG_SLASH)
			dmg:SetDamageForce(ply:GetAimVector()*self.Primary.Force)
			dmg:SetDamagePosition(trace.HitPos)
			dmg:SetAttacker(ply)
			dmg:SetInflictor(self)
			trace.Entity:DispatchTraceAttack(dmg,trace)
			if(!holy or !flesh)then
			self:SetChargeEnd(CurTime()-1)
			ply:SetFOV(0,0.5)
			end
			if(flesh)then
			trace.Entity:EmitSound(self.FleshSound  , 80, 100, 1, CHAN_WEAPON)
			self:GetOwner():EmitSound("physics/flesh/flesh_impact_hard"..math.random(1,4)..".wav")

			else
			ply:ViewPunch(Angle(25,24,0))
			self:EmitSound(self.WallSound  , 80, 100, 1, CHAN_WEAPON)
			end

			else
			ply:SetVelocity(ply:GetAimVector()*self.ChargeAttackVelocity*100*delta)
		end

	end

	
	 
	while (IsValid(self:GetOwner()) and self:GetHitCount() > 0 and CurTime() >= self:GetHitNext()) do
		self.Owner:LagCompensation( true )
		local tr = {}
		local trace 
		tr.filter = self.SwingFilter
		tr.start = ply:GetShootPos()
		tr.mask = MASK_SHOT
		
		
		local count = self:GetHitCount()
		local yaw = Lerp((20-(count-0.5))/20,-90,90)
		local size = Lerp(math.abs(yaw)/90,8,1)
		tr.mins = Vector(1,1,1)*-size
		tr.maxs = Vector(1,1,1)*size
		local yawoffset = yaw
	

		local horz = Lerp(1-math.pow(math.abs(yawoffset/90),3),0.4,1)
		local ang = ply:EyeAngles()

		if(overhead)then
			ang:RotateAroundAxis(ang:Right(),-yawoffset)
		else
			ang:RotateAroundAxis(ang:Up(),yawoffset)
		end
		tr.endpos = tr.start + ang:Forward()*self.Primary.Distance*horz* (overhead and 1.5 or 1)
		debugoverlay.Text(tr.endpos,yawoffset,4,true)

		trace = util.TraceHull(tr)
		debugoverlay.Line(trace.StartPos,trace.HitPos,4,HSVToColor(count * 10,1,1),true)
		debugoverlay.SweptBox( trace.StartPos, trace.HitPos, tr.mins, tr.maxs, Angle(), 4, ColorAlpha(HSVToColor(count * 10,1,0.4),32) )

		
		if(trace.Hit)then
			local lowered = self.HitFirstTarget and !holy
			local dmgvalue = lowered and self.SlashDamageAfter or self.SlashDamage
			if(overhead)then
				dmgvalue = lowered and self.ChopDamageAfter or self.ChopDamage
			end

			local dmg = DamageInfo()
			dmg:SetDamage(dmgvalue)
			dmg:SetDamageType(holy and DMG_DISSOLVE or DMG_SLASH)
			dmg:SetDamageForce(ply:GetAimVector()*4000 * (holy and 100 or 1))
			dmg:SetDamagePosition(trace.HitPos)
			dmg:SetAttacker(ply)
			dmg:SetInflictor(self)
			trace.Entity:DispatchTraceAttack(dmg,trace)
			local flesh = util.GetSurfacePropName(trace.SurfaceProps) == "flesh"
			
			if(flesh)then
				trace.Entity:EmitSound(self.FleshSound  , 80, 100, 1, CHAN_WEAPON)
				self.HitFirstTarget = true
				table.insert(self.SwingFilter,trace.Entity)
				debugoverlay.Text(trace.HitPos,dmg:GetDamage().."  "..tostring(trace.Entity),4,true)
			end
			if(!flesh)then
				
				self.Weapon:SetNextPrimaryFire( CurTime() + (overhead and self.ChopDelayHit or self.SlashDelayHit))
				ply:SetVelocity(trace.HitNormal*450)
				local vm = ply:GetViewModel()
				if(trace.Fraction < self.Primary.SlashRatio and trace.HitWorld and math.abs(trace.HitNormal.z) < 0.99 and !holy)then
					self:SetHitCount(0)
					ply:ViewPunch(overhead and Angle(-15,0,0) or Angle(0,-15,0))
					self:EmitSound(self.WallSound  , 80, 100, 1, CHAN_WEAPON)
					vm:SendViewModelMatchingSequence( vm:LookupSequence( "idle_01" ) )
				vm:SetPlaybackRate(1)
				else
					ply:SetVelocity(trace.HitNormal*25)
					if(!self.HitFirstTarget)then 
						self.HitFirstTarget = true 
						self:EmitSound("physics/metal/metal_sheet_impact_soft2.wav",80,math.Rand(90,122), 1, CHAN_WEAPON)
					end
				end
				if(CLIENT)then
					local effectdata = EffectData()
					effectdata:SetOrigin( trace.HitPos )
					effectdata:SetNormal(trace.HitNormal)
					effectdata:SetMagnitude(1)
					effectdata:SetAngles(VectorRand():AngleEx(trace.HitNormal))
					util.Effect( "Sparks", effectdata ) 
					util.Decal( "ManhackCut", trace.StartPos, trace.StartPos + trace.Normal*1000, tr.Filter )
				end
			end
			
			
		end
		if(self.LastHit)then
			debugoverlay.Line(self.LastHit,trace.HitPos,4,Color(0,0,0),true)
			
		end
		self.LastHit = trace.HitPos*1
		
		self.Owner:LagCompensation( false )

		self:SetHitCount(self:GetHitCount() - 1)
		self:SetHitNext(self:GetHitNext() + (overhead and !ply:OnGround() and 0.05 or 0.01))
	end

	self.LastThink = CurTime()

end

function SWEP:SecondaryAttack()
	
	local ply = self:GetOwner()
	if(!ply:OnGround())then 
		self.Weapon:SetNextSecondaryFire( CurTime() + 0.1)
		return
	end	

	ply:EmitSound("aof/weapons/charge1.wav",60,100)
	
	self:SetChargeEnd(CurTime() + self.ChargeDuration)
	ply:SetFOV(self.ChargeFOV,0.5)
	
	timer.Simple(1,function()
		if(IsValid(ply))then
		ply:SetFOV(0,0.5)
		end
	end)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.SlashDelayHit)

	self.Weapon:SetNextSecondaryFire( CurTime() + self.ChargeDelay)

end

function SWEP:OnRemove()
	if(IsValid(self:GetOwner()))then
		self:GetOwner():SetFOV(0,0.5)
	end

end

hook.Add("KeyPress", "keypress_crusadersword", function(ply, key)
    if key ~= IN_JUMP then return end
    if not IsFirstTimePredicted() then return end
    local self = ply:GetActiveWeapon()
    if not IsValid(self) or self:GetClass() ~= "weapon_crusadersword" then return end
	if !self.Owner:IsOnGround() then return end --self.Owner:SetPos(self.Owner:GetPos()+Vector(0,0,1))
	self:Jump()
	ply:SetFOV(0,0.5)
	self:SetChargeEnd(CurTime() -1)
end)

hook.Add("KeyRelease", "keyrelease_crusadersword", function(ply, key)
    if key ~= IN_JUMP then return end

	if(ply.CrusaderGravity)then
		ply:SetGravity(1)
		ply.CrusaderGravity = nil
	end
end)

function SWEP:Jump()
	local ply = self:GetOwner()
	ply:SetVelocity(Vector(0,0,100))

	ply.CrusaderGravity = true
	ply:SetGravity(0.4)
	--self:EmitSound("aof/weapons/harp.wav",80,100, 1, CHAN_WEAPON)
	
	self.Weapon:SetNextSecondaryFire( CurTime() + 2)
end

function SWEP:GetViewModelPosition(pos,ang)
	local charging = self:IsCharging()
	local opos,oang = pos*1,ang*1 
	local ang2 = ang*1
	pos = pos + ang2:Forward()*-2
	pos = pos + ang2:Up()*4
	ang:RotateAroundAxis(ang:Right(),-60)
	ang:RotateAroundAxis(ang:Forward(),-15)
	ang:RotateAroundAxis(ang2:Up(),15)
	self.LERPVALUE = math.Approach(self.LERPVALUE or 0,charging and 1 or 0,FrameTime()*4)
	pos = LerpVector(self.LERPVALUE,opos,pos)
	ang = LerpAngle(self.LERPVALUE,oang,ang)
	return pos,ang
end

hook.Add("DoPlayerDeath","Holiness",function(ply,attacker,dmg)
	local wep = dmg:GetInflictor()
	if(wep:GetClass() == "weapon_crusadersword")then
		attacker:SetHealth(math.max(math.min(attacker:Health() + 3,attacker:GetMaxHealth()),attacker:Health()))
		wep.KillChain = (wep.KillChain or 0) + 1
		if(wep.KillChain > 2)then
			wep:SetHoly(true)
		end

		timer.Create(wep:EntIndex().."crusader_chain",5,1,function()
			if(IsValid(wep))then
				wep.KillChain = 0
				if(wep:GetHoly())then
					wep:SetHoly(false)
				end
			end
		end)
	end
end)
