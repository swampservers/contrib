-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

AddCSLuaFile()
DEFINE_BASECLASS( "prop_trash" )

ENT.Spawnable			= false

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.CanChangeTrashOwner = false

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self, true )
	self:NetworkVar("String", 1, "TheaterName")
	self:NetworkVar("Int", 0, "MobileLocationIndex")
end

function ENT:Initialize()
	BaseClass.Initialize( self, true )

	if SERVER then
		self:SetMobileLocationIndex(0)
		self:SetTheaterName("MOBILETHEATER "..self:GetOwnerID())
		self.Shots = 6
		self:FindTheaterName()
	end
end

function ENT:Draw()
	local realmodel = self:GetModel()
	if realmodel == "models/hunter/plates/plate1x2.mdl" then
		self:SetModel("models/props_phx/rt_screen.mdl")
		local oldpos = self:GetPos()
		local oldang = self:GetAngles()
		local wpos, wang = LocalToWorld(Vector(26,0,-3), Angle(-90,0,0), oldpos, oldang)
		self:SetPos(wpos)
		self:SetAngles(wang)
		self:SetModelScale(1.36)
		self:SetupBones()
		BaseClass.Draw( self, true )
		self:SetModelScale(1)
		self:SetPos(oldpos)
		self:SetAngles(oldang)
		self:SetModel(realmodel)
	else
		BaseClass.Draw( self, true )
	end
	TrashDrawProtectionOutlines(self)
end

function ENT:DrawTranslucent()
	if PropTrashLookedAt == self then 
		render.CullMode(MATERIAL_CULLMODE_CW)
		render.SetColorMaterial()
		local col = self:GetTaped() and Color( 128, 255, 255, 60 ) or Color( 255, 255, 255, 20 )
		render.DrawBox( Vector(0,0,0), Angle(0,0,0), self:GetAreaMin(), self:GetAreaMax(), col, false )
		render.CullMode(MATERIAL_CULLMODE_CCW)
	end
end

TrashMobileTheaterData = {
["models/props_c17/tv_monitor01.mdl"] = {
	distance = 50,
	cubesize = 125,
	tpos = Vector(7,-9,5),
	tang = Angle(0,90,0),
	tw = 16*0.95,
	th = 9*0.95
},
["models/props_phx/rt_screen.mdl"] = {
	distance = 100,
	cubesize = 250,
	tpos = Vector(6.16,-28,35),
	tang = Angle(0,90,0),
	tw = 56,
	th = 31.5
},
["models/hunter/plates/plate1x2.mdl"] = {
	distance = 150,
	cubesize = 350,
	tpos = Vector(-21.1,-28*1.36,5.5),
	tang = Angle(0,90,-90),
	tw = 56*1.36,
	th = 31.5*1.36
}
}

function ENT:GetAreaMin()
	local cs = TrashMobileTheaterData[self:GetModel()].cubesize
	return self:GetPos() + (((self:GetModel() == "models/hunter/plates/plate1x2.mdl") and self:GetUp() or self:GetForward()) * TrashMobileTheaterData[self:GetModel()].distance) - Vector(cs/2,cs/2,cs/2)
end

function ENT:GetAreaMax()
	local cs = TrashMobileTheaterData[self:GetModel()].cubesize
	return self:GetAreaMin() + Vector(cs,cs,cs)
end

function ENT:Think()
	local t = self:GetTaped()
	self.LastMobileLocationIndex = self.LastMobileLocationIndex or 0
	if self.LastMobileLocationIndex ~= self:GetMobileLocationIndex() then		
		if self:GetMobileLocationIndex() > 0 then
			self:CreateTheater(self:GetMobileLocationIndex())
		else
			self:DestroyTheater()
		end
		self.LastMobileLocationIndex = self:GetMobileLocationIndex()
	end
	self:NextThink(CurTime()+0.1)
	return true
end

function ENT:CreateTheater(i)
	local li = Location.MobileLocations[i]
	local l = Location.GetLocationByIndex(li)
		
	l.Min = self:GetAreaMin()
	l.Max = self:GetAreaMax()

	l.Name = self:GetTheaterName()

	l.Theater.Width = TrashMobileTheaterData[self:GetModel()].tw
	l.Theater.Height = TrashMobileTheaterData[self:GetModel()].th

	local tpos, tang = LocalToWorld(TrashMobileTheaterData[self:GetModel()].tpos, TrashMobileTheaterData[self:GetModel()].tang, self:GetPos(), self:GetAngles())

	l.Theater.Pos = tpos
	l.Theater.Ang = tang
	l.Theater.PermanentOwnerID = self:GetOwnerID()

	local t = theater.GetByLocation(li)
	if t then 
		t._Name = l.Name
		if SERVER then
			t._OriginalName = t._Name
		end
		t._Pos = l.Theater.Pos
		t._Ang = l.Theater.Ang
		t._Width = l.Theater.Width * 10
		t._Height = l.Theater.Height * 10
		t._PermanentOwnerID = l.Theater.PermanentOwnerID
	end

	Location.RefreshPositions()
end

function ENT:DestroyTheater()
	local i = self:GetMobileLocationIndex()
	if i==0 then i=(self.LastMobileLocationIndex or 0) end
	if i>0 then
		local li = Location.MobileLocations[i]
		local l = Location.GetLocationByIndex(li)
		l.Min = Vector(-1,-1,-10001)
		l.Max = Vector(1,1,-10000)

		Location.RefreshPositions()
	end
end

function ENT:OnRemove()
	self:DestroyTheater()
end

function ENT:CanTape(userid)
	return self:GetPos():Distance(Vector(0,-1152,0))>900 and TrashCanTapeProtectionTest(self, userid) and BaseClass.CanTape(self, userid)
end

function ENT:ProtectsIfTaped(other)
	return other:GetPos():WithinAABox(self:GetAreaMin(),self:GetAreaMax())
end

function ENT:ProtectsPoint(pos)
	return self:GetTaped() and pos:WithinAABox(self:GetAreaMin(),self:GetAreaMax())
end

function ENT:Protects(other)
	return self:GetTaped() and self:ProtectsIfTaped(other)
end
