-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
GM.Name = "Cinema"
GM.Author = "Swamp(STEAM_0:0:38422842) and pixelTail Games"
GM.Email = "swampservers@gmail.com"
GM.Website = "swamp.sv"
GM.Version = "swamp"
GM.TeamBased = false
include('sh_load.lua')
include('player_shd.lua')
include('player_class/player_lobby.lua')
include('translations.lua')
include('animations.lua')
Loader.Load("extensions")
Loader.Load("modules")

--[[
-- Load Map configuration file
local strMap = GM.FolderName .. "/gamemode/maps/" .. game.GetMap() .. ".lua"
if file.Exists( strMap, "LUA" ) then
	if SERVER then
		AddCSLuaFile( strMap )
	end
	include( strMap )
end
]]
--
function GM:CreateTeams()
end

--[[---------------------------------------------------------
	 Name: gamemode:PlayerShouldTakeDamage
	 Return true if this player should take damage from this attacker
-----------------------------------------------------------]]
function GM:PlayerShouldTakeDamage(ply, attacker)
    if attacker:GetClass() == "sent_popcorn_thrown" then return false end
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
    att = dmginfo:GetAttacker()

    if (dmginfo:GetInflictor() and dmginfo:GetInflictor():IsValid() and dmginfo:GetInflictor():GetClass() == "npc_grenade_frag") then
        dmginfo:ScaleDamage(2) --100)
    end

    if (dmginfo:GetAttacker() and dmginfo:GetAttacker():IsValid() and dmginfo:GetAttacker():GetClass() == "player" and dmginfo:GetAttacker():GetActiveWeapon() and dmginfo:GetAttacker():GetActiveWeapon():IsValid() and dmginfo:GetAttacker():GetActiveWeapon():GetClass() == "weapon_shotgun") then
        dmginfo:ScaleDamage(2)
    end

    if (dmginfo:GetAttacker() and dmginfo:GetAttacker():IsValid() and dmginfo:GetAttacker():GetClass() == "player" and dmginfo:GetAttacker():GetActiveWeapon() and dmginfo:GetAttacker():GetActiveWeapon():IsValid() and dmginfo:GetAttacker():GetActiveWeapon():GetClass() == "weapon_slam") then
        dmginfo:ScaleDamage(1.5)
    end

    if IsValid(att) and att:GetClass() == "player" and IsValid(att:GetActiveWeapon()) and att:GetActiveWeapon():GetClass() == "weapon_crowbar" then
        dmginfo:SetDamage(25) -- gmod june 2020 update sets crowbar damage to 10, set it back to 25
    end
end

function GM:GetGameDescription()
    return self.Name
end

function GM:ShouldCollide(Ent1, Ent2)
    return false
end

function GM:Move(ply, mv)
end

-- if (player_manager.RunClass(ply, "Move", mv)) then return true end
function GM:SetupMove(ply, mv, cmd)
end

-- if (player_manager.RunClass(ply, "StartMove", mv, cmd)) then  return true end
function GM:FinishMove(ply, mv)
end

-- if (player_manager.RunClass(ply, "FinishMove", mv)) then return true end
-- Allow physgun pickup of players ONLY ... maybe add trash and some other stuff?... dont forget PROTECTION for this
function GM:PhysgunPickup(ply, ent)
    if ent:IsPlayer() and ent:Alive() and not ent:IsProtected() and not ply:IsProtected() and not ent:IsFrozen() then
        if ent.Obesity and ent:Obesity() > 40 then return end

        return true
    end

    if ply:GetMoveType() == MOVETYPE_NOCLIP then return true end

    return false
end
