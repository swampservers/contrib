SWEP.PrintName = "Police Taser"
SWEP.Author = "Chev"
SWEP.Instructions = "Left click: Attach taser tongs to a player.\nRight click: Taser attached player.\nReload: Remove attached tongs."

SWEP.Category = "Taser"

SWEP.Spawnable = true
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/cg_ocrp2/v_taser.mdl"
SWEP.WorldModel = "models/weapons/cg_ocrp2/w_taser.mdl"

SWEP.MaxTaseDist = 120
SWEP.MaxHoldDist = 250
SWEP.AutoUntase = 20

if CLIENT then
    local ragdollSnd = "physics/body/body_medium_impact_hard"

    hook.Add("PrePlayerDraw", "TaserSeizure", function(ply)
        if !IsValid(ply) or !IsValid(ply.IsTaseredBy) then return end

        local originvec, originang = ply:GetBonePosition(1)
        if ply:IsPony() then
            ply:ManipulateBonePosition(0, Vector(0,0,-13))
        else
            ply:ManipulateBonePosition(0, Vector(0, 0, -35))
        end
        ply:ManipulateBoneAngles(0, Angle(0, 0, -90))

        for i=1, ply:GetBoneCount(), 1 do
            if i > 22 then continue end
            ply:ManipulateBonePosition(i, VectorRand(-1, 1))
            ply:ManipulateBoneAngles(i, AngleRand(-10, 10))
        end

        if math.random(0, 100) < 1 then
            ply:ExtEmitSound(ragdollSnd..tostring(math.random(1, 6))..".wav")
        end
    end)

    hook.Add("UpdateAnimation", "PlayerTPoseRagdoll", function(ply)
        if !ply.IsTaseredBy then return end
        ply:SetSequence(0)
    end)
else -- server code 
    hook.Add("PlayerSwitchWeapon", "DisableWeaponSwitchingTaser", function(ply) -- ply:Freeze() doesn't account for weapon switching
        return ply:IsFrozen()
    end)

    hook.Add("DoPlayerDeath", "OnPlayerTaserDeath", function(ply, att, dmg)
        if IsValid(ply.IsTaseredBy) and IsValid(ply.IsTaseredBy:GetActiveWeapon()) and ply.IsTaseredBy:GetActiveWeapon():GetClass() == "weapon_taser" then -- victim dies
            ply.IsTaseredBy:GetActiveWeapon():RemoveWire()
        elseif IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_taser" then -- attacker dies
            ply:GetActiveWeapon():RemoveWire()
        end
    end)
end

function SWEP:Deploy()
    self:SetHoldType("revolver")
    self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:OnRemove() -- for !drop, etc.
    self:RemoveWire()
end

function SWEP:PrimaryAttack() -- attempt attach to a player
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim(ACT_VM_DRYFIRE)

    if !IsFirstTimePredicted() then return end

    local trc = self.Owner:GetEyeTrace()

    if IsValid(trc.Entity) and trc.Entity:IsPlayer() and self.Owner:GetPos():DistToSqr(trc.Entity:GetPos()) < self.MaxTaseDist*self.MaxTaseDist and !Safe(trc.Entity) and !trc.Entity:InVehicle() then
        self:UnTasePlayer()
        self.Owner:ExtEmitSound("ambient/energy/zap8.wav")

        self:AttachWire(trc.Entity)

        /*if SERVER then
            self.Owner:ChatPrint("Taser is now attached to " .. self.AttachedPlayer:Nick()) -- debug
        end*/
        self:SetNextPrimaryFire(CurTime() + 1)
    else
        self:SetNextPrimaryFire(CurTime() + 0.3)
    end
end

function SWEP:SecondaryAttack() -- tase a player, if one is attached
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim(ACT_VM_DRYFIRE)

    self:SetNextSecondaryFire(CurTime() + 0.5)

    if !IsFirstTimePredicted() or !IsValid(self.AttachedPlayer) then self:RemoveWire() return end

    local edat = EffectData()
    edat:SetOrigin(self.AttachedPlayer:GetPos())
    util.Effect("cball_explode", edat)

    self:TasePlayer(self.AttachedPlayer)
end

function SWEP:Reload() -- remove the attachment
    self:RemoveWire()
end

function SWEP:Think() -- remove the rope if the player goes too far
    if IsValid(self.AttachedPlayer) then
        if self.Owner:GetPos():DistToSqr(self.AttachedPlayer:GetPos()) > self.MaxHoldDist*self.MaxHoldDist or !self.AttachedPlayer:Alive() then
            self:RemoveWire()
        end
    end
end

function SWEP:TasePlayer()
    if !IsValid(self.AttachedPlayer) then return end
    ply = self.AttachedPlayer

    if IsValid(ply.IsTaseredBy) then -- if the player is already tasered
        self:UnTasePlayer()
        timer.Stop("ForceStopTasing"..self.Owner:SteamID64())
        return
    end

    ply.IsTaseredBy = self.Owner

    if SERVER then
        ply:Freeze(true)
        ply:SendLua("THIRDPERSON = true")
        --ply:DropToFloor()

        self.Rope:SetKeyValue("EndOffset", tostring(Vector(0, 0, 0)))

        ply:ExtEmitSound("weapon_taser/taser.ogg")
    end

    timer.Create("ForceStopTasing"..self.Owner:SteamID64(), self.AutoUntase, 0, function()
        if !IsValid(self) then return end
        self:UnTasePlayer()
    end)
end

function SWEP:UnTasePlayer()
    if !IsValid(self.AttachedPlayer) then return end
    ply = self.AttachedPlayer

    ply.IsTaseredBy = nil

    for i=0, ply:GetBoneCount(), 1 do
        ply:ManipulateBonePosition(i, vector_origin)
        ply:ManipulateBoneAngles(i, angle_zero)
    end

    if SERVER then
        ply:Freeze(false)
        ply:SendLua("THIRDPERSON = false")
        --ply:UnSpectate()

        self.Rope:SetKeyValue("EndOffset", tostring(Vector(0, 0, 48)))
    end
end

function SWEP:AttachWire(ent) -- attach the taser wire to an entity
    self.AttachedPlayer = ent

    if SERVER then
        if IsValid(self.Rope) then self.Rope:Remove() end

        self.Rope = constraint.CreateKeyframeRope(self:GetPos(), 1, "cable/cable.vmt", nil, self, Vector(0, 0, 0), 0, ent, Vector(0, 0, 48), 0)

        self.Rope:SetKeyValue("Collide", 1) --collide with world brushes
        self.Rope:SetKeyValue("Slack", 200) --add some rope slack
        self.Rope:SetKeyValue("Subdiv", 4) --smoother rope
    end
end

function SWEP:RemoveWire()
    if !IsFirstTimePredicted() or !IsValid(self.AttachedPlayer) then return end

    self:UnTasePlayer()

    self.AttachedPlayer = nil

    if SERVER then
        self.Rope:Remove()
        self:ExtEmitSound("ambient/energy/spark6.wav")
    end
end

function SWEP:Holster()
    return !IsValid(self.AttachedPlayer) -- if a player is attached, prevent holster
end
