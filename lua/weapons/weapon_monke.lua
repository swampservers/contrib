-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

--if(SERVER)then resource.AddWorkshop(2396963452) end

SWEP.PrintName = "Return To Monke"
SWEP.Author = "PYROTEKNIK"
SWEP.Category = "PYROTEKNIK"
SWEP.Instructions = "Left Click for monkey scream, Right click for monkey rage. Reload for a nutritious snack."
SWEP.Slot = 1

SWEP.ViewModel	= "models/props/cs_italy/bananna.mdl"
SWEP.WorldModel = "models/props/cs_italy/bananna.mdl"
SWEP.HoldType = "knife"
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = true
SWEP.DrawAmmo = false
SWEP.Spawnable = true


SWEP.TauntsPrimary = {ACT_GMOD_GESTURE_RANGE_FRENZY}
SWEP.TauntsSecondary = {ACT_GMOD_GESTURE_TAUNT_ZOMBIE}
SWEP.EatTaunt = ACT_GMOD_GESTURE_ITEM_GIVE

SWEP.SoundsPrimary = {"monke/monkey1.ogg","monke/monkey2.ogg","monke/monkey3.ogg","monke/monkey4.ogg"}
SWEP.SoundsPrimaryLength = {0.68,1.232,0.912,0.647}
SWEP.SoundsSecondary = {"monke/monkey_long1.ogg","monke/monkey_long2.ogg"}
SWEP.SoundsSecondaryLength = {5.466,4.875}
--i was going to use SoundDuration but it appears to be fucked


function SWEP:CanPrimaryAttack()

	if ( self:GetNextPrimaryFire() > CurTime() ) then
		return false
	end

	return true

end

function SWEP:CanSecondaryAttack()

	if ( self:GetNextSecondaryFire() > CurTime() ) then
		return false
	end

	return true

end

function SWEP:Initialize()
	self:SetHoldType("knife")
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int",0,"RandomSeed")
end

function SWEP:Reload()
	if(!self:CanPrimaryAttack() or !self:CanSecondaryAttack())then return end
	if(self.BananaEatNext and self.BananaEatNext > CurTime())then return end 
	self:NetworkTaunt(3)
	local ply = self:GetOwner()
	if(SERVER)then ply:SetHealth(math.min(self.Owner:Health() + math.random(8,50),self.Owner:GetMaxHealth())) end
	ply.ChewScale = 1
	ply.ChewStart = CurTime()		
	ply.ChewDur = 0.2
	self.Owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ply.IsPony and ply:IsPony() and ACT_LAND or self.EatTaunt, true)
	ply:ExtEmitSound("beans/eating.wav", {level=60,shared=true})
	self.BananaNextRender = CurTime() + 3
	self.BananaEatNext = CurTime() + 3
	self:SetNextPrimaryFire(CurTime() + 3)
	self:SetNextSecondaryFire(CurTime() + 3)
end


