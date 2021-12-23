-- This file is subject to copyright - contact swampservers@gmail.com for more information.
hook.Add("Think", "RequestVideoCloser", function()
    if ValidPanel(RequestPanel) and gui.IsGameUIVisible() then
        gui.HideGameUI()
        RequestPanel:OnClose()
        RequestPanel:Remove()
    end
end)

hook.Add("PostRenderVGUI", "PostDrawHUD_RequestedVideo", function()
    local alp = 1 - ((CurTime() - (LastRequestClickTime or -10)) * 0.7) ^ 4

    if alp > 0 then
        draw.WordBox(4, gui.MouseX() + 20, gui.MouseY(), "Requested!", "Trebuchet24", Color(0, 0, 0, 200 * alp), Color(255, 255, 255, 255 * alp))
        draw.WordBox(4, gui.MouseX() + 24, gui.MouseY() + 30, "Esc to close", "Trebuchet18", Color(0, 0, 0, 200 * alp), Color(255, 255, 255, 255 * alp))
    end
end)

function RequestVideoURL(url)
    -- if ValidPanel(RequestPanel) then
    --     RequestPanel:OnClose()
    --     RequestPanel:Remove()
    -- end
    LastRequestClickTime = CurTime()
    LastURLRequested = url
    --RunConsoleCommand( "cinema_video_request", url )
    net.Start("VideoRequest")
    net.WriteString(url)
    net.SendToServer()
end

local PANEL = {}
PANEL.HistoryWidth = 300

function PANEL:Init()
    RequestPanel = self
    local w = math.Clamp(ScrW() - 100, 800, 1152 + self.HistoryWidth)
    local h = ScrH()

    if h > 800 then
        h = h * 3 / 4
    elseif h > 600 then
        h = h * 7 / 8
    end

    self:SetSize(w, h)
    self.HomeURL = "https://swamp.sv/video/"
    self.Browser:OpenURL(self.HomeURL)
    self.AddressBar:SetText(self.HomeURL)
    self.History = vgui.Create("RequestHistory", self)
    self.History:SetPaintBackgroundEnabled(false)
    self.AddressBar:DockMargin(0, 2 * 3, 0, 2 * 3)

    self.AddressBar.OnChange = function()
        if theater.ExtractURLInfo(self.AddressBar:GetValue()) then
            self.RequestButton:SetDisabled(false)
        else
            self.RequestButton:SetDisabled(true)
        end
    end

    self.RequestButton = vgui.Create("TheaterButton", self.Controls)
    self.RequestButton:SetSize(32 * 8, 32)
    self.RequestButton:SetText('Request URL')
    self.RequestButton:SetTooltip('Press to request a valid video URL.\nThe button will be red when the URL is valid')
    self.RequestButton:SetDisabled(true)
    self.RequestButton:Dock(RIGHT)
    self.RequestButton:DockMargin(8, 4, 8, 4)
    self.RequestButton.BackgroundColor = Color(123, 32, 29)

    self.RequestButton.DoClick = function()
        RequestVideoURL(self.AddressBar:GetValue())
    end

    self.HomeButton.DoRightClick = function()
        local menu = DermaMenu()

        menu:AddOption("Advanced User Mode", function()
            if not RequestPanel.f then
                CinemaResourceMonitor(RequestPanel)
            end
        end)

        menu:Open()
    end

    local function updateAddressBar(url)
        self.AddressBar:SetText(url)

        if IsValid(self.PanelInput) then
            self.PanelInput:SetText("")
        end

        if theater.ExtractURLInfo(url) then
            self.RequestButton:SetDisabled(false)
        else
            self.RequestButton:SetDisabled(true)
        end
    end

    self.Browser:AddFunction("gmod", "detect", function(url)
        updateAddressBar(url)
    end)

    self.Browser.OnDocumentReady = function(panel, url)
        updateAddressBar(url)
        self.Browser:RunJavascript("if(window.location.host!='lookmovie.io')if(window.movie_storage){gmod.detect('https://lookmovie.io/movies/view/'+window.__reportSlug)}else if(window.show_storage){gmod.detect('https://lookmovie.io/shows/view/'+window.__reportSlug+window.location.hash)}")
    end
