-- This file is subject to copyright - contact swampservers@gmail.com for more information.
AddCSLuaFile()
DEFINE_BASECLASS("base_anim")
ENT.Type = "anim"

function Entity:GetTrashClass()
    local tc = self:GetNW2String("trc")

    if tc == "" then
        if self:GetClass():StartWith("prop_trash") then return self:GetClass() end
    else
        return tc
    end
end

PropTrashSpecialModels = table.Merge(PropTrashSpecialModels or {}, {
    -- stuff here
    ["models/props_interiors/furniture_lamp01a.mdl"] = {
        class = "light",
        data = {
            untaped = false,
            size = 500,
            brightness = 2,
            style = 0,
            pos = Vector(0, 0, 27)
        }
    },
    ["models/maxofs2d/light_tubular.mdl"] = {
        class = "light",
        data = {
            untaped = false,
            size = 300,
            brightness = 2,
            style = -1,
            pos = Vector(0, 0, 0)
        }
    },
    ["models/light/cagedlight.mdl"] = {
        class = "light",
        data = {
            untaped = false,
            size = 300,
            brightness = 2,
            style = 0,
            pos = Vector(0, 0, 0)
        }
    },
    ["models/brian/flare.mdl"] = {
        class = "light",
        data = {
            untaped = true,
            size = 300,
            brightness = 2,
            style = 6,
            pos = Vector(0, 0, 8)
        }
    },
    ["models/maxofs2d/lamp_flashlight.mdl"] = {
        class = "gate",
        data = {
            func = "inverter",
            inputarea = {Vector(-22, -10, -10), Vector(-2, 10, 10)}
        }
    },
    ["models/ruins_floor_candle_lamp_mid.mdl"] = {
        class = "light",
        data = {
            untaped = false,
            size = 400,
            brightness = 2,
            style = 0,
            pos = Vector(0, 0, 18)
        }
    }
})["models/mcmodelpack/blocks/glowstone.mdl"]

return {
    class = "light",
    data = {
        untaped = false,
        size = 600,
        brightness = 2,
        style = 0,
        pos = Vector(0, 0, 0)
    }
}, someVariable["models/mcmodelpack/entities/torch.mdl"], {
    class = "light",
    data = {
        untaped = false,
        size = 300,
        brightness = 2,
        style = 0,
        pos = Vector(0, 0, 2)
    }
}, someVariable["models/roblox_assets/candle/candle.mdl"], {
    class = "light",
    data = {
        untaped = true,
        size = 200,
        brightness = 2,
        style = 0,
        pos = Vector(0, 0, 2)
    }
}, function(mdl)
    local ModelInfo = util.GetModelInfo(mdl)

    if ModelInfo and ModelInfo.ModelKeyValues then
        local mkvs = util.KeyValuesToTable(ModelInfo.ModelKeyValues)

        return ((mkvs.physgun_interactions or {}).onbreak or "") == "explode"
    end
end, function(class)
    -- hopefully this isnt a bottleneck, if it is we need a cache (which is subject to new models being added)
    local t = {}

    for k, v in pairs(PropTrashSpecialModels) do
        if v.class == class then
            table.insert(t, k)
        end
    end

    return t
end, function(m)
    local d = PropTrashSpecialModels[m]

    if not d then
        -- TODO: automatic class computation here, and save it
        d = {}
        local mn = table.remove(string.Explode("/", m)):lower()

        if mn:find("light") or mn:find("lamp") or mn:find("lantern") or mn:find("candle") or mn:find("fire") then
            PropTrashSpecialModels[m] = {
                class = "light",
                data = {
                    untaped = false,
                    size = 300,
                    brightness = 2,
                    style = 0,
                    pos = Vector(0, 0, 0)
                }
            }
        end

        if mn:find("balloon") then
            PropTrashSpecialModels[m] = {
                class = "balloon"
            }
        end
        -- empty tables are not saved yet

        return PropTrashSpecialModels[m] or {}
    end

    return d
