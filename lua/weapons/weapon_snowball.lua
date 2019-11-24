SWEP.PrintName = "Snowballs"	

SWEP.Instructions = "Left click to throw a snowball\nRight click changes trail color"

SWEP.ViewModel = "models/weapons/v_snowball.mdl"
SWEP.WorldModel = "models/weapons/w_snowball.mdl" 

SWEP.Slot = 4
SWEP.SlotPos = 1

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 68

SWEP.AutoSwitchTo = false
SWEP.HoldType = "grenade"

SWEP.Category = "Snowballs"
SWEP.Spawnable = true

SWEP.Primary.ClipSize = 1

SWEP.Primary.Automatic = true
SWEP.ThrowSound = Sound("weapons/iceaxe/iceaxe_swing1.wav")
SWEP.ReloadSound = Sound("weapons/weapon_snowball/crunch.ogg")

local ti = os.date("%B", os.time())
if ti == "December" then --only activate during December
	hook.Add("PlayerChangeLocation", "ChristmasSnowballs", function(ply, loc, old) --auto equip the snowball when outside
		if !IsValid(ply) then return end
		
		local locname = GetLocationNameByIndex(loc)

		if locname == "Outside" or locname == "Golf" and !ply:HasWeapon("weapon_snowball") then
			ply:Give("weapon_snowball")
		end
	end)
end

if SERVER then --network the player's new color
	util.AddNetworkString("CLtoSVSnowballColor")
	util.AddNetworkString("SVtoCLSnowballColor")
	net.Receive("CLtoSVSnowballColor", function(len, ply)
		local col = net.ReadTable()
		ply.currentcolor = col
		net.Start("SVtoCLSnowballColor")
			net.WriteTable(col)
			net.WriteEntity(ply)
			net.Broadcast()
	end)
else
	net.Receive("SVtoCLSnowballColor", function()
		local col = net.ReadTable()
		local ply = net.ReadEntity()
		if !IsValid(ply) then return end
		ply.currentcolor = col
	end)
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self.Weapon:SetClip1(1)
	self.Owner.currentcolor = self.Owner.currentcolor or Color(255, 255, 255)
end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() then return end
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:EmitSound(self.ThrowSound, 75, 100, 0.4, CHAN_WEAPON)

	if SERVER then
		local front = self.Owner:GetAimVector()

		if SERVER then 
			local ball = ents.Create("ent_snowball_nodamage")

			if IsValid(ball) then
				ball:SetOwner(self.Owner)
				ball:SetPos(self.Owner:GetShootPos() + front * 10 + self.Owner:EyeAngles():Up() * -5)
				ball:Spawn()
				ball:Activate()

				local phys = ball:GetPhysicsObject()
				if IsValid(phys) then
					local rand = front:Angle()
					rand = rand:Forward()
					phys:ApplyForceCenter(rand * 1069)
				end
			end
		end
	end
	self.Weapon:SetNextPrimaryFire(CurTime() + 1.2)
	self:Reload()
end

function SWEP:SecondaryAttack() --custom color select menu
	if !IsFirstTimePredicted() then return end
	if CLIENT then
		if IsValid(f) then return end
		local f = vgui.Create("DFrame")
		f:SetSize(287, 211)
		f:Center()
		f:MakePopup()
		f:SetTitle("Trail Color Picker")

		local m = vgui.Create("DColorMixer", f)
		m:Dock(FILL)
		m:SetPalette(true)
		m:SetAlphaBar(true)
		m:SetWangs(true)
		m:SetColor(self.Owner.currentcolor)
		
		local b = vgui.Create("DButton", f)
		b:SetSize(100, 25)
		b:Dock(BOTTOM)
		b:SetText("Change trail color")
		b.DoClick = function()
			f:Close()
			self.Owner.currentcolor = m:GetColor()
			net.Start("CLtoSVSnowballColor")
				net.WriteTable(m:GetColor())
				net.SendToServer()
		end
	end
end

function SWEP:Reload()
	timer.Simple(0.2, function()
		if !IsValid(self) then return end
		self.Weapon:EmitSound(self.ReloadSound, 75, 100, 0.4, CHAN_WEAPON)
	end)
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
end
