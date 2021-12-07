-- This file is subject to copyright - contact swampservers@gmail.com for more information.
PPM.default_pony = {
    --main
    kind = {
        default = 1,
        min = 1,
        max = 4
    },
    age = {
        default = 2,
        min = 2,
        max = 2
    },
    gender = {
        default = 1,
        min = 1,
        max = 2
    },
    body_type = {
        default = 1,
        min = 1,
        max = 1
    },
    --body
    mane = {
        default = 1,
        min = 1,
        max = 15
    },
    manel = {
        default = 1,
        min = 1,
        max = 12
    },
    tail = {
        default = 1,
        min = 1,
        max = 14
    },
    tailsize = {
        default = 1,
        min = 0.8,
        max = 1.5
    },
    cmark_enabled = {
        default = 2
    },
    cmark = {
        default = 1,
        min = 1,
        max = 30
    },
    bodyweight = {
        default = 1,
        min = 0.5,
        max = 2.0
    },
    coatcolor = {
        default = Vector(1, 1, 1),
        min = Vector(0, 0, 0),
        max = Vector(1, 1, 1)
    },
    haircolor1 = {
        default = Vector(1, 1, 1),
        min = Vector(0, 0, 0),
        max = Vector(1, 1, 1)
    },
    haircolor2 = {
        default = Vector(1, 1, 1),
        min = Vector(0, 0, 0),
        max = Vector(1, 1, 1)
    },
    haircolor3 = {
        default = Vector(1, 1, 1),
        min = Vector(0, 0, 0),
        max = Vector(1, 1, 1)
    },
    haircolor4 = {
        default = Vector(1, 1, 1),
        min = Vector(0, 0, 0),
        max = Vector(1, 1, 1)
    },
    haircolor5 = {
        default = Vector(1, 1, 1),
        min = Vector(0, 0, 0),
        max = Vector(1, 1, 1)
    },
    haircolor6 = {
        default = Vector(1, 1, 1),
        min = Vector(0, 0, 0),
        max = Vector(1, 1, 1)
    },
    --bodydetails
    bodydetail1 = {
        default = 1
    },
    bodydetail2 = {
        default = 1
    },
    bodydetail3 = {
        default = 1
    },
    bodydetail4 = {
        default = 1
    },
    bodydetail5 = {
        default = 1
    },
    bodydetail6 = {
        default = 1
    },
    bodydetail7 = {
        default = 1
    },
    bodydetail8 = {
        default = 1
    },
    bodydetail1_c = {
        default = Vector(1, 1, 1)
    },
    bodydetail2_c = {
        default = Vector(1, 1, 1)
    },
    bodydetail3_c = {
        default = Vector(1, 1, 1)
    },
    bodydetail4_c = {
        default = Vector(1, 1, 1)
    },
    bodydetail5_c = {
        default = Vector(1, 1, 1)
    },
    bodydetail6_c = {
        default = Vector(1, 1, 1)
    },
    bodydetail7_c = {
        default = Vector(1, 1, 1)
    },
    bodydetail8_c = {
        default = Vector(1, 1, 1)
    },
    --eyes
    eyehaslines = {
        default = 1
    },
    eyelash = {
        default = 1,
        min = 1,
        max = 5
    },
    eyeirissize = {
        default = 0.7,
        min = 0.65,
        max = 0.88
    },
    eyeholesize = {
        default = 0.7,
        min = 0.65,
        max = 0.88
    },
    eyejholerssize = {
        default = 1,
        min = 0.2,
        max = 1
    },
    eyecolor_bg = {
        default = Vector(1, 1, 1)
    },
    eyecolor_iris = {
        default = Vector(1, 1, 1) / 3
    },
    eyecolor_grad = {
        default = Vector(1, 1, 1) / 2
    },
    eyecolor_line1 = {
        default = Vector(1, 1, 1) * 0.8
    },
    eyecolor_line2 = {
        default = Vector(1, 1, 1) * 0.9
    },
    eyecolor_hole = {
        default = Vector(0, 0, 0)
    },
    --body clothing
    bodyt0 = {
        default = 1
    }
}

PPM.BODYGROUP_BODY = 1
PPM.BODYGROUP_HORN = 2
PPM.BODYGROUP_WING = 3
PPM.BODYGROUP_MANE = 4
PPM.BODYGROUP_MANE_LOW = 5
PPM.BODYGROUP_TAIL = 6
PPM.BODYGROUP_CMARK = 7
PPM.BODYGROUP_EYELASH = 8
PPM.EYES_COUNT = 10
PPM.MARK_COUNT = 27

