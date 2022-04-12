SS_Tab({
    name = "GPoser",
    icon = "hand-peace",
    pos = "bottom",
    class = "DSSGPoserMode",
})

vgui.Register('DSSGPoserMode', {
    Init = function(self)
        local mode = self
        self:DockPadding(100, 100, 100, 100)

        -- vgui("Panel", self, function(p)
        --     p:SetTall(32)
        --     p:Dock(TOP)
        --     p:DockMargin(0, 0, 0, 8)
        --     vgui("DLabel", function(p)
        --         p:SetWide(100)
        --         p:Dock(LEFT)
        --         p:SetText("Theme color")
        --     end)
        --     for k, v in pairs(BrandColors) do
        --         vgui("DButton", function(p)
        --             p:DockMargin(4, 4, 4, 4)
        --             p:SetWide(24)
        --             p:Dock(LEFT)
        --             p:SetText("")
        --             function p:Paint(w, h)
        --                 surface.SetDrawColor(GetConVar("ps_themecolor"):GetInt() == k and Color(255, 255, 255) or Color(64, 64, 64))
        --                 surface.DrawRect(2, 2, w - 4, w - 4)
        --                 surface.SetDrawColor(v)
        --                 surface.DrawRect(4, 4, w - 8, w - 8)
        --             end
        --             function p:DoClick()
        --                 GetConVar("ps_themecolor"):SetInt(k)
        --             end
        --         end)
        --     end
        -- end)
        vgui("SLabel", self, function(p)
            p:SetText("GPoser")
            p:SetFont("DermaLarge")
            p:SetContentAlignment(5)
            p:Dock(TOP)
            -- p:SizeToContents()
            p:SetTall(40)
        end)

        vgui("SLabel", self, function(p)
            p:SetText("Control your entire playermodel using just your webcam!")
            p:SetFont(Font.Roboto24)
            p:SetContentAlignment(5)
            p:Dock(TOP)
            -- p:SizeToContents()
            p:SetTall(40)
        end)

        local exists, existstime = false, -100

        vgui("DButton", self, function(p)
            p:SetFont("DermaLarge")
            p:SetContentAlignment(5)
            p:SetTextColor(Color.black)
            p:Dock(TOP)
            p:SetTall(40)

            function p:Think()
                if GPoserVersion then
                    self:SetVisible(false)
                else
                    if mode.FileExists then
                        self:SetText("Start GPoser")

                        function self:DoClick()
                            RunConsoleCommand("gposer")
                        end
                    else
                        self:SetText("Download Now!")

                        function self:DoClick()
                            gui.OpenURL("https://github.com/swampservers/gposer")
                        end
                    end
                end
            end
        end)

        vgui("SLabel", self, function(p)
            p:SetFont(Font.Roboto32)
            p:SetContentAlignment(5)
            p:Dock(TOP)
            p:SetTall(80)

            function p:Think()
                if GPoserVersion then
                    self:SetText("Running GPoser v" .. GPoserVersion .. "\nMay take a few minutes to load")
                else
                    self:SetText("")
                end
            end
        end)

        self.PreviewButton = vgui("DButton", self, function(p)
            p:SetText("Toggle Preview")
            p:SetFont(Font.Roboto28)
            p:SetContentAlignment(5)
            p:SetTextColor(Color.black)
            p:Dock(TOP)
            p:SetTall(32)

            function p:DoClick()
                RunConsoleCommand("gposer", "preview")
            end
        end)
    end,
    Think = function(self)
        if (self.FileExistsTime or -100) > CurTime() - 5 then return end
        self.FileExists = file.Exists("lua/bin/gmcl_gposer_win64.dll", "MOD")
        self.FileExistsTime = CurTime()
        self.PreviewButton:SetVisible(GPoserVersion and true or false)
    end,
    Paint = function(self) end
}, 'DSSMode')
