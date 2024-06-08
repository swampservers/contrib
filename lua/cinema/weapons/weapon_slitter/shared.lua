-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--Throatneck Slitter by Swamp
SWEP.PrintName = "Throatneck Slitter"
SWEP.Instructions = "Primary: Attack\nSecondary: Taunt"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.ViewModelFOV = 90
SWEP.ViewModel = "models/weapons/w_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
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
lastslit = 0
lastkillslit = 0
justslitplayer = nil
slitrspeed = .4

-- models/props_wasteland/prison_throwswitchlever001.mdl
-- models/props_junk/meathook001a.mdl
SlitterModels = {
    ["models/weapons/w_knife_t.mdl"] = {
        name = "Throatneck Slitter",
        pos = Vector(3, -1, 3),
        ang = Angle(0, 0, 180),
        scale = Vector(1, 1, 1),
    },
    ["models/props_junk/harpoon002a.mdl"] = {
        name = "Throatneck Skewer",
        pos = Vector(4, -1, 0),
        ang = Angle(90, 0, 0),
        scale = Vector(0.7, 1, 1) * 0.5,
    },
    ["models/props_c17/tools_wrench01a.mdl"] = {
        name = "Throatneck Spanner",
        pos = Vector(4, -1, -1),
        ang = Angle(0, 180, -90),
        scale = Vector(1, 1, 1) * 0.9,
    },
    ["models/Gibs/wood_gib01d.mdl"] = {
        name = "Throatneck Sticker",
        pos = Vector(3, -1, -5),
        ang = Angle(-90, -90, 0),
        scale = Vector(1, 1, 1) * 0.6,
    },
    ["models/props_junk/glassbottle01a_chunk01a.mdl"] = {
        name = "Throatneck Scratcher",
        pos = Vector(4, -1, -3),
        ang = Angle(0, 0, 0),
        scale = Vector(1, 1, 1) * 1.5,
    },
    ["models/props_lab/cleaver.mdl"] = {
        name = "Throatneck Cleaver",
        pos = Vector(3.5, -1, 0),
        ang = Angle(-90, 0, 0),
        scale = Vector(1, 1, 1) * 0.6,
    }
}

--NOMINIFY
function SWEP:SetupDataTables()
    self:NetworkVar("String", 0, "ForceModel")

    if CLIENT and self:GetForceModel() ~= "" then
        self:ApplySkin(self:GetForceModel())
    end
end

-- -- determines the knife model; this is used so it works with viewmdoel fixer script
-- function SWEP:GetViewModel()
--     return self.ViewModel
-- --     return self:GetForceModel() == "" and "models/weapons/w_knife_t.mdl" or self:GetForceModel()
-- end
function SWEP:ApplySkin(model)
    self:SetForceModel(model)
    self.WorldModel = model
    self.ViewModel = model
    self.PrintName = SlitterModels[model].name
end

-- do i really wanna do this? or find a way to encode everything in a data table string so its sync?
function SWEP:SetItem(item)
    self.item = item

    if SERVER then
        self:ApplySkin(item.model)
    else
        item:SetEntityMaterial(self)
    end
end

function SWEP:Deploy()
    -- print("deploy",self, self.Owner)
    if SERVER and not self.AppliedSkin then
        self.AppliedSkin = true

        if IsValid(self) and IsValid(self.Owner) then
            for k, v in pairs((self.Owner.items or {}).knifeskin or {}) do
                if v.eq then
                    self:SetItem(v)
                    -- self:SetModel(self.WorldModel)
                end
            end
        end
    end
    -- if IsValid(self.Owner) and IsValid(self.Owner:GetViewModel()) then
    --     self.Owner:GetViewModel():SetModel(self:GetViewModel())
    -- end
    -- self:SetModel(self:GetViewModel())
    -- self.PrintName = SlitterModels[self:GetViewModel()].name
end

function SWEP:Initialize()
    self:SetHoldType("knife")
    -- print("init",self, self.Owner, self:GetForceModel())
end

local function sinlerp(lrp)
    --*math.pi
    return 0.5 - 0.5 * math.cos(lrp * 2.9)
end

