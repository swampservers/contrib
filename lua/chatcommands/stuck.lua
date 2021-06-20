-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA



RegisterChatCommand({'stuck','unstuck','unstick'}, function(ply, arg)
    if IsValid(ply) and not ply:InVehicle() and ply:Alive() then
        local worked = ply:Unstick()
        local msg = (worked == true and "Unstuck!") or (worked == false and "Couldn't Unstick! Try to /tp to another player!") or (worked == nil and "You don't appear to be stuck.")
        ply:ChatPrint(msg)
    end
end, {
    global = false,
    throttle = true
})