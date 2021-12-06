-- This file is subject to copyright - contact swampservers@gmail.com for more information.

function GM:PlayerShouldTakeDamage(ply, attacker)
    if attacker:GetClass() == "ent_popcorn_thrown" then return false end
    if attacker:GetClass() == "dodgeball" then return false end
    if ply:IsProtected(attacker) then return false end

    return true
end

function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)
    local inf = dmginfo:GetInflictor()

    if not IsValid(inf) or not inf.GunType then
        if hitgroup == HITGROUP_HEAD then
            dmginfo:ScaleDamage(2)
        end
    end

    if ply:InVehicle() and dmginfo:GetDamageType() == DMG_BURN then
        dmginfo:ScaleDamage(0)
    end
end

function GM:EntityTakeDamage(target, dmginfo)
    local att,inf = dmginfo:GetAttacker(), dmginfo:GetInflictor()
   

    if IsValid(inf) and inf:GetClass() == "npc_grenade_frag" then
        dmginfo:ScaleDamage(2)
    end

    if IsValid(att) and att:IsPlayer() then 
        if  att:UsingWeapon("weapon_shotgun") then
            dmginfo:ScaleDamage(2)
        end

        -- todo use inflictor
        if att:UsingWeapon("weapon_slam") then
            dmginfo:ScaleDamage(1.5)
        end

        if att:UsingWeapon("weapon_crowbar") then
            dmginfo:SetDamage(25) -- gmod june 2020 update sets crowbar damage to 10, set it back to 25
        end
    end
end