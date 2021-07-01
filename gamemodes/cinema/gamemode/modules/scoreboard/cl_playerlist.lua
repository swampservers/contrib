-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
surface.CreateFont("ScoreboardTitle", {
    font = "Righteous",
    size = 52,
    weight = 400
})

surface.CreateFont("ScoreboardTitleSmall", {
    font = "Righteous",
    size = 36,
    weight = 400
})

surface.CreateFont("ScoreboardServerName", {
    font = "Lato-Light",
    size = 22,
    weight = 200
})

surface.CreateFont("ScoreboardName", {
    font = "Lato-Light",
    size = 22,
    weight = 800
})

surface.CreateFont("ScoreboardLocation", {
    font = "Lato",
    size = 16,
    weight = 200
})

surface.CreateFont("ScoreboardPing", {
    font = "Lato",
    size = 18,
    weight = 200
})

afkClockMaterial = Material("icon16/time.png")
showAFKs = false
local PLAYERLIST = {}
PLAYERLIST.TitleHeight = BrandTitleBarHeight
PLAYERLIST.ServerHeight = 32
PLAYERLIST.PlyHeight = 48

concommand.Add("mute", function(ply, cmd, args, argss)
    local v = Ply(argss)

    if v then
        v.ClickMuted = not v.ClickMuted
        print(v.ClickMuted and "Muted" or "Unmuted", v)
        UpdateMutes()
    end
end)

function UpdateMutes()
    for k, v in pairs(player.GetAll()) do
        if v ~= LocalPlayer() then
            v:SetMuted((v.ClickMuted or false) or (v:IsAFK() and MuteVoiceConVar:GetInt() >= 2))
        end
    end
end

timer.Create("updatemutes", 1, 0, UpdateMutes)

function PLAYERLIST:Init()
    if (IsValid(LASTSCOREBOARD)) then
        LASTSCOREBOARD:Remove()
    end

    LASTSCOREBOARD = self
    self.Title = Label("SWAMP CINEMA", self)
    self.Title:SetFont("ScoreboardTitle")
    self.Title:SetColor(Color(255, 255, 255))
    self.ServerName = vgui.Create("ScoreboardServerName", self)
    self.PlayerList = vgui.Create("TheaterList", self)

    self.PlayerList.VBar.btnGrip.OnMousePressed = function(pnl, code)
        if (code == MOUSE_RIGHT) then
            local menu = DermaMenu()
            local lettertab = {}

            --lettertab["!"] = false
            for i = 0, 127 do
                lettertab[string.char(i)] = false
            end

            --lettertab["Bottom"] = false
            for ply, listitem in pairs(self.Players) do
                local start = tostring(string.upper(string.sub(ply:Nick(), 1, 1)))

                if (string.byte(start) < 65) then
                    start = "?"
                end

                if (string.byte(start) > 90) then
                    start = string.char(126)
                end

                if (lettertab[start] == nil or lettertab[start] == false or ply:Nick() < (lettertab[start].Player and IsValid(lettertab[start].Player) and lettertab[start].Player:Nick() or "")) then
                    lettertab[start] = listitem
                end
            end

            for letter, first in SortedPairs(lettertab) do
                if (first ~= false or (string.byte(letter) >= 65 and string.byte(letter) <= 90)) then
                    if (letter == "?") then
                        letter = "Top"
                    end

                    if (letter == "~") then
                        letter = "Bottom"
                    end

                    local opt = menu:AddOption("Jump To: " .. letter, function()
                        if (first ~= false) then
                            self.PlayerList:ScrollToChild(first)
                        end
                    end)

                    if (first == false) then
                        opt:SetEnabled(false)
                    end
                end
            end

            menu:Open()

            return
        end

        self.PlayerList.VBar:Grip(1)
    end

    self.Players = {}
    self.NextUpdate = 0.0
end

function PLAYERLIST:AddPlayer(ply)
    local panel = vgui.Create("ScoreboardPlayer")
    panel:SetParent(self)
    panel:SetPlayer(ply)
    panel:SetVisible(true)
    self.Players[ply] = panel
    self.PlayerList:AddItem(panel)
