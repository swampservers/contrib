-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
--NOMINIFY

vgui.Register("DSSTitleInfo", {
    SetTitle = function(self, title)
        self.Title = title
    end,
    Think = function(self)
        if not self.Title then return end
        local progress = self.Title:Progress(LocalPlayer())
        if progress==self.LastProgress then return end
        self.LastProgress = progress

        -- setup for this title/progress
        -- note: Text will be removed
        for _, v in ipairs( self:GetChildren() ) do
            v:Remove()
        end

        for min,name in self.Title:Thresholds() do
            vgui("DLabel", self, function(p)
                p:SetFont("SS_DESCINSTFONT")
                p:SetText(name)
                p:SetTextColor(SS_SwitchableColor)
                p:SizeToContents()
                p:SetContentAlignment(5)
                p:DockMargin(0, 0, 0, SS_COMMONMARGIN)
                p:Dock(TOP)
            end)

            vgui("DLabel", self, function(p)
                p:SetText(self.Title:Description(min))
                p:Dock(TOP)
            end)

            vgui("DButton", self, function(p)
                if progress>=min then
                    p:SetText("Select title")
                else
                    p:SetText("Title locked ("..progress.."/"..min..")")
                    p:SetEnabled(false)
                end
                p:Dock(TOP)

                p.DoClick = function()
                    net.Start("PlayerTitle")
                    net.WriteString(name)
                    net.SendToServer()
                end
            end)
        end

            
    end
}, "DSSCustomizerSection")



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
                vgui("DSSTitleInfo", self, function(p)
                    p:SetTitle(title)
                end)

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
