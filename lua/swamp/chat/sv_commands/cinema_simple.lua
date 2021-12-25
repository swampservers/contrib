-- This file is subject to copyright - contact swampservers@gmail.com for more information.
RegisterChatLUACommand({'help', 'motd'}, 'ShowMotd("http://steamcommunity.com/groups/swampservers/discussions/0/133255810024702956/")')

RegisterChatConsoleCommand({'skip', 'voteskip'}, "cinema_voteskip")

RegisterChatLUACommand('title', "OpenTitlePicker()")
RegisterChatLUACommand('thirdperson', "THIRDPERSON = !THIRDPERSON")
RegisterChatLUACommand('virtualreality', "BOBBINGVIEW = !BOBBINGVIEW")

RegisterChatLUACommand({'global', 'globalchat', 'ooc'}, [[chat.AddText("[orange]Press "..input.LookupBinding("messagemode2"):upper().." to speak in Global chat.")]])

RegisterChatLUACommand({'golf', 'golfclub'}, [[chat.AddText("[orange]Walk up to a golf rack to grab a golf club!")]])

RegisterChatCommand({'kills', 'showkills'}, function(ply, arg)
    BotSayGlobal(ply:Nick() .. " has gotten [edgy]" .. ply:GetStat("kills_legacy") .. "[fbc] lifetime kills!")
end, {
    global = true,
    throttle = true
})

RegisterChatCommand({'deaths', 'showdeaths'}, function(ply, arg)
    BotSayGlobal(ply:Nick() .. " has died [edgy]" .. ply:GetStat("deaths_legacy") .. "[fbc] times!")
end, {
    global = true,
    throttle = true
})

RegisterChatCommand({'playtime', 'showplaytime', 'hours'}, function(ply, arg)
    BotSayGlobal(ply:Nick() .. " has played for [rainbow]" .. math.floor(ply:GetStat("minutes_legacy") / 60) .. "[fbc] hours!")
end, {
    global = true,
    throttle = true
})

RegisterChatConsoleCommand({'drop', 'dropweapon'}, "drop")

concommand.Add("drop", function(ply, cmd, args)
    ply.LastWepDropTime = ply.LastWepDropTime or 0
    if CurTime() - ply.LastWepDropTime < 2 then return end
    ply.LastWepDropTime = CurTime()
    local w = ply:GetActiveWeapon()

    if IsValid(w) then
        local cl = w:GetClass()
        if cl == "weapon_ebola" then return end
        if cl == "weapon_tag" then return end

        if w.DropOnGround then
            ply:DropWeapon(wep)

            timer.Simple(5, function()
                if IsValid(wep) and not IsValid(wep.Owner) then
                    wep:Remove()
                end
            end)
        else
            ply:StripWeapon(cl)
        end
    end
end)

RegisterChatConsoleCommand('dropall', "dropall")

concommand.Add("dropall", function(ply, cmd, args)
    ply.LastWepDropTime = ply.LastWepDropTime or 0
    if CurTime() - ply.LastWepDropTime < 2 then return end
    ply.LastWepDropTime = CurTime()

    for k, v in pairs(ply:GetWeapons()) do
        local cl = v:GetClass()

        if cl ~= "weapon_ebola" or cl ~= "weapon_tag" then
            ply:StripWeapon(cl)
        end
    end
end)

RegisterChatCommand({'rent', 'protect'}, function(ply, arg)
    TryProtectTheater(ply)
end)

timer.Create("steamspam", 100, 0, function()
    if math.random() < 0.1 then
        for k, v in pairs(player.GetAll()) do
            v:ChatPrint("[orange]Say [gold]/join[orange] to join our steam chat (and click 'Enter chat room') but don't be mean!")
        end
    end
end)
