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
    local bounty = ply:GetBounty()

    if bounty > 0 and ply ~= atk and atk:IsPlayer() then
        ply:SetBounty(0)

        if not (ply.BountyFunders or {})[atk] and bounty >= 100000 then
            atk:GroupStat("bountyhunt", ply)
        end

        ply.BountyFunders = nil
        atk:GivePoints(bounty, "Bounty.Claimed")
        WhoSeesChat(ply, true):NamedBotMessage(Style.edgy(atk), " has claimed ", Style.gold(ply, "'s"), " bounty of ", Style.rainbow(bounty), " points!")
        sc.log(atk, " claimed a bounty on ", ply, " for ", bounty, " points")
    end
end)

function TryAddBounty(ply, targets, amount, locid, locname)
    amount = math.floor(tonumber(amount) or 0)

    if amount < 1000 then
        ply:ChatPrint("[red]You must add a minimum of 1,000 points to the bounty")

        return
    end

    local needed = amount * #targets

    -- local total = (BountyLimit[ply:SteamID()] or 0) + needed
    ply:TryTakePoints(needed, "Bounty.Added", function()
        if not IsValid(ply) then return end

        for _, v in ipairs(targets) do
            if IsValid(v) then
                v:SetBounty(v:GetBounty() + amount)
                v.BountyFunders = v.BountyFunders or {}
                v.BountyFunders[ply] = true
            end
        end

        if #targets == 1 then
            if IsValid(targets[1]) then
                WhoSeesChat(targets[1], true):NamedBotMessage(targets[1], "'s bounty is now ", Style.rainbow(targets[1]:GetBounty()), " points")
                sc.log(ply, " set a bounty on ", targets[1], " for ", amount, " points")
            end
        else
            local filter = locid and WhoIsNear(ply, locid) or WhoSeesChat(NULL, true)
            filter:NamedBotMessage(ply, " has increased the bounty of ", #targets == #Ents.human and "everyone" or #targets .. " players", locname and " in " .. locname or "", " by ", Style.rainbow(amount), " points!")
            sc.log(ply, " set a bounty on ", #targets == #Ents.human and "everyone" or #targets .. " players", locname and " in " .. locname or "", " for ", amount, " points")
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
        local found = FindSinglePlayer(arg, true)

        if isnumber(found) then
            ply:ChatPrint("[red]Player \"" .. arg .. (found == 0 and "\" not found" or "\" matched " .. found .. " players"))
        else
            TryAddBounty(ply, {found}, p)
        end
    else
        ply:ChatPrint("[orange]!bounty player points")
    end
end, {
    global = true,
    throttle = true
})

RegisterChatCommand({'bountylocation', 'setbountylocation'}, function(ply, arg)
    arg = string.Explode(" ", arg)
    local p = tonumber(table.remove(arg))
    arg = string.Implode(" ", arg)

    if p then
        -- Exact match
        local found = LocationByName[arg]
        local matchcount = found and 1 or 0

        if not found then
            arg = string.lower(arg)

            for _, loc in ipairs(Locations) do
                -- Exact (lowercase) match
                local locname = string.lower(loc.Name)

                if locname == arg then
                    found = loc
                    matchcount = 1
                    break
                end

                -- Containing arg
                if string.find(locname, arg, 1, true) then
                    if not found then
                        found = loc
                        matchcount = 1
                    else
                        matchcount = matchcount + 1
                    end
                end
            end
        end

        if matchcount ~= 1 then
            ply:ChatPrint("[red]Location \"" .. arg .. (matchcount == 0 and "\" not found" or "\" matched " .. matchcount .. " locations"))
        else
            local players = GetPlayersInLocation(found.Index)

            if #players > 0 then
                TryAddBounty(ply, players, p, found.Index, found.Name)
            else
                ply:ChatPrint("[orange]Nobody's in " .. found.Name .. " right now!")
            end
        end
    else
        ply:ChatPrint("[orange]!bountylocation locationname points")
    end
end, {
    global = true,
    throttle = true
})

RegisterChatCommand({'bountyactive', 'setbountyactive'}, function(ply, arg)
    local p = tonumber(arg)

    if p then
        local players = {}

        for _, human in ipairs(Ents.human) do
            if not human:IsAFK() then
                players[#players + 1] = human
            end
        end

        TryAddBounty(ply, players, p)
    else
        ply:ChatPrint("[orange]!bountyactive points")
    end
end, {
    global = true,
    throttle = true
})

RegisterChatCommand({'bountyall', 'setbountyall'}, function(ply, arg)
    local p = tonumber(arg)

    if p then
        TryAddBounty(ply, Ents.human, p)
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

        for k, v in player.HumanIterator() do
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
    local found = FindSinglePlayer(arg, true)

    if isnumber(found) then
        ply:ChatPrint("[orange]!showbounty player (found " .. found .. " players)")
    else
        ply:ChatPrint("[orange]" .. found:Nick() .. (found:GetBounty() > 0 and "'s bounty is [edgy]" .. found:GetBounty() .. " [orange]points" or " has no bounty"))
    end
end, {
    global = false,
    throttle = false
})

RegisterChatCommand({'bounties', 'showbounties'}, function(ply, arg)
    local t = {}

    for k, v in player.HumanIterator() do
        if v:GetBounty() > 0 then
            table.insert(t, {v, v:GetBounty()})
        end
    end

    table.sort(t, function(a, b) return a[2] > b[2] end)

    if t[1] then
        ply:ChatPrint("[bot]--- [gold]Bounties [bot]---")

        for k, v in ipairs(t) do
            ply:ChatPrint("[bot]" .. v[1]:Nick() .. ": [gold]" .. v[2] .. " [white](" .. v[1]:GetLocationName() .. (v[1]:IsProtected() and " - Protected)" or ")"))
            if k >= 10 then break end
        end
    else
        ply:ChatPrint("[bot]There are currently no bounties!")
    end
end, {
    global = false,
    throttle = false
})

--Could be it's own file, but eh
RegisterChatCommand({'givepointsrandom', 'randomgivepoints'}, function(ply, arg)
    local p = math.floor(tonumber(arg) or 0)

    if p > 0 then
        local ranply = {}

        for k, v in player.HumanIterator() do
            if v:IsActive() and v ~= ply then
                table.insert(ranply, v)
            end
        end

        if #ranply == 0 then return end
        local rcvr = ranply[math.random(#ranply)]

        ply:TryTakePoints(p, "GivePointsRandom.Giver", function()
            if not IsValid(ply) then return end

            if IsValid(rcvr) then
                rcvr:GivePoints(p, "GiverPointsRandom.Receiver", function()
                    ply:Notify("You gave " .. rcvr:Nick() .. " " .. p .. " points.")
                    rcvr:Notify(ply:Nick() .. " gave you " .. p .. " of their points.")
                end, function() return end)
            end
        end, function()
            if IsValid(ply) then
                ply:ChatPrint("[red]You don't have enough points")
            end
        end)
    else
        ply:ChatPrint("[orange]!givepointsrandom points")
    end
end, {
    throttle = true
})
