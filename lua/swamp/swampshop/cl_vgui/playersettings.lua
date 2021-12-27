-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--NOMINIFY
vgui.Register("DSSTitleInfo", {
    SetTitle = function(self, title)
        self.Title = title
    end,
    Think = function(self)
        if not self.Title then return end
        local progress = self.Title:Progress(Me)
        local allsame = progress == self.LastProgress
        self.Mins = self.Mins or {}
        local mins = {}

        for i, min, name, reward in self.Title:Thresholds() do
            table.insert(mins, min)
            allsame = allsame and min == self.Mins[i]
        end

        allsame = allsame and #mins == #self.Mins
        if allsame then return end
        self.Mins = mins
        self.LastProgress = progress

        -- setup for this title/progress
        -- note: Text will be removed
        for _, v in ipairs(self:GetChildren()) do
            v:Remove()
        end

        local lastlocked = false
        local extra = 0
        local pad = 20
        self.UnlockedTitles = 0
        self.LockedTitles = 0

        for i, min, name, reward in self.Title:Thresholds() do
            if progress >= min then
                self.UnlockedTitles = self.UnlockedTitles + 1
            else
                self.LockedTitles = self.LockedTitles + 1
            end

            if lastlocked and not self.Title.showall then
                extra = extra + 1
                continue
            end

            vgui("DPanel", self, function(p)
                p:Dock(TOP)
                p:SetTall(24)
                p.Paint = noop
                p:DockPadding(pad, 0, pad, 0)
                p:DockMargin(0, 0, 0, 16)

                vgui("DLabel", function(p)
                    p:SetFont("SS_DESCINSTFONT")
                    p:SetText(name)
                    p:SetTextColor(SS_SwitchableColor)
                    p:SetWide(160)
                    p:SetContentAlignment(5)
                    p:Dock(LEFT)
                end)

                vgui("DButton", function(p)
                    if progress >= min then
                        p:SetText("Select title (" .. progress .. "/" .. min .. ")")
                    else
                        p:SetText("Title locked (" .. progress .. "/" .. min .. ")")
                        p:SetEnabled(false)
                        lastlocked = true
                    end

                    p:Dock(RIGHT)
                    p:SetWide(160)

                    p.DoClick = function()
                        net.Start("PlayerTitle")
                        net.WriteString(name)
                        net.SendToServer()
                    end
                end)

                vgui("DLabel", function(p)
                    p:SetText(self.Title:Description(i, min) .. (reward > 0 and " - Reward: " .. reward .. " points" or ""))
                    p:Dock(FILL)
                    p:SetContentAlignment(5)
                end)
            end)
        end

        local group_view = self.Title.group_view

        if group_view then
            local pset = group_view[1]

            vgui("DButton", self, function(p)
                function p:Think()
                    if SHOWNPSET == pset then
                        p:SetText("Stop showing who you've " .. group_view[2])
                    else
                        p:SetText("Show who you've already " .. group_view[2])
                    end
                end

                p:DockMargin(540, 0, pad, 0)
                p:Dock(TOP)
                p:SetWide(160)

                p.DoClick = function()
                    if SHOWNPSET ~= pset then
                        SHOWNPSET = pset
                        SHOWNPSETVERB = group_view[2]
                        LocalPlayerNotify("Look at players' nameplates to see if you've " .. group_view[2] .. " them")
                    else
                        SHOWNPSET = nil
                    end
                end
            end)
        end

        if extra > 0 then
            vgui("DLabel", self, function(p)
                p:SetText(extra .. (extra == 1 and " more title available" or " more titles available"))
                p:Dock(TOP)
                p:SetContentAlignment(5)
            end)
        end
    end
}, "DSSCustomizerSection")

vgui.Register('DSSPlayerSettingsMode', {
    Init = function(self)
        SS_TitlesPanel = self
        local titlepanels = {}

        vgui("DSSCustomizerSection", self, function(p)
            function p:Think()
                local l = 0
                local u = 0

                for i, tp in ipairs(titlepanels) do
                    if tp.UnlockedTitles then
                        l = l + tp.LockedTitles
                        u = u + tp.UnlockedTitles
                    end
                end

                p:SetText("Titles (WIP) - " .. u .. "/" .. u + l .. " unlocked")
            end

            vgui("DButton", function(p)
                p:SetText("Remove title")
                p:Dock(TOP)
                p:DockMargin(40, 0, 40, 0)

                p.DoClick = function()
                    net.Start("PlayerTitle")
                    net.WriteString("")
                    net.SendToServer()
                end
            end)
        end)

        for i, title in ipairs(Titles) do
            table.insert(titlepanels, vgui("DSSTitleInfo", self, function(p)
                p:SetTitle(title)
            end))
        end
    end
}, 'DSSScrollableMode')
