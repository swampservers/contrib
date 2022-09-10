-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SS_Tab({
    name = "Customizer",
    class = "DSSCustomizerMode"
})

vgui.Register('DSSEqualWidthLayout', {
    PerformLayout = function(self, w, h)
        local c = self:GetChildren()
        local cw = w / #c

        for i, v in ipairs(c) do
            local x = math.floor(cw * (i - 1))
            v:SetPos(x, 0)
            v:SetSize(math.floor(cw * i) - x, h)
        end
    end
}, "Panel")

vgui.Register('DSSCustomizerMode', {
    OpensOver = true,
    Title = "Customizer",
    TitleNote = "WARNING: Pornographic images or builds are not allowed!",
    Init = function(self)
        SS_CustomizerPanel = self
    end,
    DrawOverPreview = function(self, preview)
        local y = 14

        if IsValid(self.Angle) then
            draw.SimpleText("RMB + drag to rotate", Font.sans24, preview:GetWide() / 2, y, SWhite[0], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            y = y + 32
        end

        if IsValid(self.Position) then
            draw.SimpleText("MMB + drag to move", Font.sans24, preview:GetWide() / 2, y, SWhite[0], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end,
    OpenItem = function(self, item)
        self:Clear()
        self:Open()

        SS_PreviewPanel.ents.player:SwitchSequence({"reference", "menu_combine", "ragdoll"})

        self.item = item
        item.applied_cfg = table.Copy(item.cfg)
        self.wear = Me:IsPony() and "wear_p" or "wear_h"
        self:SetVisible(true)

        --bottom panel
        vgui("DSSEqualWidthLayout", self, function(p)
            p:SetTall(64)
            p:Dock(BOTTOM)

            vgui("DSSEqualWidthLayout", function(p)
                vgui("DSSButton", function(p)
                    p:SetText("Reset")
                    p:SetFont("SS_DESCTITLEFONT")

                    p.DoClick = function(butn)
                        self.item.cfg = {}
                        self:Update()
                        self:SetupControls()
                    end
                end)

                vgui("DSSButton", function(p)
                    p:SetText("Cancel")
                    p:SetFont("SS_DESCTITLEFONT")

                    p.DoClick = function(butn)
                        self.item.cfg = self.item.applied_cfg
                        self:Close()
                        SS_PreviewPanel.ents.player:SwitchSequence()
                    end
                end)
            end)

            vgui("DSSButton", function(p)
                p:SetFont("SS_DESCTITLEFONT")
                p:SetText("Done")

                p.DoClick = function(butn)
                    local callback = function()
                        self:Close()

                        SS_PreviewPanel.ents.player:TimerSimple(0.4, function(e)
                            e:SwitchSequence({
                                ({"pose_standing_01", "pose_standing_04", "pose_standing_04", "zombie_attack_07_original"})[math.ceil(math.random() * 3.2)],
                                "cidle_me1"
                            })
                        end)

                        SS_PreviewPanel.ents.player:TimerSimple(1.6, function(e)
                            e:SwitchSequence()
                        end)
                    end

                    self.item:FinishCustomizer(callback)
                end
            end)
        end)

        -- p:InvalidateLayout()
        vgui("Panel", self, function(p)
            p:SetZPos(1)
            p:Dock(BOTTOM)
            p:SetTall(DSS_DIVIDERSIZE)

            function p:Paint()
                DSS_DrawDivider(self, false)
            end
        end)

        self.controlzone = vgui("DSSEqualWidthLayout", self, function(p)
            p:Dock(FILL)
        end)

        self:SetupControls()
    end,
    SetupControls = function(self)
        self.controlzone:Clear()

        self.LeftColumn = vgui("DSSScrollPanel", self.controlzone, function(p)
            p:Dock(LEFT)
        end)

        self.RightColumn = vgui("DSSScrollPanel", self.controlzone, function(p)
            p:Dock(FILL)
        end)

        if self.item.SetupCustomizer then
            self.item:SetupCustomizer(self)
        end

        local pone = Me:IsPony()
        local suffix = pone and "_p" or "_h"
        local settings = self.item.settings

        if settings.color then
            vgui("DSSCustomizerColor", self.RightColumn, function(p)
                p:SetValue(self.item.cfg.color or self.item.color or Vector(1, 1, 1))

                p.OnValueChanged = function(pnl, vec)
                    self.item.cfg.color = vec
                    self:Update()
                end
            end)
        end

        if settings.imgur then
            vgui("DSSCustomizerImgur", self.RightColumn, function(p)
                p:SetValue(self.item.cfg.imgur)

                p.OnValueChanged = function(pnl, imgur)
                    self.item.cfg.imgur = imgur
                    self:Update()
                end
            end)
        end

        local rawdata = vgui("DSSCustomizerSection", self.RightColumn, function(p)
            p:SetVisible(false)
            p:SetText("Raw Data")

            self.RawEntry = vgui("DTextEntry", function(p)
                p:SetMultiline(true)
                p:SetTall(256)
                p:Dock(TOP)
                p:SetEditable(true)
                p:SetKeyboardInputEnabled(true)

                p.OnValueChange = function(textself, new)
                    textself:InvalidateLayout(true)

                    if not textself.RECIEVE then
                        self.item.cfg = util.JSONToTable(new) or {}
                        self:Update(true) -- TODO: sanitize input like on the server
                    end
                end

                p:SetUpdateOnType(true)
            end)
        end)

        vgui("DSSButton", self.RightColumn, function(p)
            p:SetText("Show Raw Data")
            p:SetTall(32)

            function p:DoClick()
                rawdata:SetVisible(true)
                self:Remove()
            end
        end)

        self:Update()
    end,
    Update = function(self, skiptext)
        self.item:Update()

        if IsValid(self.RawEntry) and not skiptext then
            self.RawEntry.RECIEVE = true
            self.RawEntry:SetValue(util.TableToJSON(self.item.cfg, true))
            self.RawEntry.RECIEVE = nil
        end
    end
}, 'DSSMode')

-- TODO we need a way to get the accessory ent
function ImageGetterPanel()
    local mat = IsValid(SS_PreviewPanel.ents.item) and SS_PreviewPanel.ents.item:GetMaterials()[1] or (IsValid(SS_PreviewPanel.accessoryitement) and SS_PreviewPanel.accessoryitement:GetMaterials()[1] or SS_PreviewPanel.ents.player:GetMaterials()[(SS_CustomizerPanel.item.cfg.submaterial or 0) + 1])
    assert(mat)
    local mat_inst = Material(mat)
    local dispmax = 512
    local tw, th = mat_inst:Width(), mat_inst:Height()
    local big = math.max(tw, th)
    tw = tw / big * dispmax
    th = th / big * dispmax

    vgui("DFrame", function(p)
        local frame = p
        p:SetSize(tw + 10, th + 30 + 24)
        -- p:DockPadding(SS_COMMONMARGIN, SS_COMMONMARGIN + 24, SS_COMMONMARGIN, SS_COMMONMARGIN)
        p:Center()
        p:SetTitle(mat)
        p:MakePopup()
        p.btnMaxim:SetVisible(false)
        p.btnMinim:SetVisible(false)

        -- p.BasedPaint = DFrame.Paint
        p.Paint = function(pnl, w, h)
            DisableClipping(true)
            local border = 8
            draw.BoxShadow(-2, -2, w + 4, h + 4, border, 1)
            DisableClipping(false)
            SS_PaintBG(pnl, w, h)
            BrandBackgroundPattern(0, 0, w, 24, 0)
        end

        vgui("DSSButton", function(p)
            p:SetPos(128, 0)
            p:Dock(BOTTOM)
            -- p:DockMargin(0, SS_COMMONMARGIN, 0, 0)
            p:SetText("Download Image")
            -- p.Paint = SS_PaintButtonBrandHL
            p:SetTextColor(MenuTheme_TX)

            p.DoClick = function()
                local imat = Material(mat)

                hook.Add("PostRender", "SS_TexDownload", function()
                    hook.Remove("PostRender", "SS_TexDownload")

                    local matcopy = CreateMaterial(imat:GetName() .. "copy", "UnlitGeneric", {
                        ["$basetexture"] = imat:GetString("$basetexture")
                    })

                    local RT = GetRenderTarget(imat:GetName() .. "download", imat:Width(), imat:Height())
                    render.PushRenderTarget(RT)
                    cam.Start2D()
                    render.Clear(0, 0, 0, 0, true, true)
                    render.SetMaterial(matcopy)
                    render.DrawScreenQuad()
                    cam.End2D()
                    render.SetWriteDepthToDestAlpha(false)

                    local data = render.Capture({
                        format = "png",
                        x = 0,
                        y = 0,
                        alpha = false,
                        w = ScrW(),
                        h = ScrH()
                    })

                    render.SetWriteDepthToDestAlpha(true)
                    render.PopRenderTarget()
                    local parts = string.Explode("/", imat:GetName() or "")
                    local imagename = parts[#parts] or "temp_image"
                    local fname = imagename .. ".png"
                    file.Write(fname, data)

                    if IsValid(frame) then
                        frame:SetTitle("Downloaded! Look for file: garrysmod/data/" .. fname)
                    end
                end)
            end
        end)

        vgui("DImage", function(p)
            p:Dock(FILL)
            p:SetImage(mat)
            p:GetMaterial():SetInt("$flags", 0)
            local paint = p.Paint

            function p:Paint(w, h)
                cam.IgnoreZ(true)
                paint(self, w, h)
                cam.IgnoreZ(false)
            end
        end)
    end)
end
-- if settings.bone then
--     --bunch of copied shit
--     local function transformslidersupdate()
--         if settings.scale then
--             self.item.cfg["scale" .. suffix] = self.Scale:GetValue()
--         end
--         if settings.pos then
--             self.item.cfg["pos" .. suffix] = self.Position:GetValue()
--         end
--         self:Update()
--     end
--     local itmcp = settings.pos
--     if itmcp then
--         self.Position = vgui('DSSCustomizerVectorSection', self.LeftColumn, function(p)
--             p:SetForPosition(itmcp.min, itmcp.max, self.item.cfg["pos" .. suffix] or Vector(0,0,0))
--             p.OnValueChanged = transformslidersupdate
--         end)
--     end
--     -- local itmca = settings.ang
--     -- if itmca then
--     --     self.Scale = vgui('DSSCustomizerVectorSection', self.LeftColumn, function(p)
--     --         p:SetForAngle(itmcs.min, itmcs.scale.max, self.item.cfg["scale" .. suffix] or Vector(1,1,1))
--     --         p.OnValueChanged = transformslidersupdate
--     --     end)
--     -- end
--     --end bunch of copied shit
-- end
-- function ImageHistoryPanel(button)
--     if IsValid(SS_CustTextureHistory) then
--         SS_CustTextureHistory:Remove()
--         return
--     end
--     local sz = 512
--     local Menu = DermaMenu()
--     local container = Container(nil, "Saved Textures")
--     container.Paint = noop
--     container:SetSize(512, 512)
--     Menu:AddPanel(container)
--     local textures = vgui.Create("DImgurManager", container)
--     textures:SetMultiline(true)
--     textures:Dock(TOP)
--     textures:SetTall(256)
--     textures:SetSize(512, 512)
--     Menu.Paint = function(pnl, w, h)
--         DisableClipping(true)
--         local border = 8
--         draw.BoxShadow(-2, -2, w + 4, h + 4, border, 1)
--         DisableClipping(false)
--         SS_PaintBG(pnl, w, h)
--     end
--     SS_CustTextureHistory = Menu
--     textures:SetColumns(4)
--     textures:Load()
--     local img = SS_CustomizerPanel.TextureBar:GetText()
--     textures.AddField:SetText(img)
--     textures.OnChoose = function(pnl, img)
--         SingleAsyncSanitizeImgurId(img, function(id)
--             if not IsValid(pnl) then return end
--             if id then
--                 SS_CustomizerPanel.TextureBar:SetText(id)
--                 textures.AddField:SetText(id)
--             end
--             SS_CustomizerPanel.item.cfg.imgur = id and {
--                 url = id,
--                 nsfw = false
--             } or nil
--             SS_CustomizerPanel:Update()
--         end)
--     end
--     local x, y = button:LocalToScreen(button:GetWide() + SS_COMMONMARGIN, 0)
--     Menu:Open(x, y)
--     Menu.BaseLayout = Menu.PerformLayout
--     Menu.PerformLayout = function(pnl, w, h)
--         Menu.BaseLayout(pnl, w, h)
--         local x, y = pnl:GetPos()
--         x = math.Clamp(x, 0, ScrW() - w)
--         y = math.Clamp(y, 0, ScrH() - h)
--         Menu:SetPos(x, y)
--     end
-- end
