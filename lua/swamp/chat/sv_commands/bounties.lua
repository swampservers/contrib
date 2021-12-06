-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- BountyLimit = BountyLimit or {}
hook.Add("PlayerDeath", "BountyDeath", function(ply, infl, atk)
    local bounty = GetPlayerBounty(ply)

    if bounty > 0 and ply ~= atk and atk:IsPlayer() then
        SetPlayerBounty(ply, 0)
        atk:SS_GivePoints(bounty)
        BotSayGlobal("[edgy]" .. atk:Nick() .. " [fbc]has claimed [gold]" .. ply:Nick() .. "'s [fbc]bounty of [rainbow]" .. bounty .. " [fbc]points!")
    end
end)

function GetPlayerBounty(ply)
    if ply.bounty == nil then
        ply.bounty = tonumber(ply:GetPData("bounty", 0))
    end

    return ply.bounty
end

function SetPlayerBounty(ply, bounty)
    ply:SetPData("bounty", bounty)
    ply.bounty = bounty
end

function AddBounty(ply, targets, amount)
    amount = amount > 0 and amount or 0
    local needed = amount * #targets

    -- local total = (BountyLimit[ply:SteamID()] or 0) + needed
    ply:SS_TryTakePoints(needed, function()
        if not IsValid(ply) then return end

        for k, v in ipairs(targets) do
            if IsValid(v) then
                SetPlayerBounty(v, GetPlayerBounty(v) + amount)
            end
        end

        if #targets == 1 then
            if IsValid(targets[1]) then
                BotSayGlobal("[fbc]" .. targets[1]:Nick() .. "'s bounty is now [rainbow]" .. GetPlayerBounty(targets[1]) .. " [fbc]points")
            end
        else
            BotSayGlobal("[fbc]" .. ply:Nick() .. " has increased everyone's bounty by [rainbow]" .. amount .. " [fbc]points!")
        end
    end, function()
        if not IsValid(ply) then return end
        ply:ChatPrint("[red]You don't have enough points")
    end)
    -- BountyLimit[ply:SteamID()] = (BountyLimit[ply:SteamID()] or 0) + amount
end

RegisterChatCommand({'bounty', 'setbounty'}, function(ply, arg)
    local t = string.Explode(" ", arg)
    local p = tonumber(table.remove(t))
    p = (p ~= nil and math.floor(p) or nil)

    if p == nil then
        ply:ChatPrint("[orange]!bounty player points")
    else
        local to, c = PlyCount(string.Implode(" ", t))

        if c == 1 then
            if p >= 1000 then
                AddBounty(ply, {to}, p)
            else
                ply:ChatPrint("[red]You must add a minimum of 1000 points to the bounty")
            end
        else
            ply:ChatPrint("[red]Player " .. string.Implode(" ", t) .. " not found")
        end
    end
end, {
    global = true,
    throttle = true
})

RegisterChatCommand({'bountyall', 'setbountyall'}, function(ply, arg)
    local p = tonumber(arg)
    p = (p ~= nil and math.floor(p) or nil)

    if p == nil then
        ply:ChatPrint("[orange]!bountyall points")
    else
        if p >= 1000 then
            AddBounty(ply, player.GetHumans(), p)
        else
            ply:ChatPrint("[red]You must add a minimum of 1000 points to the each bounty")
        end
    end
end, {
    global = true,
    throttle = true
})

RegisterChatCommand({'bountyrandom', 'setbountyrandom', 'randombounty', 'setrandombounty'}, function(ply, arg)
    local p = tonumber(arg)
    p = (p ~= nil and math.floor(p) or nil)

    if p == nil then
        ply:ChatPrint("[orange]!bountyrandom points")
    else
        if p >= 1000 then
            local ranply = {}

            for k, v in ipairs(player.GetHumans()) do
                if not v:IsProtected() then
                    table.insert(ranply, v)
                end
            end

            AddBounty(ply, {ranply[math.random(#ranply)]}, p)
        else
            ply:ChatPrint("[red]You must add a minimum of 1000 points to the bounty")
        end
    end
end, {
    global = true,
    throttle = true
})

RegisterChatCommand({'showbounty'}, function(ply, arg)
    local to, c = PlyCount(arg)

    if c == 1 then
        local bounty = GetPlayerBounty(to)

        if bounty > 0 then
            ply:ChatPrint("[orange]" .. to:Nick() .. "'s bounty is [edgy]" .. bounty .. " [orange]points")
        else
            ply:ChatPrint("[orange]" .. to:Nick() .. " has no bounty")
        end
    else
        ply:ChatPrint("[orange]!showbounty player")
    end
end, {
    global = false,
    throttle = false
})

RegisterChatCommand({'bounties', 'showbounties'}, function(ply, arg)
    local t = {}

    for k, v in pairs(player.GetHumans()) do
        local bounty = GetPlayerBounty(v)

        if bounty > 0 then
            table.insert(t, {v, bounty})
        end
    end

    table.sort(t, function(a, b) return a[2] > b[2] end)

    if #t >= 1 then
        ply:ChatPrint("[fbc]--- [gold]Bounties [fbc]---")

        for k, v in ipairs(t) do
            if k <= 10 then
                if not v[1]:IsProtected() then
                    ply:ChatPrint("[fbc]" .. v[1]:Nick() .. ": [gold]" .. v[2] .. " [white](" .. v[1]:GetLocationName() .. ")")
                else
                    ply:ChatPrint("[fbc]" .. v[1]:Nick() .. ": [gold]" .. v[2] .. " [white](" .. v[1]:GetLocationName() .. " - Protected)")
                end
            end
        end
    else
        ply:ChatPrint("[fbc]There are currently no bounties!")
    end
end, {
    global = false,
    throttle = false
})
