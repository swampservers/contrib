-- This file is subject to copyright - contact swampservers@gmail.com for more information.
AddCSLuaFile()
HintConVar = CreateClientConVar("swamp_help", "1", true, false, "", 0, 1)
local wasf1down = false

hook.Add("Think", "HintToggler", function()
    local isf1down = input.IsKeyDown(KEY_F1)

    if isf1down and not wasf1down then
        HintConVar:SetInt((HintConVar:GetInt() + 1) % 2)
    end

    wasf1down = isf1down
end)

function BindingName(bind, desc)
    local a = input.LookupBinding(bind) or input.LookupBinding("+" .. bind)

    if a then
        return string.upper(a)
    else
        return "the " .. desc .. " key (bind it in options)"
    end
end

local SetupFontForScrW
local partwidths
local totalwidth
local xmultiplier
local row0h
local row1h
local row2h
local topgap
local dividery
local alpha = 0

-- on top of other stuff without PostDrawHUD's weird messed up kerning
hook.Add("HUDDrawScoreBoard", "Hint_Draw", function()
    if ScrW() <= 800 and ScrH() <= 600 then
        draw.SimpleText("Your resolution is only " .. ScrW() .. "x" .. ScrH() .. ".", "Trebuchet18", ScrW() / 2, ScrH() - 36, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText("For a better experience, press escape and go to Options->Video to fix it!", "Trebuchet18", ScrW() / 2, ScrH() - 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    alpha = math.Clamp(alpha + (HintConVar:GetBool() and 1 or -1) * FrameTime() * 4, 0, 1)
    if alpha == 0 then return end
    local shift = 0.5 + 0.5 * math.cos(alpha * math.pi)
    local scrw = ScrW()
    local pad = "  "

    local controlhints = {
        {BindingName("showscores", "scoreboard"), pad .. "Show currently playing videos and settings:" .. pad},
        {BindingName("menu", "spawn menu"), pad .. pad .. "Request videos while in theaters:" .. pad},
        {BindingName("use", "use item"), pad .. "Sit in seats (to avoid being killed!):" .. pad},
        {BindingName("menu_context", "context menu"), pad .. "Open shop (for toys/weapons/props, many free):" .. pad},
        {BindingName("messagemode", "chat message") .. " or " .. BindingName("messagemode2", "team message"), pad .. "Text chat:" .. pad},
        {BindingName("voicerecord", "Use voice communication"), pad .. "Voice chat (push-to-talk):" .. pad},
        {"F1", pad .. "Hide this menu:" .. pad .. pad}
    }

    local teststr = ""

    for i, v in ipairs(controlhints) do
        teststr = teststr .. pad .. v[2] .. pad
    end

    if SetupFontForScrW ~= scrw then
        local sz = 18

        local function tryfont()
            surface.CreateFont('HintControls', {
                font = "CircularStd-Book",
                size = sz,
            })

            surface.SetFont('HintControls')
            local w, h = surface.GetTextSize(teststr)

            return w >= scrw
        end

        while sz < 40 do
            if tryfont() then break end
            sz = sz + 1
        end

        while sz > 11 do
            if not tryfont() then break end
            sz = sz - 1
        end

        partwidths = {}
        totalwidth = 0

        for i, v in ipairs(controlhints) do
            local w, h = surface.GetTextSize(v[2])
            table.insert(partwidths, w)
            totalwidth = totalwidth + w
            row1h = h
            topgap = 0 --math.Round(h/8)
        end

        while totalwidth <= scrw - #partwidths do
            for i = 1, #partwidths do
                partwidths[i] = partwidths[i] + 1
            end

            totalwidth = totalwidth + math.max(1, #partwidths)
        end

        xmultiplier = scrw / totalwidth

        surface.CreateFont('HintControlKeys', {
            font = 'coolvetica',
            size = sz * 1.4,
            weight = 1000,
        })

        surface.SetFont('HintControlKeys')
        _, row2h = surface.GetTextSize("A")

        surface.CreateFont('HintHeader', {
            font = "CircularStd-Book",
            size = sz,
            weight = 1000,
        })

        surface.SetFont('HintHeader')
        _, dividery = surface.GetTextSize("A")
        dividery = math.Round(dividery * 1.2)
        SetupFontForScrW = scrw
    end

    local yoffset = math.Round((dividery + topgap + row1h + row2h) * shift)
    surface.SetDrawColor(Color(44, 44, 44))
    surface.DrawRect(0, -yoffset, scrw, dividery)
    BrandUpGradient(0, dividery - yoffset, scrw)
    BrandDropDownGradient(0, dividery + topgap + row1h + row2h - yoffset, scrw)
    BrandGrayBackgroundPattern(0, dividery - yoffset, scrw, topgap + row1h + row2h)
    draw.SimpleText("Welcome to Swamp Cinema! Some useful controls are shown below:", 'HintHeader', scrw / 2, dividery / 2 - yoffset, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    local cw = 0

    for i, v in ipairs(controlhints) do
        local w = partwidths[i]
        local x = (cw + w / 2) * xmultiplier
        draw.SimpleText(v[2], 'HintControls', x, dividery + topgap - yoffset, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(v[1], 'HintControlKeys', x, dividery + topgap + row1h - yoffset, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        cw = cw + w
    end
end)

if GetConVar("cl_downloadfilter"):GetString() ~= "all" then
    -- put it on an imgur image because they have downloads disabled
    hook.Add("PostDrawHUD", "DownloadWarning", function()
        -- if gui.IsGameUIVisible() then return end
        surface.SetDrawColor(255, 255, 255, 255)

        surface.SetMaterial(WebMaterial({
            id = GetConVar("cl_downloadfilter"):GetString() == "all" and "0mmU13f.png" or "qdwRnPl.png",
            shader = "UnlitGeneric",
            stretch = true
        }))

        surface.DrawTexturedRect((ScrW() - 1024) / 2, (ScrH() - 464) / 2, 1024, 464)
    end)
    -- timer.Create("downloadautorejoin",0.1,0,function()
    --     if DownloadCVar:GetString()=="all" then RunConsoleCommand("retry") end
    -- end)
end
