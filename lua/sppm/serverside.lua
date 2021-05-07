-- This file is subject to copyright - contact swampservers@gmail.com for more information.
util.AddNetworkString("PonyCfg")
util.AddNetworkString("PonyInvalidate")
util.AddNetworkString("PonyRequest")

net.Receive("PonyCfg", function(len, ply)
    if (CurTime() - (ply.LastPonyCfgUpdate or -10)) < 2 then
        ply:SendLua([[timer.Simple(1, SendLocalPonyCfg)]])

        return
    end

    local cfg = net.ReadTable()
    ply.LastPonyCfgUpdate = CurTime()
    ply.ponydata = SanitizePonyCfg(cfg)
    PPM_SetBodyGroups(ply)
    net.Start("PonyInvalidate")
    net.WriteEntity(ply)
    net.SendOmit(ply)
end)

hook.Add("PlayerModelChanged", "PPM_PlayerModelApplied", function(ply, mdl)
    PPM_SetBodyGroups(ply)
end)

net.Receive("PonyRequest", function(len, ply)
    local ent = net.ReadEntity()

    if IsValid(ent) and ent.ponydata then
        net.Start("PonyCfg")
        net.WriteEntity(ent)
        net.WriteTable(ent.ponydata)
        net.Send(ply)
    end
end)
-- util.AddNetworkString("player_equip_item")
-- util.AddNetworkString("player_pony_cm_send")
-- net.Receive("player_equip_item", function(len, ply)
--     local id = net.ReadFloat()
--     local item = PPM:pi_GetItemById(id)
--     if (item ~= nil) then
--         PPM.setupPony(ply, false)
--         PPM:pi_SetupItem(item, ply)
--     end
-- end)
-- hook.Add("PlayerLeaveVehicle", "pony_fixclothes", function(ply, ent)
--     if ply:IsPPMPony() then
--         if ply.ponydata ~= nil and IsValid(ply.ponydata.clothes1) then
--             local bdata = {}
--             for i = 0, 14 do
--                 bdata[i] = ply.ponydata.clothes1:GetBodygroup(i)
--                 ply.ponydata.clothes1:SetBodygroup(i, 0)
--             end
--             timer.Simple(0.2, function()
--                 if ply.ponydata ~= nil and IsValid(ply.ponydata.clothes1) then
--                     for i = 0, 14 do
--                         ply.ponydata.clothes1:SetBodygroup(i, bdata[i])
--                     end
--                 end
--             end)
--         end
--     end
-- end)