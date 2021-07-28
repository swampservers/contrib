-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA



local PANEL = {}

function PANEL:Close()

    if(!IsValid(SS_ShopMenu))then
        self:SetVisible(false)
        return
    end
    if IsValid(SS_PopupPanel) and IsValid(SS_ShopMenu) then
        SS_ShopMenu:SetParent()
        SS_PopupPanel:Remove()
        SS_ShopMenu:SetKeyboardInputEnabled(false)
    end
    SS_DescriptionPanel:SetVisible(true)

    SS_PreviewPane:SizeTo(SS_RPANEWIDTH,-1,0.2)

    self.item = nil
    if(SS_ShopMenu.InventoryButtons)then
         
    local cat = SS_ShopMenu.InventoryButtons[SS_ShopMenu.LastCategory or "Cosmetics"]
    if(cat)then
        cat:OnActivate()
    end
    end

    SS_PreviewPane.ControlContainer:SizeTo(-1,0,0.2)
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
    if(self.Sections[name])then
        return self.Sections[name]
    end
    local sect = vgui.Create("DScrollPanel",self.controlzone)

    sect:Dock(LEFT)
        sect:DockMargin(0, 0, SS_COMMONMARGIN, 0)
        sect.VBar:DockMargin(SS_COMMONMARGIN, 0, SS_COMMONMARGIN, 0)
        SS_SetupVBar(sect.VBar)
        sect.VBar:SetWide(SS_SCROLL_WIDTH)
        sect.BasedLayout = sect.PerformLayout
        sect.PerformLayout = function(pnl)
        pnl:BasedLayout()
        if(pnl:GetDock() != FILL)then pnl:SetWide(SS_GetMainGridDivision(math.max(table.Count(self.Sections) or 1,2))) end


        end

    self.Sections[name] = sect
    for k,v in pairs(self.Sections)do
        v:Dock(k == name and table.Count(self.Sections) > 1 and FILL or LEFT)
        sect:DockMargin(0, 0, k == name and SS_COMMONMARGIN or 0, 0)
        
    end



    return self.Sections[name]
end

local function Container(parent,label)

    local pane = vgui.Create("DCollapsibleCategory", parent)
    pane:Dock(TOP)
    pane:SetTall(256)
    pane:DockMargin(0, 0, 0, 0)
    pane:DockPadding(SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN, SS_COMMONMARGIN)
    pane.BasedPerformLayout = pane.PerformLayout
    pane.Paint = SS_PaintFG
    pane.PerformLayout = function(pnl)
        pnl:SizeToChildren(false, true)
        --pnl:InvalidateParent(true)
        pnl:DockMargin(0, 0, pnl:GetParent():GetParent().VBar:IsVisible() and SS_COMMONMARGIN or 0, SS_COMMONMARGIN)
        pnl:BasedPerformLayout(pnl:GetWide(), pnl:GetTall())
    end
    pane:SetLabel(label)
    pane.Header:SetFont("SS_DESCINSTFONT")
    pane.Header:SetContentAlignment(8)
    pane.Header:SetTall(28)

    pane.Header.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
    end
    pane.Paint = function(pnl,w,h)
        SS_PaintFG(pnl,w,h)

        local y = pnl.Header:GetTall()
        surface.SetDrawColor(MenuTheme_BG)
        surface.DrawRect(2,y,w-4,1)

    end


    pane:SetExpanded(true)
    pane:SetKeyboardInputEnabled(true)

    local ExpandArrow = vgui.Create("DLabel",pane.Header)
    ExpandArrow:Dock(RIGHT)
    ExpandArrow:SetContentAlignment(9)

    ExpandArrow:SetFont('marlett')

    ExpandArrow:SetText("5")
    ExpandArrow.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
    end

    function pane:OnToggle( expanded )
        ExpandArrow:SetText(expanded and "5" or '6')
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
    if(!IsValid(parent))then
        parent = self:AddSection(section)
        ErrorNoHaltWithStack("container defined before section!!!! please fix this")
    end
    local pane = Container(parent,label)
    return pane
end


