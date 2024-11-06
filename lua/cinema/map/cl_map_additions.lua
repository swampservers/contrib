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
local vapermaterial = Material("swamponions/swampcinema/vapers")
local vapesignmaterial = Material("models/vapor/sign/sign_green")
local computerscreenmaterial = Material("models/unconid/pc_models/c64/screen_c64_ll")

timer.Simple(0, function()
    --flagmaterial:SetTexture("$basetexture", "models/props_fairgrounds/fairgrounds_flagpole01_alternate")

    vapermaterial:SetMatrix("$basetexturetransform", Matrix({
        {1, 0, 0, 0},
        {0, 1.05, 0, 0},
        {0, 0, 1, 0},
        {0, 0, 0, 1}
    }))
end)

local last_thing = 0

--vapesignmaterial:SetVector("$color2",Vector(1,0.4,0.6))
hook.Add("Think", "VapeSignColor", function()
    -- TODO: Give it a matproxy
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
