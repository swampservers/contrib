-- This file is subject to copyright - contact swampservers@gmail.com for more information.

SWEP.PrintName = "Dodgeball"

SWEP.Slot = 0

SWEP.ViewModel = Model("models/XQM/Rails/gumball_1.mdl")
SWEP.WorldModel = Model("models/XQM/Rails/gumball_1.mdl")

local outie = 64
local innie = 28

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 1)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	if SERVER then
		timer.Simple(.1, function()
			if IsValid(self) and IsValid(self.Owner) then
				local p1 = self.Owner:GetPos()+self.Owner:GetCurrentViewOffset()
				local p2 = p1+(self.Owner:GetAimVector()*outie)
				local tr = util.TraceLine({ start=p1, endpos=p2, mask=MASK_SOLID_BRUSHONLY } )
				if tr.Hit then p2 = tr.HitPos end
				p2 = p2-(self.Owner:GetAimVector()*innie)
				makeDodgeball(p2,(self.Owner:GetAimVector()*1000)+self.Owner:GetVelocity(),self.Owner)
				self.Owner:StripWeapon("weapon_dodgeball")
			end
		end)
	end
end

function SWEP:SecondaryAttack()
self:SetNextSecondaryFire(CurTime() + 1)
self.Owner:SetAnimation( PLAYER_ATTACK1 )
if SERVER then
	timer.Simple(.1, function()
		if IsValid(self) and IsValid(self.Owner) then
			local p1 = self.Owner:GetPos()+self.Owner:GetCurrentViewOffset()
			local p2 = p1+(self.Owner:GetAimVector()*outie)
			local tr = util.TraceLine({ start=p1, endpos=p2, mask=MASK_SOLID_BRUSHONLY } )
			if tr.Hit then p2 = tr.HitPos end
			p2 = p2-(self.Owner:GetAimVector()*innie)
			makeDodgeball(p2,(self.Owner:GetAimVector()*500)+self.Owner:GetVelocity(),self.Owner)
			self.Owner:StripWeapon("weapon_dodgeball")
		end
	end)
end
end

function SWEP:Reload()
	self:SetNextPrimaryFire(CurTime() + 1)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
if SERVER then
	timer.Simple(.05, function()
		if IsValid(self) and IsValid(self.Owner) then
			local p1 = self.Owner:GetPos()+self.Owner:GetCurrentViewOffset()
			local p2 = p1+(self.Owner:GetAimVector()*outie)
			local tr = util.TraceLine({ start=p1, endpos=p2, mask=MASK_SOLID_BRUSHONLY } )
			if tr.Hit then p2 = tr.HitPos end
			p2 = p2-(self.Owner:GetAimVector()*innie)
			makeDodgeball(p2,(self.Owner:GetAimVector()*200)+self.Owner:GetVelocity(),self.Owner)
			self.Owner:StripWeapon("weapon_dodgeball")
		end
	end)
end
end
