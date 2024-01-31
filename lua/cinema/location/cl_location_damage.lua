-- Quick and dirty effects for Power Plant reactor water
-- https://github.com/ValveSoftware/source-sdk-2013/blob/master/mp/src/game/client/geiger.cpp#L110
-- TODO(winter): This could be cleaned up/combined with serverside damage code, but there isn't enough incentive yet
local nextgeigercheck = 0
local swimmingstart = nil

hook.Add("Think", "Location.PowerPlant.GeigerSounds", function()
    local realtime = RealTime()

    if realtime > nextgeigercheck then
        if Me:GetLocationName() == "Power Plant" and Me:WaterLevel() > 0 and Me:GetPos().z < -48 then
            if not swimmingstart then
                swimmingstart = realtime
                surface.PlaySound("hl1/fvox/radiation_detected.wav")
            end

            if math.random(0, 127) < math.min((realtime - swimmingstart) * 6, 95) then
                Me:EmitSound(math.random(0, 1) > 0 and "Geiger.BeepLow" or "Geiger.BeepHigh", nil, nil, 0.5, CHAN_BODY)
            end
        elseif swimmingstart then
            swimmingstart = nil
        end

        nextgeigercheck = realtime + 0.06
    end
end)
