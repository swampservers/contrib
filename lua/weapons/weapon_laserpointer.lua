-- This file is subject to copyright - contact swampservers@gmail.com for more information.

SWEP.PrintName = "Laser Pointer"
SWEP.Author = "Britain1944"
SWEP.Instructions = "Left click: Turn on and off the laser.\nRight click: Change laser power\nRepurchase for more ammo."

SWEP.Category = "Other"

SWEP.Spawnable = true
SWEP.Slot = 3
SWEP.SlotPos = 0
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

game.AddAmmoType({
	name = "Battery",
	dmgtype = nil,
	tracer = nil,
	plydmg = 0,
	npcdmg = 0,
	force = 0,
	minsplash = 0,
	maxsplash = 0
})

SWEP.Primary.Ammo = "Battery"
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefualtClip = 100
SWEP.Primary.Automatic = true

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

SWEP.ViewModel = "models/brian/laserpointer.mdl"
SWEP.WorldModel = "models/brian/laserpointer.mdl"

SWEP.laserorgpos = Vector(0,0,0)
SWEP.laserorgang = Angle(0,0,0)
SWEP.LaserBeamOn = false
SWEP.LaserPower = 0
SWEP.LaserColors = {
	Color(255,0,0,255),
	Color(0,255,0,255),
	Color(255,0,255,255)
}

