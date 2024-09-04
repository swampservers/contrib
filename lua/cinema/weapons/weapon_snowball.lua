-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("weapon_swamp_base")
SWEP.PrintName = "Snowballs"
SWEP.Instructions = "Left click to throw a snowball\nRight click to change flavor. Reload to compress your snowball so it hits harder."
SWEP.ViewModel = "models/weapons/v_snowball.mdl"
SWEP.WorldModel = "models/weapons/w_snowball.mdl"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 80
SWEP.ViewModelFlip = true
SWEP.AutoSwitchTo = false
SWEP.HoldType = "grenade"
SWEP.Category = "Snowball"
SWEP.Spawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.ThrowSound = Sound("Weapon_Crowbar.Single")
SWEP.ReloadSound = Sound("weapons/weapon_snowball/crunch.ogg")

function FreeSnowballs(ply)
    local locname = ply:GetLocationName()

    return locname == "Outside" or locname == "Golf"
end

--only activate during December
if os.date("%B", os.time()) == "December" and SERVER then
    --auto equip the snowball when outside
    hook.Add("PlayerChangeLocation", "ChristmasSnowballs", function(ply, loc, old)
        if FreeSnowballs(ply) then
            ply:Give("weapon_snowball")
        end
    end)
end

hook.Add("PlayerSpawn", "PlayerACSnowball", function(ply)
    ply:TimerCreate("ACSnowball", 4, 0, function()
        if (ply.FrozenBalls or 0) > 2 then
            util.ScreenShake(ply:GetPos(), 1, 0.07, 6, 32)
        end

        if ply:OnGround() then
            local trace = util.TraceLine(util.GetPlayerTrace(ply, Vector(0, 0, -1)))

            if trace.HitTexture == "PROPS/METALFAN001A" then
                ply.FrozenBalls = math.min((ply.FrozenBalls or 0) + 2, 8)

                if ply.FrozenBalls >= 5 then
                    ply:Give("weapon_snowball")
                end
            end
        end

        ply.FrozenBalls = math.max((ply.FrozenBalls or 0) - 1, 0)
    end)
end)

function SWEP:AmmoDisplayValue()
    return self:GetHardness() * 10 .. "%"
end

--network the player's new color
if SERVER then
    util.AddNetworkString("CLtoSVSnowballColor")

    net.Receive("CLtoSVSnowballColor", function(len, ply)
        local col = net.ReadTable()
        ply:SetNWVector("SnowballColor", Color(col.r, col.g, col.b):ToVector())

        if IsValid(ply:GetWeapon("weapon_snowball")) then
            ply:GetWeapon("weapon_snowball"):SetColor(col)
        end
    end)
end

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "Hardness")
end

function SWEP:Initialize()
    local owner = self:GetOwner()

    if not IsValid(owner) then
        self:Remove()

        return
    end

    self:SetHoldType(self.HoldType)
    self:SetClip1(1)
    local plycol = owner:GetNWVector("SnowballColor", Vector(1, 1, 1)):ToColor()
    self:SetColor(plycol)
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    local vm = owner:GetViewModel()

    if IsValid(vm) then
        vm:SetPlaybackRate(1)
    end

    owner:SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_THROW)
    self:SetNextPrimaryFire(CurTime() + 1)
    self:EmitSound(self.ThrowSound, 75, 100, 0.4, CHAN_WEAPON)
    if not IsFirstTimePredicted() then return end

    if SERVER then
        local ball = ents.Create("ent_snowball_nodamage")

        if IsValid(ball) then
            local front = owner:GetAimVector()
            ball:SetOwner(owner)
            ball:SetPos(owner:GetShootPos() + front * 10 + owner:EyeAngles():Up() * -5)
            ball:Spawn()
            ball:Activate()
            ball.Hardness = self:GetHardness() * 1
            self:SetHardness(0)
            local phys = ball:GetPhysicsObject()

            if IsValid(phys) then
                local rand = front:Angle()
                rand = rand:Forward()
                phys:ApplyForceCenter(rand * 1069)
            end
        end
    end

    if SERVER and not FreeSnowballs(owner) then
        timer.Simple(0.6, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end
end

--custom color select menu
function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end

    if CLIENT then
        if IsValid(f) then return end
        local f = vgui.Create("DFrame")
        f:SetSize(287, 211)
        f:Center()
        f:MakePopup()
        f:SetTitle("Snowball Flavor")
        f:SetIcon("icon16/color_wheel.png")
        local m = vgui.Create("DColorMixer", f)
        m:Dock(FILL)
        m:SetPalette(true)
        m:SetAlphaBar(false)
        m:SetWangs(true)
        m:SetColor(self:GetOwner():GetNWVector("SnowballColor", Vector(1, 1, 1)):ToColor())
        local b = vgui.Create("DButton", f)
        b:SetSize(100, 25)
        b:Dock(BOTTOM)
        b:SetText("Yum!")

        b.DoClick = function()
            f:Close()
            net.Start("CLtoSVSnowballColor")
            net.WriteTable(m:GetColor())
            net.SendToServer()
        end
    end
end

function SWEP:OnRemove()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()

    if IsValid(vm) then
        vm:SetPlaybackRate(1)
    end
end

function SWEP:Reload()
    if self:GetNextPrimaryFire() > CurTime() then return end
    local delay = 1 + self:GetHardness() / 5
    local vm = self:GetOwner():GetViewModel()

    self:TimerSimple(delay / 5, function()
        if not IsValid(self) then return end
        self:SetHardness(self:GetHardness() + 1)
        self:EmitSound(self.ReloadSound, 75, 100, 0.4, CHAN_WEAPON)
    end)

    self:SetNextPrimaryFire(CurTime() + delay)
    self:SendWeaponAnim(ACT_VM_DRAW)

    if IsValid(vm) then
        vm:SetPlaybackRate(1 / delay)
    end
end