function SWEP:ModelOffset(pos, ang)
    local basemodelstuff = SlitterModels["models/weapons/w_knife_t.mdl"]
    local modelstuff = SlitterModels[self.WorldModel]
    local mp, ma = WorldToLocal(modelstuff.pos, modelstuff.ang, basemodelstuff.pos, basemodelstuff.ang)

    return LocalToWorld(mp, ma, pos, ang)
end

function SWEP:GetViewModelPosition(pos, ang)
    local slitlerp = 1 - math.min(1, (CurTime() - lastslit) / slitrspeed)
    local pos2 = LerpVector(sinlerp(slitlerp), Vector(10, 14, -16), Vector(4, 20, -7))
    local ang2 = LerpVector(sinlerp(slitlerp), Vector(-20, 0, 0), Vector(-65, 0, 2))
    local r = ang:Right()
    local f = ang:Forward()
    local u = ang:Up()
    pos = pos + r * pos2.x
    pos = pos + f * pos2.y
    pos = pos + u * pos2.z
    ang:RotateAroundAxis(r, ang2.x)
    ang:RotateAroundAxis(f, ang2.y)
    ang:RotateAroundAxis(u, ang2.z)

    return self:ModelOffset(pos, ang)
end

function SWEP:PreDrawViewModel(vm)
    local item = self:GetItem()

    if item then
        item:SetEntityMaterial(vm)
    end

    local m = Matrix()
    m:SetScale(SlitterModels[self.WorldModel].scale) --self:GetViewModel()].scale)
    vm:EnableMatrix("RenderMultiply", m)
end

function SWEP:PostDrawViewModel(vm)
    vm:DisableMatrix("RenderMultiply")
    vm:SetMaterial("")
    vm:SetSubMaterial()
end

function SWEP:DrawWorldModel()
    self:GetItem()
    local ply = self:GetOwner()

    if IsValid(ply) then
        local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
        local bon = ply:LookupBone(bn) or 0
        local pos = self:GetPos()
        local ang = self:GetAngles()
        local bp, ba = ply:GetBonePosition(bon)

        if bp then
            pos, ang = bp, ba
        end

        if ply:IsPony() then
            ang:RotateAroundAxis(ang:Forward(), 180)
            ang:RotateAroundAxis(ang:Up(), -90)
            pos = pos + ang:Up() * -0.5 + ang:Right() * -8.3 + ang:Forward() * -0.2
        else
            pos = pos -- + ang:Right()*12.5
        end

        local modelstuff = SlitterModels[self.WorldModel]
        local mat = Matrix()
        mat:SetTranslation(modelstuff.pos)
        mat:SetAngles(modelstuff.ang)
        mat:SetScale(modelstuff.scale)
        self:EnableMatrix("RenderMultiply", mat)
        self.matrix = Matrix()
        self.matrix:SetScale(modelstuff.scale)

        --hacky solution for this model
        if self.WorldModel == "models/props_lab/cleaver.mdl" then
            local basemodelstuff = SlitterModels["models/weapons/w_knife_t.mdl"]
            local mp, ma = WorldToLocal(Vector(12, 0, 8), Angle(-180, 90, 0), basemodelstuff.pos, basemodelstuff.ang)
            pos, ang = LocalToWorld(mp, ma, pos, ang)
        end

        self:InvalidateBoneCache()
        self:SetupBones()
        self:SetBonePosition(0, pos, ang)
    end

    self:DrawModel()
end

function SWEP:TraceSphere(vp, vr, sp, radius, maxdist)
    vp = vp - sp
    vr:Normalize()
    local b = 2.0 * vp:Dot(vr)
    local c = vp:Dot(vp) - radius * radius
    local thing = b * b - 4 * c
    if thing <= 0 then return end
    thing = math.sqrt(thing)
    --t2 is behind us
    if thing - b < 0 then return end
    local t = (-b - thing) / 2.0
    --too far
    if t > maxdist then return end
    local hitpos = vp + vr * t
    self.TraceHitNormal = hitpos:GetNormalized()

    if t < 0 then
        --we're inside it
        t = 0
        hitpos = vp
    end

    self.TraceHitPos = sp + hitpos

    return true
