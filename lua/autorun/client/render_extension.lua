function render.DrawingScreen()
    local t = render.GetRenderTarget()

    return (t == nil) or (tostring(t) == "[NULL Texture]")
end