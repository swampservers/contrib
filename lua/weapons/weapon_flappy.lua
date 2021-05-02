-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Flappy Fedora"
SWEP.Slot = 1
SWEP.Instructions = "Press jump to tip your fedora!"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 85
SWEP.WorldModel = Model("models/fedora_rainbowdash/fedora_rainbowdash.mdl")
SWEP.ViewModel = Model("models/fedora_rainbowdash/fedora_rainbowdash.mdl")

function SWEP:Initialize()
    self:SetHoldType("normal")
    self.justreloaded = 0
    self.jumptimer = 0
    self.cantip = true
end

function SWEP:Deploy()
    if not self.Owner:InTheater() then
        self:EmitSound("mlady.ogg")
    end

    if CLIENT then return end
    local ply = self:GetOwner()

    
    --if ply already has a trail, don't create a new one
    if not IsValid(ply.FedoraPoint) then
        ply.FedoraPoint = ents.Create("ent_fedora_point")
        ply.FedoraPoint:SetOwner(ply)
        ply.FedoraPoint:Spawn()
        ply.FedoraPoint:Activate()
    end
    -- if not IsValid(ply:GetNWEntity("fedora_point")) then
    --     local fp = ents.Create("ent_fedora_point")
    --     fp:SetOwner(ply)
    --     fp:Spawn()
    --     fp:Activate()
    --     ply:SetNWEntity("fedora_point", fp)
    -- end
end

function SWEP:Holster()
    return true
end

function SWEP:OnRemove()
    if CLIENT then
        if self.Owner and self.Owner:IsValid() then
            sound.Play("friendzoned.ogg", self.Owner:GetPos(), 75, 100, 1)
        end
    end
end

function SWEP:OwnerChanged()
    if SERVER and IsValid(self.Owner) then
        self:ExtEmitSound("mlady.ogg", {
            speech = 0.8
        })
    end
end




hook.Add("SetupMove", "flappy_SetupMove", function(ply, mv, cmd)
    if mv:KeyPressed(IN_JUMP) then
        local self = ply:GetActiveWeapon()
        if not IsValid(self) or self:GetClass() ~= "weapon_flappy" then return end
        if ply.InTheater and ply:InTheater() and not ply:IsOnGround() then return end

        if CLIENT and IsFirstTimePredicted() then self.TipTime = SysTime() end

        local vel = mv:GetVelocity()
        vel.z = 220
        mv:SetVelocity(vel)
        ply:DoCustomAnimEvent(PLAYERANIMEVENT_JUMP , -1)
        self:ExtEmitSound("tip.ogg", {
                    speech = 0,
                    shared = true
                })
    end
end)

function SWEP:PrimaryAttack()
    self:ExtEmitSound("nice meme.ogg", {
        speech = 0.7,
        shared = true
    })
end

function SWEP:SecondaryAttack()
    self:ExtEmitSound("mlady.ogg", {
        speech = 0.8,
        shared = true
    })
end


function SWEP:Reload()
    if self.Owner:KeyPressed( IN_RELOAD) then
        self:ExtEmitSound("friendzoned.ogg", {
            speech = 0.85,
            shared = true
        })
    end
end


if CLIENT then


    FLAPPY_TRAILS = {}

    function SWEP:DrawWorldModel()
        local ply = self:GetOwner()
    
        if IsValid(ply) then

            if not IsValid(self.TRAIL) then
                timer.Simple(0,function()
                    if IsValid(self) and not IsValid(self.TRAIL) then
                        -- self.TRAIL = ents.CreateClientside("env_spritetrail")
                        -- print(self.TRAIL)
                        -- FLAPPY_TRAILS[self.TRAIL] = true
                        -- self.TRAIL.WEAPON = self
                    end
                end)
    
            end


            local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_Head1"
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
                oang:RotateAroundAxis(oang:Forward(), 90)
                oang:RotateAroundAxis(oang:Up(), -90)
                opos = opos + (oang:Up() * 13)
            else
                oang:RotateAroundAxis(oang:Right(), -90)
                oang:RotateAroundAxis(oang:Up(), 180)
                opos = opos + (oang:Right() * -0.5) + (oang:Up() * 6.5)
            end
    
            self:SetupBones()
            local mrt = self:GetBoneMatrix(0)

            if IsValid(self.TRAIL) then
                print("TRAL")
                self.TRAIL:SetPos(opos)
            end

    
            if mrt then
                mrt:SetTranslation(opos)
                mrt:SetAngles(oang)
                self:SetBoneMatrix(0, mrt)
            end
        end
    
        self:DrawModel()
    end


hook.Add("Think","FlappyTrailCleanup",function()
    for k,v in pairs(FLAPPY_TRAILS) do
        if (not IsValid(v)) or (not IsValid(v.WEAPON)) or (not IsValid(v.WEAPON.Owner)) then
            v:Remove()
            FLAPPY_TRAILS[k]=nil
        end
    end
end)

end


SWEP.SwayScale =0

function SWEP:GetViewModelPosition(pos, ang)
    -- pos,ang = EyePos(), EyeAngles()

    local tipdelay = SysTime()-(self.TipTime or 0)

    local tipness = 1-math.min(tipdelay*6, 1)

    pos = pos + ang:Up() * 5.5
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), -8 + (math.Clamp((CurTime() - self.jumptimer) * 4, 0, 1) * 8))

    ang:RotateAroundAxis(ang:Forward(), tipness*-10)

    return pos, ang
end

