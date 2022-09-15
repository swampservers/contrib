-- This file is subject to copyright - contact swampservers@gmail.com for more information.
ShopTab({
    name = "Customizer",
    class = "ShopCustomizerMode"
})

vgui.Register('ShopEqualWidthLayout', {
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

vgui.Register('ShopCustomizerMode', {
    OpensOver = true,
    Title = "Customizer",
    TitleNote = "WARNING: Pornographic images or builds are not allowed!",
    Init = function(self)
        ShopCustomizerPanel = self
    end,
    DrawOverPreview = function(self, preview)
        local y = 14

        if IsValid(self.Angle) then
            draw.SimpleText("RMB + drag to rotate", Font.sans24, preview:GetWide() / 2, y, UI_White[0], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            y = y + 32
        end

        if IsValid(self.Position) then
            draw.SimpleText("MMB + drag to move", Font.sans24, preview:GetWide() / 2, y, UI_White[0], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end,
    OpenItem = function(self, item)
        self:Clear()
        self:Open()

        ShopPreviewPanel.ents.player:SwitchSequence({"reference", "menu_combine", "ragdoll"})

        self.item = item
        item.applied_cfg = table.Copy(item.cfg)
        self.wear = Me:IsPony() and "wear_p" or "wear_h"
        self:SetVisible(true)

        --bottom panel
        ui.ShopEqualWidthLayout({
            parent = self
        }, function(p)
            p:SetTall(64)
            p:Dock(BOTTOM)

            ui.ShopEqualWidthLayout(function(p)
                ui.ShopButton(function(p)
                    p:SetText("Reset")
                    p:SetFont(Font.Righteous32)

                    p.DoClick = function(butn)
                        self.item.cfg = {}
                        self:Update()
                        self:SetupControls()
                    end
                end)

                ui.ShopButton(function(p)
                    p:SetText("Cancel")
                    p:SetFont(Font.Righteous32)

                    p.DoClick = function(butn)
                        self.item.cfg = self.item.applied_cfg
                        self:Close()
                        ShopPreviewPanel.ents.player:SwitchSequence()
                    end
                end)
            end)

            ui.ShopButton(function(p)
                p:SetFont(Font.Righteous32)
                p:SetText("Done")

                p.DoClick = function(butn)
                    local callback = function()
                        self:Close()

                        ShopPreviewPanel.ents.player:TimerSimple(0.4, function(e)
                            e:SwitchSequence({
                                ({"pose_standing_01", "pose_standing_04", "pose_standing_04", "zombie_attack_07_original"})[math.ceil(math.random() * 3.2)],
                                "cidle_me1"
                            })
                        end)

                        ShopPreviewPanel.ents.player:TimerSimple(1.6, function(e)
                            e:SwitchSequence()
                        end)
                    end

                    self.item:FinishCustomizer(callback)
                end
            end)
        end)

        -- p:InvalidateLayout()
        ui.Panel({
            parent = self
        }, function(p)
            p:SetZPos(1)
            p:Dock(BOTTOM)
            p:SetTall(UI_DIVIDER_SIZE)

            function p:Paint()
                UI_DrawDivider(self, false)
            end
        end)

        self.controlzone = ui.ShopEqualWidthLayout({
            parent = self
        }, function(p)
            p:Dock(FILL)
        end)

        self:SetupControls()
    end,
    SetupControls = function(self)
        ui[self.controlzone](function(p)
            p:Clear()

            self.LeftColumn = ui.List({
                dock = LEFT
            })

            self.RightColumn = ui.List({
                dock = FILL
            })
        end)

        if self.item.SetupCustomizer then
            self.item:SetupCustomizer(self)
        end

        local pone = Me:IsPony()
        local suffix = pone and "_p" or "_h"
        local settings = self.item.settings

        if settings.color then
            ui.ShopCustomizerColor({
                parent = self.RightColumn
            }, function(p)
                p:SetValue(self.item.cfg.color or self.item.color or Vector(1, 1, 1))

                p.OnValueChanged = function(pnl, vec)
                    self.item.cfg.color = vec
                    self:Update()
                end
            end)
        end

        if settings.imgur then
            ui.ShopCustomizerImgur({
                parent = self.RightColumn
            }, function(p)
                p:SetValue(self.item.cfg.imgur)

                p.OnValueChanged = function(pnl, imgur)
                    self.item.cfg.imgur = imgur
                    self:Update()
                end
            end)
        end

        local rawdata = ui.ShopCustomizerSection({
            parent = self.RightColumn
        }, function(p)
            p:SetVisible(false)
            p:SetText("Raw Data")

            self.RawEntry = ui.DTextEntry(function(p)
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

        ui.ShopButton({
            parent = self.RightColumn
        }, function(p)
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
}, 'ShopMode')

-- TODO we need a way to get the accessory ent
function ImageGetterPanel()
    local mat = IsValid(ShopPreviewPanel.ents.item) and ShopPreviewPanel.ents.item:GetMaterials()[1] or (IsValid(ShopPreviewPanel.accessoryitement) and ShopPreviewPanel.accessoryitement:GetMaterials()[1] or ShopPreviewPanel.ents.player:GetMaterials()[(ShopCustomizerPanel.item.cfg.submaterial or 0) + 1])
    assert(mat)
    local mat_inst = Material(mat)
    local dispmax = 512
    local tw, th = mat_inst:Width(), mat_inst:Height()
    local big = math.max(tw, th)
    tw = tw / big * dispmax
    th = th / big * dispmax

    ui.DFrame(function(p)
        local frame = p
        p:SetSize(tw + 10, th + 30 + 24)
        -- p:DockPadding(UI_MARGIN, UI_MARGIN + 24, UI_MARGIN, UI_MARGIN)
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
            ShopPaintBG(pnl, w, h)
            BrandBackgroundPattern(0, 0, w, 24, 0)
        end

        ui.ShopButton(function(p)
            p:SetPos(128, 0)
            p:Dock(BOTTOM)
            -- p:DockMargin(0, UI_MARGIN, 0, 0)
            p:SetText("Download Image")
            -- p.Paint = ShopPaintButtonBrandHL
            p:SetTextColor(MenuTheme_TX)

            p.DoClick = function()
                local imat = Material(mat)

                hook.Add("PostRender", "ShopTexDownload", function()
                    hook.Remove("PostRender", "ShopTexDownload")

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

        ui.DImage(function(p)
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
--         self.Position = ui.ShopCustomizerVectorSection({parent=self.LeftColumn},function(p)
--             p:SetForPosition(itmcp.min, itmcp.max, self.item.cfg["pos" .. suffix] or Vector(0,0,0))
--             p.OnValueChanged = transformslidersupdate
--         end)
--     end
--     -- local itmca = settings.ang
--     -- if itmca then
--     --     self.Scale = ui.ShopCustomizerVectorSection({parent=self.LeftColumn},function(p)
--     --         p:SetForAngle(itmcs.min, itmcs.scale.max, self.item.cfg["scale" .. suffix] or Vector(1,1,1))
--     --         p.OnValueChanged = transformslidersupdate
--     --     end)
--     -- end
--     --end bunch of copied shit
-- end
-- function ImageHistoryPanel(button)
--     if IsValid(ShopCustomizerTextureHistory) then
--         ShopCustomizerTextureHistory:Remove()
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
--         ShopPaintBG(pnl, w, h)
--     end
--     ShopCustomizerTextureHistory = Menu
--     textures:SetColumns(4)
--     textures:Load()
--     local img = ShopCustomizerPanel.TextureBar:GetText()
--     textures.AddField:SetText(img)
--     textures.OnChoose = function(pnl, img)
--         SingleAsyncSanitizeImgurId(img, function(id)
--             if not IsValid(pnl) then return end
--             if id then
--                 ShopCustomizerPanel.TextureBar:SetText(id)
--                 textures.AddField:SetText(id)
--             end
--             ShopCustomizerPanel.item.cfg.imgur = id and {
--                 url = id,
--                 nsfw = false
--             } or nil
--             ShopCustomizerPanel:Update()
--         end)
--     end
--     local x, y = button:LocalToScreen(button:GetWide() + UI_MARGIN, 0)
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