function SWEP:GetMonkeyTaunt(sec)
	local ply = self:GetOwner()
	if(ply.IsPony and ply:IsPony())then return ACT_LAND end
	local choice = math.Round(util.SharedRandom( "MonkeyTaunt"..ply:UserID(), 1, #self.TauntsPrimary, self:GetRandomSeed() ),0)
	return self.TauntsPrimary[choice] or ACT_GMOD_GESTURE_RANGE_FRENZY
end

function SWEP:GetMonkeyTaunt2(sec)
	local ply = self:GetOwner()
	if(ply.IsPony and ply:IsPony())then return ACT_LAND end
	local choice = math.Round(util.SharedRandom( "MonkeyTaunt2"..ply:UserID(), 1, #self.TauntsSecondary, self:GetRandomSeed() ),0)
	return self.TauntsSecondary[choice] or ACT_GMOD_GESTURE_TAUNT_ZOMBIE
end


local function SoundMul()
	return  (SERVER and 2 or CLIENT and 4.3)
end

if(CLIENT)then
	net.Receive("MonkyTaunt",function(len)
		local wep = net.ReadEntity()
		if(!IsValid(wep))then return end
		if(wep:GetClass() != "weapon_monke")then return end
		if(!IsValid(wep:GetOwner()))then return end
		local state = net.ReadInt(8)
		if(state == 1)then wep:PrimaryAttack() end
		if(state == 2)then wep:SecondaryAttack() end
		if(state == 3)then wep:Reload() end
	
	end)
end
if(SERVER)then util.AddNetworkString("MonkyTaunt") end

function SWEP:NetworkTaunt(tt)
	if(SERVER)then
		if(!IsValid(self:GetOwner()))then return end
		net.Start("MonkyTaunt")
		net.WriteEntity(self)
		net.WriteInt(tt,8)
		net.SendOmit(self:GetOwner())
	end
end


function SWEP:PrimaryAttack()
	self:NetworkTaunt(1)
	local ply = self:GetOwner()
	local soundindex = math.Round(util.SharedRandom( "MonkeyPrimary"..ply:UserID(), 1, #self.SoundsPrimary, self:GetRandomSeed() ),0)
	local sound = self.SoundsPrimary[soundindex]
	local delay = self.SoundsPrimaryLength[soundindex]
	if(delay == nil or delay == 0)then delay = 1 end
	if(ply.ExtEmitSound)then
		ply:ExtEmitSound(sound, {speech=0.1, shared=true,pitch=100,crouchpitch=100})
	else
		ply:EmitSound(sound)
	end
	ply:ViewPunch( Angle( -2, 0, 0 ) )
	if(self.MonkeyingAround != 1)then
		self.MonkeyingAround = 1
		self.Owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, self:GetMonkeyTaunt(), false)
	end
	timer.Create(ply:EntIndex().."stopmonkeyingaround",delay+0.1,1,function()
		if(IsValid(self))then self.MonkeyingAround = nil end
		ply:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
	end)
	
	if(SERVER)then self:SetRandomSeed(math.random(1,8008135)) end
	self:SetNextPrimaryFire(CurTime() + delay)
	self:SetNextSecondaryFire(CurTime() + delay)
end

function SWEP:SecondaryAttack()
	self:NetworkTaunt(2)
	local ply = self:GetOwner()
	local soundindex = math.Round(util.SharedRandom( "MonkeySecondary"..ply:UserID(), 1, #self.SoundsSecondary, self:GetRandomSeed() ),0)
	local sound = self.SoundsSecondary[soundindex]
	local delay =  self.SoundsSecondaryLength[soundindex]
	if(delay == nil or delay == 0)then delay = 4 end
	if(ply.ExtEmitSound)then
		ply:ExtEmitSound(sound, {speech=0.1, shared=true,pitch=100,crouchpitch=100})
	else
		ply:EmitSound(sound)
	end
	if(self.MonkeyingAround != 2)then
		self.MonkeyingAround = 2
		self.Owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, self:GetMonkeyTaunt2(), false)
	end
	self.BeatingChest = true
	timer.Create(ply:EntIndex().."stopmonkeyingaround",delay,1,function()
		if(IsValid(self))then 
			self.MonkeyingAround = nil 
			self.BeatingChest = false 
			self.BeatChestValue = 0
		end
		if(IsValid(ply))then ply:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD) end
	end)
	for i=1,10 do
		timer.Create(ply:EntIndex().."monkeybeatchest-"..i,0.2+(i*0.15),1,function()
			if(IsValid(self) and IsValid(ply) and ply:GetActiveWeapon() == self)then
			self:SlapChest()
			end
		end)
	end
	if ( IsFirstTimePredicted()) then
		self:DropBanana(delay)
	end
	if(SERVER)then self:SetRandomSeed(math.random(1,8008135)) end
	self:SetNextPrimaryFire(CurTime() + delay)
	self:SetNextSecondaryFire(CurTime() + delay)
end


function SWEP:SlapChest()
	local ply = self:GetOwner()
	if(!IsValid(ply))then return end
	local val = self.BeatChestValue == 1 and 2 or 1
	if(val != self.BeatChestValue)then 
		if(IsValid(ply))then
			local ang1 = Angle(30,-90,0)
			local ang2 = Angle(-30,-90,0)
			if(val == 1)then ang1 = Angle(0,0,0) end
			if(val == 2)then ang2 = Angle(0,0,0) end
			if(val == 1)then ply:ViewPunch( Angle( 0, -1, 1) ) end
			if(val == 2)then ply:ViewPunch( Angle( 0, 1, -1 ) ) end
			if(CLIENT)then
				if(ply:LookupBone("ValveBiped.Bip01_L_Forearm"))then ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Forearm"),ang1) end
				if(ply:LookupBone("ValveBiped.Bip01_R_Forearm"))then ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Forearm"),ang2) end
			end
			if(val != 0)then ply:EmitSound("physics/body/body_medium_impact_soft"..math.random(1,4)..".wav",90,100,0.2) end
		end
		self.BeatChestValue = val
	end
	timer.Create(ply:EntIndex().."resetmonkeychestslap",0.3,1,function()
		if(IsValid(ply) and IsValid(self))then
			self:ResetChest()
		end
	end)
end



function SWEP:ResetChest()
	self.BeatChestValue = 0
	local ply = self:GetOwner()
	if(IsValid(ply))then
		if(ply:LookupBone("ValveBiped.Bip01_L_Forearm"))then ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Forearm"),Angle()) end
		if(ply:LookupBone("ValveBiped.Bip01_R_Forearm"))then ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Forearm"),Angle()) end
	end
end

function SWEP:OnRemove()
	self:ResetChest()
	local ply = self:GetOwner()
	if(IsValid(ply))then
	ply:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
	end
end

function SWEP:DropBanana(delay)
delay = delay or 1
if ( !IsFirstTimePredicted() ) then return end
if ( self.BananaNextRender and self.BananaNextRender > CurTime() ) then self.BananaNextRender = CurTime() + delay return end
if(SERVER)then return end
		if(IsValid(self.BananaGib))then self.BananaGib:Remove() end
		self.BananaGib = ents.CreateClientProp( self.WorldModel )
		if(!IsValid(self.BananaGib))then return end
		local matrix = self:DrawWorldModel(nil,true)
		self.BananaGib:SetPos( matrix:GetTranslation() )
		self.BananaGib:SetAngles( matrix:GetAngles() ) 
		self.BananaGib.BananaGib = true
		self.BananaGib:Spawn()
		self.BananaGib:Activate()
		self.BananaGib:SetModelScale(0.01,4)
		self.BananaNextRender = CurTime() + delay
		if(IsValid(self.BananaGib:GetPhysicsObject()))then 
			self.BananaGib:GetPhysicsObject():ApplyForceCenter(Vector(0,0,500)  + VectorRand()*500) 
			self.BananaGib:GetPhysicsObject():AddAngleVelocity(VectorRand()*500) 
		end
		timer.Simple(4,function()
		if(IsValid(self.BananaGib))then
		self.BananaGib:Remove()
		end
		end)
end

function SWEP:DrawWorldModel(flags,check)
	local ply = self:GetOwner()
	if IsValid(ply) then
		
		local bname = ply.IsPony != nil and ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
		local bone = ply:LookupBone(bname) or 0
		local opos = self:GetPos()
		local oang = self:GetAngles()
		local bp,ba = self.Owner:GetBonePosition(bone)
		if (bp) then opos = bp end
		if (ba) then oang = ba end
		
		if bname == "LrigScull" then
			opos = opos + oang:Right()*-2
			opos = opos + oang:Forward()*9
			opos = opos + oang:Up()*1
			oang:RotateAroundAxis(oang:Forward(),90)
			oang:RotateAroundAxis(oang:Right(),-135)
			
		else
			opos = opos + oang:Right()*2
			opos = opos + oang:Forward()*3
			opos = opos + oang:Up()*-1
			
			oang:RotateAroundAxis(oang:Forward(),90)
			oang:RotateAroundAxis(oang:Right(),-90)
			oang:RotateAroundAxis(oang:Up(),0)
		end
		self:SetupBones()
		local banscale = self.BananaNextRender and 1- math.Clamp((self.BananaNextRender - CurTime())*4,0,1) or 1
		local mrt = self:GetBoneMatrix(0)
		if mrt then
			mrt:SetTranslation(opos)
			mrt:SetAngles(oang)
			mrt:SetScale(Vector(.8,.8,.8)*banscale)
			self:SetBoneMatrix(0,mrt)
		end
		
		if(!check)then 
			if(self.BananaNextRender == nil or (self.BananaNextRender != nil and banscale > 0))then
				self:DrawModel()
			end
		end
		
		if(check)then return mrt end
		return
	end
	
	self:DrawModel()
	return
end

function SWEP:GetViewModelPosition(pos,ang)
	local defang = ang*1
	pos = pos + ang:Forward()* 30
	pos = pos + ang:Right()* 15
	ang:RotateAroundAxis(defang:Up(),90)
	ang:RotateAroundAxis(defang:Right(),90)
	ang:RotateAroundAxis(defang:Up(),-70)
	ang:RotateAroundAxis(ang:Forward(),35)
	ang:RotateAroundAxis(defang:Up(),math.sin(math.rad(CurTime()*90))*15)
	ang:RotateAroundAxis(defang:Right(),math.sin(math.rad(CurTime()*90 + 90))*-15)
	pos = pos + defang:Up()* math.sin(math.rad(CurTime()*90 + 90))*1
	pos = pos + ang:Right() * -2
	pos = pos + defang:Up() * -10
	local banscale = self.BananaNextRender and 1- math.Clamp((self.BananaNextRender - CurTime())*4,0,1) or 1		
	pos = pos + defang:Up() * (1-banscale)*-30
	self.BananaShakeValue = self.BananaShakeValue or 0 
	self.BananaShakeValue = math.Approach(self.BananaShakeValue,self.MonkeyingAround != nil and 1 or 0, FrameTime()*4)
	pos = pos + VectorRand()*self.BananaShakeValue
	return pos,ang
end
