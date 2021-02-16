-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

SWEP.ViewModel = "models/Teh_Maestro/popcorn.mdl"
SWEP.WorldModel = "models/Teh_Maestro/popcorn.mdl"

SWEP.PrintName          = "Popcorn"
SWEP.Slot				= 0

SWEP.Primary.ClipSize			= -1
SWEP.Primary.Damage				= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic			= false
SWEP.Primary.Ammo				= "none"

SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Damage			= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo				= "none"

function SWEP:Deploy()
end

function SWEP:Think()
    if (self.Owner.ChewScale or 0) > 0 then
		if SERVER and self.Owner.BiteStart and CurTime() >= self.Owner.BiteStart+0.625 and self.Owner.BitesRem > 0 then
			self.Owner.BiteStart = CurTime()
			self.Owner.BitesRem = self.Owner.BitesRem - 1
			net.Start("Popcorn_Eat")
				net.WriteEntity(self.Owner)
				net.WriteFloat(math.Round(math.Rand(4,8)+self.Owner.BitesRem*8))
			net.Broadcast()
		end
        self.Owner.ChewScale = math.Clamp((self.Owner.ChewStart+self.Owner.ChewDur - CurTime())/self.Owner.ChewDur,0,1)
    end
end

function SWEP:PrimaryAttack()
	if SERVER then
        self.Owner:EmitSound( "crisps/eat.wav", 60)
		self.Owner.BiteStart = 0
		self.Owner.BitesRem = 3
		net.Start("Popcorn_Eat_Start")
			net.WriteEntity(self.Owner)
		net.Broadcast()
		self.Owner:SetHealth(math.min(self.Owner:Health()+25,self.Owner:GetMaxHealth()))
	end
	self.Owner.ChewScale = 1
	self.Owner.ChewStart = CurTime()
	self.Owner.ChewDur = SoundDuration("crisps/eat.wav")
	self.Weapon:SetNextPrimaryFire(CurTime() + 12 )
end

function SWEP:SecondaryAttack()
	local bucket, att, phys, tr

	self.Weapon:SetNextSecondaryFire(CurTime() + 0.15)
    
    if CLIENT then
        return
    end

    if self:GetClass()=="weapon_popcorn_spam" then
    	local t = self.Owner:GetTheater()
    	if t and t:Name()=="Movie Theater" then
    		return
    	end
    end
    
    self.Owner:EmitSound( "weapons/slam/throw.wav" )
	
	self.Owner:ViewPunch( Angle( math.Rand(-8,8), math.Rand(-8,8), 0 ) )
	
    bucket = ents.Create(self:GetClass()=="weapon_sandcorn" and "sent_sandcorn_thrown" or "sent_popcorn_thrown")
    bucket:SetOwner( self.Owner )
    bucket:SetPos( self.Owner:GetShootPos( ) )
    bucket:Spawn() 
    bucket:Activate()
	
    phys = bucket:GetPhysicsObject( )
        
    if IsValid( phys ) then
		phys:SetVelocity( self.Owner:GetPhysicsObject():GetVelocity() )
		phys:AddVelocity( self.Owner:GetAimVector( ) * 128 * phys:GetMass( ) )
		phys:AddAngleVelocity( VectorRand() * 128 * phys:GetMass( ) )
    end
	
	
	if self:GetClass()~="weapon_popcorn_spam" then
		self.Owner:StripWeapon(self:GetClass())
	end
	
end
