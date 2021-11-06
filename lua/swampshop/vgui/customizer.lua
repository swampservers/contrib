﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
--NOMINIFY
local PANEL = {}
PANEL.NeedsKeyboard = true

function PANEL:Init()
    SS_CustomizerPanel = self
end

function PANEL:OpenItem(item)
    self:OpenOver()

    for k, v in pairs(self:GetChildren()) do
        v:Remove()
    end

    self.item = item
    item.applied_cfg = table.Copy(item.cfg)
    self.wear = LocalPlayer():IsPony() and "wear_p" or "wear_h"
    self.Paint = SS_PaintBG
    self:SetVisible(true)

    --main panel
    vgui("DPanel", self, function(p)
        p.Paint = noop
        p:Dock(FILL)
        p:DockMargin(0, SS_COMMONMARGIN, 0, SS_COMMONMARGIN)

        self.controlzone = vgui("DPanel", function(p)
            p:Dock(FILL)
            p:DockMargin(0, 0, 0, 0)
            p.Paint = SS_PaintBG
        end)

        self:SetupControls()

        vgui("DPanel", function(p)
            p.Paint = SS_PaintFG
            p:DockMargin(0, 0, 0, SS_COMMONMARGIN)
            p:SetTall(SS_CUSTOMIZER_HEADINGSIZE)
            p:Dock(TOP)

            vgui("DLabel", function(p)
                p:SetFont("SS_LargeTitle")
                p:SetText("βUSTOMIZER")
                p:SetTextColor(MenuTheme_TX)
                p:SetContentAlignment(5)
                p:SizeToContents()
                p:DockMargin(80, 8, 0, 10)
                p:Dock(LEFT)
            end)

            vgui("DLabel", function(p)
                p:SetFont("SS_DESCINSTFONT")
                p:SetText("                                      WARNING:\nPornographic images or builds are not allowed!")
                p:SetTextColor(MenuTheme_TX)
                p:SetContentAlignment(5)
                p:SizeToContents()
                p:DockMargin(0, 0, 32, 0)
                p:Dock(RIGHT)
            end)
        end)

        --bottom panel
        vgui("DPanel", function(p)
            p.Paint = function() end
            p:SetTall(SS_CUSTOMIZER_HEADINGSIZE)
            p:Dock(BOTTOM)

            vgui("DButton", function(p)
                p:SetText("Reset")
                p:SetFont("SS_DESCTITLEFONT")
                p:SetWide(SS_GetMainGridDivision(4))
                p:DockMargin(0, SS_COMMONMARGIN, SS_COMMONMARGIN, 0)
                p:Dock(LEFT)
                p.Paint = SS_PaintButtonBrandHL

                p.UpdateColours = function(pnl)
                    pnl:SetTextStyleColor(MenuTheme_TX)
                end

                p.DoClick = function(butn)
                    self.item.cfg = {}
                    self:UpdateCfg()
                    self:SetupControls()
                end
            end)

            vgui("DButton", function(p)
                p:SetText("Cancel")
                p:SetFont("SS_DESCTITLEFONT")
                p:SetWide(SS_GetMainGridDivision(4))
                p:DockMargin(0, SS_COMMONMARGIN, 0, 0)
                p:Dock(LEFT)
                p.Paint = SS_PaintButtonBrandHL

                p.UpdateColours = function(pnl)
                    pnl:SetTextStyleColor(MenuTheme_TX)
                end

                p.DoClick = function(butn)
                    self.item.cfg = self.item.applied_cfg
                    self:Close()
                end
            end)

            vgui("DButton", function(p)
                p:SetText("Done")
                p:SetFont("SS_DESCTITLEFONT")
                p:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, 0, 0)
                p:Dock(FILL)
                p.Paint = SS_PaintButtonBrandHL

                p.UpdateColours = function(pnl)
                    pnl:SetTextStyleColor(MenuTheme_TX)
                end

                p.DoClick = function(butn)
                    SS_ItemServerAction(self.item.id, "configure", self.item.cfg)
                    self:Close()
                end
            end)
        end)
    end)
end

