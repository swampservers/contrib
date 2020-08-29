-- This file is subject to copyright - contact swampservers@gmail.com for more information.

surface.CreateFont( "ScoreboardTitle", { font = "Righteous", size = 52, weight = 400 } )
surface.CreateFont( "ScoreboardTitleSmall", { font = "Righteous", size = 36, weight = 400 } )
surface.CreateFont( "ScoreboardServerName", { font = "Lato-Light", size = 22, weight = 200 } )
surface.CreateFont( "ScoreboardName", { font = "Lato-Light", size = 22, weight = 800 } )
surface.CreateFont( "ScoreboardLocation", { font = "Lato", size = 16, weight = 200 } )
surface.CreateFont( "ScoreboardPing", { font = "Lato", size = 18, weight = 200 } )
afkClockMaterial=Material("icon16/time.png")
showAFKs = false

local PLAYERLIST = {}
PLAYERLIST.TitleHeight = BrandTitleBarHeight
PLAYERLIST.ServerHeight = 32
PLAYERLIST.PlyHeight = 48


function UpdateMutes()
	for k,v in pairs(player.GetAll()) do	
		if v ~= LocalPlayer() then
			v:SetMuted((v.ClickMuted or false) or (v:IsAFK() and MuteAFKConVar:GetBool()))	
		end
	end
end
timer.Create("updatemutes",1,0,UpdateMutes)


function PLAYERLIST:Init()

	self.Title = Label( "SWAMP CINEMA", self )
	self.Title:SetFont( "ScoreboardTitle" )
	self.Title:SetColor( Color( 255, 255, 255 ) )

	self.ServerName = vgui.Create( "ScoreboardServerName", self )

	self.PlayerList = vgui.Create( "TheaterList", self )

	self.Players = {}
	self.NextUpdate = 0.0

end

function PLAYERLIST:AddPlayer( ply )
	
	local panel = vgui.Create( "ScoreboardPlayer" )
	panel:SetParent( self )
	panel:SetPlayer( ply )
	panel:SetVisible( true )

	self.Players[ ply ] = panel
	self.PlayerList:AddItem( panel )
    
	
end

function PLAYERLIST:RemovePlayer( ply )

	if ValidPanel( self.Players[ ply ] ) then
		self.PlayerList:RemoveItem( self.Players[ ply ] )
		self.Players[ ply ]:Remove()
		self.Players[ ply ] = nil
	end

end

function PLAYERLIST:Paint( w, h )
	surface.SetDrawColor(BrandColorGrayDarker)
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )

	local xp,_ = self:GetPos()
	BrandBackgroundPattern(0, 0, self:GetWide(), self.Title:GetTall(), xp)
	BrandDropDownGradient(0,self.Title:GetTall(),self:GetWide())
end

function PLAYERLIST:Think()

	if RealTime() > self.NextUpdate then

		for ply in pairs( self.Players ) do 
			if !IsValid( ply ) then
				self:RemovePlayer( ply )
			end
		end
		
		for _, ply in pairs( player.GetHumans() ) do 
			if self.Players[ ply ] == nil then
				self:AddPlayer( ply )
			end
		end
		
		self.ServerName:Update()
		self:InvalidateLayout(true)

		self.NextUpdate = RealTime() + 1.0

	end

end

function PLAYERLIST:PerformLayout()

	if RealTime() < self.NextUpdate then return end

	table.sort( self.PlayerList.Items, function( a, b ) 

		if !a or !a.Player or !IsValid(a.Player) then return false end
		if !b or !b.Player or !IsValid(b.Player) then return true end
		
		return string.lower( a.Player:Nick() ) < string.lower( b.Player:Nick() )

	end )

	local curY = PLAYERLIST.TitleHeight + PLAYERLIST.ServerHeight

	for _, panel in pairs( self.PlayerList.Items ) do

		panel:InvalidateLayout( true )
		panel:UpdatePlayer()
		panel:SetWide( self:GetWide() )

		curY = curY + self.PlyHeight + 2

	end

	self.Title:SizeToContents()
	self.Title:SetTall( PLAYERLIST.TitleHeight )
	self.Title:CenterHorizontal()

	self.ServerName:SizeToContents()
	self.ServerName:AlignTop( PLAYERLIST.TitleHeight )
	self.ServerName:SetWide( self:GetWide() )
	self.ServerName:SetTall( PLAYERLIST.ServerHeight )
	self.ServerName:CenterHorizontal()

	self.PlayerList:Dock( FILL )
	self.PlayerList:DockMargin( 0, self.TitleHeight + self.ServerHeight, 0, 0 )
	self.PlayerList:SizeToContents()

	self:SetTall( math.min( curY, ScrH() * 0.8 ) )

end

vgui.Register( "ScoreboardPlayerList", PLAYERLIST )



local PLAYER = {}
PLAYER.Padding = 8

