-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- GLOBAL


function OpenTitlePicker()

    vgui( "DFrame", function(p)
        local frame = p
        p:SetSize( 200, 120 ) 	
        p:SetTitle( "Title Changer" ) 	
        p:MakePopup() 	
        p:Center()
        p:CloseOnEscape()

        vgui("DLabel", function(p)
            p:SetText("Get a title by being a top donor\nto trump or biden (more titles coming)")
            -- p:SetTextWrap(true)
            p:Dock(TOP)
            p:SizeToContents()
        end)


        vgui("DLabel", function(p)
            p:Dock(TOP)
            local t = LocalPlayer():GetTitle()
            p:SetText("Current title: "..(t=="" and "None" or t))
        end)
            
        local titlepicker = vgui( "DComboBox", function(p)
            p:Dock(TOP)
            p:SetValue(LocalPlayer():GetTitle())
            p:AddChoice("None")
            p:ChooseOption("None",1)
            for i,v in ipairs(LocalPlayer():GetTitles()) do
                p:AddChoice( v)
            end
            -- p.OnSelect = function( self, index, value )

            -- end
        end)


        vgui( "DButton", function(p)
            p:SetText("Apply")
            p:Dock(TOP)
            p.DoClick = function()
                net.Start("PlayerTitles")
                local t = titlepicker:GetValue()
                if t=="None" then t="" end
                net.WriteString(t)
                net.SendToServer()
                frame:Close()
            end
        end) 

    end)	


end