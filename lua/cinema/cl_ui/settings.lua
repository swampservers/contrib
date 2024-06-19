-- This file is subject to copyright - contact swampservers@gmail.com for more information.
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

vgui.Register("ScoreboardSettings", {
    Init = function(self)
        self.Canvas:DockPadding(0, 2, 0, 6)

        local function addSlider(title, convar, tooltip)
            local Volume = ui.TheaterNumSlider({
                text = title
            })

            Volume:SetConVar(convar)
            Volume:SetTooltip(tooltip)
            Volume:SetMinMax(0, 100)
            Volume:SetDecimals(0)
            Volume:SetTall(30)
            Volume:DockMargin(8, 0, 16, 0)
            -- Volume.Wrap:SetTall(Volume:GetTall())
        end

        local function addLabel(label)
            local setting = ui.DLabel({
                text = label
            })

            setting:AlignLeft(16)
            --setting:AlignTop( checkboxy + (checkboxs*checkboxn) )
            setting:SetFont(Font.sans24)
            setting:SetColor(color_white)
            setting:SetTall(24)
            setting:SetContentAlignment(5)
            setting:DockMargin(16, 8, 16, 4)
            -- setting.Wrap:SetTall(setting:GetTall())
        end

        local function addCheckbox(label, convar, hover)
            local HD = ui.TheaterCheckBoxLabel({
                text = label
            })

            HD:SetConVar(convar)

            if convar:StartWith("radiobutton") then
                HD.RadioButton = true
            end

            HD:SetTooltip(hover)
            HD.Label:SetFont(Font.sans20)
            HD.Label:SetColor(color_white)
            HD:SetTall(24)
            HD:DockMargin(16, 4, 16, 4)
        end

        local function addDropdown(title, convar, tooltip, selections, labelsize, comboboxsize, basedvalue)
            local Wrap = vgui.Create("Panel", self)
            Wrap:DockPadding(16, 6, 16, 4)
            Wrap:SetTooltip(tooltip)
            Wrap:SetTall(28)
            local label = vgui.Create("DLabel", Wrap)
            label:SetFont(Font.sans20)
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
        end

        addLabel('Volume')
        addSlider("Video", "cinema_volume", "Cinema videos and background music")
        addSlider("Game", "cinema_game_volume", "Gunshots, footsteps etc.\nIf this doesn't work well, try the settings in the escape menu.")
        addSlider("Voice", "cinema_voice_volume", "voice chat")
        addSlider("Loading", "swamp_loading_volume", "Loading screen volume")
        addCheckbox('Mute video while alt-tabbed', "cinema_mute_nofocus", 'No background noise')
        addCheckbox('Mute game while alt-tabbed', "snd_mute_losefocus", 'No background noise')
        addCheckbox('Mute game sound in theater', "cinema_mutegame", 'Mute game sound in theater.')

        addDropdown("Voice chat", "cinema_mute_voice", "When should voice chat be heard?", {"Everywhere", "Mute in theaters", "Mute AFK players", "Mute AFK and in theaters", "Mute everyone"}, 80, 120)

        addLabel('Quality')

        addDropdown("Video quality", "cinema_quality", "Video playback quality; affects FPS.\nSettings are 256p/512p/1024p", {"Low (best FPS)", "Medium", "High"})

        addDropdown("Playermodels", "swamp_workshop", "When to download playermodels?", {"Don't Download", "Small (≤10mb) only", "Medium (≤30mb) only", "All (≤60mb) - Short range", "All (≤60mb) - Long range"}, 100, 100, -3)

        addCheckbox('Dynamic theater lighting', "cinema_dynamic_light", 'Exclusive lighting effects (reduces fps)')
        addCheckbox('Turbo button (increase FPS)', "swamp_fps_boost", "Put your gaymergear PC into overdrive")
        addLabel('Display')
        addCheckbox('Show help menu', "swamp_help", 'Show controls on the top of your screen')
        addCheckbox('Hide player names', "cinema_hidenames", "Big names in yo face")
        addCheckbox('Hide sprays', "spraymesh_disable", "May help performance")
        --addCheckbox('Don\'t load chat images',"fedorachat_hideimg","Hides all images in chat")
        addCheckbox('Hide interface', "cinema_hideinterface", "Clean Your Screen")
        addCheckbox('Hide players in theater', "cinema_hideplayers", 'For when trolls stand in front of your screen')
        -- addLabel('Adult content (18+)')
        addCheckbox('Adult videos & sprays (F6)', "swamp_mature_content", 'Show potentially mature videos & sprays')

        -- addCheckbox('Chatbox images (toggle: F7)', "swamp_mature_chatbox", 'Show potentially mature chatbox images')
        ui.DButton({
            margin = {32, 4, 32, 4},
            text = "Chat Command List",
            DoClick = function()
                RunConsoleCommand("say", "/help")
            end
        })

        ui.DLabel({
            text = 'Click to activate your mouse',
            font = Font.sans20,
            alignment = 5,
            color = Color(255, 255, 255, 150)
        })
    end,
    PerformLayout = function(self, ...)
        self:SetTall(math.min(self.Canvas:GetTall(), self:GetParent():GetTall()))
        self.BaseClass.PerformLayout(self, ...)
    end,
    Paint = function(self, w, h)
        UI_BackgroundPattern(self, 0, 0, w, h)
    end
}, "List")
