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


timer.Create("dodgeballcontroller", 1, 0, function()
    local ingymcount = 0
    local outgymcount = 0

    for k, v in ipairs(Ents.weapon_dodgeball) do
        if v:GetLocationName():StartWith("Gym") then
            ingymcount = ingymcount + 1
        else
            outgymcount = outgymcount + 1
        end
    end

    for k, v in ipairs(Ents.dodgeball) do
        if v:GetLocationName():StartWith("Gym") then
            ingymcount = ingymcount + 1
            v.OutsideGymTime = nil

            if ingymcount > 6 then
                v:Remove()
            end
        else
            outgymcount = outgymcount + 1

            if not v.OutsideGymTime then
                v.OutsideGymTime = CurTime()
            end

            if v:InTheater() or CurTime() - v.OutsideGymTime > 900 or outgymcount > 6 then
                v:Remove()
            end
        end
    end

    if ingymcount < 5 then
        makeDodgeball(Vector(1360, math.random(-1392 - 32, -1968 - 32), 16), Vector(0, 0, 0), nil)
    end
end)
