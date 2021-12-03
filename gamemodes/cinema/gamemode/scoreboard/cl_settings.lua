-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
surface.CreateFont("LabelBigger", {
    font = "Lato-Light",
    size = 24,
    weight = 200
})

surface.CreateFont("LabelSmaller", {
    font = "Lato-Light",
    size = 20,
    weight = 200
})

surface.CreateFont("ScoreboardHelp", {
    font = "Lato-Light",
    size = 18,
    weight = 200
})

SETTINGS = {}
SETTINGS.TitleHeight = BrandTitleBarHeight

function SETTINGS:DoClick()
end

function SETTINGS:Init()
    self.Title = Label(T'Settings_Title', self)
    self.Title:SetFont("ScoreboardTitleSmall")
    self.Title:SetColor(Color(255, 255, 255))
    self.Help = Label(T'Settings_ClickActivate', self)
    self.Help:SetFont("ScoreboardHelp")
    self.Help:SetColor(Color(255, 255, 255, 150))
    self.Settings = {}
    self.TheaterList = vgui.Create("TheaterList", self)
    self:Create()
end

function SETTINGS:NewSetting(control, text, convar)
    local Wrap = vgui.Create("Panel", self)
    local Control = vgui.Create(control, Wrap)
    Control:SetText(text or "")
    Control:Dock(FILL)

    if convar then
        Control:SetConVar(convar)
    end

    Control.Wrap = Wrap

    if not table.HasValue(self.Settings, Control) then
        table.insert(self.Settings, Control)
    end

    return Control
end

function SETTINGS:Paint(w, h)
    surface.SetDrawColor(BrandColorGrayDarker)
    surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
    local xp, _ = self:GetPos()
    BrandBackgroundPattern(0, 0, self:GetWide(), self.TitleHeight, xp)
    BrandDropDownGradient(0, self.TitleHeight, self:GetWide())
end

function SETTINGS:PerformLayout()
    local curY = self.TitleHeight + 6 + 32 + self.TheaterList:GetCanvas():GetTall()

    for _, panel in pairs(self.Settings) do
        panel:InvalidateLayout()
        --curY = curY + panel.Wrap:GetTall()
    end

    self.maxheight = (ScrH() * 0.8)
    self:SetTall(math.min(self.maxheight, curY))
    self.Title:SizeToContents()
    self.Title:SetTall(self.TitleHeight)
    self.Title:CenterHorizontal()
    self.TheaterList:Dock(FILL)
    self.TheaterList:DockMargin(0, BrandTitleBarHeight + 6, 0, 32)
    self.TheaterList:SizeToContents()
    self.Help:SizeToContents()
    self.Help:CenterHorizontal()
    self.Help:AlignBottom(10)
end

