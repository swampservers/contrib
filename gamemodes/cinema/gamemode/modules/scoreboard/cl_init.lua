-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

SCOREBOARD = {}
SCOREBOARD.TheaterHeight = 456
SCOREBOARD.CurrentHeight = 256

function SCOREBOARD:Init()

	self:SetZPos( 2 )
	self:SetSize( 512 + 288 + 256, 256 )

	self.PlayerList = vgui.Create( "ScoreboardPlayerList", self )
	self.TheaterList = vgui.Create( "ScoreboardTheaterList", self )
	self.Settings = vgui.Create( "ScoreboardSettings", self )

end

function SCOREBOARD:Paint( w, h )

	-- Render the background
	surface.SetDrawColor(BrandColorGrayDarker)
	surface.DrawRect( 0, 0, self.PlayerList:GetWide() + 1, self:GetTall() )

end

function SCOREBOARD:PerformLayout()

	self:Center()

	self.PlayerList:SetWide( 512 )

	self.TheaterList:SetWide( 288 )
	self.TheaterList:AlignLeft( self.PlayerList:GetWide() )

	self.Settings:SetWide( 256 )
	self.Settings:AlignLeft( self.PlayerList:GetWide() + self.TheaterList:GetWide( ) )
	
	-- Animate
	local curTall = math.max( self.Settings:GetTall(), self.TheaterList:GetTall(), self.PlayerList:GetTall() )
	curTall = math.Clamp( curTall, 256, ScrH() * .8 )
	self.CurrentHeight = math.Approach( self.CurrentHeight, curTall, FrameTime() * 400 )

	self:SetTall( self.CurrentHeight )

end

vgui.Register( "Scoreboard", SCOREBOARD )


if ValidPanel( Gui ) then 
	Gui:Remove()
	Gui = nil
end

if ValidPanel( GuiQueue ) then
	GuiQueue:Remove()
	GuiQueue = nil
end

if ValidPanel( GuiAdmin ) then
	GuiAdmin:Remove()
	GuiAdmin = nil
end

function GM:ScoreboardShow()

	if !ValidPanel( Gui ) then
		Gui = vgui.Create( "Scoreboard" )
	end

	Gui:InvalidateLayout()
	Gui:SetVisible( true )

end

function GM:ScoreboardHide()

	if ValidPanel( Gui ) then
	    Gui:SetVisible( false )
	    GAMEMODE:HideMouse()
	    CloseDermaMenus()
	end

end

GM.MouseEnabled = false

function GM:ShowMouse()
	if self.MouseEnabled then return end
	gui.EnableScreenClicker( true )
	RestoreCursorPosition()
	self.MouseEnabled = true
end

function GM:HideMouse()
	if !self.MouseEnabled then return end
	RememberCursorPosition()
	gui.EnableScreenClicker( false )
	self.MouseEnabled = false
end

hook.Add( "OnVideoVote", "SortQueueList", function()

	-- Resort the video queue after voting
	if IsValid( GuiQueue ) and GuiQueue:IsVisible() then
		GuiQueue:SortList()
	end

end )

function GM:MenuShow()

	if !IsValid(LocalPlayer()) or !LocalPlayer().GetTheater then return end

	local Theater = LocalPlayer():GetTheater()
	if !Theater then return end

	if not LocalPlayer():Alive() then 
        return 
    end
	
	-- Queue
	if !ValidPanel( GuiQueue ) then
		GuiQueue = vgui.Create( "ScoreboardQueue" )
	end

	GuiQueue:InvalidateLayout()
	GuiQueue:SetVisible( true )

	GAMEMODE:ShowMouse()

	if  (Theater:IsPrivate() and Theater:GetOwner() == LocalPlayer()) or
		(LocalPlayer():StaffControlTheater()) then

		if !ValidPanel( GuiAdmin ) then
			GuiAdmin = vgui.Create( "ScoreboardAdmin" )
		end

		GuiAdmin:InvalidateLayout()
		GuiAdmin:SetVisible( true )

	end

end
concommand.Add("+menu", GM.MenuShow ) 
concommand.Add("+menu_context", GM.MenuShow )

function GM:MenuHide()

	if ValidPanel( GuiQueue ) then
		GuiQueue:SetVisible( false )
	end

	if ValidPanel( GuiAdmin ) then
		GuiAdmin:SetVisible( false )
	end

	GAMEMODE:HideMouse()

end
concommand.Add("-menu", GM.MenuHide ) 
concommand.Add("-menu_context", GM.MenuHide )

-- Scroll playerlist
hook.Add( "PlayerBindPress", "PlayerListScroll", function( ply, bind, pressed )

	local guiVisible = ( ValidPanel(Gui) and Gui:IsVisible() )

	if bind == "+attack" then

		-- Show mouse if the scoreboard or queue menu are open
		if not GAMEMODE.MouseEnabled and ( guiVisible or
			( ValidPanel(GuiQueue) and GuiQueue:IsVisible() ) ) then

			GAMEMODE:ShowMouse()
			return true

		end

	end

	if guiVisible then

		if bind == "invnext" then
			Gui.PlayerList.PlayerList.VBar:AddScroll(2)
			return true
		elseif bind == "invprev" then
			Gui.PlayerList.PlayerList.VBar:AddScroll(-2)
			return true
		end

	end

end )

