-- This file is subject to copyright - contact swampservers@gmail.com for more information.
if CLIENT then
    concommand.Add("getwsid", function(pl, cmd, args, argStr)
        local ply = Ply(argStr) or player.GetBySteamID(argStr)

        if IsValid(ply) then
            print(ply:GetDisplayModel())
        else
            print("Player not found!")
        end
    end)
end

function Player:GetDisplayModel()
    local st = self:GetNW2String("DisplayModel", "")
    if st == "" then return self:GetModel(), nil end
    -- wsid,bodygroups might be nil
    local mdl, wsid, bodygroups = unpack(("@"):Explode(st))

    return mdl, wsid, bodygroups
end

if CLIENT then
    -- TODO: move forcing logic to client_force_mdl_mat.lua
    local function checkmodel(ply)
        local mdl = ply:GetModel()
        local dmdl, dwsid, dbodygroups = ply:GetDisplayModel()

        if dmdl and (dmdl ~= mdl or ply.ForceFixPlayermodel) then
            if (dwsid == nil or require_model(dmdl, dwsid, ply:GetPos():Distance(Me:GetPos()))) and IsValidPlayermodel(dmdl) then
                ply.ForceFixPlayermodel = nil
                ply:SetModel(dmdl)

                if dbodygroups then
                    ply:SetBodyGroups(dbodygroups)
                end

                mdl = dmdl
                -- IT MAKES THE MODEL STAY
                ply:SetPredictable(ply == Me)
                -- timer.Simple(0, function()
                --     if IsValid(ply) then
                --         ply:SetModel(dmdl)
                --         ply:SetPredictable(ply == Me)
                --     end
                -- end)
            end
        end

        if mdl ~= ply.PlayerModelChangedLastModel then
            ply.PlayerModelChangedLastModel = mdl
            hook.Run("PlayerModelChanged", ply, mdl)
        end
    end

    local players2check = {}

    hook.Add("PrePlayerDraw", "PlayerModelWSApplierChangeDetector", function(ply)
        players2check[ply] = true
    end)

    hook.Add("Tick", "LocalPlayerForceModel", function()
        if IsValid(Me) then
            checkmodel(Me)
        end

        for k, v in pairs(players2check) do
            if IsValid(k) then
                checkmodel(k)
            end

            players2check[k] = nil
        end
    end)

    local function fixplayermodel(ply)
        ply.ForceFixPlayermodel = true

        for i = 1, 5 do
            timer.Simple(0.1 * i, function()
                if IsValid(ply) then
                    ply.ForceFixPlayermodel = true
                end
            end)
        end
    end

    hook.Add("NotifyShouldTransmit", "PlayerModelReset", function(ply)
        if ply:IsPlayer() then
            fixplayermodel(ply)
        end
    end)

    hook.Add("NetworkEntityCreated", "PlayerModelReset", function(ply)
        if ply:IsPlayer() then
            fixplayermodel(ply)
        end
    end)

    hook.Add("EntityNetworkedVarChanged", "PlayerModelReset", function(ply, name, old, new)
        if ply:IsPlayer() and name == "DisplayModel" then
            fixplayermodel(ply)
        end
    end)

    -- RAGDOLL STUFF
    local function enforce_ragdoll(rag)
        -- not having this causes crashes?
        rag:InvalidateBoneCache()
        rag:SetModel(rag.enforce_model)
        rag:InvalidateBoneCache()
    end

    local enforce_models = {}

    hook.Add("Think", "EnforceRagdoll", function()
        for rag, count in next, enforce_models do
            if IsValid(rag) and count > 0 then
                enforce_ragdoll(rag)
                enforce_models[rag] = count - 1
            else
                enforce_models[rag] = nil
            end
        end
    end)

    local OversizeRagdoll = defaultdict(function(mdl) return (file.Size(mdl:gsub("%.mdl$", '.phy'), 'GAME') or 999999) > 100000 end)

    -- Setting display model has to be done in this hook or it breaks!
    hook.Add("NetworkEntityCreated", "ragdoll1", function(rag)
        if rag:GetClass() ~= "class C_HL2MPRagdoll" then return end
        local ply = rag:GetRagdollOwner()
        if not IsValid(ply) then return end
        local mdl, dw, bg = ply:GetDisplayModel()
        if not mdl or not IsValidPlayermodel(mdl) then return end
        if OversizeRagdoll[mdl] then return end
        rag.enforce_model = mdl
        enforce_models[rag] = 8
        enforce_ragdoll(rag)

        -- TODO: set bodygroups
        rag.RenderOverride = function(rag)
            rag:SetModel(rag.enforce_model)

            if enforce_models[rag] then
                rag:InvalidateBoneCache()
            end

            rag:DrawModel()
        end
    end)
    -- timer.Simple(0.5, function()
    --     if IsValid(rag) then rag.RenderOverride=nil end
    -- end)
end
