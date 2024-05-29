SWEP.PrintName = "Police Taser"
SWEP.Author = "Chev"
SWEP.Instructions = "Left click: Attach taser tongs to a player.\nRight click: Taser attached player.\nReload: Remove attached tongs."
SWEP.Category = "Taser"
SWEP.Spawnable = true
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.ViewModel = "models/weapons/cg_ocrp2/v_taser.mdl"
SWEP.WorldModel = "models/weapons/cg_ocrp2/w_taser.mdl"
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = "none"
SWEP.MaxTaseDist = 120
SWEP.MaxHoldDist = 250
SWEP.AutoUntase = 20

if CLIENT then
    local ragdollSnd = "physics/body/body_medium_impact_hard"

    hook.Add("PrePlayerDraw", "TaserSeizure", function(ply)
        if not IsValid(ply) or not IsValid(ply:GetNWEntity("IsTaseredBy", nil)) then return end
        local originvec, originang = ply:GetBonePosition(1)

        if ply:IsPony() then
            ply:ManipulateBonePosition(0, Vector(0, 0, -13))
        else
            ply:ManipulateBonePosition(0, Vector(0, 0, -35))
        end

        ply:ManipulateBoneAngles(0, Angle(0, 0, -90))

        for i = 1, ply:GetBoneCount() do
            if i > 22 then continue end
            ply:ManipulateBonePosition(i, VectorRand(-1, 1))
            ply:ManipulateBoneAngles(i, AngleRand(-10, 10))
        end

        if math.random(0, 100) < 1 then
            ply:ExtEmitSound(ragdollSnd .. tostring(math.random(1, 6)) .. ".wav")
        end
    end)

    hook.Add("UpdateAnimation", "PlayerTPoseRagdoll", function(ply)
        if not IsValid(ply:GetNWEntity("IsTaseredBy", nil)) then return end
        ply:SetSequence(0)
    end)
else -- server code
    hook.Add("PlayerSwitchWeapon", "DisableWeaponSwitchingTaser", function(ply)
        -- ply:Freeze() doesn't account for weapon switching
        if ply:IsFrozen() then return true end
    end)

    hook.Add("DoPlayerDeath", "OnPlayerTaserDeath", function(ply, att, dmg)
        -- victim dies
        local taseredby = ply:GetNWEntity("IsTaseredBy", nil)

        if IsValid(taseredby) and IsValid(taseredby:GetActiveWeapon()) and taseredby:GetActiveWeapon():GetClass() == "weapon_taser" then
            taseredby:GetActiveWeapon():RemoveWire()
        elseif IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_taser" then
            -- attacker dies
            ply:GetActiveWeapon():RemoveWire()
        end
    end)
end

-- attempt attach to a player
function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    owner:SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_DRYFIRE)
    if not IsFirstTimePredicted() then return end
    local trc = owner:GetEyeTrace()
    local trcent = trc.Entity

    if IsValid(trcent) and trcent:IsPlayer() and owner:GetPos():DistToSqr(trcent:GetPos()) < self.MaxTaseDist * self.MaxTaseDist and not trcent:IsProtected(owner) and not trcent:InVehicle() and trcent:GetMoveType() ~= MOVETYPE_NOCLIP then
        if trcent:SteamID() == "STEAM_0:0:38422842" then return end
        self:UnTasePlayer()
        owner:ExtEmitSound("ambient/energy/zap8.wav")
        self:AttachWire(trcent)
        --[[if SERVER then
            owner:ChatPrint("Taser is now attached to " .. self.AttachedPlayer:Nick()) -- debug
        end]]
        self:SetNextPrimaryFire(CurTime() + 1)
    else
        self:SetNextPrimaryFire(CurTime() + 0.3)
    end
end

--NOMINIFY
-- tase a player, if one is attached
function SWEP:SecondaryAttack()
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_DRYFIRE)
    self:SetNextSecondaryFire(CurTime() + 0.5)

    if not IsFirstTimePredicted() or not IsValid(self.AttachedPlayer) then
        self:RemoveWire()

        return
    end

    local edat = EffectData()
    edat:SetOrigin(self.AttachedPlayer:GetPos())
    util.Effect("cball_explode", edat)
    self:TasePlayer(self.AttachedPlayer)
end

-- remove the attachment
function SWEP:Reload()
    self:RemoveWire()
