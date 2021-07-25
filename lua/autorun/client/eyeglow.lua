-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
hook.Add("Think", "UndergroundEyeGlow", function()
    --if true then return end
    if not IsValid(LocalPlayer()) then return end
    local pp = LocalPlayer():EyePos()
    if pp.z > -290 then return end

    if pp.x > 724 or pp.y < -768 or (pp.y < -312 and pp.x > 242) then
    else
        return
    end

    local dlight = DynamicLight(LocalPlayer():EntIndex())

    if (dlight) then
        dlight.pos = pp
        dlight.r = 10
        dlight.g = 10
        dlight.b = 10
        dlight.brightness = 1
        dlight.decay = 1000
        dlight.size = 2000
        dlight.dietime = CurTime() + 1
    end
end)
