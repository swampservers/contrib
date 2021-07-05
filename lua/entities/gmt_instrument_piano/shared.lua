-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
ENT.Base = "gmt_instrument_base"
ENT.Type = "anim"
ENT.PrintName = "Piano"
ENT.Author = "MacDGuy"
ENT.Contact = "http://www.gmtower.org"
ENT.Purpose = "A fully playable piano!"
ENT.Category = "Fun + Games"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Model = Model("models/fishy/furniture/piano.mdl")
local darker = Color(100, 100, 100, 150)

ENT.Keys = {
    [KEY_A] = {
        Sound = "a15",
        Material = "left",
        Label = "A",
        X = 19,
        Y = 86
    },
    [KEY_S] = {
        Sound = "a16",
        Material = "middle",
        Label = "S",
        X = 44,
        Y = 86
    },
    [KEY_D] = {
        Sound = "a17",
        Material = "right",
        Label = "D",
        X = 68,
        Y = 86
    },
    [KEY_F] = {
        Sound = "a18",
        Material = "left",
        Label = "F",
        X = 94,
        Y = 86
    },
    [KEY_G] = {
        Sound = "a19",
        Material = "leftmid",
        Label = "G",
        X = 119,
        Y = 86
    },
    [KEY_H] = {
        Sound = "a20",
        Material = "rightmid",
        Label = "H",
        X = 144,
        Y = 86
    },
    [KEY_J] = {
        Sound = "a21",
        Material = "right",
        Label = "J",
        X = 169,
        Y = 86
    },
    [KEY_K] = {
        Sound = "a22",
        Material = "left",
        Label = "K",
        X = 194,
        Y = 86
    },
    [KEY_L] = {
        Sound = "a23",
        Material = "middle",
        Label = "L",
        X = 219,
        Y = 86
    },
    [KEY_SEMICOLON] = {
        Sound = "a24",
        Material = "right",
        Label = ":",
        X = 244,
        Y = 86
    },
    [KEY_APOSTROPHE] = {
        Sound = "a25",
        Material = "full",
        Label = "'",
        X = 269,
        Y = 86
    },
    [KEY_W] = {
        Sound = "b11",
        Material = "top",
        Label = "W",
        X = 33,
        Y = 31,
        TextX = 7,
        TextY = 90,
        Color = darker
    },
    [KEY_E] = {
        Sound = "b12",
        Material = "top",
        Label = "E",
        X = 64,
        Y = 31,
        TextX = 7,
        TextY = 90,
        Color = darker
    },
    [KEY_T] = {
        Sound = "b13",
        Material = "top",
        Label = "T",
        X = 108,
        Y = 31,
        TextX = 7,
        TextY = 90,
        Color = darker
    },
    [KEY_Y] = {
        Sound = "b14",
        Material = "top",
        Label = "Y",
        X = 136,
        Y = 31,
        TextX = 7,
        TextY = 90,
        Color = darker
    },
    [KEY_U] = {
        Sound = "b15",
        Material = "top",
        Label = "U",
        X = 164,
        Y = 31,
        TextX = 7,
        TextY = 90,
        Color = darker
    },
    [KEY_O] = {
        Sound = "b16",
        Material = "top",
        Label = "O",
        X = 208,
        Y = 31,
        TextX = 7,
        TextY = 90,
        Color = darker
    },
    [KEY_P] = {
        Sound = "b17",
        Material = "top",
        Label = "P",
        X = 239,
        Y = 31,
        TextX = 7,
        TextY = 90,
        Color = darker
    },
}

