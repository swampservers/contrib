-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA



RegisterChatCommand({'stuck'}, function(ply, arg)
    if IsValid(ply) and not ply:InVehicle() and ply:Alive() then
        ply:Unstick()
    end
end, {
    global = false,
    throttle = true
})