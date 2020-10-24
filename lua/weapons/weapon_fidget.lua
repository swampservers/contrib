-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

-- Fidget Spinner SWEP by swamponions - STEAM_0:0:38422842

AddCSLuaFile()

SWEP.PrintName			= "Fidget Spinner"	

SWEP.Author = "swamponions"
SWEP.Purpose = "Treat ADHD and Autism"
SWEP.Instructions		= "Primary: Flick\nSecondary: Flip\nReload: Customize"

SWEP.Slot				= 1
SWEP.SlotPos			= 99

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModelFOV = 85
SWEP.ViewModelFlip = false

SWEP.ViewModel 				= Model("models/props_workshop/fidget_spinner.mdl")
SWEP.WorldModel 			= Model("models/props_workshop/fidget_spinner.mdl")

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.ClipSize			= -1
SWEP.Primary.Damage				= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic			= false
SWEP.Primary.Ammo				= "none"

SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Damage			= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo				= "none"

function SWEP:DrawWorldModel()
	local ply = self:GetOwner()

	if(IsValid(ply))then

		self:FidgetThink()

		local bn = ply.IsPony and ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
		local bon = ply:LookupBone(bn) or 0

		local opos = self:GetPos()
		local oang = self:GetAngles()
		local bp,ba = ply:GetBonePosition(bon)
		if(bp)then opos = bp end
		if(ba)then oang = ba end
		if ply.IsPony and ply:IsPony() then
			opos = opos + ply:PonyNoseOffsetBone(oang)
			opos = opos + oang:Forward()*9.5
			opos = opos + oang:Right()*0.7
			oang:RotateAroundAxis(oang:Up(), 30)
		else
			opos = opos + oang:Right()*2
			opos = opos + oang:Forward()*5
			opos = opos + oang:Up()*-2
			oang:RotateAroundAxis(oang:Forward(), 60)
		end
		oang:RotateAroundAxis(oang:Forward(), self:GetFlippage())
		oang:RotateAroundAxis(oang:Right(), self.spinpos or 0)
		self:SetupBones()

		oscl = Vector(0.8,0.8,0.8)

		local mrt = self:GetBoneMatrix(0)
		if(mrt)then
			mrt:SetTranslation(opos)
			mrt:SetAngles(oang)
			mrt:SetScale(oscl)
			self:SetBoneMatrix(0, mrt )
		end

		local mrt = self:GetBoneMatrix(1)
		if(mrt)then
			mrt:SetTranslation(opos)
			mrt:SetAngles(oang)
			mrt:SetScale(oscl)
			self:SetBoneMatrix(1, mrt )
		end
	end

	local v = ply.CustomFidgetColor or Vector(1,0.5,0)
	render.SetColorModulation(v.x,v.y,v.z)
	self:DrawModel()
	render.SetColorModulation(1,1,1)
end

if CLIENT then
	FidgetCurTimeToSysTime = nil

	function SWEP:FidgetThink()
		if FidgetCurTimeToSysTime==nil then	FidgetCurTimeToSysTime = CurTime()-SysTime() end
		local t = SysTime() + FidgetCurTimeToSysTime
		if self.LastFidgetThink==nil then self.LastFidgetThink=t end
		local spinvel = math.max(0, ((self.FidgetFlick or 0) - t) * 60)
		self.spinpos = (self.spinpos or 0) + (spinvel * (t - self.LastFidgetThink))
		self.LastFidgetThink=t
		self.RPMdisplay = math.floor(spinvel/6.0)
	end

	function SWEP:DrawHUD()
		local d = self.RPMdisplay or 0
		if d > 0 then
			draw.WordBox(8, ScrW()*0.3, ScrH()-50, tostring(d).." RPM", "Trebuchet24", Color(0,0,0,128), Color(255,255,255,255))
		end
	end

	net.Receive("FidgetFlick", function()
		local ent = net.ReadEntity()
		ent.FidgetFlick = net.ReadFloat()
	end)

	net.Receive("FidgetFlip", function()
		local ent = net.ReadEntity()
		ent.fliptime = SysTime()
	end)

	function SWEP:GetFlippage()
		return (math.cos(math.pi*math.Clamp((SysTime() - (self.fliptime or 0))*1.25,0,1))+1)*0.5*360
	end

