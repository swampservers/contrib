
AddCSLuaFile()

SWEP.PrintName = "Tag"
SWEP.Author = "Ugleh"
SWEP.Purpose = "Tag someone within 30 seconds or you will die."
SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.Weight					= 99
SWEP.AutoSwitchTo			= true
SWEP.AutoSwitchFrom			= false

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/c_arms.mdl" )
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false

SWEP.HitDistance = 48


local justReloaded = 0
local tagTimer = 35
function SWEP:Initialize()
	self:SetHoldType( "fist" )
	if SERVER then
		self:SetNWFloat("initTime", CurTime()) 
		timer.Simple(5,function() if IsValid(self) and self.Owner:IsFrozen() then self.Owner:UnLock() end end)
		timer.Simple(tagTimer,
		function()
			if IsValid(self) then
				local effectdata = EffectData()
				effectdata:SetOrigin(self:GetPos() )
				effectdata:SetMagnitude(0)
				util.Effect( "Explosion", effectdata, true, true )
				self:Remove()
				self.Owner:Kill()
			end
		end)
	end
end

function SWEP:Deploy()
	self:SetHoldType("fist")
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_draw" ) )

end

function SWEP:Reload()
	if justReloaded<1 then
		local pitch = 100 + (self.Owner:Crouching() and 40 or 0)
		self:ExtEmitSound("tag/dead.wav", {speech=0.8, volume=0.35, pitch=pitch, shared=true})
	end
	justReloaded=2
end

function SWEP:Tick()
	justReloaded = justReloaded-1
end


function SWEP:TagPlayer(self,target,attacker)
	if SERVER then
		if (target:InVehicle()) then target:ExitVehicle() end
		target:Lock()
		target:Give( "weapon_tag" )
		self:ExtEmitSound("tag/slap.wav", {speech=0.8, volume=0.4, shared=true})
		self:ExtEmitSound("tag/frozen.wav", {speech=0.8, volume=0.3, shared=true})
		timer.Simple(0,function() if IsValid(self) then self:Remove() end end)
	end
end

function SWEP:TestTagPlayer(self,target,attacker)
	 if not Safe(target) then
		 self.TagPlayer(self,target,attacker)
	 elseif attacker:GetTheater() and attacker:GetTheater():IsPrivate() and attacker:GetTheater():GetOwner() == attacker and attacker:GetLocationName() == target:GetLocationName() then
		 self.TagPlayer(self,target,attacker)
	 else return end
end


function SWEP:DrawHUD()
	local displayTime = math.Round(tagTimer - (CurTime() - self:GetNWFloat("initTime", CurTime())), 1)
	local displayString = "You have " .. displayTime .. " Seconds to tag someone else"
	local TextWidth = surface.GetTextSize(displayString)
	draw.WordBox(8, ScrW()/2 - TextWidth/2, ScrH()/2, displayString, "Trebuchet24", Color(0,0,0,128), Color(255,255,255,255))

end
function SWEP:PrimaryAttack( right )

	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	local anim = "fists_left"
	if ( right ) then anim = "fists_right" end
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( anim ) )
	
	self:SetNextPrimaryFire( CurTime() + 0.9 )
	self:SetNextSecondaryFire( CurTime() + 0.9 )
	
		local eyetrace = self.Owner:GetEyeTrace()
	
	if eyetrace.Hit then
		if (eyetrace.Entity:IsPlayer() and eyetrace.Entity:Alive()) then
			TestTagPlayer(self,eyetrace.Entity,self.Owner)
		else
			local target = {nil,50}
			local allply = player.GetAll()
			local tracepos = self.Owner:GetEyeTrace().HitPos
			for k,v in pairs(allply) do
				if (v:Alive() and v ~= self.Owner) then	
					local otherpos = v:LocalToWorld(v:OBBCenter())
					local dis = tracepos:Distance(otherpos)
					if (dis < target[2]) then
						local tr = util.TraceLine( {
							start = tracepos,
							endpos = otherpos,
							filter = allply
						} )

						if tr.Hit then continue end
						target = {v,dis}
					end
				end
			end
			if (target[2] < 50) then
				self.TestTagPlayer(self,target[1],self.Owner)
			end
		end
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack( true )
end

function SWEP:DealDamage()

end

function SWEP:OnDrop()

end
