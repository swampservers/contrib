-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- damage indicator shit
if SERVER then
    util.AddNetworkString("HitMarker")
    HITMARKERCACHE = {}
    KILLCACHE = {}

    hook.Add("PostEntityTakeDamage", "DamageMarker", function(ent, dmg, took)
        local att = dmg:GetAttacker()

        --and (ent:IsBot() or (HumanTeamName and att.hvp ~= ent.hvp)) then
        if ent:IsPlayer() then
            if IsValid(att) and att:IsPlayer() then
                HITMARKERCACHE[att] = (HITMARKERCACHE[att] or 0) + dmg:GetDamage()
                -- if not ent:Alive() then
                --     KILLCACHE[att] = true
                -- end
            end
        end
    end)

    hook.Add("PlayerDeath", "KillMarker", function(victim, inflictor, attacker)
        if IsValid(attacker) and attacker:IsPlayer() then
            KILLCACHE[attacker] = true
        end
    end)

    hook.Add("Tick", "FlushHitMarkers", function()
        for k, v in pairs(HITMARKERCACHE) do
            if IsValid(k) then
                net.Start("HitMarker")
                net.WriteUInt(v, 16)
                net.WriteBool(KILLCACHE[k] or false)
                net.Send(k)
            end
        end

        HITMARKERCACHE = {}
        KILLCACHE = {}
    end)
else
    local hitmarkers = {}

    net.Receive("HitMarker", function(len)
        local dmg = net.ReadUInt(16)
        local kill = net.ReadBool()

        table.insert(hitmarkers, {
            dmg = dmg,
            kill = kill,
            t = SysTime(),
            x = 0.1, --math.Rand(-0.5,0.5),
            
        })
    end)

    hook.Add("PostDrawHUD", "DrawHitMarkers", function() end)

    hook.Add("HUDDrawScoreBoard", "DrawHitMarkers", function()
        local duration = 1
        local t = SysTime()
        local i = 1

        while i <= #hitmarkers do
            local marker = hitmarkers[i]

            if marker.t + duration < t then
                table.remove(hitmarkers, i)
            else
                i = i + 1
                local drift = (t - marker.t) / duration
                local alpha = 1 - drift
                drift = drift + 0.1
                -- ..marker.dmg..""
                draw.SimpleText(marker.kill and "KILL " .. marker.dmg or tostring(marker.dmg), "HitDamageFont", ScrW() / 2 + drift * 100 * marker.x, ScrH() / 2 + drift * 125, Color(255, 0, 0, 255 * alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
    end)

    surface.CreateFont("HitDamageFont", {
        font = "Trebuchet",
        size = 24,
        weight = 1000
    })
end
