-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local PLAYER = FindMetaTable("Player")
local ENTITY = FindMetaTable("Entity")
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
    tn = StripNameAdvert(tn, "moat.gg") --lol rip
    tn = StripNameAdvert(tn, "velk.ca")

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
    PLAYER.TrueSetPos = PLAYER.TrueSetPos or ENTITY.SetPos

    -- prevents teleporting out with it
    function PLAYER:SetPos(pos)
        self:StripWeapon("weapon_kekidol")
        self:TrueSetPos(pos)
    end
end

PLAYER.TrueSetModel = PLAYER.TrueSetModel or ENTITY.SetModel

if SERVER then
    function PLAYER:SetModel(mdl)
        self:TrueSetModel(mdl)
        hook.Run("PlayerModelChanged", self, mdl)

        self:SetNWString("DisplayModel","")
    end

    function PLAYER:SetDisplayModel(mdl, wsid)

        print("MAKE SURE YOU MOVE THIS")
        --what to display if unloaded or whatever
        self:SetModel(mdl)
        self:SetModel("models/player/skeleton.mdl")
        self:SetNWString("DisplayModel",mdl)
        self:SetNWString("DisplayWSID",tostring(wsid))
        -- self:SetModel(mdl)
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

function PLAYER:GetDisplayModel()
    local mdl, wsid = self:GetNWString("DisplayModel",""), tostring(self:GetNWString("DisplayWSID",""))
    if mdl~="" then return mdl,wsid end
end

function PLAYER:SetDefaultJumpPower()
    self:SetJumpPower(self:IsPony() and 160 or 152)
end

hook.Add("PlayerModelChanged", "SetJumpPower", function(ply, mdl)
    ply:SetDefaultJumpPower()
end)

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

function PLAYER:UsingWeapon(cls)
    local c = self:GetActiveWeapon()

    return IsValid(c) and c:GetClass() == cls
end

local function CreateLayeredProperty(getter, setter, id_argument, additive, default)
    local basedgetter, basedsetter = "Based" .. getter, "Based" .. setter
    -- currently unused, getter just uses the accumulated value
    PLAYER[basedgetter] = PLAYER[basedgetter] or PLAYER[getter]
    PLAYER[basedsetter] = PLAYER[basedsetter] or PLAYER[setter]
    local settable = setter .. "Tab"

    local accumulate = additive and (function(t)
        local v
        local k, accum = next(t)

        while true do
            k, v = next(t, k)
            if not k then break end
            accum = accum + v
        end

        return accum
    end) or (function(t)
        local v
        local k, accum = next(t)

        while true do
            k, v = next(t, k)
            if not k then break end
            accum = accum * v
        end

        return accum
    end)

    PLAYER[setter] = id_argument and (function(self, id, val, key)
        local s = self[settable]

        if not s then
            s = {}
            self[settable] = s
        end

        local t = s[id]

        if not t then
            t = {}
            s[id] = t
        end

        key = key or ""

        if key ~= "" then
            if not t[""] then
                t[""] = self[basedgetter](self, id)
            end

            if val == default then
                val = nil
            end
        end

        t[key] = val
        self[basedsetter](self, id, accumulate(t))
    end) or (function(self, val, key)
        local t = self[settable]

        if not t then
            t = {}
            self[settable] = t
        end

        key = key or ""

        if key ~= "" then
            if not t[""] then
                t[""] = self[basedgetter](self)
            end

            if val == default then
                val = nil
            end
        end

        t[key] = val
        self[basedsetter](self, accumulate(t))
    end)
end

PLAYER.GetManipulateBonePosition = ENTITY.GetManipulateBonePosition
PLAYER.ManipulateBonePosition = ENTITY.ManipulateBonePosition
PLAYER.GetManipulateBoneAngles = ENTITY.GetManipulateBoneAngles
PLAYER.ManipulateBoneAngles = ENTITY.ManipulateBoneAngles
PLAYER.GetManipulateBoneScale = ENTITY.GetManipulateBoneScale
PLAYER.ManipulateBoneScale = ENTITY.ManipulateBoneScale
CreateLayeredProperty("GetSlowWalkSpeed", "SetSlowWalkSpeed", false, false, 1)
CreateLayeredProperty("GetWalkSpeed", "SetWalkSpeed", false, false, 1)
CreateLayeredProperty("GetRunSpeed", "SetRunSpeed", false, false, 1)
CreateLayeredProperty("GetManipulateBonePosition", "ManipulateBonePosition", true, true, Vector(0, 0, 0))
CreateLayeredProperty("GetManipulateBoneAngles", "ManipulateBoneAngles", true, true, Angle(0, 0, 0))
CreateLayeredProperty("GetManipulateBoneScale", "ManipulateBoneScale", true, false, Vector(1, 1, 1))
-- PLAYER.TrueSetModel = PLAYER.TrueSetModel or ENTITY.SetModel
