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

-- local stripme = {"- swamp.sv", "-swamp.sv", "swamp.sv"}
function PLAYER:ComputeName()
    if self:IsBot() then return "Kleiner" end
    local tn = self:TrueName()
    -- local tnl = tn:lower()
    -- for i,s in ipairs(stripme) do
    --     if tnl:EndsWith(s) then
    --         tn = tn:sub(1,-1-string.len(s))
    --         break
    --     end
    -- end
    -- tn = tn:Trim()
    -- if tn:len() < 2 then tn="__"..tn end

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
        if not FORCEMODELL and GAMEMODE.FolderName=="cinema" then
            mdl = self:IsBot() and "models/garfield/odie.mdl" or "models/player/pyroteknik/garfield.mdl"
        end

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

local function AppropriateNavArea(ply, area)
    local mins, maxs = ply:GetCollisionBounds()
    if (area:GetSizeX() < maxs.x * 2 or area:GetSizeY() < maxs.z * 2) then return false end

    local mins,maxs = ply:GetCollisionBounds()
    local tr = {}
    tr.start = area:GetCenter() + Vector(0,0,1)
    tr.endpos =area:GetCenter()
    tr.filter = function(ent)
        if(ent == ply)then return false end
        local should = hook.Call("ShouldCollide",nil,ply,ent) or true
        return should
    end
    tr.mins = mins
    tr.maxs = maxs
    local trace = util.TraceHull(tr)
    if(trace.StartSolid)then return false end
    
    return true
end

-- multiply disance along an axis, so we can  
local function biasdist(pos1, pos2, biasvec)
    return (pos1 * biasvec):Distance((pos2 * biasvec))
end

function PLAYER:IsStuck()
    if(self:InVehicle())then return false end
    local mins,maxs = self:GetCollisionBounds()
    local tr = {}
    tr.start = self:GetPos()
    tr.endpos = tr.start + self:GetVelocity()*FrameTime()
    tr.filter = function(ent)
        if(ent == self)then return false end
        local should = hook.Call("ShouldCollide",nil,self,ent) or true
        return should
    end
    tr.mins = mins
    tr.maxs = maxs
    local trace = util.TraceHull(tr)
    if(trace.StartSolid)then return true end
    return false
end

if (SERVER) then
    concommand.Add("stuck", function(ply, cmd, args)
        local worked = ply:Unstick()
        local msg = (worked == true and "Unstuck!") or (worked == false and "Couldn't Unstick! Try to /tp to another player!") or (worked == nil and "You don't appear to be stuck.")
        ply:ChatPrint(msg)
    end)
end

function PLAYER:Unstick()
    if (not self:IsStuck()) then
        return 
    end

    local areas
    local testedareas = 0
    local bestarea
    local bestareapos = Vector(0, 0, 160000)
    --least aggressive
    bestarea = navmesh.GetNearestNavArea(self:GetPos(), false, 1000, true, true)
    if(!AppropriateNavArea(self, bestarea))then bestarea = nil end


    --more aggressive
    if (not IsValid(bestarea)) then
        areas = navmesh.Find(self:GetPos(), 512, 512, 64)

        for k, area in pairs(areas) do
            if (AppropriateNavArea(self, area)) then
                if (bestarea == nil or biasdist(self:GetPos(), area:GetCenter(), Vector(1, 1, 8)) < biasdist(self:GetPos(), bestareapos, Vector(1, 1, 8))) then
                    bestarea = area
                    bestareapos = area:GetCenter()
                end
            else
                testedareas = testedareas + 1
            end
        end
    end

    --most aggressive
    if (not IsValid(bestarea)) then
        areas = navmesh.GetAllNavAreas()

        for k, area in pairs(areas) do
            if (AppropriateNavArea(self, area)) then
                if (bestarea == nil or self:GetPos():Distance(area:GetCenter()) < self:GetPos():Distance(bestareapos)) then
                    bestarea = area
                    bestareapos = area:GetCenter()
                end
            else
                testedareas = testedareas + 1
            end
        end
    end

    if (bestarea) then
        self:SetPos(bestarea:GetCenter() + Vector(0, 0, 16))
        self:DropToFloor()
        return true
    else
        self:ChatPrint("Couldn't find anywhere safe to put you")
        return false
    end
end