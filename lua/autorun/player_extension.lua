-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local PLAYER = FindMetaTable("Player")
local entity = FindMetaTable("Entity")

function PLAYER:GetLocation()
    return self:GetDTInt(0) or 0
end

function PLAYER:GetLastLocation()
    return self.LastLocation or -1
end

function PLAYER:GetLocationName()
    return Location.GetLocationNameByIndex(self:GetLocation())
end

function PLAYER:GetLocationTable()
    return Location.GetLocationByIndex(self:GetLocation()) or {}
end

function PLAYER:InTheater()
    return self:GetLocationTable().Theater ~= nil
end

function PLAYER:GetTheater()
    return theater.GetByLocation(self:GetLocation())
end

function PLAYER:SetLocation(locationId)
    self.LastLocation = self:GetLocation()

    return self:SetDTInt(0, locationId)
end

PLAYER.TrueName = PLAYER.TrueName or PLAYER.Nick
local specials = "[]{}()<>-|= "
local specials2 = "["

for i = 1, #specials do
    specials2 = specials2 .. "%" .. specials[i]
end

specials2 = specials2 .. "]+"

function StripNameAdvert(name, advert)
    local pat = {specials2}

    for i = 1, #advert do
        local ch = advert[i]

        if ch == "." then
            table.insert(pat, "%.")
        else
            table.insert(pat, "[" .. ch:upper() .. ch .. "]")
        end
    end

    table.insert(pat, specials2)
    local n2 = (" " .. name .. " "):gsub(table.concat(pat, ""), ""):Trim()
    if #n2 < 2 then return name end

    return n2
end

-- local stripme = {"- swamp.sv", "-swamp.sv", "swamp.sv"}
function PLAYER:ComputeName()
    if self:IsBot() then return "Kleiner" end
    local tn = self:TrueName()
    tn = StripNameAdvert(tn, "swamp.sv")
    tn = StripNameAdvert(tn, "sups.gg")

    return tn
end

function PLAYER:Name()
    if self:TrueName() ~= self.LastTrueName then
        self.NameCache = self:ComputeName()
        self.LastTrueName = self:TrueName()
    end

    return self.NameCache
end

PLAYER.Nick = PLAYER.Name
PLAYER.GetName = PLAYER.Name

if SERVER then
    PLAYER.TrueSetPos = PLAYER.TrueSetPos or entity.SetPos

    -- prevents teleporting out with it
    function PLAYER:SetPos(pos)
        self:StripWeapon("weapon_kekidol")
        self:TrueSetPos(pos)
    end
end

PLAYER.TrueSetModel = PLAYER.TrueSetModel or entity.SetModel

if SERVER then
    function PLAYER:SetModel(mdl)
        self:TrueSetModel(mdl)
        hook.Run("PlayerModelChanged", self, mdl)
    end
else
    hook.Add("PrePlayerDraw", "PlayerModelChangeDetector", function(ply)
        local mdl = ply:GetModel()

        if mdl ~= ply.PlayerModelChangedLastModel then
            ply.PlayerModelChangedLastModel = mdl
            hook.Run("PlayerModelChanged", ply, mdl)
        end
    end)
end

function PLAYER:SetDefaultJumpPower()
    self:SetJumpPower(self:IsPony() and 160 or 152)
end

hook.Add("PlayerModelChanged", "SetJumpPower", function(ply, mdl)
    ply:SetDefaultJumpPower()
end)

function PLAYER:IsPony()
    return isPonyModel(self:GetModel())
end

function PLAYER:PonyNoseOffsetBone(ang)
    if self:IsPPMPony() then
        if (self.ponydata or {}).gender == 2 then return ang:Forward() * 1.9 + ang:Right() * 1.2 end
    end

    return Vector(0, 0, 0)
end

function PLAYER:PonyNoseOffsetAttach(ang)
    if self:IsPPMPony() then
        if (self.ponydata or {}).gender == 2 then return ang:Forward() * 1.8 + ang:Up() * 0.8 end
    end

    return Vector(0, 0, 0)
end

function PLAYER:IsAFK()
    return self:GetNWBool("afk", false)
end

function PLAYER:StaffControlTheater()
    local minn = 2

    if not CH then
        while minn do
            minn = minn + 1
        end
    end

    if self:GetTheater() and self:GetTheater():Name() == "Movie Theater" then
        minn = 1
    end

    return self:GetRank() >= minn
end

function isPonyModel(modelName)
    modelName = modelName:sub(1, 17)
    if modelName == "models/ppm/player" then return true end
    if modelName == "models/mlp/player" then return true end

    return false
end

function PLAYER:UsingWeapon(cls)
    local c = self:GetActiveWeapon()

    return IsValid(c) and c:GetClass() == cls
end