-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local hide = {
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudHealth"] = true,
}

hook.Add("HUDShouldDraw", "HideAmmo", function(name)
    if (hide[name]) then return false end
end)

local LASTAMMOTEXT
local LASTAMMOICON
local grey = 25
local grey_ab = 200
local overall_scale = 1.1
local color_bg = NamedColor("BgColor")
local color_fg = NamedColor("FgColor")
local color_fgred = NamedColor("DamagedFg")
local fontsize = math.Round(ScreenScale(96 * overall_scale))

local function MakeFonts()
    local size_label = math.Round(ScreenScale(6 * overall_scale))
    local size_content = math.Round(ScreenScale(14 * overall_scale))

    surface.CreateFont("smallhud_label", {
        font = "Verdana", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
        extended = false,
        size = size_label,
        weight = 700,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = true,
        outline = false,
    })

    surface.CreateFont("smallhud_content", {
        font = "HalfLife2", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
        extended = false,
        size = size_content,
        weight = 600,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = true,
        outline = false,
    })
end

MakeFonts()

hook.Add("OnScreenSizeChanged", "SetupFonts", function(oldWidth, oldHeight)
    MakeFonts()
end)

local pngmatcache = {}

function GetAmmoIconMat(png)
    local pngmat = Material(png, "noclamp smooth mips")
    if (pngmatcache[png]) then return pngmatcache[png] end

    pngmatcache[png] = pngmatcache[png] or CreateMaterial("ammoiconmat" .. png, "UnlitGeneric", {
        ["$basetexture"] = pngmat:GetTexture("$basetexture"):GetName(),
        ["$additive"] = 1,
        ["$vertexcolor"] = 1,
        ["$vertexalpha"] = 1,
        ["$translucent"] = 1,
    })

    return pngmatcache[png]
end

local littlefont = "smallhud_label"
local bigfont = "smallhud_content"

local function align_box(w, h, alignh, alignv)
    local hor = ((alignh == TEXT_ALIGN_LEFT and 1) or (alignh == TEXT_ALIGN_CENTER and 0) or (alignh == TEXT_ALIGN_RIGHT and -1))
    local ver = ((alignv == TEXT_ALIGN_TOP and 1) or (alignv == TEXT_ALIGN_CENTER and 0) or (alignv == TEXT_ALIGN_BOTTOM and -1))

    return w / 2 * hor, h / 2 * ver
end

