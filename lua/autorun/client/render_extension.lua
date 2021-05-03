function render.DrawingScreen()
    local t = render.GetRenderTarget()

    return (t == nil) or (tostring(t) == "[NULL Texture]")
end

render.BaseSetColorModulation = render.BaseSetColorModulation or render.SetColorModulation
-- render.SetColorModulation = function() print("WARNING: USE render.PushColorModulation") end
render.ColorModulationStack = render.ColorModulationStack or {}

function render.PushColorModulation(col)
    if #render.ColorModulationStack > 0 then
        col = col * render.ColorModulationStack[#render.ColorModulationStack]
    end

    table.insert(render.ColorModulationStack, col)
    render.BaseSetColorModulation(col.x, col.y, col.z)
end

function render.PopColorModulation()
    table.remove(render.ColorModulationStack)
    local col = #render.ColorModulationStack > 0 and render.ColorModulationStack[#render.ColorModulationStack] or Vector(1, 1, 1)
    render.BaseSetColorModulation(col.x, col.y, col.z)
end

-- Unrelated to the stack thing above
function render.WithColorModulation(r, g, b, func)
    local lr, lg, lb = render.GetColorModulation()
    render.SetColorModulation(r, g, b)
    func()
    render.SetColorModulation(lr, lg, lb)
end

function cam.StartCulled3D2D(pos, ang, scale)
    if (EyePos() - pos):Dot(ang:Up()) > 0 then
        cam.Start3D2D(pos, ang, scale)

        return true
    end
end

function cam.Culled3D2D(pos, ang, scale, func)
    if cam.StartCulled3D2D(pos, ang, scale) then
        func()
        cam.End3D2D()
    end
end