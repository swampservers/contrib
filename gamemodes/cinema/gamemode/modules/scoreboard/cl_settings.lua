-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

surface.CreateFont( "LabelBigger", { font = "Lato-Light", size = 24, weight = 200 } )
surface.CreateFont( "LabelSmaller", { font = "Lato-Light", size = 20, weight = 200 } )
surface.CreateFont( "ScoreboardHelp", { font = "Lato-Light", size = 18, weight = 200 } )

SETTINGS = {}
SETTINGS.TitleHeight = BrandTitleBarHeight

--[[
radiobutton0 = CreateClientConVar("radiobutton0","0",false,false)
radiobutton1 = CreateClientConVar("radiobutton1","0",false,false)
radiobutton2 = CreateClientConVar("radiobutton2","0",false,false)
radiobutton3 = CreateClientConVar("radiobutton3","0",false,false)
radiobutton4 = CreateClientConVar("radiobutton4","0",false,false)

function setRadioButtons(name,old,new)
	for n=0,4 do
		RunConsoleCommand("radiobutton"..tostring(n),"0")
	end
	RunConsoleCommand("radiobutton"..tostring(new),"1")
end

cvars.AddChangeCallback("cinema_interface",setRadioButtons)
timer.Simple(0, function() setRadioButtons("","",GetConVar("cinema_interface"):GetInt()) end)

function updateRadioButton(name,old,new)
	if tonumber(new)>0 then
		local n = name:sub(name:len())
		if cinemainterface:GetInt() ~= n then
			RunConsoleCommand("cinema_interface",tostring(n))
		end
	else
		timer.Simple(0,function()
			local allzero = true
			for n=0,4 do
				allzero = allzero and GetConVar("radiobutton"..tostring(n)):GetInt()==0
			end
			if allzero then
				RunConsoleCommand(name, "1")
			end
		end)
	end
end

cvars.AddChangeCallback("radiobutton0",updateRadioButton)
cvars.AddChangeCallback("radiobutton1",updateRadioButton)
cvars.AddChangeCallback("radiobutton2",updateRadioButton)
cvars.AddChangeCallback("radiobutton3",updateRadioButton)
cvars.AddChangeCallback("radiobutton4",updateRadioButton)
]]

function SETTINGS:DoClick()

end

function SETTINGS:Init()

	self.Title = Label( T'Settings_Title', self )
	self.Title:SetFont( "ScoreboardTitleSmall" )
	self.Title:SetColor( Color( 255, 255, 255 ) )

	self.Help = Label( T'Settings_ClickActivate', self )
	self.Help:SetFont( "ScoreboardHelp" )
	self.Help:SetColor( Color( 255, 255, 255, 150 ) )

	self.Settings = {}

	self.TheaterList = vgui.Create( "TheaterList", self )

	self:Create()

end

function SETTINGS:NewSetting( control, text, convar )

	local Wrap = vgui.Create( "Panel", self )
	local Control = vgui.Create( control, Wrap )
	Control:SetText( text or "" )
	Control:Dock(FILL)

	if convar then
		Control:SetConVar( convar )
	end

	Control.Wrap = Wrap

	if !table.HasValue( self.Settings, Control ) then
		table.insert( self.Settings, Control )
	end
	
	return Control
end

function SETTINGS:Paint( w, h )
	surface.SetDrawColor(BrandColorGrayDarker)
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall())

	local xp,_ = self:GetPos()
	BrandBackgroundPattern(0, 0, self:GetWide(), self.TitleHeight, xp)
	BrandDropDownGradient(0,self.TitleHeight,self:GetWide())
end

function SETTINGS:PerformLayout()

	local curY = self.TitleHeight +6 +32 + self.TheaterList:GetCanvas():GetTall()

	for _, panel in pairs( self.Settings ) do

		panel:InvalidateLayout()
		--curY = curY + panel.Wrap:GetTall()

	end

	self.maxheight = (ScrH()* 0.8)
	self:SetTall(math.min(self.maxheight, curY ))

	self.Title:SizeToContents()
	self.Title:SetTall( self.TitleHeight )
	self.Title:CenterHorizontal()

	self.TheaterList:Dock( FILL )
	self.TheaterList:DockMargin( 0, BrandTitleBarHeight+6, 0, 32)
	self.TheaterList:SizeToContents()

	self.Help:SizeToContents()
	self.Help:CenterHorizontal()
	self.Help:AlignBottom( 10 )
end

