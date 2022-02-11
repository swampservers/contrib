-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- BountyLimit = BountyLimit or {}
util.AddNetworkString("SetBounty")

net.Receive("SetBounty", function(len, ply)
    if ply:RateLimit("SetBounty", 5) then
        ply:Notify("Please wait!!!")

        return
    end

    local target = net.ReadEntity()
    if not IsValid(target) or not target:IsPlayer() then return end

    TryAddBounty(ply, {target}, net.ReadUInt(32))
end)

hook.Add("PlayerInitialSpawn", "LoadBounty", function(ply)
    ply.NW.bounty = tonumber(ply:GetPData("bounty", 0))
end)

function Player:GetBounty()
    return self.NW.bounty or 0
end

function Player:SetBounty(bounty)
    self:SetPData("bounty", bounty)
    self.NW.bounty = bounty
end

hook.Add("PlayerDeath", "BountyDeath", function(ply, infl, atk)
    local bounty = GetPlayerBounty(ply)

    if bounty > 0 and ply ~= atk and atk:IsPlayer() then
        ply:SetBounty(0)

        if not (ply.BountyFunders or {})[atk] and bounty >= 100000 then
            atk:GroupStat("bountyhunt", ply)
        end

        ply.BountyFunders = nil
        atk:GivePoints(bounty)
        BotSayGlobal("[edgy]" .. atk:Nick() .. " [fbc]has claimed [gold]" .. ply:Nick() .. "'s [fbc]bounty of [rainbow]" .. bounty .. " [fbc]points!")
    end
end)

function TryAddBounty(ply, targets, amount)
    amount = math.floor(tonumber(amount) or 0)

    if amount < 1000 then
        ply:ChatPrint("[red]You must add a minimum of 1,000 points to the bounty")

        return
    end

    local needed = amount * #targets

    -- local total = (BountyLimit[ply:SteamID()] or 0) + needed
    ply:TryTakePoints(needed, function()
        if not IsValid(ply) then return end

        for k, v in ipairs(targets) do
            if IsValid(v) then
                v:SetBounty(v:GetBounty() + amount)
                v.BountyFunders = v.BountyFunders or {}
                v.BountyFunders[ply] = true
            end
        end

        if #targets == 1 then
            if IsValid(targets[1]) then
                BotSayGlobal("[fbc]" .. targets[1]:Nick() .. "'s bounty is now [rainbow]" .. targets[1]:GetBounty() .. " [fbc]points")
            end
        else
            BotSayGlobal("[fbc]" .. ply:Nick() .. " has increased everyone's bounty by [rainbow]" .. amount .. " [fbc]points!")
        end
    end, function()
        if IsValid(ply) then
            ply:ChatPrint("[red]You don't have enough points")
        end
    end)
end

RegisterChatCommand({'bounty', 'setbounty'}, function(ply, arg)
    arg = string.Explode(" ", arg)
    local p = tonumber(table.remove(arg))
    arg = string.Implode(" ", arg)

    if p then
        local found = FindSinglePlayer(arg)

        if isnumber(found) then
            ply:ChatPrint("[red]Player " .. arg .. (found == 0 and " not found" or " matched " .. found .. " players"))
        else
            TryAddBounty(ply, {to}, found)
        end
    else
        ply:ChatPrint("[orange]!bounty player points")
    end
end, {
    global = true,
    throttle = true
})

RegisterChatCommand({'bountyall', 'setbountyall'}, function(ply, arg)
    local p = tonumber(arg)

    if p then
        TryAddBounty(ply, player.GetHumans(), p)
    else
        ply:ChatPrint("[orange]!bountyall points")
    end
end, {
    global = true,
    throttle = true
})

RegisterChatCommand({'bountyrandom', 'setbountyrandom', 'randombounty', 'setrandombounty'}, function(ply, arg)
    local p = tonumber(arg)

    if p then
        local ranply = {}

        for k, v in ipairs(player.GetHumans()) do
            if not v:IsProtected() then
                table.insert(ranply, v)
            end
        end

        TryAddBounty(ply, {ranply[math.random(#ranply)]}, p)
    else
        ply:ChatPrint("[orange]!bountyrandom points")
    end
end, {
    global = true,
    throttle = true
})

RegisterChatCommand({'showbounty'}, function(ply, arg)
    local found = FindSinglePlayer(arg)

    if isnumber(found) then
        ply:ChatPrint("[orange]!showbounty player (found " .. found .. " players)")
    else
        ply:ChatPrint("[orange]" .. to:Nick() .. (found:GetBounty() > 0 and "'s bounty is [edgy]" .. found:GetBounty() .. " [orange]points" or " has no bounty"))
    end
end, {
    global = false,
    throttle = false
})

RegisterChatCommand({'bounties', 'showbounties'}, function(ply, arg)
    local t = {}

    for k, v in pairs(player.GetHumans()) do
        if v:GetBounty() > 0 then
            table.insert(t, {v, v:GetBounty()})
        end
    end

    table.sort(t, function(a, b) return a[2] > b[2] end)

    if t[1] then
        ply:ChatPrint("[fbc]--- [gold]Bounties [fbc]---")

        for k, v in ipairs(t) do
            ply:ChatPrint("[fbc]" .. v[1]:Nick() .. ": [gold]" .. v[2] .. " [white](" .. v[1]:GetLocationName() .. (v[1]:IsProtected() and " - Protected)" or ")"))
            if k >= 10 then break end
        end
    else
        ply:ChatPrint("[fbc]There are currently no bounties!")
    end
end, {
    global = false,
    throttle = false
})
