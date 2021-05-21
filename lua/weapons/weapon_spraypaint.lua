AddCSLuaFile()

SWEP.PrintName = "Spraypaint"
SWEP.Author = "PYROTEKNIK &"
SWEP.Category = "PYROTEKNIK"
SWEP.Instructions = "Left Click to Draw, Hold Right mouse to reduce mouse sensitivity, Press R to change color and paint size"
SWEP.Purpose = "Point it in someone's eye :)"

SWEP.Slot = 1
SWEP.SlotPos = 100

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/pyroteknik/v_spraypaint.mdl")
SWEP.WorldModel = Model("models/pyroteknik/w_spraypaint.mdl")
SWEP.CapModel = Model( "models/pyroteknik/w_spraypaint_cap.mdl" )
SWEP.ShakeSound = Sound("spraypaint/spray_shake.wav")
SWEP.PopCapSound = Sound("spraypaint/spray_capoff.wav")

SWEP.ViewModelFOV = 70
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = true

SWEP.DrawCrosshair = false
SWEP.BounceWeaponIcon = false
SWEP.RenderGroup =RENDERGROUP_OPAQUE




if(CLIENT)then
	SPRAYMATS = {}
	local function GetPaintMaterial(color)
		color = Color(255,255,255,255)
		SPRAYMATS = SPRAYMATS or {}
		SPRAYMATS[color] = SPRAYMATS[color] or {
			CreateMaterial(
			"spraypaint"..tostring(color),
			"LightmappedGeneric",
			{
				["$basetexture"] = "spray/dot",
				["$decal"] = 1,
				["$translucent"] = 1,
				["$decalscale"] = 1/16,
				["$modelmaterial"] = "spraypaint"..tostring(color).."_model",
				["$vertexcolor"] = 1,
				["$color2"] = color:ToVector(),
				["$alpha"] = color.a/255,
			}),
			CreateMaterial(
			"spraypaint"..tostring(color).."_model",
			"VertexLitGeneric",
			{
				["$basetexture"] = "spray/dot",
				["$decal"] = 1,
				["$translucent"] = 1,
				["$decalscale"] = 1/16,
				["$vertexcolor"] = 1,
				["$color2"] = color:ToVector(),
				["$alpha"] = color.a/255,
			})
		}
		 
		
		return SPRAYMATS[color][1]
	end

	net.Receive("spraypaint_networkdecal",function(len)
		local pos = net.ReadVector()
		local normal = net.ReadVector()
		local color = net.ReadColor()
		local size = net.ReadFloat()
		local ent = net.ReadEntity()
		util.DecalEx( GetPaintMaterial(color), ent, pos, normal, color, size, size )
	end)
end

if(SERVER)then
	
	function SPRAYPAINT_MAKEDOT(trace,size,color)	
		net.Start("spraypaint_networkdecal")
		net.WriteVector(trace.HitPos)
		net.WriteVector(trace.HitNormal)
		net.WriteColor(color)
		net.WriteFloat(size)
		net.WriteEntity(trace.Entity)
		net.SendPVS(trace.HitPos)
	end
	util.AddNetworkString("spraypaint_networkdecal")


end



if (CLIENT) then


	local wepicon = Material("spraypaint/spraypaint_icon.png", "smooth")

	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		self.SelNeeded = 5
		if(!IsValid(self.TempModel))then
			self.TempModel = ClientsideModel(self.WorldModel)
			self.TempModel:SetNoDraw(true)
		else
			local pan = Angle(0,0,0)
			pan:RotateAroundAxis(Vector(0,1,0),-25)
			pan:RotateAroundAxis(Vector(0,0,1),CurTime()*270)
			self.TempModel:SetAngles(pan)
		end
		if(IsValid(self.TempModel))then	
			cam.Start2D()
			cam.Start3D(Vector(0,-37,1), Angle(0,90,0), 32, x,y, wide,tall)
			render.SuppressEngineLighting(true)
			for i=0,5 do
			render.SetModelLighting( i, 0.5,0.5,0.5 )
			end
			render.SetModelLighting( 4, 1,1,1 )
			render.SetModelLighting( 5, 0,0,0 )
			
			local cl = self:GetCustomColor() or Vector(1,0,1)
			render.SetColorModulation(cl.x,cl.y,cl.z)
			
			self.TempModel:DrawModel()
			render.SuppressEngineLighting(false)
			cam.End3D()
			cam.End2D()
			local shit = self.TempModel
			timer.Remove("WEPSEL_SPRAYPAINT_"..self.TempModel:EntIndex())
			timer.Create("WEPSEL_SPRAYPAINT_"..self.TempModel:EntIndex(),0.2,1,function()
				if(IsValid(shit))then
					shit:Remove()
				end
			end)
		end
	end