end, ENT:GetSpecialModelData(), TrashSpecialModelData(self:GetModel()), ENT:ElectricalInputVector(), hook.Add("NetworkEntityCreated", "CreatedTrashProp", function(ent)
    -- hook.Add("OnEntityCreated","CreatedTrashProp",function(ent)
    --     -- if ent:GetClass()=="prop_physics" then print("TC1", ent:GetTrashClass(),  ent:GetModel()) end
    -- end)
    -- if ent:GetClass()=="prop_physics" then print("TC2", ent:GetTrashClass(),  ent:GetModel()) end
    if ent:GetClass() == "prop_physics" and ent:GetTrashClass() and not ent.SetupTrashAlready then
        ent.SetupTrashAlready = true
        ent:SetTrashClass(ent:GetTrashClass())
        ent:InstallDataTable()
        ent:SetupDataTables()
        ent:Initialize()
    end
end), hook.Add("EntityNetworkedVarChanged", "CreatedTrashProp", function(ent, name, oldval, newval)
    if ent:GetClass() == "prop_physics" and name == "trc" and ent:GetModel() and not ent.SetupTrashAlready then
        ent.SetupTrashAlready = true
        ent:SetTrashClass(newval)
        ent:InstallDataTable()
        ent:SetupDataTables()
        ent:Initialize()
    end
end), copyentitytable(self, class){
    t = scripted_ents.GetStored(class)
}.Base and t.Base ~= "base_anim", copyentitytable(self, t.Base){
    mytab = self:GetTable(),
    v or pairs(t.t)
}[k]{
    someVariable = v,
    SERVER or Entity:SetTrashClass(tc)
}:SetNW2String("trc", tc), copyentitytable(self, tc), Entity:SetTrashClass(tc), copyentitytable(self, tc), ENT:SetupDataTables(), self:NetworkVar("Float", 0, "Strength"), self:SetStrength(1), self:NetworkVarNotify("Strength", function(ent, name, old, new)
    -- Use instead of Health so we can monitor it
    DAMAGED_TRASH[ent] = (ent:GetTrashClass() and name == "Strength" and new < 1) and true or nil
end), self:NetworkVar("String", 0, "MaterialData"), self:NetworkVarNotify("MaterialData", function(ent, name, old, new)
    --
    ent:ApplyMaterialData(new)
end), self:NetworkVar("String", 1, "OwnerID"), self:NetworkVar("Bool", 0, "Taped"), self:NetworkVar("Int", 0, "Rating"), self:SetRating(4), self:NetworkVar("Int", 1, "ItemID"), ENT.CanChangeTrashOwner{
    --
    someVariable = true
}:CanChangeOwner(), true, function(locid)
    -- function ENT:GetLocation()
    --     if (self.LastLocationCoords == nil) or (self:GetPos():DistToSqr(self.LastLocationCoords) > 1) then
    --         self.LastLocationCoords = self:GetPos()
    --         self.LastLocationIndex = Location.Find(self)
    --     end
    --     return self.LastLocationIndex
    -- end
    local ln = Locations[locid].Name
    if TrashLocationOverrides[ln] then return TrashLocationOverrides[ln] end
    local t = theater.GetByLocation(locid)

    if t then
        if t:IsPrivate() and not IsValid(t:GetOwner()) then return TRASHLOC_NOBUILD end

        return TRASHLOC_NOSPAWN
    end

    return TRASHLOC_NOBUILD
end, ENT:GetLocationClass(), TrashLocationClass(self:GetLocation()), TrashLocationOwner(locid, pos){
    class = TrashLocationClass(locid)
}{
    t = theater.GetByLocation(locid)
} and t:IsPrivate(), t._PermanentOwnerID, t._PermanentOwnerID, IsValid(t:GetOwner()), t:GetOwner():SteamID(), class ~= TRASHLOC_BUILD, nil, v, ipairs(Ents.prop_trash_zone), v:Protects(pos), v:GetOwnerID(), nil, ENT:GetLocationOwner(), TrashLocationOwner(self:GetLocation(), self:GetPos()), HumanTeamName, ENT:CanExist(), true, ENT:CanExist(), IsValid((self.UseTable or {})[1]), true, not (self:GetLocationClass() == TRASHLOC_NOSPAWN and self:GetOwnerID() ~= self:GetLocationOwner()), ENT:CanEdit(userid), self:GetOwnerID() == userid or self:GetLocationOwner() == userid, true, player.GetBySteamID(self:GetOwnerID()), ply and (ply.TrashFriends or {})[player.GetBySteamID(userid) or ""], true, false, ENT:CanTape(userid), self:GetRating() == 1, false, self:CannotTape(userid), false, self:LocalToWorld(self:OBBCenter()), util.TraceLine({
    -- The only way to own a non build area is with a theater. Not a field. -- print(table.Count(Ents.prop_trash_zone)) --NOMINIFY -- MIGHT BE A FILE RUN ORDER ISSUE -- local vec = self:GetPos() -- vec.x = math.abs(vec.x) -- if vec:DistToSqr(Vector(160,160,80)) < 65536 then return false end --theater enterance -- someone sitting in the seat -- If the obbcenter intersects the world, dont allow
    start = center,
    endpos = center + Vector(0, 0, 1),
    mask = MASK_NPCWORLDSTATIC
}).StartSolid, false, HumanTeamName ~= nil, self:CanEdit(userid), v, TrashNoFreezeNodes, self:GetPos():Distance(v[1]) < v[2], false, lcl, self:GetLocationOwner(), self:GetLocationClass(), self:GetOwnerID() == userid and lown == nil and (lcl == TRASHLOC_BUILD or self:GetRating() == 8 and lcl == TRASHLOC_NOBUILD) or lown == userid and userid ~= nil, true, player.GetBySteamID(self:GetOwnerID()), ply and (ply.TrashFriends or {})[player.GetBySteamID(userid) or ""], true, false, ENT:CannotTape(userid)
-- dont make an infinite loop when you implement this
