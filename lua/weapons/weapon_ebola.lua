-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Coronavirus"
SWEP.DrawAmmo = false
SWEP.ViewModelFOV = 85
SWEP.Slot = 0
SWEP.SlotPos = 2
SWEP.Purpose = "Die"
SWEP.Instructions = "Primary: Cough"
SWEP.AdminSpawnable = false
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Damage = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
    self:SetHoldType("normal")
end

if SERVER then
    ebprint = true

    timer.Create("Ebolaaa", 1.8, 0, function()

        ebprint = not ebprint

        for k, v in ipairs(Ents.player) do
            if v:HasWeapon("weapon_ebola") then
                if v:Health() < 3 then
                    v:ChatPrint("[red]you died of coronavirus")
                    v:Kill()
                else
                    if math.random() < 0.2 then
                        v:GetWeapon("weapon_ebola"):PrimaryAttack()
                    end

                    if math.random() < 0.03 then
                        v:ChatPrint("[green]coronavirus healed")
                        v:StripWeapon("weapon_ebola")
                    else
                        if ebprint then
                            v:ChatPrint("[red]you have coronavirus")
                        end

                        v:SetHealth(v:Health() - 2)
                    end
                end
            end
        end

    end)
end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    self:SetNextPrimaryFire(CurTime() + 1)
    self.Owner:EmitSound("ambient/voices/cough" .. tostring(math.random(1, 4)) .. ".wav")

    if SERVER then
        local coughcenter = self.Owner:GetPos() + (self.Owner:GetAimVector() * 20)

        for k, v in ipairs(Ents.player) do
            if v:IsProtected() or v:InVehicle() then continue end
            if v:GetNWBool("spacehat") then continue end

            if v:GetPos():DistToSqr(coughcenter) < (60 * 60) then
                if not v:HasWeapon("weapon_ebola") then
                    v:Give("weapon_ebola")
                    v:SelectWeapon("weapon_ebola")
                end
            end
        end
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:DrawWorldModel()
end

function SWEP:GetViewModelPosition(pos, ang)
end

function SWEP:PostDrawViewModel()
end
