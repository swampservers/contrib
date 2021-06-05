-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- This script is designed to send false button copies to clients who are collecting buttons at an excessive rate to try to create difficulty in locating them using cheating.
local FAKES = {}
MAGICBUTTONS_FAKES_RECIPIENT = RecipientFilter()

function MAGICBUTTON_SENDFILTER(button)

    local recip = RecipientFilter()

    for k, v in pairs(player.GetHumans()) do
        if (v:GetPos():Distance(button:GetPos()) <= MAGICBUTTON_TRANSMIT_DISTANCE and (v.MagicButtonsPressed or 0) < 5) then
            recip:AddPlayer(v)
        end
    end
    return recip
end

function MAGICBUTTON_MODIFY(ply)
    if (ply.MagicButtonsPressed > 5) then
        print("FORCING SHITTY PRIZE FOR  " .. ply:Nick() .. "(" .. ply:SteamID64() .. "). SUSSY!!!!!!")
        return true
    end
    return false
end

--if the player presses a button less than 7 minutes apart, start sending them fakes.
function MAGICBUTTON_STAT_TRACKING(ply)
    ply.MagicButtonsPressed = (ply.MagicButtonsPressed or 0) + (ply:IsAdmin() and 0 or 1)
    local expiry = 60 * 5

    if (ply.MagicButtonsPressed > 1) then
        print("SUSPICIOUS BUTTON ACTIVITY FROM " .. ply:Nick() .. "(" .. ply:SteamID64() .. "). Adding them to obfuscation list.")
        MAGICBUTTONS_FAKES_RECIPIENT:AddPlayer(ply)
        expiry = 60 * 30
    end

    timer.Create("fakes_removeplayer" .. ply:UserID(), expiry, 1, function()
        ply.MagicButtonsPressed = nil
        MAGICBUTTONS_FAKES_RECIPIENT:RemovePlayer(ply)
    end)
end

local function TransmitFakes()
    local button = Entity(next(Ents.magicbutton))
    
    if(!IsValid(button))then return end
    local i = math.random(1, 1000)
    if (IsValid(Entity(i)) and Entity(i):GetClass() == "magicbutton") then return end

    if (FAKES[i] == nil) then
        local trace = button:FindHidingSpot()
        local ang = trace.HitNormal:Angle()
        ang:RotateAroundAxis(ang:Right(), -90)
        ang:RotateAroundAxis(ang:Up(), 180)
        local randomcolor = HSVToColor(math.Rand(0, 360), 1, 1)

        FAKES[i] = {trace.HitPos, ang, Color(randomcolor.r, randomcolor.g, randomcolor.b, 0)}
    end

    net.Start("magicbutton_transmitclone")
    net.WriteInt(i, 17)
    net.WriteVector(FAKES[i][1])
    net.WriteAngle(FAKES[i][2])
    net.WriteColor(FAKES[i][3])
    net.WriteBool(false)
    net.WriteInt(10, 7)
    net.Broadcast()
    --net.Send(MAGICBUTTONS_FAKES_RECIPIENT)
end

timer.Create("transmit_fake_buttons", 0.5, 0, function()
    TransmitFakes() 
end)