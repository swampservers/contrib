-- This file is subject to copyright - contact swampservers@gmail.com for more information.
RegisterChatLUACommand({'help', 'motd'}, 'ShowMotd("https://steamcommunity.com/groups/swampservers/discussions/0/133255810024702956/")')

RegisterChatConsoleCommand({'skip', 'voteskip'}, "cinema_voteskip")

RegisterChatLUACommand('thirdperson', "THIRDPERSON = !THIRDPERSON")

RegisterChatLUACommand({'global', 'globalchat', 'ooc'}, [[ChatMessage(Color.orange,"Press "..input.LookupBinding("messagemode2"):upper().." to speak in Global chat.")]])

RegisterChatLUACommand({'golf', 'golfclub'}, [[ChatMessage(Color.orange,"Walk up to a golf rack to grab a golf club!")]])

RegisterChatCommand({'kills', 'showkills'}, function(ply, arg)
    WhoSeesChat(ply, true):NamedBotMessage(ply, " has gotten ", Style.edgy(ply:GetStat("kill")), " kills!")
end, {
    global = true,
    throttle = true
})

RegisterChatCommand({'deaths', 'showdeaths'}, function(ply, arg)
    WhoSeesChat(ply, true):NamedBotMessage(ply, " has died ", Style.edgy(ply:GetStat("death")), " times!")
end, {
    global = true,
    throttle = true
})

RegisterChatCommand({'playtime', 'showplaytime', 'hours'}, function(ply, arg)
    WhoSeesChat(ply, true):NamedBotMessage(ply, " has played for ", Style.rainbow(math.floor(ply:GetStat("sec") / 3600)), " hours!")
end, {
    global = true,
    throttle = true
})

RegisterChatConsoleCommand({'drop', 'dropweapon'}, "drop")

RegisterChatConsoleCommand('dropall', "dropall")

RegisterChatCommand({'rent', 'protect'}, function(ply, arg)
    TryProtectTheater(ply)
end)

RegisterChatCommand({'callnoz'}, function(ply, arg)
    if ply:GetRank() < 1 then return end
    arg = (arg .. "   from " .. ply:Name() .. " " .. ply:SteamID64()):gsub("[^a-zA-Z0-9 ]", "")

    if not Shell then
        require("shell")
    end

    Shell.Execute({"/swamp/gm_shell/notify.sh", "<@656202383034155021> /callnoz " .. arg}, function(code)
        print(code)
    end)
end, {
    global = true,
    throttle = true
})
