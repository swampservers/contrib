-- This file is subject to copyright - contact swampservers@gmail.com for more information.
function Menu(Panel)
    Panel:Button("Character", "ppm_chared3")
    Panel:Button("Set Pony playermodel", "ppm_setpmodel")
    Panel:Button("Set Pony playermodel without jigglebones", "ppm_setpmodel_nojigglebones")
end

concommand.Add("ppm_setpmodel", function()
    RunConsoleCommand("cl_playermodel", "pony")
    RunConsoleCommand("kill")
end)

concommand.Add("ppm_setpmodel_nojigglebones", function()
    RunConsoleCommand("cl_playermodel", "ponynj")
    RunConsoleCommand("kill")
end)

hook.Add("PopulateToolMenu", "ppm_menu", function()
    spawnmenu.AddToolMenuOption("Options", "CPPM", "PonyPlayer", "Pony Player", "", "", Menu, {
        SwitchConVar = "sv_cheats",
    })
end)