-- Mostly-fix for https://github.com/Facepunch/garrysmod-issues/issues/3362 and 4953
-- This won't well if you're trying to set material overrides on the same entity on both the server and client.
-- Also calling SetMaterial() or SetSubMaterial() will reset both materials and submaterials.
-- Put this in lua/autorun/client/materialfix.lua
-- A set of entities which have appeared recently and have clientside material overrides
local watchlist = {}

-- It seems to take about 5 ticks/0.2 sec from when the entity enters PVS to
-- when it reapplies its server material setting (but the time is inconsistent)
-- I couldn't find any hacky way to detect it so this is what you get.
hook.Add("Tick", "ClientForceMaterial", function()
    local cutoff = CurTime() - (0.5 + (IsValid(Me) and Me:Ping() / 1000 or 1))

    for ent, _ in pairs(watchlist) do
        if not IsValid(ent) or (ent.CFM_AppearTime or 0) < cutoff or not (ent.CLIENTFORCEDMATERIAL or ent.CLIENTFORCEDSKIN) then
            watchlist[ent] = nil
        else
            for idx, mat in pairs(ent.CLIENTFORCEDMATERIAL or {}) do
                if idx == -1 then
                    ent:BasedSetMaterial(mat)
                else
                    ent:BasedSetSubMaterial(idx, mat)
                end
            end

            if ent.CLIENTFORCEDSKIN then
                ent:BasedSetSkin(ent.CLIENTFORCEDSKIN)
            end
        end
    end
end)

hook.Add("NetworkEntityCreated", "ClientForceMaterial2", function(ent)
    ent.CFM_AppearTime = CurTime()

    if ent.CLIENTFORCEDMATERIAL or ent.CLIENTFORCEDSKIN then
        watchlist[ent] = true
    end
end)

hook.Add("NotifyShouldTransmit", "ClientForceMaterial3", function(ent, trans)
    ent.CFM_AppearTime = CurTime()
    watchlist[ent] = ((ent.CLIENTFORCEDMATERIAL or ent.CLIENTFORCEDSKIN) and trans) or nil
end)


Entity.BasedGetSkin = Entity.BasedGetSkin or Entity.GetSkin
Entity.BasedSetSkin = Entity.BasedSetSkin or Entity.SetSkin
Entity.BasedGetMaterial = Entity.BasedGetMaterial or Entity.GetMaterial
Entity.BasedSetMaterial = Entity.BasedSetMaterial or Entity.SetMaterial
Entity.BasedGetSubMaterial = Entity.BasedGetSubMaterial or Entity.GetSubMaterial
Entity.BasedSetSubMaterial = Entity.BasedSetSubMaterial or Entity.SetSubMaterial

function Entity:GetSkin()
    return self.CLIENTFORCEDSKIN or self:BasedGetSkin()
end

function Entity:GetMaterial()
    return (self.CLIENTFORCEDMATERIAL or {})[-1] or self:BasedGetMaterial()
end

function Entity:GetSubMaterial(idx)
    return (self.CLIENTFORCEDMATERIAL or {})[idx] or self:BasedGetSubMaterial(idx)
end

function Entity:SetSkin(skin)
    self.CLIENTFORCEDSKIN = skin

    if skin then
        self:BasedSetSkin(skin)
    end
end

function Entity:SetMaterial(mat)
    self:SetSubMaterial(-1, mat)
end

function Entity:SetSubMaterial(idx, mat)
    if idx == nil or (idx == -1 and mat == nil) then
        self.CLIENTFORCEDMATERIAL = nil
        watchlist[self] = nil
    else
        local t = self.CLIENTFORCEDMATERIAL

        if not t then
            t = {}
            self.CLIENTFORCEDMATERIAL = t
        end

        t[idx] = mat
        watchlist[self] = true
    end

    if idx == -1 then
        self:BasedSetMaterial(mat)
    else
        self:BasedSetSubMaterial(idx, mat)
    end

    if idx then
        local t = self.CLIENTFORCEDMATERIAL

        if not t then
            t = {}
            self.CLIENTFORCEDMATERIAL = t
        end

        t[idx] = mat
    else
        self.CLIENTFORCEDMATERIAL = nil
    end
end
