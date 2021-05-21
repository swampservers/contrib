-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local cvar = GetConVar("r_decals"):GetInt()
RunConsoleCommand("r_decals", tostring(math.max(cvar, 4096)))
cvar = GetConVar("mp_decals"):GetInt()
RunConsoleCommand("mp_decals", tostring(math.max(cvar, 4096)))
--RunConsoleCommand("r_maxmodeldecal","32")
SWEP.PrintName = "Spraypaint"
SWEP.Author = "PYROTEKNIK &"
SWEP.Category = "PYROTEKNIK"
SWEP.Instructions = "Left Click to Draw, Hold Right mouse to reduce mouse sensitivity, Press R to change color and paint size"
SWEP.Purpose = "Point it in someone's eye :)"
SWEP.Slot = 1
SWEP.SlotPos = 100
SWEP.Spawnable = true
SWEP.ViewModel = Model("models/pyroteknik/v_spraypaint.mdl")
SWEP.WorldModel = Model("models/pyroteknik/w_spraypaint.mdl")
SWEP.CapModel = Model("models/pyroteknik/w_spraypaint_cap.mdl")
SWEP.ShakeSound = Sound("spraypaint/spray_shake.wav")
SWEP.PopCapSound = Sound("spraypaint/spray_capoff.wav")
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
SWEP.DrawCrosshair = false
SWEP.BounceWeaponIcon = false
SWEP.RenderGroup = RENDERGROUP_OPAQUE

function SWEP:SetupDataTables()
    self:NetworkVar("Vector", 0, "CustomColor")
    self:NetworkVar("Float", 0, "PaintAlpha")
    self:NetworkVar("Float", 1, "PaintSize")
end

function SWEP:Initialize()
    self.CapOn = true
    self:SetHoldType("passive")

    if (SERVER) then
        if (not IsValid(self:GetOwner())) then
            local randcol = HSVToColor(math.Rand(0, 360), 1, 1)
            local c = Vector(randcol.r / 255, randcol.g / 255, randcol.b / 255)
            self:SetCustomColor(Vector(c.x, c.y, c.z))
        end
    end
end

function SWEP:PrimaryAttack()
    local trace = self:GetTrace()

    if (not trace.Invalid) then
        self:MakePaint(trace, (1 / 60))
    end

    self:SetNextPrimaryFire(CurTime() + (1 / 60))
end

function SWEP:SecondaryAttack()
    if (CLIENT) then
        self.SensToggle = not self.SensToggle
    end

    self:SetNextSecondaryFire(CurTime() + 0.01)

    return true
end

function SWEP:Deploy()
    if (SERVER) then
        self:SendWeaponAnim(ACT_VM_DRAW)
    end

    if (SERVER) then
        self:UpdateCustomColor()
    end

    self:PlayEquipAnimation()

    return true
end

function SWEP:OnDrop()
end

function SWEP:Holster()
    self:CancelAllAnimations()

    return true
end

function SWEP:Reload()
    return true
end

function SWEP:OnRemove()
    return true
end

function SWEP:Think()
end

function SWEP:Equip(ply)
    if (SERVER) then
        net.Start("SpraypaintRequestCustomColor")
        net.Send(ply)
        self:UpdateCustomColor()
    end
end

function SWEP:GetTrace()
    local ply = self:GetOwner()
    local org = ply:EyePos() + ply:GetVelocity() * FrameTime()
    local tr = {}
    tr.start = org
    tr.endpos = org + ply:GetAimVector() * (self:GetPaintDistance() + 5)
    tr.mask = MASK_VISIBLE
    tr.filter = ply
    local trace = util.TraceLine(tr)

    if (trace.HitTexture == "**displacement**" or trace.HitTexture == "**studio**") then
        trace.Invalid = true
    end

    return trace
end

hook.Add("KeyPress", "SpraypaintColorPicker", function(ply, key)
    local wep = ply:GetActiveWeapon()

    if (key == IN_RELOAD and IsValid(wep) and wep:GetClass() == "weapon_spraypaint") then
        if (CLIENT) then
            wep:SpraypaintOpenPanel()
        end
    end
end)

function SWEP:MakePaint(trace, delay)
    local cc = self:GetCustomColor()
    local alpha = math.Clamp(self:GetPaintAlpha(), 0.25, 1)
    local size = self:GetPaintSize()
    local alphamul = 1
    local color = Color(cc.x * 255, cc.y * 255, cc.z * 255, alpha * 255 * alphamul)

    if (CLIENT) then
        self:DoParticle(trace.StartPos, trace.HitPos, color, size)

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

        return
    end

    if (trace.HitSky) then return end
    if (not trace.Hit) then return end
    if (not self:MovementAppropriate()) then return end
    local pos = trace.HitPos * 1
    local normal = trace.HitNormal * 1
    local cc = self:GetCustomColor()
    local alpha = math.Clamp(self:GetPaintAlpha(), 0.25, 1)
    local size = self:GetPaintSize()
    local fcolor = Color(cc.x * 255, cc.y * 255, cc.z * 255, alpha * 255 * alphamul)
    local pos2
    local surfdist = self:GetOwner():EyePos():Distance(trace.HitPos)

    if (SERVER) then
        if (SPRAYPAINT_MAKEDOT) then
            SPRAYPAINT_MAKEDOT(trace, size, fcolor)
        end
    end
end

function SWEP:EquipAmmo(ply)
end

function SWEP:GetPaintDistance()
    return 128 + (self:GetPaintSize() * 4)
end