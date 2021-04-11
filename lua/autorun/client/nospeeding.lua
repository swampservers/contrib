-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- speedhack detector, disabled in cinema cuz cinema is kinda laggy and this has false positives
timer.Simple(0, function()
    if GAMEMODE.FolderName ~= "cinema" then
        speedinTickCount = 0
        isspeedin = 0

        timer.Create("noSpeedin", 1, 0, function()
            if speedinTickCount > ((1 / engine.TickInterval()) + 2) then
                isspeedin = isspeedin + 1
            else
                isspeedin = 0
            end

            speedinTickCount = 0

            if isspeedin > 5 then
                --crash their game LOL
                while true do
                end
            end
        end)

        hook.Add("Tick", "noSpeedinTick", function()
            speedinTickCount = speedinTickCount + 1
        end)
    end
end)