function PANEL:SetupControls()
    for _, v in ipairs(self.controlzone:GetChildren()) do
        v:Remove()
    end

    self.LeftColumn = vgui.Create("DScrollPanel", self.controlzone)
    self.LeftColumn:Dock(LEFT)
    self.LeftColumn:SetWide(SS_GetMainGridDivision(2))
    self.LeftColumn:DockMargin(0, 0, SS_COMMONMARGIN, 0)
    self.LeftColumn.VBar:DockMargin(SS_COMMONMARGIN, 0, SS_COMMONMARGIN, 0)
    SS_SetupVBar(self.LeftColumn.VBar)
    self.LeftColumn.VBar:SetWide(SS_SCROLL_WIDTH)
    self.RightColumn = vgui.Create("DScrollPanel", self.controlzone)
    self.RightColumn:Dock(FILL)
    self.RightColumn:SetPadding(0)
    self.RightColumn.VBar:DockMargin(SS_COMMONMARGIN, 0, 0, 0)
    SS_SetupVBar(self.RightColumn.VBar)
    self.RightColumn.VBar:SetWide(SS_SCROLL_WIDTH)

    if self.item.SetupCustomizer then
        self.item:SetupCustomizer(self)
    else
        local pone = LocalPlayer():IsPony()
        local suffix = pone and "_p" or "_h"
        local itmcw = self.item:GetSettings().wear

        if (self.item:GetSettings() or {}).wear then

            local attach, translate, rotate, scale = self.item:AccessoryTransform(pone)

            --LabelMaker(wearzone, "Position (" .. (pone and "pony" or "human") .. ")", true)
            vgui("DSSCustomizerSection", self.LeftColumn, function(p)
                p:SetText("Attachment (" .. (pone and "pony" or "human") .. ")")

                vgui("DPanel", function(p)
                    p:Dock(TOP)
                    p:SetTall(24)
                    p.Paint = noop

                    vgui("DComboBox", function(p)
                        p:SetValue(attach) --(self.item.cfg[self.wear] or {}).attach or (pone and (self.item.wear.pony or {}).attach) or self.item.wear.attach)

                        for k, v in pairs(SS_Attachments) do
                            p:AddChoice(k)
                        end

                        p:Dock(FILL)
                        p.Paint = SS_PaintBG

                        p.UpdateColours = function(pnl)
                            pnl:SetTextStyleColor(MenuTheme_TX)
                            pnl:SetTextColor(MenuTheme_TX)
                        end

                        print("ADDONSELECT", p)
                        p.OnSelect = function(panel, index, value)
                            print("SELECT", index, value)
                            self.item.cfg[self.wear] = self.item.cfg[self.wear] or {}
                            self.item.cfg[self.wear].attach = value
                            self:UpdateCfg()
                        end
                    end)

                    vgui("DLabel", function(p)
                        p:Dock(LEFT)
                        p:SetText("Attach to")

                        p.UpdateColours = function(pnl)
                            pnl:SetTextColor(MenuTheme_TX)
                        end


                    end)
                end)
            end)

            -- p:SizeToChildren(true,true)
            -- p:SizeToChildren(true,true)
            -- local translate = (self.item.cfg[self.wear] or {}).pos or (pone and (self.item.wear.pony or {}).translate) or self.item.wear.translate
            -- local rotate = (self.item.cfg[self.wear] or {}).ang or (pone and (self.item.wear.pony or {}).rotate) or self.item.wear.rotate
            -- local scale = (self.item.cfg[self.wear] or {}).scale or (pone and (self.item.wear.pony or {}).scale) or self.item.wear.scale

            self.Position = vgui('DSSCustomizerVectorSection', self.LeftColumn, function(p)
                p:SetForPosition(itmcw.pos.min, itmcw.pos.max, translate)
            end)

            self.Angle = vgui('DSSCustomizerVectorSection', self.LeftColumn, function(p)
                p:SetForAngle(rotate)
            end)

            self.Scale = vgui('DSSCustomizerVectorSection', self.LeftColumn, function(p)
                p:SetForScale(itmcw.scale.min * self.item:ScaleLimitOffset(), itmcw.scale.max * self.item:ScaleLimitOffset(), scale)
            end)

            local function transformslidersupdate()
                self.item.cfg[self.wear] = self.item.cfg[self.wear] or {}
                self.item.cfg[self.wear].pos = self.Position:GetValue()
                self.item.cfg[self.wear].ang = self.Angle:GetValueAngle()
                self.item.cfg[self.wear].scale = self.Scale:GetValue()
                self:UpdateCfg()
            end

            self.Position.OnValueChanged = transformslidersupdate
            self.Angle.OnValueChanged = transformslidersupdate
            self.Scale.OnValueChanged = transformslidersupdate
        elseif (self.item:GetSettings() or {}).bone then
            vgui("DSSCustomizerSection", self.LeftColumn, function(p)
                p:SetText("Mod (" .. (LocalPlayer():IsPony() and "pony" or "human") .. ")")

                local function cleanbonename(bn)
                    return bn:Replace("ValveBiped.Bip01_", ""):Replace("Lrig", ""):Replace("_LEG_", "")
                end

                vgui("DComboBox", function(p)
                    p:SetValue(cleanbonename(self.item.cfg["bone" .. suffix] or (pone and "Scull" or "Head1")))
                    p:SetTall(24)
                    p:Dock(TOP)
                    p.Paint = SS_PaintBG

                    p.UpdateColours = function(pnl)
                        pnl:SetTextStyleColor(MenuTheme_TX)
                        pnl:SetTextColor(MenuTheme_TX)
                    end

                    for x = 0, (LocalPlayer():GetBoneCount() - 1) do
                        local bn = LocalPlayer():GetBoneName(x)
                        local cleanname = cleanbonename(bn)

                        if cleanname ~= "__INVALIDBONE__" then
                            p:AddChoice(cleanname, bn)
                        end
                    end

                    p.OnSelect = function(panel, index, word, value)
                        self.item.cfg["bone" .. suffix] = value
                        self:UpdateCfg()
                    end
                end)
            end)

            --bunch of copied shit
            local function transformslidersupdate()
                if self.item:GetSettings().scale then
                    self.item.cfg["scale" .. suffix] = self.Scale:GetValue()
                end

                if self.item:GetSettings().pos then
                    self.item.cfg["pos" .. suffix] = self.Position:GetValue()
                end

                self:UpdateCfg()
            end

            local itmcp = self.item:GetSettings().pos

            if itmcp then
                self.Position = vgui('DSSCustomizerVectorSection', self.LeftColumn, function(p)
                    p:SetForPosition(itmcp.min, itmcp.max, translate)
                end)
            end

            local itmcs = self.item:GetSettings().scale

            if itmcs then
                self.Scale = vgui('DSSCustomizerVectorSection', self.LeftColumn, function(p)
                    p:SetForScale(itmcw.scale.min * self.item:ScaleLimitOffset(), itmcw.scale.max * self.item:ScaleLimitOffset(), scale)
                end)
            end

            --end bunch of copied shit
            if self.item:GetSettings().scale_children then
                vgui('DSSCustomizerCheckbox', self.LeftColumn, function(p)
                    -- "Scale child bones"
                    p:SetValue(self.item.cfg["scale_children" .. suffix] and 1 or 0)

                    p.OnChange = function(checkboxself, ch)
                        self.item.cfg["scale_children" .. suffix] = ch
                        self:UpdateCfg()
                    end
                end)
            end
        end

        local limit = self.item:GetSettings().color

        if limit then
            vgui("DSSCustomizerColor", self.RightColumn, function(p)
                p:SetValue(self.item.cfg.color or self.item.color or Vector(1, 1, 1))

                p.OnValueChanged = function(pnl, vec)
                    self.item.cfg.color = vec
                    self:UpdateCfg()
                end
            end)
        end

        if self.item:GetSettings().imgur then
            vgui("DSSCustomizerImgur", self.RightColumn, function(p)
                p:SetValue(self.item.cfg.imgur)

                p.OnValueChanged = function(pnl, imgur)
                    self.item.cfg.imgur = imgur
                    self:UpdateCfg()
                end
            end)
        end
    end

    vgui("DCollapsibleCategory", self.RightColumn, function(p)
        p:Dock(TOP)
        p:SetTall(256)
        p:DockMargin(0, 0, 0, 0)
        p:DockPadding(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
        p.BasedPerformLayout = p.PerformLayout

        p.PerformLayout = function(pnl)
            pnl:SizeToChildren(false, true)
            pnl:InvalidateParent(true)
            pnl:DockMargin(0, 0, self.RightColumn.VBar:IsVisible() and SS_COMMONMARGIN or 0, SS_COMMONMARGIN)
            pnl:BasedPerformLayout(pnl:GetWide(), pnl:GetTall())
        end

        p:SetLabel("Raw Data")
        p.Header:SetFont("SS_DESCINSTFONT")
        p.Header:SetTextColor(MenuTheme_TX)
        -- p.Header.UpdateColours = function(pnl)
        --     pnl:SetTextColor(MenuTheme_TX)
        -- end
        p.Header:SetContentAlignment(8)
        p.Header:SetTall(26)
        p.Paint = SS_PaintFG
        p:SetExpanded(false)
        p:SetKeyboardInputEnabled(true)

        vgui("DPanel", function(p)
            p:Dock(FILL)
            p.Paint = SS_PaintBG

            p.PerformLayout = function(pnl)
                pnl:SizeToChildren(false, true)
                pnl:InvalidateParent(true)
            end

            self.RawEntry = vgui("DTextEntry", function(p)
                p:SetMultiline(true)
                p:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
                p:SetTall(256)
                p:Dock(FILL)
                p:SetPaintBackground(false)
                p:SetTextColor(MenuTheme_TX)
                p:SetCursorColor(MenuTheme_TX)
                p:SetEditable(true)
                p:SetKeyboardInputEnabled(true)

                -- p.UpdateColours = function(pnl)
                --     pnl:SetTextColor(MenuTheme_TX)
                --     pnl:SetCursorColor(MenuTheme_TX)
                -- end
                p.PerformLayout = function(pnl)
                    pnl:SizeToContentsY()
                    pnl:InvalidateParent(true)
                end

                p.OnValueChange = function(textself, new)
                    textself:InvalidateLayout(true)

                    if not textself.RECIEVE then
                        self.item.cfg = util.JSONToTable(new) or {}
                        self:UpdateCfg(true) -- TODO: sanitize input like on the server
                    end
                end

                p:SetUpdateOnType(true)
            end)
        end)
    end)

    --p:SetValue("unset") --(self.item.cfg.imgur or {}).url or "")
    self:UpdateCfg()
