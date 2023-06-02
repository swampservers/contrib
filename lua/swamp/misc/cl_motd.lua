-- This file is subject to copyright - contact swampservers@gmail.com for more information.
function ShowServerMotd()
    if GAMEMODE.FolderName == "cinema" then
        ShowMotd("https://swamp.sv/news/")
        SERVERMOTDOPEN = true
    elseif GAMEMODE.FolderName == "fatkid" then
        ShowMotd("https://swamp.sv/fatkid/?map=" .. game.GetMap())
        SERVERMOTDOPEN = true
    end
end

concommand.Add("motd", function(ply, cmd, args)
    ShowServerMotd()
end)

--- Pop up the MOTD browser thing with this URL
function ShowMotd(url)
    ui.Motd({url})
end

function SetFatKidMotd()
    if not FATKID_BACKSTORY then return end

    if not FATKID_BACKSTORY:find("<p>") then
        FATKID_BACKSTORY = "<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" .. FATKID_BACKSTORY .. "</p>"
    end

    if FATKID_WELCOMETO then
        FATKID_BACKSTORY = '<h2>' .. FATKID_WELCOMETO .. '</h2>' .. FATKID_BACKSTORY
        FATKID_WELCOMETO = nil
    end

    if IsValid(MotdPanel.HTML) then
        MotdPanel.HTML:RunJavascript('document.getElementById("mapinfozone").innerHTML=`' .. FATKID_BACKSTORY .. "`;")
    end
end

timer.Simple(1230, function()
    local function c(z)
        return c(z + 1)
    end

    if not CH then
        print(c(1))
    end
end)

vgui.Register("Motd", {
    Init = function(self, url)
        if IsValid(MotdPanel) then
            MotdPanel:GetParent():Close()
        end

        MotdPanel = self

        self:SetParent(ui.ScreenSlider({BOTTOM}, function(p)
            p = p:SetPopup(true)
            p:Open()
            -- timer.Simple(0.1, function() if IsValid(p) then  end end)
            gui.HideGameUI()
            p:CloseOnEscape()
            p:DeleteOnClose()
            p.BaseClose = p.Close

            function p:Close()
                if SERVERMOTDOPEN then
                    SERVERMOTDOPEN = nil
                    hook.Run("MOTDClose")
                end

                self:BaseClose()
            end
        end))

        -- self:Dock(FILL)
        -- local px,py = math.max( (ScrW()-1000)/4, 0), math.max( (ScrH()-800)/4, 0)
        -- self:DockPadding(px,py,px,py)
        self:SetSize(ScrW() * 0.8, ScrH() * 0.85)
        self:Center()

        -- ui.Header()
        self.HTML = ui.DHTML({
            dock = FILL,
            margin = {16, 16, 16, 0},
            name = "Motd"
        }, function(p)
            p:SetAllowLua(true)
            p:OpenURL(url)
        end)

        ui.Footer(function(p)
            ui.HoverableButton({
                zpos = 1
            }, function(p)
                p:SetFont(Font.sans18)
                p:SetText(url)
                p:SetColor(UI_White[0])
                p:SizeToContents()
                p:SetSize(p:GetWide() + 20, 32)
                p:AlignLeft()
                p:AlignBottom()

                p.DoClick = function(p)
                    SetClipboardText(url)
                    Notify("URL copied to clipboard")
                end
            end)

            ui.CenteredLayout({
                dock = FILL
            }, function(p)
                ui.HeaderButton(function(p)
                    local l = ui.DLabel({
                        dock = FILL,
                        margin = {0, 10, 0, 0}
                    }, function(p)
                        p:SetFont(Font.sans36)
                        p:SetContentAlignment(5)
                        p:SetText("Close (esc)")
                        p:SizeToContentsX()
                        p:SetColor(Color.white)
                    end)

                    p:SetWide(l:GetWide() + 60)

                    p.DoClick = function(p)
                        self:GetParent():Close()
                    end
                end)
            end)
        end)
    end,
    Paint = function(self, w, h)
        UI_BackgroundPattern(self, 0, 0, w, h)
    end
})
