ShopTab({
    name = "Settings",
    icon = "cog",
    pos = "bottom",
    class = "ShopSettingsMode",
})

vgui.Register('ShopSettingsMode', {
    Init = function(self)
        self:DockPadding(100, 100, 100, 100)

        ui.Panel({
            parent = self
        }, function(p)
            p:SetTall(32)
            p:Dock(TOP)
            p:DockMargin(0, 0, 0, 8)

            ui.DLabel(function(p)
                p:SetWide(100)
                p:Dock(LEFT)
                p:SetText("Theme color")
            end)

            for k, v in pairs(BrandColors) do
                ui.DButton(function(p)
                    p:DockMargin(4, 4, 4, 4)
                    p:SetWide(24)
                    p:Dock(LEFT)
                    p:SetText("")

                    function p:Paint(w, h)
                        surface.SetDrawColor(GetConVar("ps_themecolor"):GetInt() == k and Color(255, 255, 255) or Color(64, 64, 64))
                        surface.DrawRect(2, 2, w - 4, w - 4)
                        surface.SetDrawColor(v)
                        surface.DrawRect(4, 4, w - 8, w - 8)
                    end

                    function p:DoClick()
                        GetConVar("ps_themecolor"):SetInt(k)
                    end
                end)
            end
        end)

        ui.DLabel({
            parent = self
        }, function(p)
            p:SetText("To resize the shop, drag the lower right corner (where the frog is)\n\nIf the shop is haeving prooblems, right click the close button to reset it.")
            p:Dock(TOP)
            p:SizeToContents()
        end)
    end,
    Think = function(self)
        self.Think = nil
    end,
    Paint = function(self) end
}, 'ShopMode')
