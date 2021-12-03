-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local Player = FindMetaTable("Player")

function Player:GetDisplayModel()
    local st = self:GetNW2String("DisplayModel", "")
    if st == "" then return self:GetModel(), nil end
    -- wsid might be nil
    mdl, wsid = unpack(("@"):Explode(st))

    return mdl, wsid
end

if CLIENT then
    -- TODO: move forcing logic to client_force_mdl_mat.lua
    local function checkmodel(ply)
        local mdl = ply:GetModel()
        local dmdl, dwsid = ply:GetDisplayModel()

        -- if ply==LocalPlayer() then print(mdl,dmdl) end
        if dmdl and (dmdl ~= mdl or ply.ForceFixPlayermodel) then
            if (dwsid == nil or require_model(dmdl, dwsid, ply:GetPos():Distance(LocalPlayer():GetPos()))) and IsValidPlayermodel(dmdl) then
                ply.ForceFixPlayermodel = nil
                ply:SetModel(dmdl)
                -- ply:SetBodyGroups("11111111")
                mdl = dmdl
                -- IT MAKES THE MODEL STAY
                ply:SetPredictable(ply == LocalPlayer())
                -- timer.Simple(0, function()
                --     if IsValid(ply) then
                --         ply:SetModel(dmdl)
                --         ply:SetPredictable(ply == LocalPlayer())
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
        if IsValid(LocalPlayer()) then
            checkmodel(LocalPlayer())
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
