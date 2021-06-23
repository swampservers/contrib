-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- Some basic anti-cheat

function MAGICBUTTON_SENDFILTER(button)

    local recip = RecipientFilter()
    recip:AddPVS(button:GetPos())
    recip:AddPVS(button:GetPos() + button:GetUp()*3)
    
    --recip:AddPAS(button:GetPos())
    
    for k, v in pairs(player.GetHumans()) do
        if (v:GetPos():Distance(button:GetPos()) > HIDDENBUTTON_TRANSMIT_DISTANCE or (v.MagicButtonsTooFastCounter or 0) > 5) then
            recip:RemovePlayer(v)
        end
    end 
    return recip
end

-- if the player is still finding them super consistently, even after being excluded from model transmission, force a shitty prize
function MAGICBUTTON_MODIFY(ply)
    if ((ply.MagicButtonsTooFastCounter or 0) > 5) then
        return true
    end
    return false
end 

--Reset counter
function MAGICBUTTON_STAT_TRACKING(ply)
    ply.MagicButtonsTooFastCounter = (ply.MagicButtonsTooFastCounter or 0) + (ply:IsAdmin() and 0 or 1)
    local expiry = 60 * 5
    timer.Create("fakes_removeplayer" .. ply:UserID(), expiry, 1, function()
        if(IsValid(ply))then
            ply.MagicButtonsTooFastCounter = nil
        end
    end)
end
