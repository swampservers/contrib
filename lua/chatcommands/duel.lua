-- Merged the tables into a single one.
DuelData = DuelData or {}

RegisterChatCommand({"duels", "duelscores"}, function(ply, arg)
    ply:ChatPrint("[orange]Active duels:")
    local index = 1

    local hasRequests = false
    for fromID, j in pairs(DuelData) do
        local toPlayer = player.GetBySteamID(j.toID)
        local fromPlayer = player.GetBySteamID(fromID)
        if toPlayer ~= nil and toPlayer == ply and fromPlayer and j.duelStarted then
            ply:ChatPrint("[orange](" .. index .. ") [gold]" .. string.Comma(j.points) .. " points, first to " .. j.kills .. " kills. " .. j.fromName .. ": " .. j.fromPoints .. " | " .. j.toName .. ": " .. j.toPoints)
            hasRequests = true
            index = index + 1
        end
    end

    if not hasRequests then
        ply:ChatPrint("[orange]You have no active duels.")
    end
end)

RegisterChatCommand({"duelrequests"}, function(ply, arg)
    showRequests(ply)
end)

RegisterChatCommand({"duel"}, function(ply, arg)
    local args = string.Explode(" ", arg)

    -- Make sure there is a argument.
    if args[1] == nil then
        ply:ChatPrint("[orange]!duel [player] [amount of points] [number of kills to win]")
        return
    end

    local kills = args[1]:lower() ~= "accept" and tonumber(args[#args]) or nil
    local points = args[1]:lower() == "accept" and tonumber(args[#args]) or tonumber(args[#args - 1])
    points = points ~= nil and math.floor(points) or nil

    -- If command was the accept command check if number of points is set and run accept function.
    if args[1]:lower() == "accept" and points ~= nil then
        checkDuelRequest(ply, points)

        return
    elseif args[1]:lower() == "accept" and points == nil then
        ply:ChatPrint("[orange]!duel accept [confirm number of points]")
        return
    end

    -- Return if one of these is invalid.
    if points == nil or kills == nil then
        ply:ChatPrint("[orange]!duel [player] [amount of points] [number of kills to win]")
        return
    end

    -- Remove last 2 element from table which would be amount of points and number of kills so that we only have the player name left.
    table.remove(args)
    table.remove(args)

    local target, count = PlyCount(string.Implode(" ", args))

    -- Bunch of error checks, I switched to using single if statement early returns because it is more readable.
    if ply == target then
        ply:ChatPrint("[red]You can not duel yourself.")
        return
    end

    if count ~= 1 then
        ply:ChatPrint("[red]Player you mentioned was not found.")
        return
    end

    if kills > 20 or kills < 1 then
        ply:ChatPrint("[red]The win condition must be atleast 1 - 20 kills.")
        return
    end

    if points < 1000 then
        ply:ChatPrint("[red]The minimum amount of points for a duel is 1000.")
        return
    end

    if ply:SS_HasPoints(points) then
        if not target:SS_HasPoints(points) then
            ply:ChatPrint("[red]The challenged player does not have enough points.")
            return
        end
    else
        ply:ChatPrint("[red]You do not have enough points to request this duel.")
        return
    end

    -- Request the duel after this point.

    requestDuel(ply, target, points, kills)
end)

timer.Create("DuelTimer", 1, 0, function()
    for fromID, j in pairs(DuelData) do
        local fromPlayer = player.GetBySteamID(fromID)
        local toPlayer = player.GetBySteamID(j.toID)
        if (j.requestTime + 30) <= CurTime() and not j.requestAccepted then

            if fromPlayer and toPlayer then
                fromPlayer:ChatPrint("[edgy]" .. toPlayer:Nick() .. "[orange] doesn't want to fight. Try again later.")
                toPlayer:ChatPrint("[orange]You missed out on a duel with [edgy]" .. fromPlayer:Nick() .. "[orange].")
            elseif not fromPlayer and toPlayer then
                toPlayer:ChatPrint("[orange]You missed out on a duel.")
            elseif fromPlayer and not toPlayer then
                fromPlayer:ChatPrint("[red]The player you requested a duel with has left. Try again later.")
            end

            DuelData[fromID] = nil

        elseif j.duelStarted then

            -- Win conditions, tell me if there is any way to clean this up.
            if not fromPlayer and toPlayer then

                toPlayer:SS_GivePoints(j.points * 2)
                BotSayGlobal("[fbc]" .. j.toName .. " won a duel worth [rainbow]" .. string.Comma(j.points * 2) .. " points [fbc]against [gold]" .. j.fromName .. "[fbc]! Their opponent left the game.")

                DuelData[fromID] = nil

            elseif not toPlayer and fromPlayer then

                fromPlayer:SS_GivePoints(j.points * 2)
                BotSayGlobal("[fbc]" .. j.fromName .. " won a duel worth [rainbow]" .. string.Comma(j.points * 2) .. " points [fbc]against [gold]" .. j.toName .. "[fbc]! Their opponent left the game.")

                DuelData[fromID] = nil

            elseif j.fromPoints >= j.kills and toPlayer and fromPlayer then

                fromPlayer:SS_GivePoints(j.points * 2)
                BotSayGlobal("[fbc]" .. j.fromName .. " won a duel worth [rainbow]" .. string.Comma(j.points * 2) .. " points [fbc]against [gold]" .. j.toName .. "[fbc]! Final score - [green]" .. j.fromName .. ": " .. j.fromPoints .. " [fbc]| [red]" .. j.toName .. ": " .. j.toPoints)

                DuelData[fromID] = nil

            elseif j.toPoints >= j.kills and toPlayer and fromPlayer then

                toPlayer:SS_GivePoints(j.points * 2)
                BotSayGlobal("[fbc]" .. j.toName .. " won a duel worth [rainbow]" .. string.Comma(j.points * 2) .. " points [fbc]against [gold]" .. j.fromName .. "[fbc]! Final score - [green]" .. j.toName .. ": " .. j.toPoints .. " [fbc]| [red]" .. j.fromName .. ": " .. j.fromPoints)

                DuelData[fromID] = nil

            elseif not toPlayer and not fromPlayer then

                DuelData[fromID] = nil

            end

        end
    end
end)

function requestDuel(fromPlayer, toPlayer, points, kills)

    -- Make sure the user is not in a duel with this player already.
    if (DuelData[toPlayer:SteamID()] ~= nil and DuelData[toPlayer:SteamID()].toID == fromPlayer:SteamID()) or (DuelData[fromPlayer:SteamID()] ~= nil and DuelData[fromPlayer:SteamID()].toID == toPlayer:SteamID()) then
        fromPlayer:ChatPrint( "[red]You are already in a duel with this player or have a duel request from them. Type !duelrequests to check your requests.")
        return
    end

    -- I have no idea how to avoid this loop.
    for fromID, j in pairs(DuelData) do
        if j.toID == toPlayer:SteamID() and j.points == points then
            fromPlayer:ChatPrint( "[red]This player already has a duel request for this amount.")
            return
        end
    end

    -- The reason I store the usernames here is because if the player leaves this lets me still use their name in messages.
    DuelData[fromPlayer:SteamID()] = {
        toID = toPlayer:SteamID(),
        fromName = fromPlayer:Nick(),
        toName = toPlayer:Nick(),
        requestTime = CurTime(),
        requestAccepted = false,
        duelStarted = false,
        points = points,
        kills = kills,
        fromPoints = 0,
        toPoints = 0
    }

    fromPlayer:ChatPrint("[orange]" .. toPlayer:Nick() .. " was challenged to a duel.")
    toPlayer:ChatPrint("[orange]" .. fromPlayer:Nick() .. " challenged you to a duel with a win condition of " .. kills .. " kills and a price of [rainbow]" .. string.Comma(points) .. " points[orange]. Say !duel accept " .. points .. " to accept.")
end

-- This can probably be cleaned up in some way aswell, not sure how though. 
function checkDuelRequest(toPlayer, points)
    local foundRequest = false
    for fromID, j in pairs(DuelData) do
        if j.toID == toPlayer:SteamID() and j.points == points then
            local fromPlayer = player.GetBySteamID(fromID)

            foundRequest = true

            -- Stacking the SS_TryTakePoints functions to make sure the players have enough points to take and otherwise refund player 1.
            -- I feel like checking the points first and then giving them is a lot cleaner to look at but swamp told me to use this so I will.
            fromPlayer:SS_TryTakePoints(
                points,
                function()
                    fromPlayer:SS_TryTakePoints(
                        points,
                        function()
                            fromPlayer:ChatPrint("[orange]" .. j.toName .. " accepted your duel request, duel will start in 20 seconds!")
                            toPlayer:ChatPrint("[orange]Your duel with " .. j.fromName .. " will start in 20 seconds!")

                            j.requestAccepted = true;

                            local time = 20
                            timer.Create( "CountdownDuel" .. fromID, 1, 20, function()
                                time = time - 1
                                if ({[15] = true,[10] = true,[5] = true,[4] = true,[3] = true,[2] = true,[1] = true, [0] = true})[time] then

                                    -- Check if either of the players left the game and cancel the duel.
                                    if not IsValid(fromPlayer) and IsValid(toPlayer) then
                                        toPlayer:SS_GivePoints(j.points * 2)
                                        BotSayGlobal("[fbc]" .. j.toName .. " won a duel worth [rainbow]" .. string.Comma(j.points * 2) .. " points [fbc]against [gold]" .. j.fromName .. "[fbc]. Their opponent left the game.")
                                        DuelData[fromID] = nil
                                        timer.Remove( "CountdownDuel"  .. fromID )
                                        return
                                    elseif not IsValid(toPlayer) and IsValid(fromPlayer) then
                                        fromPlayer:SS_GivePoints(j.points * 2)
                                        BotSayGlobal("[fbc]" .. j.fromName .. " won a duel worth [rainbow]" .. string.Comma(j.points * 2) .. " points [fbc]against [gold]" .. j.toName .. "[fbc]. Their opponent left the game.")
                                        DuelData[fromID] = nil
                                        timer.Remove( "CountdownDuel"  .. fromID )
                                        return
                                    elseif not IsValid(toPlayer) and IsValid(notfromPlayer) then
                                        DuelData[fromID] = nil
                                        timer.Remove( "CountdownDuel"  .. fromID )
                                        return
                                    end

                                    if time > 0 then
                                        fromPlayer:ChatPrint("[orange]Duel against " .. j.toName .. " starts in " .. time .. " seconds")
                                        toPlayer:ChatPrint("[orange]Duel against " .. j.fromName .. "  starts in " .. time .. " seconds")
                                    else
                                        j.duelStarted = true
                                        fromPlayer:ChatPrint("[orange]It's time to d-d-d-duel!")
                                        toPlayer:ChatPrint("[orange]It's time to d-d-d-duel!")
                                    end
                                end
                            end)
                        end,
                        function()
                            fromPlayer:ChatPrint( "[red]" .. j.fromName .. " Accepted your duel but they no longer have enough points to fight." )
                            toPlayer:ChatPrint( "[red]You no longer have enough points to fight this duel." )
                            DuelData[fromID] = nil

                            -- Refund player 1
                            fromPlayer:SS_GivePoints(points)
                        end
                    )
                end,
                function()
                    -- No need to refund anything here.
                    DuelData[fromID] = nil
                    fromPlayer:ChatPrint( "[red]" .. j.fromName .. " Accepted your duel but you no longer have enough points to fight." )
                    toPlayer:ChatPrint( "[red]The player who requested this duel no longer has enough points." )
                end
            )
        end
    end
    if not foundRequest then
        showRequests(toPlayer)
    end
end

function showRequests(ply)
    ply:ChatPrint("[orange]Duel requests:")
    local index = 1

    local hasRequests = false
    for fromID, j in pairs(DuelData) do
        local toPlayer = player.GetBySteamID(j.toID)
        local fromPlayer = player.GetBySteamID(fromID)
        if toPlayer ~= nil and toPlayer == ply and fromPlayer and not j.requestAccepted then
            ply:ChatPrint("[orange](" .. index .. ") [gold]" .. string.Comma(j.points) .. "[orange] points, first to " .. j.kills .. " kills. from [edgy]" .. j.fromName)
            hasRequests = true
            index = index + 1
        end
    end

    if not hasRequests then
        ply:ChatPrint("[orange]You have no requests.")
    end
end

hook.Add( "PlayerDeath", "GlobalDeathMessage", function( victim, inflictor, attacker )
    if attacker:IsPlayer() then
        for fromID, j in pairs(DuelData) do
            local fromPlayer = player.GetBySteamID(fromID)
            local toPlayer = player.GetBySteamID(j.toID)

            if victim == fromPlayer and attacker == toPlayer then
                j.toPoints = j.toPoints + 1
            elseif attacker == fromPlayer and victim == toPlayer then
                j.fromPoints = j.fromPoints + 1
            else
                return
            end

            if j.fromPoints > j.toPoints then
                fromPlayer:ChatPrint("[orange]Duel Score - [green]" .. j.fromName .. ": " .. j.fromPoints .. " | [edgy]" .. j.toName .. ": " .. j.toPoints)
                toPlayer:ChatPrint("[orange]Duel Score - [green]" .. j.fromName .. ": " .. j.fromPoints .. " | [edgy]" .. j.toName .. ": " .. j.toPoints)
            elseif j.fromPoints < j.toPoints then
                fromPlayer:ChatPrint("[orange]Duel Score - [red]" .. j.fromName .. ": " .. j.fromPoints .. " | [green]" .. j.toName .. ": " .. j.toPoints)
                toPlayer:ChatPrint("[orange]Duel Score - [red]" .. j.fromName .. ": " .. j.fromPoints .. " | [green]" .. j.toName .. ": " .. j.toPoints)
            else
                fromPlayer:ChatPrint("[orange]Duel Score - [green]" .. j.fromName .. ": " .. j.fromPoints .. " | " .. j.toName .. ": " .. j.toPoints)
                toPlayer:ChatPrint("[orange]Duel Score - [green]" .. j.fromName .. ": " .. j.fromPoints .. " | " .. j.toName .. ": " .. j.toPoints)
            end
        end
    end
end )