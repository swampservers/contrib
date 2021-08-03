DuelRequests = DuelRequests or {}
AcceptedDuels = AcceptedDuels or {}
ActiveDuels = ActiveDuels or {}

RegisterChatCommand({"duels"}, function(ply, arg)
    showRequests(ply)
end)

RegisterChatCommand({"duel"}, function(ply, arg)
    local args = string.Explode(" ", arg)

    local kills = args[1]:lower() ~= "accept" and tonumber(args[#args]) or nil
    local points = args[1]:lower() == "accept" and tonumber(args[#args]) or tonumber(args[#args - 1])

    points = (points ~= nil and math.floor(points)) or nil

    if args[1]:lower() == "accept" and points ~= nil then
        checkDuelRequest(ply, points)
        return
    elseif (args[1]:lower() == "accept" and points == nil) then
        ply:ChatPrint("[orange]!duel accept [confirm number of points]")
        return
    end

    if points == nil or kills == nil then
        ply:ChatPrint("[orange]!duel [player] [amount of points] [number of kills to win]")
    else
        table.remove(args)
        table.remove(args)
        local target, count = PlyCount(string.Implode(" ", args))
        if count == 1 then
            if (kills <= 20 ) then
                if (kills >= 1) then
                    if ply == target then
                        ply:ChatPrint("[red]You can't duel yourself!")
                    elseif points >= 1000 then
                        if (ply:SS_HasPoints(points)) then
                            if (target:SS_HasPoints(points)) then
                                requestDuel(ply, target, points, kills)
                            else
                                ply:ChatPrint("[red]The challenged player does not have enough points.")
                            end
                        else
                            ply:ChatPrint("[red]You do not have enough points to request this duel.")
                        end
                    else
                        ply:ChatPrint("[red]A duel must be worth a minimum of 1000 points.")
                    end
                else
                    ply:ChatPrint("[red]The win condition can not be less than 1 kill.")
                end
            else
                ply:ChatPrint("[red]The win condition can not be more than 20 kills.")
            end
        else
            ply:ChatPrint("[red]Player " .. string.Implode(" ", args) .. " not found.")
        end
    end
end)

function findDuel(ply)
    for k, v in pairs(ActiveDuels) do
        if (v.target == ply or v.challenger == ply) then
            return v
        end
    end

    for k, v in pairs(AcceptedDuels) do
        if (v.challenger == ply or v.target == ply) then
            return v
        end
    end
    return nil
end


function findRequestIndex(ply, points)
    for k, v in pairs(DuelRequests) do
        if (v.target == ply and v.points == points) then
            return k
        end
    end
    return nil
end

function hasRequests(ply)
    for k, v in pairs(DuelRequests) do
        if (v.target == ply) then
            return true
        end
    end
    return false
end


function showRequests(ply)
    if (not hasRequests(ply)) then
        ply:ChatPrint("[red]You have no duel requests.")
        return
    end
    ply:ChatPrint("[orange]Duel requests:")
    local index = 1

    for k, v in pairs(DuelRequests) do
        if v.target == ply then

            if v.challenger then
                ply:ChatPrint("[orange](" .. index .. ") [gold]" .. string.Comma(v.points) .. "[orange] from [edgy]" .. v.challenger:Nick())
            end

            index = index + 1
        end
    end
end

function requestDuel(challenger, target, points, kills)

    local challengerDuel = findDuel(challenger)

    if (challengerDuel) then
        challenger:ChatPrint("[red]You are currently in a duel with [orange]" .. challengerDuel.target:Nick() .. "[red]. You can not start multiple duels.")
        return
    elseif (findDuel(target)) then
        challenger:ChatPrint("[red]Target is already in a duel.")
        return
    elseif (findRequestIndex(target, points)) then
        challenger:ChatPrint("[red]Target already has a duel request for that amount.")
        return
    end

    challenger:ChatPrint("[orange]" .. target:Nick() .. " was challenged to a duel.")
    target:ChatPrint("[orange]" .. challenger:Nick() .. " challenged you to a duel with a win condition of " .. kills .. " kills and a price of [rainbow]" .. string.Comma(points) .. " points[orange]. Say !duel accept [confirm number of points] to accept.")


    table.insert(DuelRequests, {
        challenger = challenger,
        target = target,
        points = points,
        kills = kills,
        time = CurTime(),
    })
end

timer.Create("Duel", 1, 0, function()
    NewDuelRequests = {}
    for k, v in pairs(DuelRequests) do
        if ((v.time + 30) <= CurTime()) then

            if (v.challenger and v.target) then
                v.challenger:ChatPrint("[edgy]" .. v.target:Nick() .. "[orange] doesn't want to fight. Try again later.")
                v.target:ChatPrint("[orange]You missed out on a duel with [edgy]" .. v.challenger:Nick() .. "[orange].")
            elseif (not v.challenger and v.target) then
                v.target:ChatPrint("[orange]You missed out on a duel.")
            elseif (v.challenger and not v.target) then
                v.challenger:ChatPrint("[red]The player you requested a duel with has left. Try again later.")
            end
        else
            table.insert(NewDuelRequests, v)
        end
    end

    DuelRequests = NewDuelRequests
    local ActiveDuelsNew = {}
    for k, v in pairs(ActiveDuels) do

        if (v.challenger_points >= v.kills) then
            v.challenger:SS_GivePoints(v.points * 2)
            v.challenger:ChatPrint("[green]You won [gold]" .. string.Comma(v.points) .. "[green] points.")
            v.target:ChatPrint("[edgy]You lost [gold]" .. string.Comma(v.points) .. "[edgy] points.")
            BotSayGlobal("[fbc]" .. v.challenger:Nick() .. " won a duel worth [rainbow]" .. string.Comma(v.points * 2) .. " points [fbc] against [gold]" .. v.target:Nick() .. "[fbc]! Final score - [green]" .. v.challenger:Nick() .. ": " .. v.challenger_points .. " [fbc]| [edgy]" .. v.target:Nick() .. ": " .. v.target_points)
        elseif (v.target_points >= v.kills) then
            v.target:SS_GivePoints(v.points * 2)
            v.target:ChatPrint("[green]You won [gold]" .. string.Comma(v.points) .. "[green] points.")
            v.challenger:ChatPrint("[edgy]You lost [gold]" .. string.Comma(v.points) .. "[edgy] points.")
            BotSayGlobal("[fbc]" .. v.target:Nick() .. " won a duel worth [rainbow]" .. string.Comma(v.points * 2) .. " points [fbc] against [gold]" .. v.challenger:Nick() .. "[fbc]! Final score - [green]" .. v.target:Nick() .. ": " .. v.target_points .. " [fbc]| [edgy]" .. v.challenger:Nick() .. ": " .. v.challenger_points)
        else
            table.insert(ActiveDuelsNew, v)
        end
    end
    ActiveDuels = ActiveDuelsNew
end)

function checkDuelRequest(target, points)

    local duelIndex = findRequestIndex(target, points)
    local duel = DuelRequests[duelIndex]

    if (duel == nil) then
        target:ChatPrint("[red]You don't have a duel request for that amount!")
        showRequests(target)
        return
    end

    if (findDuel(target)) then
        target:ChatPrint("[red]You can not accept multiple duels at the same time.")
        return
    elseif (findDuel(duel.challenger)) then
        target:ChatPrint("[red]The player you are trying to fight already has a active duel.")
        return
    elseif (not duel.challenger:SS_HasPoints(duel.points)) then
        duel.challenger:ChatPrint("[red]You do not have enough points, duel was cancelled.")
        duel.target:ChatPrint("[red]The challenger does not have enough points, duel was cancelled.")
        DuelRequests[duelIndex] = nil
        return
    elseif (not duel.target:SS_HasPoints(duel.points)) then
        duel.target:ChatPrint("[red]You do not have enough points to accept this duel.")
        duel.challenger:ChatPrint("[red]The challenged player does not have enough points, duel was cancelled.")
        DuelRequests[duelIndex] = nil
        return
    end

    duel.challenger:ChatPrint("[orange]" .. duel.target:Nick() .. " accepted your duel request, duel will start in 20 seconds!")
    duel.target:ChatPrint("[orange]Your duel with " .. duel.challenger:Nick() .. " will start in 20 seconds!")

    duel.challenger:SS_TakePoints(duel.points)
    duel.target:SS_TakePoints(duel.points)

    table.insert(AcceptedDuels, {challenger = duel.challenger, target = duel.target, points = duel.points, kills = duel.kills})
    DuelRequests[duelIndex] = nil;

    startCountdown(#AcceptedDuels)
end

function startCountdown(duelIndex)
    local duel = AcceptedDuels[duelIndex]
    local time = 20
    timer.Create( "CountdownDuel", 1, 20, function()
        time = time - 1
        if (time == 15) then
            duel.challenger:ChatPrint("[orange]Duel starts in 15 seconds")
            duel.target:ChatPrint("[orange]Duel starts in 15 seconds")
        elseif (time == 10) then
            duel.challenger:ChatPrint("[orange]Duel starts in 10 seconds")
            duel.target:ChatPrint("[orange]Duel starts in 10 seconds")
        elseif (time == 5) then
            duel.challenger:ChatPrint("[orange]Duel starts in 5 seconds")
            duel.target:ChatPrint("[orange]Duel starts in 5 seconds")
        elseif (time < 5 and time > 1) then
            duel.challenger:ChatPrint("[orange]Duel starts in " .. time .. " seconds")
            duel.target:ChatPrint("[orange]Duel starts in " .. time .. " seconds")
        elseif (time == 1) then
            duel.challenger:ChatPrint("[orange]Duel starts in 1 second")
            duel.target:ChatPrint("[orange]Duel starts in 1 second")
        elseif (time == 0) then
            startDuel(duelIndex)
        end
    end )
end

function startDuel(duelIndex)
    local duel = AcceptedDuels[duelIndex]

    if (not duel.target) then
        AcceptedDuels[duelIndex] = nil
        duel.challenger:ChatPrint("[red]The challenger has left, duel was cancelled.")
    elseif (not duel.challenger) then
        AcceptedDuels[duelIndex] = nil
        duel.target:ChatPrint("[red]The challenged player has left, duel was cancelled.")
    else
        duel.target:ChatPrint("[orange]It's time to d-d-d-duel!")
        duel.challenger:ChatPrint("[orange]It's time to d-d-d-duel!")

        table.insert(ActiveDuels, {challenger = duel.challenger, target = duel.target, points = duel.points, kills = duel.kills, challenger_points = 0, target_points = 0})
        AcceptedDuels[duelIndex] = nil
    end
end


hook.Add( "PlayerDeath", "GlobalDeathMessage", function( victim, inflictor, attacker )
    if (attacker:IsPlayer()) then
        local victimDuel = findDuel(victim)
        if (victimDuel ~= nil) then
            if ( victim == victimDuel.challenger and attacker == victimDuel.target ) then
                victimDuel.target_points = victimDuel.target_points + 1
            elseif ( attacker == victimDuel.challenger and victim == victimDuel.target ) then
                victimDuel.challenger_points = victimDuel.challenger_points + 1
            end

            if (victimDuel.challenger_points > victimDuel.target_points) then
                victimDuel.challenger:ChatPrint("[orange]Duel Score - [green]" .. victimDuel.challenger:Nick() .. ": " .. victimDuel.challenger_points .. " | [edgy]" .. victimDuel.target:Nick() .. ": " .. victimDuel.target_points)
                victimDuel.target:ChatPrint("[orange]Duel Score - [green]" .. victimDuel.challenger:Nick() .. ": " .. victimDuel.challenger_points .. " | [edgy]" .. victimDuel.target:Nick() .. ": " .. victimDuel.target_points)
            elseif (victimDuel.challenger_points < victimDuel.target_points) then
                victimDuel.target:ChatPrint("[orange]Duel Score - [green]" .. victimDuel.target:Nick() .. ": " .. victimDuel.target_points .. " | [edgy]" .. victimDuel.challenger:Nick() .. ": " .. victimDuel.challenger_points)
                victimDuel.challenger:ChatPrint("[orange]Duel Score - [green]" .. victimDuel.target:Nick() .. ": " .. victimDuel.target_points .. " | [edgy]" .. victimDuel.challenger:Nick() .. ": " .. victimDuel.challenger_points)
            else
                victimDuel.target:ChatPrint("[orange]Duel Score - [green]" .. victimDuel.challenger:Nick() .. ": " .. victimDuel.target_points .. " | [edgy]" .. victimDuel.target:Nick() .. ": " .. victimDuel.challenger_points)
                victimDuel.challenger:ChatPrint("[orange]Duel Score - [green]" .. victimDuel.challenger:Nick() .. ": " .. victimDuel.target_points .. " | [edgy]" .. victimDuel.target:Nick() .. ": " .. victimDuel.challenger_points)
            end
        end
    end
end )