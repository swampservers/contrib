-- This file is subject to copyright - contact swampservers@gmail.com for more information.
matproxy.Add({
    name = "ToggleSelfillum",
    init = function(self, mat, values)
        self.light = values.lightname .. "_on"
    end,
    bind = function(self, mat, ent)
        local on = GetGlobalBool(self.light, true)
        local flags = mat:GetInt("$flags")

        if (bit.band(flags, 64) > 0) ~= on then
            mat:SetInt("$flags", bit.bxor(flags, 64))
        end
    end
})

matproxy.Add({
    name = "ToggleEmissiveBlend",
    init = function(self, mat, values)
        self.light = values.lightname .. "_on"
    end,
    bind = function(self, mat, ent)
        local on = GetGlobalBool(self.light, true)
        mat:SetInt("$emissiveBlendEnabled", on and 1 or 0)
    end
})

local ClockArms = Material("debug/debugvertexcolor")
local ClockCenter = Vector(0, 1039.4 + 155, 192 - 4)

-- PostTranslucent so there is no z-fighting TODO this should be an entity with renderbounds
hook.Add("PostDrawTranslucentRenderables", "lobbyclock", function(depth, sky)
    if sky or depth then return end
    if EyePos().y > ClockCenter.y or EyePos():DistToSqr(ClockCenter) > 5000000 then return end
    local seconds = Vector(0, -21, 0)
    local minutes = Vector(0, -25, 0)
    local hours = Vector(0, -18, 0)
    local h, m, s = unpack(os.date("%H:%M:%S"):Split(":"))
    seconds:Rotate(Angle(0, tonumber(s) * 6, 0))
    minutes:Rotate(Angle(0, tonumber(m) * 6, 0))
    hours:Rotate(Angle(0, tonumber(h) * 30, 0))

    local function DrawClockLine(endX, endY, thickness)
        local v2 = Vector(endX, 0, -endY)
        local v1 = v2:GetNormalized() * 1.5 -- start point is offset from center
        local v3 = v2 - v1
        v3:Normalize()
        v3:Mul(thickness / 2)
        v3:Rotate(Angle(90, 0, 0))
        render.DrawQuad(ClockCenter + v1 + v3, ClockCenter + v1 - v3, ClockCenter + v2 - v3, ClockCenter + v2 + v3, Color(36, 36, 36))
    end

    render.SetMaterial(ClockArms)
    DrawClockLine(seconds.x, seconds.y, 0.4)
    DrawClockLine(minutes.x, minutes.y, 0.8)
    DrawClockLine(hours.x, hours.y, 1.2)
end)

local hevmaterial = Material("models/hevsuit/hevsuit_sheet")

timer.Simple(0, function()
    hevmaterial:SetInt("$flags", 8192 + 65536)
end)

local resetmaterial = Material("swamponions/reset")

timer.Simple(0, function()
    resetmaterial:SetInt("$flags", 0)
end)

local lanternmaterial = Material("models/dojo/lantern/lantern")

timer.Create("lanternswitcher", 100, 0, function()
    if GetGlobalBool("DAY", true) then
        lanternmaterial:SetTexture("$basetexture", "models/dojo/lantern/lantern")
        lanternmaterial:SetInt("$flags", 0)
    else
        lanternmaterial:SetTexture("$basetexture", "models/dojo/lantern/lantern_night")
        lanternmaterial:SetInt("$flags", 64)
    end
end)

local barfade = 0

hook.Add("RenderScreenspaceEffects", "BarBrightness", function()
    if IsValid(Me) and Me:GetLocationName() == "Drunken Clam" then
        barfade = math.min(barfade + FrameTime(), 1)
    else
        barfade = math.max(barfade - FrameTime() * 2, 0)
    end

    if barfade > 0 then
        local thing = -(barfade * 0.06)
        local tab = {}
        tab["$pp_colour_contrast"] = 1 / (1 + thing * 0.5)
        tab["$pp_colour_colour"] = 1 + thing
        tab["$pp_colour_brightness"] = thing
        tab["$pp_colour_mulr"] = 0
        tab["$pp_colour_mulg"] = 0
        tab["$pp_colour_mulb"] = 0
        DrawColorModify(tab)
    end
end)

local flagmaterial = Material("models/props_fairgrounds/fairgrounds_flagpole01")
local postermaterial = Material("swamponions/swampcinema/swamponions_creditposter")
local vapermaterial = Material("swamponions/swampcinema/vapers")
local vapesignmaterial = Material("models/vapor/sign/sign_green")
local computerscreenmaterial = Material("models/unconid/pc_models/c64/screen_c64_ll")

timer.Simple(0, function()
    flagmaterial:SetTexture("$basetexture", "models/props_fairgrounds/fairgrounds_flagpole01_alternate")
    postermaterial:SetTexture("$basetexture", "swamponions/swampcinema/swamponions_creditposter_drama")
    postermaterial:SetInt("$flags", 536870912 + 256)

    vapermaterial:SetMatrix("$basetexturetransform", Matrix({
        {1, 0, 0, 0},
        {0, 1.05, 0, 0},
        {0, 0, 1, 0},
        {0, 0, 0, 1}
    }))
end)

local last_thing = 0

hook.Add("Think", "VapeSignColor", function()
    -- todo give it a matproxy
    if vapesignmaterial then
        local c = HSVToColor(SysTime() * 15, 0.5, 1)
        vapesignmaterial:SetVector("$color2", Vector(c.r, c.g, c.b) / 255)
    end

    --fix the screen
    local next_thing = math.floor(CurTime() * 7)

    if next_thing ~= last_thing then
        computerscreenmaterial:SetFloat("$sqrt2", (math.random() - 0.5) * 20 / CurTime())
        last_thing = next_thing
    end
end)

-- vapesignmaterial:SetVector("$color2",Vector(1,0.4,0.6))
local citymat = Material("swamponions/af/city")
local c0 = Vector(-2385, 96, 763) --left edge of window
local c1 = Vector(-2096, -193, 646) --right edge of window
local w_center = (c0 + c1) * 0.5
local w_width = math.sqrt(math.pow(c0.x - c1.x, 2) + math.pow(c0.y - c1.y, 2))
local w_height = c0.z - c1.z
local v_width = 16000
local v_height = 9000
local v_dist = 5000

hook.Add("PostDrawOpaqueRenderables", "AFCityParallaxEffect", function(depth, sky)
    if sky or depth then return end
    local to_c0 = c0 - EyePos()
    local to_c1 = c1 - EyePos()
    local adjacent = to_c0:Dot(Vector(1, 1, 0):GetNormalized())
    if adjacent <= 0 then return end

    local function calc_parallax(opposite, w_sz, v_sz)
        local real_hit = (opposite / adjacent) * v_dist + w_sz / 2
        local virtual_hit = real_hit / (v_sz / 2)

        return virtual_hit / 2 + 0.5
    end

    vofs = -0.01
    local v0 = calc_parallax(-to_c0.z, -w_height, v_height) + vofs
    local v1 = calc_parallax(-to_c1.z, w_height, v_height) + vofs
    local u0 = calc_parallax(to_c0:Dot(Vector(1, -1, 0):GetNormalized()), -w_width, v_width)
    local u1 = calc_parallax(to_c1:Dot(Vector(1, -1, 0):GetNormalized()), w_width, v_width)
    cam.Start3D2D(w_center, Angle(0, -45, 90), 1) -- Already backface culled by checks above
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(citymat)
    surface.DrawTexturedRectUV(-w_width / 2, -w_height / 2, w_width, w_height, u0, v0, u1, v1)
    cam.End3D2D()
end)
