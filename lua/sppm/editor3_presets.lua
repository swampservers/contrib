-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-----------------------------------------------------
PPM.reservedPresetNames = {}
PPM.Editor3_presets = PPM.Editor3_presets or {}

PPM.Editor3_presets["view_cmark"] = {
    spawn = function(parent, variable)
        local CONTAINER_FAKE = vgui.Create("DPanel", parent)
        CONTAINER_FAKE:SetSize(200, 200)
        CONTAINER_FAKE:Dock(TOP)
        local CONTAINER = vgui.Create("DPanel", parent:GetParent())
        CONTAINER:SetSize(200, 200)
        CONTAINER:Dock(TOP)
        local HEADER = vgui.Create("DImageButton", CONTAINER)
        HEADER:SetSize(200, 200)
        HEADER:SetColor(Color(0, 0, 0, 255))
        HEADER:SetImage("gui/editor/pictorect.png")
        HEADER:Dock(TOP)
        local IMAGER = vgui.Create("DImage", HEADER)
        IMAGER:SetSize(200, 200)
        --IMAGER:SetColor(Color(255,255,255,255))
        IMAGER:Dock(TOP)

        IMAGER.Think = function()
            --Mat:SetTexture("$basetexture",LocalPlayer().ponydata_tex.eyeltex)
            if LocalPlayer().ponydata.custom_mark then
                IMAGER:SetMaterial(PPM.m_cmark)
            else
                IMAGER:SetImage(PPM.m_cmarks[LocalPlayer().ponydata.cmark][1])
            end
        end
    end
}

--IMAGER:FixVertexLitMaterial()
PPM.Editor3_presets["view_eye"] = {
    spawn = function(parent, variable)
        local CONTAINER_FAKE = vgui.Create("DPanel", parent)
        CONTAINER_FAKE:SetSize(200, 200)
        CONTAINER_FAKE:Dock(TOP)
        local CONTAINER = vgui.Create("DPanel", parent:GetParent())
        CONTAINER:SetSize(200, 200)
        CONTAINER:Dock(TOP)
        local HEADER = vgui.Create("DImageButton", CONTAINER)
        HEADER:SetSize(200, 200)
        HEADER:SetColor(Color(0, 0, 0, 255))
        HEADER:SetImage("gui/editor/pictorect.png")
        HEADER:Dock(TOP)
        local IMAGER = vgui.Create("DImage", HEADER)
        IMAGER:SetSize(200, 200)
        --IMAGER:SetColor(Color(255,255,255,255))
        IMAGER:Dock(TOP)
        local Mat = CreateMaterial("tempeyematerialtest", "UnlitGeneric")

        IMAGER.Paint = function()
            render.SetMaterial(Mat)
            render.DrawQuadEasy(Vector(40 + 80, 100 + 80, 0), Vector(0, 0, -1), 160, 160, Color(255, 255, 255, 255), -90) --position of the rect --direction to face in --size of the rect --color --rotate 90 degrees
        end

        IMAGER.Think = function()
            Mat:SetTexture("$basetexture", LocalPlayer().ponydata_tex.eyeltex)
            IMAGER:SetMaterial(Mat)
        end
    end
}

--*/
--IMAGER:SetMaterial(PPM.m_eyel)
local WEARSLOTS = {}
local item_selection_panel = nil

function PPM_UpdateSlot(k, eqSlot)
    if eqSlot ~= nil and eqSlot ~= NULL then
        --MsgN(k,eqSlot.weareditem)
        eqSlot.weareditem = LocalPlayer().pi_wear[k]

        if (eqSlot.weareditem ~= nil) then
            --eqSlot.btn:SetTooltip( eqSlot.weareditem.name )  
            eqSlot:SetImage("gui/items/" .. eqSlot.weareditem.img .. ".png")
            eqSlot.namelabel:SetText(eqSlot.weareditem.name)
            PPM:pi_SetupItem(eqSlot.weareditem, PPM.editor_clothing, true)
            PPM:pi_SetupItem(eqSlot.weareditem, LocalPlayer())
        end
    end
end

function PPM_UpdateSlots()
    for k, eqSlot in pairs(WEARSLOTS) do
        PPM_UpdateSlot(k, eqSlot)
    end
end