end




function SWEP:Initialize()
	self.CapOn = true
	self:SetHoldType("passive")
	if(SERVER)then
		if(!IsValid(self:GetOwner()))then
			local randcol = HSVToColor(math.Rand(0,360),1,1)
			local c = Vector(randcol.r/255,randcol.g/255,randcol.b/255)
			self:SetCustomColor(Vector(c.x,c.y,c.z))
		end
	end
	
end

function SWEP:SetupDataTables()
	self:NetworkVar("Vector", 0, "CustomColor")
	self:NetworkVar("Float", 0, "PaintAlpha")
	self:NetworkVar("Float", 1, "PaintSize")
end

function SWEP:SecondaryAttack()
if(CLIENT)then
self.SensToggle = !self.SensToggle
end
self:SetNextSecondaryFire(CurTime() + 0.01)
return true
end

function SWEP:Deploy()
	if(SERVER)then self:SendWeaponAnim( ACT_VM_DRAW ) end
	if(SERVER)then self:UpdateCustomColor() end
	
	self:PlayEquipAnimation()

	return true
end


	

function SWEP:Holster()
	self:CancelAllAnimations()
	return true
end

function SWEP:Reload()
	return true
end


function SWEP:Equip(ply)
	if(SERVER)then 
		net.Start("SpraypaintRequestCustomColor")
		net.Send(ply)
		self:UpdateCustomColor() 
	end
end

function SWEP:EquipAmmo(ply)
end

function SWEP:GetPaintDistance()

return 128 + (self:GetPaintSize()*4)
end


function SWEP:MakeCap()
	
	if(CLIENT)then
		self.Owner:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL, true)
		self.CapOn = false
		self:EmitSound(self.PopCapSound)

		local matrix,opos,oang = self:DrawWorldModel(true)
		if(IsValid(self.CapGib))then
			self.CapGib:Remove()
		end
		local cc = self:GetCustomColor()
		local color = Color(cc.x*255,cc.y*255,cc.z*255,255)
		self.CapGib = ents.CreateClientProp( self.CapModel )
		if(!IsValid(self.CapGib))then return end
		self.CapGib:SetPos( opos )
		self.CapGib:SetAngles( oang ) 
		self.CapGib:SetColor(color)
		self.CapGib:Spawn()
		self.CapGib:Activate()
		if(IsValid(self.CapGib) and IsValid(self.CapGib:GetPhysicsObject()))then
			self.CapGib:GetPhysicsObject():ApplyForceCenter(matrix:GetAngles():Up()*math.Rand(50,80))
			self.CapGib:GetPhysicsObject():ApplyTorqueCenter(VectorRand()*10)
		end
		local gib = self.CapGib
		timer.Create(self:EntIndex().."capremovegib",10,1,function()
			if(IsValid(gib))then
				gib:Remove()
			end
		end)
		
	end
end
 
