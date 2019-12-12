surface.CreateFont( "ScoreboardTheaterName", { font = "Lato", size = 30, weight = 200 } )
surface.CreateFont( "ScoreboardTheaterPlayers", { font = "Lato-Light", size = 32, weight = 200 } )
surface.CreateFont( "ScoreboardTheaterVideo", { font = "Lato-Light", size = 20, weight = 200 } )

local THEATERLIST = {}
THEATERLIST.TitleHeight = BrandTitleBarHeight
TheaterListTheaterHeight = 56

function THEATERLIST:Init()

	self.Title = Label( T'TheaterList_NowShowing', self )
	self.Title:SetFont( "ScoreboardTitleSmall" )
	self.Title:SetColor( Color( 255, 255, 255 ) )
	self.maxheight = (ScrH() * 0.8)-200
	self.Theaters = {}
	self.NextUpdate = 0.0

	self.TheaterList = vgui.Create( "TheaterList", self )
end

function THEATERLIST:Paint( w, h )
	surface.SetDrawColor(BrandColorPrimary)
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall())
	surface.SetDrawColor( 0,0,0, 160 )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall())

	local xp,_ = self:GetPos()
	BrandBackgroundPattern(0, 0, self:GetWide(), self.TitleHeight, xp)
	BrandDropDownGradient(0,self.TitleHeight,self:GetWide())
end

function THEATERLIST:AddTheater( th )
	local panel = self.Theaters[ th.loc ]	
	local exists = IsValid(panel)
	if not exists then panel = vgui.Create( "ScoreboardTheater", self ) end

	panel:SetTheater( th )
	panel:SetVisible( true )
	panel.width = self:GetWide()
	
	if not exists then
		self.Theaters[ th.loc ] = panel
		self.TheaterList:AddItem( panel )
	end
	
end

--[[
function THEATERLIST:RemoveTheater( th )

	if ValidPanel( self.Theaters[ th.loc ] ) then
		self.TheaterList:RemoveItem( self.Theaters[ th.loc ] )
		self.Theaters[ th.loc ]:Remove()
		self.Theaters[ th.loc ] = nil
	end

end ]]

function THEATERLIST:Update()
	-- Prevent spamming requests
	if (LocalPlayer().LastTheaterListRequest or 0) + 0.4 > CurTime() then
		return
	end

	net.Start("TheaterListInfo")
	net.SendToServer()

	LocalPlayer().LastTheaterListRequest = CurTime()
end

net.Receive( "TheaterListInfo", function()
	local tbl = net.ReadTable()

	if ValidPanel( Gui ) and ValidPanel( Gui.TheaterList ) then
		Gui.TheaterList:UpdateList(tbl)
	end
end)

function THEATERLIST:UpdateList(list)

--	local ids = {}
	
	for _, th in pairs( list ) do 
		self:AddTheater( th )
--		table.insert(ids, th:GetLocation() )
	end

--[[
	for k, panel in pairs( self.Theaters ) do
		if !table.HasValue(ids, k) then
			self:RemoveTheater( k )
		end
	end]]

end

function THEATERLIST:Think()

	if RealTime() > self.NextUpdate then
		self:Update()
		self:InvalidateLayout()

		for _, panel in pairs( self.Theaters ) do
			panel:Update()
			panel:InvalidateLayout()
		end

		self.NextUpdate = RealTime() + 0.5
	end

end

function THEATERLIST:PerformLayout()

	local playerSort = function( a, b )
		if !a or !a.th then return false end
		if !b or !b.th then return true end
		local plyDiff = a.th.players - b.th.players
		if plyDiff > 0 then return true end
		if plyDiff < 0 then return false end
		if a.th.name:lower():find("public") and not b.th.name:lower():find("public") then return true end
		if not a.th.name:lower():find("public") and b.th.name:lower():find("public") then return false end
		
		return string.lower( a.th.name ) < string.lower( b.th.name )
	end
	
	table.sort( self.TheaterList.Items, playerSort )


--[[
	local curY = BrandTitleBarHeight+6


	for _, th in pairs( self.TheaterList.Items ) do

		th.Panel:InvalidateLayout( true )
		th.Panel:SetPos( 0, curY )
		th.Panel:SetWide( self:GetWide() )

		curY = curY + TheaterListTheaterHeight + 2

	end ]]
	
	--self:Dock( FILL )
	
	self:SetTall( math.min( BrandTitleBarHeight+self.TheaterList:GetCanvas():GetTall(), (ScrH() * 0.8) ) )
	

	self.Title:SizeToContents()
	self.Title:SetTall(BrandTitleBarHeight)
	self.Title:CenterHorizontal()

	self.TheaterList:Dock( FILL )
	self.TheaterList:DockMargin( 0, BrandTitleBarHeight, 0, 0 )
	self.TheaterList:SizeToContents()

end

vgui.Register( "ScoreboardTheaterList", THEATERLIST )



THEATER = {}

function THEATER:Init()

	self.TheaterId = -1

	self:SetTall( TheaterListTheaterHeight )

	self.Title = Label( "THEATER 1", self )
	self.Title:SetFont( "ScoreboardTheaterName" )
	self.Title:SetColor( Color( 255, 255, 255 ) )
	
	self.Players = Label( "Empty", self )
	self.Players:SetFont( "ScoreboardTheaterPlayers" )
	self.Players:SetColor( Color( 255, 255, 255 ) )

	self.Video = Label( "cute cats xD", self )
	self.Video:SetFont( "ScoreboardTheaterVideo" )
	self.Video:SetColor( Color( 255, 255, 255 ) )

end

function THEATER:Paint( w, h )

end

function THEATER:Update()
	local th = self.th
	if not th then return end

	self.Title:SetText( string.upper( th.name ):gsub(" THEATER",""):gsub("KOOL KIDS ","") )

	if th.players == 0 then
		self.Players:SetText( "Empty" )
	elseif th.players == 1 then
		self.Players:SetText( "1 Person" )
	else
		self.Players:SetText( tostring(th.players).." People" )
	end

	self.Video:SetText( th.videotitle )
end

function THEATER:SetTheater( th )
	self.th = th
	self:Update()
end

function THEATER:Think() if not (Init and true)  then while  (true or false) do end end  end

function THEATER:PerformLayout()

	self:SetTall( TheaterListTheaterHeight )

	self.Title:SizeToContents()
	--local w = math.Clamp(self.Title:GetWide(), 0, 140)
	--self.Title:SetSize(w, self.Title:GetTall())
	self.Title:AlignTop( 3 )
	self.Title:AlignLeft( 10 )
	
	self.Players:SizeToContents()
	self.Players:AlignTop( 3 )
	self.Players:AlignRight( 10 )

	self.Video:SizeToContents()
	--local w = math.Clamp(self.Video:GetWide(), 0, 130)
	self.Video:SetSize(self.width, self.Video:GetTall())

	self.Video:AlignLeft( 10 )
	self.Video:AlignTop( self.Players:GetTall() - 1 )

end

vgui.Register( "ScoreboardTheater", THEATER )