ENT.AdvancedKeys = {
    [KEY_1] = {
        Sound = "a1",
        Material = "left",
        Label = "1",
        X = 19,
        Y = 86,
        Shift = {
            Sound = "b1",
            Material = "top",
            Label = "!",
            X = 33,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    [KEY_2] = {
        Sound = "a2",
        Material = "middle",
        Label = "2",
        X = 44,
        Y = 86,
        Shift = {
            Sound = "b2",
            Material = "top",
            Label = "@",
            X = 64,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    [KEY_3] = {
        Sound = "a3",
        Material = "right",
        Label = "3",
        X = 69,
        Y = 86
    },
    [KEY_4] = {
        Sound = "a4",
        Material = "left",
        Label = "4",
        X = 94,
        Y = 86,
        Shift = {
            Sound = "b3",
            Material = "top",
            Label = "$",
            X = 108,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    [KEY_5] = {
        Sound = "a5",
        Material = "leftmid",
        Label = "5",
        X = 119,
        Y = 86,
        Shift = {
            Sound = "b4",
            Material = "top",
            Label = "%",
            X = 136,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    [KEY_6] = {
        Sound = "a6",
        Material = "rightmid",
        Label = "6",
        X = 144,
        Y = 86,
        Shift = {
            Sound = "b5",
            Material = "top",
            Label = "^",
            X = 164,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    [KEY_7] = {
        Sound = "a7",
        Material = "right",
        Label = "7",
        X = 169,
        Y = 86
    },
    [KEY_8] = {
        Sound = "a8",
        Material = "left",
        Label = "8",
        X = 194,
        Y = 86,
        Shift = {
            Sound = "b6",
            Material = "top",
            Label = "*",
            X = 208,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    [KEY_9] = {
        Sound = "a9",
        Material = "middle",
        Label = "9",
        X = 219,
        Y = 86,
        Shift = {
            Sound = "b7",
            Material = "top",
            Label = "(",
            X = 239,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    [KEY_0] = {
        Sound = "a10",
        Material = "right",
        Label = "0",
        X = 244,
        Y = 86
    },
    [KEY_Q] = {
        Sound = "a11",
        Material = "left",
        Label = "q",
        X = 269,
        Y = 86,
        Shift = {
            Sound = "b8",
            Material = "top",
            Label = "Q",
            X = 283,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    [KEY_W] = {
        Sound = "a12",
        Material = "leftmid",
        Label = "w",
        X = 294,
        Y = 86,
        Shift = {
            Sound = "b9",
            Material = "top",
            Label = "W",
            X = 310,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 310
    [KEY_E] = {
        Sound = "a13",
        Material = "rightmid",
        Label = "e",
        X = 319,
        Y = 86,
        Shift = {
            Sound = "b10",
            Material = "top",
            Label = "E",
            X = 339,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 339
    [KEY_R] = {
        Sound = "a14",
        Material = "right",
        Label = "r",
        X = 344,
        Y = 86
    },
    [KEY_T] = {
        Sound = "a15",
        Material = "left",
        Label = "t",
        X = 369,
        Y = 86,
        Shift = {
            Sound = "b11",
            Material = "top",
            Label = "T",
            X = 383,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 383
    [KEY_Y] = {
        Sound = "a16",
        Material = "middle",
        Label = "y",
        X = 394,
        Y = 86,
        Shift = {
            Sound = "b12",
            Material = "top",
            Label = "Y",
            X = 414,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 415
    [KEY_U] = {
        Sound = "a17",
        Material = "right",
        Label = "u",
        X = 419,
        Y = 86
    },
    [KEY_I] = {
        Sound = "a18",
        Material = "left",
        Label = "i",
        X = 444,
        Y = 86,
        Shift = {
            Sound = "b13",
            Material = "top",
            Label = "I",
            X = 458,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 459
    [KEY_O] = {
        Sound = "a19",
        Material = "leftmid",
        Label = "o",
        X = 469,
        Y = 86,
        Shift = {
            Sound = "b14",
            Material = "top",
            Label = "O",
            X = 486,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 486
    [KEY_P] = {
        Sound = "a20",
        Material = "rightmid",
        Label = "p",
        X = 494,
        Y = 86,
        Shift = {
            Sound = "b15",
            Material = "top",
            Label = "P",
            X = 514,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 515
    [KEY_A] = {
        Sound = "a21",
        Material = "right",
        Label = "a",
        X = 519,
        Y = 86
    },
    [KEY_S] = {
        Sound = "a22",
        Material = "left",
        Label = "s",
        X = 544,
        Y = 86,
        Shift = {
            Sound = "b16",
            Material = "top",
            Label = "S",
            X = 558,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 559
    [KEY_D] = {
        Sound = "a23",
        Material = "middle",
        Label = "d",
        X = 569,
        Y = 86,
        Shift = {
            Sound = "b17",
            Material = "top",
            Label = "D",
            X = 590,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 590
    [KEY_F] = {
        Sound = "a24",
        Material = "right",
        Label = "f",
        X = 594,
        Y = 86
    },
    [KEY_G] = {
        Sound = "a25",
        Material = "left",
        Label = "g",
        X = 619,
        Y = 86,
        Shift = {
            Sound = "b18",
            Material = "top",
            Label = "G",
            X = 633,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 633
    [KEY_H] = {
        Sound = "a26",
        Material = "leftmid",
        Label = "h",
        X = 644,
        Y = 86,
        Shift = {
            Sound = "b19",
            Material = "top",
            Label = "H",
            X = 661,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 661
    [KEY_J] = {
        Sound = "a27",
        Material = "rightmid",
        Label = "j",
        X = 669,
        Y = 86,
        Shift = {
            Sound = "b20",
            Material = "top",
            Label = "J",
            X = 690,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 690
    [KEY_K] = {
        Sound = "a28",
        Material = "right",
        Label = "k",
        X = 694,
        Y = 86
    },
    [KEY_L] = {
        Sound = "a29",
        Material = "left",
        Label = "l",
        X = 719,
        Y = 86,
        Shift = {
            Sound = "b21",
            Material = "top",
            Label = "L",
            X = 734,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 734
    [KEY_Z] = {
        Sound = "a30",
        Material = "middle",
        Label = "z",
        X = 744,
        Y = 86,
        Shift = {
            Sound = "b22",
            Material = "top",
            Label = "Z",
            X = 765,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 765
    [KEY_X] = {
        Sound = "a31",
        Material = "right",
        Label = "x",
        X = 769,
        Y = 86
    },
    [KEY_C] = {
        Sound = "a32",
        Material = "left",
        Label = "c",
        X = 794,
        Y = 86,
        Shift = {
            Sound = "b23",
            Material = "top",
            Label = "C",
            X = 809,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 809
    [KEY_V] = {
        Sound = "a33",
        Material = "leftmid",
        Label = "v",
        X = 819,
        Y = 86,
        Shift = {
            Sound = "b24",
            Material = "top",
            Label = "V",
            X = 837,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 837
    [KEY_B] = {
        Sound = "a34",
        Material = "rightmid",
        Label = "b",
        X = 844,
        Y = 86,
        Shift = {
            Sound = "b25",
            Material = "top",
            Label = "B",
            X = 865,
            Y = 31,
            TextX = 7,
            TextY = 90,
            Color = darker
        },
    },
    -- 865
    [KEY_N] = {
        Sound = "a35",
        Material = "right",
        Label = "n",
        X = 869,
        Y = 86
    },
    [KEY_M] = {
        Sound = "a36",
        Material = "full",
        Label = "m",
        X = 894,
        Y = 86
    },
}
