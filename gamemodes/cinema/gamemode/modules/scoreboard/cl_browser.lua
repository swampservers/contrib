local PANEL = {}
local CloseTexture = Material("theater/close.png")
CreateClientConVar("linuxinputfix", "1", true, false)

function PANEL:Init()
    self:SetFocusTopLevel(true)
    local w = math.Clamp(ScrW() - 100, 800, 1152)
    local h = ScrH()

    if h > 800 then
        h = h * 3 / 4
    elseif h > 600 then
        h = h * 7 / 8
    end

    self:SetSize(w, h)
    self:Center()
    self:MakePopup()
    self.CloseButton = vgui.Create("DButton", self)
    self.CloseButton:SetZPos(5)
    self.CloseButton:NoClipping(true)
    self.CloseButton:SetText("")

    self.CloseButton.DoClick = function(button)
        self:OnClose()
        self:Remove()
    end

    self.CloseButton.Paint = function(panel, w, h)
        DisableClipping(true)
        surface.SetDrawColor(Color(250, 250, 250, 200))
        surface.DrawRect(2, 2, w - 4, h - 4)
        surface.SetDrawColor(BrandColorGrayDarker)
        surface.SetMaterial(CloseTexture)
        surface.DrawTexturedRect(0, 0, w, h)
        DisableClipping(false)
    end

    self.BrowserContainer = vgui.Create("DPanel", self)
    self.Browser = vgui.Create("TheaterHTML", self.BrowserContainer)

    if (system.IsLinux() and GetConVar("linuxinputfix"):GetInt() == 1) then
        self.PanelInput = vgui.Create("TextEntry", self)
        self.PanelInput:SetText("")
        self.PanelInput:SetVisible(false)

        self.PanelInput.OnEnter = function()
            TextEntryLoseFocus()
        end

        self.Browser:AddFunction("browser", "getinput", function()
            self.PanelInput:RequestFocus()
            self.Browser:RunJavascript("if(document.activeElement.tagName.toLowerCase()=='input')document.activeElement.value='" .. string.JavascriptSafe(self.PanelInput:GetValue()) .. "'")
        end)

        self.Browser.Paint = function(selfb, w, h)
            selfb:SetKeyboardInputEnabled(not self.PanelInput:HasFocus())
            selfb:RunJavascript("if(document.activeElement.tagName.toLowerCase()=='input')browser.getinput()")
        end
    end

    self.Browser.OnDocumentReady = function(panel, url)
        self.AddressBar:SetText(url)

        if IsValid(self.PanelInput) then
            self.PanelInput:SetText("")
        end

        print("DOC",url)
        if self.OnDocumentReady then self:OnDocumentReady(url) end
    end

    -- function self.Browser:OnURLChanged(new, old)
    --     self.OnDocumentReady(self, new)
    -- end

    self.Controls = vgui.Create("Panel", self.BrowserContainer)

    self.Controls.Paint = function(panel, w, h)
        draw.RoundedBoxEx(0, 0, 0, w, h, Color(33, 33, 33, 255), true, true, false, false)
        draw.RoundedBoxEx(0, 0, h - 2, w, 2, Color(128, 128, 128, 255), false, false, false, false)
    end

    local ButtonSize = 32
    local Margins = 2
    local Spacing = 0
    self.BackButton = vgui.Create("DImageButton", self.Controls)
    self.BackButton:SetSize(ButtonSize, ButtonSize)
    self.BackButton:SetMaterial("gui/HTML/back")
    self.BackButton:Dock(LEFT)
    self.BackButton:DockMargin(Spacing * 3, Margins, Spacing, Margins)

    self.BackButton.DoClick = function()
        self.Browser:GoBack()
    end

    self.ForwardButton = vgui.Create("DImageButton", self.Controls)
    self.ForwardButton:SetSize(ButtonSize, ButtonSize)
    self.ForwardButton:SetMaterial("gui/HTML/forward")
    self.ForwardButton:Dock(LEFT)
    self.ForwardButton:DockMargin(Spacing, Margins, Spacing, Margins)

    self.ForwardButton.DoClick = function()
        self.Browser:GoForward()
    end

    self.RefreshButton = vgui.Create("DImageButton", self.Controls)
    self.RefreshButton:SetSize(ButtonSize, ButtonSize)
    self.RefreshButton:SetMaterial("gui/HTML/refresh")
    self.RefreshButton:Dock(LEFT)
    self.RefreshButton:DockMargin(Spacing, Margins, Spacing, Margins)

    self.RefreshButton.DoClick = function()
        self.Browser:Refresh()
    end

    self.HomeButton = vgui.Create("DImageButton", self.Controls)
    self.HomeButton:SetSize(ButtonSize, ButtonSize)
    self.HomeButton:SetMaterial("gui/HTML/home")
    self.HomeButton:Dock(LEFT)
    self.HomeButton:DockMargin(Spacing, Margins, Spacing * 3, Margins)

    self.HomeButton.DoClick = function()
        self.Browser:Stop()
        self.Browser:OpenURL(self.HomeURL or "")
    end

    self.AddressBar = vgui.Create("DTextEntry", self.Controls)
    self.AddressBar:Dock(FILL)
    self.AddressBar:DockMargin(Spacing, Margins * 3, 32 + 10, Margins * 3)

    self.AddressBar.OnEnter = function()
        self.Browser:Stop()
        self.Browser:OpenURL(self.AddressBar:GetValue())
    end

    self.Controls:SetHeight(ButtonSize + Margins * 2)
    self:SetButtonColor(Color(250, 250, 250, 200))
end

function PANEL:SetButtonColor(col)
    self.BackButton:SetColor(col)
    self.ForwardButton:SetColor(col)
    self.RefreshButton:SetColor(col)
    self.HomeButton:SetColor(col)
end

function PANEL:OnClose()
    if ValidPanel(self.Browser) then
        self.Browser:Remove()
    end
end

function PANEL:PerformLayout()
    local w, h = self:GetSize()
    self.CloseButton:SetSize(32, 32)
    self.CloseButton:SetPos(w - 34, 2)
    self.BrowserContainer:Dock(FILL)
    self.Browser:Dock(FILL)
    self.Controls:Dock(TOP)
end

vgui.Register("BrowserBase", PANEL, "EditablePanel")

--keep for dev use
concommand.Add("browser", function()
    local p = vgui.Create("BrowserBase")
end)
