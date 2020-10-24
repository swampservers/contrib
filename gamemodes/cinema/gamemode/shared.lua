-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

GM.Name 		= "Cinema"
GM.Author		= "Swamp(STEAM_0:0:38422842) and pixelTail Games"
GM.Email 		= "swampservers@gmail.com"
GM.Website 		= "swampservers.net"
GM.Version 		= "swamp"
GM.TeamBased 	= false

include( 'sh_load.lua' )

include( 'player_shd.lua' )
include( 'player_class/player_lobby.lua' )
include( 'translations.lua' )
include( 'animations.lua' )

Loader.Load( "extensions" )
Loader.Load( "modules" )

--[[
-- Load Map configuration file
local strMap = GM.FolderName .. "/gamemode/maps/" .. game.GetMap() .. ".lua"
if file.Exists( strMap, "LUA" ) then
	if SERVER then
		AddCSLuaFile( strMap )
	end
	include( strMap )
end
]]--

function GM:CreateTeams()
	
end

--[[---------------------------------------------------------
	 Name: gamemode:PlayerShouldTakeDamage
	 Return true if this player should take damage from this attacker
-----------------------------------------------------------]]
function GM:PlayerShouldTakeDamage( ply, attacker )
	if attacker:GetClass()=="sent_popcorn_thrown" then return false end
	if attacker.dodgeball then return false end
	if Safe(ply) or Safe(attacker) then 
		if attacker:IsPlayer() and ply:InTheater() and ply:GetTheater():GetOwner()==attacker then
			return true
		end
		return false
	end
	return true
end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )

	if hitgroup == HITGROUP_HEAD then
		dmginfo:ScaleDamage(2)
	end

	if ply:InVehicle() and dmginfo:GetDamageType()==DMG_BURN then
		dmginfo:ScaleDamage(0)
	end

end

function GM:EntityTakeDamage( target, dmginfo )

	att = dmginfo:GetAttacker()

	if ( dmginfo:GetInflictor() and dmginfo:GetInflictor():IsValid() and dmginfo:GetInflictor():GetClass()=="npc_grenade_frag") then
 
		dmginfo:ScaleDamage( 100 )

	end

	if ( dmginfo:GetAttacker() and dmginfo:GetAttacker():IsValid() and dmginfo:GetAttacker():GetClass()=="player" and dmginfo:GetAttacker():GetActiveWeapon() and dmginfo:GetAttacker():GetActiveWeapon():IsValid() and dmginfo:GetAttacker():GetActiveWeapon():GetClass()=="weapon_shotgun" ) then
 
		dmginfo:ScaleDamage( 2 )

	end

	if ( dmginfo:GetAttacker() and dmginfo:GetAttacker():IsValid() and dmginfo:GetAttacker():GetClass()=="player" and dmginfo:GetAttacker():GetActiveWeapon() and dmginfo:GetAttacker():GetActiveWeapon():IsValid() and dmginfo:GetAttacker():GetActiveWeapon():GetClass()=="weapon_slam" ) then
 
		dmginfo:ScaleDamage( 1.5 )

	end

	if IsValid(att) and att:GetClass()=="player" and IsValid(att:GetActiveWeapon()) and att:GetActiveWeapon():GetClass() == "weapon_crowbar" then
		dmginfo:SetDamage(25) --gmod june 2020 update sets crowbar damage to 10, set it back to 25
	end

end

--[[---------------------------------------------------------
	 Name: Text to show in the server browser
-----------------------------------------------------------]]
function GM:GetGameDescription()
	return self.Name
end

--[[---------------------------------------------------------
	 Name: gamemode:ShouldCollide( Ent1, Ent2 )
	 Desc: This should always return true unless you have 
			a good reason for it not to.
-----------------------------------------------------------]]
function GM:ShouldCollide( Ent1, Ent2 )
	return false
end


--[[---------------------------------------------------------
	 Name: gamemode:Move
	 This basically overrides the NOCLIP, PLAYERMOVE movement stuff.
	 It's what actually performs the move. 
	 Return true to not perform any default movement actions. (completely override)
-----------------------------------------------------------]]
function GM:Move( ply, mv )
	if ( player_manager.RunClass( ply, "Move", mv ) ) then return true end
end


--[[---------------------------------------------------------
-- Purpose: This is called pre player movement and copies all the data necessary
--          from the player for movement. Copy from the usercmd to move.
-----------------------------------------------------------]]
function GM:SetupMove( ply, mv, cmd )
	if ( player_manager.RunClass( ply, "StartMove", mv, cmd ) ) then return true end
end

--[[---------------------------------------------------------
	 Name: gamemode:FinishMove( player, movedata )
-----------------------------------------------------------]]
function GM:FinishMove( ply, mv )
	if ( player_manager.RunClass( ply, "FinishMove", mv ) ) then return true end
end

--Allow physgun pickup of players ONLY ... maybe add trash and some other stuff?... dont forget PROTECTION for this
function GM:PhysgunPickup( ply, ent )
	if ( ent:GetClass():lower() == "player" ) then
		if ent:Alive() and (not Safe(ent)) and (not Safe(ply)) then
			ply.physgunHeld = ent
			return true
		end
	end
	if ply:GetMoveType()==MOVETYPE_NOCLIP then return true end
	return false
end
