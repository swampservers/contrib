-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SWEP.PrintName = "Cable Maker"
SWEP.DrawAmmo = false
SWEP.ViewModelFOV = 85
SWEP.Slot = 5
SWEP.SlotPos = 0
SWEP.Purpose = "Build things"
SWEP.Instructions = "Primary: Make cables (click and drag)\nSecondary: Remove cables"
SWEP.AdminSpawnable = false
SWEP.ViewModel = "models/props_c17/pulleywheels_small01.mdl"
SWEP.WorldModel = "models/props_c17/pulleywheels_small01.mdl"
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
CABLE_MAX_LENGTH = 100

-- models/props_c17/pulleywheels_small01.mdl
function SWEP:Initialize()
    self:SetHoldType("slam")
end

local trashcablestartdata = nil

function SWEP:PrimaryAttack()
    if not (CLIENT and IsFirstTimePredicted()) then return end

    if IsValid(PropTrashLookedAt) then
        trashcablestartdata = {PropTrashLookedAt, PropTrashLookedAt:WorldToLocal(PropTrashLookedAtPos), true}
    end
end

function SWEP:SecondaryAttack()
    if not (CLIENT and IsFirstTimePredicted()) then return end

    if IsValid(PropTrashLookedAt) then
        trashcablestartdata = {PropTrashLookedAt, PropTrashLookedAt:WorldToLocal(PropTrashLookedAtPos), false}
    end
end

if CLIENT then
    -- TODO: make taping (including to world)? like this
    hook.Add("KeyRelease", "FinishTrashCable", function(ply, key)
        if key == IN_ATTACK or key == IN_ATTACK2 then
            if trashcablestartdata and IsValid(trashcablestartdata[1]) then
                if IsValid(PropTrashLookedAt) or WorldLookedAtPos then
                    net.Start("TrashAction")

                    net.WriteTable({
                        ent = trashcablestartdata[1],
                        entpos = trashcablestartdata[2],
                        ent2 = PropTrashLookedAt or game.GetWorld(),
                        ent2pos = WorldLookedAtPos or PropTrashLookedAt:WorldToLocal(PropTrashLookedAtPos),
                        act = trashcablestartdata[3] and "cable" or "disconnect"
                    })

                    net.SendToServer()
                end
            end

            trashcablestartdata = nil
        end
    end)

    local beem = Material("effects/tool_tracer")

    -- trails/physbeam
    -- trails/tube
    -- trails/electric
    -- trails/plasma
    -- trails/laser
    -- trails/lol
    -- cable/redlaser
    -- cable/cable2
    -- cable/rope
    -- cable/blue_elec
    -- cable/xbeam
    -- cable/physbeam
    -- cable/hydra
    hook.Add("PostDrawTranslucentRenderables", "TrashCablePreview", function(d, s, s3)
        if d or s3 then return end

        if trashcablestartdata and IsValid(trashcablestartdata[1]) then
            render.SetMaterial(beem)
            local p1, p2 = trashcablestartdata[1]:LocalToWorld(trashcablestartdata[2]), PropTrashLookedAtPos or WorldLookedAtPos or EyePos() + EyeAngles():Forward() * 80
            local c = trashcablestartdata[3] and Color(255, 255, 255) or Color(255, 255, 0)

            if trashcablestartdata[1] ~= PropTrashLookedAt and (PropTrashLookedAtPos or WorldLookedAtPos) then
                c = trashcablestartdata[3] and Color(0, 255, 0) or Color(255, 0, 0)
            end

            if p1:Distance(p2) > CABLE_MAX_LENGTH then
                c = trashcablestartdata[3] and Color(255, 55, 0) or Color(255, 255, 0)
            end

            local r = 0 --math.random()
            render.DrawBeam(p1, p2, 2, r - p1:Distance(p2) * 0.1, p1:Distance(p2) * 0.1 + 1 + r, c)
        end
    end)
end

function SWEP:Reload()
end

function SWEP:DrawHUD()
end

-- surface.DrawCircle(ScrW() / 2, ScrH() / 2, 2, Color(0, 0, 0, 25))
-- surface.DrawCircle(ScrW() / 2, ScrH() / 2, 1, Color(255, 255, 255, 10))
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
            opos = opos + oang:Forward() * 9.5
            opos = opos + oang:Up() * 3.6
            opos = opos + oang:Right() * -3.7
            oang:RotateAroundAxis(oang:Right(), 180)
            oang:RotateAroundAxis(oang:Up(), -90)
        else
            opos = opos + oang:Right() * 7
            opos = opos + oang:Forward() * 2
            opos = opos + oang:Up() * 1
            -- oang:RotateAroundAxis(oang:Up(), 90)
            oang:RotateAroundAxis(oang:Right(), 180)
            oang:RotateAroundAxis(oang:Forward(), -90)
            -- oang:RotateAroundAxis(oang:Forward(), -90)
        end

        self:SetupBones()
        local mrt = self:GetBoneMatrix(0)

        if mrt then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            mrt:Scale(Vector(1, 1, 1) * 0.8)
            self:SetBoneMatrix(0, mrt)
        end
    end

    self:DrawModel()
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 10
    pos = pos + ang:Up() * -15
    pos = pos + ang:Forward() * 25
    ang:RotateAroundAxis(ang:Up(), 110)
    ang:RotateAroundAxis(ang:Forward(), -60)

    return pos, ang
end
