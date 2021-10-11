-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local PANEL = {}

function PANEL:Close()
    if (not IsValid(SS_ShopMenu)) then
        self:SetVisible(false)

        return
    end

    if (IsValid(SS_DescriptionPanel)) then
        SS_DescriptionPanel:SetVisible(true)
    end

    if (IsValid(SS_PreviewPane)) then
        SS_PreviewContainer:SizeTo(SS_RPANEWIDTH, -1, 0.2)
    end

    self.item = nil

    if (SS_ShopMenu.InventoryButtons) then
        local cat = SS_ShopMenu.InventoryButtons[SS_ShopMenu.LastCategory or "Cosmetics_inv"]

        if (cat) then
            for k, v in pairs(SS_ShopMenu.InventoryButtons) do
                if (v ~= pnl) then
                    v:SetActive(false)
                    --v:OnDeactivate()
                end
            end

            cat:SetActive(true)
        end
    end

    if (IsValid(SS_PreviewPane.ControlContainer)) then
        SS_PreviewPane.ControlContainer:SizeTo(-1, 0, 0.2)
        SS_PreviewPane.ControlContainer2:SizeTo(-1, 0, 0.2)
    end

    self:SetVisible(false)
end

local function GapMaker(parent)
    local GAP = vgui.Create("DPanel", parent)
    GAP:Dock(TOP)
    GAP:SetTall(SS_COMMONMARGIN)
    GAP.Paint = function() end
end

local function LabelMaker(parent, text, top)
    local p2 = nil

    if not top or true then
        p2 = vgui.Create("Panel", parent)
        p2:DockMargin(0, 0, 0, SS_COMMONMARGIN)
        p2:Dock(TOP)
        p2.Paint = noop --SS_PaintBG

        if parent.AddItem then
            parent:AddItem(p2)
        end
    end

    local p = vgui.Create("DLabel", p2 or parent)
    p:SetFont("SS_DESCINSTFONT")
    p:SetText(text)
    p:SetTextColor(SS_SwitchableColor)
    p:SizeToContents()

    p.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
    end

    if top then
        p:SetContentAlignment(5)
        p:DockMargin(0, 0, 0, 0)
        p:Dock(FILL)

        if parent.AddItem then
            parent:AddItem(p)
        end
    else
        p:DockMargin(0, 0, 0, 0)
        p:Dock(LEFT)
    end

    return p2
end

local function SliderMaker(parent, text)
    local p = vgui.Create("DNumSlider", parent)
    p:SetText(text)
    p:SetDecimals(2)
    p:DockMargin(0, 0, 0, SS_COMMONMARGIN)
    p:Dock(TOP)
    p:SetDark(not SS_DarkMode)
    p.TextArea:SetPaintBackground(false)
    p:SetTall(24)
    p.TextArea.BasedPaint = p.TextArea.Paint

    p.TextArea.Paint = function(pnl, w, h)
        SS_PaintBG(pnl, w, h)
        p.TextArea.BasedPaint(pnl, w, h)
    end

    p.TextArea.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
    end

    p.TextArea:DockMargin(SS_COMMONMARGIN, 0, 0, 0)

    p.Label.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
    end

    p.Slider.Knob:SetWide(6)

    p.Slider.Paint = function(pnl, w, h)
        local y = h / 2
        local barh = 2
        SS_GLOBAL_RECT(0, y - barh / 2, w, barh, MenuTheme_BG)
    end

    p.Slider.Knob.Paint = function(pnl, w, h)
        draw.BoxShadow(0, 0, w, h, 8, 1)
        SS_GLOBAL_RECT(0, 0, w, h, MenuTheme_Brand)
    end

    if parent.AddItem then
        parent:AddItem(p)
    end

    return p
end

local function CheckboxMaker(parent, text)
    local p2 = vgui.Create("Panel", parent)
    p2:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
    p2:Dock(TOP) --retarded wrapper
    local p3 = vgui.Create("DCheckBox", p2)
    --p:SetText(text)
    p3:SetDark(true)
    p3:SetPos(0, 2)
    --p:SetTall(24)
    local p = vgui.Create("DLabel", p2 or parent)
    p:SetFont("SS_DESCFONT")
    p:SetText(text)
    p:SetTextColor(SS_SwitchableColor)
    p:SetPos(24, 0)
    p:SizeToContents()

    --p2:SizeToChildren()
    if parent.AddItem then
        parent:AddItem(p2)
    end

    return p3
