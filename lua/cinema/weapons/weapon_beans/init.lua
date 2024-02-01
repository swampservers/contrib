-- This file is subject to copyright - contact swampservers@gmail.com for more information.
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("Beans_Eat")
util.AddNetworkString("Beans_Eat_Start")

if SERVER then
    timer.Create("BeansFart", 1.7, 0, function()
        for k, ply in ipairs(Ents.player) do
            if ply.BeansEaten ~= nil and ply.BeansEaten > 0 and math.random(0, 25) < ply.BeansEaten then
                BeanFart(ply)
                ply.BeansEaten = math.Clamp(ply.BeansEaten - math.random(0, 25), 0, 100000)
            end
        end
    end)
end

function BeanFart(ply)
    if not IsValid(ply) then return end
    ply:ExtEmitSound("fart/shitpants.wav")
    local pos = ply:GetPos()

    for _, v in ipairs(Ents.player) do
        if v:IsProtected() then continue end
        if v == ply then continue end
        if v:GetNWBool("spacehat") then continue end

        if v:GetPos():Distance(pos) < 140 then
            local d = DamageInfo()
            d:SetDamage(math.random(3, math.max(3, ply.BeansEaten * 2)))
            d:SetAttacker(ply)
            --spawn a beans temporarily as an inflictor if one doesnt exist
            local tempbeans

            if not ply:HasWeapon("weapon_beans") then
                tempbeans = ents.Create("weapon_beans")
                tempbeans:SetPos(Vector(0, 0, 3600))
                tempbeans:Spawn()
                tempbeans:Activate()

                if IsValid(tempbeans:GetPhysicsObject()) then
                    tempbeans:GetPhysicsObject():EnableMotion(false)
                end
            end

            if IsValid(tempbeans) then
                d:SetInflictor(tempbeans)
            end

            if ply:HasWeapon("weapon_beans") then
                d:SetInflictor(ply:GetWeapon("weapon_beans"))
            end

            d:SetDamageType(DMG_POISON)
            v:TakeDamageInfo(d)

            timer.Simple(0, function()
                if IsValid(tempbeans) then
                    tempbeans:Remove()
                end
            end)
        end
    end
end