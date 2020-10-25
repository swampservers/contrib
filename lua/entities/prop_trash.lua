-- This file is subject to copyright - contact swampservers@gmail.com for more information.

-- shared globals for building system
TRASHLOC_BUILD = 1
TRASHLOC_NOBUILD = 2
TRASHLOC_NOSPAWN = 3

TRASHACT_TAPE = 1
TRASHACT_UNTAPE = 2
TRASHACT_REMOVE = 3
TRASHACT_PAINT = 4
TRASHACT_UNPAINT = 5

TrashLocationOverrides = {
	['Vapor Lounge']=TRASHLOC_BUILD,
	['Furnace']=TRASHLOC_NOSPAWN,
	['AFK Corral']=TRASHLOC_BUILD,
	['Reddit']=TRASHLOC_BUILD,
	['Maintenance Room']=TRASHLOC_BUILD,
	['Rat\'s Lair']=TRASHLOC_BUILD,
	['Sewer Theater']=TRASHLOC_BUILD,
	['Moon Base']=TRASHLOC_BUILD,
	['Office of the Vice President']=TRASHLOC_BUILD,
	['Situation Monitoring Room']=TRASHLOC_BUILD,
	['Stairwell']=TRASHLOC_NOSPAWN,
	['Elevator Shaft']=TRASHLOC_NOSPAWN,
	['Trump Lobby']=TRASHLOC_BUILD,
	['SushiTheater']=TRASHLOC_NOSPAWN,
	['SushiTheater Basement']=TRASHLOC_NOSPAWN,
	['SushiTheater Second Floor']=TRASHLOC_NOSPAWN,
	['SushiTheater Attic']=TRASHLOC_BUILD,
	['Auditorium']=TRASHLOC_BUILD,
	['The Pit']=TRASHLOC_BUILD,
	['Control Room']=TRASHLOC_BUILD,
	['Cemetery']=TRASHLOC_BUILD,
	['Power Plant']=TRASHLOC_BUILD,
	['The Underworld']=TRASHLOC_BUILD,
	['Void']=TRASHLOC_BUILD,
	['The Box']=TRASHLOC_BUILD,
	['Throne Room']=TRASHLOC_BUILD,
	['Trump Tower']=TRASHLOC_BUILD,
	['SportZone']=TRASHLOC_BUILD,
	['Gym']=TRASHLOC_BUILD,
	['Locker Room']=TRASHLOC_BUILD,
	['Janitor\'s Closet']=TRASHLOC_BUILD,
	['Outdoor Pool']=TRASHLOC_BUILD,
	['Golf']=TRASHLOC_NOSPAWN,
	['Minecraft']=TRASHLOC_BUILD,
	['Tree']=TRASHLOC_BUILD,
	['Shooting Range']=TRASHLOC_NOSPAWN,
	['Temple of Kek']=TRASHLOC_BUILD,
	['Labyrinth']=TRASHLOC_BUILD,
	['Moon']=TRASHLOC_BUILD,
	['Deep Space']=TRASHLOC_BUILD,
	['Potassium Palace']=TRASHLOC_BUILD,
	['Sewer Tunnels']=TRASHLOC_BUILD,
	['Outside']=TRASHLOC_BUILD,
	['Way Outside']=TRASHLOC_BUILD,
}

TrashNoFreezeNodes = {
	{Vector(-2040,-60,80),120},
	{Vector(-1970,-1120,100),150}
	--{Vector(660,-1860,36),100},
}

AddCSLuaFile()
DEFINE_BASECLASS("base_gmodentity")

ENT.Spawnable = false

ENT.CanChangeTrashOwner = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "OwnerID")
	self:NetworkVar("Bool", 0, "Taped")
end

PropTrashExplosiveModels = {
	["models/props_c17/oildrum001_explosive.mdl"] = true,
	["models/props_phx/oildrum001_explosive.mdl"] = true,
	["models/props_phx/ww2bomb.mdl"] = true
}

