-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include('shared.lua')

hook.Add("PreDrawTranslucentRenderables", "TrashField", function()
    if IsValid(PropTrashLookedAt) and PropTrashLookedAt:GetClass()=="prop_trash_zone" then
        render.CullMode(MATERIAL_CULLMODE_CW)
        render.SetColorMaterial()
        local col = PropTrashLookedAt:GetTaped() and Color(128, 255, 255, 60) or Color(255, 255, 255, 20)
        local min,max = PropTrashLookedAt:GetBounds()
        render.DrawBox(Vector(0, 0, 0), Angle(0, 0, 0), min,max, col, false)
        render.CullMode(MATERIAL_CULLMODE_CCW)
    end
end)