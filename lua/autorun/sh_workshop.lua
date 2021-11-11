function RefreshWorkshop()
    STEAMWS_DOWNLOAD_STARTED = {}
    STEAMWS_MOUNTED =  {}
    STEAM_WORKSHOP_INFLIGHT = 0
end

if not STEAMWS_DOWNLOAD_STARTED then RefreshWorkshop() end

function SafeMountGMA(wsid, filename)
    -- print("safemount")
    local badmodels = {}

    for mdl, mwsid in pairs(STEAMWS_REGISTRY) do
        if mwsid == wsid then
            print("MOUNTING FOR", mdl)
            badmodels[mdl] = true
        end
    end

    local resetmodels = {}

    for i, v in ipairs(ents.GetAll()) do
        if v:EntIndex() == -1 and badmodels[v:GetModel()] then
            resetmodels[v] = {v:GetModel(), v:GetSequence()}

            v:SetModel("models/maxofs2d/logo_gmod_b.mdl")
        end
    end

    game.MountGMA(filename)

    for ent, mod in pairs(resetmodels) do
        ent:SetModel(mod[1])
        ent:SetSequence(mod[2])
    end
end

--placeholder: models/maxofs2d/logo_gmod_b.mdl
--or: models/props_phx/gears/spur24.mdl
function require_workshop(id)
    -- print("ID", id, STEAMWS_DOWNLOAD_STARTED[id], STEAM_WORKSHOP_INFLIGHT)
    -- 
    assert(isstring(id))

    if not STEAMWS_DOWNLOAD_STARTED[id] and STEAM_WORKSHOP_INFLIGHT == 0 then
        STEAMWS_DOWNLOAD_STARTED[id] = true
        print("\n\n***DOWNLOADING " .. id .. "***\n\n")
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
                SafeMountGMA(_id_, name)
                STEAMWS_MOUNTED[_id_] = true
            else
                print("Workshop download failed for " .. _id_)

                timer.Simple(60, function()
                    print("Retrying for " .. _id_)
                    STEAMWS_DOWNLOAD_STARTED[_id_] = nil
                end)
            end
        end)
    end

    return STEAMWS_MOUNTED[id] or false
end

STEAMWS_REGISTRY = STEAMWS_REGISTRY or {}

function register_workshop_model(mdl, wsid)
    STEAMWS_REGISTRY[mdl] = wsid
end

function require_workshop_model(mdl)
    if STEAMWS_REGISTRY[mdl] then
        return require_workshop(STEAMWS_REGISTRY[mdl])
    else
        -- assume its built in
        return true
    end
end

function is_model_undownloaded(mdl)
    -- print(1)
    if not STEAMWS_REGISTRY[mdl] then return false end
    -- print(2)
    if util.IsValidModel(mdl) then return false end
    -- print(3)

    return not STEAMWS_MOUNTED[STEAMWS_REGISTRY[mdl]]
end

utilBasedIsValidModel = utilBasedIsValidModel or util.IsValidModel
local validmodels = {}

local function isvalidmodel(mdl)
    local r = validmodels[mdl]

    if not r then
        r = utilBasedIsValidModel(mdl)

        if r then
            validmodels[mdl] = true
        end
    end

    return r
end

util.IsValidModel = isvalidmodel
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
    local correct = STEAMWS_REGISTRY[setmodel] and require_workshop(STEAMWS_REGISTRY[setmodel]) or isvalidmodel(setmodel)

    return correct and setmodel or "models/error.mdl"
end

if CLIENT then
    hook.Add("Think", "ForceLocalPlayerModel", function() end)

    hook.Add("PlayerPostThink", "ForceLocalPlayerModel", function(ply)

        if ply ~= LocalPlayer() or not IsFirstTimePredicted() then return end
        
        
        local dmdl, wsid = ply:GetDisplayModel()

        if dmdl then
            register_workshop_model(dmdl, wsid)
            if require_workshop(wsid) then
                
        --         -- ply:SetModel(dmdl)
                if ply:GetModel() ~= dmdl then
                    print("SET", ply, dmdl)

                    
                    
                    -- ply:SetModel(dmdl)
                    -- ply:SetPredictable(false)

                    -- ply:ResetHull()

                    -- ply:SetWalkSpeed(ply:GetWalkSpeed())
                    -- ply:SetRunSpeed(ply:GetRunSpeed())

                    -- THIS MAKES IT WORK
                    -- ply:SetPredictable(true)

                    
                end
            end
        end 
        -- local state = LocalPlayer():GetPredictable()
	
    


        -- ply:SetPredictable(true)


        -- print(LocalPlayer():GetModel())
    end)

end


if SERVER then

    local ent
    function PrecacheModel(mdl)
    
        local loaded = util.IsModelLoaded(mdl)
        if loaded then return end
        
        dbg("ADDING TO LIST",('%q'):format(mdl))
        
        if StringTable then
            StringTable("modelprecache"):AddString(true,mdl)
            return
        end
        
        if not ent or not ent:IsValid() then
            ent = ents.Create'base_entity'
            if not ent or not ent:IsValid() then return end
            
            ent:SetNoDraw(true)
            ent:Spawn()
            ent:SetNoDraw(true)
            
        end
        
        ent:SetModel(mdl)
        
    end
    
end