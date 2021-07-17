-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
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

if (SERVER) then
    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false

    --
    -- A concommand to quickly switch to the camera
    --
    concommand.Add("gmod_camera", function(player, command, arguments)
        player:SelectWeapon("gmod_camera")
    end)
end

--
-- Network/Data Tables
--
function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "Zoom")
    self:NetworkVar("Float", 1, "Roll")

    if (SERVER) then
        self:SetZoom(70)
        self:SetRoll(0)
    end
end

--
-- Initialize Stuff
--
function SWEP:Initialize()
    self:SetHoldType("camera")
end

--
-- Reload resets the FOV and Roll
--
function SWEP:Reload()
    if (not self.Owner:KeyDown(IN_ATTACK2)) then
        self:SetZoom(self.Owner:IsBot() and 75 or self.Owner:GetInfoNum("fov_desired", 75))
    end

    self:SetRoll(0)
end

--
-- PrimaryAttack - make a screenshot
--
function SWEP:PrimaryAttack()
    self:DoShootEffect()
    -- If we're multiplayer this can be done totally clientside
    if (not game.SinglePlayer() and SERVER) then return end
    if (CLIENT and not IsFirstTimePredicted()) then return end
    self.Owner:ConCommand("jpeg")
end

--
-- SecondaryAttack - Nothing. See Tick for zooming.
--
function SWEP:SecondaryAttack()
end

--
-- Mouse 2 action
--
function SWEP:Tick()
    if (CLIENT and self.Owner ~= LocalPlayer()) then return end -- If someone is spectating a player holding this weapon, bail
    local cmd = self.Owner:GetCurrentCommand()
    if (not cmd:KeyDown(IN_ATTACK2)) then return end -- Not holding Mouse 2, bail
    self:SetZoom(math.Clamp(self:GetZoom() + cmd:GetMouseY() * 0.1, 0.1, 175)) -- Handles zooming
    self:SetRoll(self:GetRoll() + cmd:GetMouseX() * 0.025) -- Handles rotation
end

--
-- Override players Field Of View
--
function SWEP:TranslateFOV(current_fov)
    return self:GetZoom()
end

--
-- Deploy - Allow lastinv
--
function SWEP:Deploy()
    return true
end

--
-- Set FOV to players desired FOV
--
function SWEP:Equip()
    if (self:GetZoom() == 70 and self.Owner:IsPlayer() and not self.Owner:IsBot()) then
        self:SetZoom(self.Owner:GetInfoNum("fov_desired", 75))
    end
end

function SWEP:ShouldDropOnDie()
    return false
end

--
-- The effect when a weapon is fired successfully
--
function SWEP:DoShootEffect()
    self:ExtEmitSound(self.ShootSound)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Owner:SetAnimation(PLAYER_ATTACK1)
end

if (SERVER) then return end -- Only clientside lua after this line
SWEP.WepSelectIcon = surface.GetTextureID("vgui/gmod_camera")

-- Don't draw the weapon info on the weapon selection thing
function SWEP:DrawHUD()
end

function SWEP:PrintWeaponInfo(x, y, alpha)
end

function SWEP:HUDShouldDraw(name)
    -- So we can change weapons
    if (name == "CHudWeaponSelection") then return true end
    if (name == "CHudChat") then return true end

    return false
end

function SWEP:FreezeMovement()
    -- Don't aim if we're holding the right mouse button
    if (self.Owner:KeyDown(IN_ATTACK2) or self.Owner:KeyReleased(IN_ATTACK2)) then return true end

    return false
end

function SWEP:CalcView(ply, origin, angles, fov)
    if (self:GetRoll() ~= 0) then
        angles.Roll = self:GetRoll()
    end

    return origin, angles, fov
end

function SWEP:AdjustMouseSensitivity()
    if (self.Owner:KeyDown(IN_ATTACK2)) then return 1 end

    return self:GetZoom() / 80
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if (IsValid(ply) and ply:IsPony()) then
        local bn = "LrigScull"
        local bon = ply:LookupBone(bn) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = ply:GetBonePosition(bon)

        if (bp) then
            opos = bp
        end

        if (ba) then
            oang = ba
        end

        if ply:IsPony() then
            oang:RotateAroundAxis(oang:Forward(), 90)
            --oang:RotateAroundAxis(oang:Up(),-90)
            opos = opos + (oang:Up() * 1) + (oang:Right() * -2) + (oang:Forward() * 10.5)
            oang:RotateAroundAxis(oang:Right(), 10)
        end

        self:SetupBones()
        self:SetModelScale(1, 0)
        local mrt = self:GetBoneMatrix(0)

        if (mrt) then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            --self:SetBoneMatrix(0, mrt )
            self:SetRenderOrigin(opos)
            self:SetRenderAngles(oang)
        end
    end

    self:DrawModel()
end

function CameraHUDVisible()
    return not (IsValid(LocalPlayer()) and LocalPlayer():UsingWeapon("gmod_camera"))
end

if CLIENT then
    hook.Add("Think", "RemoveVoiceIcons", function()
        local visible = CameraHUDVisible()

        if ValidPanel(g_VoicePanelList) then
            g_VoicePanelList:SetVisible(visible)
        end

        if SwampChat and ValidPanel(SwampChat.Panel) then
            SwampChat.Panel:SetVisible(visible)
        end
    end)
end
