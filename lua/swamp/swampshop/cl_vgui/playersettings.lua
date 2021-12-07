-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
vgui.Register('DSSPlayerSettingsMode', {
    Init = function(self)

        vgui("DSSCustomizerSection", self, function(p)
            function p:Think()
                local t = LocalPlayer():GetTitle()
                p:SetText("Titles (WIP) - Current title: "..(t=="" and "None" or t))
            end

            vgui("DButton", function(p)
                p:SetText("Remove title")
                p:Dock(TOP)

                p.DoClick = function()
                    net.Start("PlayerTitle")
                    net.WriteString("")
                    net.SendToServer()
                end
            end)
        end)

        for i,title in ipairs(Titles) do
            for min,name in title:Thresholds() do

                vgui("DSSCustomizerSection", self, function(p)


                    p:SetText(name)

                    vgui("DLabel", function(p)
                        p:SetText(title:Description(min))
                        p:Dock(TOP)
                    end)

                    vgui("DButton", function(p)
                        p:SetText("Select title")
                        p:Dock(TOP)
        
                        p.DoClick = function()
                            net.Start("PlayerTitle")
                            net.WriteString(n)
                            net.SendToServer()
                        end
                    end)


                end)


            end


        end
        


        -- vgui("DSSCustomizerSection", self, function(p)
        --     p:SetText("Title")
        --     local frame = p

        --     vgui("DLabel", function(p)
        --         p:SetText("Get a title by being a top donor to trump or biden (more titles coming)")
        --         -- p:SetTextWrap(true)
        --         p:Dock(TOP)
        --         p:SizeToContents()
        --     end)

        --     vgui("DLabel", function(p)
        --         p:Dock(TOP)

        --         function p:Think()
        --             local t = LocalPlayer():GetTitle()
        --             self:SetText("Current title: " .. (t == "" and "None" or t))
        --         end
        --     end)

        --     local titlepicker = vgui("DComboBox", function(p)
        --         p:Dock(TOP)
        --         p:SetValue(LocalPlayer():GetTitle())
        --         p:AddChoice("None")
        --         p:ChooseOption("None", 1)

        --         for i, v in ipairs(LocalPlayer():GetTitles()) do
        --             p:AddChoice(v)

        --             if v == LocalPlayer():GetTitle() then
        --                 p:ChooseOption(v, 1)
        --             end
        --         end
        --     end)

        --     -- p.OnSelect = function( self, index, value )
        --     -- end
        --     vgui("DButton", function(p)
        --         p:SetText("Apply")
        --         p:Dock(TOP)

        --         p.DoClick = function()
        --             net.Start("PlayerTitles")
        --             local t = titlepicker:GetValue()

        --             if t == "None" then
        --                 t = ""
        --             end

        --             net.WriteString(t)
        --             net.SendToServer()
        --         end
        --     end)
        -- end)
    end
}, 'DSSScrollableMode')
