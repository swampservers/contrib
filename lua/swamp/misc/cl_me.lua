-- This file is subject to copyright - contact swampservers@gmail.com for more information.

hook.Add("Think", "FindMe", function()
    if IsValid(LocalPlayer()) then 
        Me=LocalPlayer() 
        hook.Remove("Think","FindMe")
        timer.Create("CheckMe",1,0,function()
            if not IsValid(Me) then print("Me INVALID") ErrorNoHalt() end
        end)
    end
end)