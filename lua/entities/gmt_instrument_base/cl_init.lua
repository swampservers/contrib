-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

include("shared.lua")

ENT.DEBUG = false

ENT.KeysDown = {}
ENT.KeysWasDown = {}

ENT.AllowAdvancedMode = false
ENT.AdvancedMode = false
ENT.ShiftMode = false

ENT.PageTurnSound = Sound( "GModTower/inventory/move_paper.wav" )
surface.CreateFont( "InstrumentKeyLabel", {
	size = 22, weight = 400, antialias = true, font = "Impact"
} )
surface.CreateFont( "InstrumentNotice", {
	size = 30, weight = 400, antialias = true, font = "Impact"
} )

// For drawing purposes
// Override by adding MatWidth/MatHeight to key data
ENT.DefaultMatWidth = 128
ENT.DefaultMatHeight = 128
// Override by adding TextX/TextY to key data
ENT.DefaultTextX = 5
ENT.DefaultTextY = 10
ENT.DefaultTextColor = Color( 150, 150, 150, 255 )
ENT.DefaultTextColorActive = Color( 80, 80, 80, 255 )
ENT.DefaultTextInfoColor = Color( 120, 120, 120, 150 )

ENT.MaterialDir	= ""
ENT.KeyMaterials = {}

SynthesizerInstruments = {
	"Synthesizer",
	"eguitar",
	"Guitar",
	"Harp",
	"Organ",
	"Piano",
	"Sax",
	"Violin"
}

ENT.Instruments = SynthesizerInstruments

ENT.MainHUD = {
	Material = nil,
	X = 0,
	Y = 0,
	TextureWidth = 128,
	TextureHeight = 128,
	Width = 128,
	Height = 128,
}

ENT.AdvMainHUD = {
	Material = nil,
	X = 0,
	Y = 0,
	TextureWidth = 128,
	TextureHeight = 128,
	Width = 128,
	Height = 128,
}

ENT.BrowserHUD = {
	URL = "http://www.gmtower.org/apps/instruments/piano.php",
	Show = true, // display the sheet music?
	X = 0,
	Y = 0,
	Width = 1024,
	Height = 768,
}

ENT.QueuedNotes = {}

function ENT:Initialize()
	self:PrecacheMaterials()
end

function ENT:Think()
	self:SetNextClientThink(0)
	--process notes here for maximum responsivness
	local time = SysTime()
	
	local loc = LocalPlayer():GetLocationName()
	
	if (loc == "Trumppenbunker" or loc == "Situation Monitoring Room" or loc == "Weapons Testing Range" or loc == "Office of the Vice President") then
		return true
	end

	for k,v in pairs(self.QueuedNotes) do

		if time>=v.timestamp then

			v.ent:EmitSound( v.sound, 90 )

			// Note effect
			local eff = EffectData()
			eff:SetOrigin(v.pos)
			util.Effect( "musicnotes", eff, true, true )

			table.remove(self.QueuedNotes, k)

		end

	end

	if !IsValid( LocalPlayer().Instrument ) || LocalPlayer().Instrument != self then return end

	if self.DelayKey && self.DelayKey > CurTime() then return end

	// Update last pressed
	for keylast, keyData in pairs( self.KeysDown ) do
		self.KeysWasDown[ keylast ] = self.KeysDown[ keylast ]
	end

	// Get keys
	for key, keyData in pairs( self.Keys ) do

		// Update key status
		self.KeysDown[ key ] = input.IsKeyDown( key )

		// Check for note keys
		if self:IsKeyTriggered( key ) then
		
			if self.ShiftMode && keyData.Shift then
				self:OnRegisteredKeyPlayed( keyData.Shift.Sound )
			elseif !self.ShiftMode then
				self:OnRegisteredKeyPlayed( keyData.Sound )
			end
			
		end

	end

	// Get control keys
	for key, keyData in pairs( self.ControlKeys ) do

		// Update key status
		self.KeysDown[ key ] = input.IsKeyDown( key )

		// Check for control keys
		if self:IsKeyTriggered( key ) then
			keyData( self, true )
		end
		
		// was a control key released?
		if self:IsKeyReleased( key ) then
			keyData( self, false )
		end

	end

	// Send da keys to everyone
	//self:SendKeys()
	return true