function SWEP:TossEmpty(colorvec)
	if(CLIENT)then
		self.Owner:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL, true)
		self:SetNoDraw(true)
		local matrix,opos,oang = self:DrawWorldModel(true)
		if(IsValid(self.EmptyGib))then
			self.EmptyGib:Remove()
		end
		local cc = colorvec or self:GetCustomColor()
		local color = Color(cc.x*255,cc.y*255,cc.z*255,255)
		local ply = self:GetOwner()
		self.EmptyGib = ents.CreateClientProp( self.WorldModel )
		if(!IsValid(self.EmptyGib))then return end
		self.EmptyGib:SetPos( opos )
		self.EmptyGib:SetAngles( oang ) 
		self.EmptyGib:SetBodygroup(1,1)
		self.EmptyGib:SetColor(color)
		self.EmptyGib:Spawn()
		self.EmptyGib:Activate()
		if(IsValid(self.EmptyGib) and IsValid(self.EmptyGib:GetPhysicsObject()))then
			local dir = Angle(0,ply:EyeAngles().yaw,0)
			self.EmptyGib:GetPhysicsObject():ApplyForceCenter(Vector(0,0,150) + dir:Forward()*-100)
			self.EmptyGib:GetPhysicsObject():ApplyTorqueCenter(VectorRand()*10)
		end
		
		local gib = self.EmptyGib
		timer.Create(gib:EntIndex().."emptyremovegib",10,1,function()
			if(IsValid(gib))then
				gib:Remove()
			end
		end)
		
		
	end
end
  
 
function SWEP:ShakeCan()
	
	timer.Create("capshakesnd__"..self:EntIndex(),0.3,1,function()
		self:EmitSound(self.ShakeSound,80)
	end)
	timer.Create("capshake__"..self:EntIndex(),0.1,1,function()
		timer.Create("capshake_"..self:EntIndex(),0.2,3,function() 
			self.Owner:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL, true)
			
		end)	
		
	end)

end
 

if(SERVER)then util.AddNetworkString("spraypaint_equipanim" ) end 
 
if(CLIENT)then
net.Receive("spraypaint_equipanim",function(len)
local wep = net.ReadEntity()
local spawnempty = net.ReadBool()
local ecolor = (spawnempty and net.ReadVector()) or nil
if(IsValid(wep) and wep.PlayEquipAnimation)then wep:PlayEquipAnimation(spawnempty,ecolor) end
end)

end 
 
function SWEP:PlayEquipAnimation(spawnempty,ecolor)
	self.ViewmodelDown = 1
	if(SERVER)then
		net.Start("spraypaint_equipanim",true)
		net.WriteEntity(self)
		net.WriteBool(spawnempty)
		if(spawnempty and ecolor)then net.WriteVector(ecolor) end
		net.SendPVS(self:GetPos())
	end
	
	if(spawnempty)then
	self:TossEmpty(ecolor)
	end
	self.CapOn = true
	self:SetHoldType("normal")
	timer.Create("uncap_"..self:EntIndex(),0.3,1,function()
		self:SetNoDraw(false)
		self:MakeCap()
		self:SetHoldType("pistol")
		--if(spawnempty)then self:ShakeCan() end
	end)
end


function SWEP:CancelAllAnimations()
self.CapOn = true
timer.Destroy("capshake_"..self:EntIndex())
timer.Destroy("capshakesnd__"..self:EntIndex())
timer.Destroy("uncap_"..self:EntIndex())
timer.Destroy("capshake_"..self:EntIndex())
end 
  
 

 
 
if(CLIENT)then
	if not SpraypaintParticleEmitter then SpraypaintParticleEmitter = ParticleEmitter(Vector(0,0,0)) end

	function SWEP:DoParticle( pos, endpos, color, size)
		
		for i=1,5 do
		local matrix,opos,oang = self:DrawWorldModel(true)
		pos = opos + oang:Up()*5
		if(self:GetOwner() == LocalPlayer() and !self:GetOwner():ShouldDrawLocalPlayer())then
			local vm = self:GetOwner():GetViewModel()
			local bone = vm:LookupBone("plunger")
			if(bone)then 
				local matrix = vm:GetBoneMatrix(bone)
				if(matrix)then
					pos = matrix:GetTranslation() + matrix:GetAngles():Forward()*-5	+ matrix:GetAngles():Up()*-1
				end
			end
		end
		local dir = (endpos-pos):GetNormal()
		local tv = dir*500
		
		pos = pos + dir*math.Rand(0,tv:Length())*FrameTime()
		
		self.SprayEmitter = self.SprayEmitter or ParticleEmitter(pos)
		if(not SpraypaintParticleEmitter)then return end
		self.SprayEmitter:SetPos(pos)
		local particle = self.SprayEmitter:Add(string.format("particle/smokesprites_00%02d",math.random(7,16)), pos)
		--if DisableConvar:GetBool() then return end
		particle:SetColor(color.r, color.g, color.b, color.a )
		particle:SetStartAlpha(color.a)
	
	
		particle:SetVelocity( tv )
		particle:SetGravity( Vector(0,0,0) )
		particle:SetLifeTime(0)
		particle:SetLighting( false )
		particle:SetDieTime(math.Rand(0.1,0.3))
		particle:SetStartSize(0)
		particle:SetEndSize(size*0.25)
		particle:SetEndAlpha(0)
		particle:SetCollide(true)
		particle:SetBounce(0)
		particle:SetRoll(math.Rand(0,360))
		particle:SetRollDelta(0.01*math.Rand(-40,40))
		particle:SetAirResistance(100)
		end
		
	end
