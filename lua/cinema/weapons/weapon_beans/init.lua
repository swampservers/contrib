-- This file is subject to copyright - contact swampservers@gmail.com for more information.
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("Beans_Eat")
util.AddNetworkString("Beans_Eat_Start")

if SERVER then
    timer.Create("BeansFart", 1.7, 0, function()
        for k, ply in Ents.PlayerIterator() do
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

    for _, v in Ents.PlayerIterator() do
        if v:IsProtected() then continue end
        if v == ply then continue end
        if v:GetNWBool("spacehat") then continue end

        if v:GetPos():Distance(pos) < 140 then
            local d = DamageInfo()
            d:SetDamage(3)
            d:SetAttacker(ply)
            d:SetDamageType(DMG_POISON)
            v:TakeDamageInfo(d)
        end
    end
end