hook.Add( "GUIMousePressed", "RequestClose", function( key )

	if key == MOUSE_LEFT then

		-- Check if the user clicked outside of the request panel. If so,
		-- close the panel.
		if ValidPanel(RequestPanel) then
			RequestPanel:CheckClose()
		end

	end

end )

local function InjectResourceMonitor(panel)
	panel:RunJavascript([[
		function RestoreConsole(){ //skids disabling the console
			console.log=null;
			console.log;
			delete console.log;
			var i=document.createElement('iframe');
			i.style.display='none';
			document.body.appendChild(i);
			window.console=i.contentWindow.console;
		}
		var resource_list=[];
		setInterval(function(){
			var priority = [];
			var iframes=document.getElementsByTagName("iframe");
			for(var i=0;i<iframes.length;i++){
				if(iframes[i].src){
					priority[iframes[i].src]=1;
					if(iframes[i].getAttribute("mozallowfullscreen") || iframes[i].allowFullscreen)priority[iframes[i].src]++;
				}
			}
			var videos=document.getElementsByTagName("video");
			for(var i=0;i<videos.length;i++){
				if(videos[i].src){
					priority[videos[i].src]=5;
					if(videos[i].muted) priority[videos[i].src]=0;
				}
			}
			var sources=document.getElementsByTagName("source");
			for(var i=0;i<sources.length;i++){
				if(sources[i].src){
					priority[sources[i].src]=2;
				}
			}
			for(var key in priority)console.log(priority[key]+"|"+key);
			console.log(location.href);
			if(performance===undefined){return}
			var resources=performance.getEntriesByType("resource");
			if(resources===undefined || resources.length<=0){return}
			RestoreConsole();
			var il=resource_list.length;
			for(var i=il;i<resources.length;i++){console.log(resources[i].name)}
			resource_list=resources;
		},100);
	]])
end

function CinemaResourceMonitor(html)
	
	html.f = vgui.Create("DFrame",html)
	html.f:SetSize(500,500)
	html.f:MakePopup()
	html.f:SetTitle("")
	
	local urls = {}
	
	function html.f:Close()
		urls = {}
		html.f:Remove()
		html.f = nil
		html.Browser.OnDocumentReady = function(panel,url)
			html.Controls.AddressBar:SetText(url)
			if theater.ExtractURLInfo(url) then
				html.Controls.RequestButton:SetDisabled(false)
			else
				html.Controls.RequestButton:SetDisabled(true)
			end
		end
		function html.Browser:ConsoleMessage(msg)
		end
		return
	end
	
	local LinkList = vgui.Create("DScrollPanel",html.f)
	LinkList:Dock(FILL)
	
	html.Browser.OnDocumentReady = function(panel,url)
		LinkList:Clear()
		urls = {}
		InjectResourceMonitor(html.Browser)
		html.Controls.AddressBar:SetText(url)
		if theater.ExtractURLInfo(url) then
			html.Controls.RequestButton:SetDisabled(false)
		else
			html.Controls.RequestButton:SetDisabled(true)
		end
	end
	
	
	function html.Browser:ConsoleMessage(msg)
		local col = Color(255,255,255)
		local smsg = tostring(msg)
		if (url.parse2(smsg)) then
			local m = smsg
			local pair = nil
			if (string.find(smsg,"|")) then
				pair = string.Split(smsg,"|")
				m = pair[2]
			end
			if (string.StartWith(m,"blob:")) then return end
			if ((string.find(smsg,"|") or theater.ExtractURLInfo(smsg)) and not urls[m]) then
				if (pair and tonumber(pair[1])==nil) then return end
				if (pair and tonumber(pair[1])<2) then return end
				local p = LinkList:Add("DButton")
				p:SetText(m)
				p:SetTooltip(m)
				p:Dock(TOP)
				p:SetContentAlignment(4)
				p:SetFont("ScoreboardVidDuration")
				p:SetColor((theater.ExtractURLInfo(m) and Color(0,255,0)) or Color(255,255,0))
				if theater.ExtractURLInfo(m) then print(m) end
				function p:DoClick()
					if (theater.ExtractURLInfo(m)) then
						RequestVideoURL(m)
						html:Remove()
					else
						html.Browser:RunJavascript("location.href='"..m.."'")
					end
				end
				p.Paint = function(self,w,h)
					if self:IsHovered() then
						surface.SetDrawColor(0,0,0,100)
						surface.DrawRect(0,0,w,h)
					end
				end
				urls[m] = true
			end
		end
	end
	
end
