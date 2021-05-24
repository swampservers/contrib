﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local cvar = GetConVar("r_decals"):GetInt()
RunConsoleCommand("r_decals", tostring(math.max(cvar, 4096)))
cvar = GetConVar("mp_decals"):GetInt()
RunConsoleCommand("mp_decals", tostring(math.max(cvar, 4096)))
--RunConsoleCommand("r_maxmodeldecal","32")
SWEP.PrintName = "Spraypaint"
SWEP.Author = "PYROTEKNIK"
SWEP.Category = "PYROTEKNIK"
SWEP.Instructions = "Left Click to Draw, Right click to change paint style"
SWEP.Purpose = "Draw funny pictures :)"
SWEP.Slot = 1
SWEP.SlotPos = 100
SWEP.Spawnable = true
SWEP.ViewModel = Model("models/pyroteknik/v_spraypaint.mdl")
SWEP.WorldModel = Model("models/pyroteknik/w_spraypaint.mdl")
SWEP.CapModel = Model("models/pyroteknik/w_spraypaint_cap.mdl")
SWEP.ShakeSound = Sound("spraypaint/spray_shake.wav")
SWEP.ViewModelFOV = 70
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.BounceWeaponIcon = false
SWEP.RenderGroup = RENDERGROUP_OPAQUE
SWEP.PaintDelay = 1 / 30
SWEP.MaxMovementDistance = 128 -- Maxmimum distance the player can move while drawing before it's prevented
SPRAYPAINT_DECALS_WHITELIST = {}
SPRAYPAINT_DECALS = {}

for i = 1, 27 do
    local dname = "spraypaint_decal" .. i
    local matname = "spray/" .. dname
    SPRAYPAINT_DECALS[i] = dname
    SPRAYPAINT_DECALS_WHITELIST[dname] = true
    game.AddDecal(dname, matname)
    --Material(matname)
    list.Set("SprayPaintDecals", i, dname)
end

SWEP.DecalSet = "SprayPaintDecals"
SWEP.MenuColumns = 9
SWEP.ConVar = "spraypaint_decal"
SWEP.WindowTitle = "Spraypaint Color"

function SWEP:SetupDataTables()
    self:NetworkVar("String", 0, "LastDecal")
end

function SWEP:Initialize()
    self:SetHoldType("pistol")
end

if (SERVER) then
    util.AddNetworkString("SpraypaintNetworked")
end

if (CLIENT) then
    net.Receive("SpraypaintNetworked", function(len)
        local ent = net.ReadEntity()

        if (ent:IsValid()) then
            ent:PrimaryAttack()
        end
    end)
end

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()

    if (SERVER) then
        local filt = RecipientFilter()
        filt:AddPVS(ply:GetPos())
        filt:RemovePlayer(ply)
        net.Start("SpraypaintNetworked", true)
        net.WriteEntity(self)
        net.Send(filt)
    end

    local color, size = self:GetDecalColor()
    local trace = self:GetTrace()
    local originref = ply:GetPos()
    self.SprayStartOrigin = self.SprayStartOrigin or originref
    local origin = self.SprayStartOrigin
    local gap = size / 5

    if (self.LastPaintPos and trace.HitPos:Distance(self.LastPaintPos) < gap) then
        trace.Invalid = true
    end

    if (origin:Distance(originref) > self.MaxMovementDistance or self.SprayMovementBad) then
        self.SprayMovementBad = true
        trace.Invalid = true
    end

    if (not trace.Invalid) then
        self:MakePaint(trace, (self.PaintDelay))
        self.LastPaintPos = trace.HitPos
    end

    timer.Create("paintorigin_reset" .. self:EntIndex(), self.PaintDelay + FrameTime(), 1, function()
        if (IsValid(self)) then
            self.SprayMovementBad = nil
            self.SprayStartOrigin = nil
            self.LastPaintPos = nil
        end
    end)

    self:SetNextPrimaryFire(CurTime() + (self.PaintDelay))
end

function SWEP:SecondaryAttack()
    if (CLIENT and IsFirstTimePredicted()) then
        self:SpraypaintOpenPanel()
    end

    self:SetNextSecondaryFire(CurTime() + 0.125)

    return true
end

function SWEP:Deploy()
    if (SERVER) then
        self:SendWeaponAnim(ACT_VM_DRAW)
    end

    return true
end

function SWEP:OnDrop()
end

function SWEP:Holster()
    return true
end

function SWEP:Reload()
end

function SWEP:OnRemove()
    return true
end

function SWEP:Think()
end

function SWEP:Equip(ply)
end

