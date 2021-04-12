-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
CoinFlips = CoinFlips or {}

RegisterChatCommand({'coin', 'coinflip'}, function(ply, arg)
    local t = string.Explode(" ", arg)
    local p = tonumber(t[#t])
    p = (p ~= nil and math.floor(p) or nil)

    if t[1]:lower() == "accept" and p ~= nil then
        checkCoinFlipRequest(ply, p)

        return
    end

    if p == nil then
        if t[1]:lower() == "accept" then
            ply:ChatPrint("[orange]!coinflip accept [confirm number of points]")
        else
            ply:ChatPrint("[orange]!coinflip player points")
        end
    else
        table.remove(t)
        local to, c = PlyCount(string.Implode(" ", t))

        if c == 1 then
            if ply == to then
                ply:ChatPrint("[red]You can't coinflip yourself!")
            elseif p >= 1000 then
                -- minimum 1000 point coinflip
                initCoinFlip(ply, to, p)
            else
                ply:ChatPrint("[red]A coinflip must be a minimum of 1000 points.")
            end
        else
            ply:ChatPrint("[red]Player " .. string.Implode(" ", t) .. " not found.")
        end
    end
end, {
    global = true,
    throttle = true
})

timer.Create("CoinFlip", 1, 0, function()
    local NewCoinFlips = {}

    for fromID, j in pairs(CoinFlips) do
        if ((j[3] + 30) <= CurTime()) then
            local fromPlayer = player.GetBySteamID(fromID)
            local toPlayer = player.GetBySteamID(j[1])

            -- This whole nonsense is because I want to show the from/to's name if possible, but otherwise show a different message.
            if (fromPlayer and toPlayer) then
                fromPlayer:ChatPrint("[edgy]" .. toPlayer:Nick() .. "[orange] doesn't want to play. Try again later.")
                toPlayer:ChatPrint("[orange]You missed out on a coinflip from [edgy]" .. fromPlayer:Nick() .. "[orange].")
            elseif (not fromPlayer and toPlayer) then
                toPlayer:ChatPrint("[orange]You missed out on a coinflip.")
            elseif (fromPlayer and not toPlayer) then
                fromPlayer:ChatPrint("[red]The player you requested a coinflip to has left. Try again later.")
            end

            CoinFlips[fromID] = nil
        else
            NewCoinFlips[fromID] = j
        end
    end

    CoinFlips = NewCoinFlips
end)

function initCoinFlip(ply, target, amount)
    if ply:SS_HasPoints(amount) and CoinFlips[ply:SteamID()] == nil then
        ply:ChatPrint("[orange]" .. target:Nick() .. " is receiving your coinflip request.")
        target:ChatPrint("[orange]" .. ply:Nick() .. " is sending you a coinflip request for [rainbow]" .. string.Comma(amount) .. "[orange]. Say !coinflip accept [confirm number of points] to accept.")

        CoinFlips[ply:SteamID()] = {target:SteamID(), amount, CurTime()}
    elseif CoinFlips[ply:SteamID()] ~= nil then
        ply:ChatPrint("[red]You already have a coinflip in progress.")
    elseif not ply:SS_HasPoints(amount) then
        ply:ChatPrint("[red]You don't have enough points.")
    end
end

function checkCoinFlipRequest(toPlayer, points)
    for fromID, j in pairs(CoinFlips) do
        if j[1] == toPlayer:SteamID() and j[2] == points then
            -- Coinflip Request Found
            finishCoinFlip(fromID, toPlayer)

            return
        end
    end

    toPlayer:ChatPrint("[red]You don't have a coinflip request for that amount!")
    toPlayer:ChatPrint("[orange]COINFLIPS:")
    local index = 1

    for fromID, j in pairs(CoinFlips) do
        if j[1] == toPlayer:SteamID() then
            local fromPlayer = player.GetBySteamID(fromID)

            if fromPlayer then
                toPlayer:ChatPrint("[orange](" .. index .. ") [gold]" .. string.Comma(j[2]) .. "[orange] from [edgy]" .. fromPlayer:Nick())
            end

            index = index + 1
        end
    end
end

function finishCoinFlip(fromID, toPlayer)
    local fromPlayer = player.GetBySteamID(fromID)
    local amount = CoinFlips[fromID][2]

    if (not fromPlayer) then
        CoinFlips[fromID] = nil -- Remove request from CoinFlip because initiator left the server
        toPlayer:ChatPrint("[red]The initiator left, coinflip cancelled.")
    elseif fromPlayer:SS_HasPoints(amount) and toPlayer:SS_HasPoints(amount) then
        -- Final Check, make sure they have funds still
        CoinFlips[fromID] = nil
        local heads = math.random() < 0.5 -- the "request from" player is always Heads.
        BotSayGlobal("[edgy]" .. fromPlayer:Nick() .. "[fbc] flipped a coin worth [rainbow]" .. string.Comma((amount * 2)) .. "[fbc] against [gold]" .. toPlayer:Nick() .. "[fbc] and [rainbow]" .. (heads and "Won" or "Lost") .. "[fbc]!")
        local fromcol = heads and "green" or "edgy"
        fromPlayer:ChatPrint("[" .. fromcol .. "]You " .. (heads and "won" or "lost") .. " [gold]" .. string.Comma(amount) .. "[" .. fromcol .. "] points.")
        local tocol = heads and "edgy" or "green"
        toPlayer:ChatPrint("[" .. tocol .. "]You " .. (heads and "lost" or "won") .. " [gold]" .. string.Comma(amount) .. "[" .. tocol .. "] points.")

        -- Instead of taking the amount away from both and then giving the winner the amount x 2, simply remove/add here
        if heads then
            toPlayer:SS_TakePoints(amount)
            fromPlayer:SS_GivePoints(amount) --math.floor(amount*0.99))
        else
            fromPlayer:SS_TakePoints(amount)
            toPlayer:SS_GivePoints(amount) --math.floor(amount*0.99))
        end
    else
        CoinFlips[fromID] = nil
        toPlayer:ChatPrint("[red]ERROR: No points have been taken. Coinflip cancelled.")
        fromPlayer:ChatPrint("[red]ERROR: No points have been taken. Coinflip cancelled.")
    end
end