-- This file is subject to copyright - contact swampservers@gmail.com for more information.
if SERVER then
    SteamIDToPlayer = SteamIDToPlayer or {}
    SteamID64ToPlayer = SteamID64ToPlayer or {}
    AccountIDToPlayer = AccountIDToPlayer or {}

    --NOMINIFY
    hook.Add("OnEntityCreated", "PlayerTrackerAdd", function(ply)
        if ply:IsPlayer() then
            SteamIDToPlayer[string.upper(ply:SteamID())] = ply
            SteamID64ToPlayer[ply:SteamID64()] = ply
            AccountIDToPlayer[ply:AccountID()] = ply
        end
    end)

    hook.Add("EntityRemoved", "PlayerTrackerRemove", function(ply)
        if ply:IsPlayer() then
            SteamIDToPlayer[string.upper(ply:SteamID())] = nil
            SteamID64ToPlayer[ply:SteamID64()] = nil
            AccountIDToPlayer[ply:AccountID()] = nil
        end
    end)

    --- Unlike the built-in function, this (along with player.GetBySteamID64 and player.GetByAccountID) is fast.
    function player.GetBySteamID(id)
        local ply = SteamIDToPlayer[string.upper(id)] or false
        assert(ply == false or IsValid(ply) and ply:IsPlayer())

        return ply
    end

    function player.GetBySteamID64(id64)
        local ply = SteamID64ToPlayer[id64] or false
        assert(ply == false or IsValid(ply) and ply:IsPlayer())

        return ply
    end

    function player.GetByAccountID(id)
        local ply = AccountIDToPlayer[id] or false
        assert(ply == false or IsValid(ply) and ply:IsPlayer())

        return ply
    end

    --- 
    function util.AccountIDFrom64( id )
        assert(id:sub(1,7)=="7656119")
        id = tonumber(id:sub(8)) - 7960265728
        assert(id>0 and id < 4294967296)
        return id
    end

    --- 
    function util.SteamIDFromAccountID( id )
        return "STEAM_0:"..(id%2)..":"..math.floor(id/2)
    end

end