end

function ENT:IsKeyTriggered( key )
	return self.KeysDown[ key ] && !self.KeysWasDown[ key ]
end

function ENT:IsKeyReleased( key )
	return self.KeysWasDown[ key ] && !self.KeysDown[ key ]
end

function ENT:OnRegisteredKeyPlayed( key )

	// Play on the client first
	local sound = self:GetSound( key )
	local playtime = SysTime()
	self:EmitSound( sound, 100 )

	//Note effect
	local pos = string.sub( key, 2, 3 )
	pos = math.Fit( tonumber( pos ), 1, 36, -3.8, 4 )
	pos = LocalPlayer():GetPos() + Vector( -15, pos * 10, -5 ) 
	local eff = EffectData()
	eff:SetOrigin(pos)
	util.Effect( "musicnotes", eff, true, true )

	// Network it
	net.Start( "InstrumentNetwork" )

		net.WriteEntity( self )
		net.WriteInt( INSTNET_PLAY, 3 )
		net.WriteString( key )
		net.WriteDouble(playtime)

	net.SendToServer()

end

// Network it up, yo
function ENT:SendKeys()

	if !self.KeysToSend then return end

	// Send the queue of notes to everyone

	// Play on the client first
	for _, key in ipairs( self.KeysToSend ) do

		local sound = self:GetSound( key )

		if sound then
			self:EmitSound( sound, 100 )
		end

	end

	// Clear queue
	self.KeysToSend = nil

end

function ENT:DrawKey( mainX, mainY, key, keyData, bShiftMode )

	if keyData.Material then
		if ( self.ShiftMode && bShiftMode && input.IsKeyDown( key ) ) ||
		   ( !self.ShiftMode && !bShiftMode && input.IsKeyDown( key ) ) then

			surface.SetTexture( self.KeyMaterialIDs[ keyData.Material ] )
			surface.DrawTexturedRect( mainX + keyData.X, mainY + keyData.Y, 
									  self.DefaultMatWidth, self.DefaultMatHeight )
		end
		
	end

	// Draw keys
	if keyData.Label then

		local offsetX = self.DefaultTextX
		local offsetY = self.DefaultTextY
		local color = self.DefaultTextColor

		if ( self.ShiftMode && bShiftMode && input.IsKeyDown( key ) ) ||
		   ( !self.ShiftMode && !bShiftMode && input.IsKeyDown( key ) ) then
		   
			color = self.DefaultTextColorActive
			if keyData.AColor then color = keyData.AColor end
		else
			if keyData.Color then color = keyData.Color end
		end

		// Override positions, if needed
		if keyData.TextX then offsetX = keyData.TextX end
		if keyData.TextY then offsetY = keyData.TextY end
		
		draw.DrawText( keyData.Label, "InstrumentKeyLabel", 
						mainX + keyData.X + offsetX,
						mainY + keyData.Y + offsetY,
						color, TEXT_ALIGN_CENTER )
	end
end

