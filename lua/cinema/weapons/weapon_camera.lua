-- This file is subject to copyright - contact swampservers@gmail.com for more information.
AddCSLuaFile()
SWEP.ViewModel = Model("models/weapons/c_arms_animations.mdl")
SWEP.WorldModel = Model("models/MaxOfS2D/camera.mdl")
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.PrintName = "#GMOD_Camera"
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Spawnable = true
SWEP.ShootSound = Sound("NPC_CScanner.TakePhoto")

if SERVER then
    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false

    concommand.Add("gmod_camera", function(player, command, arguments)
        player:SelectWeapon("weapon_camera")
    end)
end

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "Zoom")
    self:NetworkVar("Float", 1, "Roll")
    self:NetworkVar("Bool", 0, "Selfie")

    if SERVER then
        self:SetZoom(70)
        self:SetRoll(0)
        self:SetSelfie(false)
    end
end

function SWEP:Initialize()
    self:SetHoldType("camera")
end

function SWEP:Reload()
    if not self.Owner:KeyDown(IN_ATTACK2) then
        self:SetZoom(self.Owner:IsBot() and 75 or self.Owner:GetInfoNum("fov_desired", 75))
    end

    self:SetRoll(0)

    if SERVER and self.Owner:KeyPressed(IN_RELOAD) then
        self:SetSelfie(not self:GetSelfie())
        self:SetHoldType(self:GetSelfie() and "pistol" or "camera")
    end
end

function SWEP:PrimaryAttack()
    self:DoShootEffect()
    -- If we're multiplayer this can be done totally clientside
    if not game.SinglePlayer() and SERVER then return end
    if CLIENT and not IsFirstTimePredicted() then return end
    self.Owner:ConCommand("jpeg")
end

function SWEP:SecondaryAttack()
end

function SWEP:Tick()
    if CLIENT and self.Owner ~= Me then return end -- If someone is spectating a player holding this weapon, bail
    local cmd = self.Owner:GetCurrentCommand()
    if not cmd:KeyDown(IN_ATTACK2) then return end -- Not holding Mouse 2, bail
    self:SetZoom(math.Clamp(self:GetZoom() + cmd:GetMouseY() * 0.1, 0.1, 175)) -- Handles zooming
    self:SetRoll(self:GetRoll() + cmd:GetMouseX() * 0.025) -- Handles rotation
end

function SWEP:TranslateFOV(current_fov)
    return self:GetZoom()
end

function SWEP:Deploy()
    return true
end

function SWEP:Equip()
    if self:GetZoom() == 70 and self.Owner:IsPlayer() and not self.Owner:IsBot() then
        self:SetZoom(self.Owner:GetInfoNum("fov_desired", 75))
    end
end

function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:DoShootEffect()
    self:ExtEmitSound(self.ShootSound)

    if not self:GetSelfie() then
        self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        self.Owner:SetAnimation(PLAYER_ATTACK1)
    end
end

if SERVER then return end -- Only clientside lua after this line
SWEP.WepSelectIcon = surface.GetTextureID("vgui/gmod_camera")

function SWEP:DrawHUD()
end

function SWEP:PrintWeaponInfo(x, y, alpha)
end

function SWEP:HUDShouldDraw(name)
    if name == "CHudWeaponSelection" then return true end
    if name == "CHudChat" then return true end

    return false
end

function SWEP:FreezeMovement()
    -- Don't aim if we're holding the right mouse button
    if self.Owner:KeyDown(IN_ATTACK2) or self.Owner:KeyReleased(IN_ATTACK2) then return true end

    return false
end

function SWEP:AdjustMouseSensitivity()
    if self.Owner:KeyDown(IN_ATTACK2) then return 1 end

    return self:GetZoom() / 80
end

