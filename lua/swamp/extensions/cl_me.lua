-- This file is subject to copyright - contact swampservers@gmail.com for more information.

hook.Add("Think", "Me", function()
    if IsValid(Me) then 
        Me=Me 
        hook.Remove("Think","Me")
        timer.Create("CHECK_Me",1,0,function()
            if not IsValid(Me) then print("Me INVALID") ErrorNoHalt() end
        end)
    end
end)