function ENT:DrawHUD()

	surface.SetDrawColor( 255, 255, 255, 255 )

	local mainX, mainY, mainWidth, mainHeight

	// Draw main
	if self.MainHUD.Material && !self.AdvancedMode then

		mainX, mainY, mainWidth, mainHeight = self.MainHUD.X, self.MainHUD.Y, self.MainHUD.Width, self.MainHUD.Height

		surface.SetTexture( self.MainHUD.MatID )
		surface.DrawTexturedRect( mainX, mainY, self.MainHUD.TextureWidth, self.MainHUD.TextureHeight )

	end

	// Advanced main
	if self.AdvMainHUD.Material && self.AdvancedMode then

		mainX, mainY, mainWidth, mainHeight = self.AdvMainHUD.X, self.AdvMainHUD.Y, self.AdvMainHUD.Width, self.AdvMainHUD.Height

		surface.SetTexture( self.AdvMainHUD.MatID )
		surface.DrawTexturedRect( mainX, mainY, self.AdvMainHUD.TextureWidth, self.AdvMainHUD.TextureHeight )

	end

	// Draw keys (over top of main)
	for key, keyData in pairs( self.Keys ) do
	
		self:DrawKey( mainX, mainY, key, keyData, false )
		
		if keyData.Shift then
			self:DrawKey( mainX, mainY, key, keyData.Shift, true )
		end
	end

	// Sheet music help
	if !ValidPanel( self.Browser ) && self.BrowserHUD.Show then

		draw.DrawText( "SPACE FOR SHEET MUSIC", "InstrumentKeyLabel", 
						mainX + ( mainWidth / 2 ), mainY + 60, 
						self.DefaultTextInfoColor, TEXT_ALIGN_CENTER )

	end

	// Advanced mode
	if self.AllowAdvancedMode && !self.AdvancedMode then

		draw.DrawText( "CONTROL FOR ADVANCED MODE", "InstrumentKeyLabel", 
						mainX + ( mainWidth / 2 ), mainY + mainHeight + 30, 
						self.DefaultTextInfoColor, TEXT_ALIGN_CENTER )
						
	elseif self.AllowAdvancedMode && self.AdvancedMode then
	
		draw.DrawText( "CONTROL FOR BASIC MODE", "InstrumentKeyLabel", 
						mainX + ( mainWidth / 2 ), mainY + mainHeight + 30, 
						self.DefaultTextInfoColor, TEXT_ALIGN_CENTER )
	end

end

// This is so I do not have to do GetTextureID in the table EACH TIME, ugh
function ENT:PrecacheMaterials()

	if !self.Keys then return end

	self.KeyMaterialIDs = {}

	for name, keyMaterial in pairs( self.KeyMaterials ) do
		if type( keyMaterial ) == "string" then // TODO: what the fuck, this table is randomly created
			self.KeyMaterialIDs[name] = surface.GetTextureID( keyMaterial )
		end
	end

	if self.MainHUD.Material then
		self.MainHUD.MatID = surface.GetTextureID( self.MainHUD.Material )
	end

	if self.AdvMainHUD.Material then
		self.AdvMainHUD.MatID = surface.GetTextureID( self.AdvMainHUD.Material )
	end

end

function ENT:OpenSheetMusic()

	if ValidPanel( self.Browser ) || !self.BrowserHUD.Show then return end

	self.Browser = vgui.Create( "HTML" )
	self.Browser:SetVisible( false )

	local width = self.BrowserHUD.Width

	if self.BrowserHUD.AdvWidth && self.AdvancedMode then
		width = self.BrowserHUD.AdvWidth
	end

	local url = self.BrowserHUD.URL
	
	if self.AdvancedMode then
		url = self.BrowserHUD.URL .. "?&adv=1"
	end
	
	local x = self.BrowserHUD.X - ( width / 2 )

	self.Browser:OpenURL( url )

	// This is delayed because otherwise it will not load at all
	// for some silly reason...
	timer.Simple( .1, function()

		if ValidPanel( self.Browser ) then
			self.Browser:SetVisible( true )
			self.Browser:SetPos( x, self.BrowserHUD.Y )
			self.Browser:SetSize( width, self.BrowserHUD.Height )
		end

	end )

end

function ENT:CloseSheetMusic()

	if !ValidPanel( self.Browser ) then return end

	self.Browser:Remove()
	self.Browser = nil

end

function ENT:ToggleSheetMusic()

	if ValidPanel( self.Browser ) then
		self:CloseSheetMusic()
	else
		self:OpenSheetMusic()
	end

end

function ENT:SheetMusicForward()

	if !ValidPanel( self.Browser ) then return end

	self.Browser:Exec( "pageForward()" )
	self:EmitSound( self.PageTurnSound, 100, math.random( 120, 150 ) )