function PLAYER:Init()

	self:SetTall( PLAYERLIST.PlyHeight )

	self.Name = Label( "Unknown", self )
	self.Name:SetFont( "ScoreboardName" )
	self.Name:SetColor( Color( 255, 255, 255, 255 ) )

	self.Location = Label( "Unknown", self )
	self.Location:SetFont( "ScoreboardLocation" )
	self.Location:SetColor( Color( 255, 255, 255, 80 ) )
	self.Location:SetPos( 0, 8 )

	self.AvatarButton = vgui.Create("DButton", self)
	self.AvatarButton:SetSize( 32, 32 )
	
	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:SetSize( 32, 32 )
	self.Avatar:SetZPos( 1 )
	self.Avatar:SetVisible( false )
	self.Avatar:SetMouseInputEnabled( false )	
	
	self.Mute = vgui.Create("DImageButton", self)	
	self.Mute:SetSize(20,20)
    self.Mute:SetPos(464,12)
	
	self.Mute:SetImage("icon32/unmuted.png")
	self.Mute:CenterVertical()
	
	self.ChatMute = vgui.Create("DImageButton", self)
	self.ChatMute:SetSize(20,20)
    self.ChatMute:SetPos(483,12)
	
	self.ChatMute:SetImage("theater/chatunmuted.png")
	self.ChatMute:CenterVertical()

	self.FriendIcon = vgui.Create("DImage", self)
	self.FriendIcon:SetSize(16, 16)
	self.FriendIcon:SetPos(30, 27)
	self.FriendIcon:SetZPos(2)
	self.FriendIcon:SetImage("chev/icon/friend.png")

	self.Ping = vgui.Create( "ScoreboardPlayerPing", self )
	self.Ping:SetPos(402, 11)

	self.Country = vgui.Create("DImage", self)	
	self.Country:SetSize(16,11)
    self.Country:SetPos(388, 18)
	
	self.Country:SetImage("countries/us.png")
	self.Country:CenterVertical()

end

function PLAYER:UpdatePlayer()

	if !IsValid(self.Player) then
		local parent = self:GetParent()
		if ValidPanel(parent) and parent.RemovePlayer then
			parent:RemovePlayer(self.Player)
		end
		return
	end
	
	if self.Player.ClickMuted then
		self.Mute:SetImage( "icon32/muted.png" )
	else
		self.Mute:SetImage( "icon32/unmuted.png" )
	end

	if self.Player.IsChatMuted then
		self.ChatMute:SetImage( "theater/chatmuted.png" )
	else
		self.ChatMute:SetImage( "theater/chatunmuted.png" )
	end

	self.Mute.DoClick = function() 
		self.Player.ClickMuted = not (self.Player.ClickMuted or false)
		net.Start("SetMuted")
		net.WriteEntity(self.Player)
		net.WriteBool(self.Player.ClickMuted)
		net.SendToServer()
		if self.Player.ClickMuted then
			self.Mute:SetImage( "icon32/muted.png" )
		else
			self.Mute:SetImage( "icon32/unmuted.png" )
		end
		UpdateMutes()
    end
	
	self.ChatMute.DoClick = function()
		self.Player.IsChatMuted = not self.Player.IsChatMuted
		print("muted"..self.Player:Nick().."'s chat")
		if self.Player.IsChatMuted then
			self.ChatMute:SetImage( "theater/chatmuted.png" )
		else
			self.ChatMute:SetImage( "theater/chatunmuted.png" )
		end	
    end

    local code = self.Player:GetNetworkedString("cntry")
    if code=="" then
    	if self.Country~=nil and self.Country.Remove~=nil then self.Country:Remove() end
    else
    	if self.Country~=nil and self.Country.SetImage~=nil then self.Country:SetImage("countries/"..string.lower(code)..".png") end
    end
	

	self.Name:SetText( self.Player:Name() )
	self.Location:SetText( string.upper( self.Player:GetLocationName() or "Unknown" ) )
	self.Ping:Update()

end

function PLAYER:SetPlayer( ply )

	self.Player = ply	
	self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

	self.Avatar:SetPlayer( ply, 64 )
	self.Avatar:SetVisible( true )

	if ply:GetFriendStatus() == "friend" then
		self.FriendIcon:Show()
	else
		self.FriendIcon:Hide()
	end

	self.Ping:SetPlayer( ply )

	self:UpdatePlayer()

end

function PLAYER:PerformLayout()

	self.Name:SizeToContents()
	self.Name:AlignTop( self.Padding - 4 )
	--if self.Player:GetNWBool("afk") then
		--self.Name:AlignLeft( self.Avatar:GetWide() + 16 + 16 )
	--else
		self.Name:AlignLeft( self.Avatar:GetWide() + 16 )
	--end
	
	self.Location:SizeToContents()
	self.Location:AlignTop( self.Name:GetTall() + 5 )
	self.Location:AlignLeft( self.Avatar:GetWide() + 16 )
	
	self.AvatarButton:AlignTop( self.Padding )
	self.AvatarButton:AlignLeft( self.Padding )
	self.AvatarButton:CenterVertical()
	
	self.Avatar:SizeToContents()
	self.Avatar:AlignTop( self.Padding )
	self.Avatar:AlignLeft( self.Padding )
	self.Avatar:CenterVertical()
	
