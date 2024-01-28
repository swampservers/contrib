-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SWEP.PrintName = "Pickaxe"
SWEP.DrawAmmo = false
SWEP.ViewModelFOV = 85
SWEP.Slot = 0
SWEP.SlotPos = 2
SWEP.Purpose = "Mine craft"
SWEP.Instructions = "Primary: Mine\nSecondary: Craft"
SWEP.ViewModel = Model("models/staticprop/props_mining/pickaxe01.mdl")
SWEP.WorldModel = Model("models/staticprop/props_mining/pickaxe01.mdl")
SWEP.Primary.Automatic = true
SWEP.SWINGINTERVAL = 0.4
SWEP.TARGETDISTANCE = 120
local DIAMONDMAT = Material("models/props_mining/pickaxe01_diamond")

function SWEP:Initialize()
    self:SetHoldType("melee2")
end

if CLIENT then
    MININGCRACKMATERIALS = {}

    for k = 1, 10 do
        table.insert(MININGCRACKMATERIALS, CreateMaterial("mining_crack_" .. tostring(k), "UnlitGeneric", {
            ["$basetexture"] = "swamponions/meinkraft/cracks",
            ["$alphatest"] = 1,
            -- ["$allowalphatocoverage"] = 1,
            ["$alphatestreference"] = 0.38 - (0.035 * k),
        }))
    end
end

function SWEP:GetTargetingBlock()
    local tr = util.TraceLine({
        start = self.Owner:EyePos(),
        endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * self.TARGETDISTANCE,
        filter = function(ent)
            if ent:GetClass() == "cvx_leaf" then return true end
        end,
        --ignoreworld=false,
        mask = MASK_ALL,
        collisiongroup = COLLISION_GROUP_PLAYER,
    })

    if tr.Hit then return tr end -- else -- 	return cvx_get_nearest_solid_vox(self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 80, true)
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.SWINGINTERVAL)
    self.Owner:SetAnimation(PLAYER_ATTACK1)

    if SERVER then
        if not self.Owner:InTheater() then
            sound.Play("weapons/iceaxe/iceaxe_swing1.wav", self.Owner:GetPos(), 60, 100, 0.4)
        end
    end

    if CLIENT and IsFirstTimePredicted() then
        self.swingtime = SysTime()
    end

    -- timer.Simple(self.SWINGINTERVAL/4,function()
    -- if SERVER then
    if not IsValid(self) or not IsFirstTimePredicted() then return end
    local bullet = {}
    bullet.Num = 1
    bullet.Attacker = self.Owner
    bullet.Src = self.Owner:EyePos() --self.Owner:GetShootPos()
    bullet.Dir = self.Owner:EyeAngles():Forward() --self.Owner:GetAimVector()
    bullet.Distance = self.TARGETDISTANCE
    bullet.Tracer = 0
    bullet.Force = 1
    bullet.Damage = self:IsDiamond() and math.random(2, 10) or math.random(1, 5)

    bullet.Callback = function(att, tr, dmginfo)
        local ent = tr.Entity

        if IsValid(ent) and ent.IsOre then
            ent:DoHit(att, tr, dmginfo)
        end
    end

    self.Owner:FireBullets(bullet)
    -- end
    -- end)
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 10)

    if CLIENT then
        RunConsoleCommand("say", "minecraft XD")
    end
end

function SWEP:IsDiamond()
    return false
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if IsValid(ply) then
        local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
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

        opos = opos + oang:Right() * 1
        opos = opos + oang:Forward() * 3
        opos = opos + oang:Up() * 8

        if ply:IsPony() then
            opos = opos + oang:Forward() * 4
            opos = opos + oang:Up() * 8
            opos = opos + oang:Right() * -3.5
        end

        oang:RotateAroundAxis(oang:Right(), 180)
        self:SetupBones()
        self:SetModelScale(0.8, 0)
        local mrt = self:GetBoneMatrix(0)

        if mrt then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            self:SetBoneMatrix(0, mrt)
        end
    end

    if self:IsDiamond() then
        render.MaterialOverride(DIAMONDMAT)
    end

    self:DrawModel()
    render.MaterialOverride()
end

function SWEP:PreDrawViewModel()
    if self:IsDiamond() then
        render.MaterialOverride(DIAMONDMAT)
    end
end

function SWEP:PostDrawViewModel()
    render.MaterialOverride()
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 22
    pos = pos + ang:Up() * -30
    pos = pos + ang:Forward() * 25
    local dt = SysTime() - (self.swingtime or 0)
    dt = dt / self.SWINGINTERVAL
    dt = math.Clamp(dt, 0, 1)
    dt = math.pow(dt, 0.8)

    if dt < 0.5 then
        dt = math.Remap(dt, 0, 0.5, 0, 1)
        dt = math.ease.OutBack(dt)
    elseif dt < 1 then
        dt = math.Remap(dt, 0.5, 1, 0, 1)
        dt = 1 - math.ease.InOutQuad(dt)
    else
        dt = 0
    end

    local sw = 70 * dt
    ang:RotateAroundAxis(ang:Up(), 180 + 15)
    ang:RotateAroundAxis(ang:Right(), sw)

    return pos, ang
end

function SWEP:DrawHUD()
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 2, Color(0, 0, 0, 100))
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 1, Color(255, 255, 255, 100))
    local ptlrp = CurTime() - pickaxepointtime

    if ptlrp < 0.9 then
        draw.DrawText("+" .. tostring(pickaxepointamount), "TargetID", (ScrW() * 0.5) + (pickaxepointdirx * ptlrp * 100), (ScrH() * 0.5) - (50 + (ptlrp * 100)), Color(255, 200, 50, 255 * (0.9 - ptlrp)), TEXT_ALIGN_CENTER)
    end
end

if CLIENT then
    pickaxepointtime = 0
    pickaxepointamount = 0
    pickaxepointdirx = 0

    net.Receive("PickaxePoints", function()
        pickaxepointtime = CurTime()
        pickaxepointamount = net.ReadInt(16)
        pickaxepointdirx = math.Rand(-0.4, 0.4)
    end)
end
