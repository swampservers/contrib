-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include('shared.lua')


function  ValentineUI(dear, sincerely)
    if IsValid(ValentineFrame) then ValentineFrame:Remove() end
    ValentineFrame = vgui("DFrame", function(p)
        p:SetSize(600,600)
        p:Center()
        p:MakePopup()
        p:SetTile("asdf")
        function p:Paint(w,h)
            surface.SetMaterial(Material["holiday/valentine_card_unlit"])
            surface.SetDrawColor(Color.white)
            surface.DrawTexturedRect(0,0,w,h)
        end

        vgui("DLabel", function(p)
            p:SetText("Dear "..dear)
            p:SetContentAlignment(5)
            p:Dock(TOP)
        end)


        vgui("DLabel", function(p)
            p:SetText(sincerely)
            p:SetContentAlignment(5)
            p:Dock(BOTTOM)
        end)

        vgui("DLabel", function(p)
            p:SetText("Sincerely,")
            p:SetFont(Font["Segoe Script24"])
            p:SetContentAlignment(5)
            p:Dock(BOTTOM)
        end)


        
        p.Button1=vgui("DButton",  function(p)
  
            p:SetPos(ValentineFrame:GetTall()-p:GetTall(), ValentineFrame:GetWide()/2 - p:GetWide())
            
        end)

        p.Button2=vgui("DButton",  function(p)

            p:SetPos(ValentineFrame:GetTall()-p:GetTall(), ValentineFrame:GetWide()/2)

        end)

        p.Note = vgui("DLabel",  function(p)
            p:SetPos(ValentineFrame:GetTall()-40, 0)
            p:SetSize(ValentineFrame:GetWide(),40)
      
        end)
    end)
end
