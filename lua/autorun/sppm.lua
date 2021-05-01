-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--player_manager.AddValidModel( "pony", "models/ppm/player_default_base.mdl" ) 
--player_manager.AddValidModel( "ponynj", "models/ppm/player_default_base_nj.mdl" )  
if SERVER then
    AddCSLuaFile("sppm.lua")

    local function add_files(dir)
        local files, folders = file.Find(dir .. "*", "LUA")

        for key, file_name in pairs(files) do
            AddCSLuaFile(dir .. file_name)
        end

        for key, folder_name in pairs(folders) do
            add_files(dir .. folder_name .. "/")
        end
    end

    add_files("sppm/")
end

if CLIENT then end --list.Set( "PlayerOptionsModel", "pony", "models/ppm/player_default_base.mdl" )  --list.Set( "PlayerOptionsModel", "ponynj", "models/ppm/player_default_base_nj.mdl" ) 
include("sppm/init.lua")
PPM = PPM or {}
PPM.PonyData = PPM.PonyData or {}
PPM.FailedEnts = PPM.FailedEnts or {}
PPM.UnInitializedPonies = PPM.UnInitializedPonies or {}
PPM.ActivePonies = PPM.ActivePonies or {}

function PPM.RefreshActivePonies()
    PPM.ActivePonies = {PPM.editor3_pony}

    -- for k,v in pairs(ents.GetAll()) do
    --  	if v:IsPPMPony() then
    -- 		 table.insert(PPM.ActivePonies, v)
    -- 	end
    -- end
    -- PrintTable(PPM.ActivePonies)
    for k, v in pairs(player.GetAll()) do
        if v:IsPPMPony() then
            table.insert(PPM.ActivePonies, v)
            -- PPM.ActivePonies[v] = true
            local v2 = v:GetRagdollEntity()

            if IsValid(v2) and v2:IsPPMPony() then
                table.insert(PPM.ActivePonies, v2)
                -- PPM.ActivePonies[v2] = true
            end
        end
    end
end

function PPM.SanitizeImgurCmark(txt)
    local spoof = "http://i.imgur.com/2UdwxGb.png"
    if not isstring(txt) then return "" end --spoof end
    local txt2 = " " .. txt .. " "
    if txt2:gsub(" https?://i%.imgur%.com/%w+%.[jp][pn]g ", "") ~= "" then return spoof end

    return txt
end