end

function SWEP:TraceCapsule(vp, vr, cp, ca, cmin, cmax, radius, maxdist)
    local p2mp1 = vp - cp
    vr:Normalize()
    ca:Normalize()
    local thing = p2mp1 - vr * p2mp1:Dot(vr)
    thing = thing:Dot(ca)
    thing = thing / (1.0 - math.pow(vr:Dot(ca), 2))
    thing = math.Clamp(thing, cmin, cmax)

    return self:TraceSphere(vp, vr, cp + thing * ca, radius, maxdist)
end

function SWEP:TargetedPlayer()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vp = owner:EyePos()
    local vr = owner:EyeAngles():Forward()
    local ca = Vector(0, 0, 1)

    -- TODO(winter): There better be a good reason we're iterating over ALL PLAYERS and doing traces for every single one of them!!
    -- TODO(winter): What's more expensive, this or util.TraceHull within strike range, then narrowing down via a filter until we hit something with both util.TraceHull and TraceCapsule?
    for _, ply in player.Iterator() do
        if ply == owner then continue end
        if ply:InVehicle() then continue end
        if not ply:Alive() then continue end
        if ply:IsProtected(owner) then continue end

        --radius was 12
        if self:TraceCapsule(vp, vr, ply:GetPos(), ca, 12, ply:Crouching() and 38 or 58, 12.5, 100) then
            local tr = util.TraceLine({
                start = vp,
                endpos = self.TraceHitPos,
                filter = Ents.player
            })

            if tr.Hit then continue end

            return ply
        end
    end

    local trace = owner:GetEyeTrace()

    if IsValid(trace.Entity) then
        local traceEntClass = trace.Entity:GetClass()

        if traceEntClass == "ent_mysterybox" or traceEntClass == "enemy_skeleton" and trace.HitPos:Distance(vp) < 100 then
            self.TraceHitPos = trace.HitPos
            self.TraceHitNormal = trace.HitNormal

            return trace.Entity
        end
    end
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.35 * (HumanTeamName and 3 or 1))
    if not IsFirstTimePredicted() then return end
    slitrspeed = math.Rand(.35, .45)
    lastslit = CurTime()
    local shouldHearChink = true

    if CLIENT then
        local hitplayer = self:TargetedPlayer()

        if hitplayer then
            -- TODO(winter): What the fuck? Why are we using net messages for this??? SWEPs are predicted
            net.Start("SlitThroatneck")
            net.WriteEntity(hitplayer)
            net.WriteVector(Me:EyeAngles():Forward())
            net.WriteVector(self.TraceHitPos)
            net.WriteVector(self.TraceHitNormal)
            net.SendToServer()
            self:EmitSound("Weapon_Knife.Hit", 80, 100, 1, CHAN_WEAPON)
            shouldHearChink = false

            if hitplayer:IsPlayer() then
                local effectdata = EffectData()
                effectdata:SetOrigin(self.TraceHitPos)
                effectdata:SetNormal(self.TraceHitNormal)
                effectdata:SetMagnitude(1)
                effectdata:SetScale(15)
                effectdata:SetColor(BLOOD_COLOR_RED)
                effectdata:SetFlags(3)
                util.Effect("bloodspray", effectdata, true, true)
            end

            lastkillslit = CurTime()
            justslitplayer = hitplayer
        end
    end

    if shouldHearChink then
        self:ExtEmitSound("Weapon_Knife.HitWall", {
            pitch = 100,
            shared = true
        })
    end

    self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:SecondaryAttack()
    if HumanTeamName then
        if CLIENT and IsFirstTimePredicted() then
            OpenCSBuyMenu()
        end

        return
    end

    if SERVER then
        local s = table.Random({
            {"throatneck.ogg",},
            {"throatneck2.ogg", 2.1}
        })

        local p = math.random(50, 160)

        self:ExtEmitSound(s[1], {
            pitch = p,
            speech = s[2],
            channel = CHAN_VOICE
        })
    end

    self:SetNextSecondaryFire(CurTime() + 1)
end
-- function SWEP:DoImpactEffect(tr, nDamageType)
--     util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
--     return true
-- end