end


function SWEP:MakePaint(trace,delay)
	local cc = self:GetCustomColor()
	local alpha = math.Clamp(self:GetPaintAlpha(),0.25,1)
	local size = self:GetPaintSize()
	local alphamul = 1
	local color = Color(cc.x*255,cc.y*255,cc.z*255,alpha*255*alphamul)
	if(CLIENT)then

		
		
		self:DoParticle( trace.StartPos , trace.HitPos , color, size)
		
		if(!self.SpraySound)then
		sound.PlayFile( "sound/spraypaint/spraypaint.wav", "3d mono noblock" ,function(sound)
			if(IsValid(sound))then
				self.SpraySound = sound
				sound:SetPos(self:GetPos())
			end
		end)
		end
		if(self.SpraySound)then
		self.SpraySound:SetPos(self:GetPos())
		if(self.SpraySound:GetState() != GMOD_CHANNEL_PLAYING)then self.SpraySound:Play() end
			if(self.SpraySound:GetTime() >= 0.6)then 
				self.SpraySound:SetTime(0.055+math.Rand(0,0.4)) 
			end
			local globpitch = 1
			local globvol = 1
			self.SprayRand = self.SprayRand or 1
			self.SprayRand = math.Clamp(self.SprayRand + math.Rand(-1,1)*FrameTime()*0.1,0.9,1.1)
			self.SpraySound:SetPlaybackRate(globpitch * self.SprayRand)
			self.SpraySound:SetVolume(globvol)
			timer.Create(self:EntIndex().."spraysoundend",delay*1.04,1,function()
				if(IsValid(self.SpraySound))then
					self.SpraySound:SetTime(0.665)
				end
			end)
			
		end
		
		return 
	end 

	if(trace.HitSky)then return end
	if(!trace.Hit)then return end
	if(!self:MovementAppropriate())then return end

	local pos = trace.HitPos*1
	local normal = trace.HitNormal*1
	local cc = self:GetCustomColor()
	local alpha = math.Clamp(self:GetPaintAlpha(),0.25,1)
	local size = self:GetPaintSize()
	local fcolor = Color(cc.x*255,cc.y*255,cc.z*255,alpha*255*alphamul)
	local pos2
	local surfdist = self:GetOwner():EyePos():Distance(trace.HitPos)
	
	
	if(SERVER)then
		if(SPRAYPAINT_MAKEDOT)then
			SPRAYPAINT_MAKEDOT(trace,size,fcolor)		
		end
	end
end

hook.Add("KeyPress","SpraypaintColorPicker",function(ply, key)
	local wep = ply:GetActiveWeapon()
	if(key == IN_RELOAD and IsValid(wep) and wep:GetClass() == "weapon_spraypaint") then
		if(CLIENT)then
		wep:SpraypaintOpenPanel()
		end
	end
end)

