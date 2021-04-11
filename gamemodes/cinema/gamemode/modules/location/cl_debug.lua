-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
module("Location", package.seeall)
DebugEnabled = CreateClientConVar("cinema_debug_locations", "0", false, false)

-- location visualizer for debugging
hook.Add("PostDrawTranslucentRenderables", "CinemaDebugLocations", function()
    if (not DebugEnabled:GetBool()) then return end

    for k, v in pairs(GetLocations() or {}) do
        local center = (v.Min + v.Max) / 2
        Debug3D.DrawBox(v.Min, v.Max)
        Debug3D.DrawText(center, v.Name, "VideoInfoSmall")
    end
end)