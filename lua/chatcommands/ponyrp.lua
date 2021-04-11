-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
RegisterChatCommand({'ponyrp'}, function(ply, arg)
    if IsValid(ply) and not Safe(ply) and not ply:InVehicle() and ply:Alive() then
        ply:SetPos(Vector(-388, 1400, -118)) --treatment room location

        for k, v in pairs(ents.GetAll()) do
            if IsValid(v) then
                if v:GetName() == "treatmentdoor" then
                    v:Fire("Close")
                end

                if v:GetName() == "treatmentlever" then
                    v:Fire("PressOut")
                end
            end
        end
    end
end, {
    global = false,
    throttle = true
})

hook.Add("PlayerSay", "TreatmentRoomChat", function(ply, text, team)
    if ply:GetLocationName() == "Treatment Room" and text ~= "/tpa" and text ~= "!tpa" then return "i like ponies" end
end)