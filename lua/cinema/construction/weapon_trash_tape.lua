-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SWEP.PrintName = "DuckTape"
SWEP.DrawAmmo = false
SWEP.ViewModelFOV = 85
SWEP.Slot = 5
SWEP.SlotPos = 0
SWEP.Purpose = "Build things"
SWEP.Instructions = "Primary: Tape Object Down\nSecondary: Untape object\nReload: Destroy item (or quick spawn trash)\n\nTip: Get another player to hold a prop in position while you tape it!"
SWEP.AdminSpawnable = false
SWEP.ViewModel = Model("models/swamponions/ducktape.mdl")
SWEP.WorldModel = Model("models/swamponions/ducktape.mdl")
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
    self:SetHoldType("slam")
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()
    self:SetModelScale(0.8)

    if IsValid(ply) then
        local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
        local bon = ply:LookupBone(bn) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = ply:GetBonePosition(bon)

        if bp then
            opos = bp
        end

        if ba then
            oang = ba
        end

        if ply:IsPony() then
            opos = opos + oang:Forward() * 9.5
            opos = opos + oang:Up() * 3.6
            opos = opos + oang:Right() * -3.7
            oang:RotateAroundAxis(oang:Right(), 180)
            oang:RotateAroundAxis(oang:Up(), -90)
        else
            opos = opos + oang:Right() * 8.6
            opos = opos + oang:Forward() * 3.5
            opos = opos + oang:Up() * 0.4
            oang:RotateAroundAxis(oang:Right(), 180)
            oang:RotateAroundAxis(oang:Forward(), -90)
        end

        self:SetupBones()
        local mrt = self:GetBoneMatrix(0)

        if mrt then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            self:SetBoneMatrix(0, mrt)
        end
    end

    self:DrawModel()
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 8
    pos = pos + ang:Up() * -12
    pos = pos + ang:Forward() * 18
    ang:RotateAroundAxis(ang:Up(), 110)
    ang:RotateAroundAxis(ang:Forward(), -60)

    return pos, ang
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.3)
    if not IsFirstTimePredicted() then return end

    if CLIENT then
        if PropTrashLookedAt then
            net.Start("TrashAction")

            net.WriteTable({
                ent = PropTrashLookedAt,
                act = TRASHACT_TAPE,
                hitpos = PropTrashLookedAtPos
            })

            net.SendToServer()
        end
    end
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 0.3)
    if not IsFirstTimePredicted() then return end

    if CLIENT then
        if PropTrashLookedAt then
            net.Start("TrashAction")

            net.WriteTable({
                ent = PropTrashLookedAt,
                act = TRASHACT_UNTAPE,
                hitpos = PropTrashLookedAtPos
            })

            net.SendToServer()
        end
    end
end

local LastReloadTime = 0

function SWEP:Reload()
    if CLIENT then
        if LastReloadTime + 0.3 > CurTime() then return end
        LastReloadTime = CurTime()

        if PropTrashLookedAt then
            net.Start("TrashAction")

            net.WriteTable({
                ent = PropTrashLookedAt,
                act = TRASHACT_REMOVE,
                hitpos = PropTrashLookedAtPos
            })

            net.SendToServer()
        else
            SS_Products.trash:Buy()
        end
    end

    return false
end

function SWEP:DrawHUD()
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 2, Color(0, 0, 0, 25))
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 1, Color(255, 255, 255, 10))
end

if CLIENT then
    hook.Add("Think", "TrashToolUpdate", function()
        PropTrashLookedAt = nil

        if IsValid(Me) and IsValid(Me:GetActiveWeapon()) and Me:GetActiveWeapon():GetClass():StartWith("weapon_trash") then
            local self = Me:GetActiveWeapon()
            local tr = {}
            tr.start = self.Owner:GetShootPos()
            tr.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 120
            tr.filter = self.Owner
            tr.mask = MASK_SHOT
            local trace = util.TraceLine(tr)
            PropTrashLookedAt = nil
            PropTrashLookedAtPos = nil
            WorldLookedAtPos = nil

            if trace.Hit then
                --:GetClass():StartWith("prop_trash") then
                if trace.Entity:GetTrashClass() then
                    PropTrashLookedAt = trace.Entity
                    PropTrashLookedAtPos = trace.HitPos
                elseif trace.Entity:IsWorld() then
                    WorldLookedAtPos = trace.HitPos
                end
            end
        end
    end)
end
