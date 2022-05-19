-- This file is subject to copyright - contact swampservers@gmail.com for more information.

vgui.Register("ScoreboardAdmin", {
    TitleHeight = 64,

Init = function(self)
    local Theater = Me:GetTheater()
    self:SetZPos(1)
    self:SetSize(256, 512)
    self:SetPos(ScrW() - (256 + 8), ScrH() / 2 - self:GetTall() / 2)
    self.Title = Label("", self)
    self.Title:SetFont("ScoreboardTitle")
    self.Title:SetColor(Color(255, 255, 255))
    self.NextUpdate = 0.0
    self.Options = vgui.Create("DPanelList", self)
    self.Options:DockMargin(0, self.TitleHeight + 2, 0, 0)
    self.Options:SetDrawBackground(false)
    self.Options:SetPadding(4)
    self.Options:SetSpacing(4)
    -- Skip the current video
    local VoteSkipButton = vgui.Create("TheaterButton")
    VoteSkipButton:SetText('Skip')

    VoteSkipButton.DoClick = function(self)
        RunConsoleCommand("cinema_forceskip")
    end

    self.Options:AddItem(VoteSkipButton)
    -- Seek
    local SeekButton = vgui.Create("TheaterButton")
    SeekButton:SetText('Seek')

    SeekButton.DoClick = function(self)
        Derma_StringRequest('Seek', 'HH:MM:SS or number of seconds (e.g. 1:30:00 or 5400)', "0", function(strTextOut)
            RunConsoleCommand("cinema_seek", strTextOut)
        end, function(strTextOut) end, 'Seek', 'Cancel')
    end

    self.Options:AddItem(SeekButton)

    -- Admin-only options
    if Me:IsAdmin() then
        -- Reset the theater
        local ResetButton = vgui.Create("TheaterButton")
        ResetButton:SetText('Reset')

        ResetButton.DoClick = function(self)
            RunConsoleCommand("cinema_reset")
        end

        self.Options:AddItem(ResetButton)
    end

    -- Private theater options
    if Theater and Theater:IsPrivate() then
        local NameButton = vgui.Create("TheaterButton")
        NameButton:SetText('Change Name')

        NameButton.DoClick = function(self)
            Derma_StringRequest('Change Name', "", Theater:Name(), function(strTextOut)
                RunConsoleCommand("cinema_name", strTextOut)
            end, function(strTextOut) end, 'Set', 'Cancel')
        end

        self.Options:AddItem(NameButton)
        local LockButton = vgui.Create("TheaterButton")
        LockButton:SetText('Toggle Queue Lock')

        LockButton.DoClick = function(self)
            RunConsoleCommand("cinema_lock")
        end

        self.Options:AddItem(LockButton)
        --added
        self.AllowItemUse = vgui.Create("TheaterButton", self)
        self.AllowItemUse:SetText("Allow/Block Vapes")

        self.AllowItemUse.DoClick = function()
            net.Start("ToggleItemsInMyTheater")
            net.SendToServer()
        end

        self.Options:AddItem(self.AllowItemUse)

        if Theater:GetOwner() ~= Me then
            self.AllowItemUse:SetVisible(false)
        end

        self.MuteMode = vgui.Create("TheaterButton", self)
        self.MuteMode:SetText("Toggle Gag Mode")

        self.MuteMode.DoClick = function()
            net.Start("ToggleTheaterMuteMode")
            net.SendToServer()
        end

        self.Options:AddItem(self.MuteMode)

        if Theater:GetOwner() ~= Me then
            self.MuteMode:SetVisible(false)
        end

        self.extendRent = vgui.Create("TheaterButton", self)
        self.extendRent:SetText("Protect Theater")
        self.extendRent:SetFont("Trebuchet24")

        self.extendRent.DoClick = function()
            CreateRentWindow()
        end

        self.Options:AddItem(self.extendRent)

        if Theater:GetOwner() ~= Me then
            self.extendRent:SetVisible(false)
        end
    end
end,

Update = function(self)
    local Theater = Me:GetTheater() -- get player's theater from their location
    if not Theater then return end

    -- Change title text
    if Theater:IsPrivate() and Theater:GetOwner() == Me then
        self.Title:SetText('OWNER')

        if self.extendRent then
            self.extendRent:SetVisible(true)
        end

        if self.AllowItemUse then
            self.AllowItemUse:SetVisible(true)
        end

        if self.MuteMode then
            self.MuteMode:SetVisible(true)
        end
    elseif Me:StaffControlTheater() then
        self.Title:SetText('STAFF CONTROL')

        if self.extendRent then
            self.extendRent:SetVisible(false)
        end

        if self.AllowItemUse then
            self.AllowItemUse:SetVisible(false)
        end

        if self.MuteMode then
            self.MuteMode:SetVisible(false)
        end
    end
end,

Think = function(self)
    if RealTime() > self.NextUpdate then
        self:Update()
        self:InvalidateLayout()
        self.NextUpdate = RealTime() + 3.0
    end
end
,Paint = function(self, w, h)
    -- surface.SetDrawColor(BrandColorGrayDarker)
    -- surface.DrawRect(0, 0, self:GetWide(), self:GetTall())

    SS_BackgroundPattern(self, 0, 0, w, h, false)

    local xp, _ = self:GetPos()
    BrandBackgroundPattern(0, 0, self:GetWide(), self.Title:GetTall(), xp)
    BrandDropDownGradient(0, self.Title:GetTall(), self:GetWide())
end

,PerformLayout = function(self)
    self.Title:SizeToContents()
    self.Title:SetTall(self.TitleHeight)
    self.Title:CenterHorizontal()

    if self.Title:GetWide() > self:GetWide() and self.Title:GetFont() ~= "ScoreboardTitleSmall" then
        self.Title:SetFont("ScoreboardTitleSmall")
    end

    self.Options:Dock(FILL)
    self.Options:SizeToContents()
end

})
