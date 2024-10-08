﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local cm_dn = "swamponions/cm_d"

hook.Add("Tick", "cm_dn", function()
    cm_dn = GetGlobalBool("DAY") and "swamponions/cm_d" or "swamponions/cm_n"
end)

-- For stuff like the japanese shoji doors, so they'll glow at night
matproxy.Add({
    name = "DayNight",
    init = function(self, mat, values)
        -- Store the name of the variable we want to set
        self.ResultTo = values.resultvar
        self.ValueDay = values.dayval
        self.ValueNight = values.nightval
    end,
    bind = function(self, mat, ent)
        local day = GetGlobalBool("DAY", true)
        local val_day = mat:GetVector(self.ValueDay)
        local val_night = mat:GetVector(self.ValueNight)
        local value = val_day or val_night or Vector(1, 1, 1)

        if day and val_day then
            value = val_day
        end

        if not day and val_night then
            value = val_night
        end

        mat:SetVector(self.ResultTo, value)
    end
})

matproxy.Add({
    name = "cm_dn",
    init = function(self, mat, values) end,
    bind = function(self, mat, ent)
        mat:SetTexture("$envmap", cm_dn)
    end
})

matproxy.Add({
    name = "cm_d",
    init = function(self, mat, values) end,
    bind = function(self, mat, ent)
        mat:SetTexture("$envmap", "swamponions/cm_d")
    end
})

matproxy.Add({
    name = "cm_fm",
    init = function(self, mat, values)
        self.tex = values.tex
    end,
    bind = function(self, mat, ent)
        mat:SetTexture("$envmapmask", self.tex)
    end
})

-- local sky_day_bk = Material( "swamponions/sky/sky_day_bk" )
-- local sky_day_ft = Material( "swamponions/sky/sky_day_ft" )
-- local sky_day_lf = Material( "swamponions/sky/sky_day_lf" )
-- local sky_day_rt = Material( "swamponions/sky/sky_day_rt" )
-- local sky_day_up = Material( "swamponions/sky/sky_day_up" )
local sky_night_bk = Material("swamponions/sky/sky_night_bk")
local sky_night_ft = Material("swamponions/sky/sky_night_ft")
local sky_night_lf = Material("swamponions/sky/sky_night_lf")
local sky_night_rt = Material("swamponions/sky/sky_night_rt")
local sky_night_up = Material("swamponions/sky/sky_night_up")

hook.Add("PostDraw2DSkyBox", "DrawDayNightSky", function()
    local fade = 1 - math.min(GetGlobalFloat("DAYFADE", 1) * 2, 1)

    if fade > 0 then
        render.OverrideDepthEnable(true, false)
        cam.Start3D(Vector(0, 0, 0))
        sky_night_rt:SetFloat("$alpha", fade)
        sky_night_bk:SetFloat("$alpha", fade)
        sky_night_lf:SetFloat("$alpha", fade)
        sky_night_ft:SetFloat("$alpha", fade)
        sky_night_up:SetFloat("$alpha", fade)
        render.SetMaterial(sky_night_rt)
        render.DrawQuadEasy(Vector(32, 0, 12), Vector(-1, 0, 0), 64, 40.025, Color.white, 0)
        render.SetMaterial(sky_night_bk)
        render.DrawQuadEasy(Vector(0, -32, 12), Vector(0, 1, 0), 64, 40.025, Color.white, 0)
        render.SetMaterial(sky_night_lf)
        render.DrawQuadEasy(Vector(-32, 0, 12), Vector(1, 0, 0), 64, 40.025, Color.white, 0)
        render.SetMaterial(sky_night_ft)
        render.DrawQuadEasy(Vector(0, 32, 12), Vector(0, -1, 0), 64, 40.025, Color.white, 0)
        render.SetMaterial(sky_night_up)
        render.DrawQuadEasy(Vector(0, 0, 32), Vector(0, 0, -1), 64, 64, Color.white, 0)
        cam.End3D()
        render.OverrideDepthEnable(false, false)
    end
end)

local sky_space_lf = Material("swamponions/sky/sky_space_lf")
local sky_space_rt = Material("swamponions/sky/sky_space_rt")
local sky_space_up = Material("swamponions/sky/sky_space_up")
local sky_space_dn = Material("swamponions/sky/sky_space_dn")
local sky_space_ft = Material("swamponions/sky/sky_space_ft")
local sky_space_bk = Material("swamponions/sky/sky_space_bk")
local sky_space_sun = Material("effects/yellowflare_noz")

local function drawMoonStars()
    if not render.DrawingScreen() then return end
    local alpha = IsValid(Me) and math.Clamp((Me:GetPos().z - 3700) / 3500, 0, 1) or 0
    if alpha <= 0 then return end
    sky_space_rt:SetFloat("$alpha", alpha)
    sky_space_lf:SetFloat("$alpha", alpha)
    sky_space_up:SetFloat("$alpha", alpha)
    sky_space_dn:SetFloat("$alpha", alpha)
    sky_space_ft:SetFloat("$alpha", alpha)
    sky_space_bk:SetFloat("$alpha", alpha)
    render.OverrideDepthEnable(true, false)
    cam.Start3D(Vector(0, 0, 0))
    render.SetMaterial(sky_space_rt)
    render.DrawQuadEasy(Vector(32, 0, 0), Vector(-1, 0, 0), 64, 64, Color.white, 0)
    render.SetMaterial(sky_space_lf)
    render.DrawQuadEasy(Vector(-32, 0, 0), Vector(1, 0, 0), 64, 64, Color.white, 0)
    render.SetMaterial(sky_space_ft)
    render.DrawQuadEasy(Vector(0, 32, 0), Vector(0, -1, 0), 64, 64, Color.white, 0)
    render.SetMaterial(sky_space_bk)
    render.DrawQuadEasy(Vector(0, -32, 0), Vector(0, 1, 0), 64, 64, Color.white, 0)
    render.SetMaterial(sky_space_up)
    render.DrawQuadEasy(Vector(0, 0, 32), Vector(0, 0, -1), 64, 64, Color.white, 0)
    render.SetMaterial(sky_space_dn)
    render.DrawQuadEasy(Vector(0, 0, -32), Vector(0, 0, 1), 64, 64, Color.white, 0)
    render.SetMaterial(sky_space_sun)
    render.DrawQuadEasy(Vector(16, -11, -3), Vector(-1, 1, 0), 12, 12, Color.white, 0)
    cam.End3D()
    render.OverrideDepthEnable(false, false)
end

-- BUG(winter): Map v4; for some reason only using the 3D post-draw doesn't work at certain camera angles (2D vs 3D Skybox brushes?)
hook.Add("PostDraw2DSkyBox", "DrawMoonStars2D", drawMoonStars)
hook.Add("PostDrawSkyBox", "DrawMoonStars3D", drawMoonStars)
