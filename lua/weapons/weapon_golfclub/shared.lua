GolfPrizeTargets = {
["Cheap tricks"] = {
	{ 2, 10000 },
	{ 3, 2000 }
},
["Updog"] = {
	{ 1, 2000 }
},
["Conveyor"] = {
	{ 2, 6200 },
	{ 3, 1000 }
},
["Chasm"] = {
	{ 2, 5000 },
	{ 4, 1000 }
},
["Elevator"] = {
	{ 1, 5000 },
	{ 2, 2000 }
},
["Twirlies"] = {
	{ 1, 40000 },
	{ 3, 6000 }
},
["Blindmans cave"] = {
	{ 3, 80000 },
	{ 5, 5000 }
},
["Hopscotch islands"] = {
	{ 1, 10000 },
	{ 4, 4000 }
},
["Boundary swap"] = {
	{ 1, 19000 },
	{ 3, 3000 }
},
["Reset roundabout"] = {
	{ 1, 16000 },
	{ 3, 1000 }
},
["House on a hill"] = {
	{ 3, 15000 }
},
["Gears"] = {
	{ 1, 12000 },
	{ 3, 3000 }
},
["Srsly2hard4u"] = {
	{ 0, 0 }
},
["Big hole"] = {
	{ 1, 20000 },
	{ 2, 2000 },
},
["The easy one"] = {
	{ 1, 100 }
},
["The windmill"] = {
	{ 1, 500 }
},
["U bend"] = {
	{ 1, 2000 }
},
["The eight game"] = {
	{ 1, 1600 },
	{ 2, 800 }
},
["Frustration hill"] = {
	{ 1, 1500 }
},
["Curved bridge"] = {
	{ 1, 1000 }
},
["The moon"] = {
	{ 1, 1969 }
},
["The loop"] = {
	{ 1, 3000 },
	{ 2, 500 }
},
["Border crossing"] = {
	{ 1, 2020 }
},
["Minge world"] = {
	{ 1, 8000 },
	{ 2, 1000 }
},
["L pond"] = {
	{ 1, 18000 },
	{ 2, 1000 }
},
["Anger bridge"] = {
	{ 1, 13000 },
	{ 2, 1000 }
},
}



if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end



	SWEP.PrintName			= "Golf Club"
	SWEP.Author				= "Swamp & PYROTEKNIK"
	SWEP.ViewModel      = "models/pyroteknik/putter.mdl"
	SWEP.WorldModel   = "models/pyroteknik/putter.mdl"
	SWEP.Slot				= 0
	SWEP.ViewModelFOV		= 62



SWEP.Instructions = "Left/right click: place, hit ball\nReload: retry hole"


function SWEP:DrawWorldModel()

	local ply = self:GetOwner()

	if(IsValid(ply))then

		local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_L_Hand"
		local bon = ply:LookupBone(bn) or 0

		local opos = self:GetPos()
		local oang = self:GetAngles()
		local bp,ba = ply:GetBonePosition(bon)
		if(bp)then opos = bp end
		if(ba)then oang = ba end
		if ply:IsPony() then
			oang:RotateAroundAxis(oang:Up(),-90)
			opos = opos + (oang:Up()*-9) + (oang:Right()*-6.7) + (oang:Forward()*-1.9)
		else
			oang:RotateAroundAxis(oang:Up(),150)
			oang:RotateAroundAxis(oang:Forward(),25)
			oang:RotateAroundAxis(oang:Right(),30)
			opos = opos + oang:Forward()*-2.6 + oang:Right()*0 + oang:Up()*-10
		end
		self:SetupBones()

		--self:SetModelScale(0.8,0)
		local mrt = self:GetBoneMatrix(0)
		if(mrt)then
		mrt:SetTranslation(opos)
		mrt:SetAngles(oang)

		self:SetBoneMatrix(0, mrt )
		end
	end

	self:DrawModel()

end

GolfClubPositionLerp = 0

function SWEP:GetViewModelPosition( pos, ang )
	if self:GetHoldType()=="passive" then
		GolfClubPositionLerp = math.min(1,GolfClubPositionLerp+(FrameTime()*0.5))
	else
		GolfClubPositionLerp = math.max(0,GolfClubPositionLerp-(FrameTime()*2))
	end

	pos = pos + ang:Right()*7 + ang:Up()*-20  + ang:Forward()*15
	local oang = Angle()
	oang:Set(ang)
	ang:RotateAroundAxis(oang:Up(),90)
	ang:RotateAroundAxis(oang:Forward(),10)
	ang:RotateAroundAxis(oang:Right(),-30+(-100*GolfClubPositionLerp))

	return pos, ang 
