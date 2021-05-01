-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--player_manager.AddValidModel( "pony", "models/ppm/player_default_base.mdl" ) 
--player_manager.AddValidModel( "ponynj", "models/ppm/player_default_base_nj.mdl" )  
PPM = PPM or {}
PPM.Playermodel = "models/ppm/player_default_base.mdl"
FindMetaTable("Entity").IsPPMPony = function(self) return self:GetModel() == PPM.Playermodel end

FindMetaTable("Entity").PonyPlayer = function(self)
    if self:IsPlayer() then return self end
	if self:EntIndex() == -1 then return LocalPlayer() end --pointshop model
	if self.RagdollSourcePlayer then return self.RagdollSourcePlayer end
	-- if self.PonyPlayerEntity then return 
    -- if its a ragdoll then return owner
    print(self)
end

PPM.serverPonydata = PPM.serverPonydata or {}
PPM.isLoaded = false

-- Deleted items because apparently it was never even meant to save, what a garbage system!
-- Even if I added saving of the items, it would be incompatible with other PPM servers.
-- Plus it is extra complication.
-- include("sppm/items.lua") 

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
    -- AddCSLuaFile("sppm/items.lua")
    AddCSLuaFile("sppm/pony_player.lua")
    AddCSLuaFile("sppm/render.lua")
    AddCSLuaFile("sppm/render_texture.lua")
    AddCSLuaFile("sppm/resources.lua")
end









-- TODO SET MAX NUMBERS TO THE CORRECT MAX OR AT LEAST HIGH ENOUGH
local ponydata_numbers = {
    age = {2, 2, 2},
    body_type = {1, 1, 1},
    bodydetail1 = {1, 21, 1},
    bodydetail2 = {1, 21, 1},
    bodydetail3 = {1, 21, 1},
    bodydetail4 = {1, 21, 1},
    bodydetail5 = {1, 21, 1},
    bodydetail6 = {1, 21, 1},
    bodydetail7 = {1, 21, 1},
    bodydetail8 = {1, 21, 1},
    bodyt0 = {1, 6, 1},
    bodyt1 = {1, 1, 1},
    bodyweight = {0.5, 2.0, 1},
    cmark = {1, 48, 1},
    cmark_enabled = {1, 2, 2},
    eye = {1, 10, 1},
    eyehaslines = {1, 2, 1},
    eyeholesize = {0.3, 1, 0.8},
    eyeirissize = {0.2, 2, 1},
    eyejholerssize = {0.2, 1, 1},
    eyelash = {1, 6, 1},
    gender = {1, 2, 1},
    kind = {1, 4, 1},
    mane = {1, 16, 1},
    manel = {1, 13, 1},
    tail = {1, 15, 1},
    tailsize = {0.8, 1.5, 1}
}

local ponydata_vectors = {
    bodydetail1_c={},
    bodydetail2_c={}, bodydetail3_c={}, bodydetail4_c={},bodydetail5_c={},bodydetail6_c={},bodydetail7_c={},bodydetail8_c={},bodyt1_color={},coatcolor={},eyecolor_bg={},eyecolor_grad={},
    eyecolor_hole={Vector(0,0,0)},eyecolor_iris={},eyecolor_line1={},eyecolor_line2={},haircolor1={},haircolor2={},haircolor3={},haircolor4={},haircolor5={},haircolor6={}}

function SanitizePonyCfg(in_cfg)
    local cfg = {}

    -- local json = util.JSONToTable(util.Decompress(data))
    -- local pdata = {}
    -- pdata._cmark_loaded = false
    for k, v in pairs(ponydata_numbers) do
        local value = in_cfg[k]
        value = isnumber(value) and value or v[3]
        value = math.Clamp(value, v[1], v[2])

        if v[4] then
            value = math.floor(value)
        end

        cfg[k] = value
    end

    for k, v in pairs(ponydata_vectors) do
        local value = in_cfg[k]
        local vec = isvector(value) and value or v[1] or Vector(1, 1, 1)
        vec.x = math.Clamp(vec.x, 0, 1)
        vec.y = math.Clamp(vec.y, 0, 1)
        vec.z = math.Clamp(vec.z, 0, 1)
        cfg[k] = vec
    end

    cfg.imgurcmark = SanitizeImgurId(in_cfg.imgurcmark)

    return cfg
end


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

function PPM_SetBodyGroups(ent)
	if not ent:IsPPMPony() then return end
	local ply = ent:PonyPlayer()
	if not IsValid(ply) then return end
	local ponydata = ply.ponydata
	if not ponydata then return end

	local h,w
	if ponydata.kind == 1 then
		h,w=1,1
    elseif ponydata.kind == 2 then
        h,w=1,0
    elseif ponydata.kind == 3 then
        h,w=0,1
    else
        h,w=0,0
    end

	ent:SetBodygroup( BODYGROUP_HORN, h)
	ent:SetBodygroup( BODYGROUP_WING, w)
    ent:SetBodygroup( BODYGROUP_BODY, ponydata.gender - 1)
    ent:SetBodygroup( BODYGROUP_MANE, ponydata.mane - 1)
    ent:SetBodygroup( BODYGROUP_MANE_LOW, ponydata.manel - 1)
    ent:SetBodygroup( BODYGROUP_TAIL, ponydata.tail - 1)
    ent:SetBodygroup( BODYGROUP_CMARK, ponydata.cmark_enabled - 1)
	ent:SetBodygroup( BODYGROUP_EYELASH, (ponydata.gender == 1) and (ponydata.eyelash - 1) or 5)
end