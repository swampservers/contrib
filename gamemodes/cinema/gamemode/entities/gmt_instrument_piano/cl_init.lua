-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include("shared.lua")
ENT.AllowAdvancedMode = true
-- For drawing purposes
-- Override by adding MatWidth/MatHeight to key data
ENT.DefaultMatWidth = 32
ENT.DefaultMatHeight = 128
-- Override by adding TextX/TextY to key data
ENT.DefaultTextX = 11
ENT.DefaultTextY = 100
ENT.DefaultTextColor = Color(150, 150, 150, 150)
ENT.DefaultTextColorActive = Color(80, 80, 80, 150)
ENT.DefaultTextInfoColor = Color(46, 20, 6, 255)
ENT.MaterialDir = "gmod_tower/instruments/piano/piano_note_"

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
    X = ScrW() / 2 - 313 / 2,
    Y = ScrH() - 316,
    TextureWidth = 512,
    TextureHeight = 256,
    Width = 313,
    Height = 195,
}

ENT.AdvMainHUD = {
    Material = "gmod_tower/instruments/piano/piano_large",
    X = ScrW() / 2 - 940 / 2,
    Y = ScrH() - 316,
    TextureWidth = 1024,
    TextureHeight = 256,
    Width = 940,
    Height = 195,
}

ENT.BrowserHUD = {
    URL = "http://www.gmtower.org/apps/instruments/piano.php?",
    Show = true, -- display the sheet music?
    X = ScrW() / 2,
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

function MIDI_LOAD()
    -- 
    -- local extensions = {
    --     "win32",
    --     "win64",
    --     "osx",
    --     "linux",
    --     "linux64"
    -- }
    -- local exist = false
    -- for i,ex in ipairs(extensions) do
    --     exist = exist or file.Exists("lua/bin/gmcl_midi_"..ex..".dll", "MOD")
    -- end
    -- if exist then
    -- print("Attempting to load MIDI")
    require("midi")

    if #midi.GetPorts() > 0 then
        print("Midi loaded:")
        print(midi.Open(0))
        print(midi.IsOpened())

        local MIDIKeys = {
            [36] = {
                Sound = "a1"
            },
            -- C
            [37] = {
                Sound = "b1"
            },
            [38] = {
                Sound = "a2"
            },
            [39] = {
                Sound = "b2"
            },
            [40] = {
                Sound = "a3"
            },
            [41] = {
                Sound = "a4"
            },
            [42] = {
                Sound = "b3"
            },
            [43] = {
                Sound = "a5"
            },
            [44] = {
                Sound = "b4"
            },
            [45] = {
                Sound = "a6"
            },
            [46] = {
                Sound = "b5"
            },
            [47] = {
                Sound = "a7"
            },
            [48] = {
                Sound = "a8"
            },
            -- c
            [49] = {
                Sound = "b6"
            },
            [50] = {
                Sound = "a9"
            },
            [51] = {
                Sound = "b7"
            },
            [52] = {
                Sound = "a10"
            },
            [53] = {
                Sound = "a11"
            },
            [54] = {
                Sound = "b8"
            },
            [55] = {
                Sound = "a12"
            },
            [56] = {
                Sound = "b9"
            },
            [57] = {
                Sound = "a13"
            },
            [58] = {
                Sound = "b10"
            },
            [59] = {
                Sound = "a14"
            },
            [60] = {
                Sound = "a15"
            },
            -- c'
            [61] = {
                Sound = "b11"
            },
            [62] = {
                Sound = "a16"
            },
            [63] = {
                Sound = "b12"
            },
            [64] = {
                Sound = "a17"
            },
            [65] = {
                Sound = "a18"
            },
            [66] = {
                Sound = "b13"
            },
            [67] = {
                Sound = "a19"
            },
            [68] = {
                Sound = "b14"
            },
            [69] = {
                Sound = "a20"
            },
            [70] = {
                Sound = "b15"
            },
            [71] = {
                Sound = "a21"
            },
            [72] = {
                Sound = "a22"
            },
            -- c''
            [73] = {
                Sound = "b16"
            },
            [74] = {
                Sound = "a23"
            },
            [75] = {
                Sound = "b17"
            },
            [76] = {
                Sound = "a24"
            },
            [77] = {
                Sound = "a25"
            },
            [78] = {
                Sound = "b18"
            },
            [79] = {
                Sound = "a26"
            },
            [80] = {
                Sound = "b19"
            },
            [81] = {
                Sound = "a27"
            },
            [82] = {
                Sound = "b20"
            },
            [83] = {
                Sound = "a28"
            },
            [84] = {
                Sound = "a29"
            },
            -- c'''
            [85] = {
                Sound = "b21"
            },
            [86] = {
                Sound = "a30"
            },
            [87] = {
                Sound = "b22"
            },
            [88] = {
                Sound = "a31"
            },
            [89] = {
                Sound = "a32"
            },
            [90] = {
                Sound = "b23"
            },
            [91] = {
                Sound = "a33"
            },
            [92] = {
                Sound = "b24"
            },
            [93] = {
                Sound = "a34"
            },
            [94] = {
                Sound = "b25"
            },
            [95] = {
                Sound = "a35"
            },
        }

        notesPlayable = 400

        timer.Create("pianoratelimit", 1, 0, function()
            notesPlayable = 400
        end)

        hook.Add("MIDI", "playablePianoMidi", function(time, command, note, velocity)
            if command == nil then
                print("nil midi command")

                return
            end

            local instrument = Me.Instrument
            if not IsValid(instrument) then return end
            -- Zero velocity NOTE_ON substitutes NOTE_OFF
            if not midi or midi.GetCommandName(command) ~= "NOTE_ON" or velocity == 0 or not MIDIKeys or not MIDIKeys[note] then return end
            notesPlayable = notesPlayable - 1

            if notesPlayable > 0 then
                instrument:OnRegisteredKeyPlayed(MIDIKeys[note].Sound)
            end
        end)
        --chat.AddText("PIANO FLOOD DETECTED")
    else
        print(midi.FAILED and "MIDI binary module (for the piano) wasn't found. Install it from https://github.com/FPtje/gmcl_midi" or "No MIDI devices found")
    end
    -- end
end

concommand.Add("midi_reload", MIDI_LOAD)
