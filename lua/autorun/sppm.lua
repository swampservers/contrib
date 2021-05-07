-- This file is subject to copyright - contact swampservers@gmail.com for more information.
PPM = PPM or {}
PPM.Playermodel = "models/ppm/player_default_base.mdl"
local Entity = FindMetaTable("Entity")

function Entity:IsPPMPony()
    return self:GetModel() == PPM.Playermodel
end

function Entity:PonyPlayer()
    if self:IsPlayer() then return self end
    if self:EntIndex() == -1 then return LocalPlayer() end --pointshop model
    if self.RagdollSourcePlayer then return self.RagdollSourcePlayer end
    -- if self.PonyPlayerEntity then return 
    -- if its a ragdoll then return owner
    print(self, "unknown pony")
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
-- TODO MOVE THIS TO pony_player.lua AND USE THE SAME TABLE AS IS IN THERE
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
    bodydetail1_c = {},
    bodydetail2_c = {},
    bodydetail3_c = {},
    bodydetail4_c = {},
    bodydetail5_c = {},
    bodydetail6_c = {},
    bodydetail7_c = {},
    bodydetail8_c = {},
    bodyt1_color = {},
    coatcolor = {},
    eyecolor_bg = {},
    eyecolor_grad = {},
    eyecolor_hole = {Vector(0, 0, 0)},
    eyecolor_iris = {},
    eyecolor_line1 = {},
    eyecolor_line2 = {},
    haircolor1 = {},
    haircolor2 = {},
    haircolor3 = {},
    haircolor4 = {},
    haircolor5 = {},
    haircolor6 = {}
}

function SanitizePonyCfg(in_cfg)
    local cfg = {}

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

function PPM_SetBodyGroups(ent)
    if not ent:IsPPMPony() then return end
    local ply = ent:PonyPlayer()
    if not IsValid(ply) then return end
    local ponydata = ply.ponydata
    if not ponydata then return end
    local h, w

    if ponydata.kind == 1 then
        h, w = 1, 1
    elseif ponydata.kind == 2 then
        h, w = 1, 0
    elseif ponydata.kind == 3 then
        h, w = 0, 1
    else
        h, w = 0, 0
    end

    ent:SetBodygroup(PPM.BODYGROUP_HORN, h)
    ent:SetBodygroup(PPM.BODYGROUP_WING, w)
    ent:SetBodygroup(PPM.BODYGROUP_BODY, ponydata.gender - 1)
    ent:SetBodygroup(PPM.BODYGROUP_MANE, ponydata.mane - 1)
    ent:SetBodygroup(PPM.BODYGROUP_MANE_LOW, ponydata.manel - 1)
    ent:SetBodygroup(PPM.BODYGROUP_TAIL, ponydata.tail - 1)
    ent:SetBodygroup(PPM.BODYGROUP_CMARK, ponydata.cmark_enabled - 1)
    ent:SetBodygroup(PPM.BODYGROUP_EYELASH, (ponydata.gender == 1) and (ponydata.eyelash - 1) or 5)
end

if CLIENT then
    local stock_weapon_pony_position = {
        weapon_crowbar = {
            {0, Vector(3, 3.6, 7), Angle(0, 0, 4)}
        },
        weapon_pistol = {
            {1, Vector(9.5, 2, -4), Angle(-10, -5, 0)}
        },
        weapon_357 = {
            {1, Vector(4, 3.5, 0), Angle(-10, -5, 0)}
        },
        weapon_smg1 = {
            {2, Vector(10, 1, -4), Angle(-10, -5, 0)}
        },
        weapon_ar2 = {
            {1, Vector(-1, 6, -3), Angle(0, 5, -90)}
        },
        weapon_shotgun = {
            {1, Vector(-2, 5, -3), Angle(-3, -2, -90)}
        },
        weapon_crossbow = {
            {2, Vector(-1, 11, -3), Angle(-90, -95, -90)}
        },
        weapon_rpg = {
            {1, Vector(-1, 13, -4), Angle(-90, -85, -90)}
        },
        weapon_frag = {
            {0, Vector(9, 0, 0.5), Angle(20, 150, 0)}
        },
        weapon_slam = {
            {1, Vector(8.5, 2.3, -5), Angle(-4, 125, -93)}
        },
        weapon_bugbait = {
            {0, Vector(6, 4.2, 0), Angle(0, 0, 0)}
        },
        weapon_physcannon = {
            {1, Vector(-4, 11, -4), Angle(-90, -95, -90)},
            {2, Vector(0, 2.5, 24), Angle(0, 0, 0)},
            {3, Vector(0, 5, 20), Angle(0, 0, 0)},
            {4, Vector(3, 0.5, 20), Angle(0, 60, 0)},
            {5, Vector(-2, 1, 20), Angle(0, -60, 0)},
        }
    }

    stock_weapon_pony_position.weapon_physgun = stock_weapon_pony_position.weapon_physcannon

    hook.Add("OnEntityCreated", "PonyStockWeapons", function(ent)
        if stock_weapon_pony_position[ent:GetClass()] then
            ent:AddCallback("BuildBonePositions", function(ent, numbones)
                local o = ent:GetOwner()

                if o and IsValid(o) then
                    local misspelled_skull = o:LookupBone("LrigScull")

                    if misspelled_skull then
                        local spos, sang = o:GetBonePosition(misspelled_skull)

                        if (o.ponydata or {}).gender == 2 then
                            spos = spos + sang:Forward() * 1.9 + sang:Right() * 0.6
                        end

                        local rootpos, rootang

                        for i, v in ipairs(stock_weapon_pony_position[ent:GetClass()]) do
                            local wepbone, pos, ang = unpack(v)

                            if i > 1 then
                                pos, ang = LocalToWorld(pos, ang, rootpos, rootang)
                            else
                                rootpos, rootang = pos, ang
                            end

                            -- Without this it throws an uncatchable error when you pull out the physgun
                            if ent:GetBoneContents(wepbone) > 0 then
                                ent:SetBonePosition(wepbone, LocalToWorld(pos, ang, spos, sang))
                            end
                        end
                    end
                end
            end)
        end
    end)
end