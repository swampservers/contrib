-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local meta = FindMetaTable("Player")
local entity = FindMetaTable("Entity")

function meta:GetLocation()
    return self:GetDTInt(0) or 0
end

function meta:GetLastLocation()
    return self.LastLocation or -1
end

function meta:GetLocationName()
    return Location.GetLocationNameByIndex(self:GetLocation())
end

function meta:GetLocationTable()
    return Location.GetLocationByIndex(self:GetLocation()) or {}
end

function meta:InTheater()
    return self:GetLocationTable().Theater ~= nil
end

function meta:GetTheater()
    return theater.GetByLocation(self:GetLocation())
end

function meta:SetLocation(locationId)
    self.LastLocation = self:GetLocation()

    return self:SetDTInt(0, locationId)
end

if not meta.TrueName then
    meta.TrueName = meta.Nick
end

function meta:Name()
    local st = self:TrueName()

    if self:IsBot() then
        st = "Kleiner"
    end

    return st
end

meta.Nick = meta.Name
meta.GetName = meta.Name

if SERVER then
    if not meta.TrueSetPos then
        meta.TrueSetPos = entity.SetPos
    end

    -- prevents teleporting out with it
    function meta:SetPos(pos)
        self:StripWeapon("weapon_kekidol")
        self:TrueSetPos(pos)
    end
end

if not meta.TrueSetModel then
    meta.TrueSetModel = entity.SetModel
end

function meta:SetModel(modelName)
    self:TrueSetModel(modelName)
    if GAMEMODE.FolderName == "spades" then return end

    -- if isPonyModel(modelName) then
    --     self:SetViewOffset(Vector(0, 0, self:GetModelScale() * 42))
    --     self:SetViewOffsetDucked(Vector(0, 0, self:GetModelScale() * 32))

    --     if modelName == "models/mlp/player_celestia.mdl" then
    --         self:SetViewOffset(Vector(0, 0, self:GetModelScale() * 66))
    --         self:SetViewOffsetDucked(Vector(0, 0, self:GetModelScale() * 55))
    --     end

    --     if modelName == "models/mlp/player_luna.mdl" then
    --         self:SetViewOffset(Vector(0, 0, self:GetModelScale() * 58))
    --         self:SetViewOffsetDucked(Vector(0, 0, self:GetModelScale() * 47))
    --     end
    -- else
    --     self:SetViewOffset(Vector(0, 0, self:GetModelScale() * 64))
    --     self:SetViewOffsetDucked(Vector(0, 0, self:GetModelScale() * 28))

    --     if modelName == "models/garfield/garfield.mdl" then
    --         self:SetViewOffset(Vector(0, 0, self:GetModelScale() * 40))
    --         self:SetViewOffsetDucked(Vector(0, 0, self:GetModelScale() * 18))
    --     end

    --     if modelName == "models/player/ztp_nickwilde.mdl" then
    --         self:SetViewOffset(Vector(0, 0, self:GetModelScale() * 52))
    --         self:SetViewOffsetDucked(Vector(0, 0, self:GetModelScale() * 24))
    --     end

    --     if modelName:StartWith("models/player/minion/") then
    --         self:SetViewOffset(Vector(0, 0, self:GetModelScale() * 36))
    --         self:SetViewOffsetDucked(Vector(0, 0, self:GetModelScale() * 8))
    --     end
    -- end

    self:SetSubMaterial()
    self:SetDefaultJumpPower()
    hook.Run("PlayerModelChanged", self, modelName)
end

function meta:SetDefaultJumpPower()
    self:SetJumpPower(self:IsPony() and 160 or 144)
end

function meta:IsPony()
    return isPonyModel(self:GetModel())
end

function meta:PonyNoseOffsetBone(ang)
    if self:IsPPMPony() then
        if (self.ponydata or {}).gender == 2 then return ang:Forward() * 1.9 + ang:Right() * 1.2 end
    end

    return Vector(0, 0, 0)
end

function meta:PonyNoseOffsetAttach(ang)
    if self:IsPPMPony() then
        if (self.ponydata or {}).gender == 2 then return ang:Forward() * 1.8 + ang:Up() * 0.8 end
    end

    return Vector(0, 0, 0)
end

function meta:IsAFK()
    return self:GetNWBool("afk", false)
end

function meta:StaffControlTheater()
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

if CLIENT then
    hook.Add("Think", "PMViewOffset", function() end) -- local lp = LocalPlayer() -- if IsValid(lp) then --     lp:SetupBones() --     local att = lp:LookupAttachment("eyes") --     if att>0 then --         att = lp:GetAttachment(att) --         if lp:Nick()=="Joker Gaming" then --             local v = Vector(0,0,att.Pos.z - lp:GetPos().z) --             -- v.z=10 --             print(v) --             lp:SetViewOffset(v) --         end --     end -- end
end