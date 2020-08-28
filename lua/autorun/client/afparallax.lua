-- This file is subject to copyright - contact swampservers@gmail.com for more information.

AF_CITYMAT = AF_CITYMAT or Material("swamponions/af/city")

local c0 = Vector(-2385, 96, 763) --left edge of window
local c1 = Vector(-2096, -193, 646) --right edge of window

local w_center = (c0+c1)*0.5
local w_width = math.sqrt( math.pow(c0.x-c1.x,2)+math.pow(c0.y-c1.y,2) )
local w_height = c0.z-c1.z

local v_width = 16000
local v_height = 9000
local v_dist = 5000

hook.Add("PostDrawOpaqueRenderables", "AFCityParallaxEffect", function()
    
    local to_c0 = c0-EyePos()
    local to_c1 = c1-EyePos()

    local adjacent = to_c0:Dot(Vector(1,1,0):GetNormalized())

    if adjacent <=0 then return end

    local function calc_parallax(opposite, w_sz, v_sz)
        local real_hit = ( ((opposite/adjacent) * v_dist) + (w_sz/2) )
        local virtual_hit = real_hit / (v_sz/2)
        return (virtual_hit/2)+0.5 
    end

    vofs = -0.01

    local v0 = calc_parallax(-to_c0.z, -w_height, v_height) + vofs
    local v1 = calc_parallax(-to_c1.z, w_height, v_height) + vofs

    local u0 = calc_parallax(to_c0:Dot(Vector(1,-1,0):GetNormalized()), -w_width, v_width)
    local u1 = calc_parallax(to_c1:Dot(Vector(1,-1,0):GetNormalized()), w_width, v_width)

    cam.Start3D2D(w_center, Angle(0,-45,90), 1)
    surface.SetDrawColor(255,255,255,255)
    surface.SetMaterial(AF_CITYMAT)
    surface.DrawTexturedRectUV(-w_width/2,-w_height/2,w_width,w_height,u0,v0,u1,v1)
    cam.End3D2D() 
end)
