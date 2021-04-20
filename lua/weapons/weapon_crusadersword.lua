------------------------------// General Settings \\------------------------------------------------------------|
SWEP.Author 			= "Horatio"                           -- Your name.
SWEP.Contact 			= "Horatio"                     		-- How People could contact you.
SWEP.base 				= "weapon_base"							-- What base should the swep be based on.
SWEP.ViewModel 			= "models/aoc_weapon/v_longsword.mdl" 									-- The viewModel, the model you see when you are holding it.
SWEP.WorldModel 		= "models/aoc_weapon/w_longsword.mdl" 									-- The world model, The model you when it's down on the ground.
SWEP.HoldType 			= "melee2"                            		-- How the swep is hold Pistol smg grenade melee.
SWEP.PrintName 			= "Crusader Sword"                         			-- your sweps name.
SWEP.Category 			= "Crusader Weapons"                					-- Make your own category for the swep.
SWEP.Instructions 		= ""              						-- How do people use your swep.
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
------------------------------\\ General Settings //------------------------------------------------------------|
----------------------------------------------------------------------------------------------------------------|
SWEP.Primary.Automatic 			= true     					-- Do We Have To Click Or Hold Down The Click
SWEP.Primary.Ammo 				= "none"  						-- What Ammo Does This SWEP Use (If Melee Then Use None)   
SWEP.Primary.Damage 			= 500 	               			-- How Much Damage Does The SWEP Do                         
SWEP.Primary.Spread	 			= -1                 			-- How Much Of A Spread Is There (Should Be Zero)
SWEP.Primary.NumberofShots 		= -1                 			-- How Many Shots Come Out (should Be Zero)
SWEP.Primary.Recoil 			= 8                 			-- How Much Jump After An Attack        
SWEP.Primary.ClipSize			= -1                 			-- Size Of The Clip
SWEP.Primary.DefaultClip 		= -1
SWEP.Primary.Delay 				= .7                 			-- How longer Till Our Next Attack       
SWEP.Primary.Force 				= 10                 			-- The Amount Of Impact We Do To The World 
SWEP.Primary.Distance 			= 75                				-- How far can we reach?
SWEP.SwingSound					= "aof/weapons/longsword_attack2.wav"               				-- Sound we make when we swing
SWEP.WallSound 					= "aof/weapons/block_shield5.wav"            				-- Sound when we hit something
SWEP.FleshSound 				= "aof/weapons/hitbod6.wav"            				-- Sound when we hit Flesh
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Damage = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"


------------------------------//Crotch Gun Fix\\------------------------------------------------------------|
SWEP.Offset = {
Pos = {Up = -20, Right = 1, Forward = 49, },
Ang = {Up =90, Right = 0, Forward = 180,}
}
function SWEP:DrawWorldModel( )
	local hand, offset, rotate
	local pl = self:GetOwner()
	if IsValid( pl ) then
		local boneIndex = pl:LookupBone( "ValveBiped.Bip01_R_Hand" )
			if boneIndex then
				local pos, ang = pl:GetBonePosition( boneIndex )
				pos = pos + ang:Forward() * 		 	self.Offset.Pos.Forward + ang:Right() * self.Offset.Pos.Right + ang:Up() * self.Offset.Pos.Up
				ang:RotateAroundAxis( ang:Up(),    	self.Offset.Ang.Up)
				ang:RotateAroundAxis( ang:Right(), 	self.Offset.Ang.Right )
				ang:RotateAroundAxis( ang:Forward(),  self.Offset.Ang.Forward )
				self:SetRenderOrigin( pos )
				self:SetRenderAngles( ang )
				self:DrawModel()
			end
	else
		self:SetRenderOrigin( nil )
		self:SetRenderAngles( nil )
		self:DrawModel()
	end
end

function SWEP:Initialize()
	if ( SERVER ) then
self:SetWeaponHoldType(self.HoldType)
	end
end
--------------

function SWEP:Deploy()
	self.Owner:DrawViewModel(true)
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:PrimaryAttack()

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "swing1" ) )
	self.Weapon:EmitSound(self.SwingSound,100,math.random(90,120))
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay)
	
	if CLIENT then
		
	end
	
	if SERVER then
		
		timer.Simple(.7, function() if self:IsValid() then
			local trace = self.Owner:GetEyeTrace()
		if trace.HitPos:Distance(self.Owner:GetShootPos()) <= (self.Primary.Distance) then
		if ( trace.Hit ) then
		self:EmitSound( self.WallSound , 80, 100, 1, CHAN_WEAPON)
		end
		end
			
			local center = self.Owner:EyePos() + self.Owner:EyeAngles():Forward()*75
			for _,v in ipairs(ents.GetAll()) do
				if v~=self.Owner and v:LocalToWorld(v:OBBCenter()):Distance(center)<75 then
				v:TakeDamage(100,self.Owner,self)
				self:EmitSound( self.FleshSound , 80, 100, 1, CHAN_WEAPON)
				self.Weapon:SetNextPrimaryFire( CurTime() + 1.5)
				self.Owner:SetAnimation( PLAYER_ATTACK1 )

			else
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
			end
			end
			
			else
				self.Weapon:SetNextPrimaryFire(  CurTime() + 1.5 )
				self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				local rnda = self.Primary.Recoil * -1 
				local rndb = self.Primary.Recoil * math.random(-1, 2) 
			end
			
		end)
	end
end

function SWEP:SecondaryAttack()
end