function SWEP:GetTrace()
	local ply = self:GetOwner()
	local org = ply:EyePos() + ply:GetVelocity()*FrameTime()
	local tr = {}
	tr.start = org
	tr.endpos = org + ply:GetAimVector()*(self:GetPaintDistance()+5)
	tr.mask = MASK_VISIBLE
	tr.filter = ply
	local trace = util.TraceLine(tr)
	if(trace.HitTexture == "**displacement**" or trace.HitTexture == "**studio**")then
	trace.Invalid = true
	end
	
	
	return trace
end

function SWEP:MovementAppropriate()
	return true
end


function SWEP:PrimaryAttack()
	

	local trace = self:GetTrace()
	if(!trace.Invalid)then
		self:MakePaint(trace,(1/60))
	end
	self:SetNextPrimaryFire(CurTime() + (1/60))
end


function SWEP:OnDrop()
end

function SWEP:PreDrawViewModel(vm, weapon, ply)
	self:SetBodygroup(2,(self.CapOn and 0) or 1)
	local cl = self:GetCustomColor()
	render.SetColorModulation(cl.x,cl.y,cl.z)
	local down = ply:KeyDown(IN_ATTACK)
	self.FingerLerp = self.FingerLerp or 0
	if(down)then self.FingerLerp = math.min(self.FingerLerp + FrameTime()*12,1) end
	if(!down)then self.FingerLerp = math.max(self.FingerLerp - FrameTime()*8,0) end
	vm:SetPoseParameter("press",self.FingerLerp)

end
hook.Add("PostDrawViewModel","paint_handsfix",function(vm,ply,weapon)
render.SetColorModulation(1,1,1)
end)


function SWEP:PostDrawViewModel(vm, weapon, ply)
render.SetColorModulation(1,1,1)
end

function SWEP:DrawWorldModel(query)
	local ply = self:GetOwner()
	self:SetModelScale(1, 0)
	self:SetSubMaterial()
	local matrix
	
	local horn = false
	local opos = self:GetPos()
	local oang = self:GetAngles()
	if IsValid(ply) then
		local modelStr = ply:GetModel():sub(1, 17)
		local isPony = modelStr == "models/ppm/player" or modelStr == "models/mlp/player" or modelStr == "models/cppm/playe"
		local bn = isPony and "LrigScull" or "ValveBiped.Bip01_R_Hand"
		local bon = ply:LookupBone(bn) or 0
		
		local bp, ba = ply:GetBonePosition(bon)
		if bp then
			opos = bp
		end
		if ba then
			oang = ba
		end
		if isPony then
			opos = opos + (oang:Forward() * 6.4) + (oang:Right() * -1.8) + (oang:Up() * 0)
			oang:RotateAroundAxis(oang:Right(), 80)
			oang:RotateAroundAxis(oang:Forward(), 12)
			oang:RotateAroundAxis(oang:Up(), 20)
		else
			if (bn ~= 0) then
				oang:RotateAroundAxis(oang:Forward(), 90)
				oang:RotateAroundAxis(oang:Right(), 90)
				
				oang:RotateAroundAxis(oang:Forward(),90)
				
				opos = opos + oang:Right()*3.5
				opos = opos + oang:Forward()*2
				opos = opos + oang:Up()*0
				oang:RotateAroundAxis(oang:Up(),-90)
			end
		end
		if (isPony) then
			if (horn) then
				opos = opos - oang:Up() * 5
			else
				opos = opos + oang:Up() * 3
			end
		end
		self:SetupBones()
		matrix = self:GetBoneMatrix(0)
		if matrix then
			matrix:SetTranslation(opos)
			matrix:SetAngles(oang) 
			if (query ~= true) then
				self:SetBoneMatrix(0, matrix)
			end
		end
		
		
		end 
		if (query ~= true) then
			render.MaterialOverride()
			draw.NoTexture()
			local cl = self:GetCustomColor()
			render.SetColorModulation(cl.x,cl.y,cl.z)
			render.SetBlend(1)
			self:SetBodygroup(1,(self.CapOn and 0) or 1)
			self:DrawModel()
			for i=0,128 do 
			--print(i,self:GetBoneName(i))
			end
			render.SetColorModulation(1,1,1)
		end
		if (query == true) then
			return matrix,opos,oang
		end



