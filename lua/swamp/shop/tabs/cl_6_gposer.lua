-- SS_Tab({
--     name = "GPoser",
--     icon = "hand-peace",
--     pos = "bottom",
--     class = "DSSGPoserMode",
-- })

vgui.Register('DSSGPoserMode', {
    Init = function(self)
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
    end,
    Think = function(self)
        self.Think = nil
    end,
    Paint = function(self) end
}, 'DSSMode')
