DuelRequests = DuelRequests or {}
AcceptedDuels = AcceptedDuels or {}
ActiveDuels = ActiveDuels or {}

RegisterChatCommand({"duel"}, function(player1, arg)
    local args = string.Explode(" ", arg)

    local kills = args[1]:lower() ~= "accept" and tonumber(args[#args]) or nil
    local points = args[1]:lower() == "accept" and tonumber(args[#args]) or tonumber(args[#args - 1])

    points = (points ~= nil and math.floor(points)) or nil

    if args[1]:lower() == "accept" and points ~= nil then
        checkDuelRequest(player1, points)
        return
    elseif (args[1]:lower() == "accept" and points == nil) then
        player1:ChatPrint("[orange]!duel accept [confirm number of points]")
        return
    end

    if points == nil or kills == nil then
        player1:ChatPrint("[orange]!duel [player] [amount of points] [number of kills to win]")
    else
        table.remove(args)
        table.remove(args)

        local player2, count = PlyCount(string.Implode(" ", args))
        if count == 1 then
            if (kills <= 20 ) then
                if (kills >= 1) then
                    if player1 == player2 then
                        player1:ChatPrint("[red]You can't duel yourself!")
                    elseif points >= 1000 then
                        requestDuel(player1, player2, points, kills)
                    else
                        player1:ChatPrint("[red]A duel must be worth a minimum of 1000 points.")
                    end
                else
                    player1:ChatPrint("[red]The win condition can not be less than 1 kill.")
                end
            else
                player1:ChatPrint("[red]The win condition can not be more than 20 kills.")
            end
        else
            player1:ChatPrint("[red]Player " .. string.Implode(" ", args) .. " not found.")
        end
    end
end)

function hasPendingDuel(player1ID, player2ID, points)
    local player1 = Player(player1ID)

    for k, v in pairs(ActiveDuels) do
        if (v.player2 == player2ID or v.player1 == player1ID or v.player2 == player1ID or v.player1 == player2ID) then

            if (v.player2 == player2ID and v.player1 == player1ID or v.player2 == player1ID and v.player1 == player2ID) then
                player1:ChatPrint("[red]You are currently in a duel with this player.")
            else
                if (v.player1 == player1ID) then
                    player1:ChatPrint("[red]You are currently in a duel with [orange]" .. Player(v.player2):Nick() .. ".")
                elseif (v.player2 == player1ID) then
                    player1:ChatPrint("[red]You are currently in a duel with [orange]" .. Player(v.player1):Nick() .. ".")
                else
                    player1:ChatPrint("[red]Player is currently in a duel.")
                end
            end
            return true
        end
    end

    for k, v in pairs(DuelRequests) do
        if (v.player2 == player2ID and v.points == points) then
            player1:ChatPrint("[red]Player already has a duel request for that amount.")
            return true
        elseif (v.player1 == player1ID) then
            player1:ChatPrint("[red]You already made a duel request.")
            return true
        end
    end

    for k, v in pairs(AcceptedDuels) do
        if (v.player2 == player2ID and v.points == points) then
            player1:ChatPrint("[red]Player already has a duel request for that amount.")
            return true
        elseif (v.player1 == player1ID) then
            player1:ChatPrint("[red]You already made a duel request.")
            return true
        end
    end

    return false
end


function hasAcceptedDuel(playerID)
    for k, v in pairs(ActiveDuels) do
        if (v.player1 == playerID or v.player2 == playerID) then
            return true
        end
    end

    for k, v in pairs(AcceptedDuels) do
        if (v.player1 == playerID or v.player2 == playerID) then
            return true
        end
    end

    return false
end

function requestDuel(player1, player2, points, kills)
    if (not hasPendingDuel(player1:UserID(), player2:UserID(), points)) then
        player1:ChatPrint("[orange]" .. player2:Nick() .. " was challenged to a duel.")
        player2:ChatPrint("[orange]" .. player1:Nick() .. " challenged you to a duel with a win condition of " .. kills .. " kills and a price of [rainbow]" .. string.Comma(points) .. " points[orange]. Say !duel accept [confirm number of points] to accept.")


        table.insert(DuelRequests, {
            player1 = player1:UserID(),
            player2 = player2:UserID(),
            points = points,
            kills = kills,
            time = CurTime(),
        })
    end
end

timer.Create("Duel", 1, 0, function()
    NewDuelRequests = {}
    for k, v in pairs(DuelRequests) do
        if ((v.time + 30) <= CurTime()) then
            local player1 = Player(v.player1)
            local player2 = Player(v.player2)

            if (player1 and player2) then
                player1:ChatPrint("[edgy]" .. player2:Nick() .. "[orange] doesn't want to fight. Try again later.")
                player2:ChatPrint("[orange]You missed out on a duel with [edgy]" .. player1:Nick() .. "[orange].")
            elseif (not player1 and player2) then
                player2:ChatPrint("[orange]You missed out on a duel.")
            elseif (player1 and not player2) then
                player1:ChatPrint("[red]The player you requested a duel with has left. Try again later.")
            end
        else
            table.insert(NewDuelRequests, v)
        end
    end

    DuelRequests = NewDuelRequests
    local ActiveDuelsNew = {}
    for k, v in pairs(ActiveDuels) do
        local player1 = Player(v.player1)
        local player2 = Player(v.player2)

        if (v.player1_points >= v.kills) then
            player2:SS_TakePoints(amount)
            player1:SS_GivePoints(amount)
            player1:ChatPrint("[green]You won [gold]" .. string.Comma(v.points) .. "[green] points.")
            player2:ChatPrint("[edgy]You lost [gold]" .. string.Comma(v.points) .. "[edgy] points.")
            BotSayGlobal("[fbc]" .. player1:Nick() .. " won a duel worth [rainbow]" .. string.Comma(v.points * 2) .. " points [fbc] against [gold]" .. player2:Nick() .. "[fbc]! Final score - [green]" .. player1:Nick() .. ": " .. v.player1_points .. " [fbc]| [edgy]" .. player2:Nick() .. ": " .. v.player2_points)
        elseif (v.player2_points >= v.kills) then
            player1:SS_TakePoints(amount)
            player2:SS_GivePoints(amount)
            player2:ChatPrint("[green]You won [gold]" .. string.Comma(v.points) .. "[green] points.")
            player1:ChatPrint("[edgy]You lost [gold]" .. string.Comma(v.points) .. "[edgy] points.")
            BotSayGlobal("[fbc]" .. player2:Nick() .. " won a duel worth [rainbow]" .. string.Comma(v.points * 2) .. " points [fbc] against [gold]" .. player1:Nick() .. "[fbc]! Final score - [green]" .. player2:Nick() .. ": " .. v.player2_points .. " [fbc]| [edgy]" .. player1:Nick() .. ": " .. v.player1_points)
        else
            table.insert(ActiveDuelsNew, v)
        end
    end
    ActiveDuels = ActiveDuelsNew
end)

function checkDuelRequest(player2, points)
    if (hasAcceptedDuel(player2:UserID())) then
        player2:ChatPrint("[red]You can not accept multiple duels at the same time.")
        return
    end

    for k, v in pairs(DuelRequests) do
        local player1 = Player(v.player1)
        if v.player2 == player2:UserID() and v.points == points then
            if (hasAcceptedDuel(v.player1)) then
                player2:ChatPrint("[red]The player you are trying to fight already has a active duel.")
                return
            end
            player1:ChatPrint("[orange]" .. player2:Nick() .. " accepted your duel request, duel will start in 20 seconds!")
            player2:ChatPrint("[orange]Your duel with " .. player1:Nick() .. " will start in 20 seconds!")

            table.insert(AcceptedDuels, {player1 = v.player1, player2 = v.player2, points = v.points, kills = v.kills})

            local time = 20
            timer.Create( "CountdownDuel", 1, 20, function()
                time = time - 1
                if (time == 15) then
                    player1:ChatPrint("[orange]Duel starts in 15 seconds")
                    player2:ChatPrint("[orange]Duel starts in 15 seconds")
                elseif (time == 10) then
                    player1:ChatPrint("[orange]Duel starts in 10 seconds")
                    player2:ChatPrint("[orange]Duel starts in 10 seconds")
                elseif (time == 5) then
                    player1:ChatPrint("[orange]Duel starts in 5 seconds")
                    player2:ChatPrint("[orange]Duel starts in 5 seconds")
                elseif (time < 5 and time > 1) then
                    player1:ChatPrint("[orange]Duel starts in " .. time .. " seconds")
                    player2:ChatPrint("[orange]Duel starts in " .. time .. " seconds")
                elseif (time == 1) then
                    player1:ChatPrint("[orange]Duel starts in 1 second")
                    player2:ChatPrint("[orange]Duel starts in 1 second")
                elseif (time == 0) then
                    startDuel(#AcceptedDuels)
                end
            end )

            return
        end
    end


    player2:ChatPrint("[red]You don't have a duel request for that  amount!")
    player2:ChatPrint("[orange]Duels:")
    local index = 1

    for k, v in pairs(DuelRequests) do
        if v.player2 == player2:UserID() then
            local player1 = Player(v.player1)

            if player1 then
                player2:ChatPrint("[orange](" .. index .. ") [gold]" .. string.Comma(v.points) .. "[orange] from [edgy]" .. player1:Nick())
            end

            index = index + 1
        end
    end

end

function startDuel(duelIndex)

    local duel = AcceptedDuels[duelIndex]

    local player1 = Player(duel.player1)
    local player2 = Player(duel.player2)

    if (not player1) then
        AcceptedDuels[duelIndex] = nil
        player2:ChatPrint("[red]The challenger has left, duel cancelled.")
    elseif /*player1:SS_HasPoints(amount) and player2:SS_HasPoints(amount)*/ true then
        player2:ChatPrint("[orange]It's time to d-d-d-duel!")
        player1:ChatPrint("[orange]It's time to d-d-d-duel!")

        table.insert(ActiveDuels, {player1 = duel.player1, player2 = duel.player2, points = duel.points, kills = duel.kills, player1_points = 0, player2_points = 0})
        AcceptedDuels[duelIndex] = nil
    else
        AcceptedDuels[duelIndex] = nil
        player2:ChatPrint("[red]ERROR: No points have been taken. Duel cancelled.")
        player1:ChatPrint("[red]ERROR: No points have been taken. Duel cancelled.")
    end
end


hook.Add( "PlayerDeath", "GlobalDeathMessage", function( victim, inflictor, attacker )
    for k, v in pairs(ActiveDuels) do
        local player1 = Player(v.player1)
        local player2 = Player(v.player2)
        if (attacker:IsPlayer()) then
            if ( victim:UserID() == v.player1 and attacker:UserID() == v.player2 ) then
                v.player2_points = v.player2_points + 1
            elseif ( attacker:UserID() == v.player1 and victim:UserID() == v.player2 ) then
                v.player1_points = v.player1_points + 1
            end
            if ( victim:UserID() == v.player1 and attacker:UserID() == v.player2 or attacker:UserID() == v.player1 and victim:UserID() == v.player2 ) then
                if (v.player1_points > v.player2_points) then
                    player1:ChatPrint("[orange]Duel Score - [green]" .. player1:Nick() .. ": " .. v.player1_points .. " | [edgy]" .. player2:Nick() .. ": " .. v.player2_points)
                    player2:ChatPrint("[orange]Duel Score - [green]" .. player1:Nick() .. ": " .. v.player1_points .. " | [edgy]" .. player2:Nick() .. ": " .. v.player2_points)
                elseif (v.player1_points < v.player2_points) then
                    player2:ChatPrint("[orange]Duel Score - [green]" .. player2:Nick() .. ": " .. v.player2_points .. " | [edgy]" .. player1:Nick() .. ": " .. v.player1_points)
                    player1:ChatPrint("[orange]Duel Score - [green]" .. player2:Nick() .. ": " .. v.player2_points .. " | [edgy]" .. player1:Nick() .. ": " .. v.player1_points)
                else
                    player2:ChatPrint("[orange]Duel Score - [green]" .. player1:Nick() .. ": " .. v.player2_points .. " | [edgy]" .. player2:Nick() .. ": " .. v.player1_points)
                    player1:ChatPrint("[orange]Duel Score - [green]" .. player1:Nick() .. ": " .. v.player2_points .. " | [edgy]" .. player2:Nick() .. ": " .. v.player1_points)
                end
            end
        end
    end
end )