-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--player_manager.AddValidModel( "pony", "models/ppm/player_default_base.mdl" ) 
--player_manager.AddValidModel( "ponynj", "models/ppm/player_default_base_nj.mdl" )  

PPM = PPM or {}

PPM.Playermodel = "models/ppm/player_default_base.mdl"
FindMetaTable("Entity").IsPPMPony = function(self)
    return self:GetModel()==PPM.Playermodel  
end

FindMetaTable("Entity").PonyPlayer = function(self)
    if self:IsPlayer() then return self end
    if self:EntIndex()==-1 then return LocalPlayer() end
    -- if its a ragdoll then return owner
    print(self)
end

PPM.serverPonydata = PPM.serverPonydata or {}
PPM.isLoaded = false

include("sppm/items.lua")
include("sppm/pony_player.lua")

if CLIENT then
    include("sppm/editor3.lua")
    include("sppm/editor3_body.lua")
    include("sppm/editor3_presets.lua")
    include("sppm/io.lua")
    include("sppm/render.lua")
    include("sppm/render_texture.lua")
    include("sppm/resources.lua")
else
    include("sppm/serverside.lua")
    AddCSLuaFile("sppm/editor3.lua")
    AddCSLuaFile("sppm/editor3_body.lua")
    AddCSLuaFile("sppm/editor3_presets.lua")
    AddCSLuaFile("sppm/io.lua")
    AddCSLuaFile("sppm/items.lua")
    AddCSLuaFile("sppm/pony_player.lua")
    AddCSLuaFile("sppm/render.lua")
    AddCSLuaFile("sppm/render_texture.lua")
    AddCSLuaFile("sppm/resources.lua")
end


-- PPM.PonyData = PPM.PonyData or {}
-- PPM.FailedEnts = PPM.FailedEnts or {}
-- PPM.UnInitializedPonies = PPM.UnInitializedPonies or {}
-- PPM.ActivePonies = PPM.ActivePonies or {}

-- function PPM.RefreshActivePonies()
--     PPM.ActivePonies = {PPM.editor3_pony}

--     -- for k,v in pairs(ents.GetAll()) do
--     --  	if v:IsPPMPony() then
--     -- 		 table.insert(PPM.ActivePonies, v)
--     -- 	end
--     -- end
--     -- PrintTable(PPM.ActivePonies)
--     for k, v in pairs(player.GetAll()) do
--         if v:IsPPMPony() then
--             table.insert(PPM.ActivePonies, v)
--             -- PPM.ActivePonies[v] = true
--             local v2 = v:GetRagdollEntity()

--             if IsValid(v2) and v2:IsPPMPony() then
--                 table.insert(PPM.ActivePonies, v2)
--                 -- PPM.ActivePonies[v2] = true
--             end
--         end
--     end
-- end


-- if SERVER then
--     util.AddNetworkString("ppm_ponydata")
--     util.AddNetworkString("ppm_ponyrequest")

--     net.Receive("ppm_ponyrequest", function(len, ply)
--         ply.poniesAlreadySent = ply.poniesAlreadySent or {}
--         ply.lastResetPoniesAlreadySent = ply.lastResetPoniesAlreadySent or CurTime()

--         if CurTime() - ply.lastResetPoniesAlreadySent > 60 then
--             ply.poniesAlreadySent = {}
--             ply.lastResetPoniesAlreadySent = CurTime()
--         end

--         local pones = net.ReadTable()

--         for k, v in pairs(pones) do
--             local fff = false

--             if IsValid(k) then
--                 if ply.poniesAlreadySent[k] then
--                 else
--                     fff = true
--                     PPM.SendPony(k, ply)
--                 end
--             end
--             --			print("      ", k, fff)
--         end
--     end)

--     PPM.CompressedPonies = PPM.CompressedPonies or {}

--     function PPM.SendPony(ply, target)
--         local comp = PPM.CompressedPonies[ply]
--         if not comp then return end

--         if type(target) == "Player" then
--             target.poniesAlreadySent = target.poniesAlreadySent or {}
--             target.poniesAlreadySent[ply] = true
--         end

