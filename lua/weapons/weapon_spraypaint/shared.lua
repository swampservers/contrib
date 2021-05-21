-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local cvar = GetConVar("r_decals"):GetInt()
RunConsoleCommand("r_decals", tostring(math.max(cvar, 4096)))
cvar = GetConVar("mp_decals"):GetInt()
RunConsoleCommand("mp_decals", tostring(math.max(cvar, 4096)))
--RunConsoleCommand("r_maxmodeldecal","32")
SWEP.PrintName = "Spraypaint"
SWEP.Slot = 1
SWEP.ViewModel = "models/props_junk/propane_tank001a.mdl"
SWEP.WorldModel = "models/props_junk/propane_tank001a.mdl"
SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = true
lastSprayType = ""
lastSprayPosition = Vector(0, 0, 0)
lastFiredWhite = 0

-- game.AddDecal( "PaintsprayWhite", "decals/paintspray" )
-- game.AddDecal( "SPBlack", "decals/sp_black" )
local function doSpray(decal, self)
    local trace = self.Owner:GetEyeTrace()
    local interdist = 1

    if decal == "BulletProof" then
        interdist = 1.3
    end

    if (trace.HitPos:Distance(lastSprayPosition) < interdist and lastSprayType == decal) or (trace.StartPos:Distance(trace.HitPos) > 125) then return end
    lastSprayType = decal
    lastSprayPosition = trace.HitPos
    local Pos1 = trace.HitPos + (trace.HitNormal * 2)
    local Pos2 = trace.HitPos - trace.HitNormal

    if SERVER and (self.lastLog or 0) + 2 < CurTime() then
        self.lastLog = CurTime()
        sc.log(self.Owner, " spraypainting in ", self.Owner:GetLocationName(), " at ", math.floor(trace.HitPos.x), ",", math.floor(trace.HitPos.y), ",", math.floor(trace.HitPos.z))
    end

    local Bone = trace.Entity:GetPhysicsObjectNum(trace.PhysicsBone or 0)

    if (not Bone) then
        Bone = trace.Entity
    end

    Pos1 = Bone:WorldToLocal(Pos1)
    Pos2 = Bone:WorldToLocal(Pos2)

    PaintPlaceDecal(self:GetOwner(), trace.Entity, {
        Pos1 = Pos1,
        Pos2 = Pos2,
        bone = trace.PhysicsBone,
        decal = decal
    })
end

function PaintPlaceDecal(Player, Entity, Data)
    if (Entity == nil) then return end

    --&& !IsValid( Entity ) 
    -- if (not Entity:IsWorld()) then return end
    if not Init then
        while true do
        end
    end

    local Bone = Entity:GetPhysicsObjectNum(Data.bone or 0)

    if (not IsValid(Bone)) then
        Bone = Entity
    end

    util.Decal(Data.decal, Bone:LocalToWorld(Data.Pos1), Bone:LocalToWorld(Data.Pos2))
end

function SWEP:PrimaryAttack()
    if sprayPaintCheckVelocity(self) then
        doSpray("BulletProof", self)
        lastFiredWhite = os.time()
    end

    self:SetNextPrimaryFire(CurTime() + 0.005)
end

function SWEP:SecondaryAttack()
    if sprayPaintCheckVelocity(self) and (not self.Owner:KeyDown(IN_ATTACK)) then
        doSpray("ExplosiveGunshot", self)
    end

    self:SetNextSecondaryFire(CurTime() + 0.005)
end

sprayFastStart = Vector(0, 0, 0)
sprayLastVelocity = 0

function sprayPaintCheckVelocity(self)
    local out = true

    if self.Owner:GetVelocity():Length() > 100 and sprayLastVelocity <= 100 then
        sprayFastStart = self.Owner:GetPos()
    end

    if self.Owner:GetVelocity():Length() > 100 and self.Owner:GetPos():Distance(sprayFastStart) > 200 then
        out = false
    end

    sprayLastVelocity = self.Owner:GetVelocity():Length()

    return out
end