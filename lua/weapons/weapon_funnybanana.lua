SWEP.PrintName = "Funny Picture of a Banana"
SWEP.Purpose = "A hilarious picture. Look at it!"
SWEP.Author = "John J. Callanan"
SWEP.Instructions = "Left Click: Laugh\nRight Click: Laugh Hard"

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("chev/weapon_funnybanana/funnybananawepicon")
	SWEP.BounceWeaponIcon = false
end

SWEP.ViewModel = "models/chev/bananaframe.mdl"
SWEP.WorldModel = "models/chev/bananaframe.mdl"

function SWEP:PrimaryAttack()
	if CLIENT then
		if self.Owner:IsPony() then
			RunConsoleCommand("act", "dance")
		else
			RunConsoleCommand("act", "laugh")
		end
		
		if math.random(0, 10) < 3 then --random chance to banana-ify the screen
			RunConsoleCommand("pp_texturize", "pp/texturize/banana.png")
			timer.Simple(6, function()
				RunConsoleCommand("pp_texturize", "")
			end)
		end
	end
	if SERVER then
		self.Owner:Say("hahaha! what a funny picture!")		

		for k, v in pairs(player.GetAll()) do
			if self.Owner:GetPos():Distance(v:GetPos()) < 200 then
				if v != self.Owner then
					timer.Simple(math.Rand(0,1.5),function()
						if IsValid(v) then
							v:ExtEmitSound("weapon_funnybanana/hahaha.ogg", {level=70}, {pitch=math.random(90,110)})
						end
					end)
				end
			end
		end
	end

	local cartoonsnd = {"funnysounds01.ogg", "funnysounds02.ogg"}

	self.Owner:ExtEmitSound("weapon_funnybanana/hahaha_funnypicture.ogg", {shared=true, level=70, channel=CHAN_WEAPON})
	timer.Simple(2, function()
		if IsValid(self) and IsValid(self.Owner) then
			self.Owner:ExtEmitSound("weapon_funnybanana/audiencelaugh.ogg", {shared=true, level=65, volume=0.7, channel=CHAN_AUTO})
			self.Owner:ExtEmitSound("weapon_funnybanana/slipsoundc.ogg", {shared=true, level=65, volume=0.5, channel=CHAN_AUTO})
			self.Owner:ExtEmitSound("weapon_funnybanana/"..cartoonsnd[math.random(#cartoonsnd)], {shared=true, level=65, volume=0.4, channel=CHAN_AUTO})
			self.Owner:ExtEmitSound("airhorn/honk1.ogg", {shared=true, level=65, volume=0.5, channel=CHAN_AUTO})
		end
	end)

	self:SetNextPrimaryFire(CurTime() + 10)
end

function SWEP:SecondaryAttack() --Same as primary attack, but you laugh so hard you die (because the picture is very funny)
	self:PrimaryAttack()
	if SERVER then
		timer.Simple(5, function()
			if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() and self.Owner:GetLocationName() != "Treatment Room" then
				self.Owner:Kill()
				self.Owner:ChatPrint("[red]you died after laughing too hard")
			end
		end)
	end
	self:SetNextSecondaryFire(CurTime() + 10)
end

if CLIENT then
	function SWEP:DrawWorldModel()
	    local ply = self:GetOwner()

		if IsValid(ply) then

			local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
			local bon = ply:LookupBone(bn) or 0

			local opos = self:GetPos()
			local oang = self:GetAngles()
			local bp, ba = ply:GetBonePosition(bon)

			if bp then opos = bp end
			if ba then oang = ba end

			if ply:IsPony() then
				opos = opos + oang:Forward() * 11
				opos = opos + oang:Up() * -0
				opos = opos + oang:Right() * 0
				oang:RotateAroundAxis(oang:Forward(), 90)
			else
				opos = opos + oang:Right() * 2.5
				opos = opos + oang:Forward() * 4
				opos = opos + oang:Up() * 1
				oang:RotateAroundAxis(oang:Forward(), 180)
				oang:RotateAroundAxis(oang:Up(), 90)
			end
			self:SetupBones()

			self:SetModelScale(0.6, 0)
			local mrt = self:GetBoneMatrix(0)
			if(mrt)then
				mrt:SetTranslation(opos)
				mrt:SetAngles(oang)
				self:SetBoneMatrix(0, mrt)
			end
   		end

		self:DrawModel()
	end

	function SWEP:GetViewModelPosition(p, a)
		local bpos = Vector(15, 30, -15)
		local bang = Vector(-20, 125, 20)

		local right = a:Right()
		local up = a:Up()
		local forward = a:Forward()

		a:RotateAroundAxis(right, bang.x)
		a:RotateAroundAxis(up, bang.y)
		a:RotateAroundAxis(forward, bang.z)

		p = p + bpos.x * right
		p = p + bpos.y * forward
		p = p + bpos.z * up

		return p, a
	end
end

function SWEP:Holster()
	return true
end

function SWEP:Deploy()
	self:SetHoldType("pistol")
	return true
end

function SWEP:Initialize()
	return true
end
