-- This file is subject to copyright - contact swampservers@gmail.com for more information.

hook.Add("OnEntityCreated", "FindMe", function()
    if IsValid(LocalPlayer()) then 
        --- Use this global instead of LocalPlayer() (it will be either nil or a valid entity)
        Me = LocalPlayer()
        hook.Remove("OnEntityCreated","FindMe")
        timer.Create("CheckMe",5,0,function()
            if not IsValid(Me) then 
                if IsValid(LocalPlayer()) then Me=LocalPlayer() end
                print("Me WENT INVALID")
                ErrorNoHalt()
            end
        end)
    end
end)