end

function PLAYERLIST:RemovePlayer(ply)
    if ValidPanel(self.Players[ply]) then
        self.PlayerList:RemoveItem(self.Players[ply])
        self.Players[ply]:Remove()
        self.Players[ply] = nil
    end
end

function PLAYERLIST:Paint(w, h)
    surface.SetDrawColor(BrandColorGrayDarker)
    surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
    local xp, _ = self:GetPos()
    BrandBackgroundPattern(0, 0, self:GetWide(), self.Title:GetTall(), xp)
    BrandDropDownGradient(0, self.Title:GetTall(), self:GetWide())
end

function PLAYERLIST:Think()
    if RealTime() > self.NextUpdate then
        for ply in pairs(self.Players) do
            if not IsValid(ply) then
                self:RemovePlayer(ply)
            end
        end

        for _, ply in pairs(player.GetHumans()) do
            if self.Players[ply] == nil then
                self:AddPlayer(ply)
            end
        end

        self.ServerName:Update()
        self:InvalidateLayout(true)
        self.NextUpdate = RealTime() + 1.0
    end
end

function PLAYERLIST:PerformLayout()
    if RealTime() < self.NextUpdate then return end

    table.sort(self.PlayerList.Items, function(a, b)
        if not a or not a.Player or not IsValid(a.Player) then return false end
        if not b or not b.Player or not IsValid(b.Player) then return true end

        return string.lower(a.Player:Nick()) < string.lower(b.Player:Nick())
    end)

    local curY = PLAYERLIST.TitleHeight + PLAYERLIST.ServerHeight

    for _, panel in pairs(self.PlayerList.Items) do
        panel:InvalidateLayout(true)
        panel:UpdatePlayer()
        panel:SetWide(self:GetWide())
        curY = curY + self.PlyHeight + 2
    end

    self.Title:SizeToContents()
    self.Title:SetTall(PLAYERLIST.TitleHeight)
    self.Title:CenterHorizontal()
    self.ServerName:SizeToContents()
    self.ServerName:AlignTop(PLAYERLIST.TitleHeight)
    self.ServerName:SetWide(self:GetWide())
    self.ServerName:SetTall(PLAYERLIST.ServerHeight)
    self.ServerName:CenterHorizontal()
    self.PlayerList:Dock(FILL)
    self.PlayerList:DockMargin(0, self.TitleHeight + self.ServerHeight, 0, 0)
    self.PlayerList:SizeToContents()
    self:SetTall(math.min(curY, ScrH() * 0.8))
end

vgui.Register("ScoreboardPlayerList", PLAYERLIST)
local PLAYER = {}
PLAYER.Padding = SS_COMMONMARGIN

