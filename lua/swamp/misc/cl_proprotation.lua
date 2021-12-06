-- This file is subject to copyright - contact swampservers@gmail.com for more information.
net.Receive("RotateHeldEnt", function(len)
    if len > 0 then
        PROPROTATIONHELDENT = net.ReadEntity()
    else
        if IsValid(PROPROTATIONHELDENT) then
            PROPROTATIONHELDENT:SetRenderAngles()
        end

        PROPROTATIONHELDENT = nil
    end
end)

hook.Add("CreateMove", "RotateHeldEnts1", function(cmd)
    if not IsValid(LocalPlayer()) then return end

    if not IsValid(PROPROTATIONHELDENT) or not cmd:KeyDown(IN_ATTACK2) or not PROPROTATIONLASTEYEANGLE then
        -- just released it
        if IsValid(PROPROTATIONHELDENT) and PROPROTATIONTARGETANGLE then
            net.Start("RotateHeldEnt", true)
            net.WriteAngle(PROPROTATIONTARGETANGLE)
            net.SendToServer()
        end

        PROPROTATIONLASTEYEANGLE = cmd:GetViewAngles()

        if IsValid(PROPROTATIONHELDENT) then
            PROPROTATIONHELDENT:SetRenderAngles()
        end

        PROPROTATIONTARGETANGLE = nil
        PROPROTATIONLASTSENTANGLE = nil

        return
    end

    local ea = PROPROTATIONHELDENT:GetAngles()

    if not PROPROTATIONTARGETANGLE then
        PROPROTATIONTARGETANGLE = ea
        PROPROTATIONLASTSENTANGLE = Angle(ea)
    end

    -- PROPROTATIONTARGETANGLE = PROPROTATIONTARGETANGLE or ea
    local rv = PROPROTATIONLASTEYEANGLE:Forward():Cross(cmd:GetViewAngles():Forward()) * -80
    PROPROTATIONTARGETANGLE:RotateAroundAxis(rv:GetNormalized(), rv:Length())
    PROPROTATIONHELDENT:SetRenderAngles(PROPROTATIONTARGETANGLE)

    if CurTime() > (PROPROTATIONLASTSEND or 0) + 0.2 and PROPROTATIONTARGETANGLE ~= PROPROTATIONLASTSENTANGLE then
        PROPROTATIONLASTSENTANGLE = Angle(PROPROTATIONTARGETANGLE)
        net.Start("RotateHeldEnt", true)
        net.WriteAngle(PROPROTATIONTARGETANGLE)
        net.SendToServer()
        PROPROTATIONLASTSEND = CurTime()
    end

    cmd:RemoveKey(IN_ATTACK2)
    cmd:SetViewAngles(PROPROTATIONLASTEYEANGLE)
end)

hook.Add("HUDPaint", "RotateHeldEntsHint", function()
    if not IsValid(LocalPlayer()) then return end

    if IsValid(PROPROTATIONHELDENT) then
        -- print(PROPROTATIONHELDENT)
        draw.SimpleText("Hold RMB to rotate", "DermaLarge", ScrW() / 2, ScrH() * 5 / 6, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)
