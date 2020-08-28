-- This file is subject to copyright - contact swampservers@gmail.com for more information.

if SERVER then
   AddCSLuaFile()
end

ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_slam.mdl")
ENT.Base = "ent_chess_board"
ENT.Models = {
	["board"] = Model("models/props_phx/games/chess/board.mdl"),
	--["table"] = Model("models/props/de_tides/restaurant_table.mdl"),
	["table"] = Model( "models/props_c17/furnituretable001a.mdl" ),
	
	["dama"] = Model("models/props_phx/games/chess/white_pawn.mdl"),
	
	["WhiteMan"] = Model("models/props_phx/games/chess/white_dama.mdl"),	["BlackMan"] = Model("models/props_phx/games/chess/black_dama.mdl"),
	["WhiteKing"] = Model("models/props_phx/games/chess/white_dama.mdl"),	["BlackKing"] = Model("models/props_phx/games/chess/black_dama.mdl"),
}
ENT.DrawDouble = {
	["King"] = true,
}

ENT.PrintName		= "Draughts/Checkers"
ENT.Author			= "my_hat_stinks"
ENT.Information		= "A draughts (checkers) board"
ENT.Category		= "Game boards"

ENT.Game = "Draughts"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.AdminSpawnable = true

--Status
local CHESS_INACTIVE = 0
local CHESS_WHITEMOVE = 1
local CHESS_BLACKMOVE = 2
local CHESS_WHITEPROMO = 3	local CHESS_WHITEJUMP = 3
local CHESS_BLACKPROMO = 4	local CHESS_BLACKJUMP = 4
local CHESS_WAGER = 5

--Captured piece squares
local CHESS_WCAP1 = 10
local CHESS_WCAP2 = 11
local CHESS_BCAP1 = 12
local CHESS_BCAP2 = 13

local NumToLetter = {"a", "b", "c", "d", "e", "f", "g", "h", ["a"]=1, ["b"]=2, ["c"]=3, ["d"]=4, ["e"]=5, ["f"]=6, ["g"]=7, ["h"]=8} --Used extensively for conversions

ENT.StartState = CHESS_BLACKMOVE

function ENT:SetupDataTables()
--	self:NetworkVar( "Int", 0, "BlackPassant" )
--	self:NetworkVar( "Int", 1, "WhitePassant" )
	
	self:NetworkVar( "Int", 2, "ChessState" )
	self:NetworkVar( "Bool", 0, "Playing" )
	
	self:NetworkVar( "Float", 0, "WhiteWager" )
	self:NetworkVar( "Float", 1, "BlackWager" )
	
	self:NetworkVar( "Entity", 0, "WhitePlayer" )
	self:NetworkVar( "Entity", 1, "BlackPlayer" )
	self:NetworkVar( "Entity", 2, "TableEnt" )
	
--	self:NetworkVar( "Int", 3, "MoveCount" )
--	self:NetworkVar( "Bool", 1, "Repetition" )
	
	self:NetworkVar( "Bool", 2, "PSWager" )
	
	self:NetworkVar( "Float", 2, "WhiteTime" )
	self:NetworkVar( "Float", 3, "BlackTime" )
	
	--Draughts vars
	self:NetworkVar( "Bool", 1, "JumpMove" )
	self:NetworkVar( "Int", 0, "JumpLet" )
	self:NetworkVar( "Int", 1, "JumpNum" )
end

function ENT:Initialize()
	self.ChessDerived = true
	self.IsDraughts = true
	
	return self.BaseClass.Initialize( self )
end

