-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Cable Maker"
SWEP.DrawAmmo = false
SWEP.ViewModelFOV = 85
SWEP.Slot = 5
SWEP.SlotPos = 0
SWEP.Purpose = "Build things"
SWEP.Instructions = "Primary: Make cables (hold and release)"
SWEP.AdminSpawnable = false
SWEP.ViewModel = "models/weapons/c_toolgun.mdl"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"
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

function SWEP:Initialize()
    self:SetHoldType("pistol")
end

local trashcabledata = nil

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.3)
    if not IsFirstTimePredicted() then return end

    if CLIENT then
        if IsValid(PropTrashLookedAt) then
            trashcabledata = {PropTrashLookedAt, PropTrashLookedAt:WorldToLocal(PropTrashLookedAtPos)}
        end
    end
    -- if CLIENT then
    --     if PropTrashLookedAt then
    --         net.Start("TrashAction")
    --         net.WriteTable({
    --             ent = PropTrashLookedAt,
    --             act = TRASHACT_TAPE,
    --             hitpos = PropTrashLookedAtPos
    --         })
    --         net.SendToServer()
    --     end
    -- end
end

if CLIENT then
    hook.Add("KeyRelease", "FinishTrashCable", function(ply, key)
        if key == IN_ATTACK then
            if trashcabledata and IsValid(trashcabledata[1]) then
                if IsValid(PropTrashLookedAt) or WorldLookedAtPos then
                    net.Start("TrashAction")

                    net.WriteTable({
                        ent = trashcabledata[1],
                        entpos = trashcabledata[2],
                        ent2 = PropTrashLookedAt or game.GetWorld(),
                        ent2pos = WorldLookedAtPos or PropTrashLookedAt:WorldToLocal(PropTrashLookedAtPos),
                        act = "cable"
                    })

                    net.SendToServer()
                end
            end

            trashcabledata = nil
        end
    end)

    local beem = Material("effects/tool_tracer")

    hook.Add("PostDrawTranslucentRenderables", "TrashCablePreview", function(d, s, s3)
        if d or s3 then return end

        if trashcabledata and IsValid(trashcabledata[1]) then
            render.SetMaterial(beem)
            local p1, p2 = trashcabledata[1]:LocalToWorld(trashcabledata[2]), PropTrashLookedAtPos or WorldLookedAtPos or (EyePos() + EyeAngles():Forward() * 80)
            local c = Color(255, 255, 255)

            if trashcabledata[1] ~= PropTrashLookedAt and (PropTrashLookedAtPos or WorldLookedAtPos) then
                c = Color(0, 255, 0)
            end

            if p1:Distance(p2) > CABLE_MAX_LENGTH then
                c = Color(255, 55, 0)
            end

            local r = 0 --math.random()
            render.DrawBeam(p1, p2, 2, r - p1:Distance(p2) * 0.1, p1:Distance(p2) * 0.1 + 1 + r, c)
        end
    end)
end

function SWEP:SecondaryAttack()
    net.Start("TrashAction")

    net.WriteTable({
        ent = PropTrashLookedAt,
        act = "uncable"
    })

    net.SendToServer()
end

function SWEP:Reload()
end

function SWEP:DrawHUD()
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 2, Color(0, 0, 0, 25))
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 1, Color(255, 255, 255, 10))
end
