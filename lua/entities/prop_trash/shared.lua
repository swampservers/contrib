-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
DEFINE_BASECLASS("base_anim")
ENT.Type = "anim"

PropTrashLightData = {
    ["models/props_interiors/furniture_lamp01a.mdl"] = {
        untaped = false,
        size = 500,
        brightness = 2,
        style = 0,
        pos = Vector(0, 0, 27)
    },
    ["models/maxofs2d/light_tubular.mdl"] = {
        untaped = false,
        size = 300,
        brightness = 2,
        style = -1,
        pos = Vector(0, 0, 0)
    },
    ["models/light/cagedlight.mdl"] = {
        untaped = false,
        size = 300,
        brightness = 2,
        style = 0,
        pos = Vector(0, 0, 0)
    },
    ["models/brian/flare.mdl"] = {
        untaped = true,
        size = 300,
        brightness = 2,
        style = 6,
        pos = Vector(0, 0, 8)
    }
}

PropTrashDoors = {
    ["models/staticprop/props_c17/door01_left.mdl"]=true
}

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "OwnerID")
    self:NetworkVar("Bool", 0, "Taped")
    self:NetworkVar("Int", 0, "Rating")
    self:SetRating(4)
    self:NetworkVar("Int", 1, "ItemID")
    -- self:NetworkVar("Bool", 1, "Painted")
    self:NetworkVar("Vector", 0, "UnboundedColor")
    self:SetUnboundedColor(Vector(1, 1, 1))
end

ENT.CanChangeTrashOwner = true

function ENT:CanChangeOwner()
    return true
end

function ENT:GetLocation()
    if (self.LastLocationCoords == nil) or (self:GetPos():DistToSqr(self.LastLocationCoords) > 1) then
        self.LastLocationCoords = self:GetPos()
        self.LastLocationIndex = Location.Find(self)
    end

    return self.LastLocationIndex
end

function TrashLocationClass(locid)
    local ln = Location.GetLocationNameByIndex(locid)
    if TrashLocationOverrides[ln] then return TrashLocationOverrides[ln] end
    local t = theater.GetByLocation(locid)

    if t then
        if t:IsPrivate() and not IsValid(t:GetOwner()) then return TRASHLOC_NOBUILD end

        return TRASHLOC_NOSPAWN
    end

    return TRASHLOC_NOBUILD
end

function ENT:GetLocationClass()
    return TrashLocationClass(self:GetLocation())
end

function TrashLocationOwner(locid, pos)
    local class = TrashLocationClass(locid)
    local t = theater.GetByLocation(locid)

    if t and t:IsPrivate() then
        if t._PermanentOwnerID then return t._PermanentOwnerID end
        if IsValid(t:GetOwner()) then return t:GetOwner():SteamID() end
    end

    if class ~= TRASHLOC_BUILD then return nil end -- The only way to own a non build area is with a theater. Not a field.

    for k, v in pairs(Ents.prop_trash_zone) do
        if v:Protects(pos) then return v:GetOwnerID() end
    end

    return nil
end

function ENT:GetLocationOwner()
    return TrashLocationOwner(self:GetLocation(), self:GetPos())
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