function ENT:GetManMoves( tbl, GridLet, GridNum, IsWhite )
	local CapMove = false
	
	--Forward Right
	local TargetRow = GridNum+ (IsWhite and 1 or (-1))
	local TargetColumn = NumToLetter[GridLet]+1
	if TargetRow<=8 and TargetRow>=1 and TargetColumn<=8 and TargetColumn>=1 then
		local target = self:GetSquare( NumToLetter[TargetColumn], TargetRow )
		if target then
			if ((self:SquareTeam(target)=="White")~=IsWhite) then --Enemy piece
				local CapRow = TargetRow+ (IsWhite and 1 or (-1))
				local CapCol = TargetColumn+1
				
				if CapRow<=8 and CapRow>=1 and CapCol<=8 and CapCol>=1 then --In range
					local target = self:GetSquare( NumToLetter[CapCol], CapRow )
					if not target then --Empty space
						tbl[NumToLetter[CapCol]][CapRow] = {"CAPTURE", NumToLetter[TargetColumn], TargetRow} --Capture move
						CapMove = true --Flag as capture move
					end
				end
			end
		else
			tbl[NumToLetter[TargetColumn]][TargetRow] = true --Standard valid move
		end
	end
	--Forward Left
	local TargetRow = GridNum+ (IsWhite and 1 or (-1))
	local TargetColumn = NumToLetter[GridLet]-1
	if TargetRow<=8 and TargetRow>=1 and TargetColumn<=8 and TargetColumn>=1 then
		local target = self:GetSquare( NumToLetter[TargetColumn], TargetRow )
		if target then
			if ((self:SquareTeam(target)=="White")~=IsWhite) then
				local CapRow = TargetRow+ (IsWhite and 1 or (-1))
				local CapCol = TargetColumn-1
				
				if CapRow<=8 and CapRow>=1 and CapCol<=8 and CapCol>=1 then
					local target = self:GetSquare( NumToLetter[CapCol], CapRow )
					if not target then
						tbl[NumToLetter[CapCol]][CapRow] = {"CAPTURE", NumToLetter[TargetColumn], TargetRow}
						CapMove = true
					end
				end
			end
		else
			tbl[NumToLetter[TargetColumn]][TargetRow] = true --Standard valid move
		end
	end
	
	return CapMove
end
function ENT:GetKingMoves( tbl, GridLet, GridNum, IsWhite )
	local CapMove = self:GetManMoves( tbl, GridLet, GridNum, IsWhite ) --Forward moves
	
	--Back Right
	local TargetRow = GridNum+ (IsWhite and (-1) or (1))
	local TargetColumn = NumToLetter[GridLet]+1
	if TargetRow<=8 and TargetRow>=1 and TargetColumn<=8 and TargetColumn>=1 then
		local target = self:GetSquare( NumToLetter[TargetColumn], TargetRow )
		if target then
			if ((self:SquareTeam(target)=="White")~=IsWhite) then
				local CapRow = TargetRow+ (IsWhite and (-1) or (1))
				local CapCol = TargetColumn+1
				
				if CapRow<=8 and CapRow>=1 and CapCol<=8 and CapCol>=1 then
					local target = self:GetSquare( NumToLetter[CapCol], CapRow )
					if not target then
						tbl[NumToLetter[CapCol]][CapRow] = {"CAPTURE", NumToLetter[TargetColumn], TargetRow}
						CapMove = true
					end
				end
			end
		else
			tbl[NumToLetter[TargetColumn]][TargetRow] = true --Standard valid move
		end
	end
	--Back Left
	local TargetRow = GridNum+ (IsWhite and (-1) or (1))
	local TargetColumn = NumToLetter[GridLet]-1
	if TargetRow<=8 and TargetRow>=1 and TargetColumn<=8 and TargetColumn>=1 then
		local target = self:GetSquare( NumToLetter[TargetColumn], TargetRow )
		if target then
			if ((self:SquareTeam(target)=="White")~=IsWhite) then
				local CapRow = TargetRow+ (IsWhite and (-1) or (1))
				local CapCol = TargetColumn-1
				
				if CapRow<=8 and CapRow>=1 and CapCol<=8 and CapCol>=1 then
					local target = self:GetSquare( NumToLetter[CapCol], CapRow )
					if not target then
						tbl[NumToLetter[CapCol]][CapRow] = {"CAPTURE", NumToLetter[TargetColumn], TargetRow}
						CapMove = true
					end
				end
			end
		else
			tbl[NumToLetter[TargetColumn]][TargetRow] = true --Standard valid move
		end
	end
	
	return CapMove
end
function ENT:GetMove( GridLet, GridNum, IgnoreCap )
	if not (GridLet and GridNum) then return {} end
	if not NumToLetter[GridLet] then return {} end
	if NumToLetter[GridLet]<1 or NumToLetter[GridLet]>8 then return {} end
	if GridNum<1 or GridNum>8 then return {} end
	
	local square = self:GetSquare( GridLet, GridNum )
	if not square then return {} end
	
	local class = square.Class or (IsValid(square.Ent) and square.Ent:GetRole())
	if not class then return {} end
	
	if self:GetJumpMove() and self:GetJumpLet()~=0 and self:GetJumpNum()~=0 and (NumToLetter[GridLet]~=self:GetJumpLet() or GridNum~=self:GetJumpNum()) then return {} end
	
	local IsWhite = self:SquareTeam(square)=="White"
	local Moved = self:SquareMoved(square)
	
	local CanJump = IgnoreCap or self:CanCapture( IsWhite )
	local tbl = { ["a"] = {}, ["b"] = {}, ["c"] = {}, ["d"] = {}, ["e"] = {}, ["f"] = {}, ["g"] = {}, ["h"] = {} }
	if class=="King" then
		self:GetKingMoves( tbl, GridLet, GridNum, IsWhite )
	else
		self:GetManMoves( tbl, GridLet, GridNum, IsWhite )
	end
	
	if CanJump then
		for CheckLet,File in pairs(tbl) do
			for CheckNum,v in pairs(File) do
				if v==true then
					tbl[CheckLet][CheckNum] = nil --We can capture, but this isn't a capture move
				end
			end
		end
	end
	return tbl
