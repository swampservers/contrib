-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local BODYGROUP_BODY = 1
local BODYGROUP_HORN = 2
local BODYGROUP_WING = 3
local BODYGROUP_MANE = 4
local BODYGROUP_MANE_LOW = 5
local BODYGROUP_TAIL = 6
local BODYGROUP_CMARK = 7
local BODYGROUP_EYELASH = 8
local EYES_COUNT = 10
local MARK_COUNT = 27
PPM.pony_models = {}

PPM.pony_models["models/ppm/player_default_base.mdl"] = {
    isPonyModel = true,
    BgroupCount = 8
}

PPM.pony_models["models/ppm/player_default_base_nj.mdl"] = {
    isPonyModel = true,
    BgroupCount = 8
}

PPM.pony_models["models/ppm/player_default_base_ragdoll.mdl"] = {
    isPonyModel = true,
    BgroupCount = 8
}

PPM.pony_models["models/ppm/player_mature_base.mdl"] = {
    isPonyModel = true,
    BgroupCount = 6
}

PPM.pony_models["models/ppm/player_default_clothes1.mdl"] = {
    isPonyModel = false,
    BgroupCount = 8
}

function PPM.LOAD()
    if CLIENT then
        PPM.setupPony(LocalPlayer())
        PPM.loadResources()
        PPM.Load_settings()
        PPM.loadrt()
        PPM.SendPonyData()
    end

    PPM.RefreshActivePonies()
    PPM.isLoaded = true
end

function PPM.setupPony(ent, fake)
    --if ent.ponydata!=nil then return end 
    ent.ponydata_tex = ponydata_tex or {}
    ent.ponydata = ent.ponydata or {}

    for k, v in SortedPairs(PPM.Pony_variables.default_pony) do
        ent.ponydata[k] = ent.ponydata[k] or v.default
    end

    if not fake then
        if SERVER then
            if not IsValid(ent.ponydata.clothes1) then
                ent.ponydata.clothes1 = ents.Create("prop_dynamic")
                ent.ponydata.clothes1:SetModel("models/ppm/player_default_clothes1.mdl")
                ent.ponydata.clothes1:DrawShadow(false)
                ent.ponydata.clothes1:SetParent(ent)
                ent.ponydata.clothes1:AddEffects(EF_BONEMERGE)
                ent.ponydata.clothes1:SetRenderMode(RENDERMODE_TRANSALPHA)
                --ent.ponydata.clothes1:SetNoDraw(true)	
                ent:SetNetworkedEntity("pny_clothing", ent.ponydata.clothes1)
            end
            --PPM.setPonyValues(ent)
        end
    end
end

function PPM.doRespawn(ply)
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
end

function PPM.getPonyEnts()
end

function PPM.reValidatePonies()
end

function PPM.cleanPony(ent)
    PPM.setupPony(ent)

    for k, v in SortedPairs(PPM.Pony_variables.default_pony) do
        ent.ponydata[k] = v.default
    end
    --ent.ponydata._cmark = nil
    --ent.ponydata._cmark_loaded = false 
end

function PPM.randomizePony(ent)
    PPM.setupPony(ent)
    ent.ponydata.kind = math.Round(math.Rand(1, 4))
    ent.ponydata.gender = math.Round(math.Rand(1, 2))
    ent.ponydata.body_type = 1
    ent.ponydata.mane = math.Round(math.Rand(1, 15))
    ent.ponydata.manel = math.Round(math.Rand(1, 12))
    ent.ponydata.tail = math.Round(math.Rand(1, 14))
    ent.ponydata.tailsize = math.Rand(0.8, 1)
    ent.ponydata.eye = math.Round(math.Rand(1, EYES_COUNT))
    ent.ponydata.eyelash = math.Round(math.Rand(1, 5))
    ent.ponydata.coatcolor = Vector(math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1))

    for I = 1, 6 do
        ent.ponydata["haircolor" .. I] = Vector(math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1))
    end

    for I = 1, 8 do
        ent.ponydata["bodydetail" .. I] = 1
        ent.ponydata["bodydetail" .. I .. "_c"] = Vector(0, 0, 0)
    end

    ent.ponydata.cmark = math.Round(math.Rand(1, MARK_COUNT))
    ent.ponydata.bodyweight = math.Rand(0.8, 1.2)
    ent.ponydata.bodyt0 = 1 --math.Round(math.Rand(1,4)) 
    ent.ponydata.bodyt1_color = Vector(math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1))
    local iriscolor = Vector(math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1)) * 2
    ent.ponydata.eyecolor_bg = Vector(1, 1, 1)
    ent.ponydata.eyeirissize = 0.7 + math.Rand(-0.1, 0.1)
    ent.ponydata.eyecolor_iris = iriscolor
    ent.ponydata.eyecolor_grad = iriscolor / 3
    ent.ponydata.eyecolor_line1 = iriscolor * 0.9
    ent.ponydata.eyecolor_line2 = iriscolor * 0.8
    ent.ponydata.eyeholesize = 0.7 + math.Rand(-0.1, 0.1)
    ent.ponydata.eyecolor_hole = Vector(0, 0, 0)
