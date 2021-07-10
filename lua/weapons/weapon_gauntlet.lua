-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Infinity Gauntlet"
SWEP.Instructions = "*snap*"
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.m_WeaponDeploySpeed = 9
SWEP.ViewModel = "models/swamp/v_infinitygauntlet.mdl"
SWEP.WorldModel = "models/swamp/v_infinitygauntlet.mdl"
SWEP.ViewModelFlip = false
--SWEP.ViewModelFOV           = 60
SWEP.Spawnable = true
SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "infinitygauntlet"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Instructions = "Hold left mouse button to snap. wait time is based on target's health."

SWEP.TargetCone = 15

--NOMINIFY
if (CLIENT) then
    language.Add("infinitygauntlet_ammo", "Comedy Stones")
end

hook.Add("Initialize", "InfinityGauntletAmmo", function()
    game.AddAmmoType({
        name = "infinitygauntlet",
        dmgtype = DMG_DISSOLVE,
    })
end)

function SWEP:SetupDataTables()
    self:NetworkVar("Entity", 0, "LockTarget")
    self:NetworkVar("Int", 0, "Charge")
end

function SWEP:Initialize()
end

function SWEP:GetMaxCharge()
    local lock = self:GetLockTarget()
    if (not IsValid(lock)) then return 1 end

    return 5 + (lock:Health() / 40)
end

function SWEP:DoDrawCrosshair(x, y)
    if (not self:CanPrimaryAttack()) then return true end
    local ply = self:GetOwner()
    local target = self:GetTarget()
    local dir = ply:GetAimVector():Angle()
    dir:RotateAroundAxis(dir:Up(), self.TargetCone)
    local maxrad = 0
    local data2D = (EyePos() + (dir:Forward() * 100)):ToScreen() -- Gets the position of the entity on your screen

    if (data2D.visible) then
        maxrad = Vector(x, y, 0):Distance(Vector(data2D.x, data2D.y, 0))
    end

    local chg = self:GetCharge() * 1.1
    local rd = (chg / self:GetMaxCharge())
    self.RadiusLerp = Lerp(0.1, self.RadiusLerp or rd, rd)
    rd = self.RadiusLerp
    
    for i=1,10 do
    surface.DrawCircle( x, y, maxrad*(1-rd) + i , Color(128, 0, 255,255*rd) )
    end
    --surface.DrawCircle( x, y, maxrad , Color(128, 128, 128,64) )

    return true
end

local meta = FindMetaTable("Player")

function meta:Fizzle(attacker, inflictor, damage)
    if SERVER then
        if (self:InVehicle()) then
            self:ExitVehicle()
        end

        local dmginfo = DamageInfo()
        dmginfo:SetDamage(damage or self:Health()*100)
        dmginfo:SetDamageType(DMG_DISSOLVE)
        dmginfo:SetAttacker(attacker or game.GetWorld())
        dmginfo:SetDamageForce(Vector(0, 0, 1))
        dmginfo:SetInflictor(inflictor or game.GetWorld())
        self:TakeDamageInfo(dmginfo)
    end
end

function SWEP:Equip(ply)
end

function SWEP:EquipAmmo(ply)
end

function SWEP:Snap()
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)

    if (SERVER) then
        self:GetOwner():EmitSound("gauntlet/snap.wav", 100)
        util.ScreenShake(self:GetOwner():GetPos(), 1, 2, 0.2, 300)
    end

    local target = self:GetTarget()

    if (IsValid(target)) then
        target:Fizzle(self:GetOwner(), self)
        self:GetOwner():RemoveAmmo(1, "infinitygauntlet")

        self:TimerSimple(0.5, function()
            if (SERVER and self:Ammo1() <= 0) then
                if IsValid(self) then
                    self:Remove()
                end
            end
        end)
    end
end

function SWEP:CanTarget(v)
    if (not v:IsPlayer()) then return false end
    if (Safe(v)) then return false end
    if (not v:Alive()) then return false end
    if (v == self:GetOwner()) then return false end
    if (not self:GetTargetNearness(v)) then return false end
    local ply = self:GetOwner()
    
    local hookt = hook.Run( "PlayerShouldTakeDamage", v,ply )
    if(hookt == false)then
        return false 
    end

    

    return true
end

function SWEP:GetTargetNearness(v)
    local ply = self:GetOwner()
    local mins,maxs = v:GetCollisionBounds()
    local otherpos = v:LocalToWorld(v:OBBCenter())
    local ofs = v:InVehicle() and  Vector(0,0,-maxs.z/2)or  Vector()
    otherpos = otherpos + ofs

    local a = ply:GetAimVector()
    local b = (otherpos - ply:GetShootPos()):GetNormalized()
    local dis = otherpos:Distance(ply:GetShootPos()) / 20
    local cn = math.deg(math.acos(a:Dot(b)))
    if (cn > self.TargetCone) then return end
    if (dis * 20 > 1000) then return end --2000

    return cn + dis
end

function SWEP:GetTarget()
    local lock = self:GetLockTarget()
    

    if(!IsValid(lock) and CLIENT and self:GetOwner() == LocalPlayer())then return self:FindTarget() end

    if (IsValid(lock)) then return self:CanTarget(lock) and self:GetLockTarget() end
end

