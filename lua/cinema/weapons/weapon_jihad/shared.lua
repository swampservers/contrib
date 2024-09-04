-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("weapon_swamp_base")
SWEP.PrintName = "Suicide Bombing"
SWEP.Slot = 4
SWEP.WorldModel = Model("models/dav0r/tnt/tnt.mdl")
SWEP.ViewModel = ""

function SWEP:Deploy()
    BaseClass.Deploy(self)
    self.ActivateAfter = CurTime() + 0.5
end

function SWEP:PrimaryAttack()
    if CurTime() < (self.ActivateAfter or 0) then return end

    if CLIENT then
        if not HumanTeamName and self.Owner == Me then
            if Me:IsPony() then
                RunConsoleCommand("act", "dance")
            else
                RunConsoleCommand("act", "zombie")
            end
        end
    else
        self:DoPrimaryAttack()
    end
end

function SWEP:SecondaryAttack()
    if self.Owner:Crouching() then
        self:EmitSound("isissong.ogg", 90, 160, 1)
    else
        self:EmitSound("isissong.ogg", 90, 100, 1)
    end

    if SERVER then
        SetPlayerSpeechDuration(self.Owner, 10)
    end

    self.Weapon:SetNextSecondaryFire(CurTime() + 1)
end
