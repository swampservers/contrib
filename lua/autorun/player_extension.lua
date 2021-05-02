-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local player = FindMetaTable("Player")
local entity = FindMetaTable("Entity")

function player:GetLocation()
    return self:GetDTInt(0) or 0
end

function player:GetLastLocation()
    return self.LastLocation or -1
end

function player:GetLocationName()
    return Location.GetLocationNameByIndex(self:GetLocation())
end

function player:GetLocationTable()
    return Location.GetLocationByIndex(self:GetLocation()) or {}
end

function player:InTheater()
    return self:GetLocationTable().Theater ~= nil
end

function player:GetTheater()
    return theater.GetByLocation(self:GetLocation())
end

function player:SetLocation(locationId)
    self.LastLocation = self:GetLocation()

    return self:SetDTInt(0, locationId)
end

player.TrueName = player.TrueName or player.Nick
function player:Name()
    return self:IsBot() and "Kleiner" or self:TrueName()
end
player.Nick = player.Name
player.GetName = player.Name

if SERVER then
    player.TrueSetPos = player.TrueSetPos or entity.SetPos

    -- prevents teleporting out with it
    function player:SetPos(pos)
        self:StripWeapon("weapon_kekidol")
        self:TrueSetPos(pos)
    end
end

player.TrueSetModel = player.TrueSetModel or entity.SetModel

if SERVER then
    function player:SetModel(mdl)
        self:TrueSetModel(mdl)
        hook.Run("PlayerModelChanged", self, mdl)
    end
else
    hook.Add("PrePlayerDraw","PlayerModelChangeDetector",function(ply)
        local mdl = ply:GetModel()
        if mdl~=ply.PlayerModelChangedLastModel then
            ply.PlayerModelChangedLastModel=mdl
            hook.Run("PlayerModelChanged", ply, mdl)
        end
    end)
end


hook.Add("PlayerModelChanged", "SetJumpPower",function(ply,mdl) 
    -- print(ply,mdl)
    ply:SetJumpPower(ply:IsPony() and 160 or 152)
end)

function player:IsPony()
    return isPonyModel(self:GetModel())
end

function player:PonyNoseOffsetBone(ang)
    if self:IsPPMPony() then
        if (self.ponydata or {}).gender == 2 then return ang:Forward() * 1.9 + ang:Right() * 1.2 end
    end

    return Vector(0, 0, 0)
end

function player:PonyNoseOffsetAttach(ang)
    if self:IsPPMPony() then
        if (self.ponydata or {}).gender == 2 then return ang:Forward() * 1.8 + ang:Up() * 0.8 end
    end

    return Vector(0, 0, 0)
end

function player:IsAFK()
    return self:GetNWBool("afk", false)
end

function player:StaffControlTheater()
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