function SWEP:GetCurrentDecal()
    local ply = self:GetOwner()
    local decal = ply:GetInfo(self.ConVar)

    --I don't think GetInfo is properly networked
    if (CLIENT and ply ~= LocalPlayer()) then
        decal = self:GetLastDecal()
    end

    if (SPRAYPAINT_DECALS_WHITELIST[decal]) then return decal end

    return "spraypaint_decal1"
end

function SWEP:GetTrace()
    local ply = self:GetOwner()
    local org = ply:EyePos() + ply:GetVelocity() * FrameTime()
    local tr = {}
    tr.start = org
    tr.endpos = org + ply:GetAimVector() * (self:GetPaintDistance() + 5)
    --tr.mask = MASK_VISIBLE
    tr.filter = ply
    local trace = util.TraceLine(tr)
    if (trace.HitTexture == "**displacement**" or trace.HitTexture == "**studio**") then end --trace.Invalid = true

    if (trace.HitPos:Distance(org) > 128) then
        trace.Invalid = true
    end

    return trace
end

SPRAYPAINT_DECALPREVIEW_CACHE = {}
SPRAYPAINT_DECALCOLOR_CACHE = {}
SPRAYPAINT_DECALSIZE_CACHE = {}

--i think this will function serverside as long as the materials are installed there
function SWEP:GetDecalColor(decal)
    local ply = self:GetOwner()
    if (not IsValid(ply)) then return Vector(1, 1, 1), 1 end
    decal = decal or self:GetCurrentDecal()
    if (SPRAYPAINT_DECALCOLOR_CACHE[decal] and SPRAYPAINT_DECALSIZE_CACHE[decal]) then return SPRAYPAINT_DECALCOLOR_CACHE[decal], SPRAYPAINT_DECALSIZE_CACHE[decal] end
    local mat = Material(util.DecalMaterial(decal))
    local maintex

    if (mat:GetTexture("$basetexture")) then
        maintex = mat:GetTexture("$basetexture")
    end

    --shit seems to crash if you try to access width
    if (mat) then
        local texwidth = mat:Width()
        local size = texwidth * tonumber(mat:GetFloat("$decalscale") or 1)
        size = size or 1
        SPRAYPAINT_DECALCOLOR_CACHE[decal] = mat:GetVector("$color2")
        SPRAYPAINT_DECALSIZE_CACHE[decal] = size

        return mat:GetVector("$color2") or Vector(1, 1, 1), size
    end

    return Vector(1, 1, 1), 16
end

hook.Add("KeyPress", "SpraypaintColorPicker", function(ply, key) end)

function SWEP:MakePaint(trace, delay)
    local ply = self:GetOwner()
    local color, size = self:GetDecalColor()

    if (CLIENT) then
        self:DoParticle(trace.HitPos, color)
        self:DoSound(delay)

        return
    end

    if (trace.HitSky) then return end
    if (not trace.Hit) then return end
    local pos = trace.HitPos * 1
    local normal = trace.HitNormal * 1
    local surfdist = self:GetOwner():EyePos():Distance(trace.HitPos)
    local decalname = self:GetCurrentDecal()

    if (SERVER) then
        self:SetLastDecal(decalname)

        util.Decal(decalname, trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal, {ply})
    end
end

function SWEP:DoSound(delay)
    if (not self.SpraySound) then
        sound.PlayFile("sound/spraypaint/spraypaint.wav", "3d mono noblock", function(sound)
            if (IsValid(sound)) then
                self.SpraySound = sound
                sound:SetPos(self:GetPos())
            end
        end)
    end

    if (self.SpraySound) then
        self.SpraySound:SetPos(self:GetPos())

        if (self.SpraySound:GetState() ~= GMOD_CHANNEL_PLAYING) then
            self.SpraySound:Play()
        end

        if (self.SpraySound:GetTime() >= 0.6) then
            self.SpraySound:SetTime(0.055 + math.Rand(0, 0.4))
        end

        local globpitch = 1
        local globvol = 1
        self.SprayRand = self.SprayRand or 1
        self.SprayRand = math.Clamp(self.SprayRand + math.Rand(-1, 1) * FrameTime() * 0.1, 0.9, 1.1)
        self.SpraySound:SetPlaybackRate(globpitch * self.SprayRand)
        self.SpraySound:SetVolume(globvol)

        timer.Create(self:EntIndex() .. "spraysoundend", delay * 1.04, 1, function()
            if (IsValid(self.SpraySound)) then
                self.SpraySound:SetTime(0.665)
            end
        end)
    end
end

function SWEP:EquipAmmo(ply)
end

function SWEP:GetPaintDistance()
    return 128
end