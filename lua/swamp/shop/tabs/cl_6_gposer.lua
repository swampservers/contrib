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
            p:SetFont(Font.sansbold48)
            p:SetContentAlignment(5)
            p:Dock(TOP)
            -- p:SizeToContents()
            p:SetTall(40)
        end)

        vgui("SLabel", self, function(p)
            p:SetText("Control your entire playermodel using just your webcam!")
            p:SetFont(Font.sans24)
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
                if GPoserVersion == "0.2" then
                    self:SetVisible(false)
                else
                    if mode.FileExists then
                        self:SetText("Start GPoser")

                        function self:DoClick()
                            RunConsoleCommand("gposer")
                        end
                    else
                        function self:DoClick()
                            gui.OpenURL("https://github.com/swampservers/gposer")
                        end

                        self:SetText(GPoserVersion and "Please update!" or "Download Now!")
                    end
                end
            end
        end)

        vgui("SLabel", self, function(p)
            p:SetFont(Font.sans28)
            p:SetContentAlignment(5)
            p:Dock(TOP)
            p:SetTall(100)

            function p:Think()
                if GPoserVersion then
                    self:SetText("GPoser v" .. GPoserVersion .. "\n" .. GPoserState .. "\n" .. GPoserInfo)
                else
                    self:SetText("")
                end
            end
        end)

        local pstate = 1
        local qstate = 1
        local estate = -6

        self.b1 = vgui("DButton", self, function(p)
            p:SetText("Toggle Preview")
            p:SetFont(Font.sans24)
            p:SetContentAlignment(5)
            p:SetTextColor(Color.black)
            p:Dock(TOP)
            p:SetTall(32)

            function p:DoClick()
                pstate = 1 - pstate
                RunConsoleCommand("gposer", "preview", tostring(pstate))
            end
        end)

        self.b2 = vgui("DButton", self, function(p)
            p:SetText("Toggle Quality")
            p:SetFont(Font.sans24)
            p:SetContentAlignment(5)
            p:SetTextColor(Color.black)
            p:Dock(TOP)
            p:SetTall(32)

            function p:DoClick()
                qstate = 1 - qstate
                RunConsoleCommand("gposer", "quality", tostring(qstate))
            end
        end)

        self.b3 = vgui("DButton", self, function(p)
            p:SetText("Increase Exposure Time (better in low light)")
            p:SetFont(Font.sans24)
            p:SetContentAlignment(5)
            p:SetTextColor(Color.black)
            p:Dock(TOP)
            p:SetTall(32)

            function p:DoClick()
                estate = math.min(-1, estate + 1)
                RunConsoleCommand("gposer", "exposure", estate)
            end
        end)

        self.b4 = vgui("DButton", self, function(p)
            p:SetText("Decrease Exposure Time (better motion response, less blur)")
            p:SetFont(Font.sans24)
            p:SetContentAlignment(5)
            p:SetTextColor(Color.black)
            p:Dock(TOP)
            p:SetTall(32)

            function p:DoClick()
                estate = math.min(-1, estate - 1)
                RunConsoleCommand("gposer", "exposure", estate)
            end
        end)

        local sstate = true

        self.b5 = vgui("DButton", self, function(p)
            p:SetText("Stop/Start")
            p:SetFont(Font.sans24)
            p:SetContentAlignment(5)
            p:SetTextColor(Color.black)
            p:Dock(TOP)
            p:SetTall(32)

            function p:DoClick()
                sstate = not sstate
                RunConsoleCommand("gposer", sstate and "start" or "stop")
            end
        end)
    end,
    Think = function(self)
        if (self.FileExistsTime or -100) > CurTime() - 5 then return end
        self.FileExists = file.Exists("lua/bin/gmcl_gposer_win64.dll", "MOD")
        self.FileExistsTime = CurTime()

        for x = 1, 5 do
            self["b" .. x]:SetVisible(GPoserVersion and true or false)
        end
    end,
    Paint = function(self) end
}, 'DSSMode')
