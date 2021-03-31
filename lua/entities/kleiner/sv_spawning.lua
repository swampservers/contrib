-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

KLEINER_NPCS = KLEINER_NPCS or {}
KLEINER_NPCS_FILTER = KLEINER_NPCS_FILTER or {}
KLEINER_NPC_TARGETS = KLEINER_NPC_TARGETS or {}
KLEINER_NPCS_CURRENT_NUMBER = KLEINER_NPCS_CURRENT_NUMBER or 0 
KLEINER_DESIRED_NUMBER = 18




	
timer.Create("kleiner_spawner",1,0,function()
	if(table.Count(KLEINER_NPCS) < KLEINER_DESIRED_NUMBER)then
		local newkleiner = ents.Create("kleiner")
		if(IsValid(newkleiner))then
			local spawnpoint = gmod.GetGamemode().SpawnPoints and table.Random(gmod.GetGamemode().SpawnPoints):GetPos() or Vector(0,0,16)
			newkleiner:SetPos(spawnpoint)
			newkleiner:Spawn()
			newkleiner:Activate()
		end
	end 
end)  

hook.Add("EntityRemoved","kleiner_npc_kleanup",function(ent)
	if(ent:GetClass() == "kleiner" or ent:IsPlayer())then
		KLEINER_NPCS[ent] = nil
		KLEINER_NPC_TARGETS[ent] = nil
		KLEINER_NPCS_CURRENT_NUMBER = table.Count(KLEINER_NPCS)
	end	
	
end)
hook.Add("OnEntityCreated","kleiner_npc_register",function(ent)
	if(ent:GetClass() == "kleiner" or ent:IsPlayer())then
		KLEINER_NPCS[ent] = ent:GetClass() == "kleiner" and true or nil
		KLEINER_NPC_TARGETS[ent] =  ent:IsPlayer() and true or nil
		
		KLEINER_NPCS_FILTER = {}
		for k,v in pairs(ents.FindByClass("kleiner"))do
			table.insert(KLEINER_NPCS_FILTER,v)
		end
		KLEINER_NPCS_CURRENT_NUMBER = table.Count(KLEINER_NPCS)
	end
end)


--this hook isn't especially needed, its purpose is mainly to credit kleiners with any kills they get with grenades. without this it just counts them as world kills.
--the value that the engine weapon uses to associate grenades to players appears to be engine-only.
hook.Add( "EntityTakeDamage", "GrenadeAttribution", function( target, dmginfo ) 
	local attacker = dmginfo:GetAttacker()
	if(IsValid(attacker) and attacker:GetClass() == "npc_grenade_frag")then dmginfo:SetInflictor(attacker) dmginfo:SetAttacker(game.GetWorld()) end
	local inflictor = dmginfo:GetInflictor()
	if (IsValid(inflictor) and inflictor:GetClass() == "npc_grenade_frag" and dmginfo:GetAttacker() == game.GetWorld() and IsValid(inflictor:GetOwner())) then
		dmginfo:SetAttacker(dmginfo:GetInflictor():GetOwner())	
	end
	if(target:GetClass() == "npc_grenade_frag" and dmginfo:GetDamage() > 5 and !target.DamageTriggered)then
	target.DamageTriggered = true
	target:Fire("SetTimer",0.5)
	end
	
end )