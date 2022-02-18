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
    BotSayGlobal(ply:Nick() .. " has played for [rainbow]" .. math.floor(ply:GetStat("minutes_legacy") / 60) .. "[fbc] hours!")
end, {
    global = true,
    throttle = true
})

RegisterChatConsoleCommand({'drop', 'dropweapon'}, "drop")

concommand.Add("drop", function(ply, cmd, args)
    -- if ply:RateLimit("dropweapon",0.1,3) then return end
    
    local w = ply:GetActiveWeapon()

    if IsValid(w) then
        if w.CannotDrop then ply:Notify("You can't drop this!") return end

        if w:GetModel()=="" then 
            ply:StripWeapon(w:GetClass())
        else
            ply.DroppedWeapons = ply.DroppedWeapons or {}
            local i = 1
            while ply.DroppedWeapons[i] do
                local dropped = ply.DroppedWeapons[i]
                if IsValid(dropped) and not IsValid(dropped.Owner) then
                    i=i+1
                else
                    table.remove(ply.DroppedWeapons, i)
                end
            end

            if i>3 then
                table.remove(ply.DroppedWeapons, 1):Remove()
            end

            ply:DropWeapon(w)
            w.DroppedWeapon = true
            table.insert(ply.DroppedWeapons, w)
            w:TimerCreate("DropRemove", 5, 1, function()
                if not IsValid(w.Owner) then w:Remove() end
            end)
        end
    end
end)


hook.Add("PlayerCanPickupWeapon", "NoDropAutoPickup", function( ply, weapon )
    if weapon.DroppedWeapon then return false end
end)


hook.Add("PlayerUse", "DropManualPickup", function( ply, ent )
	if ent.DroppedWeapon then 
        ply:PickupWeapon(ent) 
        ply:SelectWeapon(ent:GetClass())
    end
end)

-- Player.BaseDropWeapon = Player.BaseDropWeapon or Player.DropWeapon

-- function Player


RegisterChatConsoleCommand('dropall', "dropall")

concommand.Add("dropall", function(ply, cmd, args)
    for k, v in pairs(ply:GetWeapons()) do
        if not v.CannotDrop then
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