function DrawHL2Bubble(label, text, x, y, alignh, alignv, alpha, red)
    local minwidth = math.Round(ScreenScale(64 * overall_scale))
    local margin = math.Round(ScreenScale(2 * overall_scale))
    local gap = 0
    alpha = alpha or 1
    local bgcol = ColorAlpha(color_bg, color_bg.a * alpha)
    local fgcol = ColorAlpha(color_fg, color_fg.a * alpha)
    local fgcolred = ColorAlpha(color_fgred, color_fgred.a * alpha)
    surface.SetFont(littlefont)
    local labelwidth, labelheight = surface.GetTextSize(label)
    surface.SetFont(bigfont)
    local textwidth, textheight = surface.GetTextSize(text)
    local box_width, box_height = math.max(labelwidth or 0, textwidth or 0, minwidth), math.max(labelheight, textheight)
    local ofsx, ofsy = align_box(box_width, box_height, alignh, alignv)
    x = x + ofsx
    y = y + ofsy
    local box_x, box_y = x - box_width / 2, y - box_height / 2
    local label_x, label_y = box_x + margin, box_y + box_height - margin
    draw.RoundedBox(8, box_x, box_y, box_width, box_height, bgcol)
    draw.SimpleText(label, littlefont, label_x, label_y, fgcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    local content_x, content_y = box_x + box_width - margin, box_y + box_height
    draw.SimpleText(text, bigfont, content_x, content_y, (text == 0 or red) and fgcolred or fgcol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

    return box_width, box_height
end

function DrawHL2Label(label, x, y, alignh, alignv, alpha)
    local minwidth = math.Round(ScreenScale(64 * overall_scale))
    local margin = math.Round(ScreenScale(2 * overall_scale))
    local gap = 0
    alpha = alpha or 1
    local bgcol = ColorAlpha(color_bg, color_bg.a * alpha)
    local fgcol = ColorAlpha(color_fg, color_fg.a * alpha)
    local fgcolred = ColorAlpha(color_fgred, color_fgred.a * alpha)
    surface.SetFont(littlefont)
    local labelwidth, labelheight = surface.GetTextSize(label)
    local box_width, box_height = math.max(labelwidth or 0, textwidth or 0, minwidth), labelheight + margin * 2
    local ofsx, ofsy = align_box(box_width, box_height, alignh, alignv)
    x = x + ofsx
    y = y + ofsy
    local box_x, box_y = x - box_width / 2, y - box_height / 2
    local label_x, label_y = x, box_y + margin + labelheight / 2
    draw.RoundedBox(8, box_x, box_y, box_width, box_height, bgcol)
    draw.SimpleText(label, littlefont, label_x, label_y, fgcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    return box_width, box_height
end

function DrawAmmoGuage(count, icon, x, y, alignh, alignv, alpha)
    local minwidth = math.Round(ScreenScale(64 * overall_scale))
    local margin = math.Round(ScreenScale(2 * overall_scale))
    local gap = 0
    local collimit = 8
    local drawcount = count == 0 and 1 or math.min(count, collimit)
    alpha = alpha or 1
    local bgcol = ColorAlpha(color_bg, color_bg.a * alpha)
    local fgcol = ColorAlpha(color_fg, color_fg.a * alpha)
    local fgcolred = ColorAlpha(color_fgred, color_fgred.a * alpha)
    local icongap = math.Round(ScreenScale(1 * overall_scale))
    local iconmax = math.Round(ScreenScale(6 * overall_scale))
    local iconsh = math.min(math.ceil(drawcount), collimit)
    local iconsize = iconmax
    local box_width, box_height = minwidth, ((iconsize + icongap) - icongap + margin * 2)
    local ofsx, ofsy = align_box(box_width, box_height, alignh, alignv)
    x = x + ofsx
    y = y + ofsy
    local box_x, box_y = x - box_width / 2, y - box_height / 2
    draw.RoundedBox(8, box_x, box_y, box_width, box_height, bgcol)
    surface.SetDrawColor(fgcol)
    local mat = GetAmmoIconMat(icon)
    surface.SetMaterial(mat)
    render.PushFilterMag(TEXFILTER.LINEAR)
    render.PushFilterMin(TEXFILTER.LINEAR)
    local remcount = count

    if (count > collimit) then
        draw.SimpleText(math.ceil(count) .. "", littlefont, x - margin, y, fgcol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        local icx, icy = x, y - iconsize / 2
        surface.DrawTexturedRect(icx, icy, iconsize, iconsize)
    else
        local recenter = ((iconsh * (iconsize + icongap)) - icongap) / 2

        for i = 1, math.ceil(drawcount) do
            local fill = math.Clamp(remcount, 0, 1)
            fill = math.Round(fill * iconsize) / iconsize
            local emptycol = fgcolred
            local icx, icy = x - recenter + ((i - 1) * (iconsize + icongap)), box_y + margin

            if (fill == 1) then
                surface.DrawTexturedRect(icx, icy, iconsize, iconsize)
            else
                surface.DrawTexturedRectUV(icx, icy + iconsize * (1 - fill), iconsize, iconsize * fill, 0, (1 - fill), 1, 1)
                surface.SetDrawColor(ColorAlpha(emptycol, emptycol.a * 2))
                surface.DrawTexturedRectUV(icx, icy, iconsize, iconsize * (1 - fill), 0, 0, 1, (1 - fill))
            end

            remcount = remcount - 1
        end
    end

    render.PopFilterMag()
    render.PopFilterMin()

    return box_width, box_height
end

local AMMOLABEL_MAGCOUNTER = 1
local AMMOLABEL_LABEL = 2

local wicons = {
    weapon_frag = "hud/ammo_grenade.png",
    weapon_rpg = "hud/ammo_rocket.png",
    weapon_crossbow = "hud/ammo_projectile.png",
    weapon_357 = "hud/ammo_misc.png",
    weapon_peacekeeper = "hud/ammo_misc.png",
}

hook.Add("HUDPaint", "SwampHealthAmmo", function()
    if (GetConVar("cinema_hideinterface") and GetConVar("cinema_hideinterface"):GetBool() == true) then return end
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    local alpha = AMMO_ALPHA
    local drawammo = ply:Alive() and IsValid(wep) and ((wep.DrawAmmo ~= nil and wep.DrawAmmo) or (wep.DrawAmmo == nil and true))

    if (IsValid(wep) and wep:GetClass() == "weapon_shotgun") then
        drawammo = false
    end

    if (drawammo) then
        local clip = wep:Clip1()
        local clipsize = (wep.Primary and wep.Primary.ClipSize) or wep:GetMaxClip1()
        local ammotype = wep:GetPrimaryAmmoType()
        local ammo = ply:GetAmmoCount(wep:GetPrimaryAmmoType())
        local ammosize = game.GetAmmoMax(wep:GetPrimaryAmmoType())
        local icon = clipsize < 1 and "hud/ammo_misc.png" or clipsize == 1 and "hud/ammo_projectile.png" or "hud/ammo_mag.png"
        local customammo = wep.CustomAmmoDisplay and wep:CustomAmmoDisplay() or {}
        local drawtype = AMMOLABEL_MAGCOUNTER

        if (customammo.PrimaryAmmo) then
            ammo = customammo.PrimaryAmmo
        end

        if (customammo.PrimaryClip) then
            clip = customammo.PrimaryClip
        end

        if (wicons[wep:GetClass()]) then
            icon = wicons[wep:GetClass()]
        end

        if (wep.MagIcon) then
            icon = wep.MagIcon
        end

        if (ammotype == nil or ammotype == -1) then
            ammo = nil
        end

        if (clipsize <= 1) then
            clipsize = nil
        end

        if (ammo) then
            local clipcount = (ammo / (clipsize or 1))

            LASTAMMOTEXT = {drawtype, clipcount, icon}
        else
            drawammo = false
        end

        if (customammo.DrawLabel) then
            drawtype = AMMOLABEL_LABEL

            if (customammo.Label) then
                LASTAMMOTEXT = {drawtype, customammo.Label}

                drawammo = true
            else
                drawammo = false
            end
        end
    end

    AMMO_ALPHA = math.Approach(AMMO_ALPHA or 0, drawammo and 1 or 0, FrameTime() * 4)
    local stack_height = 0

    if (AMMO_ALPHA > 0 and LASTAMMOTEXT) then
        local showtype = LASTAMMOTEXT[1]
        local value = LASTAMMOTEXT[2]
        local icon = LASTAMMOTEXT[3] or "hud/ammo_mag.png"
        local w, h = 0, 0

        if (showtype == AMMOLABEL_MAGCOUNTER) then
            w, h = DrawAmmoGuage(value, icon, ScrW() - 8, ScrH() - 8, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, AMMO_ALPHA)
        end

        if (showtype == AMMOLABEL_LABEL) then
            w, h = DrawHL2Label(value, ScrW() - 8, ScrH() - 8, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, AMMO_ALPHA)
        end

        h = h * AMMO_ALPHA
        stack_height = stack_height + h + 4
    end

    local drawhealth = ply:Alive() and ply:Health() < ply:GetMaxHealth()
    HEALTH_ALPHA = math.Approach(HEALTH_ALPHA or 0, drawhealth and 1 or 0, FrameTime() * 4)

    if (HEALTH_ALPHA > 0) then
        DrawHL2Bubble("HEALTH", math.max(0, LocalPlayer():Health()), ScrW() - 8, ScrH() - 8 - stack_height, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, HEALTH_ALPHA, ply:Health() <= 20)
    end
end)