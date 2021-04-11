-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
function CreateRentWindow()
    local window = vgui.Create("CinemaRentalsWindow")
    window:SetSize(450, 125)
    window:SetTitle("Protect Theater")
    local desc = vgui.Create("DLabel", window)
    desc:SetWrap(true)
    desc:SetText("Protect your theater to prevent weapons from being used inside it. Lasts for 20 minutes.")
    desc:SetFont("Trebuchet24")
    desc:SetContentAlignment(5)
    desc:SetSize(window:GetWide() - 16, 60)
    desc:SetPos(8, window:GetTall() - 90)
    desc:CenterHorizontal()
    local rentButton = vgui.Create("TheaterButton", window)
    rentButton:SetText("Purchase")
    rentButton:SetSize(window:GetWide() - 8, 25)
    rentButton:SetPos(0, window:GetTall() - rentButton:GetTall() - 4)
    rentButton:CenterHorizontal()

    rentButton.DoClick = function(btn)
        -- net.Start("protectPT")
        -- net.SendToServer()
        RunConsoleCommand("say", "/protect")
        window:Remove()
    end

    window.Think = function(pnl)
        local t = getPTProtectionCost(getPTProtectionTime(Location.Find(LocalPlayer())))

        if t > 0 then
            rentButton:SetText("Purchase for " .. tostring(t) .. " Points")
        else
            rentButton:SetText("Play a video to buy protection")
        end
    end

    window:Center()
    window:MakePopup()
end

local thumbWidth = 480
local thumbHeight = 360
local renderScale = 0.2
local str, col, tw, th, ty, bw, bh, by, scale, location = nil

hook.Add("PostDrawTranslucentRenderables", "TheaterRentals_Thumasdfbnails", function(depth, sky)
    if depth or sky then return end

    for _, ent in ipairs(ents.FindByClass("theater_thumbnail")) do
        if ent.Attach and ent:GetNWBool("Rentable") then
            location = ent:GetNWInt("Location")
            local tb = protectedTheaterTable[location]

            if tb ~= nil and tb["time"] > 1 then
                surface.SetFont("TheaterInfoMedium")
                str = "Protected"
                tw, th = surface.GetTextSize(str)
                tw = tw + tw * 0.05
                scale = tw / thumbWidth
                scale = math.max(scale, 0.88)
                bw, bh = (thumbWidth * scale), (thumbHeight * scale) * 0.16
                bh = math.max(bh, th)
                by = (thumbHeight * scale)
                ty = by + (th / 2)
                cam.Start3D2D(ent.Attach.Pos, ent.Attach.Ang, (1 / scale) * renderScale)
                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawRect(0, by, bw, bh)
                draw.TheaterText(str, "TheaterInfoMedium", (thumbWidth * scale) / 2, ty, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                cam.End3D2D()
            end
        end
    end
end)