-- This file is subject to copyright - contact swampservers@gmail.com for more information.

SWEP.PrintName = "Suicide Bombing"

SWEP.Slot = 4

SWEP.WorldModel = Model("models/dav0r/tnt/tnt.mdl")

function SWEP:PrimaryAttack()
	if CLIENT then
		if self.Owner==LocalPlayer() then
			if LocalPlayer():IsPony() then
				RunConsoleCommand("act","dance")
			else
				RunConsoleCommand("act","zombie")
			end
		end
	else
		self:DoPrimaryAttack()
	end
end

function SWEP:SecondaryAttack()
	if self.Owner:Crouching() then
		self:EmitSound( "isissong.ogg", 90, 160, 1 )
	else
		self:EmitSound( "isissong.ogg", 90, 100, 1 )
	end
	if SERVER then
		SetPlayerSpeechDuration(self.Owner,10)
	end
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)
end