if CLIENT then
	hook.Add("HUDPaint", "BatteryBar", function()
		local wep = LocalPlayer():GetActiveWeapon()
		if IsValid(wep) and wep:GetClass() == "weapon_laserpointer" then
			draw.RoundedBox(8, (ScrW()/2)-64, ScrH()-48, 128, 32, Color(0, 0, 0, 128))
			draw.RoundedBox(0, (ScrW()/2)-58, ScrH()-42, 1.16*wep:Clip1(), 20, wep.LaserColors[wep.LaserPower+1])
			draw.DrawText("Battery", "DermaLarge", (ScrW()/2), ScrH()-84, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		end
	end)
	hook.Add("HUDPaintBackground", "BlindnessDraw", function()
		local ply = LocalPlayer()
		if IsValid(ply) then
			surface.SetDrawColor(255,255,255,ply:GetNWFloat("Blindness",0))
			surface.DrawRect(0, 0, ScrW(), ScrH())
		end
	end)
	hook.Add("PostDrawTranslucentRenderables", "DrawAllLasers", function()
		for i,v in next, player.GetAll() do
			local wep = v:GetActiveWeapon()
			if IsValid(wep) and wep:GetClass() == "weapon_laserpointer" and wep:GetNWBool("LaserBeamOn") and wep:GetNWBool("CanDrawLaser") and v ~= LocalPlayer() then
				local tr = v:GetEyeTrace()
				local lsrclr = wep.LaserColors[v:GetNWFloat("LaserPower", 0)+1]

				cam.Start3D(EyePos(), EyeAngles())
					--local maxbounce = maxbounce or 0
					local size = math.random()*10

					render.SetMaterial(Material("sprites/bluelaser1"))
					render.DrawBeam(wep:GetNWVector("laserorgpos",Vector(0,0,0,0))+wep:GetNWVector("laserorgang",Angle(0,0,0)):Up()*6, tr.HitPos, 2, 0, 12.5, lsrclr, false)
					render.SetMaterial(Material("sprites/light_glow02_add"))
					render.DrawQuadEasy(tr.HitPos, tr.HitNormal, size, size, lsrclr)

					--[[if tr.Entity:GetMaterial() == "func_reflective_glass" and maxbounce <= 1 then--this is for the refelcted laser
						local vec = origin-tr.HitPos
						local normal = tr.HitNormal
						local reflect = -2*vec:Dot(normal)*normal+vec
						local trc = util.TraceLine({
							start = tr.HitPos,
							endpos = tr.HitPos + reflect:Angle():Forward() * 10000,
							filter = false
						})

						render.SetMaterial(Material("sprites/bluelaser1"))
						render.DrawBeam(tr.HitPos, trc.HitPos, 2, 0, 12.5, lsrclr, false)
						render.SetMaterial(Material("sprites/light_glow02_add_noz"))
						render.DrawSprite(trc.HitPos, size, size, lsrclr)

						maxbounce = maxbounce+1
					end]]
				cam.End3D()
			end
		end
	end)
	hook.Add("KeyRelease","RemoveBeam", function(ply, key)
		if key == IN_ATTACK then
			if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_laserpointer" then
				ply:GetActiveWeapon():RemoveLaser()
			end
		end
	end)
else--server code
	hook.Add("KeyRelease","RemoveBeam", function(ply, key)
		if key == IN_ATTACK then
			if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_laserpointer" then
				ply:GetActiveWeapon():RemoveLaser()
			end
		end
	end)
	hook.Add("WeaponEquip", "MakeSureAmmoIs100", function(wep, ply)
		if IsValid(wep) and wep:GetClass() == "weapon_laserpointer" then
			if wep:Clip1() < 100 then
				wep:SetClip1(100)
			end
		end
	end)
	hook.Add("DoPlayerDeath", "OnPlayerDeath", function(ply, att, dmg)
        if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_laserpointer" then
            ply:GetActiveWeapon():RemoveLaser()
        end
    end)
    timer.Create("BlindnessUpdater", 0.1, 0, function()
    	for i,v in next, player:GetAll() do
    		if IsValid(v) then
    		local blind = v:GetNWFloat("Blindness", 0)
				if blind ~= nil then
					if (blind or 0) > 0 then blind = blind-2 end
					if blind < 0 then blind = 0 end

					v:SetNWFloat("Blindness",blind)
				end
			end
		end
	end)
end

function SWEP:DrawWorldModel()
	local ply = self.Owner

	if(IsValid(ply))then
		local bn = "ValveBiped.Bip01_R_Hand"
		local bon = ply:LookupBone(bn) or 0

		local opos = self:GetPos()
		local oang = self:GetAngles()
		local bp,ba = ply:GetBonePosition(bon)
		if(bp)then opos = bp end
		if(ba)then oang = ba end

		oang:RotateAroundAxis(oang:Right(), -90)
		oang:RotateAroundAxis(oang:Up(), 90)
		opos = opos + oang:Forward()*-2
		opos = opos + oang:Right()*1.25
		opos = opos + oang:Up()*1.5

		self.laserorgpos:Set(opos)
		self.laserorgang:Set(oang)
		self:SetNWVector("laserorgpos",opos)
		self:SetNWAngle("laserorgang",oang)

		self:SetupBones()

		if IsValid(self) and self:GetClass() == "weapon_laserpointer" and self.LaserBeamOn and self.Weapon:Clip1() > 0  then
			local tr = self.Owner:GetEyeTrace()
			local lsrclr = self.LaserColors[self.LaserPower+1]

			cam.Start3D(EyePos(), EyeAngles())
				local size = math.random()*10

				--render.SetMaterial(Material("sprites/bluelaser1"))
				render.SetMaterial(Material("cable/new_cable_lit"))
				render.DrawBeam(self.laserorgpos+self.laserorgang:Up()*6, tr.HitPos, 0.1, 0, 12.5, lsrclr, false)
				render.SetMaterial(Material("sprites/light_glow02_add"))
				render.DrawQuadEasy(tr.HitPos, tr.HitNormal, size, size, lsrclr)
			cam.End3D()
		end

		local mrt = self:GetBoneMatrix(0)

		if(mrt)then
			mrt:SetTranslation(opos)
			mrt:SetAngles(oang)
			self:SetBoneMatrix(0, mrt)
		end
	end
	self:DrawModel()
end

function SWEP:GetViewModelPosition(pos, ang)
	pos = pos + ang:Right()*2
	pos = pos + ang:Up()*-3
	pos = pos + ang:Forward()*5
	ang:RotateAroundAxis(ang:Forward(), -3)
	ang:RotateAroundAxis(ang:Right(), -90)
	ang:RotateAroundAxis(ang:Up(), -105)
	pos = pos + ang:Forward()*0.1
	return pos, ang
end

function SWEP:PreDrawViewModel()
	if IsValid(self) and self:GetClass() == "weapon_laserpointer" and self.LaserBeamOn and self.Weapon:Clip1() > 0  then
		local tr = self.Owner:GetEyeTrace()
		local vm = self.Owner:GetViewModel()
		local attachmentIndex = vm:LookupAttachment("tip")
		local origin = vm:GetAttachment(attachmentIndex).Pos
		local lsrclr = self.LaserColors[self.LaserPower+1]

		cam.Start3D(EyePos(), EyeAngles())
			local size = math.random()*10

			render.SetMaterial(Material("sprites/bluelaser1"))
			render.DrawBeam(origin, tr.HitPos, 2, 0, 12.5, lsrclr, false)
			render.SetMaterial(Material("sprites/light_glow02_add_noz"))
			render.DrawSprite(tr.HitPos, size, size, lsrclr)
		cam.End3D()
		--[[if tr.Entity:GetMaterial() == "func_reflective_glass" and maxbounce <= 1 then--for reflecting the laser
			local vec = origin-tr.HitPos
			local normal = tr.HitNormal
			local reflect = -2*vec:Dot(normal)*normal+vec
			local trc = util.TraceLine({
				start = tr.HitPos,
				endpos = tr.HitPos + reflect:Forward() * 10000,
				filter = false
			})

			render.SetMaterial(Material("sprites/bluelaser1"))
			render.DrawBeam(tr.HitPos, trc.HitPos, 2, 0, 12.5, lsrclr, false)
			render.SetMaterial(Material("sprites/light_glow02_add_noz"))
			render.DrawSprite(trc.HitPos, size, size, lsrclr)

			maxbounce = maxbounce+1
		end]]
	end
end

function SWEP:Deploy()
	self:RemoveLaser()
	self:SetHoldType("pistol")
    self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:OnRemove()
	self:RemoveLaser()
end

function SWEP:PrimaryAttack()--shoots the laser
	if (!self:CanPrimaryAttack()) then return end

	local trc = self.Owner:GetEyeTrace()
	local lctn = Location.GetLocationNameByIndex(Location.Find(trc.Entity)):lower()
	local loc = Location.GetLocationNameByIndex(Location.Find(self.Owner)):lower()

	if (self.Owner:InTheater() and not (self.Owner:GetTheater()._AllowItems)) or loc=="trump lobby" or loc=="golf" then
		self.Owner:PrintMessage(HUD_PRINTTALK, "[red] Stop right there! Lasers are not allowed in this area. ;authority;")
	end

	self:DrawLaser()
	self.Weapon:TakePrimaryAmmo(self.LaserPower/2+0.1)

	if IsValid(trc.Entity) and trc.Entity:IsPlayer() and trc.HitBox == 0 and not -Safe(trc.Entity) and (trc.Entity:InTheater() and not (trc.Entity:GetTheater()._AllowItems)) or lctn=="trump lobby" or lctn=="golf" then
		self:BlindPlayer(trc.Entity)
		self:SetNextPrimaryFire(CurTime() + 0.1)
	else
		self:SetNextPrimaryFire(CurTime() + 0.1)
	end
end

function SWEP:SecondaryAttack()--changes laser color
	if (!IsFirstTimePredicted()) then return end

    if not self.LaserPower then self.LaserPower = 0 end
    self.LaserPower = (self.LaserPower+1) % (#self.LaserColors)
    self.Owner:SetNWFloat("LaserPower",self.LaserPower)
end

function SWEP:Reload()--reloads the batteries
	if (!IsValid(self)) or timer.Exists("Reload"..self.Owner:SteamID64()) or self.Weapon:Clip1() >= self.Primary.ClipSize or self.Owner:GetAmmoCount(self.Primary.Ammo) == 0 then return end

	timer.Create("Reload"..self.Owner:SteamID64(), 0.1, 0, function()
		self.Owner:RemoveAmmo(100-self.Weapon:Clip1(), self.Primary.Ammo, false)
		self.Weapon:SetClip1(100)
		self.Owner:EmitSound("items/ammo_pickup.wav")
		timer.Remove("Reload"..self.Owner:SteamID64())
	end)
end

function SWEP:Think()
	if self:Clip1() > 0 then
		self:SetNWBool("CanDrawLaser",true)
	else
		self:SetNWBool("CanDrawLaser",false)
	end
end

function SWEP:BlindPlayer(ply)--makes the player being aimed at go blind
	if SERVER then
		local blind = ply:GetNWFloat("Blindness", 0)
		blind = (blind or 0)+(1+self.LaserPower)*15
		if (blind or 0) > 0 then
			if blind > 255 then blind = 255 end
		end

		ply:SetNWFloat("Blindness",blind)
	end
end

function SWEP:DrawLaser()
	self.LaserBeamOn = true
	self:SetNWBool("LaserBeamOn", true)
end

function SWEP:RemoveLaser()
	self.LaserBeamOn = false
	self:SetNWBool("LaserBeamOn", false)
end
