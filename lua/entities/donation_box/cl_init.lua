-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")

function ENT:Initialize()
    self:SetRenderBounds(Vector(-10, -100, -10), Vector(10, 100, 200))
end

function ENT:Draw()
    -- retarded thing reset the renderbounds when exit+enter pvs
    self:Initialize()

    if self:GetLibtarded() then
        render.SetColorModulation(3, 0.5, 1.5)
    else
        render.SetColorModulation(3, 1.5, 0.5)
    end

    self:DrawModel()
    render.SetColorModulation(1, 1, 1)
end

surface.CreateFont("PatriotFont1", {
    font = "Times New Roman",
    extended = false,
    size = 114,
    weight = 500
})

surface.CreateFont("PatriotFont2", {
    font = "Courier New",
    extended = true,
    size = 60,
    weight = 1000
})

surface.CreateFont("PatriotFont3", {
    font = "Times New Roman",
    extended = false,
    size = 80,
    weight = 500
})

function ENT:DrawTranslucent()
    if EyePos():DistToSqr(self:GetPos()) > 2000000 then return end

    cam.Culled3D2D(self:GetPos() + Vector(0, 0, 100) + self:GetAngles():Forward() * (-6 + 1), self:LocalToWorldAngles(Angle(0, 90, 90)), 0.1, function()
        local ox, oy = 0, 0

        if self:GetLibtarded() then
            ox = 500
            oy = 350
        end

        draw.DrawText(self:GetLibtarded() and "Joe Biden's Allies" or "Donald J. Trump's Golden Patriots", "PatriotFont1", ox, oy - 500, color_black, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(ox - 700, oy - 376, 1400, 4)
        draw.DrawText(self:GetPatriots(), "PatriotFont2", ox - 500, oy - 350, color_black, TEXT_ALIGN_LEFT)
        draw.DrawText("Donate Here", "PatriotFont3", 0, 750, color_black, TEXT_ALIGN_CENTER)
    end)
end

--NOMINIFY
net.Receive("DonationBoxPoints", function()
    local libtard = net.ReadBool()

    local bgmaterial = CreateMaterial("trumpdonationwindowbg", "UnlitGeneric", {
        ["$basetexture"] = "swamponions/errorpainting"
    })

    vgui("DFrame", function(p)
        p:SetSize(550, 400)
        p:Center()
        p:MakePopup()
        p:SetTitle("")
        p:DockPadding(80, 80, 80, 80)
        p:CloseOnEscape()
        p:ShowCloseButton(false)

        p.Paint = function(self, w, h)
            if libtard then
                for hue = 0, 5 do
                    local c = HSVToColor(hue * 60, 1, 1)
                    surface.SetDrawColor(c.r, c.g, c.b, 255)
                    surface.DrawRect(0, (h / 6) * hue, w, math.ceil(h / 6))
                end
            else
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(bgmaterial)
                surface.DrawTexturedRect(0, 0, w, h)
            end

            local m1, m2 = 0.125, 0.155
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawRect(w * m1, h * m2, w * (1 - 2 * m1), h * (1 - 2 * m2))
        end

        local frame = p
        local pointentry

        local function submit()
            net.Start('DonationBoxPoints')
            net.WriteUInt(math.max(0, tonumber(pointentry:GetValue())), 32)
            net.WriteBool(libtard)
            net.SendToServer()
            frame:Close()
        end

        vgui("DLabel", function(p)
            p:SetContentAlignment(8)
            p:SetColor(color_black)
            p:SetText(libtard and [[ joe biden is raising points to promote racial equity and LGBTQ rights
by fighting racism, sexism, homophobia, transphobia, and ableism!

he is calling upon all his supporters for donations to build back better!

contribute now! the top 10 donors will have the exclusive honor of
                    being a joe biden ally!]] or [[     Donald J. Trump is raising points to fight the Radical Far Left Democrats,
 the Big Tech Cartels, the Fake News Media, and the Washington D.C. Swamp!

          He is calling upon all his supporters for donations to Save America!

         Contribute now! The top 10 donors will have the exclusive honor of
                            being a DONALD J. TRUMP GOLDEN PATRIOT!]])
            p:SetTall(110)
            p:Dock(TOP)
        end)

        vgui("DPanel", function(p)
            p.Paint = function() end
            p:Dock(TOP)
            p:DockMargin(100, 0, 100, 0)
            p:SetTall(72)

            vgui("DLabel", function(p)
                p:SetContentAlignment(5)
                p:SetColor(color_black)
                p:SetText("Enter number of points:")
                p:Dock(TOP)
            end)

            pointentry = vgui("DNumberWang", function(p)
                p:SetTextColor(Color(0, 0, 0, 255))
                p:SetTall(24)
                p:Dock(TOP)
                p.OnEnter = submit
            end)

            vgui("DPanel", function(p)
                p:SetDrawBackground(false)
                p:DockMargin(0, 5, 0, 0)
                p:Dock(BOTTOM)

                vgui('DButton', function(p)
                    p:SetText('Cancel')
                    -- p:DockMargin(4, 0, 0, 0)
                    p:Dock(LEFT)

                    p.DoClick = function()
                        frame:Close()
                    end
                end)

                vgui('DButton', function(p)
                    p:SetText('Donate')
                    -- p:DockMargin(0, 0, 4, 0)
                    p:Dock(RIGHT)
                    p.DoClick = submit
                end)
            end)
        end)

        vgui("DLabel", function(p)
            p:SetContentAlignment(2)
            p:SetColor(color_black)
            p:SetText([[NO REFUNDS!!!!]])
            p:SetTall(30)
            p:Dock(TOP)
        end)

        vgui("DLabel", function(p)
            p:SetContentAlignment(5)
            -- p:SetColor(color_black)
            p:SetText([[(disclaimer: this is not a donation to ]] .. (libtard and "any real-world political\n" or "the real-world Donald Trump\n") .. [[        campaign - they don't accept swamp cinema points)]])
            p:SetTall(50)
            p:Dock(TOP)
        end)
    end)
end)
