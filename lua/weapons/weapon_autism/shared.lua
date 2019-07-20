SWEP.PrintName = "Autistic Outbursts"

SWEP.Slot = 2

SWEP.WorldModel = ""

lastAutism = 0
autisticTwitches = {0,ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL,ACT_HL2MP_GESTURE_RANGE_ATTACK_DUEL,ACT_HL2MP_GESTURE_RANGE_ATTACK_PHYSGUN,ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN,ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG, ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER}

function SWEP:PrimaryAttack()
	if SERVER then
		local thisautism = math.random(1,11)
		if thisautism==lastAutism then thisautism = math.random(1,11) end
		if thisautism==lastAutism then thisautism = math.random(1,11) end
		lastAutism=thisautism
		local soundfile = "autism/left/"..tostring(thisautism)..".wav"
		local pit = math.random(85,115)
		if self.Owner:Crouching() then pit=pit+50 end
		self:ExtEmitSound(soundfile, {speech=-1, pitch=pit})
		local stime = SoundDuration(soundfile)*100/pit
		self.Owner:SendLua("util.ScreenShake(LocalPlayer():GetPos(), 5, 0.5, "..tostring((stime*1.65))..", 10000 )")
		if IsValid(self) and IsValid(self.Owner) then
			timer.Simple(math.Rand(0,1), function()
				setPlayerGesture(self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD, table.Random(autisticTwitches), true )
			end)
		end
		if stime>2 then timer.Simple(math.Rand(0,2), function() if IsValid(self.Owner) and not self.Owner.autismWalkSpeed then setPlayerGesture(self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD, table.Random(autisticTwitches), true ) end end) end
		if stime>2 then timer.Simple(math.Rand(1,2), function() if IsValid(self.Owner) and not self.Owner.autismWalkSpeed then setPlayerGesture(self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD, table.Random(autisticTwitches), true ) end end) end
		if stime>3 then timer.Simple(math.Rand(1,3), function() if IsValid(self.Owner) and not self.Owner.autismWalkSpeed then setPlayerGesture(self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD, table.Random(autisticTwitches), true ) end end) end
		if stime>3 then timer.Simple(math.Rand(2,3), function() if IsValid(self.Owner) and not self.Owner.autismWalkSpeed then setPlayerGesture(self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD, table.Random(autisticTwitches), true ) end end) end
		if stime>4 then timer.Simple(math.Rand(2,4), function() if IsValid(self.Owner) and not self.Owner.autismWalkSpeed then setPlayerGesture(self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD, table.Random(autisticTwitches), true ) end end) end
		if stime>4 then timer.Simple(math.Rand(3,4), function() if IsValid(self.Owner) and not self.Owner.autismWalkSpeed then setPlayerGesture(self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD, table.Random(autisticTwitches), true ) end end) end
		self:SetNextPrimaryFire(CurTime() + stime - 0.05)
		--self:SetNextSecondaryFire(CurTime() + stime - 0.45)
	end
end


function SWEP:SecondaryAttack()
	
	if SERVER and not self.Owner:Crouching() then
			--setPlayerGesture(self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD,ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER, true )
			--self:SetHoldType("grenade")


		local soundfile = "autism/right/1.wav"
		local threehit=false
		local pit = math.random(90,105)
		if math.random(1,9)<3 then
			autismHitSelf(self.Owner,true)
			soundfile = "autism/right/2.wav"
			SetPlayerSpeechDuration(self.Owner,0.2)
			--timer.Simple(0.2,function() SetPlayerSpeechDuration(self.Owner,0) end)
			timer.Simple(0.9,function() 
				if IsValid(self) and IsValid(self.Owner) then SetPlayerSpeechDuration(self.Owner,0.2) end
			end)
			timer.Simple(1.9,function() 
				if IsValid(self) and IsValid(self.Owner) then SetPlayerSpeechDuration(self.Owner,0.2) end
			end)
					local stime = SoundDuration(soundfile) --*100/pit
		self:SetNextPrimaryFire(CurTime() + stime - 0.1)
		self:SetNextSecondaryFire(CurTime() + stime - 0.1)
				
		else
			autismHitSelf(self.Owner,false)
			SetPlayerSpeechDuration(self.Owner,0.2)
					local stime = SoundDuration(soundfile) --*100/pit
		self:SetNextPrimaryFire(CurTime() + stime - 0.5)
		self:SetNextSecondaryFire(CurTime() + stime - 0.5)
				pit = math.random(90,110)
		end

		self:ExtEmitSound(soundfile, {pitch=pit})

	end
end

function SWEP:Reload()
	if CurTime()>(self.Owner.autismlastreload or 0)+2 then
		self.Owner.autismlastreload=CurTime()
		if self.Owner:KeyDown(IN_WALK) then
			self:ExtEmitSound("autism/takeaway.wav", {speech=-1, pitch=pit})
		else	
			if CLIENT then
				RunConsoleCommand("act","wave")
			end
			timer.Simple(0.4,function() self:ExtEmitSound("autism/hai.wav", {speech=-1, pitch=pit}) end)
		end
	end
end