end




function SWEP:SetupDataTables()

	self:NetworkVar( "Int", 0, "ShootStage" )
	self:NetworkVar( "Int", 1, "CurrentStroke" )
	self:NetworkVar( "Entity", 0, "BallToShoot" )
	self:NetworkVar( "Vector", 0, "ShotPos" )
	self:NetworkVar( "Entity", 1, "BallOwner" )
end
function SWEP:Think() -- Called every frame
local ht = "normal"
local stage = self:GetShootStage()
if(stage == 1)then ht = "normal" end
if(stage == 2)then ht = "passive" end

if(ht != self:GetHoldType())then
self:SetHoldType(ht)
end
if(SERVER)then

if(self:Clip1() > 0 and stage != 0)then
self:SetShootStage(0)
end
if(stage == 1)then

		local fball = self.ActiveBall
		--[[
			for k,v in pairs(ents.FindByClass("golfball"))do
				if( v.Owner == self:GetOwner())then
					fball = v
				end
			end ]]
	
		if(IsValid(fball))then
			if(!fball:GetPhysicsObject():IsMotionEnabled())then
				self:SetBallToShoot(fball)
				self:SetShootStage(2) 
				
			else
	
			end
		end





end

end


end

function SWEP:Reload()
if(SERVER)then
if IsValid(self.ActiveBall) then

	--timing glitch
	if self.ActiveBall.FineHole then return end

	self:SetClip1(1)
	self:FailStroke("hole",true)

	self.ActiveBall:Remove()
	self.ActiveBall = nil
end



end

end

function SWEP:SecondaryAttack()
self:PrimaryAttack()
end
function SWEP:PrimaryAttack()
local stage = self:GetShootStage()
	local newstage = stage+1
	local can = false
	local trace = self:GetOwner():GetEyeTrace()
	if(stage == 2)then
	self:GetOwner():SetAnimation( PLAYER_ATTACK1)
	end
	if(SERVER)then
	
	if(newstage > 2)then newstage = 1 end
	
		if(stage == 0)then
			if self.CantPlaceBall then return end

			local spoint = nil
			
			for k,v in pairs(ents.FindInSphere( trace.HitPos, 16 ))do
				if(v:GetClass() == "info_target" and v:GetName() == "ball_place_spot")then
				spoint = v:GetPos()
				end
				
			end
			if(spoint != nil and !IsValid(self.ActiveBall))then
			can = true
			local ball = ents.Create("golfball")
			ball:SetPos(spoint+Vector(0,0,-2))
			if spoint:Distance(Vector(5587,1638,-3210)) < 1 then ball.NoBounds=true end
			ball.Owner = self:GetOwner()
			ball:Spawn()
			ball:SetNWEntity("BallOwner",self:GetOwner())
			local c = self.Owner:GetPlayerColor()*255 
			local h,s = ColorToHSV(Color(c.x,c.y,c.z)) 
			c = HSVToColor(h,s,1)
			ball:SetColor(c)
			self:SetCurrentStroke(0)
			self:SetClip1(0)
			self.ActiveBall = ball
			else
			self:GetOwner():ChatPrint("Cannot place ball here!")
			end
			
			
		end
	
	

	
	
	if(stage == 2 and IsValid(self:GetBallToShoot()) and !self:GetBallToShoot():GetPhysicsObject():IsMotionEnabled())then
	local ball = self:GetBallToShoot()
	local p1= util.IntersectRayWithPlane( self:GetOwner():EyePos(),self:GetOwner():EyeAngles():Forward(), ball:GetPos(),Vector(0,0,1) )
	local p2 = ball:GetPos()
	if(p1 == nil)then p1 = p2 end 
	
	local medist = self:GetOwner():EyePos():Distance(ball:GetPos())
		
	if(p1:Distance(p2) > 200)then
			p1 = (p1-p2)
			p1 = p2 + (p1:GetNormalized()*200)
			end
	
	
	local dist = math.Clamp(p1:Distance(p2),0,200)
	
	if(medist < 150 and p1:Distance(p2) > 3)then
	can = true
	local tarvec = p1
	tarvec.z = ball:GetPos().z
	local ballvec = ball:GetPos()
	ball:StartShot()
	ball:GetPhysicsObject():ApplyForceCenter((tarvec - ballvec)* 100)
	local strk = self:GetCurrentStroke()
	self:SetCurrentStroke(strk+1)
	else
	can = false
	end
	
	
	
	
	
	end
	
	
	
		if(can)then
		
			self:SetShootStage(newstage)
		
		end
	end