function PLAYER:Init()
    self:SetTall(PLAYERLIST.PlyHeight)
    self.Name = Label("Unknown", self)
    self.Name:SetFont("ScoreboardName")
    self.Name:SetColor(Color(255, 255, 255, 255))
    self.AvatarButton = vgui.Create("DButton", self)
    self.AvatarButton:SetSize(32, 32)
    self.Avatar = vgui.Create("AvatarImage", self)
    self.Avatar:SetSize(32, 32)
    self.Avatar:SetZPos(1)
    self.Avatar:SetVisible(false)
    self.Avatar:SetMouseInputEnabled(false)
    self.Location = Label("Unknown", self)
    self.Location:SetFont("ScoreboardLocation")
    self.Location:SetColor(Color(255, 255, 255, 80))
    self.Location:SetPos(0, 8)

    self.FriendIcon = vgui("DImage", self, function(p)
        p:SetSize(16, 16)
        p:SetPos(30, 27)
        p:SetZPos(2)
        p:SetImage("chev/icon/friend.png")
    end)

    --holder for all these little buttons so we can dock them away from the edge
    vgui("DPanel", self, function(p)
        p.Paint = noop
        p:SetWide(256)
        p:SetTall(24)
        p:Dock(RIGHT)
        local dockv = (p:GetParent():GetTall() - 24) / 2
        p:DockMargin(0, dockv, SS_COMMONMARGIN, dockv)

        --p.PerformLayout = function(pnl,w,h)
        --p:SizeToChildren(true,false)
        --end
        self.Mute = vgui("DImageButton", function(p)
            p:SetSize(22, 22)
            p:DockMargin(1, 1, 1, 1)
            p:Dock(RIGHT)
            p:SetStretchToFit(true)
            p:SetImage("icon32/unmuted.png")
            p:SetToolTip("Toggle Voice Mute")
        end)

        self.ChatMute = vgui("DImageButton", function(p)
            p:SetSize(22, 22)
            p:DockMargin(1, 1, 1, 1)
            p:Dock(RIGHT)
            p:SetStretchToFit(true)
            p:SetImage("theater/chatunmuted.png")
            p:SetToolTip("Toggle Chat Mute")
        end)

        self.Ping = vgui("ScoreboardPlayerPing", function(p)
            p:Dock(RIGHT)
            p:DockMargin(2, 0, 2, 0)
            p:SetSize(28, 16)
        end)

        self.Country = vgui("DImageButton", function(p)
            p:SetSize(16, 12)
            p:DockMargin(2, 6, 2, 7)
            p:Dock(RIGHT)
            p:SetImage("countries/us.png")
        end)

        if (showAFKs or LocalPlayer():IsStaff()) then
            self.AFK = vgui("DImage", function(p)
                p:SetSize(16, 16)
                p:DockMargin(2, 4, 2, 4)
                p:Dock(RIGHT)
                p:SetImage("icon16/time.png")
                p:SetTooltip("AFK")
                p:CenterVertical()
            end)
        end
    end)
end

local function GetCountryData()
    http.Fetch("https://raw.githubusercontent.com/lukes/ISO-3166-Countries-with-Regional-Codes/master/all/all.json", function(str)
        local tab = util.JSONToTable(str)
        local newtab = {}

        for k, v in pairs(tab) do
            newtab[string.lower(v["alpha-2"])] = v
        end

        CountryData = newtab
    end)
end

GetCountryData()

function PLAYER:UpdatePlayer()
    if not IsValid(self.Player) then
        local parent = self:GetParent()

        if ValidPanel(parent) and parent.RemovePlayer then
            parent:RemovePlayer(self.Player)
        end

        return
    end

    if self.Player.ClickMuted then
        self.Mute:SetImage("icon32/muted.png")
    else
        self.Mute:SetImage("icon32/unmuted.png")
    end

    if self.Player.IsChatMuted then
        self.ChatMute:SetImage("theater/chatmuted.png")
    else
        self.ChatMute:SetImage("theater/chatunmuted.png")
    end

    self.Mute.DoClick = function()
        self.Player.ClickMuted = not (self.Player.ClickMuted or false)
        net.Start("SetMuted")
        net.WriteEntity(self.Player)
        net.WriteBool(self.Player.ClickMuted)
        net.SendToServer()

        if self.Player.ClickMuted then
            self.Mute:SetImage("icon32/muted.png")
        else
            self.Mute:SetImage("icon32/unmuted.png")
        end

        UpdateMutes()
    end

    self.ChatMute.DoClick = function()
        self.Player.IsChatMuted = not self.Player.IsChatMuted
        print("muted" .. self.Player:Nick() .. "'s chat")

        if self.Player.IsChatMuted then
            self.ChatMute:SetImage("theater/chatmuted.png")
        else
            self.ChatMute:SetImage("theater/chatunmuted.png")
        end
    end

    local code = self.Player:GetNetworkedString("cntry")

    if code == "" then
        if self.Country ~= nil and self.Country.Remove ~= nil then
            self.Country:Remove()
        end
    else
        if self.Country ~= nil and self.Country.SetImage ~= nil then
            self.Country:SetImage("countries/" .. string.lower(code) .. ".png")
            local country = CountryData[string.lower(code)]
            self.Country:SetToolTip(country.name .. (country.region and (", " .. country.region) or "") .. "\nClick here to view this country's wikipedia page")
            self.Country.isocode = code

            self.Country.DoClick = function(pnl)
                ShowMotd("https://en.wikipedia.org/wiki/ISO_3166-1:" .. string.upper(pnl.isocode))
            end
            --gui.OpenURL("https://en.wikipedia.org/wiki/ISO_3166-1:"..string.upper(pnl.isocode))
        end
    end

    self.Name:SetText(self.Player.TrueName and self.Player:TrueName() or self.Player:Name())
    self.Location:SetText(string.upper(self.Player:GetLocationName() or "Unknown"))
    self.Ping:Update()
