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

hook.Add("FindUseEntity", "ELEVATORBUTTONZ", function(ply, ent)
    if IsValid(ent) and ent:GetName():StartWith("tt_elevator_button_") then
        local tr = ply:GetEyeTrace()

        if tr.Hit then
            for k, v in pairs(ents.FindByClass("func_button")) do
                if v:GetName():StartWith("tt_elevator_button_") and v:GetPos():Distance(tr.HitPos) < ent:GetPos():Distance(tr.HitPos) then
                    ent = v
                end
            end

            return ent
        end
    end
end)
