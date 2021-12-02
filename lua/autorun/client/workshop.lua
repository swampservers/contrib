-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local loadrange = CreateClientConVar("swamp_workshop", 0, true, false, "", -3, 1)

function RefreshWorkshop()
    STEAMWS_FILEINFO_STARTED = {}
    STEAMWS_DOWNLOAD_STARTED = {}
    STEAMWS_FILEINFO = {}
    STEAMWS_MOUNTED = {}
    STEAM_WORKSHOP_INFLIGHT = 0
    STEAMWS_PLAYERMODELS = {}
    -- STEAMWS_REGISTRY = {}
end

if not STEAMWS_DOWNLOAD_STARTED then
    RefreshWorkshop()
end

local AvailableMdls = {}
local ValidPlayerMdls = {}

function IsModelAvailable(mdl)
    if AvailableMdls[mdl] == nil then
        AvailableMdls[mdl] = file.Exists(mdl, 'GAME')
    end

    return AvailableMdls[mdl]
end

function IsValidPlayermodel(mdl)
    if not IsModelAvailable(mdl) then return false end

    if ValidPlayerMdls[mdl] == nil then
        local ok, err = MDLIsPlayermodel(mdl)
        ValidPlayerMdls[mdl] = ok

        if not ok then
            print("INVALID PLAYERMODEL " .. mdl .. " BECAUSE " .. err)
        end
    end

    return ValidPlayerMdls[mdl]
end

function require_model(mdl, wsid, range)
    -- if range==nil then print(mdl, wsid) end
    if (wsid or "") == "" or IsModelAvailable(mdl) then return true end
    -- STEAMWS_REGISTRY[mdl] = wsid
    -- will return true despite being error if the workshop is missing the model

    return require_workshop(wsid, range)
end

-- return the size in mb or nil if unknown
function require_workshop_info(id)
    if STEAMWS_FILEINFO[id] then
        return STEAMWS_FILEINFO[id] --.size  / 1000000
    elseif not STEAMWS_FILEINFO_STARTED[id] then
        STEAMWS_FILEINFO_STARTED[id] = true
        local _id_ = id

        steamworks.FileInfo(id, function(info)
            STEAMWS_FILEINFO[_id_] = info
        end)
    end
end

--placeholder: models/maxofs2d/logo_gmod_b.mdl
--or: models/props_phx/gears/spur24.mdl
function require_workshop(id, range)
    -- print("ID", id, STEAMWS_DOWNLOAD_STARTED[id], STEAM_WORKSHOP_INFLIGHT)
    -- 
    assert(isstring(id))
    local shouldload = true

    if range then
        local info = require_workshop_info(id)

        if info then
            local setting = loadrange:GetInt()
            local mb = info.size / 1000000

            if setting == -3 then
                shouldload = false
            end

            if setting == -2 and mb * 100 > 1000 - range then
                shouldload = false
            end

            if setting == -1 and mb * 40 > 1200 - range then
                shouldload = false
            end

            if setting == 0 and mb * 25 > 1500 - range then
                shouldload = false
            end

            if setting == 1 and mb * 50 > 3000 - range then
                shouldload = false
            end
        else
            shouldload = false
        end
    end

    if shouldload and not STEAMWS_DOWNLOAD_STARTED[id] and STEAM_WORKSHOP_INFLIGHT < 2 then
        STEAMWS_DOWNLOAD_STARTED[id] = true
        print("\n\n***DOWNLOADING " .. id .. " OF SIZE " .. STEAMWS_FILEINFO[id].size .. "***\n\n")
        local _id_ = id
        STEAM_WORKSHOP_INFLIGHT = STEAM_WORKSHOP_INFLIGHT + 1

        steamworks.DownloadUGC(id, function(name, file)
            print("\n\n***CALLBACK " .. id .. "***\n\n")

            timer.Simple(0.1, function()
                STEAM_WORKSHOP_INFLIGHT = STEAM_WORKSHOP_INFLIGHT - 1
            end)

            -- NOTE:
            -- Any error models currently loaded that the mounted addon provides will be reloaded.
            -- Any error materials currently loaded that the mounted addon provides will NOT be reloaded.
            -- That means that this cannot be used to fix missing map materials, as the map materials are loaded before you are able to call this.
            if name then
                -- print("MOUNTAVBE", _id_, name) 
                -- game.MountGMA(name)
                local succ, files = SafeMountGMA(_id_, name)

                if succ then
                    STEAMWS_MOUNTED[_id_] = files
                else
                    STEAMWS_MOUNTED[_id_] = {}
                end
            else
                print("Workshop download failed for " .. _id_)

                timer.Simple(60, function()
                    print("Retrying for " .. _id_)
                    STEAMWS_DOWNLOAD_STARTED[_id_] = nil
                end)
            end
        end)
    end

    return STEAMWS_MOUNTED[id] and true or false
