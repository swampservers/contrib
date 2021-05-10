-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
SWEP.PrintName = "Abomination"
SWEP.Purpose = "COOM"
SWEP.Instructions = "Primary: Beat"
SWEP.Author = "PYROTEKNIK"
SWEP.Category = "PYROTEKNIK"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.DrawWeaponInfoBox = true
SWEP.ViewModelFOV = 85
SWEP.ViewModelFlip = false
SWEP.Slot = 0
SWEP.SlotPos = 3
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.ViewModel = "models/chev/cumjar.mdl"
SWEP.WorldModel = "models/chev/cumjar.mdl"
SWEP.Weight = 5
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
local SwingSound = Sound("WeaponFrag.Throw")
local HitSound = Sound("Flesh.ImpactHard")

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
end

function SWEP:Deploy()
    -- local ply = self:GetOwner()
    -- ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"),Vector(1,2,2))
    -- ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_UpperArm"),Vector(2,3,3))
    -- ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_Forearm"),Vector(2,2,2))
    -- ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Forearm"),Vector(10,0,0))
    -- ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Hand"),Vector(10,0,0))
end

function SWEP:Holster()
    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    for i = 0, 128 do
        -- ply:ManipulateBoneScale(i,Vector(1,1,1))
        -- ply:ManipulateBonePosition(i,Vector(0,0,0))
    end

    return true
end

hook.Add("EntityTakeDamage", "CumHulkDamage", function(target, dmginfo)
    -- if (target:IsPlayer() and IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():GetClass() == "weapon_goohulk" and dmginfo:GetAttacker() == target) then return true end --don't damage yourself with the coom fist
end)

function SWEP:MakeCumBlast(trace)
    local dir = trace.Normal
    local pos = trace.HitPos + trace.HitNormal * 48
    local decals = 0
    local dmg = DamageInfo()
    dmg:SetDamage(55)
    dmg:SetDamageType(DMG_ACID)
    dmg:SetDamageForce(self:GetVelocity() * 1000)
    dmg:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or game.GetWorld())
    dmg:SetInflictor(self)
    util.BlastDamageInfo(dmg, trace.HitPos, 200)

    while decals < 5 do
        local tr = {}
        tr.start = pos
        tr.endpos = pos + dir:GetNormalized() * 64

        tr.filter = {self, self.Owner}

        local trc = util.TraceLine(tr)

        if (trc.Hit) then
            util.Decal("PaintSplatBlue", tr.start, tr.endpos, {self, self.Owner})

            local vPoint = self:GetPos()
            local effectdata = EffectData()
            effectdata:SetOrigin(trc.HitPos + trc.HitNormal)
            effectdata:SetAngles(VectorRand():AngleEx(trace.HitNormal))
            effectdata:SetNormal(trc.HitNormal)
            effectdata:SetScale(10)
            util.Effect("watersplash", effectdata)
            decals = decals + 1
        else
            decals = decals + 0.1
        end

        dir = VectorRand()
    end

    if (trace.Hit) then
        self.Owner:EmitSound("coomer/splort.ogg")
    end
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self.Owner:EmitSound(SwingSound)
    self.Owner:EmitSound("coomer/coom.ogg", nil, math.Rand(60, 70))
    self:SetHoldType("melee")
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    local ply = self:GetOwner()

    local filt = {ply, self}

    local tr = {}
    tr.start = ply:GetShootPos()
    tr.endpos = tr.start + ply:GetAimVector() * 90
    tr.mins = Vector(1, 1, 1) * -8
    tr.maxs = Vector(1, 1, 1) * 8
    tr.mask = MASK_SHOT
    tr.filter = filt
    local trace = util.TraceHull(tr)
    -- local dir = trace.Normal
    self:MakeCumBlast(trace)
end

function SWEP:SecondaryAttack()
    if (self:GetNextSecondaryFire() > CurTime()) then return end
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
        bait:SetVelocity(ply:GetAimVector() * 4200)
    end

    -- self:SetNextPrimaryFire(CurTime() + 1)
    self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:DrawWorldModel()
    if not IsValid(self.Owner) then
        self:DrawModel()
    else
        local ply = self:GetOwner()
        -- ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"),Vector(1,2,2))
        -- ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_UpperArm"),Vector(2,3,3))
        -- ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_Forearm"),Vector(2,2,2))
        -- ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Forearm"),Vector(10,0,0))
        -- ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Hand"),Vector(10,0,0))
    end
end

if CLIENT then
    hook.Add("OnEntityCreated", "COOMERBONESFIX", function(ent)
        ent:AddCallback("BuildBonePositions", function(e, nb)
            if e:GetModel() == "models/player/soldier_stripped.mdl" then return BUILDCOOMERBONES(e, nb) end
        end)
    end)

    local mods2do = {
        [9] = Vector(1, 2, 2),
        [10] = Vector(1, 2, 2),
    }

    -- [11] = 2,
    function BUILDCOOMERBONES(e, nb)
        -- print(e:GetModelScale())
        local m = mods2do
        local s = {}
        if e:GetModelScale()>1 then
            m = {
                [9] = Vector(1, 3, 3),
                [10] = Vector(1, 3, 3),
            }
            s = {
                [1] = Vector(0, -4, 0),

                [2] = Vector(0, -6, 0),
                [3] = Vector(0, -2, 0),
                [6] = Vector(0, -4, 0),
                [8] = Vector(0, 4, 0),
                -- [9] = Vector(1, 3, 3),
                -- [10] = Vector(0,0,0),
            }

        end

        for k, v in pairs(m) do
            local mat = e:GetBoneMatrix(k)

            if mat then
                mat:Scale(v)
                e:SetBoneMatrix(k, mat)
            end
        end

        for k, v in pairs(s) do
            local mat = e:GetBoneMatrix(k)

            if mat then
                mat:Translate(v)
                e:SetBoneMatrix(k, mat)
            end
        end
    end
end