end

function PPM.copyLocalPonyTo(from, to)
    to.ponydata = to.ponydata or {} -- Make sure ponydata is initialized
    local clothes = to.ponydata.clothes1 -- Get the clothing data if possible
    to.ponydata = table.Copy(from.ponydata)
    to.ponydata.clothes1 = clothes
end

function PPM.copyLocalTextureDataTo(from, to)
    to.ponydata_tex = table.Copy(from.ponydata_tex)
end

function PPM.copyPonyTo(from, to)
    to.ponydata = to.ponydata or {} -- Make sure ponydata is initialized
    local clothes = to.ponydata.clothes1 -- Get the clothing data if possible
    to.ponydata = table.Copy(PPM.getPonyValues(from))
    to.ponydata.clothes1 = clothes
end

function PPM.mergePonyData(destination, addition)
    for k, v in pairs(addition) do
        destination[k] = v
    end
end

function PPM.hasPonyModel(model)
    if PPM.pony_models[model] == nil then return false end

    return PPM.pony_models[model].isPonyModel
end

function PPM.isValidPonyLight(ent)
    if not IsValid(ent) then return false end
    if not PPM.hasPonyModel(ent:GetModel()) then return false end

    return true
end

function PPM.isValidPony(ent)
    if not IsValid(ent) then return false end
    if ent.ponydata == nil then return false end
    if not PPM.hasPonyModel(ent:GetModel()) then return false end

    return true
end

PPM.rig = {}

PPM.rig.neck = {4, 5, 6}

PPM.rig.ribcage = {1, 2, 3}

PPM.rig.rear = {0}

PPM.rig.leg_BL = {8, 9, 10, 11, 12}

PPM.rig.leg_BR = {13, 14, 15, 16, 17}

PPM.rig.leg_FL = {18, 19, 20, 21, 22, 23}

PPM.rig.leg_FR = {24, 25, 26, 27, 28, 29}

PPM.rig_tail = {38, 39, 40}

function PPM.setBodygroups(ent, localvals)
    if not PPM.isValidPony(ent) then return end
    local ponydata = PPM.getPonyValues(ent, localvals)

    --if true then return end   
    if (ponydata.kind == 1) then
        PPM.setBodygroupSafe(ent, BODYGROUP_HORN, 1) --h
        PPM.setBodygroupSafe(ent, BODYGROUP_WING, 1) --w
    elseif (ponydata.kind == 2) then
        PPM.setBodygroupSafe(ent, BODYGROUP_HORN, 1)
        PPM.setBodygroupSafe(ent, BODYGROUP_WING, 0)
    elseif (ponydata.kind == 3) then
        PPM.setBodygroupSafe(ent, BODYGROUP_HORN, 0)
        PPM.setBodygroupSafe(ent, BODYGROUP_WING, 1)
    else
        PPM.setBodygroupSafe(ent, BODYGROUP_HORN, 0)
        PPM.setBodygroupSafe(ent, BODYGROUP_WING, 0)
    end

    PPM.setBodygroupSafe(ent, BODYGROUP_BODY, ponydata.gender - 1)
    PPM.setBodygroupSafe(ent, BODYGROUP_MANE, ponydata.mane - 1)
    PPM.setBodygroupSafe(ent, BODYGROUP_MANE_LOW, ponydata.manel - 1)
    PPM.setBodygroupSafe(ent, BODYGROUP_TAIL, ponydata.tail - 1)
    PPM.setBodygroupSafe(ent, BODYGROUP_CMARK, ponydata.cmark_enabled - 1)

    if ponydata.gender == 1 then
        PPM.setBodygroupSafe(ent, BODYGROUP_EYELASH, ponydata.eyelash - 1)
    else
        PPM.setBodygroupSafe(ent, BODYGROUP_EYELASH, 5)
    end