end

function ENT:SheetMusicBack()

	if !ValidPanel( self.Browser ) then return end

	self.Browser:Exec( "pageBack()" )
	self:EmitSound( self.PageTurnSound, 100, math.random( 100, 120 ) )

end

function ENT:OnRemove()

	self:CloseSheetMusic()

end

function ENT:Shutdown()

	self:CloseSheetMusic()
	
	self.AdvancedMode = false
	self.ShiftMode = false

	if self.OldKeys then
		self.Keys = self.OldKeys
		self.OldKeys = nil
	end

end

function ENT:ToggleAdvancedMode()
	self.AdvancedMode = !self.AdvancedMode
	
	if ValidPanel( self.Browser ) then
		self:CloseSheetMusic()
		self:OpenSheetMusic()
	end
	
end

function ENT:ToggleShiftMode()
	self.ShiftMode = !self.ShiftMode
end

function ENT:CycleInstrument()
	net.Start("ChangeInstrument")
		net.WriteEntity(self)
	net.SendToServer()
end

function ENT:ShiftMod() end // Called when they press shift
function ENT:CtrlMod() end // Called when they press cntrl

hook.Add( "HUDPaint", "InstrumentPaint", function()

	if IsValid( LocalPlayer().Instrument ) then

		// HUD
		local inst = LocalPlayer().Instrument
		inst:DrawHUD()

		// Notice bar
		local name = inst.PrintName or "INSTRUMENT"
		name = string.upper( name )

		surface.SetDrawColor( 0, 0, 0, 180 )
		surface.DrawRect( 0, ScrH() - 60, ScrW(), 60 )

		draw.SimpleText( "PRESS TAB TO LEAVE THE " .. name, "InstrumentNotice", ScrW() / 2, ScrH() - 45, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )

		name = SynthesizerInstruments[inst:GetNWInt("CurrentInstrument")]
		if inst:GetNWInt("CurrentInstrument") == 2 then
			name = "Electric Guitar"
		elseif inst:GetNWInt("CurrentInstrument") == 7 then
			name = "Saxophone"
		end
		draw.SimpleText( "PRESS ALT TO CHANGE THE SYNTHESIZER SOUND: " .. name, "InstrumentNotice", ScrW() / 2, ScrH() - 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )	
	
	end

end )

// Override regular keys
hook.Add( "PlayerBindPress", "InstrumentHook", function( ply, bind, pressed )

	if IsValid( ply.Instrument ) then
		return true
	end

end )

net.Receive( "InstrumentNetwork", function( length, client )

	local ent = net.ReadEntity()
	local enum = net.ReadInt( 3 )

	// When the player uses it or leaves it
	if enum == INSTNET_USE then

		if IsValid( LocalPlayer().Instrument ) then
			LocalPlayer().Instrument:Shutdown()
		end

		ent.DelayKey = CurTime() + .1 // delay to the key a bit so they do not play on use key
		LocalPlayer().Instrument = ent

	// Play the notes for everyone else
	elseif enum == INSTNET_HEAR then

		// Instrument does not exist
		if !IsValid( ent ) then return end

		// Gather note
		local key = net.ReadString()
		local sound = ent:GetSound( key )
		local timestamp = net.ReadDouble()
		local pos = net.ReadVector()

		// Do not play for the owner
		if IsValid( LocalPlayer().Instrument ) && LocalPlayer().Instrument == ent then
			return
		end

		// Calculate timing offset - how much farther ahead the server clock is to ours
		if not inst_timing_offset then
			inst_timing_offset = timestamp - SysTime()
		end

		//Calculate true time when sound should play
		timestamp = timestamp + INST_LATENCY - inst_timing_offset
			
		if sound then
			// Add note to table of notes to be Played
			// We do this instead of timer.Simple because the think hook is much more precise
			table.insert( ent.QueuedNotes, { ent=ent, sound=sound, pos=pos, timestamp=timestamp } )
		end

	end

end )
