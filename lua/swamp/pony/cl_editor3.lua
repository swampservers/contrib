-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-----------------------------------------------------
if CLIENT then
    list.Set("DesktopWindows", "PPMitor3", {
        title = "Pony Editor v3",
        icon = "gui/pped_icon.png",
        width = 960,
        height = 700,
        onewindow = true,
        init = function(icon, window)
            window:Remove()
            PPM.Editor3Open()
        end
    })

    PPM.EDM_FONT = "TAHDS"

    surface.CreateFont(PPM.EDM_FONT, {
        font = "Arial",
        size = 15,
        weight = 2500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false
    })

    concommand.Add("ppm_chared3", function(ply)
        PPM.Editor3Open()
    end)

    PPM.Editor3 = nil
    PPM.Editor3_ponies = PPM.Editor3_ponies or {}
    PPM.Editor3_nodes = PPM.Editor3_nodes or {}
    PPM.Editor3_presets = PPM.Editor3_presets or {}
    PPM.E3_CURRENT_NODE = nil
    PPM.nodebuttons = {}

    function PPM.Editor3Open()
        CUR_LEFTPLATFORM_CONTROLLS = {}
        CUR_RIGHTPLATFORM_CONTROLLS = {}
        WEARSLOTSL = {}
        WEARSLOTSR = {}
        PPM.ed3_selectedNode = nil
        Me.pi_wear = Me.pi_wear or {}
        left_open = false
        left_isOpening = false
        right_open = false
        right_isOpening = false
        local window = vgui.Create("DFrame")
        window:ShowCloseButton(true)
        window:SetSize(ScrW(), ScrH())
        window:SetBGColor(255, 0, 0)
        window:SetVisible(true)
        window:SetDraggable(false)
        window:MakePopup()
        window:SetTitle("PPM Editor 3")

        window.Paint = function()
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, window:GetWide(), window:GetTall())
        end

        PPM.Editor3 = window
        window:SetKeyboardInputEnabled(true)
        local mdl = window:Add("DModelPanel")

        window.Close = function()
            PPM.editor3_clothing:Remove()
            PPM.editor3_pony:Remove()
            window:Remove()
            CUR_LEFTPLATFORM_CONTROLLS = {}
            CUR_RIGHTPLATFORM_CONTROLLS = {}
            WEARSLOTSL = {}
            WEARSLOTSR = {}
            left_open = false
            left_isOpening = false
            right_open = false
            right_isOpening = false
            PPM.Editor3 = nil
            -- mdl.backgroundmodel_sky:Remove()
            -- mdl.backgroundmodel_ground:Remove()
            mdl.backgroundmodel:Remove()
            ReloadCurrentPony() --the editor adjusts local ponydata, if they didnt save then reload their current
        end

        --[[
	local top = vgui.Create("DPanel",window)
	top:SetSize( 20, 20 ) 
	top:Dock( TOP )
	top.Paint = function() -- Paint function 
		surface.SetDrawColor( 50, 50, 50, 255 ) 
		surface.DrawRect( 0, 0, top:GetWide(), top:GetTall() )
	end
	]]
        PPM.faceviewmode = false
        --smenupanel:SetSize( w, h )  
        --smenupanel:SetPos(x+w,y)
        --smenupanel:SizeTo( fw, fh, 0.4, 0, 1) 
        --smenupanel:MoveTo( fx,fy, 0.4, 0, 1) 
        --PPM.smenupanel.Paint = function() -- Paint function 
        --surface.SetDrawColor( 0, 0, 0, 255 ) 
        --surface.DrawRect( 0, 0, PPM.smenupanel:GetWide(), PPM.smenupanel:GetTall() )
        --end
        --/////////////////////////////////////////////////////////
        PPM.modelview = mdl
        mdl:Dock(FILL)
        mdl:SetFOV(70)
        mdl:SetModel("models/ppm/player_default_base.mdl")
        mdl.camang = Angle(0, 70, 0)
        mdl.camangadd = Angle(0, 0, 0)
        local time = 0

        function mdl:LayoutEntity()
            -- PPM.copyLocalPonyTo(Me, self.Entity)
            PPM.editor3_pony = self.Entity
            self.Entity.isEditorPony = true

            if mdl.model2 == nil then
                mdl.model2 = ClientsideModel("models/ppm/player_default_clothes1.mdl", RENDER_GROUP_OPAQUE_ENTITY)
                mdl.model2:SetNoDraw(true)
                mdl.model2:SetParent(self.Entity)
                mdl.model2:AddEffects(EF_BONEMERGE)
                PPM.editor3_clothing = mdl.model2
            end

            -- if Me.pi_wear[50] ~= nil then
            --     self.Entity.ponydata.bodyt0 = Me.pi_wear[50].wearid or 1
            -- end
            PPM.editor3_pony:SetPoseParameter("move_x", 0)

            -- if Me.pi_wear ~= nil then
            --     for i, item in pairs(Me.pi_wear) do
            --         PPM.setBodygroupSafe(PPM.editor3_pony, item.bid, item.bval)
            --         PPM.setBodygroupSafe(mdl.model2, item.bid, item.bval)
            --     end
            -- end
            self.OnMousePressed = function()
                self.ismousepressed = true
                self.mdx, self.mdy = self:CursorPos()
                self:SetCursor("sizeall")
            end

            self.OnMouseReleased = function()
                self.ismousepressed = false
                self.camang = self.camang + self.camangadd
                self.camangadd = Angle(0, 0, 0)
                self:SetCursor("none")
            end

            --self:RunAnimation()
            self:SetAnimSpeed(0.5)
            self:SetAnimated(false)

            if PPM.faceviewmode then
                local attachmentID = self.Entity:LookupAttachment("eyes")
                local attachpos = self.Entity:GetAttachment(attachmentID).Pos + Vector(-10, 0, 3)
                self.vLookatPos = self.vLookatPos + (attachpos - self.vLookatPos) / 20
                mdl.fFOV = mdl.fFOV + (30 - mdl.fFOV) / 50
            else
                self.vLookatPos = self.vLookatPos + (Vector(0, 0, 25) - self.vLookatPos) / 20
                mdl.fFOV = mdl.fFOV + (70 - mdl.fFOV) / 50
            end

            if self.ismousepressed then
                local x, y = self:CursorPos()
                self.camangadd = Angle(math.Clamp(self.camang.p - y + self.mdy, -89, 13) - self.camang.p, -x + self.mdx, 0)
            end

            local camvec = (Vector(1, 0, 0) * 120)
            camvec:Rotate(self.camang + self.camangadd)
            self:SetCamPos(self.vLookatPos + camvec) --Vector(90,0,60))
            self.camvec = camvec
            time = time + 0.02
            PPM_SetBodyGroups(PPM.editor3_pony)
        end

        mdl.t = 0
        -- mdl.backgroundmodel_sky = ClientsideModel("models/ppm/decoration/skydome.mdl")
        -- mdl.backgroundmodel_sky:SetModelScale(25, 0)
        -- mdl.backgroundmodel_sky:SetAngles(Angle(0, 30, 0))
        -- mdl.backgroundmodel_ground = ClientsideModel("models/ppm/decoration/ground.mdl")
        -- mdl.backgroundmodel_ground:SetModelScale(5, 0)
        --mdl.backgroundmodel = ClientsideModel("models/ppm/decoration/building.mdl") 
        --mdl.backgroundmodel:SetModelScale( 25,0)
        --mdl.backgroundmodel:SetPos(Vector(0,0,-15))
        mdl.backgroundmodel = ClientsideModel("models/player/neckbeard.mdl")
        mdl.backgroundmodel.GetPlayerColor = function(ent) return Vector(0.2, 0.2, 0.2) end
        local scl = 1.2
        mdl.backgroundmodel:SetModelScale(5 * scl, 0)
        mdl.backgroundmodel:SetSequence(mdl.backgroundmodel:LookupSequence("idle_all_01"))
        mdl.backgroundmodel:SetAngles(Angle(0, -105, 0))
        local scl2 = 1.2
        mdl.backgroundmodel:SetPos(scl * Vector(32 * scl2, 100 * scl2, -300)) --Vector(-200,50,-600))

        -- mdl.backgroundmodel_ground:SetPos(Vector(0, 0, -15))
        --//////////////////////////////////
        mdl.Paint = function()
            if (not IsValid(mdl.Entity)) then return end
            local x, y = mdl:LocalToScreen(0, 0)
            mdl:LayoutEntity(mdl.Entity)
            -- PPM.PrePonyDraw(mdl.Entity, true)
            local ang = mdl.aLookAngle

            if not ang then
                ang = (mdl.vLookatPos - mdl.vCamPos):Angle()
            end

            local w, h = mdl:GetSize()
            cam.Start3D(mdl.vCamPos, ang, mdl.fFOV, x, y, w, h, 5, 4096)
            cam.IgnoreZ(false)
            render.Clear(219 * 0.85, 242 * 0.85, 255 * 0.85, 255, true, true)
            surface.SetMaterial(Material("gui/editor/group_circle.png"))
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(-30, -30, 30, 30)
            render.SuppressEngineLighting(true)
            render.SetLightingOrigin(mdl.Entity:GetPos())
            render.ResetModelLighting(mdl.colAmbientLight.r / 255, mdl.colAmbientLight.g / 255, mdl.colAmbientLight.b / 255)
            render.SetColorModulation(mdl.colColor.r / 255, mdl.colColor.g / 255, mdl.colColor.b / 255)
            render.SetBlend(mdl.colColor.a / 255)
            render.FogMode(MATERIAL_FOG_LINEAR)
            render.FogStart(0)
            render.FogEnd(3000)
            render.FogMaxDensity(0.5)
            render.FogColor(219, 242, 255)

            for i = 0, 6 do
                local col = mdl.DirectionalLight[i]

                if col then
                    render.SetModelLighting(i, col.r / 255, col.g / 255, col.b / 255)
                end
            end

            --mdl.backgroundmodel_sky:DrawModel()
            --mdl.backgroundmodel_ground:DrawModel()
            mdl.backgroundmodel:DrawModel()
            render.SetMaterial(Material("gui/editor/group_circle.png"))

            for k = 0, 10 do
                local div = (10 - k)
                local dim = 25 + 10 - k
                --render.SetBlend( k/10 )
                --render.SetColorModulation( k/10, k/10,k/10 )
                render.DrawQuad(Vector(-dim, -dim, -div), Vector(-dim, dim, -div), Vector(dim, dim, -div), Vector(dim, -dim, -div))
            end

            --local dim=50 
            --render.DrawQuad(Vector(-dim,-dim,-10), Vector(-dim,dim,-10), Vector(dim,dim,-10),Vector(dim,-dim,-10) )
            --local dim=25 
            --render.DrawQuad(Vector(-dim,-dim,0), Vector(-dim,dim,0), Vector(dim,dim,0),Vector(dim,-dim,0) )
            PPM_PrePonyDraw(mdl.Entity)
            mdl.Entity:DrawModel()
            mdl.model2:DrawModel()
            render.SuppressEngineLighting(false)
            --cam.IgnoreZ( false )
            cam.End3D()

            --[[
			local attachmentID=mdl.Entity:LookupAttachment("eyes");
			local attachpos =  mdl.Entity:GetAttachment(attachmentID).Pos
			mdl.t=mdl.t+0.01
			 local x,y, viz =	VectorToLPCameraScreen(((mdl.Entity:GetPos()+ attachpos)- mdl.camvec-mdl.vLookatPos):GetNormal( ), w, h, ang,math.rad( mdl.fFOV))
			 //local ww,hh =PPM.selector_circle[1]:GetSize( )
				if(viz) then
				 
					//PPM.selector_circle[1]:SetPos(x-ww/2,y-hh/2)
					local tt =4 
					surface.SetDrawColor( 255, 0, 0, 255 ) 
					surface.DrawRect( x,y, tt,tt )
				else
					//PPM.selector_circle[1]:SetPos(-ww,-hh)
				end
				//PPM.selector_circle[1]:Draw()
				]]
            if PPM.E3_CURRENT_NODE ~= nil and PPM.E3_CURRENT_NODE.name == nil then
                for k, v in pairs(PPM.E3_CURRENT_NODE) do
                    local x, y, viz = VectorToLPCameraScreen(((mdl.Entity:GetPos() + v.pos) - mdl.camvec - mdl.vLookatPos):GetNormal(), w, h, ang, math.rad(mdl.fFOV))
                    local tt = 50
                    local shift = 25
                    local RADIUS = 20
                    local RADIED = 25
                    x = x + shift
                    y = y + shift
                    local minim = math.min(x, y)
                    local tvpos = Vector(x - tt / 2 * 2, y - tt / 2)
                    local mousepos = Vector(input.GetCursorPos())
                    local dist = tvpos:Distance(mousepos) / 40
                    surface.SetDrawColor(255, 255, 255, 255)

                    if v == PPM.ed3_selectedNode then
                        if (false and x > ScrW() / 2) then
                            surface.DrawLine(x - tt / 2, y - tt / 2, x + minim, y - minim)
                            surface.SetDrawColor(255, 255, 255, 100)
                        else
                            local xc = x - minim + 50
                            local yc = y - minim + 50

                            if xc < 250 then
                                xc = 250
                            end

                            local xcwidth = 200
                            local direction = (Vector(x - tt / 2, y - tt / 2) - Vector(40 + xcwidth + tt / 4, 20 + tt / 4)):GetNormalized()
                            surface.DrawLine(x - tt / 2 - direction.x * RADIUS, y - tt / 2 - direction.y * RADIUS, 40 + xcwidth + tt / 4, 20 + tt / 4)
                            surface.SetDrawColor(155, 255, 255, 255)
                            surface.SetMaterial(Material("gui/editor/lid_str.png"))
                            surface.DrawTexturedRectRotated(40 + xcwidth, 20, tt, tt, 180)
                            surface.SetMaterial(Material("gui/editor/lid_mid.png"))
                            surface.DrawTexturedRectRotated(40 + xcwidth / 2, 20, xcwidth, tt, 180)
                            surface.SetMaterial(Material("gui/editor/lid_end.png"))
                            surface.DrawTexturedRectRotated(40, 20, tt, tt, 180)
                            local CK = string.upper(v.name)
                            surface.SetFont("TAHDS")
                            surface.SetTextPos(60 - tt / 2, 20)
                            surface.SetTextColor(100, 100, 100, 255)
                            surface.DrawText(CK)
                            surface.SetTextPos(60 - tt / 2 - 2, 20 - 2)
                            surface.SetTextColor(255, 255, 255, 255)
                            surface.DrawText(CK)
                        end

                        local tt = 50
                        surface.SetDrawColor(0, 255, 0, 80)
                        surface.SetMaterial(Material("gui/editor/lid_ind.png"))
                        surface.DrawTexturedRectRotated(x - RADIED, y - RADIED, RADIED * 2, RADIED * 2, 0)
                    else
                        surface.SetFont("TAHDS")
                        surface.SetTextPos(x - tt / 2 * 2 + 15, y - tt / 2 - 4)
                        surface.SetTextColor(30, 30, 30, 255)
                        surface.DrawText(v.name)
                        surface.SetTextPos(x - tt / 2 * 2 - 1 + 15, y - tt / 2 - 5)
                        surface.SetTextColor(255, 55 + (dist * 40), 155 + (dist * 20), 255)
                        surface.DrawText(v.name)
                    end

                    if IsValid(PPM.nodebuttons[k]) then
                        --local ww,hh = PPM.nodebuttons[k]:GetSize()
                        --PPM.nodebuttons[k]:SetAlpha(155/dist )
                        PPM.nodebuttons[k]:SetPos(x - tt / 2 - 20, y - tt / 2)
                        --MsgN(PPM.nodebuttons[k])
                    end
                end
            end

            mdl.LastPaint = RealTime()
        end

        --APPLY BUTTON
        local APPLY = vgui.Create("DImageButton", PPM.Editor3)
        APPLY:SetPos(ScrW() / 2 - 64, ScrH() - 64)
        APPLY:SetSize(128, 64)
        APPLY:SetImage("gui/editor/gui_button_apply.png")
        APPLY:SetColor(Color(255, 255, 255, 255))

        APPLY.DoClick = function()
            --[[local cm = Me:GetInfo( "cl_playermodel" )
		if(cm!= "pony" and cm!= "ponynj") then
			RunConsoleCommand( "cl_playermodel", "ponynj" )
		end]]
            --PPM.SendCharToServer(Me)
            PPM_Save("_current.txt")
            SendLocalPonyCfg()
            -- hook.Run("PPM.Apply", window)
            colorFlash(APPLY, 0.1, Color(0, 200, 0), Color(255, 255, 255))
        end

        --
        spawnTabs()
        setupCurPone()
        hook.Run("PPM.EditorOpened", window, mdl)
    end

    local taboffset = 0
    local tabcount = 0
    local tabs = {}
    local selected_tab = nil

    function spawnTabs()
        taboffset = 5 * -32
        --local ponymodel =Me:GetInfo( "cl_playermodel" )
        --if(PPM.Editor3_ponies[ponymodel]!=nil) then
        spawnTab("node_main", "t")
        spawnTab("node_body", "b")
        spawnTab("node_face", "h")
        -- spawnTab("node_equipment", "o")
        spawnTab("node_presets", "s")
        --end
    end

    function spawnTab(nodename, pfx)
        pfx = pfx or "e"
        local TABBUTTON = vgui.Create("DImageButton", PPM.Editor3)
        TABBUTTON.node = nodename
        TABBUTTON:SetSize(64, 128)
        TABBUTTON.eyemode = (pfx == "h")
        TABBUTTON:SetPos(ScrW() / 2 + taboffset, -64)
        TABBUTTON:SetImage("gui/editor/gui_tab_" .. pfx .. ".png")

        TABBUTTON.OnCursorEntered = function()
            if selected_tab ~= TABBUTTON then
                local px, py = TABBUTTON:GetPos()
                TABBUTTON:SetPos(px, -50)
            end
        end

        TABBUTTON.OnCursorExited = function()
            if selected_tab ~= TABBUTTON then
                local px, py = TABBUTTON:GetPos()
                TABBUTTON:SetPos(px, -64)
            end
        end

        TABBUTTON.DoClick = function()
            if selected_tab ~= TABBUTTON then
                if (IsValid(selected_tab)) then
                    local px, py = selected_tab:GetPos()
                    selected_tab:SetPos(px, -64)
                end

                local px, py = TABBUTTON:GetPos()
                TABBUTTON:SetPos(px, -40)
                selected_tab = TABBUTTON
                PPM.faceviewmode = TABBUTTON.eyemode
                PPM.ed3_selectedNode = nil
                PPM.E3_CURRENT_NODE = nil
                cleanValueEditors()
                cleanButtons()
                local ponymodel = "pony" --Me:GetInfo( "cl_playermodel" )

                --if(PPM.Editor3_ponies[ponymodel]!=nil) then
                if PPM.Editor3_nodes[PPM.Editor3_ponies[ponymodel][TABBUTTON.node]] ~= nil then
                    PPM.E3_CURRENT_NODE = PPM.Editor3_nodes[PPM.Editor3_ponies[ponymodel][TABBUTTON.node]]

                    if PPM.E3_CURRENT_NODE.name ~= nil then
                        PPM.ed3_selectedNode = PPM.E3_CURRENT_NODE
                        spawnEditPanel()
                        spawnValueEditor()
                    else
                        spawnButtons()
                    end
                end
                --end
            end
        end

        taboffset = taboffset + 64
        tabcount = tabcount + 1
        tabs[tabcount] = TABBUTTON

        return TABBUTTON
    end

    function setupCurPone()
        --local ponymodel =Me:GetInfo( "cl_playermodel" )
        --if(PPM.Editor3_ponies[ponymodel]!=nil) then
        PPM.E3_CURRENT_NODE = PPM.Editor3_nodes[PPM.Editor3_ponies["pony"].node_body]
        cleanButtons()
        spawnButtons()
        --else 
        --	PPM.E3_CURRENT_NODE=nil
        --end
    end

    function cleanButtons()
        for k, v in pairs(PPM.nodebuttons) do
            if (IsValid(v)) then
                v:Remove()
            end
        end

        PPM.nodebuttons = {}
    end

    function spawnButtons()
        if PPM.E3_CURRENT_NODE ~= nil then
            for k, v in pairs(PPM.E3_CURRENT_NODE) do
                local button = vgui.Create("DImageButton", PPM.Editor3)
                button:SetSize(50, 50)
                button:SetImage("gui/editor/lid_ind.png")
                button:SetAlpha(0)

                --button:SetColor(v.col or Vector(1,1,1))
                button.DoClick = function()
                    PPM.ed3_selectedNode = v
                    --if(v.onclick!=nil)then v.onclick() end
                    cleanValueEditors()
                    spawnEditPanel()
                    spawnValueEditor()
                end

                --/cleanValueEditors()
                PPM.nodebuttons[k] = button
                --MsgN(PPM.nodebuttons[k])
            end
        end
    end

    function spawnEditPanel()
        cleanValueEditors()
        local smpanel = vgui.Create("DPanel", PPM.Editor3)
        local smpanel_inner = vgui.Create("DPanel", smpanel)
        local scrollb = vgui.Create("DVScrollBar", smpanel)

        smpanel.PerformLayout = function()
            --if(IsValid(PPM.smenupanel_inner) and IsValid(PPM.CDVScrollBar)) then
            smpanel_inner:SetSize(200, 2000)
            scrollb:SetUp(1000, smpanel_inner:GetTall())
            smpanel_inner:SetPos(0, scrollb:GetOffset())
        end

        --end
        smpanel:SetSize(220, ScrH() - 120)
        smpanel:SetPos(20, 80)
        smpanel:SetAlpha(255)
        --PPM.smenupanel_inner:Dock(LEFT)
        smpanel_inner:SetSize(200, 2000)
        smpanel_inner:SetAlpha(255)
        scrollb:SetSize(20, ScrH() - 100)
        --scrollb:SetPos(PPM.smenupanel:GetWide()-20 ,23)
        scrollb:SetUp(1000, 2000)
        scrollb:SetEnabled(true)
        scrollb:Dock(RIGHT)
        PPM.smenupanel = smpanel
        --PPM.smenupanel_scroll = scroll
        PPM.smenupanel_inner = smpanel_inner
    end

    function spawnValueEditor()
        if PPM.ed3_selectedNode ~= nil and PPM.ed3_selectedNode.controlls ~= nil then
            spawnEditPanel()

            for k, v in pairs(PPM.ed3_selectedNode.controlls) do
                --MsgN("preset ",v.type,"   ",v.name)
                if PPM.Editor3_presets[v.type] ~= nil then
                    --MsgN("has ",v.type)
                    PPM.Editor3_presets[v.type].spawn(PPM.smenupanel_inner, v)
                end
            end
        end
    end

    function cleanValueEditors()
        if IsValid(PPM.smenupanel) then
            PPM.smenupanel:SetSize(20, 20)
            PPM.smenupanel:Remove()
            --PPM.smenupanel = nil
        end
    end

    function PPM.vectorcircles(id)
        return Vector(math.sin(id - 30), math.sin(id), math.sin(id + 30))
    end

    function PPM.colorcircles(id)
        return Color(math.sin(id - 30) * 255, math.sin(id) * 255, math.sin(id + 30) * 255)
    end

    function VectorToLPCameraScreen(vDir, iScreenW, iScreenH, angCamRot, fFoV)
        --Same as we did above, we found distance the camera to a rectangular slice of the camera's frustrum, whose width equals the "4:3" width corresponding to the given screen height.
        local d = 4 * iScreenH / (6 * math.tan(0.5 * fFoV))
        local fdp = angCamRot:Forward():Dot(vDir)
        --fdp must be nonzero ( in other words, vDir must not be perpendicular to angCamRot:Forward() )
        --or we will get a divide by zero error when calculating vProj below.
        if fdp == 0 then return 0, 0, -1 end
        --Using linear projection, project this vector onto the plane of the slice
        local vProj = (d / fdp) * vDir
        --Dotting the projected vector onto the right and up vectors gives us screen positions relative to the center of the screen.
        --We add half-widths / half-heights to these coordinates to give us screen positions relative to the upper-left corner of the screen.
        --We have to subtract from the "up" instead of adding, since screen coordinates decrease as they go upwards.
        local x = 0.5 * iScreenW + angCamRot:Right():Dot(vProj)
        local y = 0.5 * iScreenH - angCamRot:Up():Dot(vProj)
        --Lastly we have to ensure these screen positions are actually on the screen.
        local iVisibility

        --Simple check to see if the object is in front of the camera
        if fdp < 0 then
            iVisibility = -1
        elseif x < 0 or x > iScreenW or y < 0 or y > iScreenH then
            --We've already determined the object is in front of us, but it may be lurking just outside our field of vision.
            iVisibility = 0
        else
            iVisibility = 1
        end

        return x, y, iVisibility
    end
end