end

function ENT:ResetBoard()
	if SERVER then
		self.SurrenderOffer = nil
		
		self:SetWhiteWager( -1 )
		self:SetBlackWager( -1 )
		
		self:SetWhiteTime( 900 )
		self:SetBlackTime( 900 )
		
		self:SetJumpMove( false )
		self:SetJumpLet( 0 )
		self:SetJumpNum( 0 )
	end
	self:RefreshSquares()
	
	if self.Pieces then
		for _,File in pairs( self.Pieces ) do
			for _,Square in pairs(File) do
				if IsValid(Square.Ent) then Square.Ent:SetGridNum(-1) Square.Ent:Remove() end
			end
		end
	end
	self.Pieces = {
		["a"] = {
			[1] = {Team="White",Class="Man",Moved=false}, [3] = {Team="White",Class="Man",Moved=false}, [7] = {Team="Black",Class="Man",Moved=false},
		},
		["b"] = {
			[2] = {Team="White",Class="Man",Moved=false}, [6] = {Team="Black",Class="Man",Moved=false}, [8] = {Team="Black",Class="Man",Moved=false},
		},
		["c"] = {
			[1] = {Team="White",Class="Man",Moved=false}, [3] = {Team="White",Class="Man",Moved=false}, [7] = {Team="Black",Class="Man",Moved=false},
		},
		["d"] = {
			[2] = {Team="White",Class="Man",Moved=false}, [6] = {Team="Black",Class="Man",Moved=false}, [8] = {Team="Black",Class="Man",Moved=false},
		},
		["e"] = {
			[1] = {Team="White",Class="Man",Moved=false}, [3] = {Team="White",Class="Man",Moved=false}, [7] = {Team="Black",Class="Man",Moved=false},
		},
		["f"] = {
			[2] = {Team="White",Class="Man",Moved=false}, [6] = {Team="Black",Class="Man",Moved=false}, [8] = {Team="Black",Class="Man",Moved=false},
		},
		["g"] = {
			[1] = {Team="White",Class="Man",Moved=false}, [3] = {Team="White",Class="Man",Moved=false}, [7] = {Team="Black",Class="Man",Moved=false},
		},
		["h"] = {
			[2] = {Team="White",Class="Man",Moved=false}, [6] = {Team="Black",Class="Man",Moved=false}, [8] = {Team="Black",Class="Man",Moved=false},
		},
		[CHESS_WCAP1] = {}, [CHESS_WCAP2] = {}, [CHESS_BCAP1] = {}, [CHESS_BCAP2] = {},
	}
	self:Update()
end

function ENT:CanCapture( White )
	for Let,column in pairs( self.Pieces ) do
		for Num,square in pairs( column ) do
			if square.Team==(White and "White" or "Black") then
				local moves = self:GetMove( Let, Num, true )
				for _,column in pairs( moves ) do
					for _,move in pairs( column ) do
						if type(move)=="table" and move[1]=="CAPTURE" then return true end
					end
				end
			end
		end
	end
	
	return false
end
function ENT:CanMove( White )
	for Let,column in pairs( self.Pieces ) do
		for Num,square in pairs( column ) do
			if square.Team==(White and "White" or "Black") then
				local moves = self:GetMove( Let, Num )
				for _,column in pairs( moves ) do
					for _,move in pairs( column ) do
						if move then return true end
					end
				end
			end
		end
	end
	
	return false
end

