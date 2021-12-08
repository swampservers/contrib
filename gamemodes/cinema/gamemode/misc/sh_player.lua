-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
if CLIENT then
    CreateConVar("cl_playercolor", "0.24 0.34 0.41", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - not between 0-255")
    -- CreateConVar("cl_weaponcolor", "0.30 1.80 2.10", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - not between 0-255")
end

function Player:StaffControlTheater()
    local minn = 2

    if not CH then
        while minn do
            minn = minn + 1
        end
    end

    if self:GetTheater() and self:GetTheater():Name() == "Movie Theater" then
        minn = 1
    end

    return self:GetRank() >= minn
end

function GM:OnPlayerChat(player, strText, bTeamOnly, bPlayerIsDead)
    --
    -- I've made this all look more complicated than it is. Here's the easy version
    --
    -- chat.AddText( player, Color( 255, 255, 255 ), ": ", strText )
    --
    local tab = {}
    local slashme = false

    --if string.sub( strText, 1, 4 ) == "/me " then slashme=true strText = strText:sub(5) end
    if (bPlayerIsDead) then
        table.insert(tab, Color(255, 30, 40))
        table.insert(tab, "*DEAD* ")
    end

    if (bTeamOnly) then
        table.insert(tab, Color(123, 32, 29))
        table.insert(tab, "(G) ")
    else
        if player.GetLocation ~= nil then
            if IsValid(Me) and IsValid(player) and (Me:GetLocation() ~= player:GetLocation()) and (Me:InTheater() or player:InTheater()) and Me:GetRank() >= 2 then
                table.insert(tab, Color(128, 128, 128))
                table.insert(tab, "[" .. player:GetLocationName() .. "] ")
            end
        end
    end

    if slashme then
        table.insert(tab, " ")
    end

    if IsValid(player) then
        table.insert(tab, player)
    else
        table.insert(tab, "Console")
    end

    table.insert(tab, Color(255, 255, 255))

    if slashme then
        table.insert(tab, " ")
    else
        table.insert(tab, ": ")
    end

    if (string.sub(strText, 1, 1) == ">" and string.len(strText) > 1) then
        table.insert(tab, Color(186, 255, 0, 255))
    end

    strText = strText:gsub("''", '"') --fix for fedorachat bullshit
    table.insert(tab, strText)

    if IsValid(player) then
        chat.AddText(unpack(tab))
    else
        MsgN(unpack(tab))
    end

    return true
end

function GM:PlayerNoClip(pl, on)
    return pl.swamp_god or false
end
