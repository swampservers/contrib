-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")

function ENT:Draw()
    render.SetColorModulation(3,1.5,0.5)
    self:DrawModel()
    render.SetColorModulation(1,1,1)
end

surface.CreateFont( "PatriotFont1", {
	font = "Times New Roman",
	extended = false,
	size = 120,
	weight = 500
} )

surface.CreateFont( "PatriotFont2", {
	font = "Courier New",
	extended = true,
	size = 60,
	weight = 1000
} )

surface.CreateFont( "PatriotFont3", {
	font = "Times New Roman",
	extended = false,
	size = 80,
	weight = 500
} )

function ENT:DrawTranslucent()
    
	cam.Start3D2D( self:GetPos() + Vector(0,0,100) + self:GetAngles():Forward()*(-6 + 1), self:LocalToWorldAngles(Angle(0,90,90)), 0.1 )

    draw.DrawText("Donald Trump's Golden Patriots", "PatriotFont1", 0, -500, color_black, TEXT_ALIGN_CENTER )

    draw.DrawText(self:GetPatriots(), "PatriotFont2", -500, -350, color_black, TEXT_ALIGN_LEFT )

    draw.DrawText("Donate Here", "PatriotFont3", 0, 750, color_black, TEXT_ALIGN_CENTER )

	cam.End3D2D()


end

net.Receive("DonationBoxPoints", function()

    local bgmaterial = CreateMaterial("trumpdonationwindowbg","UnlitGeneric",{
        ["$basetexture"]="swamponions/errorpainting"
    })
    

    vgui("DFrame", function(p)
        p:SetSize(550, 400)
        p:Center()
        p:MakePopup()
        p:SetTitle("")
        p:DockPadding(80, 80, 80, 80)
        p:CloseOnEscape()

        p:ShowCloseButton(false)

        p.Paint = function(self,w,h)
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( bgmaterial ) 
            surface.DrawTexturedRect( 0, 0, w,h )
            local m1,m2 = 0.125,0.155
            surface.DrawRect( w*m1, h*m2, w*(1-2*m1),h*(1-2*m2) )
        end

        local frame = p
        local pointentry

        local function submit()
            net.Start('DonationBoxPoints')
            net.WriteUInt(tonumber(pointentry:GetValue()), 32)
            net.SendToServer()
            frame:Close()
        end

        vgui("DLabel", function(p)
            p:SetContentAlignment(8)
            p:SetColor(color_black)
            p:SetText(
[[ Donald Trump is raising points to fight the Radical Far Left Democrats,
             the Big Tech Cartels, and the Washington D.C. Swamp!

  He is calling upon all his supporters for donations to Save America!

 Contribute now! The top 10 donors will have the exclusive honor of
               being a DONALD J TRUMP GOLDEN PATRIOT!]])
            p:SetTall(110)
            p:Dock(TOP)
        end)

        vgui("DPanel", function(p)

            p.Paint = function() end

            p:Dock(TOP)
            p:DockMargin(100,0,100,0)
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
            p:SetText(
[[NO REFUNDS!!!!]])
            p:SetTall(30)
            p:Dock(TOP)
        end)

        vgui("DLabel", function(p)
            p:SetContentAlignment(5)
            -- p:SetColor(color_black)
            p:SetText(
[[(disclaimer: this is not a donation to the real-world Donald Trump
            campaign - they don't accept swamp cinema points)]])
            p:SetTall(50)
            p:Dock(TOP)
        end)


        -- local l3 = vgui.Create("DLabel", self)
        -- l3:SetText("WARNING: Sending points is not reversable!\nIf you were promised something in exchange for points,\nit might be a scam!")
        -- l3:Dock(TOP)
        -- l3:DockMargin(8, 8, 8, 8)
        -- l3:SizeToContents()


        -- vgui("Panel", function(p)
        --     p:SetWidth(100)
        --     p:Dock(LEFT)
        --     function p:Paint(w, h)
        --         surface.SetDrawColor(255, 0, 0)
        --         surface.DrawRect(0, 0, w, h)
        --     end
        --     vgui("DLabel", function(p)
        --         p:SetText("Based")
        --         p:Dock(TOP)
        --     end)
        --     vgui("DLabel", function(p)
        --         p:SetText("Redpilled")
        --         p:Dock(BOTTOM)
        --     end)
        -- end)
        -- vgui("Panel", function(p)
        --     p:DockMargin(20, 20, 20, 20)
        --     p:Dock(FILL)
        --     function p:Paint(w, h)
        --         surface.SetDrawColor(0, 0, 255)
        --         surface.DrawRect(0, 0, w, h)
        --     end
        --     vgui("Panel", function(p)
        --         p:Dock(BOTTOM)
        --         vgui("DButton", function(p)
        --             p:SetText("Cringe")
        --             p:Dock(LEFT)
        --         end)
        --         vgui("DButton", function(p)
        --             p:SetText("Bluepilled")
        --             p:Dock(RIGHT)
        --         end)
        --     end)
        -- end)
    end)



end)