function OpenItemMenu(slotid, container)
    local plymodel = "pony" --LocalPlayer():GetInfo( "cl_playermodel" )
    local avitems = PPM:GetAvailItems(plymodel, slotid)
    local posx, posy = container:LocalToScreen()

    --local paddx,paddy =container:GetParent():GetParent():GetPos() 
    --MsgN(posx,posy)
    if (item_selection_panel ~= nil) then
        item_selection_panel:Remove()
    end

    if avitems ~= nil then
        local PanelSelect = PPM.Editor3:Add("DPanelSelect")
        item_selection_panel = PanelSelect
        local xw = math.Clamp(table.Count(avitems), 1, 5) * 70
        PanelSelect:SetPos(posx, posy)
        PanelSelect:SetSize(5 * 70, 3 * 70)
        --PanelSelect:SetAlpha( 255)
        selection_box = PanelSelect

        for name, item in SortedPairs(avitems) do
            local icon = vgui.Create("DImageButton")
            icon:SetImage("gui/items/" .. item.img .. ".png")
            icon:SetSize(64, 64)
            icon:SetTooltip(item.name)

            icon.OnMousePressed = function()
                for i, slot in pairs(item.slot) do
                    LocalPlayer().pi_wear[slot] = item
                    --MsgN("set slot["..slot.."] = "..item.name)
                end

                if (item.issuit) then
                    PPM_UpdateLocalPonyCfg(item.varslot, item.wearid)
                end

                net.Start("player_equip_item")
                net.WriteFloat(item.id)
                net.SendToServer()
                PanelSelect.Remove(PanelSelect)
                PPM_UpdateSlots()
            end

            PanelSelect:AddPanel(icon, {})
        end
    end
end


local usedcolors = {}
local last = 1