--read tab is configurable
--write tab is .cfg.
function PANEL:AddVectorOption(section,read_tab,write_tab,writeprop,label)
    print("Property:"..writeprop)
    assert(writeprop != nil ,"No property for VectorOption")
    local suffix = self.WEARSUFFIX
    
    local options = read_tab

        local pane = self:AddContainer(section, label)
        local translate = write_tab and write_tab[writeprop] or Vector(0, 0, 0)
        pane.XSlider = SliderMaker(pane, "X (Along)")
        pane.XSlider:SetMinMax(read_tab.min.x, read_tab.max.x)
        pane.XSlider:SetValue(translate.x)
        pane.YSlider = SliderMaker(pane, "Y")
        pane.YSlider:SetMinMax(read_tab.min.y, read_tab.max.y)
        pane.YSlider:SetValue(translate.y)
        pane.ZSlider = SliderMaker(pane, "Z")
        pane.ZSlider:SetMinMax(read_tab.min.z, read_tab.max.z)
        pane.ZSlider:SetValue(translate.z)

        local function UpdateTransform(pnl)
       
            if read_tab then
                write_tab[writeprop]:Set( Vector(pane.XSlider:GetValue(), pane.YSlider:GetValue(), pane.ZSlider:GetValue()) )
            end
            PrintTable(self.item)
            --self:UpdateCfg()
        end


        pane.XSlider.OnValueChanged = UpdateTransform
        pane.YSlider.OnValueChanged = UpdateTransform
        pane.ZSlider.OnValueChanged = UpdateTransform
end

function PANEL:AddAngleOption(section,read_tab,write_tab,writeprop,label)
    local suffix = self.WEARSUFFIX
    
    local options = read_tab

        local pane = self:AddContainer(section, label)
        local rotate = write_tab and write_tab[writeprop] or Angle(0, 0, 0)
        pane.PitchSlider = SliderMaker(pane, "Pitch")
        pane.PitchSlider:SetMinMax(-180, 180)
        pane.PitchSlider:SetValue(rotate.p)
        pane.YawSlider = SliderMaker(pane, "Yaw")
        pane.YawSlider:SetMinMax(-180, 180)
        pane.YawSlider:SetValue(rotate.y)
        pane.RollSlider = SliderMaker(pane, "Roll")
        pane.RollSlider:SetMinMax(-180, 180)
        pane.RollSlider:SetValue(rotate.r)
        local function UpdateTransform(pnl)
       
            if read_tab then
                write_tab[writeprop]:Set( Angle(pane.PitchSlider:GetValue(), pane.YawSlider:GetValue(), pane.RollSlider:GetValue()) )
            end
            PrintTable(self.item)
            --self:UpdateCfg()
        end
        pane.PitchSlider.OnValueChanged = UpdateTransform
        pane.YawSlider.OnValueChanged = UpdateTransform
        pane.RollSlider.OnValueChanged = UpdateTransform
end


function PANEL:AddColorOption(section,read_tab,write_tab,writeprop,label)
    local suffix = self.WEARSUFFIX
    
    local options = read_tab

        local pane = self:AddContainer(section, label)
        
        local cv = Vector()
        cv:Set(write_tab[writeprop] or Vector(1, 1, 1))
        local cvm = math.max(1, cv.x, cv.y, cv.z)
        local PSCMixer = vgui.Create("DColorMixer", pane)
        PSCMixer:SetPalette(true)
        PSCMixer:SetAlphaBar(false)
        PSCMixer:SetWangs(true)
        PSCMixer:SetVector(cv / cvm)
        PSCMixer:SetTall(250)
        PSCMixer:DockMargin(0, 0, 0, 0)
        PSCMixer:Dock(TOP)
        local PSBS = SliderMaker(pane, "Boost")
        PSBS:SetMinMax(1, read_tab.max)
        PSBS:SetValue(cvm)
        PSBS:DockMargin(0, SS_COMMONMARGIN, 0, SS_COMMONMARGIN)

        local function colorchanged()
            write_tab[writeprop] = PSCMixer:GetVector() * PSBS:GetValue()
            self:UpdateCfg()
        end

        PSCMixer.ValueChanged = colorchanged
        PSBS.ValueChanged = colorchanged
        
end

function PANEL:AddImgurOption(section,read_tab,write_tab,writeprop,label)
    local suffix = self.WEARSUFFIX
    
    local options = read_tab

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
    texturebar:SetText(write_tab and write_tab[writeprop] or "")

    texturebar.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
        pnl:SetCursorColor(MenuTheme_TX)
    end

    texturebar.OnValueChange = function(textself, new)

        write_tab[writeprop] = new and {
            url = new,
            nsfw = nsfw
        } or nil

        self:UpdateCfg()
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

        ImageHistoryPanel(pnl)
    end
