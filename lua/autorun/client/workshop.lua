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

local function IsModelAvailable(mdl)
    if AvailableMdls[mdl] == nil then
        AvailableMdls[mdl] = file.Exists(mdl, 'GAME')
    end

    return AvailableMdls[mdl]
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

    if shouldload and not STEAMWS_DOWNLOAD_STARTED[id] and STEAM_WORKSHOP_INFLIGHT == 0 then
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
    -- clear this cache
    for k, v in pairs(AvailableMdls) do
        if v == false then
            AvailableMdls[k] = nil
        end
    end

    -- print("safemount")
    -- local badmodels = {}
    -- for mdl, mwsid in pairs(STEAMWS_REGISTRY) do
    --     if mwsid == wsid then
    --         print("MOUNTING FOR", mdl)
    --         badmodels[mdl] = true
    --     end
    -- end
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
    PrintTable(files)

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

--requires mdlinspect.lua
function MDLIsPlayermodel(f)
    local mdl, err, err2 = mdlinspect.Open(f)
    if not mdl then return nil, err, err2 end
    if mdl.version < 44 or mdl.version > 49 then return false, "bad model version" end
    local ok, err = mdl:ParseHeader()
    if not ok then return false, err or "hdr" end
    if not mdl.bone_count or mdl.bone_count <= 2 then return false, "nobones" end
    local imdls = mdl:IncludedModels()
    local found_anm

    for k, v in next, imdls do
        v = v[2]
        if v and v:find("_arms_", 1, true) then return false, "arms" end
        if v and not v:find"%.mdl$" then return false, "badinclude", v end

        if v == "models/m_anm.mdl" or v == "models/f_anm.mdl" or v == "models/z_anm.mdl" then
            found_anm = true
        end
    end

    local attachments = mdl:Attachments()

    if (not attachments or not next(attachments)) and not found_anm then
        return false, "noattachments"
    else
        local found

        for k, v in next, attachments do
            local name = v[1]

            if name == "eyes" or name == "anim_attachment_head" or name == "mouth" or name == "anim_attachment_RH" or name == "anim_attachment_LH" then
                found = true
                break
            end
        end

        if not found and not found_anm then return false, "attachments" end
    end

    return true, found_anm
end

--vertice count and bounding box size
function OutfitterCheckModelSize(mdl)
    local meshes = util.GetModelMeshes(mdl) or {}

    -- and lastmdl ~= mdl) then --lastmdl????
    if (#meshes > 0) then
        local max = {}
        local min = {}
        local vcount = 0

        for k, v in pairs(meshes) do
            vcount = vcount + #(meshes[k]["verticies"])

            for _, l in pairs(meshes[k]["verticies"]) do
                local p = l.pos

                if (p.x > (max.x or p.x - 1)) then
                    max.x = p.x
                end

                if (p.y > (max.y or p.y - 1)) then
                    max.y = p.y
                end

                if (p.z > (max.z or p.z - 1)) then
                    max.z = p.z
                end

                if (p.x < (min.x or p.x + 1)) then
                    min.x = p.x
                end

                if (p.y < (min.y or p.y + 1)) then
                    min.y = p.y
                end

                if (p.z < (min.z or p.z + 1)) then
                    min.z = p.z
                end
            end
        end

        local minV, maxV = Vector(min.x, min.y, min.z), Vector(max.x, max.y, max.z)
        local dis = minV:Distance(maxV)

        if vcount > 30000 and ((not IsValid(LocalPlayer())) or (not LocalPlayer():GetNWBool("oufitr+"))) then
            --return nil, "Model has too many vertices (" .. vcount .. ">30000). Get Outfitter+ to use it anyway."
            return false
        elseif vcount < 30 then
            --return nil, "Model has too few vertices (" .. vcount .. "<30)"
            return false
        elseif dis > 200 then
            --return nil, "Model's boundary box is too large (" .. math.floor(dis) .. ">200)"
            return false
        end
    end

    return true
end

function GetPlayermodels(files)
    for k, v in pairs(files) do
        if v:Trim():sub(-4):lower() == '.vtf' then
            local f = file.Open(v, "rb", "GAME")

            if f then
                f:Seek(16)
                local width = f:Read(2)
                local height = f:Read(2)
                width = string.byte(width, 1) + string.byte(width, 2) * 256
                height = string.byte(height, 1) + string.byte(height, 2) * 256
                if width > 4096 or height > 4096 then return nil end --oversize vtfs
            end
        end
    end

    --option to be more rigorous by checking every model file (vvd, mdl, phys)
    local modellist = FileListParseModels(files)
    local mdl_list = {}

    for k, entry in pairs(modellist) do
        local isplr, err, err2 = MDLIsPlayermodel(entry.Name)

        if isplr and OutfitterCheckModelSize(entry.Name) then
            table.insert(mdl_list, entry.Name)
        end
    end

    return mdl_list
end

--return list of models
function FileListParseModels(files)
    local mdls = {}

    for _, path in pairs(files) do
        local ext = path:sub(-4):lower()

        if ext == '.mdl' then
            mdls[#mdls + 1] = {
                Name = path,
                path = path,
                nogma = true
            }
        end
    end

    return mdls
end

function require_playermodel_list(wsid)
    if not require_workshop(wsid) then return end
    STEAMWS_PLAYERMODELS[wsid] = STEAMWS_PLAYERMODELS[wsid] or GetPlayermodels(STEAMWS_MOUNTED[wsid])

    return STEAMWS_PLAYERMODELS[wsid]
end