function SWEP:GetSelfieCam()
    local ply = self:GetOwner()
    local bn = ply:LookupBone("ValveBiped.Bip01_R_Hand")

    if bn then
        local mat = ply:GetBoneMatrix(bn)

        if mat then
            local pos, ang = mat:GetTranslation(), mat:GetAngles()

            return pos, ang
        end
    else
        bn = ply:LookupBone("LrigScull")

        if bn then
            local mat = ply:GetBoneMatrix(bn)

            if mat then
                local pos, ang = mat:GetTranslation(), mat:GetAngles()

                return LocalToWorld(Vector(3, 2, -2), Angle(0, 0, -90), pos, ang)
            end
        end
    end

    return self:GetPos(), self:GetAngles()
end

--NOMINIFY
local stickpos, stickang = Vector(10, -3, -4), Angle(30, -15, -90)
local phonepos, phoneang = Vector(21, -7, -12.5), Angle(190, 0, 90)
local camang = Angle(190, 0, 0)

function SWEP:CalcView(ply, origin, angles, fov)
    if self:GetRoll() ~= 0 then
        angles.Roll = self:GetRoll()
    end

    if self:GetSelfie() then
        self.Owner:SetupBones()
        local p, a = self:GetSelfieCam()
        local p2, a2 = LocalToWorld(phonepos + Vector(-1, 0, -1), camang, p, a)
        a2:RotateAroundAxis(a2:Forward(), self:GetRoll())

        return p2, a2, fov
    end

    return origin, angles, fov
end

hook.Add("ShouldDrawLocalPlayer", "SelfieDrawLocalPlayer", function(ply)
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep.GetSelfie and wep:GetSelfie() then return true end
end)

-- models/props_combine/combinecamera001.mdl
-- models/mechanics/robotics/c4.mdl
function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if IsValid(ply) then
        if self:GetSelfie() then
            if not IsValid(SELFIE_PHONE) then
                SELFIE_PHONE = ClientsideModel("models/jokergaming/iphone12.mdl")
                SELFIE_PHONE:SetNoDraw(true)
            end

            if not IsValid(SELFIE_STICK) then
                SELFIE_STICK = ClientsideModel("models/mechanics/robotics/c4.mdl")
                SELFIE_STICK:SetNoDraw(true)
                -- SELFIE_STICK:SetRenderMode(RENDERMODE_TRANSCOLOR)
                -- SELFIE_STICK:SetColor(Color(100,100,100))
            end

            SELFIE_STICK:SetModelScale(0.1)
            local p, a = self:GetSelfieCam()
            local p2, a2 = LocalToWorld(stickpos, stickang, p, a)
            SELFIE_STICK:SetPos(p2)
            SELFIE_STICK:SetAngles(a2)
            SELFIE_STICK:SetupBones()
            SELFIE_STICK:DrawModel()
            local p2, a2 = LocalToWorld(phonepos, phoneang, p, a)
            SELFIE_PHONE:SetPos(p2)
            SELFIE_PHONE:SetAngles(a2)
            SELFIE_PHONE:SetupBones()
            SELFIE_PHONE:DrawModel()

            ply:SetEyeTarget(p2)

            return
        else
            bn = ply:LookupBone("LrigScull")

            if bn then
                local mat = ply:GetBoneMatrix(bn)

                if mat then
                    local pos, ang = mat:GetTranslation(), mat:GetAngles()
                    ang:RotateAroundAxis(ang:Forward(), 90)
                    pos = pos + ang:Up() * 1 + ang:Right() * -2 + ang:Forward() * 10.5
                    ang:RotateAroundAxis(ang:Right(), 10)
                    self:SetRenderOrigin(pos)
                    self:SetRenderAngles(ang)
                end
            end
        end
    end

    self:DrawModel()
end

if CLIENT then
    hook.Add("Think", "RemoveVoiceIcons", function()
        local visible = not (IsValid(Me) and Me:UsingWeapon("weapon_camera"))

        if IsValid(g_VoicePanelList) then
            g_VoicePanelList:SetVisible(visible)
        end

        if SwampChat and IsValid(SwampChat.Panel) then
            SwampChat.Panel:SetVisible(visible or SwampChat.IsOpen)
        end
    end)
end