end

function ImageGetterPanel()
    local mat
    local mdl = IsValid(SS_HoverCSModel) and SS_HoverCSModel or LocalPlayer()

    if IsValid(SS_HoverCSModel) then
        mat = SS_HoverCSModel:GetMaterials()[1]
    else
        mat = SS_PreviewPane.Entity:GetMaterials()[(SS_CustomizerPanel.item.cfg.submaterial or 0) + 1]
    end

    local mat_inst = Material(mat)
    local dispmax = 512
    local tw, th = mat_inst:Width(), mat_inst:Height()
    local big = math.max(tw, th)
    tw = tw / big * dispmax
    th = th / big * dispmax

    if mat then
        local Frame = vgui.Create("DFrame")
        Frame:SetSize(tw + 10, th + 30 + 24)
        Frame:DockPadding(SS_COMMONMARGIN, SS_COMMONMARGIN + 24, SS_COMMONMARGIN, SS_COMMONMARGIN)
        Frame:Center()
        Frame:SetTitle(mat)
        Frame:MakePopup()
        Frame.btnMaxim:SetVisible(false)
        Frame.btnMinim:SetVisible(false)
        local DLButton = vgui.Create("DButton", Frame)
        DLButton:SetPos(128, 0)
        DLButton:Dock(BOTTOM)
        DLButton:DockMargin(0, SS_COMMONMARGIN, 0, 0)
        DLButton:SetText("Download Image")
        DLButton.Paint = SS_PaintButtonBrandHL
        DLButton:SetTextColor(MenuTheme_TX)

        DLButton.DoClick = function()
            local function DownloadTexture(mat, callback)
                hook.Add("PostRender", "SS_TexDownload", function()
                    if (mat and not mat:IsError()) then
                        local matcopy = CreateMaterial(mat:GetName() .. "copy", "UnlitGeneric", {
                            ["$basetexture"] = mat:GetString("$basetexture")
                        })

                        local RT = GetRenderTarget(mat:GetName() .. "download", mat:Width(), mat:Height())
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
                        local parts = string.Explode("/", mat:GetName() or "")
                        local imagename = parts[#parts] or "temp_image"
                        local fname = imagename .. ".png"
                        file.Write(fname, data)

                        if callback then
                            callback(fname, data)
                        end
                    else
                        if callback then
                            callback()
                        end
                    end

                    hook.Remove("PostRender", "SS_TexDownload")
                end)
            end

            DownloadTexture(Material(mat), function(fname, data)
                if (fname) then
                    Frame:SetTitle("Downloaded! Look for file: garrysmod/data/" .. fname)
                else
                    Frame:SetTitle("Couldn't Download!")
                end
            end)
        end

        Frame.BasedPaint = Frame.Paint

        Frame.Paint = function(pnl, w, h)
            DisableClipping(true)
            local border = 8
            draw.BoxShadow(-2, -2, w + 4, h + 4, border, 1)
            DisableClipping(false)
            SS_PaintBG(pnl, w, h)
            BrandBackgroundPattern(0, 0, w, 24, 0)
        end

        local img = vgui.Create("DImage", Frame)
        img:Dock(FILL)
        img:SetImage(mat)
        img:GetMaterial():SetInt("$flags", 0)
        img.BasedPaint = img.Paint

        function img:Paint(w, h)
            cam.IgnoreZ(true)
            self:BasedPaint(w, h)
            cam.IgnoreZ(false)
        end
    else
        LocalPlayerNotify("Couldn't find the material, sorry.")
    end
end

function PANEL:UpdateCfg(skiptext)
    self.item:Sanitize()

    if IsValid(self.RawEntry) and not skiptext then
        self.RawEntry.RECIEVE = true
        self.RawEntry:SetValue(util.TableToJSON(self.item.cfg, true))
        self.RawEntry.RECIEVE = nil
    end
end

vgui.Register('DSSCustomizerMode', PANEL, 'DSSMode')
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
--             if (id) then
--                 SS_CustomizerPanel.TextureBar:SetText(id)
--                 textures.AddField:SetText(id)
--             end
--             SS_CustomizerPanel.item.cfg.imgur = id and {
--                 url = id,
--                 nsfw = false
--             } or nil
--             SS_CustomizerPanel:UpdateCfg()
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
