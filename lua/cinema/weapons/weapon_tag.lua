-- This file is subject to copyright - contact swampservers@gmail.com for more information.
AddCSLuaFile()
SWEP.PrintName = "Tag"
SWEP.Author = "Ugleh"
SWEP.Purpose = "Tag someone within 30 seconds or you will die."
SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.Weight = 99
SWEP.AutoSwitchFrom = false
SWEP.Spawnable = true
SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = "models/Gibs/HGIBS.mdl"
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 54
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = false
SWEP.HitDistance = 58
SWEP.CannotDrop = true
local justReloaded = 0
local tagTimer = 35

function SWEP:Initialize()
    self:SetHoldType("fist")

    if SERVER then
        self:SetNWFloat("initTime", CurTime())

        timer.Simple(5, function()
            if IsValid(self) and self.Owner:IsFrozen() then
                self.Owner:Freeze(false)
            end
        end)

        timer.Simple(tagTimer, function()
            if IsValid(self) then
                local effectdata = EffectData()
                effectdata:SetOrigin(self:GetPos())
                effectdata:SetMagnitude(0)
                util.Effect("Explosion", effectdata, true, true)
                self:Remove()
                self.Owner:Kill()
            end
        end)
    end
end

function SWEP:Deploy()
    self:SetHoldType("fist")
    local vm = self.Owner:GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))
end

function SWEP:Reload()
    if justReloaded < 1 then
        local pitch = 100 + (self.Owner:Crouching() and 40 or 0)

        self:ExtEmitSound("tag/dead.wav", {
            volume = 0.55,
            pitch = pitch
        })
    end

    justReloaded = 2
end

function SWEP:Tick()
    justReloaded = justReloaded - 1
end

function SWEP:TagPlayer(target, attacker)
    if SERVER then
        target:Freeze(true)
        target:Give("weapon_tag")

        self:ExtEmitSound("tag/frozen.wav", {
            volume = 0.6
        })

        self:ExtEmitSound("tag/slap.wav", {
            volume = 0.9
        })

        timer.Simple(0, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end
end

function SWEP:TestTagPlayer(target, attacker)
    if not target:IsProtected() and not target:InVehicle() then
        self:TagPlayer(target, attacker)
    elseif not target:InTheater() and not target:IsAFK() and target:InVehicle() then
        self:TagPlayer(target, attacker)
    elseif attacker:GetTheater() and attacker:GetTheater():IsPrivate() and attacker:GetTheater():GetOwner() == attacker and attacker:GetLocationName() == target:GetLocationName() then
        self:TagPlayer(target, attacker)
    else
        return
    end
end

function SWEP:DrawHUD()
    local displayTime = math.Round(tagTimer - (CurTime() - self:GetNWFloat("initTime", CurTime())), 1)
    local displayString = "You have " .. displayTime .. " Seconds to tag someone!"

    if displayTime > 30 then
        displayString = "You are IT and FROZEN for " .. displayTime - (tagTimer - 5) .. " seconds!"
    end

    local TextWidth = surface.GetTextSize(displayString)
    draw.WordBox(8, ScrW() / 2 - TextWidth / 2, ScrH() / 2, displayString, "Trebuchet24", Color(0, 0, 0, 128), Color(255, 255, 255, 255))
end

function SWEP:PrimaryAttack(right)
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    local anim = "fists_left"

    if right then
        anim = "fists_right"
    end

    local vm = self.Owner:GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
    self:SetNextPrimaryFire(CurTime() + 0.9)
    self:SetNextSecondaryFire(CurTime() + 0.9)
    local eyetrace = self.Owner:GetEyeTrace()

    if eyetrace.Hit then
        if (eyetrace.Entity:IsPlayer() and eyetrace.Entity:Alive()) and not eyetrace.Entity:IsProtected() then
            self:TestTagPlayer(eyetrace.Entity, self.Owner)
        else
            local target = {nil, 58}

            local allply = player.GetAll()
            local tracepos = self.Owner:GetEyeTrace().HitPos

            for k, v in pairs(allply) do
                if v:Alive() and v ~= self.Owner then
                    local otherpos = v:LocalToWorld(v:OBBCenter())
                    local dis = tracepos:Distance(otherpos)

                    if dis < target[2] then
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

            if target[2] < 58 then
                self:TestTagPlayer(target[1], self.Owner)
            end
        end
    end
end

function SWEP:DrawWorldModel()
    local wm = self:CreateWorldModel()
    local bone = self.Owner:LookupBone("ValveBiped.Bip01_Head1") or 0
    local opos = self:GetPos()
    local oang = self:GetAngles()
    local bp, ba = self.Owner:GetBonePosition(bone)

    if bp then
        opos = bp
    end

    if ba then
        oang = ba
    end

    wm:SetModelScale(2)
    opos = opos + oang:Forward() * 20
    oang:RotateAroundAxis(oang:Up(), 260)
    oang:RotateAroundAxis(oang:Forward(), -90)
    wm:SetRenderOrigin(opos)
    wm:SetRenderAngles(oang)
    wm:DrawModel()
end

function SWEP:SecondaryAttack()
    self:PrimaryAttack(true)
end

function SWEP:DealDamage()
end

function SWEP:OnDrop()
end
