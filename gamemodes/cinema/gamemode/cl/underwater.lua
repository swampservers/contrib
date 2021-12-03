-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

hook.Add("RenderScreenspaceEffects", "FishEyeEffect", function()
    if IsValid(LocalPlayer()) and LocalPlayer():WaterLevel() == 3 then
        DrawMaterialOverlay("effects/water_warp01", -0.1)
    end
end)
