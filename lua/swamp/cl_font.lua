-- ExtraLight @200
-- Light @300
-- Regular @400
-- Medium @500
-- SemiBold @600
-- Bold @700
-- ExtraBold @800
function test()
    hook.Add("HUDPaint", "a", function()
        -- for i, v in ipairs({"Plus Jakarta Sans", "Plus Jakarta Sans Medium", "Plus Jakarta Sans SemiBold", "Plus Jakarta Sans Bold", "Circular Std Medium", "Arial", "Roboto", "Times New Roman"}) do
        -- for i, v in ipairs({"Plus Jakarta Sans", "Swampkarta", "Circular Std Medium", "Arial"}) do
        for i, v in ipairs({"Swampkarta ExtraLight", "Swampkarta Regular", "Swampkarta Medium", "Swampkarta ExtraBold", "Swampkarta", "Circular Std Medium", "CircularStd-Book", "CircularStd-Bold"}) do
            local s = 24 --math.floor((CurTime() % 10) * 10)
            -- local w,h = GetTextSize(Font[v .. s], "Hello")
            txt = "Hello " .. s -- .. " " .. w .. " "..h
            x, y = 10, i * s
            draw.SimpleText(txt, Font[v .. s], x, y)
            draw.SimpleText(txt, Font[v .. s .. "_200"], x + 200, y)
            draw.SimpleText(txt, Font[v .. s .. "_400"], x + 400, y)
            draw.SimpleText(txt, Font[v .. s .. "_500"], x + 600, y)
            draw.SimpleText(txt, Font[v .. s .. "_800"], x + 800, y)
            -- y=y+100
            -- draw.SimpleText(txt, Font[v .. s.."_italic"], x, y)
            -- draw.SimpleText(txt, Font[v .. s.."_100_italic"], x+200, y)
            -- draw.SimpleText(txt, Font[v .. s.."_400_italic"], x+400, y)
            -- draw.SimpleText(txt, Font[v .. s.."_600_italic"], x+600, y)
            -- draw.SimpleText(txt, Font[v .. s.."_800_italic"], x+800, y)
            -- w, h = GetTextSize(Font[v .. s], txt)
            -- surface.SetDrawColor(255, 255, 255)
            -- surface.DrawOutlinedRect(x, y, w, h)
        end
    end)
end

DefaultCreateFont = DefaultCreateFont or surface.CreateFont
DefaultSetFont = DefaultSetFont or surface.SetFont
DefaultGetTextSize = DefaultGetTextSize or surface.GetTextSize
local currentfont = "Default"

function surface.SetFont(font)
    -- if currentfont ~= font then
    currentfont = font
    DefaultSetFont(font)
    -- end
end

function surface.GetTextSize(text)
    return GetTextSize(currentfont, text)
end

local spam = {
    extended = false,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
}

local textsizecache = defaultdict(function() return {} end)
local textsizecachecount = 0

function surface.CreateFont(name, settings)
    for k, v in pairs(settings) do
        if spam[k] == v then
            print("Unnecessary font setting", name, k, v)
        end
    end

    -- if (settings.font or ""):StartWith("Plus Jak") then
    -- settings.size = (settings.size or 13)*1.2
    -- end
    textsizecachecount = textsizecachecount - table.Count(textsizecache[name])
    textsizecache[name] = {}

    return DefaultCreateFont(name, settings)
end

--- surface.GetTextSize with cached result
function GetTextSize(font, text)
    if not text then
        local w, h = GetTextSize(font, "")

        return h
    end

    local c = textsizecache[font]

    if not c[text] then
        if textsizecachecount > 1000 then
            -- todo make it make max larger if it clears twice within 10 sec or whatever
            print("CLEAR TEXT SIZE CACHE")
            textsizecachecount = 0
            textsizecache = defaultdict(function() return {} end)
        end

        surface.SetFont(font)

        c[text] = {DefaultGetTextSize(text)}

        textsizecachecount = textsizecachecount + 1
    end

    return unpack(c[text])
end

function GetTextWidth(font, text)
    local w, h = GetTextSize(font, text)

    return w
end

function GetTextHeight(font)
    local w, h = GetTextSize(font, "")

    return h
end

-- TODO add bold and the other shit. parse kvs?
local function parse_settings(setting_str)
    local stuff = ("_"):Explode(setting_str)

    local settings = {
        font = stuff[1]
    }

    local szstart = settings.font:find("%d")

    if szstart then
        settings.size = tonumber(settings.font:sub(szstart))
        settings.font = settings.font:sub(1, szstart - 1)
    end

    local i = 2
    settings.weight = tonumber(stuff[2])

    if settings.weight then
        i = 3
    end

    while stuff[i] do
        settings[stuff[i]] = true
        i = i + 1
    end

    -- aliases
    if settings.font == "sans" then
        -- settings.font = "Swampkarta SemiBold" 
        -- settings.weight = 600
        settings.font = "CircularStd-Book"
    end

    if settings.font == "sansmedium" then
        settings.font = "CircularStd-Medium"
    end

    if settings.font == "sansbold" then
        settings.font = "CircularStd-Bold"
    end

    return settings
end

local function pack_settings(settings)
    local setting_str = (settings.font or "sans") .. (settings.size or "13")

    if settings.weight then
        setting_str = setting_str .. "_" .. settings.weight
    end

    for k, v in pairs(settings) do
        if v == true then
            setting_str = setting_str .. ("_" .. k)
        elseif k ~= "font" and k ~= "size" and k ~= "weight" then
            error()
        end
    end

    return setting_str
end

local fontsmade = {}

--- Generates a font quickly. Caches so it can be used in paint hooks.
-- Example input: draw.DrawText("based", Font.Arial24)
Font = defaultdict(function(setting_str)
    surface.CreateFont(setting_str, parse_settings(setting_str))

    return setting_str
end)

-- default size
Font.sans = Font.sans24
-- todo clear cache
local ffc = defaultdict(function() return defaultdict(function() return {} end) end)

function FitFont(setting_str, txt, w)
    local c = ffc[setting_str][txt][w]
    if c then return c end
    local in_setting_str = setting_str
    local settings = parse_settings(setting_str)

    if not settings.size then
        settings.size = 4

        while ({GetTextSize(Font[pack_settings(settings)], txt)})[1] <= w do
            settings.size = settings.size * 2
        end

        settings.size = settings.size - 1
    end

    local min, max = 4, settings.size + 1
    local mid2

    while min < max - 1 do
        local mid = math.floor((min + max) / 2)
        assert(mid ~= mid2)
        mid2 = mid
        settings.size = mid

        if ({GetTextSize(Font[pack_settings(settings)], txt)})[1] <= w then
            min = mid
        else
            max = mid
        end
    end

    settings.size = min
    local c = Font[pack_settings(settings)]
    ffc[in_setting_str][txt][w] = c

    return c
end

local function tryfont()
    surface.CreateFont('HintControls', {
        font = 'Lato',
        size = sz,
    })

    surface.SetFont('HintControls')
    local w, h = surface.GetTextSize(teststr)

    return w >= scrw
end

-- Dude move this
function draw.ShadowedText(text, font, x, y, c, xalign, yalign)
    draw.SimpleText(text, font, x + 1, y + 3, Color(0, 0, 0, 255 * math.pow(c.a / 255, 0.5)), xalign, yalign)
    draw.SimpleText(text, font, x, y, c, xalign, yalign)
end
