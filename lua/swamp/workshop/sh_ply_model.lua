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
    mdl, wsid, bodygroups = unpack(("@"):Explode(st))

    return mdl, wsid, bodygroups
end

if CLIENT then
    -- TODO: move forcing logic to client_force_mdl_mat.lua
    local function checkmodel(ply)
        local mdl = ply:GetModel()
        local dmdl, dwsid, dbodygroups = ply:GetDisplayModel()

        -- if ply==Me then print(mdl,dmdl) end
        if dmdl and (dmdl ~= mdl or ply.ForceFixPlayermodel) then
            if (dwsid == nil or require_model(dmdl, dwsid, ply:GetPos():Distance(Me:GetPos()))) and IsValidPlayermodel(dmdl) then
                ply.ForceFixPlayermodel = nil
                ply:SetModel(dmdl)

                if bodygroups then
                    ply:SetBodyGroups(bodygroups)
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
end