function ENT:Initialize()
	if SERVER then
		self:SetUseType(SIMPLE_USE)

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)

		self:UnTape()

		self.ProtectedPropShot = 0

		if PropTrashExplosiveModels[self:GetModel()] then
			self.OnShoot = function(this)
				this:Remove()
			end
			self.OnRemove = function()
				local effectdata = EffectData()
				effectdata:SetOrigin(self:GetPos())
		 		effectdata:SetMagnitude(0)
				util.Effect( "Explosion", effectdata, true, true )
				util.BlastDamage(self, self, self:GetPos(), 256, 80)
			end
		end
	end
end

local whitemat = Material("models/debug/debugwhite")

function ENT:DrawOutline()
	render.SuppressEngineLighting(true)
	render.MaterialOverride(whitemat)
	local sc = self:GetModelScale()
	local rad = self:BoundingRadius()
	self:SetModelScale(sc*(rad+0.2)/rad)
	render.CullMode(MATERIAL_CULLMODE_CW)
	self:SetupBones()
	self:DrawModel()
	render.CullMode(MATERIAL_CULLMODE_CCW)
	self:SetModelScale(sc)
	render.MaterialOverride()
	render.SuppressEngineLighting(false)
end

PropTrashLightData = {
	["models/props_interiors/furniture_lamp01a.mdl"] = {
		untaped = false,
		size = 500,
		brightness = 2,
		style = 0,
		pos = Vector(0,0,27)
	},
	["models/maxofs2d/light_tubular.mdl"] = {
		untaped = false,
		size = 300,
		brightness = 2,
		style = -1,
		pos = Vector(0,0,0)
	}
}

if CLIENT then
	function ENT:Think()
		local light = PropTrashLightData[self:GetModel()]
		if light and (self:GetTaped() or light.untaped) then
			if EyePos():Distance(self:GetPos()) > (self:GetPos().z>-48 and 1000 or 3000) then return end
			local dlight = DynamicLight(self:EntIndex())
			if dlight then
				dlight.pos = self:LocalToWorld(light.pos)
				dlight.r = self:GetColor().r
				dlight.g = self:GetColor().g
				dlight.b = self:GetColor().b
				dlight.brightness = light.brightness
				dlight.Size = light.size
				dlight.style = (light.style == -1) and self:EntIndex()%12 or light.style
				if light.dir then
					local d = Vector(0,0,0)
					d:Set(light.dir)
					d:Rotate(self:GetAngles())
					dlight.dir = d
					dlight.innerangle = light.innerangle
					dlight.outerangle = light.outerangle
				end
				dlight.Decay = 500
				dlight.DieTime = CurTime() + 1
			end
		end
	end
	if IsValid((self.UseTable or {})[1]) then
		(self.UseTable or {})[1]:ExitVehicle()
	end
end

function ENT:Draw()
	if PropTrashLookedAt == self then 
		local cr,cg,cb = render.GetColorModulation()
		local id = LocalPlayer():SteamID()
		render.SetColorModulation(1,0.5,0)
		if self:GetTaped() then
			if self:CanEdit(id) then
				render.SetColorModulation(0,1,1)
			end
		else
			if self:CanTape(id) then
				render.SetColorModulation(1,1,1)
			end
		end
		self:DrawOutline()
		render.SetColorModulation(cr,cg,cb)
	end
	if self:GetMaterial()=="phoenix_storms/gear" then
		local cr,cg,cb = render.GetColorModulation()
		render.SetColorModulation((cr*1.6)+0.3,(cg*1.6)+0.3,(cb*1.6)+0.3)
	end
	BaseClass.Draw(self) --, true)
end

function ENT:Use(ply)
	local seat = IsChairEntity(self)
	if seat then
		if self:IsUnTaped() then
			if ply:Crouching() then
				ply:Notify("Uncrouch+use to pick up the seat.")
				self.UpdateTime = CurTime()
				SitInSeat(ply, self, ply:EyePos())
				self:SetOwnerID(ply:SteamID())
			else
				if self:GetClass()=="prop_trash_wheelchair" and IsValid((self.UseTable or {})[1]) then
					ply:Notify("Too heavy!")
					return
				end
				ply:Notify("Crouch+use to sit in the seat.")
				ply:PickupObject(self)
			end
		else
			self.UpdateTime = CurTime()
			SitInSeat(ply, self, ply:EyePos())
		end
	elseif self:IsUnTaped() then
		ply:PickupObject(self)
	end
