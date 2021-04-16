-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
CreateConVar("kleiner_spawncount", "18", FCVAR_ARCHIVE + FCVAR_PROTECTED, "Number of Kleiner NPCs to spawn automatically.", 0, 100)
KLEINER_NPCS = KLEINER_NPCS or {}
KLEINER_NPCS_FILTER = KLEINER_NPCS_FILTER or {}
KLEINER_NPC_TARGETS = KLEINER_NPC_TARGETS or {}
KLEINER_NPCS_CURRENT_NUMBER = KLEINER_NPCS_CURRENT_NUMBER or 0
KLEINER_DESIRED_NUMBER = KLEINER_DESIRED_NUMBER or GetConVar("kleiner_spawncount"):GetInt() or 0

function KLEINER_NPC_SETUPTIMER(value)
    KLEINER_DESIRED_NUMBER = GetConVar("kleiner_spawncount"):GetInt() or 0
    timer.Destroy("kleiner_spawner")

    if (value > 0) then
        timer.Create("kleiner_spawner", 1, 0, function()
            if (table.Count(KLEINER_NPCS) < KLEINER_DESIRED_NUMBER) then
                local newkleiner = ents.Create("kleiner")

                if (IsValid(newkleiner)) then
                    local spawnpoint = gmod.GetGamemode().SpawnPoints and table.Random(gmod.GetGamemode().SpawnPoints):GetPos() or Vector(0, 0, 16)
                    newkleiner:SetPos(spawnpoint)
                    newkleiner:Spawn()
                    newkleiner:Activate()
                end
            end
        end)
    end

    local clearcount = KLEINER_NPCS_CURRENT_NUMBER - value

    if (clearcount > 0) then
        for i = 1, clearcount do
            table.Random(ents.FindByClass("kleiner")):Remove()
        end
    end
end

hook.Add("Initialize", "KleinerNPC_TimerInit", function()
    cvars.AddChangeCallback("kleiner_spawncount", function(convar_name, value_old, value_new)
        KLEINER_NPC_SETUPTIMER(tonumber(value_new))
    end, "kleiner_adjust_spawnlimit")

    KLEINER_NPC_SETUPTIMER(KLEINER_DESIRED_NUMBER)
end)

hook.Add("EntityRemoved", "kleiner_npc_kleanup", function(ent)
    if (ent:GetClass() == "kleiner" or ent:IsPlayer()) then
        KLEINER_NPCS[ent] = nil
        KLEINER_NPC_TARGETS[ent] = nil
        KLEINER_NPCS_CURRENT_NUMBER = table.Count(KLEINER_NPCS)
    end
end)

hook.Add("OnEntityCreated", "kleiner_npc_register", function(ent)
    if (ent:GetClass() == "kleiner" or ent:IsPlayer()) then
        KLEINER_NPCS[ent] = ent:GetClass() == "kleiner" and true or nil
        KLEINER_NPC_TARGETS[ent] = ent:IsPlayer() and true or nil
        KLEINER_NPCS_CURRENT_NUMBER = table.Count(KLEINER_NPCS)
    end
end)

--this hook isn't especially needed, its purpose is mainly to credit kleiners with any kills they get with grenades. without this it just counts them as world kills.
--the value that the engine weapon uses to associate grenades to players appears to be engine-only.
hook.Add("EntityTakeDamage", "GrenadeAttribution", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()

    --clear attacker from damage if it's attacker is a grenade, set inflictor to grenade instead
    if (IsValid(attacker) and attacker:GetClass() == "npc_grenade_frag") then
        dmginfo:SetInflictor(attacker)
        dmginfo:SetAttacker(game.GetWorld())
    end

    --if no attacker on damage inflicted by grenade, set attacker to the grenade's owner
    local inflictor = dmginfo:GetInflictor()

    if (IsValid(inflictor) and inflictor:GetClass() == "npc_grenade_frag" and dmginfo:GetAttacker() == game.GetWorld() and IsValid(inflictor:GetOwner())) then
        dmginfo:SetAttacker(dmginfo:GetInflictor():GetOwner())
    end

    --if grenade is hit by high force damage from non-world, change grenade owner to attacker
    if (target:GetClass() == "npc_grenade_frag" and dmginfo:GetDamage() > 5 and dmginfo:GetDamageForce():Length() > 200 and IsValid(dmginfo:GetAttacker()) and IsValid(dmginfo:GetInflictor())) then
        if (dmginfo:GetDamageForce():Length() < 5000) then
            dmginfo:SetDamageForce(dmginfo:GetDamageForce():GetNormalized() * 5000)
        end

        target:SetOwner(dmginfo:GetAttacker())

        if (not target.DamageTriggered) then
            target.DamageTriggered = true
            target:Fire("SetTimer", 0.5)
        end
    end
end)