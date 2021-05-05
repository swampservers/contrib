-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

AddCSLuaFile()
HintConVar = CreateClientConVar("swamp_showhints", "1", true, false, "", 0, 1)

SWAMP_HINTS = {
    intro = function() return "Welcome to Swamp Cinema! Hold " .. (input.LookupBinding("showscores") or "the scoreboard key (bind it in options)") .. " to see what's playing." end,
    settings = function() return "You can also disable hints from this menu (click to unlock your mouse)" end,
    theater = function() return "Inside theaters, you can hold " .. string.upper(input.LookupBinding("menu") or "the spawn menu key (bind it in options)") .. " to request your own video." end,
    store = function() return "Press " .. string.upper(input.LookupBinding("menu_context") or "the context menu key (bind it in options)") .. " to open the shop and get fun items, weapons, and cosmetics. Many items are free!" end,
}

CURRENT_SWAMP_HINT = "intro"
SWAMP_HINT_JOIN_CURTIME = SWAMP_HINT_JOIN_CURTIME or CurTime()

function SetSwampHint(to, timelimit)
    --unset hints once they're shown
    if CURRENT_SWAMP_HINT then
        SWAMP_HINTS[CURRENT_SWAMP_HINT] = nil
    end

    CURRENT_SWAMP_HINT = SWAMP_HINTS[to] and to or nil
end

hook.Add("Think", "SwampHintThink", function()
    local lp = LocalPlayer()
    if not IsValid(lp) then return end

    if not CURRENT_SWAMP_HINT then
        if lp.InTheater and lp:InTheater() then
            SetSwampHint("theater")
        end

        -- if not lp:Alive() then SetSwampHint("store") end
        if CurTime() - SWAMP_HINT_JOIN_CURTIME > 40 then
            SetSwampHint("store")
        end
    elseif CURRENT_SWAMP_HINT == "intro" then
        local b = input.LookupBinding("showscores")

        if b and input.IsButtonDown(input.GetKeyCode(b)) then
            SetSwampHint("settings")
        end
    elseif CURRENT_SWAMP_HINT == "settings" then
        local b = input.LookupBinding("showscores")

        if b and not input.IsButtonDown(input.GetKeyCode(b)) then
            SetSwampHint()
        end
    elseif CURRENT_SWAMP_HINT == "theater" then
        local b = input.LookupBinding("menu")

        if b and input.IsButtonDown(input.GetKeyCode(b)) then
            SetSwampHint()
        end
    elseif CURRENT_SWAMP_HINT == "store" then
        local b = input.LookupBinding("menu_context")

        -- if input.IsKeyDown(KEY_F3) then
        if b and input.IsButtonDown(input.GetKeyCode(b)) then
            SetSwampHint()
        end
    end
end)

hook.Add("PostRenderVGUI", "Hint_PostRenderVGUI", function()
    if not HintConVar:GetBool() then return end
    if not CURRENT_SWAMP_HINT then return end
    surface.SetFont("DermaLarge")
    local txt = SWAMP_HINTS[CURRENT_SWAMP_HINT]()
    if not txt then return end
    local w, h = surface.GetTextSize(txt)
    local cx, cy = ScrW() / 2, 50
    draw.RoundedBox(8, cx - w / 2 - 8, cy - h / 2 - 8, w + 16, h + 16, Color(0, 0, 0, 200))
    draw.DrawText(txt, "DermaLarge", cx - w / 2, cy - h / 2, Color(255, 255, 255, 255))
end)