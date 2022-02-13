-- This file is subject to copyright - contact swampservers@gmail.com for more information.


local function should_tape_on_click()
    local w = Me and Me:GetActiveWeapon()
    -- print(1)
    if IsValid(w) and w:GetClass()=="weapon_trash_tape" then
        -- print(2)
        -- print(PropTrashLookedAt==HandledEntity, CanTapeWhileHandling(HandledEntity))
        return PropTrashLookedAt==HandledEntity and CanTapeWhileHandling(HandledEntity)
    end
end

hook.Add("CreateMove", "RotateHeldEnts1", function(cmd)
    if not IsValid(Me) then return end

    if IsValid(HandledEntity) and cmd:KeyDown(IN_ATTACK) and should_tape_on_click(HandledEntity) then
        
        if not TapeHandledEntityCooldown then
            Me:GetWeapon("weapon_trash_tape"):PrimaryAttack(true)
            TapeHandledEntityCooldown=true
            timer.Simple(0.5, function() TapeHandledEntityCooldown=nil end)
        end
        
        cmd:RemoveKey(IN_ATTACK)
        -- HandledEntity = nil
        return
    end

    if not IsValid(HandledEntity) or not cmd:KeyDown(IN_ATTACK2) or not EntityHandlingLastEyeAngle then
        -- just released it
        if IsValid(HandledEntity) and EntityHandlingTargetAngle then
            net.Start("HandleEntity", true)
            net.WriteAngle(EntityHandlingTargetAngle)
            net.SendToServer()
        end

        EntityHandlingLastEyeAngle = cmd:GetViewAngles()

        if IsValid(HandledEntity) then
            HandledEntity:SetRenderAngles()
        end

        EntityHandlingTargetAngle = nil
        EntityHandlingLastSentAngle = nil

        return
    end

    local ea = HandledEntity:GetAngles()

    if not EntityHandlingTargetAngle then
        EntityHandlingTargetAngle = ea
        EntityHandlingLastSentAngle = Angle(ea)
    end

    -- EntityHandlingTargetAngle = EntityHandlingTargetAngle or ea
    local rv = EntityHandlingLastEyeAngle:Forward():Cross(cmd:GetViewAngles():Forward()) * -80
    EntityHandlingTargetAngle:RotateAroundAxis(rv:GetNormalized(), rv:Length())
    HandledEntity:SetRenderAngles(EntityHandlingTargetAngle)

    if CurTime() > (EntityHandlingLastSendTime or 0) + 0.2 and EntityHandlingTargetAngle ~= EntityHandlingLastSentAngle then
        EntityHandlingLastSentAngle = Angle(EntityHandlingTargetAngle)
        net.Start("RotateHeldEnt", true)
        net.WriteAngle(EntityHandlingTargetAngle)
        net.SendToServer()
        EntityHandlingLastSendTime = CurTime()
    end

    cmd:RemoveKey(IN_ATTACK2)
    cmd:SetViewAngles(EntityHandlingLastEyeAngle)
end)

hook.Add("HUDPaint", "RotateHeldEntsHint", function()
    if not IsValid(Me) then return end

    if IsValid(HandledEntity) then
        -- print(HandledEntity)
        draw.SimpleText("Hold RMB to rotate", "DermaLarge", ScrW() / 2, ScrH() * 5 / 6, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if should_tape_on_click(HandledEntity) then 
            draw.SimpleText("Press LMB to tape!", "DermaLarge", ScrW() / 2, ScrH() * 4 / 6, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end)