end

-- remove the rope if the player goes too far
function SWEP:Think()
    local owner = self:GetOwner()

    if IsValid(self.AttachedPlayer) and (owner:GetPos():DistToSqr(self.AttachedPlayer:GetPos()) > self.MaxHoldDist * self.MaxHoldDist or not self.AttachedPlayer:Alive()) then
        self:RemoveWire()
    end

    if owner:InVehicle() then
        self:RemoveWire()
    end
end

function SWEP:TasePlayer()
    if not IsValid(self.AttachedPlayer) then return end
    local owner = self:GetOwner()
    local ply = self.AttachedPlayer

    -- if the player is already tasered
    if IsValid(ply:GetNWEntity("IsTaseredBy", nil)) then
        self:UnTasePlayer()
        timer.Stop("ForceStopTasing" .. owner:SteamID64())

        return
    end

    ply:SetNWEntity("IsTaseredBy", owner)
    ply:ManipulateBoneAngles(0, Angle(0, 0, -90), false) -- Need the server to be in sync roughly with the client, so that traces aren't mismatched

    if SERVER then
        ply:Freeze(true)
        ply:SendLua("THIRDPERSON = true")
        --ply:DropToFloor()
        self.Rope:SetKeyValue("EndOffset", tostring(Vector(0, 0, 0)))
        ply:ExtEmitSound("weapon_taser/taser.ogg")
    end

    timer.Create("ForceStopTasing" .. owner:SteamID64(), self.AutoUntase, 0, function()
        if not IsValid(self) then return end
        self:UnTasePlayer()
    end)
end

function SWEP:UnTasePlayer()
    if not IsValid(self.AttachedPlayer) then return end
    local ply = self.AttachedPlayer
    ply:SetNWEntity("IsTaseredBy", NULL)

    for i = 0, ply:GetBoneCount() do
        ply:ManipulateBonePosition(i, vector_origin, false)
        ply:ManipulateBoneAngles(i, angle_zero, false)
    end

    if SERVER then
        ply:Freeze(false)
        ply:SendLua("THIRDPERSON = false")
        -- HACK(winter): If we don't do this, UnTasePlayer only ever gets called on the client for the SWEP's owner
        BroadcastLua([[
            local wep = Entity(]] .. self:EntIndex() .. [[)
            if IsValid(wep) and wep.UnTasePlayer then
                wep.AttachedPlayer = Entity(]] .. ply:EntIndex() .. [[)
                wep:UnTasePlayer()
                wep.AttachedPlayer = nil
            end
        ]])
        --ply:UnSpectate()
        self.Rope:SetKeyValue("EndOffset", tostring(Vector(0, 0, 48)))
    end
end

-- attach the taser wire to an entity
function SWEP:AttachWire(ent)
    self.AttachedPlayer = ent

    if SERVER then
        if IsValid(self.Rope) then
            self.Rope:Remove()
        end

        self.Rope = constraint.CreateKeyframeRope(self:GetPos(), 1, "cable/cable.vmt", nil, self, Vector(0, 0, 0), 0, ent, Vector(0, 0, 48), 0)
        self.Rope:SetKeyValue("Collide", 1) --collide with world brushes
        self.Rope:SetKeyValue("Slack", 200) --add some rope slack
        self.Rope:SetKeyValue("Subdiv", 4) --smoother rope
    end
end

function SWEP:RemoveWire(force)
    if (not force and not IsFirstTimePredicted()) or not IsValid(self.AttachedPlayer) then return end
    self:UnTasePlayer()
    self.AttachedPlayer = nil

    if SERVER then
        self.Rope:Remove()
        self:ExtEmitSound("ambient/energy/spark6.wav")
    end
end

function SWEP:Deploy()
    self:SetHoldType("revolver")
    self:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:Holster()
    -- if a player is attached, prevent holster
    return not IsValid(self.AttachedPlayer)
end

-- for !drop, etc.
function SWEP:OnDrop()
    self:RemoveWire(true)

    if SERVER then
        BroadcastLua([[
            local wep = Entity(]] .. self:EntIndex() .. [[)
            if IsValid(wep) and wep.OnDrop then
                wep:OnDrop()
            end
        ]])
    end
end

function SWEP:OnRemove()
    self:RemoveWire(true)
end