end

function PPM.setBodygroupSafe(ent, bgid, bgval)
    if ent == nil or not IsEntity(ent) or ent == NULL then return end
    if bgid < 1 or bgval < 0 then return end
    local mdl = ent:GetModel()
    if PPM.pony_models[mdl] == nil then return end
    if bgid > PPM.pony_models[mdl].BgroupCount then return end
    ent:SetBodygroup(bgid, bgval)
end

function PPM.initPonyValues(ent)
    if not PPM.isValidPonyLight(ent) then return end
    --[[
	ent.SetupDataTables = function()
	
	self:NetworkVar( "Vector",	0,	"pny_coatcolor",	{ KeyName = "topcolor", Edit = { type = "VectorColor", category = "Main", title = "Coat color", order = 1 } } );		
	self:NetworkVar( "Vector",	1,	"pny_haircolor1",	{ KeyName = "bottomcolor", Edit = { type = "VectorColor", category = "Main", title = "Hair Color 1", order = 2  } } );		
	end
	ent.SetupDataTables(ent)
	]]
end

function PPM.getPonyValues(ent, localvals)
    if (localvals) then
        local pony = ent.ponydata
        pony._cmark = {}

        return ent.ponydata
    else
        PPM.UnInitializedPonies[ent] = nil
        local pony

        if PPM.PonyData[ent] then
            pony = PPM.PonyData[ent][2]
        end

        if not pony then
            --EntIndex() ~= -1 then
            if ent:IsPlayer() then
                PPM.UnInitializedPonies[ent] = true
            end

            pony = {}

            for k, v in pairs(PPM.Pony_variables.default_pony) do
                pony[k] = v.default
            end
        end

        pony._cmark = {}

        return pony
    end
end

if CLIENT then
    PPM.jiggleboneids = {}

    function PPM.fixJigglebones(ent)
        local bonecount = ent:GetBoneCount()
        print("PLAYER BONECOUNT:", bonecount)
        bboneeez(ent, bonecount, bonecount)
        ent.BuildBonePositions(ent, bonecount)
        --Entity:GetBoneMatrix( number boneID )
    end
end

