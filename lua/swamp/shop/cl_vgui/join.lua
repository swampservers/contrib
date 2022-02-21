-- This file is subject to copyright - contact swampservers@gmail.com for more information.
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
            self.info = vgui("DSSTransitionPanel", function(p)
                p:Dock(FILL)

                -- p:SetMouseInputEnabled(false)
                p:SwapTo(vgui("Panel", function(p)
                    local function button(txt)
                        return vgui("DButton", function(p)
                            p:Dock(FILL)
                            p:SetText(txt)
                            p:SetTextColor(Color.white)
                            p:SetFont(Font.Calibri24_800)
                            p.Hover = 0
                            DSS_Anim(p, "Hover", 10)

                            function p:Paint(w, h)
                                PaintOutlineRect(Color.white, 0, 0, w, h, 3)
                            end
                        end)
                    end

                    vgui("DSSEqualWidthLayout", function(p)
                        p:Dock(TOP)
                        p:DockMargin(0, 70, 0, 0)
                        p:SetTall(52)

                        vgui("Panel", function(p)
                            p:DockPadding(20, 0, 20, 0)
                            local b = button("Join for 20,000 points")

                            function b:DoClick()
                                gui.OpenURL('https://steamcommunity.com/groups/swampservers')
                            end

                            vgui("Panel", function(p)
                                p:SetTall(20)
                                p:Dock(BOTTOM)
                            end)
                        end)

                        vgui("Panel", function(p)
                            p:DockPadding(20, 0, 20, 0)
                            local b = button("Join for 2x income")

                            function b:DoClick()
                                gui.OpenURL('https://swamp.sv/discord')
                            end

                            vgui("DLabel", function(p)
                                p:SetTall(20)
                                p:SetContentAlignment(5)
                                p:Dock(BOTTOM)
                                p:SetText("(Requires joining Steam too)")
                            end)
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

                    vgui("DSSEqualWidthLayout", function(p)
                        p:Dock(BOTTOM)
                        p:SetTall(48)

                        local function text2(txt)
                            vgui("SLabel", function(p)
                                p:SetFont(Font.Calibri24_800)
                                p:SetContentAlignment(5)
                                p:SetText(txt)
                                p:Dock(TOP)
                                p:SetTall(50)
                            end)
                        end

                        vgui("Panel", function(p)
                            text2("Join both the group and chat!")
                        end)

                        vgui("Panel", function(p)
                            text2("Make sure to link your Steam account!")
                        end)
                    end)
                end))
            end)
        end)
    end,
    DoClick = function(self)
        if self.Expansion < 0.5 then
            self.ExpansionAnim:SetTarget(1)
        end
    end,
    ThinkAlways = function(self)
        if not IsValid(SS_ShopMenu) then
            self:Remove()

            return
        end

        if not (Me and Me:GetRank() == 9) then
            self:Remove()

            return
        end

        local e = self.Expansion
        self:SetVisible(SS_ShopMenu:IsVisible())
        self:SetSize(Lerp(e, 400, 700), Lerp(e, 72, 400))
        local x, y = SS_ShopMenu:LocalToScreen(-20, SS_ShopMenu.botbar:GetY() - 70)
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

function ppp(self, w, h)
    local e = self.Expansion
    local l = Lerp(e, (math.sin(SysTime() * 3) + 1) * 0.1, 0)
    -- local c = Color(Lerp(l, 27, 255), Lerp(l, 40, 255), Lerp(l, 56, 255))
    local c = Color(Lerp(l, 40, 255), Lerp(l, 60, 255), Lerp(l, 30, 255))
    surface.SetDrawColor(c)
    draw.NoTexture()
    local x1, y1 = 100, 40

    surface.DrawPoly({
        {
            x = x1,
            y = y1
        },
        {
            x = x1 + 100,
            y = y1
        },
        {
            x = x1 + 50,
            y = y1 + 50
        },
    })

    surface.DrawRect(0, 0, w, h)
    draw.VerticalGradient(Color.black, 0, 0, w, h, e * 0.5, 0)
    surface.SetDrawColor(255, 255, 255, 255)
    local s = 64 --Lerp(e, 64, 80)
    local m = Material["swamp/join/steam_text.png"]
    surface.SetMaterial(m)
    local dw = Lerp(e, s, s * m:Width() / m:Height())
    surface.DrawTexturedRectUV(Lerp(e, 0, w / 4 - dw / 2), 0, dw, s, 0, 0, Lerp(e, m:Height() / m:Width(), 1), 1)
    local m = Material["swamp/join/discord_text.png"]
    surface.SetMaterial(m)
    local dw = Lerp(e, s, s * m:Width() / m:Height())
    surface.DrawTexturedRectUV(Lerp(e, w - dw, w * 3 / 4 - dw / 2), 0, dw, s, 0, 0, Lerp(e, m:Height() / m:Width(), 1), 1)
    local a = e * 2 - 1

    if a > 0 then
        local m = Material["swamp/join/steam_instructions.png"]
        surface.SetMaterial(m)
        surface.SetDrawColor(255, 255, 255, 255 * a)
        surface.DrawTexturedRect(w / 4 - m:Width() / 2, h / 2 - m:Height() / 2, m:Width(), m:Height())
        local m = Material["swamp/join/discord_instructions.png"]
        surface.SetMaterial(m)
        surface.SetDrawColor(255, 255, 255, 255 * a)
        surface.DrawTexturedRect(w * 3 / 4 - m:Width() / 2, h / 2 - m:Height() / 2, m:Width(), m:Height())
    end

    a = -a

    if a > 0 then
        local s = 16
        draw.SimpleText("Join us on Steam & Discord", 'SS_JOINFONT', w / 2, h / 2 - s, Color(255, 255, 255, 255 * s), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("for 2x income & 20,000 points!", 'SS_JOINFONT', w / 2, h / 2 + s, Color(255, 255, 255, 255 * s), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end