end

function ENT:Tape()
	self:GetPhysicsObject():EnableMotion(false)
	self:SetTaped(true)
	self.UpdateTime = CurTime()
end

function ENT:UnTape()
	self:GetPhysicsObject():EnableMotion(true)
	self:GetPhysicsObject():Wake()
	self:PhysWake()
	self:SetTaped(false)
	self.UpdateTime = CurTime()
end

function ENT:IsUnTaped()
	return !self:GetTaped()
end

function ENT:GetLocation()
	if (self.LastLocationCoords == nil) or (self:GetPos():DistToSqr(self.LastLocationCoords) > 1) then
		self.LastLocationCoords = self:GetPos()
		self.LastLocationIndex = Location.Find(self)
	end
	return self.LastLocationIndex
end

function ENT:GetLocationClass()
	local locid = self:GetLocation()
	local ln = Location.GetLocationNameByIndex(locid)
	if TrashLocationOverrides[ln] then
		return TrashLocationOverrides[ln]
	end
	local t = theater.GetByLocation(locid)
	if t then
		if t:IsPrivate() and !IsValid(t:GetOwner()) then
			return TRASHLOC_NOBUILD
		end
		return TRASHLOC_NOSPAWN
	end

	return TRASHLOC_NOBUILD
end

TrashFieldEntsCache = {}
TrashFieldEntsCacheTime = 0

function GetTrashFields()
	local it = TrashFieldEntsCache
	TrashFieldEntsCache = {}

	if TrashFieldEntsCacheTime + 0.2 < CurTime() then
		TrashFieldEntsCacheTime = CurTime()
		it = ents.GetAll()
	end

	-- Ensures invalid ents can't be returned from the cache
	for i,v in ipairs(it) do
		if IsValid(v) then
			local c = v:GetClass()
			if c=="prop_trash_field" or c=="prop_trash_theater" then
				table.insert(TrashFieldEntsCache, v)
			end
		end
	end

	return TrashFieldEntsCache
end

function ENT:GetLocationOwner()
	local class = self:GetLocationClass()
	local t = theater.GetByLocation(self:GetLocation())
	if t and t:IsPrivate() then
		if t._PermanentOwnerID then return t._PermanentOwnerID end
		if IsValid(t:GetOwner()) then return t:GetOwner():SteamID() end
	end

	if class ~= TRASHLOC_BUILD then return nil end --The only way to own a non build area is with a theater. Not a field.

	for k,v in ipairs(GetTrashFields()) do
		if IsValid(v) and v:Protects(self) then
			return v:GetOwnerID()
		end
	end
	return nil
end

--MIGHT BE A FILE RUN ORDER ISSUE
if HumanTeamName then
	function ENT:CanExist()
		return true
	end
else
	function ENT:CanExist()
		--local vec = self:GetPos()
		--vec.x = math.abs(vec.x)
		--if vec:DistToSqr(Vector(160,160,80)) < 65536 then return false end --theater enterance

		return not (self:GetLocationClass() == TRASHLOC_NOSPAWN and self:GetOwnerID() ~= self:GetLocationOwner())
	end
end

function ENT:CanEdit(userid)
	return (self:GetOwnerID() == userid) or (self:GetLocationOwner() == userid)
end

function ENT:CanTape(userid)
	if HumanTeamName~=nil then
		return self:CanEdit(userid)
	end
	for k,v in ipairs(TrashNoFreezeNodes) do
		if self:GetPos():Distance(v[1]) < v[2] then
			return false
		end
	end
	local lown = self:GetLocationOwner()
	return ((self:GetOwnerID() == userid) and (lown == nil) and (self:GetLocationClass() == TRASHLOC_BUILD)) or (lown == userid)
end

function ENT:OnShoot()
	if Safe(self) then
		self.ProtectedPropShot = self.ProtectedPropShot + 1
	end

	if self.ProtectedPropShot == 6 or not Safe(self) then
		self:UnTape()
	end
end
