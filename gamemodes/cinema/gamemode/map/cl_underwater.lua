-- This file is subject to copyright - contact swampservers@gmail.com for more information.


hook.Add("RenderScreenspaceEffects", "UnderwaterEffect", function()
    if bit.band( util.PointContents(EyePos()), CONTENTS_WATER ) == CONTENTS_WATER then
        DrawMaterialOverlay("effects/water_warp01", -0.1)
    end
end)