end







function PANEL:AddSelectionOption(section,tab,key,property)
    local parent = self.Sections[section]
    local pane = Container(parent, "Attachment")
    local cnt = vgui.Create("DPanel", pane)
    cnt:Dock(TOP)
    cnt:SetTall(24)
    cnt.Paint = noop
    ATTACHSELECT = vgui.Create("DComboBox", cnt)
    ATTACHSELECT:SetValue((self.item.cfg[self.wear] or {}).attach or (pone and (self.item.wear.pony or {}).attach) or self.item.wear.attach)

    for k, v in pairs(SS_Attachments) do
        ATTACHSELECT:AddChoice(k)
    end

    ATTACHSELECT:SetTall(32)
    ATTACHSELECT:Dock(FILL)
    ATTACHSELECT.Paint = SS_PaintBG

    ATTACHSELECT.UpdateColours = function(pnl)
        pnl:SetTextStyleColor(MenuTheme_TX)
        pnl:SetTextColor(MenuTheme_TX)
    end

    p = vgui.Create("DLabel", cnt)
    p:Dock(LEFT)
    p:SetText("Attach to")

    p.UpdateColours = function(pnl)
        pnl:SetTextColor(MenuTheme_TX)
    end

    ATTACHSELECT.OnSelect = function(panel, index, value)
        self.item.cfg[self.wear] = self.item.cfg[self.wear] or {}
        self.item.cfg[self.wear].attach = value
        self:UpdateCfg()
    end


end





