-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- makes material a table that caches things
Material = setmetatable(isfunction(Material) and {
    [0] = Material
} or Material, {
    __call = function(tab, mn, png) return tab[0](mn, png) end,
    __index = function(tab, k)
        local v = tab[0](k)
        tab[k] = v

        return v
    end
})

-- local t=type(r)
-- if t=="number" then
--     sdc(r,g,b,a)
-- elseif t=="table" then
--     sdc(r.r,r.g,r.b,r.a)
-- else
--     sdc(255,255,255)
-- end
function render.BlendAdd()
    render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD)
end

function render.BlendSubtract()
    render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_REVERSE_SUBTRACT)
end

function render.BlendMultiply()
    render.OverrideBlend(true, BLEND_DST_COLOR, BLEND_ZERO, BLENDFUNC_ADD)
end

function render.BlendReset()
    render.OverrideBlend(false)
end

--- Bool if we are currently drawing to the screen.
function render.DrawingScreen()
    local t = render.GetRenderTarget()

    return t == nil or tostring(t) == "[NULL Texture]"
end

local getcm, setcm = render.GetColorModulation,render.SetColorModulation

--- Sets the color modulation, calls your callback, then sets it back to what it was before.
function render.WithColorModulation(r, g, b, callback)
    local lr, lg, lb = getcm()
    setcm(r, g, b)
    callback()
    setcm(lr, lg, lb)
end

--- Runs `cam.Start3D2D(pos, ang, scale) callback() cam.End3D2D()` but only if the user is in front of the "screen" so they can see it.
function cam.Culled3D2D(pos, ang, scale, callback)
    if (EyePos() - pos):Dot(ang:Up()) > 0 then
        cam.Start3D2D(pos, ang, scale)
        callback()
        cam.End3D2D()
        return true
    end
end