--///////////////////////////////////////////////////////////////CLIENT
if CLIENT then
    function PPM.RELOAD()
    end

    function getValues()
        local pony = PPM.getPonyValues(LocalPlayer(), false)

        for k, v in SortedPairs(pony) do
            MsgN(k .. " = " .. tostring(v))
        end
    end

    function getValuesl()
        local pony = PPM.getPonyValues(LocalPlayer(), true)

        for k, v in SortedPairs(pony) do
            MsgN(k .. " = " .. tostring(v))
        end
    end

    function reloadPPM()
        PPM.isLoaded = false
    end

    function OnEntityCreated(ent)
        --[[
  print("3456345")
		if ent:IsPlayer() then -- We want to define this for each player that gets created.
	 print("BONE:235235")
			ent.BuildBonePositions = function( self, NumBones, NumPhysBones )
					print("BONE:")
				-- Do stuff
				 bboneeez(self, NumBones, NumPhysBones )
			end
	 
		end
	 ]]
    end

    function getLocalBoneAng(ent, boneid)
        local wangle = ent:GetBoneMatrix(boneid):GetAngles()
        local parentbone = ent:GetBoneParent(boneid)
        local wangle_parent = ent:GetBoneMatrix(parentbone):GetAngles()
        local lp, la = WorldToLocal(Vector(0, 0, 0), wangle, Vector(0, 0, 0), wangle_parent)

        return la
    end

    function getWorldAng(ent, boneid, ang)
        --local wangle = ent:GetBoneMatrix(boneid):GetAngles()
        local parentbone = ent:GetBoneParent(boneid)
        local wangle_parent = ent:GetBoneMatrix(parentbone):GetAngles()
        local lp, la = LocalToWorld(Vector(0, 0, 0), ang, Vector(0, 0, 0), wangle_parent)

        return la
    end

    function bboneeez(self, NumBones, NumPhysBones)
        for k = 1, NumBones - 1 do
            print("BONE:", k, self:GetBoneName(k))
            local bmatrix = self:GetBoneMatrix(k)

            --if( k>=30 && k<=40 )then
            -- print("","",bmatrix:GetAngles())
            --bmatrix:SetAngles( Angle(0,0,0) )
            -- print("","",bmatrix:GetAngles()) 
            --ent:SetBoneMatrix(k,bmatrix) 
            --ent:ManipulateBoneAngles(k,Angle(0,10,0) )
            --self:SetBonePosition( k, Vector(0,0,0),Angle(0,10,0) )
            if (k == 40) then
                local ba = getLocalBoneAng(self, k)
                local diff1 = Angle(0.133, 0.000, 0.021) - ba
                local diff2 = getWorldAng(self, k, diff1)
                print("PREV", ba)
                print("DIFF", diff1)
                print("DIFF", diff2)
                self:ManipulateBoneAngles(k, -diff2) --diff1) 
                print("AFTE", getLocalBoneAng(self, k))
            end
            --self:ManipulateBoneAngles( k,getLocalBoneAng(self,k)- Angle(180,180,180))//self:GetManipulateBoneAngles( k)+ Angle(0,190,190))
            --print(self:GetManipulateBoneAngles( k))
            --ent:SetupBones()
            --end 
        end

        --An entity cannot have more than 128 bones
        for i = 1, NumBones do
            -- self:SetBonePosition( i, VectorRand() * 32, VectorRand():Angle() )
        end
    end

    hook.Add("OnEntityCreated", "pony_spawnent", OnEntityCreated)
    concommand.Add("ppm_getvalues", getValues)
    concommand.Add("ppm_getvaluesl", getValuesl)
    concommand.Add("ppm_reload", reloadPPM)

    concommand.Add("ppm_getbones", function(ply)
        for i = 0, ply:GetBoneCount() - 1 do
            MsgN(i, " - ", ply:GetBoneName(i))
        end
    end)
end

--///////////////////////////////////////////////////////////////SERVER
if SERVER then
    function PPM.setPonyValues(ent)
        if not PPM.isValidPony(ent) then return end
        --local custom_mark_temp = ent.ponydata.custom_mark
        --ent.ponydata.custom_mark = nil
        local ocData = PPM.PonyDataToString(ent.ponydata)
        --ent.ponydata.custom_mark = custom_mark_temp
        local sig
        local id
        --if SERVER then
        --     PPM.SendCharToClients(ent)
        --end
    end

    local function HOOK_SpawnedRagdoll(ply, model, ent)
        if PPM.isValidPonyLight(ent) then
            PPM.randomizePony(ent)
            --PPM.initPonyValues(ent)
            PPM.setPonyValues(ent)
            PPM.setBodygroups(ent)
        end
    end

    --[[
	local function HOOK_PlayerSpawn( ply )
		local m = ply:GetInfo( "cl_playermodel" )
		if(m=="pony")or (m=="ponynj")then
            timer.Simple( 1, function()
                if ply.ponydata==nil then 
                    PPM.setupPony( ply )
                end
                
                PPM.setBodygroups( ply, false )
                --PPM.setPonyValues(ply)
                --PPM.ccmakr_onplyinitspawn(ply)
			end )
		end
	end ]]
    --hook.Add("PlayerSpawn", "pony_spawn", HOOK_PlayerSpawn)
    hook.Add("PlayerSpawnedRagdoll", "pony_spawnragdoll", HOOK_SpawnedRagdoll)
    local playertable = FindMetaTable("Player")

    if playertable.SetModelInsidePPM == nil then
        playertable.SetModelInsidePPM = playertable.SetModel or FindMetaTable("Entity").SetModel

        function playertable:SetModel(modelName)
            self:SetModelInsidePPM(modelName)

            if modelName ~= self.pi_prevplmodel then
                PPM:pi_UnequipAll(self)
            end

            if PPM.hasPonyModel(modelName) then
                -- timer.Simple( 1, function()
                if self.ponydata == nil then
                    PPM.setupPony(self)
                end

                PPM.setBodygroups(self, false)
                PPM.setPonyValues(self)
                --PPM.ccmakr_onplyinitspawn(ply)
                --end )
            end

            self.pi_prevplmodel = modelName
        end
    end
end