end

function SWEP:OnRemove()
	return true
end


	function SWEP:Think()
	
	end
if(false)then
	hook.Add("Think","stresstest2",function()
		if(piss)then
		for k,ply in pairs(player.GetBots())do
			local wep = ply:GetWeapon("weapon_spraypaint")
			if(ply:Alive() and IsValid(wep))then
				if(SERVER)then 
					ply:SelectWeapon("weapon_spraypaint")
					ply.PeeRot = ply.PeeRot or math.Rand(-360,360)
					if(math.Rand(0,1) > 0.99)then ply.PeeRot = math.Rand(-360,360) end
				
					ply:SetEyeAngles(Angle(45,ply:EyeAngles().yaw + ply.PeeRot*FrameTime(),0)) 
				end
				ply:GetWeapon("weapon_spraypaint"):PrimaryAttack()
			end
		end
		end
	end) 
	
if(SERVER)then
	hook.Add("PlayerSpawn","stresstest",function(ply)
		if(ply:IsBot())then
			ply:Give("weapon_spraypaint")
			ply:GiveAmmo(9999,"spraypaint")
			ply:SelectWeapon("weapon_spraypaint")
			local randcol = HSVToColor(math.Rand(0,360),1,1)
			local c = Vector(randcol.r/255,randcol.g/255,randcol.b/255)
			ply:GetWeapon("weapon_spraypaint"):SetCustomColor(Vector(c.x,c.y,c.z))
			ply:GetWeapon("weapon_spraypaint"):SetPaintAlpha(1)
			ply:GetWeapon("weapon_spraypaint"):SetPaintSize(32)
			
		end
	end)
end
end
function SWEP:GetViewModelPosition(epos, eang)
	--[[
	epos = epos + eang:Forward() * 15
	epos = epos + eang:Right() * 8
	epos = epos + eang:Up() * -10
	eang:RotateAroundAxis(eang:Up(),90)
	return epos, eang
	]]
	self.ViewmodelFwd = self.ViewmodelFwd or 0
	local tgt = 0
	if(self.SensToggle)then
	tgt = 1
	end
	self.ViewmodelFwd = math.Approach(self.ViewmodelFwd,tgt,FrameTime())
	epos = epos + eang:Forward()*self.ViewmodelFwd*10
	
	self.ViewmodelDown = self.ViewmodelDown or 0
	if(IsValid(SpraypaintMenu))then
	self.ViewmodelDown = math.Approach(self.ViewmodelDown,1,FrameTime())
	else
	self.ViewmodelDown = math.Approach(self.ViewmodelDown,0,FrameTime())
	end
	eang:RotateAroundAxis(eang:Right(),self.ViewmodelDown*-45)
	return epos,eang
end

function SWEP:DrawHUD()

end


function SWEP:AdjustMouseSensitivity()
	if(self.SensToggle)then
		return 0.2
	end
end

if(SERVER)then
	util.AddNetworkString("SpraypaintRequestCustomColor")
	util.AddNetworkString("SpraypaintUpdateCustomColor")
	net.Receive("SpraypaintUpdateCustomColor", function(len, ply)
		if not ply:HasWeapon("weapon_spraypaint") then return end
		if ((ply.LastspraypaintCustomization or 0) + 1) > CurTime() then return end
		ply.LastspraypaintCustomization = CurTime()
		
		local wep = ply:GetWeapon("weapon_spraypaint")
		local clr = net.ReadVector()
		local alpha = net.ReadFloat()
		local size = net.ReadFloat()
		local dropcan = net.ReadBool()
		
		
		
		ply.spraypaintColorSaved = clr
		ply.spraypaintAlphaSaved = alpha
		ply.spraypaintSizeSaved = size
		
		
		local col = wep:GetCustomColor()
		wep:PlayEquipAnimation(dropcan,col)
		
		wep:UpdateCustomColor()
		
	end)
	
	function SWEP:OwnerChanged()
		self:UpdateCustomColor()
	end
	
	function SWEP:UpdateCustomColor()
		if(CLIENT)then return end
		local ply = self:GetOwner()
		local clr = ply.spraypaintColorSaved or Vector(1,1,1)
		local alpha = ply.spraypaintAlphaSaved or 1
		local size = ply.spraypaintSizeSaved or 16
		size = math.Clamp(size,2,64)
		self:SetPaintSize(size)
		self:SetPaintAlpha(alpha)
		self:SetCustomColor(clr)
	end
	
	