function PPM_rgbtoHex(r, g, b)
    --[[
	local value = string.char(r)..string.char(g)..string.char(b)
	local index = usedcolors[value]
	local oldnumber = 0
	if index ==nil then
		usedcolors[value] = last
		oldnumber = last
		last = last + 1 
	else
		oldnumber = index
	end
	local nextnumber =math.floor(oldnumber/256)
	local prevnumber =oldnumber - nextnumber*256
	return string.char(nextnumber)..string.char(prevnumber)
	//]]
    return string.char(r) .. string.char(g) .. string.char(b)
end

-- THIS OPENS THE ITEM MENU
-- PPM.Editor3_presets["edit_equipment_slot"] = {
--     spawn = function(parent, variable)
--         local SLOTID = variable.slotid
--         local CONTAINER = vgui.Create("DPanel", parent)
--         CONTAINER:SetSize(70, 70)
--         CONTAINER:Dock(TOP)
--         local DISPLAY = vgui.Create("DImageButton", CONTAINER)
--         DISPLAY:SetPos(3, 3)
--         DISPLAY:SetSize(64, 64)
--         DISPLAY:SetColor(Color(255, 255, 255, 255))
--         DISPLAY:SetImage("gui/items/none.png")
--         WEARSLOTS[SLOTID] = DISPLAY
--         local DISPLAY_CASE = vgui.Create("DImageButton", CONTAINER)
--         DISPLAY_CASE:SetPos(0, 0)
--         DISPLAY_CASE:SetSize(70, 70)
--         DISPLAY_CASE:SetColor(Color(255, 255, 255, 255))
--         local plymodel = "pony" --LocalPlayer():GetInfo( "cl_playermodel" )
--         local avitems = PPM:GetAvailItems(plymodel, SLOTID)

--         if (avitems ~= nil and table.Count(avitems) > 0) then
--             DISPLAY_CASE:SetImage("gui/item.png")

--             DISPLAY_CASE.DoClick = function()
--                 OpenItemMenu(SLOTID, CONTAINER)
--             end
--         else
--             DISPLAY_CASE:SetImage("gui/editor/gui_cross.png")
--         end

--         --DISPLAY:Dock( TOP )
--         local HEADERLABEL = vgui.Create("DLabel", CONTAINER)
--         HEADERLABEL:SetPos(80, 10)
--         HEADERLABEL:SetColor(Color(20, 20, 20, 255))
--         HEADERLABEL:SetText(variable.name)
--         HEADERLABEL:SetFont(PPM.EDM_FONT)
--         HEADERLABEL:SetSize(100, 20)
--         local NAMELABEL = vgui.Create("DLabel", CONTAINER)
--         NAMELABEL:SetPos(80, 30)
--         NAMELABEL:SetColor(Color(20, 20, 20, 255))
--         NAMELABEL:SetText(variable.name)
--         --NAMELABEL:SetFont(PPM.EDM_FONT)
--         NAMELABEL:SetSize(100, 20)
--         DISPLAY.namelabel = NAMELABEL
--         PPM_UpdateSlot(SLOTID, DISPLAY)
--     end
-- }

PPM.Editor3_presets["select_custom_cmark"] = {
    spawn = function(parent, variable) end
}

PPM.Editor3_presets["edit_bool"] = {
    spawn = function(parent, variable)
        local CONTAINER = vgui.Create("DPanel", parent)
        CONTAINER:SetSize(200, 40)
        CONTAINER:Dock(TOP)
        local HEADER = vgui.Create("DImageButton", CONTAINER)
        HEADER:SetSize(200, 20)
        HEADER:SetColor(Color(0, 0, 0, 255))
        HEADER:SetImage("gui/editor/pictorect.png")
        HEADER:Dock(TOP)
        local HEADERLABEL = vgui.Create("DLabel", HEADER)
        --HEADERLABEL:Dock( TOP )
        HEADERLABEL:SetPos(80, 0)
        HEADERLABEL:SetText(variable.name)
        local SELECTOR = vgui.Create("DCheckBoxLabel", CONTAINER)
        SELECTOR:SetText(tostring(istable(variable) and variable.param or ""))
        --SELECTOR:SetSize( 100, 100 ) 
        SELECTOR:SetPos(20, 20)
        SELECTOR:Dock(FILL)
        SELECTOR:SetValue(LocalPlayer().ponydata[variable.param] == variable.onvalue)

        SELECTOR.OnChange = function(pSelf, fValue)

                PPM_UpdateLocalPonyCfg(variable.param, fValue and variable.onvalue or variable.offvalue)
                

        end
    end
}

PPM.Editor3_presets["edit_number"] = {
    spawn = function(parent, variable)
        local CONTAINER = vgui.Create("DPanel", parent)
        CONTAINER:SetSize(200, 40)
        CONTAINER:Dock(TOP)
        local HEADER = vgui.Create("DImageButton", CONTAINER)
        HEADER:SetSize(200, 20)
        HEADER:SetColor(Color(0, 0, 0, 255))
        HEADER:SetImage("gui/editor/pictorect.png")
        HEADER:Dock(TOP)
        local HEADERLABEL = vgui.Create("DLabel", HEADER)
        --HEADERLABEL:Dock( TOP )
        HEADERLABEL:SetPos(80, 0)
        HEADERLABEL:SetText(variable.name)
        local SELECTOR = vgui.Create("DNumSlider", CONTAINER)
        --SELECTOR:SetText("Value")
        SELECTOR:SetMin(variable.min)
        SELECTOR:SetMax(variable.max)
        --SELECTOR:SetSize( 100, 100 ) 
        SELECTOR:SetPos(20, 20)
        SELECTOR:Dock(FILL)
        SELECTOR:SetValue(LocalPlayer().ponydata[variable.param])

        SELECTOR.OnValueChanged = function()
            --local value =variable.min + SELECTOR:GetValue()*(variable.max-variable.min)
            PPM_UpdateLocalPonyCfg(variable.param, SELECTOR:GetValue())
        end
    end
}

PPM.Editor3_presets["edit_imgur_cmark"] = {
    spawn = function(parent, variable)
        local CONTAINER = vgui.Create("DPanel", parent)
        CONTAINER:SetSize(200, 170)
        CONTAINER:Dock(TOP)
        local HEADER = vgui.Create("DImageButton", CONTAINER)
        HEADER:SetSize(200, 20)
        HEADER:SetColor(Color(0, 0, 0, 255))
        HEADER:SetImage("gui/editor/pictorect.png")
        HEADER:Dock(TOP)
        local HEADERLABEL = vgui.Create("DLabel", HEADER)
        --HEADERLABEL:Dock( TOP )
        HEADERLABEL:SetPos(80, 0)
        HEADERLABEL:SetSize(120, 20)
        HEADERLABEL:SetText(variable.name)
        local DLabel = vgui.Create("DLabel", CONTAINER)
        DLabel:SetSize(120, 40)
        DLabel:DockMargin(8, 2, 8, 2)
        DLabel:Dock(TOP)
        DLabel:SetTextColor(Color(0, 0, 0, 255))
        DLabel:SetText("Paste an imgur URL here. Example:\nhttp://i.imgur.com/OMyCUd4.jpg")
        local TextEntry = vgui.Create("DTextEntry", CONTAINER)
        TextEntry:SetSize(75, 30)
        TextEntry:SetText(LocalPlayer().ponydata.imgurcmark or "")
        TextEntry:DockMargin(8, 0, 8, 4)
        TextEntry:Dock(TOP)
        local DermaButton = vgui.Create("DButton", CONTAINER)
        DermaButton:SetText("Set")
        DermaButton:SetSize(80, 30)
        DermaButton:Dock(TOP)

        DermaButton.DoClick = function()
            PPM_UpdateLocalPonyCfg('imgurcmark', SanitizeImgurId(TextEntry:GetValue()))
            --print("imgur cmark:"..LocalPlayer().ponydata.imgurcmark)
            TextEntry:SetValue(LocalPlayer().ponydata.imgurcmark)
        end

        local DermaButton = vgui.Create("DButton", CONTAINER)
        DermaButton:SetText("Remove")
        DermaButton:SetSize(80, 30)
        DermaButton:Dock(TOP)

        DermaButton.DoClick = function()
            PPM_UpdateLocalPonyCfg('imgurcmark', "")            
            TextEntry:SetValue("")
        end
    end
}

PPM.Editor3_presets["edit_color"] = {
    spawn = function(parent, variable)
        local VALUE = LocalPlayer().ponydata[variable.param] or Vector(1, 1, 1)
        local CONTAINER = vgui.Create("DPanel", parent)
        CONTAINER:SetSize(200, 220)
        CONTAINER:Dock(TOP)
        --local CONTAINER = vgui.Create("DCollapsibleCategory", parent)
        --CONTAINER:SetPos( 25,50 )
        --CONTAINER:SetSize( 200, 200 ) -- Keep the second number at 50
        --CONTAINER:SetExpanded( 200 ) -- Expanded when popped up
        --CONTAINER:SetLabel(variable.name)
        --CONTAINER:Dock( TOP )
        local HEADER = vgui.Create("DImageButton", CONTAINER)
        HEADER:SetSize(200, 20)
        HEADER:SetColor(Color(0, 0, 0, 255))
        HEADER:SetImage("gui/editor/pictorect.png")
        HEADER:Dock(TOP)
        local HEADERLABEL = vgui.Create("DLabel", HEADER)
        --HEADERLABEL:Dock( TOP )
        HEADERLABEL:SetPos(80, 0)
        HEADERLABEL:SetText(variable.name)
        local INDICATOR = vgui.Create("DImageButton", CONTAINER)
        INDICATOR:Dock(LEFT)
        INDICATOR:SetSize(20, 20)
        INDICATOR:SetImage("gui/editor/pictorect.png")
        local SELECTOR = vgui.Create("DColorMixer", CONTAINER)
        SELECTOR:SetSize(100, 100)
        SELECTOR:SetPos(20, 20)
        SELECTOR:SetAlphaBar(false)
        --[[
	local bCANCEL = vgui.Create( "DButton", sR )
	bCANCEL:SetSize( 20, 130 ) 
	bCANCEL:Dock( BOTTOM )
	bCANCEL:SetPos(0,0)
	bCANCEL:SetText( "C" )
	bCANCEL.DoClick = function( button ) 
		PanelSelect:SetColor(Color(color.x*255,color.y*255,color.z*255,255))
		PanelSelect.ValueChanged()
	end
	]]
        SELECTOR:SetColor(Color(VALUE.x * 255, VALUE.y * 255, VALUE.z * 255, 255))
        INDICATOR:SetColor(Color(VALUE.x * 255, VALUE.y * 255, VALUE.z * 255, 255))
        SELECTOR:Dock(FILL)

        SELECTOR.ValueChanged = function()
            local v2 = SELECTOR:GetVector()
            PPM_UpdateLocalPonyCfg(variable.param, v2)
            INDICATOR:SetColor(Color(v2.x * 255, v2.y * 255, v2.z * 255, 255))
        end
    end
}

PPM.Editor3_presets["edit_type"] = {
    spawn = function(parent, variable)
        local VALUE = LocalPlayer().ponydata[variable.param] or 0
        local CONTAINER = vgui.Create("DPanel", parent)
        CONTAINER:SetSize(200, 220)
        CONTAINER:Dock(TOP)
        local HEADER = vgui.Create("DImageButton", CONTAINER)
        HEADER:SetSize(200, 20)
        HEADER:SetColor(Color(0, 0, 0, 255))
        HEADER:SetImage("gui/editor/pictorect.png")
        HEADER:Dock(TOP)
        local HEADERLABEL = vgui.Create("DLabel", HEADER)
        --HEADERLABEL:Dock( TOP )
        HEADERLABEL:SetPos(80, 0)
        HEADERLABEL:SetText(variable.name)
        --[[
	local INDICATOR = vgui.Create("DImageButton",CONTAINER)
	INDICATOR:Dock( LEFT )
	INDICATOR:SetSize( 20, 20 ) 
	INDICATOR:SetImage( "gui/editor/pictorect.png" )
	]]
        --choises
        --[[
	local SELECTOR = vgui.Create( "DComboBox", CONTAINER )
	SELECTOR:SetPos( 10, 35 )
	SELECTOR:SetSize( 100, 185 )
	//SELECTOR:SetMultiple( false )
	
	 
	SELECTOR:Dock( TOP )
	if variable.choises !=nil then
		for k , v in pairs(variable.choises) do
			SELECTOR:AddChoice( v ) 
		end
		SELECTOR:ChooseOptionID(LocalPlayer().ponydata[variable.param] or 1)
		SELECTOR.OnSelect = function( panel, index, value, data ) 
			LocalPlayer().ponydata[variable.param] = index 
		end 
	end
	]]
        local SELECTOR = vgui.Create("DPanel", CONTAINER)
        SELECTOR:SetPos(10, 35)
        SELECTOR:SetSize(100, 185)
        SELECTOR:Dock(TOP)
        --[[
	SCROLL = vgui.Create( "DVScrollBar", SELECTOR )
	SCROLL:SetSize( 20, ScrH()-100) 
	SCROLL:SetUp(1000,2000)
	SCROLL:SetEnabled(true)
	SCROLL:Dock(RIGHT)
	]]
        local SELECTOR_INNER = vgui.Create("DPanel", SELECTOR)
        SELECTOR_INNER:SetPos(0, 0)
        SELECTOR_INNER:SetSize(200, 2000)
        SELECTOR.PerformLayout = function() end --SELECTOR_INNER:SetSize(200,2000) --PPM.CDVScrollBar:SetUp(1000,PPM.smenupanel_inner:GetTall()) --SELECTOR_INNER:SetPos(0,SCROLL:GetOffset()) 
        local VARIABLE = LocalPlayer().ponydata[variable.param] or 1
        SELECTOR.buttons = {}

        if variable.choises ~= nill then
            CONTAINER:SetSize(100, table.Count(variable.choises) * 20 + 20)
            SELECTOR:SetSize(100, table.Count(variable.choises) * 20)

            for k, v in pairs(variable.choises) do
                local ITEM_CONTAINER = vgui.Create("DPanel", SELECTOR_INNER)
                ITEM_CONTAINER:SetSize(100, 20)
                ITEM_CONTAINER:Dock(TOP)
                local ITEM_INDICATOR = vgui.Create("DImageButton", ITEM_CONTAINER)
                ITEM_INDICATOR:SetImage("gui/editor/pictorect.png")
                ITEM_INDICATOR:SetSize(20, 20)
                ITEM_INDICATOR:Dock(LEFT)
                SELECTOR.buttons[k] = ITEM_INDICATOR

                if (k == VARIABLE) then
                    ITEM_INDICATOR:SetColor(Color(200, 255, 200)) --PPM.colorcircles(k))
                else
                    ITEM_INDICATOR:SetColor(Color(100, 100, 100))
                end

                local ITEM = vgui.Create("DButton", ITEM_CONTAINER)
                ITEM:SetSize(200, 20)
                ITEM:SetBGColor(PPM.colorcircles(k))
                --ITEM:SetImage( "gui/editor/pictorect.png" )
                ITEM:Dock(FILL)
                ITEM:SetText(v)

                ITEM.OnCursorEntered = function()
                    PPM_UpdateLocalPonyCfg(variable.param, k)
                end

                ITEM.OnCursorExited = function()
                    PPM_UpdateLocalPonyCfg(variable.param, VARIABLE)
                end

                ITEM.DoClick = function()
                    VARIABLE = k
                    PPM_UpdateLocalPonyCfg(variable.param, VARIABLE)

                    for k2, v2 in pairs(variable.choises) do
                        if (k2 == VARIABLE) then
                            SELECTOR.buttons[k2]:SetColor(Color(200, 255, 200))
                        else
                            SELECTOR.buttons[k2]:SetColor(Color(100, 100, 100))
                        end
                    end
                end
            end
        end
    end
}

local INDICATOR_ONE = nil
local INDICATOR_TWO = nil

function NewPresetMenu(parent)
    if (curmenupanel ~= nil) then
        curmenupanel:Remove()
        curmenupanel = nil
    end

    local smenupanel = vgui.Create("DPanel", parent:GetParent())
    local x, y = 0, 0 -- parent:GetParent():GetPos()
    local px, py = 0, 0 --parent:GetPos()
    local w, h = parent:GetSize()
    smenupanel:SetSize(w, h * 3)
    smenupanel:SetPos(parent:GetPos())
    smenupanel:SetKeyboardInputEnabled(true)
    curmenupanel = smenupanel
    local nfNInput = vgui.Create("DTextEntry", smenupanel)
    nfNInput:SetText("NewFileName")
    nfNInput:SetSize(20, h)
    nfNInput:Dock(TOP)
    nfNInput:SetKeyboardInputEnabled(true)
    local bPSave = vgui.Create("DButton", smenupanel)
    bPSave:SetSize(20, h)
    bPSave:Dock(BOTTOM)
    bPSave:SetPos(0, 0)
    bPSave:SetText("SAVE")

    bPSave.DoClick = function(button)
        local selected_fname = nfNInput:GetValue()
        if (selected_fname == nil or string.Trim(selected_fname) == "") then return end --colorFlash(bPSave, 0.1, Color(200,0,0),Color(255,255,255)) --colorFlash(PPM.button_save, 0.1, Color(200,0,0),Color(255,255,255))
        if (table.HasValue(PPM.reservedPresetNames, selected_fname)) then return end --colorFlash(bPSave, 0.1, Color(200,0,0),Color(255,255,255)) --colorFlash(PPM.button_save, 0.1, Color(200,0,0),Color(255,255,255))
        PPM_Save(selected_fname)
        --colorFlash(PPM.button_save, 0.1, Color(0,200,0),Color(255,255,255))
        LoadFileList(PPM.dPresetList)
        smenupanel:Remove()
        curmenupanel = nil
    end

    local bExit = vgui.Create("DButton", smenupanel)
    bExit:SetSize(20, h)
    bExit:Dock(BOTTOM)
    bExit:SetPos(0, 0)
    bExit:SetText("CANCEL")

    bExit.DoClick = function(button)
        smenupanel:Remove()
        curmenupanel = nil
    end
end

function LoadFileList(CTL)
    CTL:Clear()
    local files = file.Find("data/ppm/*.txt", "GAME")

    for k, v in pairs(files) do
        if (not string.match(v, "*/_*", 0)) then
            CTL:AddLine(v)
        end
    end
end

function colorFlash(controll, time, color, defcolor)
    controll:SetColor(color)

    timer.Simple(time, function()
        controll:SetColor(defcolor)
    end)
end

PPM.Editor3_presets["menu_save_load"] = {
    spawn = function(parent, variable)
        local VALUE = LocalPlayer().ponydata[variable.param] or Vector(1, 1, 1)
        local CONTAINER = vgui.Create("DPanel", parent)
        CONTAINER:SetSize(200, 1000)
        CONTAINER:Dock(TOP)
        local INDICATOR = vgui.Create("DImageButton", CONTAINER)
        INDICATOR:Dock(LEFT)
        INDICATOR:SetSize(20, 1000)
        INDICATOR:SetImage("gui/editor/pictorect.png")
        local INDICATOR2 = vgui.Create("DImageButton", CONTAINER)
        INDICATOR2:Dock(RIGHT)
        INDICATOR2:SetSize(20, 1000)
        INDICATOR2:SetImage("gui/editor/pictorect.png")
        -- it begins ~_~
        INDICATOR_ONE = INDICATOR
        INDICATOR_TWO = INDICATOR2
        local dPresetList = vgui.Create("DListView")
        dPresetList:SetParent(CONTAINER)
        dPresetList:SetPos(0, 0)
        dPresetList:SetSize(ScrW() / 8, ScrH() * 1 / 2)
        dPresetList:SetMultiSelect(false)
        dPresetList:Dock(TOP)
        dPresetList:AddColumn("Preset list")
        PPM.dPresetList = dPresetList
        local bAddPreset = vgui.Create("DButton", CONTAINER)
        bAddPreset:SetSize(180, 30)
        bAddPreset:Dock(TOP)
        bAddPreset:SetText("New Preset")

        bAddPreset.DoClick = function(button)
            NewPresetMenu(bAddPreset)
        end

        local bDelPreset = vgui.Create("DButton", CONTAINER)
        local SPACE = vgui.Create("DImageButton", CONTAINER)
        local button_save = vgui.Create("DButton", CONTAINER)

        bDelPreset.goDef = function()
            if bDelPreset.bdel ~= nil then
                bDelPreset.bdel:Remove()
                bDelPreset.bdel = nil
            end

            bDelPreset:SetSize(180, 30)
            bDelPreset:Dock(TOP)
            bDelPreset:SetText("Delete")
            bDelPreset.sure = false
            button_save:SetSize(180, 30)
        end

        bDelPreset.goDef()

        bDelPreset.DoClick = function(button)
            local selline = dPresetList:GetSelectedLine()

            if (selline == nil) then
                colorFlash(INDICATOR_ONE, 0.1, Color(200, 0, 0), Color(0, 0, 0))
                colorFlash(INDICATOR_TWO, 0.1, Color(200, 0, 0), Color(0, 0, 0))
                bDelPreset.goDef()

                return
            end

            local selected_fname = dPresetList:GetLine(selline):GetColumnText(1)

            if (selected_fname == nil) then
                colorFlash(INDICATOR_ONE, 0.1, Color(200, 0, 0), Color(0, 0, 0))
                colorFlash(INDICATOR_TWO, 0.1, Color(200, 0, 0), Color(0, 0, 0))
                bDelPreset.goDef()

                return
            end

            if (table.HasValue(PPM.reservedPresetNames, selected_fname)) then
                colorFlash(INDICATOR_ONE, 0.1, Color(200, 0, 0), Color(255, 255, 255))
                colorFlash(INDICATOR_TWO, 0.1, Color(200, 0, 0), Color(255, 255, 255))

                return
            end

            if not bDelPreset.sure then
                bDelPreset:SetText("NO!")
                bDelPreset:SetSize(180, 15)
                bDelPreset.sure = true
                button_save:SetSize(180, 15)
                bDelPreset.bdel = vgui.Create("DButton", button_save)
                bDelPreset.bdel:SetSize(180, 15)
                bDelPreset.bdel:Dock(BOTTOM)
                bDelPreset.bdel:SetText("YES, DELETE!")

                bDelPreset.bdel.DoClick = function(button)
                    file.Delete("ppm/" .. selected_fname)
                    LoadFileList(PPM.dPresetList)
                    bDelPreset.goDef()
                end
            else
                bDelPreset.goDef()
            end
        end

        SPACE:Dock(TOP)
        SPACE:SetSize(180, 30)
        --INDICATOR:SetImage( "gui/editor/pictorect.png" )
        --/ part 2
        button_save:SetSize(180, 30)
        --button_save:SetImage( "gui/editor/group_circle.png" ) 
        button_save:SetText("SAVE")
        button_save:Dock(TOP)
        PPM.button_save = button_save

        button_save.DoClick = function(button)
            local selline = dPresetList:GetSelectedLine()

            if (selline == nil) then
                colorFlash(INDICATOR_ONE, 0.1, Color(200, 0, 0), Color(255, 255, 255))
                colorFlash(INDICATOR_TWO, 0.1, Color(200, 0, 0), Color(255, 255, 255))

                return
            end

            local selected_fname = dPresetList:GetLine(selline):GetColumnText(1)

            if (selected_fname == nil) then
                colorFlash(INDICATOR_ONE, 0.1, Color(200, 0, 0), Color(255, 255, 255))
                colorFlash(INDICATOR_TWO, 0.1, Color(200, 0, 0), Color(255, 255, 255))

                return
            end

            if (table.HasValue(PPM.reservedPresetNames, selected_fname)) then
                colorFlash(INDICATOR_ONE, 0.1, Color(200, 0, 0), Color(255, 255, 255))
                colorFlash(INDICATOR_TWO, 0.1, Color(200, 0, 0), Color(255, 255, 255))

                return
            end

            PPM_Save(selected_fname)
            colorFlash(INDICATOR_ONE, 0.1, Color(0, 200, 0), Color(255, 255, 255))
            colorFlash(INDICATOR_TWO, 0.1, Color(0, 200, 0), Color(255, 255, 255))
            LoadFileList(PPM.dPresetList)
        end

        local button_load = vgui.Create("DButton", CONTAINER)
        button_load:SetSize(180, 30)
        --button_load:SetImage( "gui/editor/group_circle.png" ) 
        button_load:Dock(TOP)
        button_load:SetText("LOAD")

        button_load.DoClick = function(button)
            local selline = dPresetList:GetSelectedLine()

            if (selline == nil) then
                colorFlash(INDICATOR_ONE, 0.1, Color(200, 0, 0), Color(255, 255, 255))
                colorFlash(INDICATOR_TWO, 0.1, Color(200, 0, 0), Color(255, 255, 255))

                return
            end

            local selected_fname = dPresetList:GetLine(selline):GetColumnText(1)

            if (selected_fname == nil) then
                colorFlash(INDICATOR_ONE, 0.1, Color(200, 0, 0), Color(255, 255, 255))
                colorFlash(INDICATOR_TWO, 0.1, Color(200, 0, 0), Color(255, 255, 255))

                return
            end

            --if(PPM.selected_filename==nil) then return end
            --if(PPM.selected_filename=="@NEWFILE@") then return end
            --PPM.ReadFile(PPM.selected_filename)  
            -- PPM.cleanPony(LocalPlayer())

            -- for k, v in pairs(addition) do
            --     destination[k] = v
            -- end

            PPM_Load(selected_fname)
            --PPM.SendCharToServer(LocalPlayer()) 
            colorFlash(INDICATOR_ONE, 0.1, Color(0, 200, 0), Color(255, 255, 255))
            colorFlash(INDICATOR_TWO, 0.1, Color(0, 200, 0), Color(255, 255, 255))
        end

        --colorFlash(PPM.selector_circle[3], 0.2, Color(0,200,0),Color(255,255,255))
        local SPACE2 = vgui.Create("DImageButton", CONTAINER)
        SPACE2:Dock(TOP)
        SPACE2:SetSize(180, 30)
        --part 3
        local button_reset = vgui.Create("DButton", CONTAINER)
        button_reset:SetSize(180, 30)
        button_reset:SetText("Clear")
        button_reset:Dock(TOP)

        button_reset.DoClick = function(button)
            -- PPM.cleanPony(LocalPlayer())
            colorFlash(INDICATOR_ONE, 0.1, Color(0, 200, 0), Color(255, 255, 255))
            colorFlash(INDICATOR_TWO, 0.1, Color(0, 200, 0), Color(255, 255, 255))
        end

        local button_rnd = vgui.Create("DButton", CONTAINER)
        button_rnd:SetSize(180, 30)
        button_rnd:SetText("Randomize")
        button_rnd:Dock(TOP)

        button_rnd.DoClick = function(button)
            PPM_Randomize()
            colorFlash(INDICATOR_ONE, 0.1, Color(0, 200, 0), Color(255, 255, 255))
            colorFlash(INDICATOR_TWO, 0.1, Color(0, 200, 0), Color(255, 255, 255))
        end

        LoadFileList(dPresetList)
    end
}