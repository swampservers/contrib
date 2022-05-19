-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local cvar = CreateClientConVar("swamp_join_dismiss", "0")

vgui.Register("DSSJoinMenu", {
    Init = function(self)
        if IsValid(SS_JoinMenu) then
            SS_JoinMenu:Remove()
        end

        SS_JoinMenu = self
        self:SetText("")
        self:SetZPos(100)
        self:SetMouseInputEnabled(true)
        self:NoClipping(true)
        self.Expansion = 0
        DSS_Anim(self, "Expansion", 50)
        self:SetVisible(false)

        hook.Add("Think", SS_JoinMenu, function()
            SS_JoinMenu:ThinkAlways()
        end)

        local joinmenu = self

        vgui_parent(self, function(p)
            self.info = vgui("DLabel", function(p)
                p:SetMouseInputEnabled(true)
                p:SetText("")

                function p:DoClick()
                    if not system.HasFocus() then return end
                    local x, y = self:ScreenToLocal(gui.MouseX(), gui.MouseY())
                    local b = x < self:GetWide() / 2 and SS_JoinMenu.button1 or SS_JoinMenu.button2
                    b:DoClick()
                end

                p:Dock(FILL)

                local function button(txt)
                    return vgui("DButton", function(p)
                        p:Dock(FILL)
                        p:SetText(txt)
                        p:SetTextColor(Color.white)
                        p:SetFont(Font.sansbold26)
                        p.Hover = 0
                        DSS_Anim(p, "Hover", 500)

                        function p:Paint(w, h)
                            self.HoverAnim:SetTarget(self:IsHovered() and 1 or 0)
                            surface.SetDrawColor(20, 20, 20)
                            surface.DrawRect(0, 0, w, h)
                            local s = 0 --math.Round((1-p.Hover)*2)

                            for i = 0, 10 do
                                local a = 200 - i * 50 * (2 - self.Hover)
                                if a <= 0 then break end
                                PaintOutlineRect(Color(255, 255, 255, a), s + i, s + i, w - 2 * (s + i), h - 2 * (s + i), 1)
                            end
                        end
                    end)
                end

                vgui("DSSEqualWidthLayout", function(p)
                    p:Dock(TOP)
                    p:DockMargin(0, 96, 0, 0)
                    p:SetTall(32)

                    vgui("Panel", function(p)
                        p:DockPadding(40, 0, 40, 0)
                        local b = button("Join for " .. string.Comma(SS_JOIN_REWARD) .. " points")

                        function b:DoClick()
                            gui.OpenURL('https://steamcommunity.com/groups/swampservers')
                        end

                        SS_JoinMenu.button1 = b
                    end)

                    vgui("Panel", function(p)
                        p:DockPadding(40, 0, 40, 0)
                        local b = button("Join for 2x income")

                        function b:DoClick()
                            gui.OpenURL('https://swamp.sv/discord')
                        end

                        SS_JoinMenu.button2 = b
                    end)
                end)

                vgui("DButton", function(p)
                    p:SetText('r')
                    p:SetColor(Color.white)
                    p:SetSize(40, 40)

                    p.DoClick = function()
                        SS_JoinMenu.ExpansionAnim:SetTarget(0)
                    end

                    p.Paint = noop

                    p.Think = function(self)
                        local font = self:IsHovered() and Font.Marlett40_symbol or Font.Marlett32_symbol

                        if self:GetFont() ~= font then
                            self:SetFont(font)
                        end

                        self:SetPos(self:GetParent():GetWide() - self:GetWide(), 0)
                    end

                    p:Think()
                end)
            end)
        end)
    end,
    DoClick = function(self)
        if self.Expansion < 0.5 then
            if Me.NWP.in_steamgroup and Me.NWP.in_steamchat and Me.NWP.in_discord then
                cvar:SetBool(true)
            else
                self.ExpansionAnim:SetTarget(1)
                cvar:SetBool(false)
            end
        end
    end,
    ThinkAlways = function(self)
        if not IsValid(SS_ShopMenu) then
            self:Remove()

            return
        end

        if Me.NWP.in_steamgroup and Me.NWP.in_steamchat and Me.NWP.in_discord and cvar:GetBool() then
            self:Remove()

            return
        end

        -- if not (Me and Me:GetRank() == 9) then
        --     self:Remove()
        --     return
        -- end
        local e = self.Expansion
        self:SetVisible(SS_ShopMenu:IsVisible())
        self:SetSize(Lerp(e, 450, 750), Lerp(e, 72, 380))
        local x, y = SS_ShopMenu:LocalToScreen(-30, SS_ShopMenu.botbar:GetY() - 80)
        self:SetPos(Lerp(e, x, (ScrW() - self:GetWide()) / 2), Lerp(e, y, (ScrH() - self:GetTall()) / 2))
        local a = math.max(0, 2 * e - 1)
        self.info:SetVisible(a > 0)
        self:SetCursor(a > 0 and "none" or "hand")
        self.info:SetAlpha(a * 255)
    end,
    Paint = function(self, w, h)
        ppp(self, w, h)
    end
}, "DLabel")

local function triangle(grow)
    local x1, y1 = 100, 40

    return {
        {
            x = x1 - grow,
            y = y1
        },
        {
            x = x1 + 100 + grow,
            y = y1
        },
        {
            x = x1 + 50,
            y = y1 + 50 + grow
        },
    }
