-- This file is subject to copyright - contact swampservers@gmail.com for more information.
RegisterChatLUACommand({'help', 'motd'}, 'ShowMotd("http://steamcommunity.com/groups/swampservers/discussions/0/133255810024702956/")')

RegisterChatConsoleCommand({'skip', 'voteskip'}, "cinema_voteskip")

RegisterChatLUACommand('title', "OpenTitlePicker()")
RegisterChatLUACommand('thirdperson', "THIRDPERSON = !THIRDPERSON")
RegisterChatLUACommand('virtualreality', "BOBBINGVIEW = !BOBBINGVIEW")

RegisterChatLUACommand({'global', 'globalchat', 'ooc'}, [[chat.AddText("[orange]Press "..input.LookupBinding("messagemode2"):upper().." to speak in Global chat.")]])

RegisterChatLUACommand({'golf', 'golfclub'}, [[chat.AddText("[orange]Walk up to a golf rack to grab a golf club!")]])

RegisterChatCommand({'kills', 'showkills'}, function(ply, arg)
    BotSayGlobal(ply:Nick() .. " has gotten [edgy]" .. ply:GetStat("kills_legacy") .. "[fbc] lifetime kills! (" .. ply:GetStat("kill_active_cinema") .. " active player kills 2022)")
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
    BotSayGlobal(ply:Nick() .. " has played for [rainbow]" .. math.floor(ply:GetStat("minutes_legacy") / 60 + ply:GetStat("sec") / 3600) .. "[fbc] hours!")
end, {
    global = true,
    throttle = true
})

RegisterChatConsoleCommand({'drop', 'dropweapon'}, "drop")

RegisterChatConsoleCommand('dropall', "dropall")

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