end

function PANEL:PerformLayout()
    local w, h = self:GetSize()
    self.CloseButton:SetSize(32, 32)
    self.CloseButton:SetPos(w - 34, 2)
    self.BrowserContainer:Dock(FILL)
    self.Browser:Dock(FILL)
    self.History:Dock(RIGHT)
    self.History:SetWide(self.HistoryWidth)
    self.Controls:Dock(TOP)
end

function PANEL:CheckClose()
    local x, y = self:CursorPos()

    -- Remove panel if mouse is clicked outside of itself
    if not (gui.IsGameUIVisible() or gui.IsConsoleVisible()) and (x < 0 or x > self:GetWide() or y < 0 or y > self:GetTall()) then
        self:OnClose()
        self:Remove()
    end
end

vgui.Register("VideoRequestFrame", PANEL, "BrowserBase")
local HISTORY = {}
HISTORY.TitleHeight = 64
HISTORY.VidHeight = 32 -- 48

function HISTORY:Init()
    self:SetSize(256, 512)
    self:SetPos(8, ScrH() / 2 - (self:GetTall() / 2))
    self.Title = Label("HISTORY", self)
    self.Title:SetFont("ScoreboardTitle")
    self.Title:SetColor(Color(255, 255, 255))
    self.Title:SetContentAlignment(5)
    self.SearchZone = vgui.Create("DPanel", self)
    self.SearchZone:DockMargin(4, 4, 4, 4)
    self.SearchZone:SetPaintBackground(false)
    self.SearchText = Label("Filter: ", self.SearchZone)
    self.SearchText:SetColor(Color(255, 255, 255))
    self.SearchBar = vgui.Create("DTextEntry", self.SearchZone)
    self.SearchBar:SetUpdateOnType(true)

    self.SearchBar.OnValueChange = function(te, filter)
        self:Search(filter)
    end

    self.Videos = {}
    self.VideoList = vgui.Create("TheaterList", self)
    self.VideoList:DockMargin(0, 2, 0, 0)
    self.Options = vgui.Create("DPanelList", self)
    self.Options:SetDrawBackground(false)
    self.Options:SetPadding(4)
    self.Options:SetSpacing(4)
    local ClearButton = vgui.Create("TheaterButton")
    ClearButton:SetText('Clear')

    ClearButton.DoClick = function()
        Derma_Query("Are you sure you want to clear your video history?", "", "Yes", function()
            theater.ClearRequestHistory()
            self.VideoList:Clear(true)
        end, "No", function() end)
    end

    self.Options:AddItem(ClearButton)
    self:Search()
end

function HISTORY:Search(filter)
    self.Videos = {}
    self.VideoList:Clear(true)

    for _, request in pairs(theater.GetRequestHistory(filter)) do
        self:AddVideo(request)
    end

    self.VideoList:SortVideos(function(a, b) return a.lastRequest > b.lastRequest end)
end

function HISTORY:AddVideo(vid)
    if self.Videos[vid.id] then
        self.Videos[vid.id]:SetVideo(vid)
    else
        local panel = vgui.Create("RequestVideo", self)
        panel:SetVideo(vid)
        panel:SetVisible(true)
        self.Videos[vid.id] = panel
        self.VideoList:AddItem(panel)
    end
end

function HISTORY:RemoveVideo(vid)
    if ValidPanel(self.Videos[vid.id]) then
        self.VideoList:RemoveItem(self.Videos[vid.Id])
        self.Videos[vid.id]:Remove()
        self.Videos[vid.id] = nil
    end
end

function HISTORY:Paint(w, h)
    surface.SetDrawColor(BrandColorGrayDarker)
    surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
    local xp, _ = self:GetPos()
    BrandBackgroundPattern(0, 0, self:GetWide(), self.TitleHeight, xp)
    BrandDropDownGradient(0, self.TitleHeight, self:GetWide())
end