function SETTINGS:Create()

	-- Volume slider
	
	local Volume = self:NewSetting( "TheaterNumSlider", 'Video & Music Volume', "cinema_volume" )
	Volume:SetTooltip( T'Settings_VolumeTooltip' )
	Volume:SetMinMax( 0, 100 )
	Volume:SetDecimals( 0 )
	Volume:SetTall(50)
	Volume.Wrap:DockPadding(16,6,16,0)
	Volume.Wrap:SetTall(Volume:GetTall()+6)
	self.TheaterList:AddItem(Volume.Wrap)

	local function addCheckbox(label,convar,hover)
		local HD = self:NewSetting( "TheaterCheckBoxLabel",label,convar)
		if convar:StartWith("radiobutton") then
			HD.RadioButton = true
		end
		HD:SetTooltip(hover)
		HD.Label:SetFont( "LabelSmaller" )
		HD.Label:SetColor( color_white )
		HD:SetTall(24)

		HD.Wrap:DockPadding(16,0,16,0)
		HD.Wrap:SetTall(HD:GetTall())
		self.TheaterList:AddItem(HD.Wrap)
	end

	local function addLabel(label)
			local setting = self:NewSetting( "DLabel", label)
	setting:AlignLeft( 16 )
	--setting:AlignTop( checkboxy + (checkboxs*checkboxn) )
	setting:SetFont( "LabelBigger" )
	setting:SetColor( color_white )
	setting:SetTall(24)

	setting.Wrap:DockPadding(16,0,16,0)
	setting.Wrap:SetTall(setting:GetTall())
	self.TheaterList:AddItem(setting.Wrap)
	end
	
	addLabel('Sound')
	addCheckbox('Mute voice chat in theater', "cinema_muteall" ,'Mute stupid micspammers')
	addCheckbox('Mute AFK voice chat', "cinema_muteafk" ,'Mute stupid micspammers 2')
	addCheckbox('Mute game sound in theater', "cinema_mutegame",'If this doesn\'t work, run "volume 0" in console. Also try "cinema_game_volume 0.1" if you want the sounds quieter but not muted.')
	addCheckbox('Mute audio while alt-tabbed', "cinema_mute_nofocus",'No background noise')

	addLabel('Display')
	addCheckbox('HD video playback',"cinema_hd",'Stream in 1080p HD with DOLBY DIGITAL SURROUND')
	addCheckbox('Show player names', "cinema_drawnames","Big names in yo face")
	addCheckbox('Don\'t load sprays', "cl_playerspraydisable","May help performance (GMOD global)")
	--addCheckbox('Don\'t load chat images',"fedorachat_hideimg","Hides all images in chat")
	addCheckbox('Hide interface', "cinema_hideinterface","Clean Your Screen")
	addCheckbox('Hide players in theater', "cinema_hideplayers",'For when trolls stand in front of your screen')
	addCheckbox('Display Hints',"swamp_showhints",'display occasional hints on how to play on the server')

	addLabel('Performance')
	addCheckbox('Turbo button', "swamp_fps_boost","Put your gaymergear PC into overdrive")
	addCheckbox('Dynamic theater lighting',"cinema_lightfx",'Exclusive lighting effects (reduces fps)')
	

	--addLabel('Interface')
	--RunConsoleCommand("radiobutton"..cinemainterface:GetInt(),"1")
	--addCheckbox('Show everything','radiobutton4','Show all images, potentially graphic.')
	--addCheckbox('Hide explicit images','radiobutton3','Default setting')
	--addCheckbox('Hide all images','radiobutton2','Don\'t load any images')
	--addCheckbox('Hide chat completely','radiobutton1','Hide all distractions on your screen; show chat while typing only')
	--addCheckbox('Hide everything','radiobutton0','')

	addLabel('Adult Content (18+)')
	addCheckbox('Videos & sprays (toggle: F6)',"swamp_mature_content",'Show potentially mature videos & sprays')
	addCheckbox('Chatbox images (toggle: F7)',"swamp_mature_chatbox",'Show potentially mature chatbox images')

	local LanguageSelect = self:NewSetting("DButton","Chat Command List")
	--LanguageSelect:AlignTop( checkboxy + (checkboxs*checkboxn) - 0 )
	LanguageSelect.DoClick = function()
		RunConsoleCommand("say","/help")
	end
	LanguageSelect.Wrap:DockPadding(32,4,32,4)
	LanguageSelect.Wrap:SetTall(LanguageSelect:GetTall()+8)
	self.TheaterList:AddItem(LanguageSelect.Wrap)

end

vgui.Register( "ScoreboardSettings", SETTINGS )