end

function PANEL:AddSection(name)
    self.Sections = self.Sections or {}
    if (self.Sections[name]) then return self.Sections[name] end
    local sect = vgui.Create("DScrollPanel", self.controlzone)
    sect:Dock(FILL)
    sect:DockMargin(0, 0, 0, 0)
    sect.VBar:DockMargin(SS_COMMONMARGIN, 0, 0, 0)
    SS_SetupVBar(sect.VBar)
    sect.VBar:SetWide(SS_SCROLL_WIDTH)
    sect.BasedLayout = sect.PerformLayout

    sect.PerformLayout = function(pnl)
        pnl:BasedLayout()
    end

    self.Sections[name] = sect
    self.Sections[name]:InvalidateLayout(true)

    return self.Sections[name]
end

local function Container(parent, label, noncollapse)
    local pane = vgui.Create(noncollapse and "DPanel" or "DCollapsibleCategory", parent)
    pane:Dock(TOP)
    pane:SetTall(256)
    pane:DockMargin(0, 0, 0, 0)
    pane:DockPadding(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
    pane.BasedPerformLayout = pane.PerformLayout
    pane.Paint = SS_PaintFG

    pane.PerformLayout = function(pnl)
        pnl:SizeToChildren(false, true)

        --pnl:InvalidateParent(true)
        if (IsValid(pnl:GetParent()) and IsValid(pnl:GetParent():GetParent()) and IsValid(pnl:GetParent():GetParent().VBar)) then
            pnl:DockMargin(0, 0, pnl:GetParent():GetParent().VBar:IsVisible() and SS_COMMONMARGIN or 0, SS_COMMONMARGIN)
        end

        pnl:BasedPerformLayout(pnl:GetWide(), pnl:GetTall())
    end

    pane.Paint = function(pnl, w, h)
        SS_PaintFG(pnl, w, h)

        if (IsValid(pnl.Header)) then
            local y = pnl.Header:GetTall()
            surface.SetDrawColor(MenuTheme_BG)
            surface.DrawRect(2, y, w - 4, 1)
        end
    end

    if (not noncollapse) then
        pane:SetLabel(label)
        pane.Header:SetFont("SS_DESCINSTFONT")
        pane.Header:SetContentAlignment(8)
        pane.Header:SetTall(28)

        pane.Header.UpdateColours = function(pnl)
            pnl:SetTextColor(MenuTheme_TX)
        end

        pane:SetExpanded(true)
        pane:SetKeyboardInputEnabled(true)
        local ExpandArrow = vgui.Create("DLabel", pane.Header)
        ExpandArrow:Dock(RIGHT)
        ExpandArrow:SetContentAlignment(9)
        ExpandArrow:SetFont('marlett')
        ExpandArrow:SetText("5")

        ExpandArrow.UpdateColours = function(pnl)
            pnl:SetTextColor(MenuTheme_TX)
        end

        function pane:OnToggle(expanded)
            ExpandArrow:SetText(expanded and "5" or '6')
        end
    end
    --[[
    local pane = vgui.Create("Panel", parent)
    pane:DockMargin(0, 0, 0, 0)
    pane:DockPadding(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
    pane:Dock(TOP) --retarded wrapper
    pane:SetTall(512)
    pane.Paint = SS_PaintFG
    pane.PerformLayout = function(pnl)
        pnl:SizeToChildren(true, true)

        if (IsValid(parent) and parent:GetName() == "DScrollPanel") then
            pnl:DockMargin(0, 0, parent.VBar:IsVisible() and SS_COMMONMARGIN or 0, SS_COMMONMARGIN)
        else
            pnl:DockMargin(0, 0, 0, SS_COMMONMARGIN)
        end
    end


    LabelMaker(pane, label, true)
    ]]

    return pane
end

function PANEL:AddContainer(section, label)
    local parent = self.Sections[section]

    if (not IsValid(parent)) then
        parent = self:AddSection(section)
        ErrorNoHaltWithStack("container defined before section!!!! please fix this")
    end

    local pane = Container(parent, label)

    return pane
end

function PANEL:AddColorOption(section, keys, label)
    local item = self.item
    local suffix = self.WEARSUFFIX
    local options = GetNestedInfo(item, keys)
    local pane = self:AddContainer(section, label)
    local cv = GetNestedProperty(item, keys, TYPE_VECTOR)

    if (not isvector(cv)) then
        cv = Vector(1, 1, 1)
    end

    local cvm = math.max(1, cv.x, cv.y, cv.z)
    local PSCMixer = vgui.Create("DColorMixer", pane)
    PSCMixer:SetPalette(true)
    PSCMixer:SetAlphaBar(false)
    PSCMixer:SetWangs(true)
    PSCMixer:SetVector(cv / cvm)
    PSCMixer:SetTall(250)
    PSCMixer:DockMargin(0, 0, 0, 0)
    PSCMixer:Dock(TOP)
    PSCMixer.txtR:SetPaintBackground(false)
    PSCMixer.txtG:SetPaintBackground(false)
    PSCMixer.txtB:SetPaintBackground(false)
    PSCMixer.txtR.BasedPaint = PSCMixer.txtR.Paint
    PSCMixer.txtG.BasedPaint = PSCMixer.txtG.Paint
    PSCMixer.txtB.BasedPaint = PSCMixer.txtB.Paint

    PSCMixer.txtR.Paint = function(pnl, w, h)
        SS_PaintBG(pnl, w, h)
        pnl.BasedPaint(pnl, w, h)
    end

    PSCMixer.txtR.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
    end

    PSCMixer.txtG.Paint = PSCMixer.txtR.Paint
    PSCMixer.txtB.Paint = PSCMixer.txtR.Paint
    PSCMixer.txtG.UpdateColours = PSCMixer.txtR.UpdateColours
    PSCMixer.txtB.UpdateColours = PSCMixer.txtR.UpdateColours
    local PSBS = SliderMaker(pane, "Boost")
    PSBS:SetMinMax(1, options.max)
    PSBS:SetValue(cvm)
    PSBS:DockMargin(0, SS_COMMONMARGIN, 0, SS_COMMONMARGIN)

    local function colorchanged()
        SetNestedProperty(item, keys, PSCMixer:GetVector() * PSBS:GetValue())
    end

    PSCMixer.ValueChanged = colorchanged
    PSBS.ValueChanged = colorchanged
end

function PANEL:AddImgurOption(section, keys, label)
    local item = self.item
    local options = GetNestedInfo(item, keys)
    local pane = self:AddContainer(section, label)
    local texturebarhelp = vgui.Create("DLabel", pane)
    texturebarhelp:Dock(TOP)
    texturebarhelp:DockMargin(0, 0, 0, SS_COMMONMARGIN)
    texturebarhelp:SetText("Upload an image to imgur.com and enter the link into the field below.\nFor example: https://imgur.com/a/3AOvcC1\nNo videos or GIFs!")
    texturebarhelp:SetWrap(true)
    texturebarhelp:SetTall(128)
    texturebarhelp:SetAutoStretchVertical(true)

    texturebarhelp.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
    end

    local texturec = vgui.Create("DPanel", pane)
    texturec:Dock(TOP)
    texturec.Paint = noop
    local texturedl = vgui.Create("DButton", texturec)
    texturedl:SetText("Show Reference Material")
    texturedl:Dock(RIGHT)
    texturedl:SetWide(180)
    texturedl:SetTextColor(MenuTheme_TX)
    texturedl:DockMargin(SS_COMMONMARGIN, 0, 0, 0)
    texturedl.Paint = SS_PaintButtonBrandHL

    texturedl.UpdateColours = function(pnl)
        pnl:SetTextStyleColor(MenuTheme_TX)
    end

    texturedl.DoClick = function()
        ImageGetterPanel()
    end

    local texturebarc = vgui.Create("DPanel", texturec)
    texturebarc:Dock(TOP)
    texturebarc.Paint = SS_PaintBG
    local texturebar = vgui.Create("DTextEntry", texturebarc)
    texturebar:Dock(FILL)
    self.TextureBar = texturebar
    texturebar:SetPaintBackground(false)
    texturebar:SetUpdateOnType(true)
    texturebar:SetTextColor(MenuTheme_TX)
    local cur = GetNestedProperty(item, keys, TYPE_TABLE)
    texturebar:SetText(cur and cur.url or "")

    texturebar.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
        pnl:SetCursorColor(MenuTheme_TX)
    end

    texturebar.OnValueChange = function(textself, new)
        SetNestedProperty(item, keys, new and {
            url = new,
            nsfw = nsfw
        } or nil)
    end

    local savebutton = vgui.Create("DImageButton", texturebarc)
    savebutton:SetSize(16, 16)
    savebutton:SetImage("icon16/disk.png")
    savebutton:SetToolTip("Manage Saved Textures")
    savebutton:DockMargin(4, 4, 4, 4)
    savebutton:Dock(RIGHT)

    savebutton.DoClick = function(pnl)
        if (IsValid(SS_CustTextureHistory)) then
            SS_CustTextureHistory:Remove()

            return
        end

        ImageHistoryPanel(pnl, texturebar)
    end
end

function PANEL:AddChoiceOption(section, keys, label, choices)
    local item = self.item
    local parent = self.Sections[section]
    local pane = Container(parent, label)
    local cnt = vgui.Create("DPanel", pane)
    cnt:Dock(TOP)
    cnt:SetTall(24)
    cnt.Paint = noop
    ATTACHSELECT = vgui.Create("DComboBox", cnt)
    ATTACHSELECT:SetValue(GetNestedProperty(item, keys, TYPE_STRING))

    for k, v in pairs(choices) do
        ATTACHSELECT:AddChoice(k)
    end
    --unfinished    
end

function PANEL:Open(item)
    for k, v in pairs(self:GetChildren()) do
        v:Remove()
    end

    local wid = SS_MENUWIDTH - SS_COMMONMARGIN * 2 --- (SS_TILESIZE + SS_COMMONMARGIN)*2
    SS_PreviewContainer:SizeTo(wid, -1, 0.2)
    SS_DescriptionPanel:SetVisible(false)

    for k, v in pairs(SS_ShopMenu.InventoryButtons) do
        v:SetActive(false)
        v:OnDeactivate()
    end

    self.item = item
    self.wearsuf = LocalPlayer():IsPony() and "_p" or "_h"
    self.wear = "wear" .. self.wearsuf
    SS_PreviewPane.ControlContainer:SizeTo(-1, 32, 0.2)
    SS_PreviewPane.ControlContainer2:SizeTo(-1, 32, 0.2)
    SS_ShopMenu:MakePopup()
    --SS_PaintTileBG
    self.Paint = noop
    --.Paint = SS_PaintGridBG
    --.Paint = SS_PaintTileBG
    self:SetVisible(true)

    -- SS_InventoryPanel:SetVisible(false)
    --main panel
    vgui("DPanel", self, function(p)
        p.Paint = noop
        p:Dock(FILL)
        p:DockMargin(0, 0, SS_COMMONMARGIN, 0)

        self.controlzone = vgui("DPanel", function(p)
            p:Dock(FILL)
            p:DockMargin(0, SS_COMMONMARGIN, 0, 0)
            p.Paint = noop
        end)

        self:SetupControls()

        --heading
        vgui("DPanel", function(p)
            p.Paint = SS_PaintFG
            p:DockMargin(0, 0, 0, 0)
            p:SetTall(SS_CUSTOMIZER_HEADINGSIZE)
            p:Dock(TOP)

            vgui("DLabel", function(p)
                p:SetFont("SS_LargeTitle")
                p:SetText("βUSTOMIZER")

                p.UpdateColours = function(pnl)
                    pnl:SetTextColor(MenuTheme_TX)
                end

                p:SetColor(SS_SwitchableColor)
                p:SetContentAlignment(5)
                p:SizeToContents()
                p:DockMargin(8, 8, 8, 10)
                p:Dock(TOP)
            end)
        end)
    end)
    --[[
            vgui("DLabel", function(p)
                p:SetFont("SS_DESCINSTFONT")
                p:SetText("WARNING:\nPornographic images or builds are not allowed!")

                p.UpdateColours = function(pnl)
                    pnl:SetTextColor(MenuTheme_TX)
                end

                p:SetColor(SS_SwitchableColor)
                p:SetContentAlignment(5)
                p:SizeToContents()
                p:DockMargin(8, 8, 8, 8)
                p:Dock(TOP)
            end)
            ]]
    --bottom panel
end

--gets a value nested into tables using a table of keys. Should be writable?
local typedef_val = {
    [TYPE_BOOL] = false,
    [TYPE_NUMBER] = 0,
    [TYPE_STRING] = "",
    [TYPE_VECTOR] = Vector(),
    [TYPE_ANGLE] = Angle(),
}

local function typedef(typeid)
    return typedef_val[typeid]
end

--we should try to enforce what kind of data is returned by these even if it's already sanitized
local function checktype(dat, typeid)
    if typeid == nil then return true end
    if (istable(typeid)) then return table.HasValue(typeid, TypeID(dat)) end

    return TypeID(dat) == typeid
end

--if we can help it, this function should never return nil
--This function attempts to return a reasonable default value for its properties. This will look for item.wear etc. Used when no .cfg value is present
function GetNestedDefault(item, keys, typeid)
    local keys = table.Copy(keys)
    local itemdef = SS_Items[item.class]
    local use_configurable = true

    if (keys[1] == "wear_h") then
        --check item.wear
        keys[1] = "wear"
        use_configurable = false
    end

    if (keys[1] == "wear_p") then
        --check item.wear.pony
        keys[1] = "wear"
        table.insert(keys, 2, "pony")
        use_configurable = false
    end

    local base = itemdef

    if (use_configurable) then
        base = itemdef.configurable
    end

    --check "wear" table on item, translate some keys
    if (not use_configurable) then
        local ttable = {
            pos = "translate",
            ang = "rotate",
        }

        keys[#keys] = ttable[keys[#keys]] or keys[#keys]
    end

    local val = base

    for i, v in ipairs(keys) do
        val = val[v]
    end

    if (val and checktype(val, typeid)) then return val end
    --if all else fails, use a bullshit fallback value, per type

    return typedef(typeid)
end

--returns the matching value in item.configurable when you look up a .cfg key
function GetNestedInfo(item, keys)
    local base = item.configurable
    local val = base

    for i, v in ipairs(keys) do
        val = val[v]
    end

    return val
end

--attempts to get the current property value of an items config key. This will return the default value if none is present.
function GetNestedProperty(item, keys, typeid)
    local config = table.Copy(item.cfg)

    if (config ~= nil) then
        for i, v in ipairs(keys) do
            if (keys[i + 1] == nil) then continue end
            config[v] = config[v] or {}
            config = config[v]
        end

        local nv = keys[#keys]
        if (config[nv] ~= nil and checktype(config[nv], typeid)) then return config[nv] end
    end

    return GetNestedDefault(item, keys, typeid)
end

--it's probably a good idea to run every change to the items through one function
function SetNestedProperty(item, keys, value)
    local config = item.cfg
    local oldvalue = GetNestedProperty(item, keys)

    if (not item._cachedcfg) then
        item._cachedcfg = table.Copy(item.cfg)
        item._modified = true
    end

    for i, v in ipairs(keys) do
        if (keys[i + 1] == nil) then continue end --if this is the last key, leave it previous
        --if there's a property further in, make sure there's a table to step into
        config[v] = config[v] or {}
        config = config[v]
    end

    --print("changing",table.concat(keys,"."),"from",istable(oldvalue) and table.concat(oldvalue,",") or oldvalue,"to",istable(value) and table.concat(value,",") or value)
    config[keys[#keys]] = value
    SS_RefreshShopAccessories()
    SS_CustomizerPanel:UpdateCfg()
end

function PANEL:SetupControls()
    for k, v in pairs(self.controlzone:GetChildren()) do
        v:Remove()
    end

    local pone = LocalPlayer():IsPony()
    local suffix = pone and "_p" or "_h"
    local sufname = pone and "Pony" or "Human"
    local parsufname = "(" .. sufname .. ")"
    self.WEARSUFFIX = suffix
    self.Sections = {}
    --quick little hack, if you wanna stick your diffent config types into subtables it will organize them. probably don't wanna use more than 2 per item though.
    SS_PreviewPane:ClearProperties()
    SS_PreviewPane.CurrentGizmoID = nil

    local function cleanbonename(bn)
        return bn:Replace("ValveBiped.Bip01_", ""):Replace("L_", "Left "):Replace("R_", "Right "):Replace("Lrig", ""):Replace("_LEG_", "")
    end

    local item = self.item
    local configtable = table.Copy(self.item.configurable)
    local itemdef = table.Copy(SS_Items[self.item.class].configurable)
    table.Merge(configtable, itemdef)

    local deval = {
        pos = Vector(),
        ang = Angle(),
        scale = Vector(1, 1, 1),
        bone = LocalPlayer():GetBoneName(0),
        wear = {},
    }

    for k, v in pairs(configtable) do
        local section_name = "default"
        local initkey = k

        if (k == "wear") then
            initkey = "wear" .. suffix
        end

        if (deval[k]) then
            initkey = k .. suffix
        end

        self:AddSection(section_name)

        --SS_PreviewPane.SelectButton:SetEnabled(item.eq)
        if (k == "wear") then
            for k2, v2 in pairs(v) do
                if (istable(v2)) then
                    if (v2.gizmo) then
                        SS_PreviewPane:AddGizmoProperty(v2.gizmo, {initkey, k2}, v2, (v2.label or v2.gizmo))
                    end

                    if (v2.choices) then
                        SS_PreviewPane:AddChoiceProperty(v2.choices, {initkey, k2}, v2, (v2.label or k2))
                    end
                end
            end

            continue
        end

        if (istable(v) and v.gizmo) then
            SS_PreviewPane:AddGizmoProperty(v.gizmo, {initkey}, v, (v.label or v.gizmo or k))
        end

        if (k == "bone") then
            local choices = {}

            for x = 0, (LocalPlayer():GetBoneCount() - 1) do
                local bn = LocalPlayer():GetBoneName(x)
                local cleanname = cleanbonename(bn)

                if cleanname ~= "__INVALIDBONE__" then
                    choices[bn] = cleanname
                end
            end

            table.sort(choices, function(a, b) return a > b end)

            SS_PreviewPane:AddChoiceProperty(choices, {initkey}, istable(v) and v or {}, (istable(v) and v.label or "Bone"))
        end

        if (k == "submaterial") then
            local choices = {}

            for x = 0, math.min(31, (#(LocalPlayer():GetMaterials()) - 1)) do
                local matname = LocalPlayer():GetMaterials()[x + 1] or ""
                local exp = string.Explode("/", matname)
                local nicename = exp[#exp]
                choices[x] = tostring(x) .. " (" .. nicename .. ")"
            end

            SS_PreviewPane:AddChoiceProperty(choices, {initkey}, istable(v) and v or {}, (istable(v) and v.label or "Submaterial"))
        end

        if (k == "color") then
            self:AddColorOption(section_name, {initkey}, istable(v) and v.label or "Color")
        end

        if (k == "imgur") then
            self:AddImgurOption(section_name, {initkey}, istable(v) and v.label or "Custom Texture")
        end
    end

    local itmcw = self.item.configurable.wear
    self:AddSection("default")
    local rawzone = Container(self.Sections["default"], "Raw Data")
    rawzone:SetExpanded(false)
    rawzone:OnToggle(false)
    RAWENTRY = vgui.Create("DTextEntry", rawzone)
    RAWENTRY:SetMultiline(true)
    RAWENTRY:SetTall(256)
    RAWENTRY:Dock(FILL)
    RAWENTRY:SetPaintBackground(false)
    RAWENTRY:SetTextColor(MenuTheme_TX)
    RAWENTRY:SetEditable(true)
    RAWENTRY:SetKeyboardInputEnabled(true)
    RAWENTRY.BasedPaint = RAWENTRY.Paint

    RAWENTRY.Paint = function(pnl, w, h)
        --RAWENTRY:BasedPaint(w,h)
        SS_PaintBG(pnl, w, h)
        pnl:DrawTextEntryText(MenuTheme_TX, Color(128, 128, 128, 128), MenuTheme_TX)
    end

    RAWENTRY.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
        pnl:SetCursorColor(MenuTheme_TX)
    end

    RAWENTRY.PerformLayout = function(pnl)
        pnl:SizeToContentsY()
        pnl:InvalidateParent(true)
    end

    RAWENTRY.OnValueChange = function(textself, new)
        textself:InvalidateLayout(true)

        if not textself.RECIEVE then
            self.item.cfg = util.JSONToTable(new) or {}
            self:UpdateCfg(true) -- TODO: sanitize input like on the server
        end
    end

    RAWENTRY:SetUpdateOnType(true)
    --RAWENTRY:SetValue("unset") --(self.item.cfg.imgur or {}).url or "")
    self:UpdateCfg()
end

concommand.Add("CleanUp", function()
    for k, v in pairs(vgui.GetWorldPanel():GetChildren()) do
        if (v:GetName() == "SwampChat") then continue end
        if (v:GetName() == "GModMouseInput") then continue end
        if (v:GetName() == "DMenuBar") then continue end
        v:Remove()
    end
end)

function ImageHistoryPanel(button, textentry)
    if IsValid(SS_CustTextureHistory) then
        SS_CustTextureHistory:Remove()

        return
    end

    local sz = 512
    local Menu = DermaMenu()
    local container = Container(nil, "Saved Textures", true)
    container.Paint = noop
    container:SetSize(512, 512)
    Menu:AddPanel(container)
    local textures = vgui.Create("DImgurManager", container)
    textures:SetTextEntry(textentry)
    textures:Dock(TOP)
    textures:SetTall(256)
    textures:SetSize(512, 512)

    Menu.Paint = function(pnl, w, h)
        DisableClipping(true)
        local border = 8
        draw.BoxShadow(-2, -2, w + 4, h + 4, border, 1)
        DisableClipping(false)
        SS_PaintBG(pnl, w, h)
    end

    SS_CustTextureHistory = Menu
    textures:SetColumns(4)
    textures:Load()
    local img = SS_CustomizerPanel.TextureBar:GetText()
    textures.AddField:SetText(img)
    local x, y = button:LocalToScreen(button:GetWide() + SS_COMMONMARGIN, 0)
    Menu:Open(x, y)
    Menu.BaseLayout = Menu.PerformLayout

    Menu.PerformLayout = function(pnl, w, h)
        Menu.BaseLayout(pnl, w, h)
        local x, y = pnl:GetPos()
        x = math.Clamp(x, 0, ScrW() - w)
        y = math.Clamp(y, 0, ScrH() - h)
        Menu:SetPos(x, y)
    end
end

function ImageGetterPanel()
    if (IsValid(SS_TextureDownloadWindow)) then
        SS_TextureDownloadWindow:Remove()
    end

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
        SS_TextureDownloadWindow = Frame
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
            Frame:SetTitle("Downloading...")

            SS_DownloadTexture(Material(mat), function(fname, data)
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

        local img = vgui.Create("DPointshopTexture", Frame)
        img:Dock(FILL)
    else
        LocalPlayerNotify("Couldn't find the material, sorry.")
    end
end

function PANEL:UpdateCfg(skiptext)
    local ply = LocalPlayer()
    if (not self.item) then return end
    _SS_SanitizeConfig(self.item)
    SS_ShopAccessoriesClean = nil

    if IsValid(RAWENTRY) and not skiptext then
        RAWENTRY.RECIEVE = true
        RAWENTRY:SetValue(util.TableToJSON(self.item.cfg, true))
        RAWENTRY.RECIEVE = nil
    end
end

vgui.Register('DPointShopCustomizer', PANEL, 'DPanel')