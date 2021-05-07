-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.UseHands = true
SWEP.PrintName = "Goo Jar"
SWEP.Author = "PYROTEKNIK"
SWEP.Instructions = "Left Click: Throw\nRight Click: Taunt\nLook Down to heal"
SWEP.Category = "PYROTEKNIK"
SWEP.Spawnable = true
SWEP.Slot = 5
SWEP.SlotPos = 5
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/chev/cumjar.mdl"
SWEP.WorldModel = "models/chev/cumjar.mdl"
SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = false
SWEP.DrawAmmo = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = 1
SWEP.Primary.ClipSize = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1


function SWEP:Initialize()
    self:SetHoldType("grenade")
    self:SetSubMaterial(1,"models/shiny")
    --  self:SetSubMaterial(2,"engine/occlusionproxy")
end


function SWEP:SecondaryAttack(undo)
    if (self:GetNextSecondaryFire() > CurTime() or !self:ShouldFap()) then return end

    local coom = math.random(1,4)
    while coom == self.LastTaunt do
        coom = math.random(1,4)
    end

    self:EmitSound("coomer/coom_taunt"..coom..".ogg")
 
    self.LastTaunt = coom
    self:SetNextPrimaryFire(CurTime() + 1)
    self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:PrimaryAttack()
    if (self:GetNextPrimaryFire() > CurTime()) then return end
    -- if self.Throwing then return end

    local ply = self:GetOwner()
    self:SendWeaponAnim(ACT_VM_THROW)
    self:EmitSound("WeaponFrag.Throw")
    -- self.Throwing = true
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("coomer/coom.ogg")
    if (SERVER) then
        local bait = ents.Create("thrown_goo_jar")
        bait:SetPos(ply:GetShootPos() + (ply:GetVelocity() * FrameTime()))
        bait:SetOwner(ply)
        bait:Spawn()
        bait:SetVelocity(ply:GetAimVector() * 800)
    end
    self:SetNextPrimaryFire(CurTime() + 1)
    self:SetNextSecondaryFire(CurTime() + 1)

    --added
   self:Remove()
end

function SWEP:ShouldFap()
    local ply = self:GetOwner()
    if(ply:GetGooStunned())then
        return false
    end

    if(ply:EyeAngles().pitch > 60)then
        return true
    end
    return false
end

function SWEP:Think()
    local ply = self:GetOwner()
    if(self.NextFap == nil or self.NextFap <= CurTime() and self:ShouldFap())then
        self.Owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_PHYSGUN, true)
        ply:ViewPunch(Angle(-5,0,0))
        ply:SetHealth(math.min(ply:Health()+1,ply:GetMaxHealth()))
        self.NextFap = CurTime() + 0.2
    end
    local fap = self:ShouldFap()
    if(fap)then
        if(!self.FapSound)then
            self.FapSound = CreateSound( self, "coomer/fap_loop.wav" )
            self.FapSound:Play()
        end
        timer.Create(self:EntIndex().."FapMod",0.2,0,function() 
            if(IsValid(self) and self.FapSound)then
                self.FapSound:ChangePitch(math.Rand(80,110),0.2)
                self.FapSound:ChangeVolume(math.Rand(0.8,1),0.2)
            end
        end)
    else
        if(self.FapSound)then
            self.FapSound:Stop()
            self.FapSound = nil
        end

end

		
end

function SWEP:Deploy()
    local ply = self:GetOwner()

    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)

end

function SWEP:Holster()
    if(self.FapSound )then self.FapSound:Stop() end
    return true
end

local whitemat = Material("models/shiny")
local nomat = Material("engine/occlusionproxy")

function SWEP:PreDrawViewModel(vm, weapon, ply)
    render.MaterialOverrideByIndex( 1, whitemat )
    -- render.MaterialOverrideByIndex( 2, nomat )

    
end

function SWEP:PostDrawViewModel(vm, weapon, ply)
    render.MaterialOverrideByIndex( 1)
    render.MaterialOverrideByIndex( 2)
    
end

function SWEP:DrawWorldModel(flags, check)
    local ply = self:GetOwner()
    local mrt = self:GetBoneMatrix(0)

    if IsValid(ply) then
        local bname = ply.IsPony ~= nil and ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
        local bone = ply:LookupBone(bname) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()

        if (bone ~= 0) then
            local bp, ba = self.Owner:GetBonePosition(bone)

            if (bp) then
                opos = bp
            end

            if (ba) then
                oang = ba
            end

            if bname == "LrigScull" then
                opos = opos + oang:Right() * -2
                opos = opos + oang:Forward() * 9
                opos = opos + oang:Up() * 1
                oang:RotateAroundAxis(oang:Forward(), 90)
                oang:RotateAroundAxis(oang:Right(), -135)
            else
                opos = opos + oang:Right() * 2
                opos = opos + oang:Forward() * 3
                opos = opos + oang:Up() * -1
                oang:RotateAroundAxis(oang:Forward(), 0)
                oang:RotateAroundAxis(oang:Right(), -135)
                oang:RotateAroundAxis(oang:Up(), 0)
            end

            self:SetupBones()
            local banscale = self.BananaNextRender and 1 - math.Clamp((self.BananaNextRender - CurTime()) * 4, 0, 1) or 1

            if mrt then
                mrt:SetTranslation(opos)
                mrt:SetAngles(oang)
                mrt:SetScale(Vector(.8, .8, .8) * banscale)
                self:SetBoneMatrix(0, mrt)
            end

            if (not check) then
                if (self.BananaNextRender == nil or (self.BananaNextRender ~= nil and banscale > 0)) then
                    self:DrawModel()
                end
            end
        else
            if (not check) then
                
                self:DrawModel()

                return
            end
        end

        if (check) then return mrt end

        return
    end

    if (not check) then
        self:DrawModel()
    end

    return mrt
end



function SWEP:GetViewModelPosition(pos,ang)
pos = pos + ang:Right()*4
pos = pos + ang:Forward()*16
pos = pos + ang:Up()*-4


return pos,ang
end