-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
--NOMINIFY
vgui.Register("DSSTitleInfo", {
    SetTitle = function(self, title)
        self.Title = title
    end,
    Think = function(self)
        if not self.Title then return end
        local progress = self.Title:Progress(Me)
        if progress == self.LastProgress then return end
        self.LastProgress = progress

        -- setup for this title/progress
        -- note: Text will be removed
        for _, v in ipairs(self:GetChildren()) do
            v:Remove()
        end

        local lastlocked = false
        local extra = 0

        for i, min, name, reward in self.Title:Thresholds() do
            if lastlocked then
                extra = extra + 1
                continue
            end

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
                p:SetText(self.Title:Description(i, min) .. (reward > 0 and " - Reward: " .. reward .. " points" or ""))
                p:Dock(TOP)
            end)

            vgui("DButton", self, function(p)
                if progress >= min then
                    p:SetText("Select title")
                else
                    p:SetText("Title locked (" .. progress .. "/" .. min .. ")")
                    p:SetEnabled(false)
                    lastlocked = true
                end

                p:Dock(TOP)

                p.DoClick = function()
                    net.Start("PlayerTitle")
                    net.WriteString(name)
                    net.SendToServer()
                end
            end)
        end

        if extra > 0 then
            vgui("DLabel", self, function(p)
                p:SetText(extra .. " more titles available")
                p:Dock(TOP)
            end)
        end
    end
}, "DSSCustomizerSection")

vgui.Register('DSSPlayerSettingsMode', {
    Init = function(self)
        SS_TitlesPanel = self

        vgui("DSSCustomizerSection", self, function(p)
            p:SetText("Titles (WIP, SOME NOT WORKING DONT COMPLAIN)")

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

        for i, title in ipairs(Titles) do
            vgui("DSSTitleInfo", self, function(p)
                p:SetTitle(title)
            end)
        end
    end
}, 'DSSScrollableMode')
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
--             local t = Me:GetTitle()
--             self:SetText("Current title: " .. (t == "" and "None" or t))
--         end
--     end)
--     local titlepicker = vgui("DComboBox", function(p)
--         p:Dock(TOP)
--         p:SetValue(Me:GetTitle())
--         p:AddChoice("None")
--         p:ChooseOption("None", 1)
--         for i, v in ipairs(Me:GetTitles()) do
--             p:AddChoice(v)
--             if v == Me:GetTitle() then
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
