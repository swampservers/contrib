-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Pickaxe"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.DrawWeaponInfoBox = true
SWEP.ViewModelFOV = 85
SWEP.ViewModelFlip = false
SWEP.Slot = 5
SWEP.SlotPos = 2
SWEP.Purpose = "Mine gold for points"
SWEP.Instructions = "Primary: Mine\nSecondary: Craft"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.ViewModel = Model("models/staticprop/props_mining/pickaxe01.mdl")
SWEP.WorldModel = Model("models/staticprop/props_mining/pickaxe01.mdl")
SWEP.Weight = 5
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
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
    self:SetHoldType("melee2")
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.75)
    self.Owner:SetAnimation(PLAYER_ATTACK1)

    if CLIENT then
        self.swingtime = CurTime()
    end

    if SERVER then
        if not self.Owner:InTheater() then
            sound.Play("weapons/iceaxe/iceaxe_swing1.wav", self.Owner:GetPos(), 60, 100, 0.4)
        end

        local ent = self.Owner:GetEyeTrace().Entity

        if IsValid(ent) and ent:GetClass() == "goldnugget" and (ent:GetPos():Distance(self.Owner:EyePos()) < 160) then
            timer.Simple(0.1, function()
                if IsValid(ent) then
                    sound.Play("swamponions/pickaxe.wav", ent:GetPos(), 80, 100, 1)

                    if IsValid(self.Owner) then
                        ent:Mine(self.Owner)
                    end
                end
            end)
        end
    end
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 10)

    if CLIENT then
        RunConsoleCommand("say", "minecraft XD")
    end
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if (IsValid(ply)) then
        local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
        local bon = ply:LookupBone(bn) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = ply:GetBonePosition(bon)

        if (bp) then
            opos = bp
        end

        if (ba) then
            oang = ba
        end

        opos = opos + oang:Right() * 1
        opos = opos + oang:Forward() * 3
        opos = opos + oang:Up() * 8

        if ply:IsPony() then
            opos = opos + oang:Forward() * 4
            opos = opos + oang:Up() * 8
            opos = opos + oang:Right() * -3.5
        end

        oang:RotateAroundAxis(oang:Right(), 180)
        self:SetupBones()
        self:SetModelScale(0.8, 0)
        local mrt = self:GetBoneMatrix(0)

        if (mrt) then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            self:SetBoneMatrix(0, mrt)
        end
    end

    self:DrawModel()
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 22
    pos = pos + ang:Up() * -30
    pos = pos + ang:Forward() * 25
    local dt = CurTime() - (self.swingtime or 0)
    ang:RotateAroundAxis(ang:Up(), 180)
    ang:RotateAroundAxis(ang:Right(), (55 * math.Clamp(math.min((dt) * 15, 1.5 + ((dt) * -2)), 0, 1)))

    return pos, ang
end

function SWEP:DrawHUD()
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 2, Color(0, 0, 0, 25))
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 1, Color(255, 255, 255, 10))
    local ptlrp = CurTime() - pickaxepointtime

    if ptlrp < 0.9 then
        draw.DrawText("+" .. tostring(pickaxepointamount), "TargetID", (ScrW() * 0.5) + (pickaxepointdirx * ptlrp * 100), (ScrH() * 0.5) - (50 + (ptlrp * 100)), Color(255, 200, 50, 255 * (0.9 - ptlrp)), TEXT_ALIGN_CENTER)
    end
end

if CLIENT then
    pickaxepointtime = CurTime()
    pickaxepointamount = 0
    pickaxepointdirx = 0

    net.Receive("PickaxePoints", function()
        pickaxepointtime = CurTime()
        pickaxepointamount = net.ReadInt(16)
        pickaxepointdirx = math.Rand(-0.4, 0.4)
    end)
end