self:SetNextPrimaryFire(CurTime()+0.125)
self:SetNextSecondaryFire(CurTime()+0.125)
return true
end
function SWEP:FinishStroke(hole)
	local joke = (hole=="Srsly2hard4u")
local strk = self:GetCurrentStroke()
if(hole)then
local endm = strk.." strokes!"

local snd = "hl1/fvox/bell.wav"
if(strk == 1)then
endm = "a Hole-in-One!"
//snd = "skull-trumpet.wav"
end
self:GetOwner():EmitSound(snd)
if joke then
	local vd = self.Owner:GetPos()
	timer.Simple(0.4, function() sound.Play("golfmines/amazing.wav", vd, 70, 100, 1) end)
	self.CantPlaceBall = true
	timer.Simple(7,function() if IsValid(self) then self.CantPlaceBall=false end end)
end
local record = 10
if SERVER then
	record = tonumber(self:GetOwner():GetPData("golf_"..hole, 10))
	if strk<record then
		self:GetOwner():SetPData("golf_"..hole, tostring(strk))
	end
end
if !joke then GolfNotify("[yellow]"..self:GetOwner():Nick() .." completed hole '"..hole.. "' with "..endm) end
if SERVER then
	local iwonsomething = false
	if strk<record then
		local strokes = " strokes"
		if strk==1 then strokes = " stroke" end
		self:GetOwner():PrintMessage( HUD_PRINTTALK, "[red]You beat your record! New record: [orange]"..tostring(strk)..strokes )
		local t = GolfPrizeTargets[hole]
		if t then
			for k,v in pairs(t) do
				if record > v[1] and strk <= v[1] then
					if self:GetOwner().familyshared then
						self:GetOwner():PrintMessage( HUD_PRINTTALK, "[red]Sorry, you're not eligible for this prize ;hahaha;" )
					else
						self:GetOwner():PrintMessage( HUD_PRINTTALK, "[red]Congratulations! You won [gold]"..tostring(v[2]).." points!" )
						self:GetOwner():PS_GivePoints(v[2])
					end
					iwonsomething = true
				end
			end
		end
	else
		local strokes = " strokes"
		if record==1 then strokes = " stroke" end
		self:GetOwner():PrintMessage( HUD_PRINTTALK, "[red]Your record for this hole is: [orange]"..tostring(record)..strokes )
	end
	local t = GolfPrizeTargets[hole]
	if t then
		local got = math.min(strk,record)
		local nex = nil
		for k,v in pairs(t) do
			if got > v[1] then
			if nex == nil or nex[1]<v[1] then
				nex = v
			end
			end
		end
		if nex == nil then
			if iwonsomething==false then
				self:GetOwner():PrintMessage(HUD_PRINTTALK, "[red]You've claimed all the prizes for this hole!")
			end
		else
			local strokes = " strokes"
			if nex[1]==1 then strokes = " stroke" end
			self:GetOwner():PrintMessage(HUD_PRINTTALK, "[red]Beat this hole in [orange]"..tostring(nex[1])..strokes.."[red] to win [gold]"..tostring(nex[2]).." points!")
		end
	end
end
end
self:SetCurrentStroke(0)
end

function SWEP:FailStroke(hole,nan)
local strk = self:GetCurrentStroke()

local snd = "hl1/fvox/bell.wav"
self:GetOwner():EmitSound(snd,100,75)
if nan then else
GolfNotify(self:GetOwner():Nick() .." Failed Hole")
end

self:SetCurrentStroke(0)
end

 
function SWEP:Deploy()
self:SetHoldType("normal")
return true;
end

function SWEP:Holster()
	self:Reload()
return true;
end

local function makeCircle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is need for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end


function GolfNotify(text)
if(SERVER)then
for k,v in pairs(player.GetAll())do
if(v:HasWeapon("weapon_golfclub"))then
v:ChatPrint(text)
end
end
end
end

