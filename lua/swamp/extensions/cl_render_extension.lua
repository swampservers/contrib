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

Color = setmetatable(isfunction(Color) and {
    [0] = Color
} or Color, {
    __call = function(tab, ...) return tab[0](...) end,
    __index = function(tab, k)
        if isstring(k) then
            local len = #k
            local double = len == 2 or len == 6 or len == 8

            local function dv(d)
                return tonumber(d) or string.byte(d) - 87
            end

            local a = {}
            local i = 1

            while i <= len do
                local dig = dv(sub(k, i, i))
                i = i + 1

                if double then
                    dig = dig * 16 + dv(sub(k, i, i))
                    i = i + 1
                else
                    dig = dig * 17
                end

                table.insert(a, dig)
            end

            if len < 3 then
                a[2] = a[1]
                a[3] = a[1]
            end

            PrintTable(a)
            a = tab[0](unpack(a))
            tab[k] = a

            return a
        end
    end
})

table.Merge(Color, {
    black = Color["0"],
    white = Color["f"],
    red = Color["f00"],
})

BaseSurfaceSetDrawColor = BaseSurfaceSetDrawColor or surface.SetDrawColor
local sdc = BaseSurfaceSetDrawColor

-- it is faster
function surface.SetDrawColor(r, g, b, a)
    if isnumber(r) then
        sdc(r, g, b, a)
    else
        sdc(r.r, r.g, r.b, r.a)
    end
end

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

--- Sets the color modulation, calls your callback, then sets it back to what it was before.
function render.WithColorModulation(r, g, b, callback)
    local lr, lg, lb = render.GetColorModulation()
    render.SetColorModulation(r, g, b)
    callback()
    render.SetColorModulation(lr, lg, lb)
end

function cam.StartCulled3D2D(pos, ang, scale)
    if (EyePos() - pos):Dot(ang:Up()) > 0 then
        cam.Start3D2D(pos, ang, scale)

        return true
    end
end

--- Runs `cam.Start3D2D(pos, ang, scale) callback() cam.End3D2D()` but only if the user is in front of the "screen" so they can see it.
function cam.Culled3D2D(pos, ang, scale, callback)
    if cam.StartCulled3D2D(pos, ang, scale) then
        callback()
        cam.End3D2D()
    end
end