else
	util.AddNetworkString("FidgetFlick")
	util.AddNetworkString("FidgetFlip")
end

function SWEP:PreDrawViewModel( vm, wp, ply )
	local v = ply.CustomFidgetColor or Vector(1,0.5,0)
	render.SetColorModulation(v.x,v.y,v.z)
end

function SWEP:GetViewModelPosition( pos, ang )
	self:FidgetThink()
	pos = pos + ang:Right()*9
	pos = pos + ang:Up()*-7
	pos = pos + ang:Forward()*15
	ang:RotateAroundAxis(ang:Forward(), -40)
	ang:RotateAroundAxis(ang:Forward(), self:GetFlippage())
	ang:RotateAroundAxis(ang:Up(), self.spinpos or 0)
	pos = pos + ang:Forward()*0.2
	return pos, ang 
end

function SWEP:PostDrawViewModel( vm, wp, ply )
	render.SetColorModulation(1,1,1)
end

function SWEP:Initialize() 
	self:SetHoldType("slam") 	 
end 

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.1)

	if SERVER then
		self.FidgetFlick = math.max(CurTime(), self.FidgetFlick or 0) + 5
		net.Start("FidgetFlick")
		net.WriteEntity(self)
		net.WriteFloat(self.FidgetFlick)
		net.Broadcast()
	end
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.8)
	if SERVER then
		net.Start("FidgetFlip")
		net.WriteEntity(self)
		net.Broadcast()
	end
end

function SWEP:Reload()
	if SERVER then
		self.Owner:SendLua("CustomFidgetOpenPanel()")
	end
end

if CLIENT then
	CreateConVar( "cl_fidgetcolor", "1.0 0.5 0.0", FCVAR_ARCHIVE, "The value is a Vector - so between 0-1 - not between 0-255" )

	function SWEP:OwnerChanged()
		if self.Owner == LocalPlayer() then
			self.Owner.CustomFidgetColor = Vector(GetConVar("cl_fidgetcolor"):GetString())
			net.Start("FidgetUpdateCustomColor")
			net.WriteVector(self.Owner.CustomFidgetColor)
			net.SendToServer()
		end
	end

	CustomFidgetFrame = nil

	function CustomFidgetOpenPanel()
		if IsValid(CustomFidgetFrame) then return end

		local Frame = vgui.Create( "DFrame" )
		Frame:SetSize( 320, 240 ) --good size for example
		Frame:SetTitle( "Fidget Widget" )
		Frame:Center()
		Frame:MakePopup()

		local Mixer = vgui.Create( "DColorMixer", Frame )
		Mixer:Dock( FILL )
		Mixer:SetPalette( true )
		Mixer:SetAlphaBar(false) 
		Mixer:SetWangs( true )
		Mixer:SetVector(Vector(GetConVarString("cl_fidgetcolor")))
		Mixer:DockPadding(0,0,0,40)

		local DButton = vgui.Create( "DButton", Frame )
		DButton:SetPos( 128, 200 )
		DButton:SetText( "Build!" )
		DButton:SetSize( 64, 32 )
		DButton.DoClick = function()
			surface.PlaySound("weapons/smg1/switch_single.wav")
			local cvec = Mixer:GetVector()
			RunConsoleCommand('cl_fidgetcolor',tostring(cvec))
			Frame:Remove()
			timer.Simple(0.1, function()
				net.Start("FidgetUpdateCustomColor")
				net.WriteVector(cvec)
				net.SendToServer()
			end)
		end

		CustomFidgetFrame = Frame
	end

	net.Receive("FidgetUpdateCustomColor", function(len)
		local ply = net.ReadEntity()
		local vec = net.ReadVector()
		if IsValid(ply) then ply.CustomFidgetColor = vec end
	end)
else
	util.AddNetworkString("FidgetUpdateCustomColor")
	net.Receive("FidgetUpdateCustomColor", function(len, ply)
		if !ply:HasWeapon("weapon_fidget") then return end
		if ((ply.LastCustomFidgetColorChange or 0) + 1) > CurTime() then return end
		ply.LastCustomFidgetColorChange = CurTime()
		local vec = net.ReadVector()
		net.Start("FidgetUpdateCustomColor")
		net.WriteEntity(ply)
		net.WriteVector(vec)
		net.Broadcast()
	end)
end
