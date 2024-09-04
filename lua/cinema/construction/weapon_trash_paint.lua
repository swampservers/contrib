-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("weapon_swamp_base")
SWEP.PrintName = "Paint Bucket"
SWEP.DrawAmmo = false
SWEP.ViewModelFOV = 85
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.Purpose = "Paint things"
SWEP.Instructions = "Primary: Paint object\nSecondary: Unpaint object\nReload: Change Color"
SWEP.AdminSpawnable = false
SWEP.ViewModel = Model("models/props_junk/metal_paintcan001a.mdl")
SWEP.WorldModel = Model("models/props_junk/metal_paintcan001a.mdl")
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
    local owner = self:GetOwner()
    self:SetModelScale(0.8)

    if IsValid(owner) then
        local bn = owner:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
        local bon = owner:LookupBone(bn) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = owner:GetBonePosition(bon)

        if bp then
            opos = bp
        end

        if ba then
            oang = ba
        end

        if owner:IsPony() then
            opos = opos + oang:Forward() * 9.7
            opos = opos + oang:Up() * 1
            opos = opos + oang:Right() * -7
            oang:RotateAroundAxis(oang:Forward(), 90)
            --oang:RotateAroundAxis(oang:Up(),-90)
        else
            opos = opos + oang:Right() * 6
            opos = opos + oang:Forward() * 3.5
            opos = opos + oang:Up() * 0.4
            oang:RotateAroundAxis(oang:Up(), -90)
            oang:RotateAroundAxis(oang:Forward(), 180)
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
    ang:RotateAroundAxis(ang:Up(), 20)
    ang:RotateAroundAxis(ang:Forward(), -10)

    return pos, ang
end

function SWEP:PreDrawViewModel(vm, wp, ply)
    render.SetColorModulation(TrashPaintColor.x * 0.9 + 0.2, TrashPaintColor.y * 0.9 + 0.2, TrashPaintColor.z * 0.9 + 0.2)
end

function SWEP:PostDrawViewModel(vm, wp, ply)
    render.SetColorModulation(1, 1, 1)
end

if CLIENT then
    TrashPaintColor = Vector(1, 1, 1)
    TrashPaintColorFrame = nil
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.3)
    if not IsFirstTimePredicted() then return end

    if CLIENT then
        if PropTrashLookedAt then
            net.Start("TrashAction")

            net.WriteTable({
                ent = PropTrashLookedAt,
                act = TRASHACT_PAINT,
                hitpos = PropTrashLookedAtPos,
                color = TrashPaintColor
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
                act = TRASHACT_UNPAINT,
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
        if IsValid(TrashPaintColorFrame) then return end
        local Frame = vgui.Create("DFrame")
        Frame:SetSize(320, 240) --good size for example
        Frame:SetTitle("Choose paint color")
        Frame:Center()
        Frame:MakePopup()
        local Mixer = vgui.Create("DColorMixer", Frame)
        Mixer:Dock(FILL)
        Mixer:SetPalette(true)
        Mixer:SetAlphaBar(false)
        Mixer:SetWangs(true)
        Mixer:SetVector(TrashPaintColor)
        Mixer:DockPadding(0, 0, 0, 40)
        local DButton = vgui.Create("DButton", Frame)
        DButton:SetPos(128, 200)
        DButton:SetText("Choose")
        DButton:SetSize(64, 32)

        DButton.DoClick = function()
            surface.PlaySound("weapons/smg1/switch_single.wav")
            TrashPaintColor = Mixer:GetVector()
            Frame:Remove()
        end

        TrashPaintColorFrame = Frame
    end

    return false
end

function SWEP:DrawHUD()
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 2, Color(0, 0, 0, 25))
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 1, Color(255, 255, 255, 10))
end
