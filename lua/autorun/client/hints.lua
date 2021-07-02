-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
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

local function bindingname(bind, desc)
    local a = input.LookupBinding(bind) or input.LookupBinding("+" .. bind)

    if a then
        return string.upper(a)
    else
        return "the " .. desc .. " key (bind it in options)"
    end
end

-- SWAMP_HINTS = {
--     intro = function() return "Welcome to Swamp Cinema! Hold " .. (input.LookupBinding("showscores") or "the scoreboard key (bind it in options)") .. " to see what's playing." end,
--     settings = function() return "You can also disable hints from this menu (click to unlock your mouse)" end,
--     theater = function() return "Inside theaters, you can hold " .. string.upper(input.LookupBinding("menu") or "the spawn menu key (bind it in options)") .. " to request your own video." end,
--     store = function() return "Press " .. string.upper(input.LookupBinding("menu_context") or "the context menu key (bind it in options)") .. " to open the shop and get fun items, weapons, and cosmetics. Many items are free!" end,
-- }
-- CURRENT_SWAMP_HINT = "intro"
-- SWAMP_HINT_JOIN_CURTIME = SWAMP_HINT_JOIN_CURTIME or CurTime()
-- function SetSwampHint(to, timelimit)
--     --unset hints once they're shown
--     if CURRENT_SWAMP_HINT then
--         SWAMP_HINTS[CURRENT_SWAMP_HINT] = nil
--     end
--     CURRENT_SWAMP_HINT = SWAMP_HINTS[to] and to or nil
-- end
-- hook.Add("Think", "SwampHintThink", function()
--     local lp = LocalPlayer()
--     if not IsValid(lp) then return end
--     if not CURRENT_SWAMP_HINT then
--         if lp.InTheater and lp:InTheater() then
--             SetSwampHint("theater")
--         end
--         -- if not lp:Alive() then SetSwampHint("store") end
--         if CurTime() - SWAMP_HINT_JOIN_CURTIME > 40 then
--             SetSwampHint("store")
--         end
--     elseif CURRENT_SWAMP_HINT == "intro" then
--         local b = input.LookupBinding("showscores")
--         if b and input.IsButtonDown(input.GetKeyCode(b)) then
--             SetSwampHint("settings")
--         end
--     elseif CURRENT_SWAMP_HINT == "settings" then
--         local b = input.LookupBinding("showscores")
--         if b and not input.IsButtonDown(input.GetKeyCode(b)) then
--             SetSwampHint()
--         end
--     elseif CURRENT_SWAMP_HINT == "theater" then
--         local b = input.LookupBinding("menu")
--         if b and input.IsButtonDown(input.GetKeyCode(b)) then
--             SetSwampHint()
--         end
--     elseif CURRENT_SWAMP_HINT == "store" then
--         local b = input.LookupBinding("menu_context")
--         -- if input.IsKeyDown(KEY_F3) then
--         if b and input.IsButtonDown(input.GetKeyCode(b)) then
--             SetSwampHint()
--         end
--     end
-- end)
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
    alpha = math.Clamp(alpha + (HintConVar:GetBool() and 1 or -1) * FrameTime() * 4, 0, 1)
    if alpha == 0 then return end
    local shift = 0.5 + 0.5 * math.cos(alpha * math.pi)
    -- if not CURRENT_SWAMP_HINT then return end
    -- surface.SetFont("DermaLarge")
    -- local txt = SWAMP_HINTS[CURRENT_SWAMP_HINT]()
    -- if not txt then return end
    -- local w, h = surface.GetTextSize(txt)
    -- local cx, cy = scrw / 2, 50
    -- draw.RoundedBox(8, cx - w / 2 - 8, cy - h / 2 - 8, w + 16, h + 16, Color(0, 0, 0, 200))
    -- draw.DrawText(txt, "DermaLarge", cx - w / 2, cy - h / 2, Color(255, 255, 255, 255))
    local scrw = ScrW()
    local pad = "   "

    local controlhints = {
        {bindingname("showscores", "scoreboard"), pad .. "Show currently playing videos and settings:" .. pad},
        {bindingname("menu", "spawn menu"), pad .. pad .. "Request videos while in theaters:" .. pad},
        {bindingname("use", "use item"), pad .. "Sit in seats (to avoid being killed!):" .. pad},
        {bindingname("menu_context", "context menu"), pad .. "Open shop (for toys/weapons/props, many free):" .. pad},
        {bindingname("messagemode", "chat message") .. " or " .. bindingname("messagemode2", "team message"), pad .. "Text chat:" .. pad},
        {bindingname("voicerecord", "Use voice communication"), pad .. "Voice chat (push-to-talk):" .. pad},
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
                font = 'Lato',
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
            font = 'Lato',
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
--     local w1,h1,finish1 = draw.WrappedText(txt,'HintControls', scrw, 0, scrw/2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, true)
-- local w1,h1,finish1 = draw.WrappedText(txt,'HintControls', scrw, 0, scrw/2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, true)
-- local h = math.max(h1,h2)
-- finish1()
-- surface.CreateFont('HintCenter', {
--     font = 'coolvetica',
--     size = 64
-- })
-- surface.CreateFont('HintControls', {
--     font = 'arial',
--     size = 20,
--     weight=500,
-- })