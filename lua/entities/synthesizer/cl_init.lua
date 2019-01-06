include("shared.lua")

ENT.AllowAdvancedMode = true

// For drawing purposes
// Override by adding MatWidth/MatHeight to key data
ENT.DefaultMatWidth = 32
ENT.DefaultMatHeight = 128
// Override by adding TextX/TextY to key data
ENT.DefaultTextX = 11
ENT.DefaultTextY = 100
ENT.DefaultTextColor = Color( 150, 150, 150, 150 )
ENT.DefaultTextColorActive = Color( 80, 80, 80, 150 )
ENT.DefaultTextInfoColor = Color( 255, 255, 255, 200 )

ENT.MaterialDir	= "gmod_tower/instruments/piano/piano_note_"

ENT.KeyMaterials = {
	["left"] = ENT.MaterialDir .. "left",
	["leftmid"] = ENT.MaterialDir .. "leftmid",
	["right"] = ENT.MaterialDir .. "right",
	["rightmid"] = ENT.MaterialDir .. "rightmid",
	["middle"] = ENT.MaterialDir .. "middle",
	["top"] = ENT.MaterialDir .. "top",
	["full"] = ENT.MaterialDir .. "full",
}

ENT.MainHUD = {
	Material = "gmod_tower/instruments/piano/piano",
	X = ( ScrW() / 2 ) - ( 313 / 2 ),
	Y = ScrH() - 316,
	TextureWidth = 512,
	TextureHeight = 256,
	Width = 313,
	Height = 195,
}

ENT.AdvMainHUD = {
	Material = "gmod_tower/instruments/piano/piano_large",
	X = ( ScrW() / 2 ) - ( 940 / 2 ),
	Y = ScrH() - 316,
	TextureWidth = 1024,
	TextureHeight = 256,
	Width = 940,
	Height = 195,
}

ENT.BrowserHUD = {
	URL = "http://www.gmtower.org/apps/instruments/piano.php?",
	Show = true, // display the sheet music?
	X = ( ScrW() / 2 ),
	Y = ENT.MainHUD.Y - 190,
	Width = 450,
	Height = 250,
	AdvWidth = 600,
}

function ENT:CtrlMod()

	self:ToggleAdvancedMode()

	if self.OldKeys then
		self.Keys = self.OldKeys
		self.OldKeys = nil
	else
		self.OldKeys = self.Keys
		self.Keys = self.AdvancedKeys
	end

end

function ENT:ShiftMod()
	self:ToggleShiftMode()
end

function ENT:AltMod()
	self:CycleInstrument()
end