-- PPM.pony_models = {
--     ["models/ppm/player_default_base.mdl"] = {
--         isPonyModel = true,
--         BgroupCount = 8
--     }
--     -- ,
-- --     ["models/ppm/player_default_clothes1.mdl"] = {
-- --         isPonyModel = false,
-- --         BgroupCount = 8
-- --     }
-- }
-- function PPM.LOAD()
--     if CLIENT then
--         PPM.setupPony(Me)
--         PPM.SendPonyData()
--     end
--     PPM.RefreshActivePonies()
--     PPM.isLoaded = true
-- end
-- function PPM.setupPony(ent, fake)
--     --if ent.ponydata!=nil then return end 
--     ent.ponydata_tex = ponydata_tex or {}
--     ent.ponydata = ent.ponydata or {}
--     for k, v in SortedPairs(PPM.default_pony) do
--         ent.ponydata[k] = ent.ponydata[k] or v.default
--     end
--     if not fake then
--         if SERVER then
--             if not IsValid(ent.ponydata.clothes1) then
--                 ent.ponydata.clothes1 = ents.Create("prop_dynamic")
--                 ent.ponydata.clothes1:SetModel("models/ppm/player_default_clothes1.mdl")
--                 ent.ponydata.clothes1:DrawShadow(false)
--                 ent.ponydata.clothes1:SetParent(ent)
--                 ent.ponydata.clothes1:AddEffects(EF_BONEMERGE)
--                 ent.ponydata.clothes1:SetRenderMode(RENDERMODE_TRANSALPHA)
--                 --ent.ponydata.clothes1:SetNoDraw(true)	
--                 ent:SetNetworkedEntity("pny_clothing", ent.ponydata.clothes1)
--             end
--             --PPM.setPonyValues(ent)
--         end
--     end
-- end
-- function PPM.cleanPony(ent)
--     PPM.setupPony(ent)
--     for k, v in SortedPairs(PPM.default_pony) do
--         ent.ponydata[k] = v.default
--     end
--     --ent.ponydata._cmark = nil
--     --ent.ponydata._cmark_loaded = false 
-- end
-- function PPM.copyLocalPonyTo(from, to)
--     to.ponydata = to.ponydata or {} -- Make sure ponydata is initialized
--     local clothes = to.ponydata.clothes1 -- Get the clothing data if possible
--     to.ponydata = table.Copy(from.ponydata)
--     to.ponydata.clothes1 = clothes
-- end
-- function PPM.copyLocalTextureDataTo(from, to)
--     to.ponydata_tex = table.Copy(from.ponydata_tex)
-- end
-- function PPM.copyPonyTo(from, to)
--     to.ponydata = to.ponydata or {} -- Make sure ponydata is initialized
--     local clothes = to.ponydata.clothes1 -- Get the clothing data if possible
--     to.ponydata = table.Copy(PPM.getPonyValues(from))
--     to.ponydata.clothes1 = clothes
-- end
-- function PPM.mergePonyData(destination, addition)
-- end
-- function PPM.hasPonyModel(model)
--     if PPM.pony_models[model] == nil then return false end
--     return PPM.pony_models[model].isPonyModel
-- end
-- function PPM.isValidPonyLight(ent)
--     if not IsValid(ent) then return false end
--     if not PPM.hasPonyModel(ent:GetModel()) then return false end
--     return true
-- end
-- function PPM.isValidPony(ent)
--     if not IsValid(ent) then return false end
--     if ent.ponydata == nil then return false end
--     if not PPM.hasPonyModel(ent:GetModel()) then return false end
--     return true
-- end
PPM.rig = {
    neck = {4, 5, 6},
    ribcage = {1, 2, 3},
    rear = {0},
    leg_BL = {8, 9, 10, 11, 12},
    leg_BR = {13, 14, 15, 16, 17},
    leg_FL = {18, 19, 20, 21, 22, 23},
    leg_FR = {24, 25, 26, 27, 28, 29}
}