end

function PLAYER:SetPlayer(ply)
    self.Player = ply

    self.AvatarButton.DoClick = function()
        local menu = DermaMenu()

        local prof = menu:AddOption("View Profile", function()
            self.Player:ShowProfile()
        end)

        prof:SetIcon("icon16/user.png")

        local points = menu:AddOption("Give Points", function()
            local gp = vgui.Create('DPointShopGivePoints')
            gp.playerselect:ChooseOption(self.Player:Nick(), self.Player:UniqueID())
            gp.selected_uid = self.Player:UniqueID()
            gp:Update()
        end)

        points:SetIcon("icon16/coins.png")

        local tp = menu:AddOption("Request Teleport To", function()
            RunConsoleCommand("say_team", "/tp " .. self.Player:Nick())
        end)

        tp:SetIcon("icon16/world.png")

        if (LocalPlayer():IsStaff()) then
            local staffsubmenu, staffmenu = menu:AddSubMenu("Copy SteamID", function()
                SetClipboardText(self.Player:SteamID())
            end)

            staffmenu:SetIcon("icon16/user_red.png")

            staffsubmenu:AddOption("SteamID", function()
                SetClipboardText(self.Player:SteamID())
            end)

            staffsubmenu:AddOption("SteamID64", function()
                SetClipboardText(self.Player:SteamID64())
            end)
        end

        menu:Open()
    end

    self.AvatarButton.DoRightClick = self.AvatarButton.DoClick
    self.Avatar:SetPlayer(ply, 64)
    self.Avatar:SetVisible(true)

    if ply:GetFriendStatus() == "friend" then
        self.FriendIcon:Show()
    else
        self.FriendIcon:Hide()
    end

    self.Ping:SetPlayer(ply)
    self:UpdatePlayer()
end

function PLAYER:PerformLayout()
    self.Name:SizeToContents()
    self.Name:AlignTop(self.Padding - 4)
    --if self.Player:GetNWBool("afk") then
    --self.Name:AlignLeft( self.Avatar:GetWide() + 16 + 16 )
    --else
    self.Name:AlignLeft(self.Avatar:GetWide() + 16)
    --end
    self.Location:SizeToContents()
    self.Location:AlignTop(self.Name:GetTall() + 5)
    self.Location:AlignLeft(self.Avatar:GetWide() + 16)
    self.AvatarButton:AlignTop(self.Padding)
    self.AvatarButton:AlignLeft(self.Padding)
    self.AvatarButton:CenterVertical()
    self.Avatar:SizeToContents()
    self.Avatar:AlignTop(self.Padding)
    self.Avatar:AlignLeft(self.Padding)
    self.Avatar:CenterVertical()
end

