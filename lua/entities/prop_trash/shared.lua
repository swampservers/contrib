-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
DEFINE_BASECLASS("base_anim")
ENT.Type = "anim"

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "OwnerID")
    self:NetworkVar("Bool", 0, "Taped")
    self:NetworkVar("Int", 0, "ItemID")
    self:NetworkVar("Bool", 1, "Painted")
    self:NetworkVar("Vector", 1, "PaintColor")
end

ENT.CanChangeTrashOwner = true

function ENT:CanChangeOwner()
    return true
end

function ENT:GetRating()
    return self:GetNW2Int("Rating", 4)
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
    if TrashLocationOverrides[ln] then return TrashLocationOverrides[ln] end
    local t = theater.GetByLocation(locid)

    if t then
        if t:IsPrivate() and not IsValid(t:GetOwner()) then return TRASHLOC_NOBUILD end

        return TRASHLOC_NOSPAWN
    end

    return TRASHLOC_NOBUILD
end

function ENT:GetLocationOwner()
    local class = self:GetLocationClass()
    local t = theater.GetByLocation(self:GetLocation())

    if t and t:IsPrivate() then
        if t._PermanentOwnerID then return t._PermanentOwnerID end
        if IsValid(t:GetOwner()) then return t:GetOwner():SteamID() end
    end

    if class ~= TRASHLOC_BUILD then return nil end -- The only way to own a non build area is with a theater. Not a field.

    for k, v in ipairs(GetTrashFields()) do
        if IsValid(v) and v:Protects(self) then return v:GetOwnerID() end
    end

    return nil
end

-- MIGHT BE A FILE RUN ORDER ISSUE
if HumanTeamName then
    function ENT:CanExist()
        return true
    end
else
    function ENT:CanExist()
        -- local vec = self:GetPos()
        -- vec.x = math.abs(vec.x)
        -- if vec:DistToSqr(Vector(160,160,80)) < 65536 then return false end --theater enterance
        -- someone sitting in the seat
        if IsValid((self.UseTable or {})[1]) then return true end

        return not (self:GetLocationClass() == TRASHLOC_NOSPAWN and self:GetOwnerID() ~= self:GetLocationOwner())
    end
end

function ENT:CanEdit(userid)
    return (self:GetOwnerID() == userid) or (self:GetLocationOwner() == userid)
end

function ENT:CanTape(userid)
    if self:GetRating() == 1 then return false end
    if HumanTeamName ~= nil then return self:CanEdit(userid) end

    for k, v in ipairs(TrashNoFreezeNodes) do
        if self:GetPos():Distance(v[1]) < v[2] then return false end
    end

    local lown, lcl = self:GetLocationOwner(), self:GetLocationClass()

    return ((self:GetOwnerID() == userid) and (lown == nil) and ((lcl == TRASHLOC_BUILD) or (self:GetRating() == 8 and lcl == TRASHLOC_NOBUILD))) or (lown == userid and userid ~= nil)
end

-- only used by field thing currently
local whitemat = Material("models/debug/debugwhite")

function ENT:DrawOutline()
    render.SuppressEngineLighting(true)
    render.MaterialOverride(whitemat)
    local sc = self:GetModelScale()
    local rad = self:BoundingRadius()
    self:SetModelScale(sc * (rad + 0.2) / rad)
    render.CullMode(MATERIAL_CULLMODE_CW)
    self:SetupBones()
    self:DrawModel()
    render.CullMode(MATERIAL_CULLMODE_CCW)
    self:SetModelScale(sc)
    render.MaterialOverride()
    render.SuppressEngineLighting(false)
end
