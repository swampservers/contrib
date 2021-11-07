-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA


vgui.Register('DSSPlayerSettingsMode', {

    Init = function(self)
        
        vgui("DSSCustomizerSection", self, function(p)
            p:SetText("Title")
            local frame = p

            vgui("DLabel", function(p)
                p:SetText("Get a title by being a top donor to trump or biden (more titles coming)")
                -- p:SetTextWrap(true)
                p:Dock(TOP)
                p:SizeToContents()
            end)

            vgui("DLabel", function(p)
                p:Dock(TOP)

                function p:Think()
                    local t = LocalPlayer():GetTitle()
                    self:SetText("Current title: " .. (t == "" and "None" or t))
                end
            end)

            local titlepicker = vgui("DComboBox", function(p)
                p:Dock(TOP)
                p:SetValue(LocalPlayer():GetTitle())
                p:AddChoice("None")
                p:ChooseOption("None", 1)

                for i, v in ipairs(LocalPlayer():GetTitles()) do
                    p:AddChoice(v)
                    if v==LocalPlayer():GetTitle() then
                        p:ChooseOption(v, 1)
                    end
                end
            end)

            -- p.OnSelect = function( self, index, value )
            -- end
            vgui("DButton", function(p)
                p:SetText("Apply")
                p:Dock(TOP)

                p.DoClick = function()
                    net.Start("PlayerTitles")
                    local t = titlepicker:GetValue()

                    if t == "None" then
                        t = ""
                    end

                    net.WriteString(t)
                    net.SendToServer()
                    -- frame:Close()
                end
            end)
        end)

    end

}, 'DSSScrollableMode')
