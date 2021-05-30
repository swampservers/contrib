-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Infinity Gauntlet"
SWEP.Instructions = "*snap*"
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.DrawAmmo = false
SWEP.m_WeaponDeploySpeed = 9
SWEP.ViewModel = "models/swamp/v_infinitygauntlet.mdl"
SWEP.WorldModel = "models/swamp/v_infinitygauntlet.mdl"
--SWEP.ViewModelFOV           = 60
SWEP.Spawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function GauntletFizzlePlayer(self, target, attacker)
    if SERVER then
        if (target:InVehicle()) then
            target:ExitVehicle()
        end

        local dmginfo = DamageInfo()
        dmginfo:SetDamage(target:GetHealth()) --is this okay?
        dmginfo:SetDamageType(DMG_DISSOLVE)
        dmginfo:SetAttacker(attacker)
        dmginfo:SetDamageForce(Vector(0, 0, 1))
        dmginfo:SetInflictor(self)
        target:TakeDamageInfo(dmginfo)
        attacker:EmitSound("gauntlet/snap.wav", 100)

        timer.Simple(0, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end
end

function TestFizzleDeath(self, target, attacker)
    if not Safe(target) then
        GauntletFizzlePlayer(self, target, attacker)
    elseif attacker:GetTheater() and attacker:GetTheater():IsPrivate() and attacker:GetTheater():GetOwner() == attacker and attacker:GetLocationName() == target:GetLocationName() then
        GauntletFizzlePlayer(self, target, attacker)
    else
        return
    end
end

function SWEP:PrimaryAttack()
    local eyetrace = self.Owner:GetEyeTrace()

    if eyetrace.Hit then
        if (eyetrace.Entity:IsPlayer() and eyetrace.Entity:Alive()) then
            TestFizzleDeath(self, eyetrace.Entity, self.Owner)
        else
            local target = {nil, 50}

            local allply = player.GetAll()
            local tracepos = self.Owner:GetEyeTrace().HitPos

            for k, v in pairs(allply) do
                if (v:Alive() and v ~= self.Owner) then
                    local otherpos = v:LocalToWorld(v:OBBCenter())
                    local dis = tracepos:Distance(otherpos)

                    if (dis < target[2]) then
                        local tr = util.TraceLine({
                            start = tracepos,
                            endpos = otherpos,
                            filter = allply
                        })

                        if tr.Hit then continue end

                        target = {v, dis}
                    end
                end
            end

            if (target[2] < 50) then
                TestFizzleDeath(self, target[1], self.Owner)
            end
        end
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:Deploy()
    self:SetHoldType("fist")
end

function SWEP:DrawHUD()
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 2, Color(0, 0, 0, 25))
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 1, Color(255, 255, 255, 10))
end

function SWEP:CreateWorldModel()
    if not IsValid(self.WModel) then
        self.WModel = ClientsideModel(self.WorldModel, RENDERGROUP_OPAQUE)
        self.WModel:SetNoDraw(true)
        self.WModel:SetBodygroup(1, 1)
    end

    return self.WModel
end

function SWEP:DrawWorldModel()
    local wm = self:CreateWorldModel()
    local bone = self.Owner:LookupBone("ValveBiped.Bip01_L_Hand") or 0
    local opos = self:GetPos()
    local oang = self:GetAngles()
    local bp, ba = self.Owner:GetBonePosition(bone)

    if (bp) then
        opos = bp
    end

    if (ba) then
        oang = ba
    end

    wm:SetModelScale(3.5)
    opos = opos + oang:Right() * -18
    opos = opos + oang:Forward() * -19
    opos = opos + oang:Up() * 3.5
    oang:RotateAroundAxis(oang:Right(), 210)
    oang:RotateAroundAxis(oang:Forward(), -50)
    oang:RotateAroundAxis(oang:Up(), 210)
    wm:SetRenderOrigin(opos)
    wm:SetRenderAngles(oang)
    wm:DrawModel()
end

function SWEP:OnRemove()
    if self.WModel then
        self.WModel:Remove()
    end
end