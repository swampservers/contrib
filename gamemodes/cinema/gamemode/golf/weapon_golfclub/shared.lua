-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Golf Club"
SWEP.ViewModel = "models/pyroteknik/putter.mdl"
SWEP.WorldModel = "models/pyroteknik/putter.mdl"
SWEP.Slot = 0
SWEP.AutoSwitchTo = false
-------------------------------------------------------------------
SWEP.Author = "Swamp & PYROTEKNIK"
SWEP.Purpose = "Hit the thing with it"
SWEP.Instructions = "Left/right click: place, hit ball\nReload: retry hole"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
-----------------------------------------------
SWEP.Primary.Delay = 0.3
SWEP.Primary.Recoil = 0
SWEP.Primary.Damage = 0
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
-------------------------------------------------
SWEP.Secondary.Delay = 60.999999999
SWEP.Secondary.Recoil = 0
SWEP.Secondary.Damage = 1
SWEP.Secondary.NumShots = 1
SWEP.Secondary.Cone = 0
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

-------------------------------------------------
function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "Stage")
    self:NetworkVar("Int", 1, "Stroke")
    self:NetworkVar("Entity", 0, "Ball")
    self:NetworkVar("Bool", 1, "Controls")
end

-- Called every frame
function SWEP:Think()
    -- if SERVER and self:GetOwner()==ME() then print(self:GetStage()) end
    local ht = (self:GetStage() == 2) and "passive" or "normal"

    if ht ~= self:GetHoldType() then
        self:SetHoldType(ht)
    end

    if SERVER and self:GetStage() == 2 then
        -- print(self:GetBall())
        if self.Owner:GetPos():Distance(self:GetBall():GetPos()) > self.ShotFinishDist + 300 then
            self:CancelShot()
        end
    end
    -- if (SERVER) then
    --     if (self:Clip1() > 0 and stage ~= 0) then
    --         self:SetStage(0)
    --     end
    --     if (stage == 1) then
    --         local fball = self.ActiveBall
    --         if (IsValid(fball)) then
    --             if (not fball:GetPhysicsObject():IsMotionEnabled()) then
    --                 self:SetBallToShoot(fball)
    --                 self:SetStage(2)
    --             end
    --         end
    --     end
    -- end
end

function SWEP:WeirdGolf()
    return self:GetBall():GetControls()
end

function SWEP:PrimaryAttack()
    if self:GetStage() == 2 and self:WeirdGolf() then
        if CLIENT and Me == self.Owner and IsFirstTimePredicted() then
            if GOLFCAMVECTOR then
                ENDGOLFSHOT()

                return
            end

            local ball = self:GetBall()
            local p1 = ball:GetPos()
            local p2 = util.IntersectRayWithPlane(self:GetOwner():EyePos(), self:GetOwner():EyeAngles():Forward(), p1, Vector(0, 0, 1))

            if p1:Distance(self.Owner:GetPos()) < 80 and p2 then
                local vec = p2 - p1
                vec.z = 0
                STARTGOLFSHOT(vec:GetNormalized())
            end
        end

        return
    end

    -- if self:GetStage()== 2 then
    --     self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    -- end
    if SERVER then
        self:SV_PrimaryAttack()
    end

    self:SetNextPrimaryFire(CurTime() + 0.2)
    self:SetNextSecondaryFire(CurTime() + 0.2)

    return true
end

function SWEP:SecondaryAttack()
    if SERVER then
        self:CancelShot()
    end
end

function SWEP:Reload()
    if SERVER then
        if CurTime() - (self.ReloadTime or 0) < 0.5 then return end
        self.ReloadTime = CurTime()
        self:CancelShot()
        self:SetControls(not self:GetControls())
        self.Owner:SendLua([[surface.PlaySound('weapons/smg1/switch_single.wav')]])
    end
end

function SWEP:Holster()
    if SERVER then
        self:CancelShot()
    end

    return true
end

function SWEP:OnRemove()
    if SERVER then
        self:CancelShot()
    end
end

function HitGolfball(ball, speed)
    speed.z = 0

    if speed:Length() > 500 then
        speed = speed:GetNormalized() * 500
    end

    ball:GetPhysicsObject():ApplyForceCenter(speed * 40)
end