end

function SafeMountGMA(wsid, filename)
    local ok, err = GMABlacklist(filename)

    if not ok then
        print("COULD NOT MOUNT " .. wsid .. " BECAUSE " .. err)

        return false, {}
    end

    -- mounting with a clientside error model crashes the game
    local resetmodels = {}

    for i, v in ipairs(ents.GetAll()) do
        if v:EntIndex() == -1 then
            local m = v:GetModel()

            if m and not util.IsValidModel(m) then
                resetmodels[v] = {m, v:GetSequence()}

                v:SetModel("models/maxofs2d/logo_gmod_b.mdl")
            end
        end
    end

    local succ, files = game.MountGMA(filename)

    if not succ then
        files = {}
    end

    for i, v in ipairs(files) do
        if v:EndsWith(".mdl") then
            AvailableMdls[v] = true
        end
    end

    for ent, mod in pairs(resetmodels) do
        ent:SetModel(mod[1])
        ent:SetSequence(mod[2])
    end

    return succ, files
end

-- STEAMWS_REGISTRY = STEAMWS_REGISTRY or {}
-- function register_workshop_model(mdl, wsid)
--     STEAMWS_REGISTRY[mdl] = wsid
-- end
-- function require_workshop_model(mdl)
--     if STEAMWS_REGISTRY[mdl] then
--         return require_workshop(STEAMWS_REGISTRY[mdl])
--     else
--         -- assume its built in
--         return true
--     end
-- end
--implement steamworks.IsSubscribed(wsid) and file.Exists(mdl,'GAME')
-- function is_model_undownloaded(mdl)
--     -- print(1)
--     if not STEAMWS_REGISTRY[mdl] then return false end
--     -- print(2)
--     if util.IsValidModel(mdl) then return false end
--     -- print(3)
--     return not STEAMWS_MOUNTED[STEAMWS_REGISTRY[mdl]]
-- end
-- utilBasedIsValidModel = utilBasedIsValidModel or util.IsValidModel
-- local validmodels = {}
-- local function isvalidmodel(mdl)
--     local r = validmodels[mdl]
--     if not r then
--         r = utilBasedIsValidModel(mdl)
--         if r then
--             validmodels[mdl] = true
--         end
--     end
--     return r
-- end
-- util.IsValidModel = isvalidmodel
local Entity = FindMetaTable("Entity")
local getmodel = Entity.GetModel

function Entity:GetActualModel()
    -- if self:IsPlayer() then
    --     local dmdl, wsid = self:GetDisplayModel()
    --     if dmdl then
    --         register_workshop_model(dmdl, wsid)
    --         -- print(require_workshop(wsid)) 
    --         if require_workshop(wsid) then
    --             if self:GetModel()~=dmdl then self:SetModel(dmdl) end
    --         end
    --     end
    -- end
    local setmodel = getmodel(self)
    -- local correct = STEAMWS_REGISTRY[setmodel] and require_workshop(STEAMWS_REGISTRY[setmodel]) or isvalidmodel(setmodel)
    -- return correct and setmodel or "models/error.mdl"
    -- util.IsValidModel

    return IsModelAvailable(setmodel) and setmodel or "models/error.mdl"
end

hook.Add("Think", "ForceLocalPlayerModel", function() end)
hook.Add("PlayerPostThink", "ForceLocalPlayerModel", function(ply) end) -- if ply ~= LocalPlayer() or not IsFirstTimePredicted() then return end -- local dmdl, wsid = ply:GetDisplayModel() -- if dmdl then --     if require_model(dmdl, wsid) then -- --         -- ply:SetModel(dmdl) --         if ply:GetModel() ~= dmdl then --             print("SET", ply, dmdl) --             ply:SetModel(dmdl) --             -- ply:SetPredictable(false) --             -- ply:ResetHull() --             -- ply:SetWalkSpeed(ply:GetWalkSpeed()) --             -- ply:SetRunSpeed(ply:GetRunSpeed()) --             -- THIS MAKES IT WORK --             ply:SetPredictable(true) --         end --     end -- end  -- local state = LocalPlayer():GetPredictable() -- ply:SetPredictable(true) -- print(LocalPlayer():GetModel())

function require_playermodel_list(wsid)
    if not require_workshop(wsid) then return end

    if not STEAMWS_PLAYERMODELS[wsid] then
        local mdl_list = {}

        for k, f in ipairs(STEAMWS_MOUNTED[wsid]) do
            if f:EndsWith(".mdl") then
                local isplr, err, err2 = MDLIsPlayermodel(f)

                if isplr then
                    table.insert(mdl_list, f)
                end
            end
        end

        STEAMWS_PLAYERMODELS[wsid] = mdl_list
    end

    return STEAMWS_PLAYERMODELS[wsid]
end