PPM.rig_tail = {38, 39, 40}
-- function PPM.getPonyValues(ent, localvals)
--     if (localvals) then
--         local pony = ent.ponydata
--         pony._cmark = {}
--         return ent.ponydata
--     else
--         PPM.UnInitializedPonies[ent] = nil
--         local pony
--         if PPM.PonyData[ent] then
--             pony = PPM.PonyData[ent][2]
--         end
--         if not pony then
--             --EntIndex() ~= -1 then
--             if ent:IsPlayer() then
--                 PPM.UnInitializedPonies[ent] = true
--             end
--             pony = {}
--             for k, v in pairs(PPM.default_pony) do
--                 pony[k] = v.default
--             end
--         end
--         pony._cmark = {}
--         return pony
--     end
-- end
-- if CLIENT then end -- function PPM.RELOAD() -- end -- function getValues() --     local pony = PPM.getPonyValues(Me, false) --     for k, v in SortedPairs(pony) do --         MsgN(k .. " = " .. tostring(v)) --     end -- end -- function getValuesl() --     local pony = PPM.getPonyValues(Me, true) --     for k, v in SortedPairs(pony) do --         MsgN(k .. " = " .. tostring(v)) --     end -- end -- function reloadPPM() --     PPM.isLoaded = false -- end -- function getLocalBoneAng(ent, boneid) --     local wangle = ent:GetBoneMatrix(boneid):GetAngles() --     local parentbone = ent:GetBoneParent(boneid) --     local wangle_parent = ent:GetBoneMatrix(parentbone):GetAngles() --     local lp, la = WorldToLocal(Vector(0, 0, 0), wangle, Vector(0, 0, 0), wangle_parent) --     return la -- end -- function getWorldAng(ent, boneid, ang) --     --local wangle = ent:GetBoneMatrix(boneid):GetAngles() --     local parentbone = ent:GetBoneParent(boneid) --     local wangle_parent = ent:GetBoneMatrix(parentbone):GetAngles() --     local lp, la = LocalToWorld(Vector(0, 0, 0), ang, Vector(0, 0, 0), wangle_parent) --     return la -- end -- concommand.Add("ppm_getvalues", getValues) -- concommand.Add("ppm_getvaluesl", getValuesl) -- concommand.Add("ppm_reload", reloadPPM)
-- if SERVER then end -- function PPM.setPonyValues(ent) --     if not PPM.isValidPony(ent) then return end --     --local custom_mark_temp = ent.ponydata.custom_mark --     --ent.ponydata.custom_mark = nil --     local ocData = PPM.PonyDataToString(ent.ponydata) --     --ent.ponydata.custom_mark = custom_mark_temp --     local sig --     local id --     --if SERVER then --     --     PPM.SendCharToClients(ent) --     --end -- end -- hook.Add("PlayerSpawnedRagdoll", "pony_spawnragdoll", function(ply, model, ent) --     if PPM.isValidPonyLight(ent) then --         PPM.randomizePony(ent) --         --PPM.initPonyValues(ent) --         PPM.setPonyValues(ent) --         PPM.setBodygroups(ent) --     end -- end) --[[
-- 	local function HOOK_PlayerSpawn( ply )
-- 		local m = ply:GetInfo( "cl_playermodel" )
-- 		if(m=="pony")or (m=="ponynj")then
--             timer.Simple( 1, function()
--                 if ply.ponydata==nil then 
--                     PPM.setupPony( ply )
--                 end
--                 PPM.setBodygroups( ply, false )
--                 --PPM.setPonyValues(ply)
--                 --PPM.ccmakr_onplyinitspawn(ply)
-- 			end )
-- 		end
-- 	end --hook.Add("PlayerSpawn", "pony_spawn", HOOK_PlayerSpawn) -- local playertable = FindMetaTable("Player") -- if playertable.SetModelInsidePPM == nil then --     playertable.SetModelInsidePPM = playertable.SetModel or FindMetaTable("Entity").SetModel --     function playertable:SetModel(modelName) --         self:SetModelInsidePPM(modelName) --         if modelName ~= self.pi_prevplmodel then --             PPM:pi_UnequipAll(self) --         end --         if PPM.hasPonyModel(modelName) then --             -- timer.Simple( 1, function() --             if self.ponydata == nil then --                 PPM.setupPony(self) --             end --             PPM.setBodygroups(self, false) --             PPM.setPonyValues(self) --             --PPM.ccmakr_onplyinitspawn(ply) --             --end ) --         end --         self.pi_prevplmodel = modelName --     end -- end