function SWEP:DrawHUD()
local stage = self:GetShootStage()
local strk = self:GetCurrentStroke()

	if(IsValid(self:GetBallToShoot()))then
	cam.Start3D()
	local ball = self:GetBallToShoot()
	local trace = LocalPlayer():GetEyeTrace()
	local p1= util.IntersectRayWithPlane( EyePos(),EyeAngles():Forward(), ball:GetPos(),Vector(0,0,1) )
	
	local p2 = ball:GetPos()
		if(p1 == nil)then p1 = p2 end 
	
		if(p1:Distance(p2) > 200)then
			p1 = (p1-p2)
			p1 = p2 + (p1:GetNormalized()*200)
			end
	local dist = p1:Distance(p2)	
	
	local cpos = p1
	local bpos =	ball:GetPos() + Vector(-5,5,0)
	local pos = trace.HitPos
	//pos.z = ball:GetPos().z
	local angle = Angle(0,0,0)
	local a2 = Angle(0,0,0)
	a2:RotateAroundAxis( Vector(0,0,1), math.deg(math.atan2(  p2.x-p1.x, p1.y-p2.y )) )

	local tv = Vector(-5,5,0)
	tv:Rotate(a2)
	if(stage == 2) then
		cam.Start3D2D( cpos + tv, a2, 1 )
		local c = HSVToColor(120 - ((dist/200)*120),1,1)
		surface.SetDrawColor( c.r, c.g, c.b, 100 )
		draw.NoTexture()

			local off=5
			local cir = {}
			table.insert( cir, { x = off, y = off-1, u = 0.5, v = 0.5 } )
			table.insert( cir, { x = off+2, y = 5+off-3, u = 0.5, v = 0.5 } )
			table.insert( cir, { x = off-2, y = 5+off-3, u = 0.5, v = 0.5 } )
			surface.DrawPoly( cir )
			if dist>4.5 then


			cir = {}
			table.insert( cir, { x = off-1, y = 5+off-3, u = 0, v = 1 } )
			table.insert( cir, { x = off+1, y = dist+off-2.5, u = 1, v = 0 } )
			table.insert( cir, { x = off-1, y = dist+off-2.5, u = 1, v = 1 } )
			surface.DrawPoly( cir )
			cir = {}
			table.insert( cir, { x = off+1, y = 5+off-3, u = 0, v = 1 } )
			table.insert( cir, { x = off+1, y = dist+off-2.5, u = 1, v = 0 } )
			table.insert( cir, { x = off-1, y = 5+off-3, u = 1, v = 1 } )
			surface.DrawPoly( cir )
				
			end

		cam.End3D2D()
	end

	
		local ball = self:GetBallToShoot()
			local trc = {}
		trc.start = EyePos()
		trc.endpos = ball:GetPos()
		trc.filter = LocalPlayer()
		local seetrace = util.TraceLine(trc)
		if(seetrace.Entity != ball)then
			cam.Start3D2D( bpos, angle, 1 )
			local c = ball:GetColor()
			surface.SetDrawColor( 128,128,128, 255 )
			draw.NoTexture()
			makeCircle(5,5, 2.5,32 )
			surface.SetDrawColor( c.r, c.g, c.b, 255 )
			draw.NoTexture()
			makeCircle(5,5, 2,32 )

		cam.End3D2D()
		end
		


		
		
	cam.End3D()
	end
	

	
	if(stage == 0)then
	cam.Start3D()
	
	local trace = LocalPlayer():GetEyeTrace()
	local cpos = trace.HitPos + Vector(-6,6,0)
	
	local pos = trace.HitPos
	//pos.z = ball:GetPos().z
	local angle = Angle(0,0,0)
	
		cam.Start3D2D( cpos, angle, 1 )
		
			surface.SetDrawColor( 0, 0, 0, 200 )
			draw.NoTexture()
			makeCircle(6,6, 3,32 )
			local c = self.Owner:GetPlayerColor()*255 
			local h,s = ColorToHSV(Color(c.x,c.y,c.z)) 
			c = HSVToColor(h,s,1)
			surface.SetDrawColor( c.r, c.g, c.b, 200 )
			draw.NoTexture()
			makeCircle(6,6, 2.75,32 )

		cam.End3D2D()


		
		
		
	cam.End3D()
	end
		local stg = "Place the ball"
		local clr = Color(255,255,255)
		local fnd=false
		local rdy = nil
		if(stage ==1)then
			for k,v in pairs(ents.FindByClass("golfball"))do
			if(v:GetNWEntity("BallOwner") == LocalPlayer())then
			fnd=true
			if(v:GetNWBool("shootable"))then
			rdy = true
			else
			rdy = false
			end
	
			end
			end
		if(fnd and rdy)then
		stg = "Click anywhere to start shot" 
		else
		stg = "Ball is moving..." 
		end
		end

		if(stage == 2 and IsValid(self:GetBallToShoot()))then
		
		
		local trace = LocalPlayer():GetEyeTrace()
		local ball = self:GetBallToShoot()
		
		local p1= util.IntersectRayWithPlane( EyePos(),EyeAngles():Forward(), ball:GetPos(),Vector(0,0,1) )
		local medist = LocalPlayer():EyePos():Distance(ball:GetPos())
		
		//local p1 = trace.HitPos
			local p2 = ball:GetPos()
			if(p1 == nil)then p1 = p2 end 
	
			if(p1:Distance(p2) > 200)then
			p1 = (p1-p2)
			p1 = p2 + (p1:GetNormalized()*200)
			end
			
			
			local dist = math.Clamp(p1:Distance(p2),0,200)
			
			
			
			
			stg = "Power: "..math.ceil(dist/2) .. "%" 
			clr = HSVToColor(120 - ((dist/200)*120),1,1)
			if(medist > 150)then
			stg = "Move closer to the ball"
			clr = Color(255,0,0,255)
			end
		
		end
	
	local clr2 = Color(255,255,255,255)
	local strom = strk.." Stroke"
	if(strk > 1)then strom = strom.."s" end
	if(strk == 0)then strom = "" end
	if(strk == 8)then clr2 = Color(255,255,0,255) end
	if(strk == 9)then clr2 = Color(255,100,0,255) end
	
	if(strk == 10)then
	clr2 = Color(255,0,0,255)
	strom = "Final Stroke!"
	end
	
	
	
	
		local bw,bh = 384,64
	local marg = 8
	local mix,miy = ScrW() - bw/2 - marg, ScrH() - bh/2 - marg
	draw.RoundedBox( 8, ScrW()-bw - marg, ScrH()-bh - marg, bw, bh, Color(25,25,25,200) )
	if(stage == 0 or strom == "")then
	draw.SimpleText(stg, "Trebuchet24", mix, miy, clr, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	else
	draw.SimpleText(strom, "Trebuchet24", mix, miy-16, clr2, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	draw.SimpleText(stg, "Trebuchet24", mix, miy+16, clr, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	
	
end

function SWEP:CustomAmmoDisplay()

end
if(CLIENT)then
--[[ hook.Add( "PreDrawHalos", "GolfHalo", function()

	for k,v in pairs(ents.FindByClass("golfball"))do
	if(v:GetNWEntity("BallOwner") == LocalPlayer())then
	
	if(v:GetNWBool("shootable"))then
	halo.Add( {v}, Color( 100, 255, 100 ), 2, 2, 2 )
	else
	halo.Add( {v}, Color( 255, 100, 100 ), 2, 2, 2 )
	end
	
	end
	end
	
end ) ]]--
end

-------------------------------------------------------------------
SWEP.Author   = "PYROTEKNIK"
SWEP.Contact        = ""
SWEP.Purpose        = "Hit the thing with it"
SWEP.Instructions   = ""
SWEP.Spawnable      = true
SWEP.AdminSpawnable  = true

-----------------------------------------------
SWEP.Primary.Delay		= 0.3
SWEP.Primary.Recoil		= 0
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 1		
SWEP.Primary.Cone		= 0
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic   	= false
SWEP.Primary.Ammo         	= "none" 
-------------------------------------------------
SWEP.Secondary.Delay			= 60.999999999
SWEP.Secondary.Recoil			= 0
SWEP.Secondary.Damage			= 1
SWEP.Secondary.NumShots			= 1
SWEP.Secondary.Cone				= 0
SWEP.Secondary.ClipSize			= 1
SWEP.Secondary.DefaultClip		= 1
SWEP.Secondary.Automatic   		= false
SWEP.Secondary.Ammo         		= "none"
-------------------------------------------------