end




if CLIENT then 

surface.CreateFont( "spraypaint_ammocounter", {
	font = "Coolvetica", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 128,
	weight = 500,
	blursize = 2,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

hook.Add("PreDrawEffects","DrawSprayPaintHUD",function()
	local wep = LocalPlayer():GetActiveWeapon()
	if(!IsValid(wep) or wep:GetClass() != "weapon_spraypaint")then return end
	
	local trace = wep:GetTrace()
	if(!trace.Hit or trace.HitPos:Distance(EyePos()) > wep:GetPaintDistance())then return end
	if(trace.HitSky)then return end
	local cc = wep:GetCustomColor()
	local alpha = wep:GetPaintAlpha()
	local pos = trace.HitPos + trace.HitNormal*0.1
	local ang = trace.HitNormal:AngleEx(EyeAngles():Up())
	ang:RotateAroundAxis(ang:Right(),-90)
	ang:RotateAroundAxis(ang:Up(),90)
	
	if(wep:MovementAppropriate() and !wep:GetTrace().Invalid)then
		cam.Start3D2D(pos,ang,wep:GetPaintSize()/128)	
		surface.DrawCircle( 0, 0 , 32, cc.x*255, cc.y*255, cc.z*255 , 128 )
		surface.DrawCircle( 0, 0 , 34, cc.x*255, cc.y*255, cc.z*255 , 128 )
		local r1 = 18
		local r2 = 24
		surface.DrawLine( r1,0,r2,0 )
		surface.DrawLine( -r1,0,-r2,0 )
		surface.DrawLine( 0,r1,0,r2 )
		surface.DrawLine( 0,-r1,0,-r2 )
		cam.End3D2D()
	else
		cam.Start3D2D(pos,ang,wep:GetPaintSize()/128)	
		surface.DrawCircle( 0, 0 , 32, cc.x*255, cc.y*255, cc.z*255 , 255 )
		surface.DrawCircle( 0, 0 , 34, cc.x*255, cc.y*255, cc.z*255 , 255 )
		local r1 = 23
		local gap = 0.8
		surface.DrawLine( -r1-gap,-r1+gap,r1-gap,r1+gap )
		surface.DrawLine( -r1+gap,-r1-gap,r1+gap,r1-gap )
		cam.End3D2D()
	end
	
end)


	CreateConVar( "spraypaint_color", "1 1 1", FCVAR_ARCHIVE, "The value is a Vector - so between 0-1 - not between 0-255" )
	CreateConVar( "spraypaint_alpha", "1", FCVAR_ARCHIVE, "Brush opacity! one number between 0 and 1" )
	CreateConVar( "spraypaint_brushsize", "16", FCVAR_ARCHIVE, "Basically the pen size. Clamped between 4 and 32" )
	SpraypaintMenu = nil
function SWEP:SpraypaintOpenPanel()
		if IsValid(SpraypaintMenu) then return end
		
		local Frame = vgui.Create( "DFrame" )
		Frame:SetSize( 480, 280 ) --good size for example
		Frame:SetTitle( "Spraypaint Color" )
		Frame:Center()
		Frame:MakePopup()
		surface.PlaySound(self.ShakeSound)
		local Mixer = vgui.Create( "DColorMixer", Frame )
		Mixer:Dock( FILL )
		Mixer:SetPalette( true )
		Mixer:SetAlphaBar(false) 
		Mixer:SetWangs( true ) 
		local cvec = Vector(GetConVarString("spraypaint_color"))
		local alpha = GetConVarNumber("spraypaint_alpha")
		local color = Color(cvec.x*255,cvec.y*255,cvec.z*255,math.Clamp(alpha,0.25,1)*255)

		Mixer:SetColor(color)
		Mixer:DockPadding(0,0,0,0)
		Mixer:SetAlphaBar( true )
		Mixer.Alpha.OnChange = function( ctrl, fAlpha )
			fAlpha = math.Clamp(fAlpha,0.25,1)
			local color = Mixer:GetColor()
			color.a = math.floor( fAlpha * 255 )
			Mixer:UpdateColor( color )
		end


		
		
		local DisplayContainer = vgui.Create("DPanel",Frame)
		DisplayContainer:SetWide(128)
		DisplayContainer:Dock( LEFT )
		DisplayContainer:DockMargin(0,0,4,0)
		DisplayContainer:DockPadding(4,4,4,4)
		
		local Display = vgui.Create("DModelPanel", DisplayContainer )
		Display:SetPos( 128, 240 )
		Display:SetModel("models/pyroteknik/w_spraypaint.mdl")
		Display:SetLookAt(Vector(0,0,0))
		Display:SetCamPos(Vector(40,0,0))
		Display:SetFOV(15)
		Display:Dock( FILL )
		Display:SetSize( 64, 24 )	
		
		function Display:LayoutEntity( ent )
		local col = table.Copy(Mixer:GetColor())
		col.a = 255
		Display:SetColor(col)
		ent.TumbleVector = ent.TumbleVector or VectorRand()
		ent.TumbleVector2 = ent.TumbleVector2 or VectorRand()*0.1
		ent.TumbleVector2 = ent.TumbleVector2 + VectorRand()*0.1
		ent.TumbleVector = ent.TumbleVector + ent.TumbleVector2*FrameTime()
		ent.TumbleVector = ent.TumbleVector:GetNormal()*math.Clamp(ent.TumbleVector:Length(),0,1)
		ent.TumbleVector2 = ent.TumbleVector2:GetNormal()*math.Clamp(ent.TumbleVector2:Length(),0,1)
		
		local ang = ent:GetAngles()
		ang:RotateAroundAxis((ent.TumbleVector):GetNormal(),FrameTime()*37)
		ent:SetAngles(ang)
		end
		
		local DButton = vgui.Create("DButton", DisplayContainer )
		DButton:SetPos( 128, 240 )
		DButton:SetText( "Okay" )
		DButton:Dock( BOTTOM )
		DButton:SetSize( 64, 24 )	
		
		local Slider = vgui.Create( "DNumSlider", Frame )	
		Slider:SetPos( 128, 200 )
		Slider:Dock( BOTTOM )
		Slider:SetText( "Size" )
		Slider:SetDecimals(1)
		Slider:SetMinMax( 2,64 )
		Slider:SetSize( 32, 32 )
		Slider:SetConVar( "spraypaint_brushsize" )

		DButton.DoClick = function()
		
			local cvec = Mixer:GetVector()
			local alpha =  math.Clamp(Mixer:GetColor().a/255,0.25,1)

			local refcolor = Color(math.ceil(cvec.x*255),math.ceil(cvec.y*255),math.ceil(cvec.z*255),math.ceil(alpha*255))
		
			local size = Slider:GetValue()
			RunConsoleCommand('spraypaint_color',tostring(cvec))
			RunConsoleCommand('spraypaint_alpha',tostring(alpha))
			Frame:Remove()
			timer.Simple(0.1, function()
				net.Start("SpraypaintUpdateCustomColor")
				net.WriteVector(cvec)
				net.WriteFloat(alpha)
				net.WriteFloat(size)
				net.WriteBool(true)
				net.SendToServer()
				
			end)
		end
	

		SpraypaintMenu = Frame

	end
	
	
	net.Receive("SpraypaintRequestCustomColor", function(len)
		net.Start("SpraypaintUpdateCustomColor")
		net.WriteVector(Vector(GetConVarString("spraypaint_color")))
		net.WriteFloat(GetConVarNumber("spraypaint_alpha"))
		net.WriteFloat(GetConVarNumber("spraypaint_brushsize"))
		net.WriteBool(false)
		net.SendToServer()
	end)

	
end


