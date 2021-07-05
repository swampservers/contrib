-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = Model("models/sunabouzu/thumbnail_case.mdl")

-- ENT.Model = Model("models/props_phx/rt_screen.mdl")
function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "TheaterName")
    self:NetworkVar("String", 1, "Title")
    self:NetworkVar("String", 2, "Service")
    self:NetworkVar("Entity", 0, "TheaterOwner")

    if SERVER then
        self:SetTitle('NoVideoPlaying')
        self:SetTheaterName('Invalid')
        self:SetThumbnail('')
        self:SetService('')
    end
end

function ENT:OnRemove()
    if CLIENT and ValidPanel(self.HTML) then
        self.HTML:Remove()
    end
end

function ENT:GetThumbnail()
    local i, t = 1, ""

    while self:GetNW2String("Thumbnail" .. tostring(i), "") ~= "" do
        t = t .. self:GetNW2String("Thumbnail" .. tostring(i), i)
        i = i + 1
    end

    return t
end

function ENT:GetTheaterOwnerName()
    local x = IsValid(self:GetTheaterOwner())

    return IsValid(x) and x:Nick() or ""
end
