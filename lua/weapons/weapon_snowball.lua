-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
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
local ti = os.date("%B", os.time())

--only activate during December
if ti == "December" then
    --auto equip the snowball when outside
    hook.Add("PlayerChangeLocation", "ChristmasSnowballs", function(ply, loc, old)
        if not IsValid(ply) then return end
        local locname = ply:GetLocationName()

        if locname == "Outside" or locname == "Golf" and not ply:HasWeapon("weapon_snowball") then
            ply:Give("weapon_snowball")
        end
    end)
end
hook.Add("PlayerSpawn","PlayerACSnowball",function(ply)
    ply:TimerCreate("ACSnowball",4,0,function()
        if((ply.FrozenBalls or 0) > 2 )then util.ScreenShake(ply:GetPos(), 1, 0.07, 6, 32 ) end
        if(ply:OnGround())then
            local trace = util.TraceLine(util.GetPlayerTrace( ply, Vector(0,0,-1) ))
            if(trace.HitTexture == "PROPS/METALFAN001A")then
                ply.FrozenBalls = math.min((ply.FrozenBalls or 0) + 2,8)
                if(ply.FrozenBalls >= 5)then
                    ply:Give("weapon_snowball")
                end
            end
        end
        ply.FrozenBalls = math.max((ply.FrozenBalls or 0) - 1,0)
    end)
end)


function SWEP:AmmoDisplayValue() 
    return (self:GetHardness() * 10) .."%"
end

--network the player's new color
if SERVER then
    util.AddNetworkString("CLtoSVSnowballColor")

    net.Receive("CLtoSVSnowballColor", function(len, ply)
        local col = net.ReadTable()
        ply:SetNWVector("SnowballColor", Color(col.r, col.g, col.b):ToVector())
        if(IsValid(ply:GetWeapon("weapon_snowball")))then
            ply:GetWeapon("weapon_snowball"):SetColor(col)
        end    
    end)
end

function SWEP:SetupDataTables()
    self:NetworkVar("Int",0,"Hardness")
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self.Weapon:SetClip1(1)
    local plycol = self:GetOwner():GetNWVector("SnowballColor", Vector(1, 1, 1)):ToColor()
    self:SetColor(plycol)
end

function SWEP:PrimaryAttack()
    local vm = self:GetOwner():GetViewModel()
    vm:SetPlaybackRate(1)
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim(ACT_VM_THROW)
    self.Weapon:SetNextPrimaryFire(CurTime() + 1)
    self.Weapon:EmitSound(self.ThrowSound, 75, 100, 0.4, CHAN_WEAPON)
    if not IsFirstTimePredicted() then return end

    if SERVER then
        local ball = ents.Create("ent_snowball_nodamage")

        if IsValid(ball) then
            local front = self.Owner:GetAimVector()
            ball:SetOwner(self.Owner)
            ball:SetPos(self.Owner:GetShootPos() + front * 10 + self.Owner:EyeAngles():Up() * -5)
            ball:Spawn()
            ball:Activate()
            ball.Hardness = self:GetHardness()*1
            self:SetHardness(0)
            local phys = ball:GetPhysicsObject()

            if IsValid(phys) then
                local rand = front:Angle()
                rand = rand:Forward()
                phys:ApplyForceCenter(rand * 1069)
            end
        end
    end

    timer.Simple(0.6, function()
        if SERVER and IsValid(self) then
            self:Remove()
        end
    end)
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
        m:SetColor(self.Owner:GetNWVector("SnowballColor", Vector(1, 1, 1)):ToColor())
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
    local vm = self:GetOwner():GetViewModel()
    vm:SetPlaybackRate(1)
end

function SWEP:Reload()
    if(self:GetNextPrimaryFire() > CurTime())then
        return
    end
    local delay = 1 + self:GetHardness() / 5

    local vm = self:GetOwner():GetViewModel()
   
    self:TimerSimple(delay / 5, function()
        if not IsValid(self) then return end
        self:SetHardness(self:GetHardness() + 1)
        self.Weapon:EmitSound(self.ReloadSound, 75, 100, 0.4, CHAN_WEAPON)
    end)
    self.Weapon:SetNextPrimaryFire(CurTime() + delay)
    self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
    vm:SetPlaybackRate(1/delay)
end