if SERVER then
    util.AddNetworkString("ppm_ponydata")
    util.AddNetworkString("ppm_ponyrequest")

    net.Receive("ppm_ponyrequest", function(len, ply)
        ply.poniesAlreadySent = ply.poniesAlreadySent or {}
        ply.lastResetPoniesAlreadySent = ply.lastResetPoniesAlreadySent or CurTime()

        if CurTime() - ply.lastResetPoniesAlreadySent > 60 then
            ply.poniesAlreadySent = {}
            ply.lastResetPoniesAlreadySent = CurTime()
        end

        local pones = net.ReadTable()

        for k, v in pairs(pones) do
            local fff = false

            if IsValid(k) then
                if ply.poniesAlreadySent[k] then
                else
                    fff = true
                    PPM.SendPony(k, ply)
                end
            end
            --			print("      ", k, fff)
        end
    end)

    PPM.CompressedPonies = PPM.CompressedPonies or {}

    function PPM.SendPony(ply, target)
        local comp = PPM.CompressedPonies[ply]
        if not comp then return end

        if type(target) == "Player" then
            target.poniesAlreadySent = target.poniesAlreadySent or {}
            target.poniesAlreadySent[ply] = true
        end

        net.Start("ppm_ponydata")
        net.WriteInt(ply:EntIndex(), 14)
        net.WriteInt(#comp, 17)
        net.WriteData(comp, #comp)
        net.Send(target)
    end

    local pnum = {}

    pnum.age = {2, 2, 2}

    pnum.body_type = {1, 1, 1}

    pnum.bodydetail1 = {1, 20, 1}

    pnum.bodydetail2 = {1, 20, 1}

    pnum.bodydetail3 = {1, 20, 1}

    pnum.bodydetail4 = {1, 20, 1}

    pnum.bodydetail5 = {1, 20, 1}

    pnum.bodydetail6 = {1, 20, 1}

    pnum.bodydetail7 = {1, 20, 1}

    pnum.bodydetail8 = {1, 20, 1}

    pnum.bodyt0 = {1, 6, 1}

    pnum.bodyt1 = {1, 1, 1}

    pnum.bodyweight = {0.5, 2.0, 1}

    pnum.cmark = {1, 48, 1}

    pnum.cmark_enabled = {1, 2, 2}

    pnum.eye = {1, 10, 1}

    pnum.eyehaslines = {1, 2, 1}

    pnum.eyeholesize = {0.3, 1, 0.8}

    pnum.eyeirissize = {0.2, 2, 1}

    pnum.eyejholerssize = {0.2, 1, 1}

    pnum.eyelash = {1, 6, 1}

    pnum.gender = {1, 2, 1}

    pnum.kind = {1, 4, 1}

    pnum.mane = {1, 16, 1}

    pnum.manel = {1, 13, 1}

    pnum.tail = {1, 15, 1}

    pnum.tailsize = {0.8, 1.5, 1}

    local pvec = {"bodydetail1_c", "bodydetail2_c", "bodydetail3_c", "bodydetail4_c", "bodydetail5_c", "bodydetail6_c", "bodydetail7_c", "bodydetail8_c", "bodyt1_color", "coatcolor", "eyecolor_bg", "eyecolor_grad", "eyecolor_hole", "eyecolor_iris", "eyecolor_line1", "eyecolor_line2", "haircolor1", "haircolor2", "haircolor3", "haircolor4", "haircolor5", "haircolor6"}

    local function Validate(data)
        local json = util.JSONToTable(util.Decompress(data))
        local pdata = {}
        pdata._cmark_loaded = false

        for k, v in pairs(pnum) do
            local value = json[k]
            value = isnumber(value) and value or v[3]
            value = math.Clamp(value, v[1], v[2])
            pdata[k] = value
        end

        for _, v in ipairs(pvec) do
            local value = json[v]
            local vec = isvector(value) and value or Vector(1, 1, 1)
            vec.x = math.Clamp(vec.x, 0, 1)
            vec.y = math.Clamp(vec.y, 0, 1)
            vec.z = math.Clamp(vec.z, 0, 1)
            pdata[v] = vec
        end

        pdata.imgurcmark = PPM.SanitizeImgurCmark(json.imgurcmark)
        local newdata = util.Compress(util.TableToJSON(pdata))

        return newdata, pdata
    end

    local function ReceivePony(bits, ply)
        if ply.delay_ponydata and (ply.delay_ponydata > CurTime()) then return end
        ply.delay_ponydata = CurTime() + 2.7
        local comp, tbl = Validate(net.ReadData(bits / 8))

        if PPM.CompressedPonies[ply] then
            if (PPM.CompressedPonies[ply] == comp) then return end
        end

        PPM.CompressedPonies[ply] = comp
        PPM.PonyData[ply] = PPM.PonyData[ply] or {}
        PPM.PonyData[ply][1] = 1
        PPM.PonyData[ply][2] = tbl
        PPM.setBodygroups(ply)
        PPM.SendPony(ply, player.GetAll())
    end

    net.Receive("ppm_ponydata", ReceivePony)

    hook.Add("PlayerDisconnected", "delete_ppm_compressed_pony", function(ply)
        PPM.CompressedPonies[ply] = nil
        PPM.PonyData[ply] = nil
    end)
else
    local delays = 0

    function PPM.SendPonyData()
        local tbl = LocalPlayer().ponydata
        if not istable(tbl) then return end
        if (delays > CurTime()) then return end
        delays = CurTime() + 3
        local json = util.TableToJSON(tbl)
        local comp = util.Compress(json)
        PPM.SentPonyData = comp
        local length = #comp
        net.Start("ppm_ponydata")
        net.WriteData(comp, length)
        net.SendToServer()
    end

    local function ReceivePony()
        local plynum = net.ReadInt(14)
        local length = net.ReadInt(17)
        local comp = net.ReadData(length)
        local json = util.Decompress(comp)
        local tbl = util.JSONToTable(json)
        local ply = Entity(plynum)

        if IsValid(ply) then
            PPM.PonyData[ply] = PPM.PonyData[ply] or {}
            PPM.PonyData[ply][1] = 1
            PPM.PonyData[ply][2] = tbl
        else
            PPM.FailedEnts[plynum] = {}
            PPM.FailedEnts[plynum].pony = tbl
            PPM.FailedEnts[plynum].retries = 0
        end
    end

    net.Receive("ppm_ponydata", ReceivePony)
    local delayl = 0

    local function LoadPonies()
        if (delayl > CurTime()) then return end
        delayl = CurTime() + 2
        local rq = false

        for k, v in pairs(PPM.UnInitializedPonies) do
            if IsValid(k) then
                rq = true
                PPM.UnInitializedPonies[k] = tostring(k)
            end
        end

        if rq then
            net.Start("ppm_ponyrequest")
            net.WriteTable(PPM.UnInitializedPonies)
            net.SendToServer()
            PPM.UnInitializedPonies = {}
        end

        for k, v in pairs(PPM.FailedEnts) do
            local ply = Entity(k)

            if IsValid(ply) then
                if PPM.PonyData[ply] then
                    PPM.FailedEnts[k] = nil
                else
                    PPM.PonyData[ply] = {}
                    PPM.PonyData[ply][1] = 1
                    PPM.PonyData[ply][2] = v.pony
                    PPM.FailedEnts[k] = nil
                end
            elseif (PPM.FailedEnts[k].retries > 20) then
                PPM.FailedEnts[k] = nil
            else
                PPM.FailedEnts[k].retries = PPM.FailedEnts[k].retries + 1
            end
        end
    end

    hook.Add("Think", "ppm_load_unloaded_ponies", LoadPonies)
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
    local delayr = 0

    hook.Add("Think", "ppm_pony_cleanup", function(ent)
        if (delayr > CurTime()) then return end
        delayr = CurTime() + 0.2
        PPM.RefreshActivePonies()
    end)
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
end

local entity = FindMetaTable("Entity")

function entity:IsPPMPony()
    return PPM.hasPonyModel(self:GetModel())
end