end

function ppp(self, w, h)
    local nwp = Me and Me.NWP or {}
    local e = self.Expansion
    local l = Lerp(e, Lerp(0.3, (math.sin(SysTime() * 3) + 1) * 0.5, 1), 0)
    -- local c = Color(Lerp(l, 27, 255), Lerp(l, 40, 255), Lerp(l, 56, 255))
    -- local c = Color(Lerp(l, 40, 255), Lerp(l, 60, 255), Lerp(l, 30, 255))
    local linecolor = Color(Lerp(l, 128, 64), Lerp(l, 128, 255), Lerp(l, 128, 64))
    surface.SetDrawColor(linecolor)
    draw.NoTexture()
    surface.DrawPoly(triangle(4))
    surface.DrawRect(-3, -3, w + 6, h + 6)
    local shade = 50
    surface.SetDrawColor(shade, shade, shade, 255)
    surface.DrawPoly(triangle(0))
    surface.DrawRect(0, 0, w, h)
    draw.VerticalGradient(Color.black, 0, 0, w, h, 0.8, 0)
    linecolor.a = 255 * e
    surface.SetDrawColor(linecolor)
    surface.DrawRect(w / 2 - 1, 50, 2, h - 100)
    surface.SetDrawColor(255, 255, 255, 255)
    local s = 64 --Lerp(e, 64, 80)
    local pad = (h - s) / 2
    local m = Material["swamp/join/steam_text.png"]
    surface.SetMaterial(m)
    local dw = Lerp(e, s, s * m:Width() / m:Height())
    surface.DrawTexturedRectUV(Lerp(e, pad, w / 4 - dw / 2), Lerp(e, pad, 16), dw, s, 0, 0, Lerp(e, m:Height() / m:Width(), 1), 1)
    local m = Material["swamp/join/discord_text.png"]
    surface.SetMaterial(m)
    local dw = Lerp(e, s, s * m:Width() / m:Height())
    surface.DrawTexturedRectUV(Lerp(e, w - (dw + pad), w * 3 / 4 - dw / 2), Lerp(e, pad, 16), dw, s, 0, 0, Lerp(e, m:Height() / m:Width(), 1), 1)
    local a = e * 2 - 1

    if a > 0 then
        local c = Color(255, 255, 255, 255 * a)
        surface.SetDrawColor(c)
        self.button1:SetVisible(not (nwp.in_steamgroup and nwp.in_steamchat))
        self.button2:SetVisible(not nwp.in_discord)

        -- "(Requires joining Steam too)"
        if nwp.in_steamgroup and nwp.in_steamchat then
            draw.SimpleText("Steam connected!", Font.sansbold36, w / 4, h / 2, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            local ofs = 0

            if nwp.in_steamgroup or nwp.in_steamchat then
                local white = (math.sin(SysTime() * 3) + 1) * 0.5
                draw.SimpleText("You are only in the " .. (nwp.in_steamgroup and "group" or "chat"), Font.sansbold24, w / 4, h - 20, Color(255, 255 * white, 255 * white, 255 * a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                ofs = -16
            end

            local m = Material["swamp/join/steam_instructions.png"]
            surface.SetMaterial(m)
            surface.DrawTexturedRect(w / 4 - m:Width() / 2, h / 2 - m:Height() / 2 + 40 + ofs, m:Width(), m:Height())
            draw.SimpleText("Join both the group and chat!", Font.sansbold24, w / 4, h - 30 + ofs, Color(255, 255, 255, 255 * a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if nwp.in_discord then
            draw.SimpleText("Discord connected!", Font.sansbold36, w * 3 / 4, h / 2, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText((nwp.in_steamgroup and nwp.in_steamchat) and "2x income unlocked!" or "Join Steam too for 2x income", Font.sansbold24, w * 3 / 4, h / 2 + 50, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            if not (nwp.in_steamgroup and nwp.in_steamchat) then
                draw.SimpleText("(Requires joining Steam too)", "DermaDefault", w * 3 / 4, 140, Color(160, 160, 160, c.a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            local m = Material["swamp/join/discord_instructions.png"]
            surface.SetMaterial(m)
            surface.DrawTexturedRect(w * 3 / 4 - m:Width() / 2, h / 2 - m:Height() / 2 + 40, m:Width(), m:Height())
            draw.SimpleText("Make sure to link your Steam account!", Font.sansbold24, w * 3 / 4, h - 30, Color(255, 255, 255, 255 * a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    a = -a

    if a > 0 then
        local s = 16

        if nwp.in_steamgroup and nwp.in_steamchat and nwp.in_discord then
            draw.SimpleText("2x income unlocked!", Font.Lato32_800, w / 2, h / 2 - s, Color(255, 255, 255, 255 * a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Click to dismiss", Font.Lato24_800, w / 2, h / 2 + s, Color(255, 255, 255, 255 * a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("Join us on Steam & Discord", Font.Lato30_800, w / 2, h / 2 - s, Color(255, 255, 255, 255 * a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("for 2x income & " .. string.Comma(SS_JOIN_REWARD) .. " points!", Font.Lato26_800, w / 2, h / 2 + s, Color(255, 255, 255, 255 * a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end