function ENT:NoMaterialCheck()
	local BlackMat = {}
	local WhiteMat = {}
	
	for GridLet,File in pairs(self.Pieces) do
		if GridLet==CHESS_WCAP1 or GridLet==CHESS_WCAP2 or GridLet==CHESS_BCAP1 or GridLet==CHESS_BCAP2 then continue end
		for GridNum,square in pairs(File) do
			if square then
				local IsWhite = self:SquareTeam(square)=="White"
				
				if IsWhite then
					table.insert( WhiteMat, {Square=square, Class=Class, GridLet=GridLet, GridNum=GridNum} )
				else
					table.insert( BlackMat, {square=square, Class=Class, GridLet=GridLet, GridNum=GridNum} )
				end
			end
		end
	end
	
	if (#BlackMat+#WhiteMat)==0 then self:EndGame() return false end
	if #WhiteMat==0 then self:EndGame("Black") return false end
	if #BlackMat==0 then self:EndGame("White") return false end
	
	return true
end
function ENT:EndGame( winner, NoMsg )
	self:SetChessState( CHESS_INACTIVE )
	self:SetPlaying( false )
	
	local White = self:GetPlayer( "White" )
	local Black = self:GetPlayer( "Black" )
	local WhiteName = IsValid(White) and White:Nick() or "[Anonymous White]"
	local BlackName = IsValid(Black) and Black:Nick() or "[Anonymous Black]"
	if not NoMsg then
		net.Start( "Chess GameOver" )
			if winner=="White" then
				net.WriteTable( {" ", Color(255,255,255), WhiteName, Color(150,255,150), " has won against ", Color(100,100,100), BlackName, Color(150,255,150), "!"} )
			else
				net.WriteTable( {" ", Color(100,100,100), BlackName, Color(150,255,150), " has won against ", Color(255,255,255), WhiteName, Color(150,255,150), "!"} )
			end
			net.WriteString( "icon16/medal_gold_2.png" )
		net.Broadcast()
	end
	
	timer.Simple( 0.5, function()
		if not IsValid(self) then return end
		if IsValid(Black) and Black:GetVehicle()==self.BlackSeat then Black:ExitVehicle() end
		if IsValid(White) and White:GetVehicle()==self.WhiteSeat then White:ExitVehicle() end
	end)
	if IsValid( White ) then
		if winner=="White" then
			if IsValid(Black) then White:DraughtsWin( Black ) end
			if self.WagerValue then
				if self:GetPSWager() then
					--White:PS_GivePoints( self.WagerValue )
				else
					if White.addMoney then White:addMoney( self.WagerValue ) else White:SetDarkRPVar( "money", (White:getDarkRPVar( "money" ) or 0) + self.WagerValue ) end
				end
			end
		elseif winner=="Black" then
			if IsValid(Black) then White:DraughtsLose( Black ) end
			if self.WagerValue then
				if self:GetPSWager() then
					--White:PS_TakePoints( self.WagerValue )
				else
					if White.addMoney then White:addMoney( -self.WagerValue ) else White:SetDarkRPVar( "money", (White:getDarkRPVar( "money" ) or 0) - self.WagerValue ) end
				end
			end
		elseif winner~="Error" then
			if IsValid(Black) then White:DraughtsDraw( Black ) end
		end
	end
	if IsValid( Black ) then
		if winner=="Black" then
			if IsValid(White) then Black:DraughtsWin( White ) end
			if self.WagerValue then
				if self:GetPSWager() then
					--Black:PS_GivePoints( self.WagerValue )
				else
					if Black.addMoney then Black:addMoney( self.WagerValue ) else Black:SetDarkRPVar( "money", (Black:getDarkRPVar( "money" ) or 0) + self.WagerValue ) end
				end
			end
		elseif winner=="White" then
			if IsValid(White) then Black:DraughtsLose( White ) end
			if self.WagerValue then
				if self:GetPSWager() then
					--Black:PS_TakePoints( self.WagerValue )
				else
					if Black.addMoney then Black:addMoney( -self.WagerValue ) else Black:SetDarkRPVar( "money", (Black:getDarkRPVar( "money" ) or 0) - self.WagerValue ) end
				end
			end
		elseif winner~="Error" then
			if IsValid(White) then Black:DraughtsDraw( White ) end
		end
	end
end
function ENT:DoCapture( square, EndLet, EndNum )
	if not square then return end
	
	local class = square.Class
	
	local made = false
	local CapLet,CapNum
	if square.Team=="White" then --Black captured
		for i=CHESS_BCAP1,CHESS_BCAP2 do
			for n=1,8 do
				local CapSq = self:GetSquare( i, n )
				if not CapSq then
					self.Pieces[i][n] = {Team="White", Class=class, Moved=false}
					CapSq = self.Pieces[i][n]
					
					made = true
					CapLet,CapNum = i,n
					break
				end
			end
			if made then break end
		end
	else
		for i=CHESS_WCAP1,CHESS_WCAP2 do
			for n=1,8 do
				local CapSq = self:GetSquare( i, n )
				if not CapSq then
					self.Pieces[i][n] = {Team="Black", Class=class, Moved=false}
					CapSq = self.Pieces[i][n]
					
					made = true
					CapLet,CapNum = i,n
					break
				end
			end
			if made then break end
		end
	end
	
	return {From={EndLet,EndNum}, To={CapLet,CapNum}}
end
function ENT:DoMove( StartLet, StartNum, EndLet, EndNum )
	if CLIENT then return end
	if not (StartLet and EndLet and StartNum and EndNum) then return end
	if (StartLet==EndLet) and (StartNum==EndNum) then return end
	
	local Start = self:GetSquare( StartLet, StartNum )
	if not Start then return end
	
	local Moves = self:GetMove( StartLet, StartNum )
	if not Moves[EndLet][EndNum] then return end
	local Move = Moves[EndLet][EndNum]
	
	local CapMove
	if type(Move)=="table" then
		if Move[1]=="CAPTURE" then
			local CapLet, CapNum = Move[2], Move[3]
			local square = self:GetSquare( CapLet, CapNum )
			if CapLet and CapNum then
				CapMove = self:DoCapture( square, CapLet, CapNum )
				self.Pieces[CapLet][CapNum] = nil
			end
		end
	end
	
	local End = self:GetSquare( EndLet, EndNum )
	if not End then
		self.Pieces[EndLet] = self.Pieces[EndLet] or {}
		self.Pieces[EndLet][EndNum] = self.Pieces[EndLet][EndNum] or {}
		End = self.Pieces[EndLet][EndNum]
	end
	
	End.Team=Start.Team
	End.Class=Start.Class
	End.Moved=true
	
	self.Pieces[StartLet][StartNum] = nil
	
	local ply = self:GetPlayer( End.Team )
	if (EndNum==1 or EndNum==8) and End.Class=="Man" then --End of the board, promote
		End.Class = "King"
//		self:SetChessState( End.Team=="White" and CHESS_BLACKMOVE or CHESS_WHITEMOVE )
//		
//		self:SetJumpMove( false )
//		self:SetJumpLet( 0 )
//		self:SetJumpNum( 0 )
	end
	if type(Move)=="table" and Move[1]=="CAPTURE" then
		self:SetJumpMove(false)
		if self:CanCapture( End.Team=="White" ) then
			local GetMoves = self:GetMove(EndLet, EndNum)
			local Cap = false
			for _,column in pairs( GetMoves ) do
				for _,move in pairs(column) do
					if move and move~=true then
						Cap=true
					end
				end
			end
			if Cap then
				self:SetJumpMove( true )
				self:SetJumpLet( NumToLetter[EndLet] )
				self:SetJumpNum( EndNum )
			else
				self:SetChessState( End.Team=="White" and CHESS_BLACKMOVE or CHESS_WHITEMOVE )
				
				self:SetJumpMove( false )
				self:SetJumpLet( 0 )
				self:SetJumpNum( 0 )
			end
		else
			self:SetChessState( End.Team=="White" and CHESS_BLACKMOVE or CHESS_WHITEMOVE )
			
			self:SetJumpMove( false )
			self:SetJumpLet( 0 )
			self:SetJumpNum( 0 )
		end
	else --Standard move, other player's turn
		self:SetChessState( End.Team=="White" and CHESS_BLACKMOVE or CHESS_WHITEMOVE )
		
		self:SetJumpMove( false )
		self:SetJumpLet( 0 )
		self:SetJumpNum( 0 )
	end
	
	local move = {From={StartLet,StartNum},To={EndLet,EndNum}}
	self:Update( move, CapMove )
	
	self:NoMaterialCheck()
	
	if self:GetChessState()==CHESS_BLACKMOVE and not self:CanMove( false ) then self:EndGame( "White" ) end
	if self:GetChessState()==CHESS_WHITEMOVE and not self:CanMove( true ) then self:EndGame( "Black" ) end
	
	return move
end

function ENT:GetElo( ply )
	return IsValid(ply) and " ("..ply:GetDraughtsElo()..")" or ""
end

if CLIENT then
	local PanelCol = {
		Main = Color(0,0,0,200), ToMove = Color(200,200,200,20), Text = Color(180,180,180),
		White = Color(255,255,255), Black = Color(20,20,20,255),
	}
	local StateToString = {[CHESS_INACTIVE] = "Waiting", [CHESS_WHITEMOVE] = "White", [CHESS_BLACKMOVE] = "Black", [CHESS_WHITEPROMO] = "White (jumping)", [CHESS_BLACKPROMO] = "Black (jumping)", [CHESS_WAGER] = "Wagers"}
	function ENT:CreateChessPanel()
		local frame = vgui.Create( "DFrame" )
		frame:SetSize(300,115)
		frame:SetPos( (ScrW()/2)-100, ScrH()-150 )
		--frame:SetDraggable( false )
		frame:SetTitle( "" )
		frame:ShowCloseButton( false )
		frame:SetDeleteOnClose( true )
		frame.Paint = function( s,w,h )
			draw.RoundedBox( 8, 0, 0, w, h, PanelCol.Main )
		end
		frame:DockMargin( 0,0,0,0 )
		frame:DockPadding( 5,6,5,5 )
		
		local TimePnl = vgui.Create( "DPanel", frame )
		TimePnl:Dock( RIGHT )
		TimePnl:SetWide( 100 )
		TimePnl:DockMargin( 2,2,2,2 )
		TimePnl.Paint = function(s,w,h)
			draw.RoundedBox( 16, 0, 0, w, (h/2)-1, PanelCol.ToMove )
			draw.RoundedBox( 16, 0, (h/2)+1, w, (h/2)-1, PanelCol.ToMove )
			
			draw.SimpleText( string.FormattedTime( math.Round(self:GetWhiteTime() or 300,1), "%02i:%02i" ), "ChessText", w/2, h/4, PanelCol.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( string.FormattedTime( math.Round(self:GetBlackTime() or 300,1), "%02i:%02i" ), "ChessText", w/2, (h/4)+(h/2), PanelCol.Black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		
		local ToMove = vgui.Create( "DPanel", frame )
		ToMove:SetSize(200,80)
		ToMove:Dock( TOP )
		ToMove.Paint = function( s,w,h )
			draw.RoundedBox( 4, 0, 0, w, h, PanelCol.ToMove )
			draw.SimpleText( "To move", "ChessTextSmall", 5, 0, PanelCol.Text )
			local state = IsValid(self) and self:GetChessState()
			if not (IsValid( self ) and state) then
				draw.SimpleText( "[N/A]", "ChessTextSmall", w/2, h/2, PanelCol.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			else
				local str = (StateToString[state] or "N/A")..( (self:GetPlaying() and self:GetJumpMove() and " (jump)") or "" )
				local col = ((state==CHESS_WHITEMOVE or state==CHESS_WHITEPROMO) and PanelCol.White) or ((state==CHESS_BLACKMOVE or state==CHESS_BLACKPROMO) and PanelCol.Black) or PanelCol.Text
				draw.SimpleText( str, "ChessTextLarge", w/2, h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		end
		
		local ButtonPanel = vgui.Create( "DPanel", frame )
		ButtonPanel:SetSize( 200, 20 )
		ButtonPanel:Dock( BOTTOM )
		ButtonPanel.Paint = function() end
		
		frame.OfferDraw = vgui.Create( "DButton", ButtonPanel)
		frame.OfferDraw:SetSize(60,20)
		frame.OfferDraw:Dock( LEFT )
		frame.OfferDraw:SetText( "Offer Draw" )
		frame.OfferDraw.DoClick = function( s )
			if (IsValid(self)) and not (self:GetPlaying()) then
				chat.AddText( Color(150,255,150), "You can't offer a draw before the game starts!" )
				return
			end
			net.Start( "Chess DrawOffer" ) net.SendToServer()
			s:SetText( "Draw offered" )
		end

		local ShowSpec = vgui.Create( "DButton", ButtonPanel)
		ShowSpec:SetSize(70,20)
		ShowSpec:Dock( RIGHT )
		ShowSpec:SetText( "Hide Players" )
		ShowSpec.DoClick = function( s )
			ChessLocalHideSpectators = not (ChessLocalHideSpectators or false)
		end
		
		local Resign = vgui.Create( "DButton", ButtonPanel)
		Resign:SetSize(56,20)
		Resign:Dock( RIGHT )
		Resign:SetText( "Resign" )
		Resign.DoClick = function( s )
			net.Start( "Chess ClientResign" ) net.SendToServer() --No client-side exit func :/
		end
		
		return frame
	end
end