function PLAYER:Paint(w, h)
    surface.SetDrawColor(BrandColorGrayDark)
    surface.DrawRect(0, 0, self:GetSize())
    surface.SetDrawColor(255, 255, 255, 255)
    local xp = 364

    if (IsValid(self.Player) and IsValid(self.AFK)) then
        self.AFK:SetVisible(self.Player:GetNWBool("afk"))
    else
        self:SetVisible(false)
    end

    if self.Player:IsStaff() then
        --local xp = ({self.Name:GetPos()})[1] + self.Name:GetWide() + 4
        local str = self.Player:GetRankName()
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetFont("DermaDefault")

        xp = xp - ({surface.GetTextSize(str)})[1]

        surface.DrawRect(xp, 17, ({surface.GetTextSize(str)})[1] + 4, 13)

        draw.SimpleText(str, "DermaDefault", xp + 2, 17, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
end

vgui.Register("ScoreboardPlayer", PLAYER)
local PLAYERPING = {}
PLAYERPING.Padding = 0


function PLAYERPING:Init()
    self.Heights = {4, 8, 12}

    self.PingAmounts = {300, 200, 100}

    self.BaseSpacing = 5
end

function PLAYERPING:Update()
    local ping = self.Player:Ping()
    self.PingVal = ping
end

function PLAYERPING:SetPlayer(ply)
    self.Player = ply
    self:Update()
end

function PLAYERPING:Paint(w, h)
    if (not self:IsHovered()) then
        local maxh = self.Heights[#self.Heights]
        local bar = 7
        local total = #self.Heights * bar
        local x = w / 2 - (total / 2)

        for i, height in pairs(self.Heights) do
            if self.PingVal < self.PingAmounts[i] then
                surface.SetDrawColor(255, 255, 255, 255)
            else
                surface.SetDrawColor(255, 255, 255, 10)
            end

            surface.DrawRect(x, (h / 2) - (maxh / 2) + (maxh - height), bar - 2, height)
            x = x + bar
        end

        -- Lit/Main
        x = 0
        surface.SetDrawColor(255, 255, 255, 255)
    else
        surface.SetTextColor(255, 255, 255, 10)
        surface.SetFont("ScoreboardPing")
        local zeros = "000"

        if self.PingVal >= 1 then
            zeros = "00"
        end

        if self.PingVal >= 10 then
            zeros = "0"
        end

        if self.PingVal >= 100 then
            zeros = ""
        end

        local tw, th = surface.GetTextSize(zeros)
        surface.SetTextPos(0, h / 2 - th / 2)
        surface.DrawText(zeros)
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(tw, h / 2 - th / 2)
        surface.DrawText(self.PingVal)
    end
end

vgui.Register("ScoreboardPlayerPing", PLAYERPING)
local SERVERNAME = {}
SERVERNAME.Padding = 8

function SERVERNAME:Init()
    self.Name = Label("Unknown", self)
    self.Name:SetFont("ScoreboardServerName")
    self.Name:SetColor(Color(255, 255, 255))
    self.MapName = Label("Unknown", self)
    self.MapName:SetFont("ScoreboardServerName")
    self.MapName:SetColor(Color(255, 255, 255))
end

function SERVERNAME:Update()
    self.Name:SetText(game.GetMap())
    local players = SV_PLYCOUNT or table.Count(player.GetHumans())
    local ttext = tostring(players) .. " Players Online"

    if players == 1 then
        ttext = "One Player Online"
    end

    local x, y = self:LocalCursorPos()
    local xs, ys = self:GetSize()
    showAFKs = false

    if x > 0 and y > 0 and x < xs and y < ys then
        showAFKs = true
        local count = 0
        local count2 = 0

        for k, v in pairs(player.GetHumans()) do
            if v:GetNWBool("afk") then
                count = count + 1

                if not (v:InTheater()) then
                    count2 = count2 + 1
                end
            end
        end

        ttext = tostring(count) .. " / " .. tostring(players) .. " AFK (" .. tostring(count2) .. " AFK + !InTheater)	"
    end

    self.MapName:SetText(ttext)
    self:PerformLayout()
end

function SERVERNAME:PerformLayout()
    self.Name:SizeToContents()
    self.Name:AlignLeft(self.Padding)
    self.Name:AlignTop(3)
    self.MapName:SizeToContents()
    self.MapName:AlignRight(self.Padding)
    self.MapName:AlignTop(3)
end

vgui.Register("ScoreboardServerName", SERVERNAME)