--         net.Start("ppm_ponydata")
--         net.WriteInt(ply:EntIndex(), 14)
--         net.WriteInt(#comp, 17)
--         net.WriteData(comp, #comp)
--         net.Send(target)
--     end

--     local function ReceivePony(bits, ply)
--         if ply.delay_ponydata and (ply.delay_ponydata > CurTime()) then return end
--         ply.delay_ponydata = CurTime() + 2.7
--         local comp, tbl = Validate(net.ReadData(bits / 8))

--         if PPM.CompressedPonies[ply] then
--             if (PPM.CompressedPonies[ply] == comp) then return end
--         end

--         PPM.CompressedPonies[ply] = comp
--         PPM.PonyData[ply] = PPM.PonyData[ply] or {}
--         PPM.PonyData[ply][1] = 1
--         PPM.PonyData[ply][2] = tbl
--         PPM.setBodygroups(ply)
--         PPM.SendPony(ply, player.GetAll())
--     end

--     net.Receive("ppm_ponydata", ReceivePony)

--     hook.Add("PlayerDisconnected", "delete_ppm_compressed_pony", function(ply)
--         PPM.CompressedPonies[ply] = nil
--         PPM.PonyData[ply] = nil
--     end)
-- else
--     local delays = 0



    -- local function ReceivePony()
    --     local plynum = net.ReadInt(14)
    --     local length = net.ReadInt(17)
    --     local comp = net.ReadData(length)
    --     local json = util.Decompress(comp)
    --     local tbl = util.JSONToTable(json)
    --     local ply = Entity(plynum)

    --     if IsValid(ply) then
    --         PPM.PonyData[ply] = PPM.PonyData[ply] or {}
    --         PPM.PonyData[ply][1] = 1
    --         PPM.PonyData[ply][2] = tbl
    --     else
    --         PPM.FailedEnts[plynum] = {}
    --         PPM.FailedEnts[plynum].pony = tbl
    --         PPM.FailedEnts[plynum].retries = 0
    --     end
    -- end

    -- net.Receive("ppm_ponydata", ReceivePony)
    -- local delayl = 0

    -- local function LoadPonies()
    --     if (delayl > CurTime()) then return end
    --     delayl = CurTime() + 2
    --     local rq = false

    --     for k, v in pairs(PPM.UnInitializedPonies) do
    --         if IsValid(k) then
    --             rq = true
    --             PPM.UnInitializedPonies[k] = tostring(k)
    --         end
    --     end

    --     if rq then
    --         net.Start("ppm_ponyrequest")
    --         net.WriteTable(PPM.UnInitializedPonies)
    --         net.SendToServer()
    --         PPM.UnInitializedPonies = {}
    --     end

    --     for k, v in pairs(PPM.FailedEnts) do
    --         local ply = Entity(k)

    --         if IsValid(ply) then
    --             if PPM.PonyData[ply] then
    --                 PPM.FailedEnts[k] = nil
    --             else
    --                 PPM.PonyData[ply] = {}
    --                 PPM.PonyData[ply][1] = 1
    --                 PPM.PonyData[ply][2] = v.pony
    --                 PPM.FailedEnts[k] = nil
    --             end
    --         elseif (PPM.FailedEnts[k].retries > 20) then
    --             PPM.FailedEnts[k] = nil
    --         else
    --             PPM.FailedEnts[k].retries = PPM.FailedEnts[k].retries + 1
    --         end
    --     end
    -- end

    -- hook.Add("Think", "ppm_load_unloaded_ponies", LoadPonies)
    --[[
	hook.Add("OnEntityCreated", "detect_ppm_pony", function(ent)
	
		if ent:IsPPMPony() then
			PPM.ActivePonies[ent] = true
		end
	
	end)

	hook.Add("EntityRemoved", "detect_ppm_pony", function(ent)
	
		if !IsValid(ent) then return end
	

			PPM.ActivePonies[ent] = nil

	
	end) ]]
    -- local delayr = 0

    -- hook.Add("Think", "ppm_pony_cleanup", function(ent)
    --     if (delayr > CurTime()) then return end
    --     delayr = CurTime() + 0.2
    --     PPM.RefreshActivePonies()
    -- end)
    --[[
		
		for ent, _ in pairs(PPM.ActivePonies) do
		
			if !IsValid(ent) then
				PPM.ActivePonies[ent] = nil
			end

		end
		
		for _, ply in ipairs(player.GetAll()) do
		
			if ply:IsPPMPony() then
				PPM.ActivePonies[ply] = true
			end
		
		end
		
		for ent, _ in ipairs(PPM.CompressedPonies or {}) do
		
			if !IsValid(ent) then
				PPM.CompressedPonies[ent] = nil
			end
			
		end ]]
-- end

