-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function makeDodgeball(pos, vel, player)
    local e = ents.Create("dodgeball")
    e.thrower = player
    e:SetPos(pos)
    e:Spawn()
    e:Activate()
    e:GetPhysicsObject():AddVelocity(vel)
end

local gymLocCenter = GetLocationCenterByName("Gym")

timer.Create("dodgeballcontroller", 1, 0, function()
    local ingymcount = 0
    local outgymcount = 0

    for _, ent in ipairs(Ents.weapon_dodgeball) do
        if ent:GetLocationName():StartWith("Gym") then
            ingymcount = ingymcount + 1
        else
            outgymcount = outgymcount + 1
        end
    end

    for _, ent in ipairs(Ents.dodgeball) do
        if ent:GetLocationName():StartWith("Gym") then
            ingymcount = ingymcount + 1
            ent.OutsideGymTime = nil

            if ingymcount > 6 then
                ent:Remove()
            end
        else
            outgymcount = outgymcount + 1

            if not ent.OutsideGymTime then
                ent.OutsideGymTime = CurTime()
            end

            if ent:InTheater() or CurTime() - ent.OutsideGymTime > 900 or outgymcount > 6 then
                ent:Remove()
            end
        end
    end

    if ingymcount < 5 then
        makeDodgeball(gymLocCenter + Vector(math.Rand(-442, 442), math.Rand(-300, 300), -64), Vector(0, 0, 0), nil)
    end
end)
