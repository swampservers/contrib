
AddCSLuaFile()
DEFINE_BASECLASS( "prop_trash" )

ENT.Spawnable			= false

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.CanChangeTrashOwner = false

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self, true )
end

function ENT:Initialize()
	BaseClass.Initialize( self, true )
end

function ENT:Draw()
	BaseClass.Draw( self, true )
	TrashDrawProtectionOutlines(self)
end

TrashFieldModelToRadius = {
["models/maxofs2d/hover_classic.mdl"] = 200,
["models/dav0r/hoverball.mdl"] = 300
}

--also used by theater
function TrashDrawProtectionOutlines(self)
	if PropTrashLookedAt == self then 
		local cr,cg,cb = render.GetColorModulation()
		for k,v in pairs(ents.FindByClass("prop_trash*")) do
			if self:ProtectsIfTaped(v) then
				if v:GetOwnerID() == LocalPlayer():SteamID() then
					render.SetColorModulation(0,1,1)
				else
					render.SetColorModulation(1,0.5,0)
				end
				v:DrawOutline()
			end
		end
		render.SetColorModulation(cr,cg,cb)
	end
end

function ENT:DrawTranslucent()
	if PropTrashLookedAt == self then 
		render.CullMode(MATERIAL_CULLMODE_CW)
		render.SetColorMaterial()
		local col = self:GetTaped() and Color( 128, 255, 255, 60 ) or Color( 255, 255, 255, 20 )
		render.DrawSphere( self:GetPos(), self:ProtectionRadius(), 64, 32, col )
		render.CullMode(MATERIAL_CULLMODE_CCW)
	end
end

function ENT:ProtectionRadius()
	local field_size = TrashFieldModelToRadius[self:GetModel()]
	local locid = self:GetLocation()
	local ln = Location.GetLocationNameByIndex(locid)
	if ln=="The Pit" then
		field_size=field_size/2
	end
	return field_size
end

function ENT:ProtectsIfTaped(other)
	local field_size = self:ProtectionRadius()
	if other:GetClass() == "prop_trash_field" then
		field_size = field_size + other:ProtectionRadius()
	end
	return other:GetPos():Distance(self:GetPos()) < field_size
end

function ENT:Protects(other)
	return self:GetTaped() and self:ProtectsIfTaped(other)
end

function ENT:CanTape(userid)
	--TrashCanTapeProtectionTest(self, userid) and 
	return BaseClass.CanTape(self, userid)
end

--also used by theater
function TrashCanTapeProtectionTest(self, userid)
	local badcount = -1
	for k,v in pairs(ents.FindByClass("prop_trash*")) do
		if self:ProtectsIfTaped(v) and v:GetTaped() then
			badcount = badcount + ((v:GetOwnerID() == self:GetOwnerID()) and -1 or 1)
		end
	end
	if badcount > 0 then
		if SERVER then
			for k,v in pairs(player.GetAll()) do
				if v:SteamID() == userid then
					v:ChatPrint("[red]Can't tape here - too much of other people's stuff.")
				end
			end
		end
		return false
	end
	return true
end