function HISTORY:PerformLayout()
    self.Title:SetTall(self.TitleHeight)
    self.Title:Dock(TOP)
    self.SearchZone:SetTall(20)
    self.SearchZone:Dock(TOP)
    self.SearchText:SizeToContents()
    self.SearchText:Dock(LEFT)
    self.SearchBar:Dock(FILL)
    self.VideoList:Dock(FILL)
    self.Options:Dock(BOTTOM)
    self.Options:SizeToContents()
end

vgui.Register("RequestHistory", HISTORY)
local VIDEO = {}
VIDEO.Padding = 8

function VIDEO:Init()
    self:SetTall(HISTORY.VidHeight)
    self.Title = Label("Unknown", self)
    self.Title:SetFont("ScoreboardVidTitle")
    self.Title:SetColor(Color(255, 255, 255))
    self.Duration = Label("0:00", self)
    self.Duration:SetFont("ScoreboardVidDuration")
    self.Duration:SetColor(Color(255, 255, 255))
    self.Requests = Label("1 request(s)", self)
    self.Requests:SetFont("ScoreboardVidDuration")
    self.Requests:SetColor(Color(255, 255, 255))
    self.RequestVideo = vgui.Create("DImageButton", self)
    self.RequestVideo:SetSize(16, 16)
    self.RequestVideo:SetImage("theater/play.png")
    self.RequestVideo:SetTooltip('Request Video')

    self.RequestVideo.DoClick = function()
        RequestVideoURL(self.Video.url)
    end

    self.RequestVideo.Think = function()
        if IsMouseOver(self.RequestVideo) then
            self.RequestVideo:SetAlpha(255)
        else
            self.RequestVideo:SetAlpha(25)
        end
    end

    self.DeleteVideo = vgui.Create("DImageButton", self)
    self.DeleteVideo:SetSize(16, 16)
    self.DeleteVideo:SetImage("theater/trashbin.png")
    self.DeleteVideo:SetTooltip('Remove video from history')

    self.DeleteVideo.DoClick = function()
        theater.RemoveRequestById(self.Video.id)

        -- Lovely DPanelList
        pcall(function(v)
            self:GetParent():GetParent():GetParent():RemoveVideo(v)
        end, self.Video)
    end

    self.DeleteVideo.Think = function()
        if IsMouseOver(self.DeleteVideo) then
            self.DeleteVideo:SetAlpha(255)
        else
            self.DeleteVideo:SetAlpha(25)
        end
    end
end

function VIDEO:SetVideo(vid)
    self.Video = vid
    self:SetTooltip(self.Video.title)
    self.Title:SetText(self.Video.title)

    if tonumber(self.Video.duration) > 0 then
        self.Duration:SetText(string.format("%s | %s", self.Video.type, string.FormatSeconds(self.Video.duration)))
    else
        self.Duration:SetText(string.format("%s | %s", self.Video.type, "live"))
    end

    self.Requests:SetText(string.format("%d request(s)", self.Video.count))
end

function VIDEO:PerformLayout()
    self.Title:SizeToContents()
    local w = math.Clamp(self.Title:GetWide(), 0, 224)
    self.Title:SetSize(w, self.Title:GetTall())
    self.Title:AlignTop(-2)
    self.Title:AlignLeft(self.Padding)
    self.Duration:SizeToContents()
    self.Duration:AlignTop(self.Title:GetTall() - 4)
    self.Duration:AlignLeft(self.Padding)
    self.Requests:SizeToContents()
    self.Requests:SetContentAlignment(6)
    self.Requests:AlignTop(self.Title:GetTall() - 4)
    self.Requests:AlignRight(64)
    self.RequestVideo:Center()
    self.RequestVideo:AlignRight(36)
    self.DeleteVideo:Center()
    self.DeleteVideo:AlignRight(10)
end

function VIDEO:Paint(w, h)
    surface.SetDrawColor(BrandColorGrayDark)
    surface.DrawRect(0, 0, self:GetSize())
end

function VIDEO:OnMousePressed(key)
    if key == MOUSE_RIGHT then
        local menu = DermaMenu()

        menu:AddOption("Copy Link", function()
            SetClipboardText(self.Video.url)
        end)

        menu:Open()
    end
end

vgui.Register("RequestVideo", VIDEO)