function PANEL:Open(item)
    for k, v in pairs(self:GetChildren()) do
        v:Remove()
    end


    local wid = SS_MENUWIDTH - SS_GetMainGridDivision(2) - SS_COMMONMARGIN*3
    SS_PreviewPane:SizeTo(wid,-1,0.2)
    SS_DescriptionPanel:SetVisible(false)
    

    for k, v in pairs(SS_ShopMenu.InventoryButtons) do
        v:SetActive(false)
        v:OnDeactivate()
    end

    self.item = item
    
    self.wear = LocalPlayer():IsPony() and "wear_p" or "wear_h"

    if IsValid(SS_PopupPanel) then
        SS_ShopMenu:SetParent()
        SS_PopupPanel:Remove()
    end
    SS_PreviewPane.ControlContainer:SizeTo(-1,32,0.2)
    SS_ShopMenu:MakePopup()
    --SS_PaintTileBG
    self.Paint = noop

    --.Paint = SS_PaintGridBG
    --.Paint = SS_PaintTileBG
    SS_PopupPanel = vgui("DFrame", function(p)
        p:SetPos(0, 0)
        p:SetSize(ScrW(), ScrH())
        p:SetDraggable(false)
        p:ShowCloseButton(true)
        p:SetTitle("")
        p:RequestFocus()
        p.Paint = function() end
        p:SetParent(SS_PopupPanel)
    end)

    self:SetVisible(true)

    -- SS_InventoryPanel:SetVisible(false)
    --main panel
    vgui("DPanel", self, function(p)
        p.Paint = noop
        p:Dock(FILL)
        p:DockMargin(0, SS_COMMONMARGIN, 0, SS_COMMONMARGIN)

        self.controlzone = vgui("DPanel", function(p)
            p:Dock(FILL)
            p:DockMargin(0, 0, 0, 0)
            p.Paint = noop
            
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

                p.UpdateColours = function(pnl)
                    pnl:SetTextColor(MenuTheme_TX)
                end

                p:SetColor(SS_SwitchableColor)
                p:SetContentAlignment(5)
                p:SizeToContents()
                p:DockMargin(8, 8, 8, 10)
                p:Dock(TOP)
            end)

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


            
        end)

        --bottom panel
        vgui("DPanel", function(p)
            p.Paint = function() end
            p:SetTall(SS_CUSTOMIZER_HEADINGSIZE)
            p:Dock(BOTTOM)

            vgui("DButton", function(p)
                p:SetText("Reset")
                p:SetFont("SS_DESCTITLEFONT")
                p:SetWide(SS_GetMainGridDivision(6))
                p:DockMargin(0, SS_COMMONMARGIN, SS_COMMONMARGIN, 0)
                p:Dock(LEFT)
                p.Paint = SS_PaintButtonBrandHL

                p.UpdateColours = function(pnl)
                    pnl:SetTextStyleColor(MenuTheme_TX)
                end

                p.DoClick = function(butn)
                    self.item.cfg = {}
                    self:UpdateCfg()
                    self:SetupControls(self.controlzone)
                end
            end)

            vgui("DButton", function(p)
                p:SetText("Cancel")
                p:SetFont("SS_DESCTITLEFONT")
                p:SetWide(SS_GetMainGridDivision(6))
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

--gets a value nested into tables using a table of keys. Should be writable?
function GetTableNested(tab, keys )
    local val = tab
    local sstring = ""
    for i,v in ipairs(keys) do
        assert(val[v] , "Nested Table Search Fail at "..sstring)
        val = val[v]
        sstring = sstring .. "["..tostring(v).."("..type(v)..")]"
    end
    print(sstring)
    return val
end


BANANA = {ASS = {SHIT = {DIE = 4}}}


function PANEL:SetupControls()
    for k, v in pairs(self.controlzone:GetChildren()) do
        v:Remove()
    end
    local pone = LocalPlayer():IsPony()
    self.item.applied_cfg = table.Copy(self.item.cfg)
    local suffix = pone and "_p" or "_h"
    local sufname = pone and "Pony" or "Human"
    local parsufname = "("..sufname..")"
    self.WEARSUFFIX = suffix

    self.Sections = {}

    --quick little hack, if you wanna stick your diffent config types into subtables it will organize them. probably don't wanna use more than 2 per item though.
   

    for k,v in pairs(self.item.configurable)do
        local sname = "default"
        if(k == "wear")then sname = k end 

        if(k == "wear")then sname = "wear"..suffix end 

        self:AddSection(sname)
        
        local ignore = {
                pos = true,
                ang = true,
                scale = true,
            }
            if(ignore[k])then continue end

        if(k == "wear")then

            self.item.cfg[k..suffix] =  self.item.cfg[k..suffix] or {}
            for k2,v2 in pairs(v)do
                if(ignore[k2])then continue end
                self.item.cfg[k..suffix][k2] = self.item.cfg[k..suffix][k2] or k2 == "ang" and Angle() or k2 == "scale" and Vector(1,1,1) or Vector(0,0,0)
                if(k2 == "pos")then 
                    self:AddVectorOption(sname,self.item.configurable.wear[k2],self.item.cfg[k..suffix],k2,"Offset"..parsufname) 
                    self:AddAngleOption(sname,self.item.configurable.wear["ang"],self.item.cfg[k..suffix],"ang","Rotate"..parsufname)

                    
                end
                if(k2 == "scale")then 
                    self:AddVectorOption(sname,self.item.configurable.wear[k2],self.item.cfg[k..suffix],k2,"Scale"..parsufname,true)
                
                end
                
            end
        else
            self.item.cfg[k..suffix] = self.item.cfg[k..suffix] or k == "ang" and Angle() or k == "scale" and Vector(1,1,1) or Vector(0,0,0)
            
            if(k == "pos")then 
        
                self:AddVectorOption(sname,self.item.configurable[k],self.item.cfg,k..suffix,"Offset"..parsufname)
            end
            if(k == "scale")then self:AddVectorOption(sname,self.item.configurable[k],self.item.cfg,k..suffix,"Scale"..parsufname,true) end
            if(k == "rotate")then self:AddAngleOption(sname,self.item.configurable[k],self.item.cfg,k..suffix,"Rotate"..parsufname) end
            
            if(k == "color")then self:AddColorOption(sname,self.item.configurable[k],self.item.cfg,k,istable(v) and v.label or "Color") end
            if(k == "imgur")then self:AddImgurOption(sname,self.item.configurable[k],self.item.cfg[k],"url",istable(v) and v.label or "Custom Texture") end


        end 

    end

    



    
    local itmcw = self.item.configurable.wear
    --[[[
    if (self.item.configurable or {}).wear then
        --LabelMaker(wearzone, "Position (" .. (pone and "pony" or "human") .. ")", true)

        local pane = Container(wear_container, "Offset")
        local translate = (self.item.cfg[self.wear] or {}).pos or (pone and (self.item.wear.pony or {}).translate) or self.item.wear.translate
        XSL = SliderMaker(pane, "Forward/Backward")
        XSL:SetMinMax(itmcw.pos.min.x, itmcw.pos.max.x)
        XSL:SetValue(translate.x)
        YSL = SliderMaker(pane, "Left/Right")
        YSL:SetMinMax(itmcw.pos.min.y, itmcw.pos.max.z)
        YSL:SetValue(translate.y)
        ZSL = SliderMaker(pane, "Up/Down")
        ZSL:SetMinMax(itmcw.pos.min.z, itmcw.pos.max.z)
        ZSL:SetValue(translate.z)
        local pane = Container(wear_container, "Angle")
       
        local pane = Container(wear_container, "Scale")
        local scale = (self.item.cfg[self.wear] or {}).scale or (pone and (self.item.wear.pony or {}).scale) or self.item.wear.scale

        if isnumber(scale) then
            scale = Vector(scale, scale, scale)
        end

        SXSL = SliderMaker(pane, "Length")
        SXSL:SetMinMax(itmcw.scale.min.x, itmcw.scale.max.x)
        SXSL:SetValue(scale.x)
        SYSL = SliderMaker(pane, "Width")
        SYSL:SetMinMax(itmcw.scale.min.y, itmcw.scale.max.y)
        SYSL:SetValue(scale.y)
        SZSL = SliderMaker(pane, "Height")
        SZSL:SetMinMax(itmcw.scale.min.z, itmcw.scale.max.z)
        SZSL:SetValue(scale.z)

        local function transformslidersupdate()
            self.item.cfg[self.wear] = self.item.cfg[self.wear] or {}
            self.item.cfg[self.wear].pos = Vector(XSL:GetValue(), YSL:GetValue(), ZSL:GetValue())
            self.item.cfg[self.wear].ang = Angle(XRSL:GetValue(), YRSL:GetValue(), ZRSL:GetValue())
            self.item.cfg[self.wear].scale = Vector(SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue())
            self:UpdateCfg()
        end

        XSL.OnValueChanged = transformslidersupdate
        YSL.OnValueChanged = transformslidersupdate
        ZSL.OnValueChanged = transformslidersupdate
        XRSL.OnValueChanged = transformslidersupdate
        YRSL.OnValueChanged = transformslidersupdate
        ZRSL.OnValueChanged = transformslidersupdate
        SXSL.OnValueChanged = transformslidersupdate
        SYSL.OnValueChanged = transformslidersupdate
        SZSL.OnValueChanged = transformslidersupdate
        SUSL = SliderMaker(pane, "Scale")
        SUSL:SetMinMax(math.max(itmcw.scale.min.x, itmcw.scale.min.y, itmcw.scale.min.z), math.min(itmcw.scale.max.x, itmcw.scale.max.y, itmcw.scale.max.z))

        SUSL.OnValueChanged = function(self)
            SXSL:SetValue(self:GetValue())
            SYSL:SetValue(self:GetValue())
            SZSL:SetValue(self:GetValue())
        end

        SUSL:SetVisible(false)
        local scalebutton = vgui.Create("DButton", pane)
        scalebutton:SetText("Use Uniform Scaling")
        scalebutton:SetWide(160)
        scalebutton:Dock(TOP)
        scalebutton.Paint = SS_PaintButtonBrandHL

        scalebutton.UpdateColours = function(pnl)
            pnl:SetTextStyleColor(MenuTheme_TX)
        end

        scalebutton.DoClick = function(btn)
            if btn.UniformMode then
                btn.UniformMode = nil
                btn:SetText("Use Uniform Scaling")
                SXSL:SetVisible(true)
                SYSL:SetVisible(true)
                SZSL:SetVisible(true)
                SUSL:SetVisible(false)
            else
                btn.UniformMode = true
                btn:SetText("Use Independent Scaling")
                SXSL:SetVisible(false)
                SYSL:SetVisible(false)
                SZSL:SetVisible(false)
                SUSL:SetVisible(true)

                local v = {SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue()}

                table.sort(v, function(a, b) return a > b end)
                SUSL:SetValue(v[2])
            end
        end

        if scale.x == scale.y and scale.y == scale.z then
            scalebutton:DoClick()
        end
    elseif (self.item.configurable or {}).bone then
        local pane = Container(wear_container, "Mod (" .. (LocalPlayer():IsPony() and "pony" or "human") .. ")")

        local function cleanbonename(bn)
            return bn:Replace("ValveBiped.Bip01_", ""):Replace("Lrig", ""):Replace("_LEG_", "")
        end

        ATTACHSELECT = vgui.Create("DComboBox", pane)
        ATTACHSELECT:SetValue(cleanbonename(self.item.cfg["bone" .. suffix] or (pone and "Scull" or "Head1")))
        ATTACHSELECT:SetTall(24)
        ATTACHSELECT:Dock(TOP)
        ATTACHSELECT.Paint = SS_PaintBG

        ATTACHSELECT.UpdateColours = function(pnl)
            pnl:SetTextStyleColor(MenuTheme_TX)
            pnl:SetTextColor(MenuTheme_TX)
        end

        for x = 0, (LocalPlayer():GetBoneCount() - 1) do
            local bn = LocalPlayer():GetBoneName(x)
            local cleanname = cleanbonename(bn)

            if cleanname ~= "__INVALIDBONE__" then
                ATTACHSELECT:AddChoice(cleanname, bn)
            end
        end

        ATTACHSELECT.OnSelect = function(panel, index, word, value)
            self.item.cfg["bone" .. suffix] = value
            self:UpdateCfg()
        end

        --bunch of copied shit
        --ADD SCALE CHECK HERE AAAAAA

        local itmcs = self.item.configurable.scale

        if itmcs then
            local pane = Container(wear_container, "Scale")
            local scale = self.item.cfg["scale" .. suffix] or Vector(1, 1, 1)

            if isnumber(scale) then
                scale = Vector(scale, scale, scale)
            end

            SXSL = SliderMaker(pane, "X (Along)")
            SXSL:SetMinMax(itmcs.min.x, itmcs.max.x)
            SXSL:SetValue(scale.x)
            SYSL = SliderMaker(pane, "Y")
            SYSL:SetMinMax(itmcs.min.y, itmcs.max.y)
            SYSL:SetValue(scale.y)
            SZSL = SliderMaker(pane, "Z")
            SZSL:SetMinMax(itmcs.min.z, itmcs.max.z)
            SZSL:SetValue(scale.z)
            SXSL.OnValueChanged = transformslidersupdate
            SYSL.OnValueChanged = transformslidersupdate
            SZSL.OnValueChanged = transformslidersupdate
            SUSL = SliderMaker(pane, "Scale")
            SUSL:SetMinMax(math.max(itmcs.min.x, itmcs.min.y, itmcs.min.z), math.min(itmcs.max.x, itmcs.max.y, itmcs.max.z))

            SUSL.OnValueChanged = function(self)
                SXSL:SetValue(self:GetValue())
                SYSL:SetValue(self:GetValue())
                SZSL:SetValue(self:GetValue())
            end

            SUSL:SetVisible(false)
            local scalebutton = vgui.Create("DButton", pane)
            scalebutton:SetText("Use Uniform Scaling")
            scalebutton:SetWide(160)
            scalebutton.Paint = SS_PaintButtonBrandHL
            scalebutton:Dock(TOP)

            scalebutton.UpdateColours = function(pnl)
                pnl:SetTextStyleColor(MenuTheme_TX)
            end

            scalebutton.DoClick = function(btn)
                if btn.UniformMode then
                    btn.UniformMode = nil
                    btn:SetText("Use Uniform Scaling")
                    SXSL:SetVisible(true)
                    SYSL:SetVisible(true)
                    SZSL:SetVisible(true)
                    SUSL:SetVisible(false)
                else
                    btn.UniformMode = true
                    btn:SetText("Use Independent Scaling")
                    SXSL:SetVisible(false)
                    SYSL:SetVisible(false)
                    SZSL:SetVisible(false)
                    SUSL:SetVisible(true)

                    local v = {SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue()}

                    table.sort(v, function(a, b) return a > b end)
                    SUSL:SetValue(v[2])
                end
            end

            if scale.x == scale.y and scale.y == scale.z then
                scalebutton:DoClick()
            end
        end

        --end bunch of copied shit
        if self.item.configurable.scale_children then
            CHILDCHECKBOX = CheckboxMaker(pane, "Scale child bones")
            CHILDCHECKBOX:SetValue(self.item.cfg["scale_children" .. suffix] and 1 or 0)

            CHILDCHECKBOX.OnChange = function(checkboxself, ch)
                self.item.cfg["scale_children" .. suffix] = ch
                self:UpdateCfg()
            end
        end
    elseif (self.item.configurable or {}).submaterial then
        local pane = Container(wear_container, "Skin ID")
        ATTACHSELECT = vgui.Create("DComboBox", pane)

        for x = 0, math.min(31, (#(LocalPlayer():GetMaterials()) - 1)) do
            local matname = LocalPlayer():GetMaterials()[x + 1] or ""
            local exp = string.Explode("/", matname)
            local nicename = exp[#exp]
            local sel = tonumber(self.item.cfg.submaterial or 0) == x
            ATTACHSELECT:AddChoice(tostring(x) .. " (" .. nicename .. ")", tostring(x), sel)
        end

        ATTACHSELECT.OnSelect = function(panel, index, word, value)
            self.item.cfg.submaterial = tonumber(value)
            self:UpdateCfg()
        end

        ATTACHSELECT:SetWide(200)
        ATTACHSELECT:Dock(TOP)
        ATTACHSELECT.Paint = SS_PaintBG

        ATTACHSELECT.UpdateColours = function(pnl)
            pnl:SetTextStyleColor(MenuTheme_TX)
            pnl:SetTextColor(MenuTheme_TX)
        end
    end

    
    local limit = self.item:CanCfgColor()

    if limit then
        local colorzone = Container(appearance_container, "Appearance")
        
    end

   ]]

  
   
    local rawzone =  Container(self.Sections["default"],"Raw Data")
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
    RAWENTRY.Paint = function(pnl,w,h)
        RAWENTRY:BasedPaint(w,h)
        
    SS_PaintBG(pnl,w,h)
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

local function TexDownloadHook()
    if (SS_REQUESTED_TEX and not SS_REQUESTED_TEX:IsError()) then
        local mat = SS_REQUESTED_TEX

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

        if (SS_REQUESTED_TEX_CALLBACK) then
            SS_REQUESTED_TEX_CALLBACK(fname, data)
        end
    else
        if (SS_REQUESTED_TEX_CALLBACK) then
            SS_REQUESTED_TEX_CALLBACK()
        end
    end

    SS_REQUESTED_TEX = nil
    SS_REQUESTED_TEX_CALLBACK = nil
    hook.Remove("PostRender", "SS_TexDownload")
end

hook.Remove("PostRender", "SS_TexDownload")
SS_REQUESTED_TEX = nil
SS_REQUESTED_TEX_CALLBACK = nil

local function DownloadTexture(mat, callback)
    SS_REQUESTED_TEX = mat
    SS_REQUESTED_TEX_CALLBACK = callback

    hook.Add("PostRender", "SS_TexDownload", function()
        TexDownloadHook()
    end)
end

concommand.Add("CleanUp", function()
    for k, v in pairs(vgui.GetWorldPanel():GetChildren()) do
        if (v:GetName() == "SwampChat") then continue end
        if (v:GetName() == "GModMouseInput") then continue end
        if (v:GetName() == "DMenuBar") then continue end
        v:Remove()
    end
end)

function ImageHistoryPanel(button)
    if IsValid(SS_CustTextureHistory) then
        SS_CustTextureHistory:Remove()

        return
    end

    local sz = 512
    local Menu = DermaMenu()
    local container = Container(nil, "Saved Textures")
    container.Paint = noop
    container:SetSize(512, 512)
    Menu:AddPanel(container)
    local textures = vgui.Create("DImgurManager", container)
    textures:SetMultiline(true)
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

    textures.OnChoose = function(pnl, img)
        SingleAsyncSanitizeImgurId(img, function(id)
            if not IsValid(pnl) then return end

            if (id) then
                SS_CustomizerPanel.TextureBar:SetText(id)
                textures.AddField:SetText(id)
            end

            SS_CustomizerPanel.item.cfg.imgur = id and {
                url = id,
                nsfw = false
            } or nil

            SS_CustomizerPanel:UpdateCfg()
        end)
    end

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
            Frame:SetTitle("Downloading...")

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

    if IsValid(RAWENTRY) and not skiptext then
        RAWENTRY.RECIEVE = true
        RAWENTRY:SetValue(util.TableToJSON(self.item.cfg, true))
        RAWENTRY.RECIEVE = nil
    end
end

vgui.Register('DPointShopCustomizer', PANEL, 'DPanel')