function SWEP:FindTarget()
    local eyetrace = self.Owner:GetEyeTrace()
    local target = {nil, 10000}

    local ply = self:GetOwner()
    local allply = player.GetAll()
    local tracepos = ply:GetEyeTrace().HitPos

    for k, v in pairs(allply) do
        local mins,maxs = v:GetCollisionBounds()
        local otherpos = v:LocalToWorld(v:OBBCenter())
        local ofs = v:InVehicle() and  Vector(0,0,-maxs.z/2)or  Vector()
        otherpos = otherpos + ofs


        if (not self:CanTarget(v)) then continue end
        local near = self:GetTargetNearness(v) 
        if (near and near < target[2]) then
            local tr = util.TraceLine({
                start = ply:GetShootPos(),
                endpos = otherpos,
                filter = {ply, v}
            })

            local tr2 = util.TraceLine({
                start = ply:GetShootPos(),
                endpos = v:EyePos() + ofs,
                filter = {ply, v}
            })
            
            local wmins,wmaxs = mins + v:GetPos() + ofs,maxs + v:GetPos() + ofs

            if(tr.Hit and tr.HitPos:WithinAABox(wmins,wmaxs))then
                tr.Hit = false
            end
            if(tr2.Hit and tr2.HitPos:WithinAABox(wmins,wmaxs))then
                tr2.Hit = false
            end
            if (not tr.Hit or not tr2.Hit) then
                debugoverlay.Box(Vector(),wmins,wmaxs,0.1,Color(255,0,0,32))
                target = {v, near}
            end
        end
    end

    if (target[1]) then return target[1] end
end

hook.Add("PreDrawHalos", "InfinityGauntletHalo", function()
    if (LocalPlayer():UsingWeapon("weapon_gauntlet")) then
        local wep = LocalPlayer():GetWeapon("weapon_gauntlet")
        if (wep:GetNextPrimaryFire() - 0.4 > CurTime()) then return end
        local ply = wep:GetTarget()

        if (IsValid(ply)) then
            local tb = {ply}

            if (ply.GetActiveWeapon and IsValid(ply:GetActiveWeapon())) then
                tb[2] = ply:GetActiveWeapon()
            end

            local rd = wep:GetCharge() / wep:GetMaxCharge()
            halo.Add(tb, Color(128, 0, 255), 2, 2, 2, true, true)

            if (rd > 0) then
                local rad = (rd * 8)
                halo.Add(tb, Color(128, 0, 255, 255 * rd), rad, rad, 10, true, true)
            end
        end
    end
end)

function SWEP:CanPrimaryAttack()
    return self:GetOwner():GetAmmoCount("infinitygauntlet") > 0
end

function SWEP:PrimaryAttack()
    local target = self:FindTarget()
    if (not self:CanPrimaryAttack()) then return end

    if (SERVER) then
        SuppressHostEvents(self:GetOwner())
    end

    

    if (self:GetCharge() == 0) then


        if (IsValid(target)) then
            self:SetLockTarget(target)
            util.ScreenShake(self:GetOwner():GetPos(), 0.5, 1, 0.2, 300)
        else
            self:EmitSound("buttons/combine_button_locked.wav")
            self:SetNextPrimaryFire(CurTime() + 0.5)
            return
        end

        
    end
    local lock = self:GetLockTarget()
    if(!self:CanTarget(lock))then
        self:SetLockTarget(nil)
        self:SetCharge(0)
        self:SetNextPrimaryFire(CurTime() + 0.05)
        return
    end


    self:SetCharge(self:GetCharge() + 1)

    if (self:GetCharge() >= self:GetMaxCharge()) then
        self:Snap()
        self:SetCharge(0)
        self:SetNextPrimaryFire(CurTime() + 0.05)
       
        self:SetLockTarget(nil)
    else
        self:SetNextPrimaryFire(CurTime() + 0.05)

        self:TimerCreate("SnapExpire", 0.2, 1, function()
            if (SERVER) then
                SuppressHostEvents(self:GetOwner())
            end

            self:SetLockTarget(nil)
            
            self:SetCharge(0)

            if (SERVER) then
                SuppressHostEvents()
            end

            self:SetNextPrimaryFire(CurTime() + 0.5)
        end)
       
    end

    if (SERVER) then
        SuppressHostEvents()
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:OnRemove()
end

function SWEP:Reload()
end

function SWEP:Deploy()
    self:SetHoldType("fist")
end

function SWEP:CreateWorldModel()
    if not IsValid(self.WModel) then
        self.WModel = ClientsideModel(self.WorldModel, RENDERGROUP_OPAQUE)
        self.WModel:SetNoDraw(true)
        self.WModel:SetBodygroup(1, 1)
    end

    return self.WModel
end

if (CLIENT) then
    gauntletglow = CreateMaterial("gauntletglow", "UnlitGeneric", {
        ["$basetexture"] = "sprites/light_glow02",
        ["$model"] = 1,
        ["$additive"] = 1,
        ["$translucent"] = 1,
        ["$color2"] = Vector(4, 4, 4),
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1
    })
end

function SWEP:DrawWorldModel()
    if (not IsValid(self:GetOwner())) then return end
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

    local spos = opos + oang:Forward() * 4
    render.SetMaterial(gauntletglow)
    local rd = math.Clamp(self:GetCharge() / self:GetMaxCharge(), 0, 1)
    local size = 32 + (rd * 32)

    if (rd > 0) then
            render.DrawQuadEasy(spos, -EyeAngles():Forward(), size, size, Color(136, 17, 255), math.Rand(0, 360))
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