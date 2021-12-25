-- it'd probably be a good idea to look into why this is happening in the first place
-- it seems like a fairly recent issue, but i'm not 100% positive
hook.Add("AcceptInput", "ElevatorSoundsFix", function(ent, name, activator, caller, data)
    if ent:GetName() == "tt_elevator" then
        if name == "SetPosition" then
            ent:StopSound("plats/elevator_move_loop1.wav")
        end
    end
end)

hook.Add("PlayerShouldTakeDamage", "elevattorfix", function(ply, att)
    if att:GetClass() == "func_movelinear" and att:GetPos().y == -624 then return false end
end)
