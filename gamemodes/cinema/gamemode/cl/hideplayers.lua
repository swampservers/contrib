-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

local cvar = CreateClientConVar("cinema_hideplayers", 0, true, false, "", 0, 1)

local undomodelblend = false
local white = Material("models/debug/debugwhite")
hook.Add("PrePlayerDraw", "HidePlayers", function(ply)
    assert(not ply:GetNoDraw())
    -- TODO: or ply:GetNoDraw()?
    if theater.Fullscreen then return true end

    if not ply:InVehicle() then
        local transhide = false

        if LocalPlayer():InVehicle() and LocalPlayer():GetVehicle():GetNWBool("IsChessSeat", false) and ChessLocalHideSpectators then
            transhide = true
        end

        if LocalPlayer():InTheater() and cvar:GetBool() then
            transhide = true
        end

        if transhide then
            render.SetBlend(0.2)
            render.ModelMaterialOverride(white)
            render.SetColorModulation(0.5, 0.5, 0.5)
            
            hook.Add("PostPlayerDraw", "UndoPlayerBlend", function(ply)
                render.SetBlend(1.0)
                render.ModelMaterialOverride()
                render.SetColorModulation(1, 1, 1)
                hook.Remove("PostPlayerDraw", "UndoPlayerBlend")
            end)
        end
    end
end)

