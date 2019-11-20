

CreateClientConVar("cinema_drawnames", 1, true, false )
CreateClientConVar("cinema_lightfx", 0, true, false )
CreateClientConVar("cinema_volume", 50, true, false )
CreateClientConVar("cinema_muteall", 0, true, true )
MuteAFKConVar = CreateClientConVar("cinema_muteafk", 0, true, true )
--CreateClientConVar("cinema_mutegame", 0, true, true )
CreateClientConVar("cinema_gamevolume", 1, true, false )
CreateClientConVar("cinema_hd", 0, true, false )
CreateClientConVar("cinema_cc", 0, true, false )
CreateClientConVar("cinema_hideinterface", 0, true, false )
CreateClientConVar("cinema_resolution", 720, true, false )
local MuteNoFocus = CreateClientConVar("cinema_mute_nofocus", 1, true, false )
local ScrollAmount = CreateClientConVar("cinema_scrollamount", 60, true, false )
local HidePlayers = CreateClientConVar("cinema_hideplayers", 0, true, false )
local HideAmount = CreateClientConVar("cinema_hide_amount", 0.11, true, false )

--[[
timer.Simple(2,function()
	timer.Create("volumeUPDATEEDS",0.2,0,function()

		if GetConVarNumber("volume")>0 then RunConsoleCommand("cinema_gamevolume",GetConVarNumber("volume")) end
		if LocalPlayer():InTheater() and GetConVarNumber("cinema_mutegame")>0 then --and (not isPauseMenuOpen) then --pause menu unmute?
			if GetConVarNumber("volume")>0 then RunConsoleCommand("volume",0) end
		else
			if GetConVarNumber("volume")==0 then RunConsoleCommand("volume",GetConVarNumber("cinema_gamevolume")) end
		end  
	end)
end)

cvars.AddChangeCallback( "cinema_mutegame", function(cmd, old, new)
	new = tonumber(new)
	old = tonumber(old)
	if old==0 and new==1 then
		Derma_Message( "If you leave the game while in a theater with this enabled, your game stay muted! Go to Options > Audio and drag Game Volume back up to fix this.", "Warning", "OK" )
	end
end)]]

concommand.Add("cinema_requestlast", function()
	if LastURLRequested then
		RequestVideoURL( LastURLRequested )
	else
		local thelastrequest = nil
		local thevurl = nil
		for _, request in pairs( theater.GetRequestHistory() ) do
			if not thelastrequest then thelastrequest = request.lastRequest end
			if thelastrequest < request.lastRequest then thevurl = request.url end
			thelastrequest = request.lastRequest
		end
		if thevurl then
			RequestVideoURL( thevurl )
		end
	end
end)

cvars.AddChangeCallback( "cinema_hd", function(cmd, old, new)
	new = tonumber(new)
	
	if !new then
		return
	elseif new < 1 then
		RunConsoleCommand( "cinema_resolution", "720" )
	else
		RunConsoleCommand( "cinema_resolution", "1080" )
	end
end)

cvars.AddChangeCallback( "cinema_resolution", function(cmd, old, new)
	new = tonumber(new)
	
	if !new then
		return
	elseif new < 2 then
		RunConsoleCommand( "cinema_resolution", 2 )
	elseif new > 1080 then
		RunConsoleCommand( "cinema_resolution", 1080 )
	else
		theater.ResizePanel()
	end
end)

cvars.AddChangeCallback( "cinema_volume", function(cmd, old, new)
	new = tonumber(new)
	
	if !new then
		return
	elseif new < 0 then
		RunConsoleCommand( "cinema_volume", 0 )
	elseif new > 100 then
		RunConsoleCommand( "cinema_volume", 100 )
	else
		theater.SetVolume(new)
		if MusicPagePanel then MusicPagePanel:RunJavascript("setVolume("..tostring(new)..");") end
	end
end)

concommand.Add( "cinema_refresh", function()
	theater.RefreshPanel(true)
end )

concommand.Add( "cinema_fullscreen", function() theater.ToggleFullscreen() end)

-- Mute theater on losing focus to Garry's Mod window
local FocusState, HasFocus, LastVolume = true, true, false
hook.Add( "Think", "TheaterMuteOnFocusChange", function()

	if LastVolume == false then LastVolume = theater.GetVolume() end

	if not MuteNoFocus:GetBool() then return end

	HasFocus = system.HasFocus()

	if ( LastState and !HasFocus ) or ( !LastState and HasFocus ) then
		
		if HasFocus == true then
			theater.SetVolume( LastVolume )
			if MusicPagePanel then MusicPagePanel:RunJavascript("setVolume("..tostring(LastVolume)..");") end
			LastVolume = nil
		else
			LastVolume = theater.GetVolume()
			theater.SetVolume( 0 )
			if MusicPagePanel then MusicPagePanel:RunJavascript("setVolume(0);") end
		end

		LastState = HasFocus

	end

end )