function SETTINGS:Create()
    local function addSlider(title, convar, tooltip)
        local Volume = self:NewSetting("TheaterNumSlider", title, convar)
        Volume:SetTooltip(tooltip)
        Volume:SetMinMax(0, 100)
        Volume:SetDecimals(0)
        Volume:SetTall(30)
        Volume.Wrap:DockPadding(8, 0, 16, 0)
        Volume.Wrap:SetTall(Volume:GetTall())
        self.TheaterList:AddItem(Volume.Wrap)
    end

    local function addLabel(label)
        local setting = self:NewSetting("DLabel", label)
        setting:AlignLeft(16)
        --setting:AlignTop( checkboxy + (checkboxs*checkboxn) )
        setting:SetFont("LabelBigger")
        setting:SetColor(color_white)
        setting:SetTall(24)
        setting:SetContentAlignment(5)
        setting.Wrap:DockPadding(16, 0, 16, 0)
        setting.Wrap:SetTall(setting:GetTall())
        self.TheaterList:AddItem(setting.Wrap)
    end

    local function addCheckbox(label, convar, hover)
        local HD = self:NewSetting("TheaterCheckBoxLabel", label, convar)

        if convar:StartWith("radiobutton") then
            HD.RadioButton = true
        end

        HD:SetTooltip(hover)
        HD.Label:SetFont("LabelSmaller")
        HD.Label:SetColor(color_white)
        HD:SetTall(24)
        HD.Wrap:DockPadding(16, 0, 16, 0)
        HD.Wrap:SetTall(HD:GetTall())
        self.TheaterList:AddItem(HD.Wrap)
    end

    local function addDropdown(title, convar, tooltip, selections, labelsize, comboboxsize, basedvalue)
        local Wrap = vgui.Create("Panel", self)
        Wrap:DockPadding(16, 6, 16, 4)
        Wrap:SetTooltip(tooltip)
        Wrap:SetTall(28)
        local label = vgui.Create("DLabel", Wrap)
        label:SetFont("LabelSmaller")
        label:Dock(LEFT)
        label:SetText(title)
        label:SetSize(labelsize or 100, 18)
        label:SetColor(color_white)
        local DComboBox = vgui.Create("DComboBox", Wrap)
        DComboBox:Dock(RIGHT)
        DComboBox:SetSize(comboboxsize or 100, 18)
        DComboBox:SetSortItems(false)

        for i, v in ipairs(selections) do
            DComboBox:AddChoice(v)
        end

        DComboBox:ChooseOptionID(math.Clamp(GetConVar(convar):GetInt() + 1 - (basedvalue or 0), 1, #selections))

        DComboBox.OnSelect = function(self, index, value)
            RunConsoleCommand(convar, tostring((index - 1) + (basedvalue or 0)))
        end

        self.TheaterList:AddItem(Wrap)
    end

    addLabel('Volume')
    addSlider("Video", "cinema_volume", "cinema videos and background music")
    addSlider("Game", "cinema_game_volume", "Gunshots, footsteps etc.\nIf this doesn't work well, try the settings in the escape menu.")
    addSlider("Voice", "cinema_voice_volume", "voice chat")
    addCheckbox('Mute video while alt-tabbed', "cinema_mute_nofocus", 'No background noise')
    addCheckbox('Mute game while alt-tabbed', "snd_mute_losefocus", 'No background noise')
    addCheckbox('Mute game sound in theater', "cinema_mutegame", 'Mute game sound in theater.')

    addDropdown("Voice chat", "cinema_mute_voice", "When should voice chat be heard?", {"Everywhere", "Mute in theaters", "Mute AFK players", "Mute AFK and in theaters", "Mute everyone"}, 80, 120)

    addLabel('Quality')

    addDropdown("Video quality", "cinema_quality", "Video playback quality; affects FPS.\nSettings are 256p/512p/1024p", {"Low (best FPS)", "Medium", "High"})

    addDropdown("Playermodels", "swamp_workshop", "When to download playermodels?", {"Don't Download", "Small (<10mb) only", "Medium (<30mb) only", "All (<60mb) - Short range", "All (<60mb) - Long range"}, 100, 100, -3)

    addCheckbox('Dynamic theater lighting', "cinema_lightfx", 'Exclusive lighting effects (reduces fps)')
    addCheckbox('Turbo button (increase FPS)', "swamp_fps_boost", "Put your gaymergear PC into overdrive")
    addLabel('Display')
    addCheckbox('Show help menu', "swamp_help", 'Show controls on the top of your screen')
    addCheckbox('Hide player names', "cinema_hidenames", "Big names in yo face")
    addCheckbox('Hide sprays', "cl_playerspraydisable", "May help performance (GMOD global)")
    --addCheckbox('Don\'t load chat images',"fedorachat_hideimg","Hides all images in chat")
    addCheckbox('Hide interface', "cinema_hideinterface", "Clean Your Screen")
    addCheckbox('Hide players in theater', "cinema_hideplayers", 'For when trolls stand in front of your screen')
    -- addLabel('Adult content (18+)')
    addCheckbox('Adult videos & sprays (F6)', "swamp_mature_content", 'Show potentially mature videos & sprays')
    -- addCheckbox('Chatbox images (toggle: F7)', "swamp_mature_chatbox", 'Show potentially mature chatbox images')
    local LanguageSelect = self:NewSetting("DButton", "Chat Command List")

    --LanguageSelect:AlignTop( checkboxy + (checkboxs*checkboxn) - 0 )
    LanguageSelect.DoClick = function()
        RunConsoleCommand("say", "/help")
    end

    LanguageSelect.Wrap:DockPadding(32, 4, 32, 4)
    LanguageSelect.Wrap:SetTall(LanguageSelect:GetTall() + 8)
    self.TheaterList:AddItem(LanguageSelect.Wrap)
end

vgui.Register("ScoreboardSettings", SETTINGS)
