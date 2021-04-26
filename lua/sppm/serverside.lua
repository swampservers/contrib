-- This file is subject to copyright - contact swampservers@gmail.com for more information.
if (SERVER) then
    util.AddNetworkString("player_equip_item")
    util.AddNetworkString("player_pony_cm_send")

    --util.AddNetworkString( "player_pony_set_charpars" )
    net.Receive("player_equip_item", function(len, ply)
        local id = net.ReadFloat()
        local item = PPM:pi_GetItemById(id)

        if (item ~= nil) then
            PPM.setupPony(ply, false)
            PPM:pi_SetupItem(item, ply)
        end
    end)

    function HOOK_PlayerLeaveVehicle(ply, ent)
        --if(table.HasValue(ponyarray_temp,ply:GetInfo( "cl_playermodel" ))) then
        if ply:IsPPMPony() then
            if ply.ponydata ~= nil and IsValid(ply.ponydata.clothes1) then
                local bdata = {}

                for i = 0, 14 do
                    bdata[i] = ply.ponydata.clothes1:GetBodygroup(i)
                    ply.ponydata.clothes1:SetBodygroup(i, 0)
                end

                timer.Simple(0.2, function()
                    if ply.ponydata ~= nil and IsValid(ply.ponydata.clothes1) then
                        for i = 0, 14 do
                            ply.ponydata.clothes1:SetBodygroup(i, bdata[i])
                        end
                    end
                end)
            end
        end
    end

    ponyarray_temp = {"pony", "ponynj"}

    PPM.camoffcetenabled = CreateConVar("ppm_enable_camerashift", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Enables ViewOffset Setup")

    hook.Add("PlayerLeaveVehicle", "pony_fixclothes", HOOK_PlayerLeaveVehicle)
end