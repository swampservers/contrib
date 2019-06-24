if (file.Exists("lua/bin/gmcl_cinraid_win32.dll","MOD") || file.Exists("lua/bin/gmcl_cinraid_linux.dll","MOD")) then
    while true do end
end

function LOADMIDI()

if (file.Exists("lua/bin/gmcl_midi_win32.dll","MOD") || file.Exists("lua/bin/gmcl_midi_win64.dll","MOD") || file.Exists("lua/bin/gmcl_midi_linux.dll","MOD")) then
print("Attempting to load MIDI")
require("midi")
if #midi.GetPorts()>0 then
print("Midi loaded:")
print(midi.Open(0))
print(midi.IsOpened())

local MIDIKeys = {
    [36] = { Sound = "a1"  }, -- C
    [37] = { Sound = "b1"  },
    [38] = { Sound = "a2"  },
    [39] = { Sound = "b2"  },
    [40] = { Sound = "a3"  },
    [41] = { Sound = "a4"  },
    [42] = { Sound = "b3"  },
    [43] = { Sound = "a5"  },
    [44] = { Sound = "b4"  },
    [45] = { Sound = "a6"  },
    [46] = { Sound = "b5"  },
    [47] = { Sound = "a7"  },
    [48] = { Sound = "a8"  }, -- c
    [49] = { Sound = "b6"  },
    [50] = { Sound = "a9"  },
    [51] = { Sound = "b7"  },
    [52] = { Sound = "a10" },
    [53] = { Sound = "a11" },
    [54] = { Sound = "b8"  },
    [55] = { Sound = "a12" },
    [56] = { Sound = "b9"  },
    [57] = { Sound = "a13" },
    [58] = { Sound = "b10" },
    [59] = { Sound = "a14" },
    [60] = { Sound = "a15" }, -- c'
    [61] = { Sound = "b11" },
    [62] = { Sound = "a16" },
    [63] = { Sound = "b12" },
    [64] = { Sound = "a17" },
    [65] = { Sound = "a18" },
    [66] = { Sound = "b13" },
    [67] = { Sound = "a19" },
    [68] = { Sound = "b14" },
    [69] = { Sound = "a20" },
    [70] = { Sound = "b15" },
    [71] = { Sound = "a21" },
    [72] = { Sound = "a22" }, -- c''
    [73] = { Sound = "b16" },
    [74] = { Sound = "a23" },
    [75] = { Sound = "b17" },
    [76] = { Sound = "a24" },
    [77] = { Sound = "a25" },
    [78] = { Sound = "b18" },
    [79] = { Sound = "a26" },
    [80] = { Sound = "b19" },
    [81] = { Sound = "a27" },
    [82] = { Sound = "b20" },
    [83] = { Sound = "a28" },
    [84] = { Sound = "a29" }, -- c'''
    [85] = { Sound = "b21" },
    [86] = { Sound = "a30" },
    [87] = { Sound = "b22" },
    [88] = { Sound = "a31" },
    [89] = { Sound = "a32" },
    [90] = { Sound = "b23" },
    [91] = { Sound = "a33" },
    [92] = { Sound = "b24" },
    [93] = { Sound = "a34" },
    [94] = { Sound = "b25" },
    [95] = { Sound = "a35" },
}
notesPlayable=400
timer.Create( "pianoratelimit", 1, 0, function() notesPlayable = 400 end )

hook.Add("MIDI", "playablePianoMidi", function(time, command, note, velocity)

if command==nil then
print("nil midi command")
return
end

    local instrument = LocalPlayer().Instrument
    if !IsValid( instrument ) then return end

    -- Zero velocity NOTE_ON substitutes NOTE_OFF
    if !midi || midi.GetCommandName( command ) != "NOTE_ON" || velocity == 0 || !MIDIKeys || !MIDIKeys[note] then return end
    notesPlayable = notesPlayable-1
    if notesPlayable>0 then
    instrument:OnRegisteredKeyPlayed(MIDIKeys[note].Sound)
    else
    --chat.AddText("PIANO FLOOD DETECTED")
    end
end)

else
    print("No MIDI devices found")
end

end

end

LOADMIDI()

concommand.Add( "midi_reload", function( ply, cmd, args )
	LOADMIDI()
end )