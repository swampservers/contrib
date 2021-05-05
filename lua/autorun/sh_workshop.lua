STEAMWS_DOWNLOAD_STARTED = STEAMWS_DOWNLOAD_STARTED or {}
STEAMWS_MOUNTED = STEAMWS_MOUNTED or {}
STEAM_WORKSHOP_INFLIGHT = STEAM_WORKSHOP_INFLIGHT or 0

function SafeMountGMA(wsid, filename)
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
    if not STEAMWS_DOWNLOAD_STARTED[id] and STEAM_WORKSHOP_INFLIGHT == 0 then
        STEAMWS_DOWNLOAD_STARTED[id] = true
        print("\n\n***DOWNLOADING " .. id .. "***\n\n")
        local _id_ = id
        STEAM_WORKSHOP_INFLIGHT = STEAM_WORKSHOP_INFLIGHT + 1

        steamworks.DownloadUGC(id, function(name, file)
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
    if not STEAMWS_REGISTRY[mdl] then return false end
    if util.IsValidModel(mdl) then return false end
    return not STEAMWS_MOUNTED[STEAMWS_REGISTRY[mdl]]
end