end

function PLAYER:Paint( w, h )

	surface.SetDrawColor(BrandColorGrayDark)
	surface.DrawRect( 0, 0, self:GetSize() )

	surface.SetDrawColor( 255, 255, 255, 255 )

	local xp = 370

	if self.Player:GetNWBool("afk") and (showAFKs or LocalPlayer():IsStaff()) then
		surface.SetDrawColor( 255, 255, 255, 120 )
		surface.SetMaterial(afkClockMaterial)
		surface.DrawTexturedRect(360, 16, 16,16 )
		xp = xp - 24
	end

	if self.Player:IsStaff() then
		--local xp = ({self.Name:GetPos()})[1] + self.Name:GetWide() + 4
		
		local str=self.Player:GetRankName()
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetFont("DermaDefault")

		xp = xp - ({surface.GetTextSize(str)})[1]
		surface.DrawRect( xp, 17, ({surface.GetTextSize(str)})[1] + 4, 13) 
		draw.SimpleText(str, "DermaDefault", xp+2, 17, Color( 0,0,0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	end
end

vgui.Register( "ScoreboardPlayer", PLAYER )



local PLAYERPING = {}
PLAYERPING.Padding = 8

function PLAYERPING:Init()

	self.Ping = Label( "99", self )
	self.Ping:SetFont( "ScoreboardPing" )
	self.Ping:SetColor( Color( 255, 255, 255 ) )
	
	self.Heights = { 4, 8, 12 }
	self.PingAmounts = { 300, 200, 100 }
	self.BaseSpacing = 5

end

function PLAYERPING:Update()

	local ping = self.Player:Ping()

	self.Ping:SetText( ping )
	self.PingVal = ping

end

function PLAYERPING:SetPlayer( ply )

	self.Player = ply
	self:Update()

end

function PLAYERPING:PerformLayout()

	self.Ping:SizeToContents()
	self.Ping:SetWide(self.Ping:GetWide()+2)
	self.Ping:AlignRight()
	self.Ping:CenterVertical()

end

function PLAYERPING:Paint( w, h )

	local height = self.Ping:GetTall()
	local xpos = 35 - 20
	local x = xpos
	
	// BG
	surface.SetDrawColor( 255, 255, 255, 10 )

	for _, h in pairs( self.Heights ) do
		surface.DrawRect( x, (height) - h, 4, h )
		x = x + 6
	end

	// Lit/Main
	x = xpos
	surface.SetDrawColor( 255, 255, 255, 255 )

	for i=1, #self.Heights do

		local h = self.Heights[i]

		if self.PingVal < self.PingAmounts[i] then
			surface.DrawRect( x, (height) - h, 4, h )
		end

		x = x + 6

	end


	surface.SetTextColor( 255, 255, 255, 10 )
	surface.SetFont( "ScoreboardPing" )

	local zeros = "000"
	if self.PingVal >= 1 then zeros = "00" end
	if self.PingVal >= 10 then zeros = "0" end
	if self.PingVal >= 100 then zeros = "" end

	local w, h = surface.GetTextSize( zeros )
	surface.SetTextPos( self.Ping.x - w - 1, self.Ping.y )
	surface.DrawText( zeros )

end

vgui.Register( "ScoreboardPlayerPing", PLAYERPING )



local SERVERNAME = {}
SERVERNAME.Padding = 8

function SERVERNAME:Init()

	self.Name = Label( "Unknown", self )
	self.Name:SetFont( "ScoreboardServerName" )
	self.Name:SetColor( Color( 255, 255, 255 ) )

	self.MapName = Label( "Unknown", self )
	self.MapName:SetFont( "ScoreboardServerName" )
	self.MapName:SetColor( Color( 255, 255, 255 ) )

end

function SERVERNAME:Update()
	
	self.Name:SetText( game.GetMap() )
	local players = table.Count(player.GetHumans())
	local ttext = tostring(players).." Players Online"
	if players==1 then ttext = "One Player Online" end
	local x,y = self:LocalCursorPos()
	local xs,ys = self:GetSize()
	showAFKs = false
	if x>0 and y>0 and x<xs and y<ys then
		showAFKs = true
		local count = 0
		local count2 = 0
		for k,v in pairs(player.GetHumans()) do 
			if v:GetNWBool("afk") then count = count+1 if !(v:InTheater()) then count2=count2+1 end end
		end
		ttext = tostring(count).." / "..tostring(players).." AFK ("..tostring(count2).." AFK + !InTheater)	"
	end
	self.MapName:SetText( ttext )

	self:PerformLayout()

end

function SERVERNAME:PerformLayout()

	self.Name:SizeToContents()
	self.Name:AlignLeft( self.Padding )
	self.Name:AlignTop( 3 )

	self.MapName:SizeToContents()
	self.MapName:AlignRight( self.Padding )
	self.MapName:AlignTop( 3 )
	
end

vgui.Register( "ScoreboardServerName", SERVERNAME )
