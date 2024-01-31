-- CNavArea:GetPlace override to use the Location system instead of its own internal thing
local CNAVAREA = FindMetaTable("CNavArea")
local CachedLocationNames = {}

function CNAVAREA:SetPlace(...)
    ErrorNoHalt("CNavArea:SetPlace is not supported. Use the Location system instead\n")

    return false
end

function CNAVAREA:GetPlace()
    local id = self:GetID()

    if not CachedLocationNames[id] then
        local loc_id = FindLocation(self:GetCenter())
        local loc_info = Locations[loc_id]
        CachedLocationNames[id] = loc_info.Name
    end

    return CachedLocationNames[id]
end
