-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local LastNoFocusTime = 0

hook.Add("CreateMove", "NoWindowClickShoot", function(cmd)
    if not system.HasFocus() then
        LastNoFocusTime = CurTime()
    end

    if CurTime() - LastNoFocusTime < 0.3 then
        cmd:RemoveKey(IN_ATTACK)
        cmd:RemoveKey(IN_ATTACK2)
    end
end)
