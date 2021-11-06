-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA 
SS_Tab("Swag", "color_swatch")
SS_Heading("Accessories")
local accessoryradius = 20


SS_AccessoryModels = {
    ["models/props_halloween/jackolantern_01.mdl"] = {
        name = "Jack-O-Lantern",
        description = "Halloween 2021 unique",
        wear = {

            attach="eyes",
            scale = 0.28,
            translate = Vector(-3.45, 0, -4.9),
            rotate = Angle(0,0,0),
            pony = {

                    attach = "lower_body",
                    scale = 0.28,
                    
                    translate = Vector(0, -1.1, 0),
                    rotate = Angle(180,0,90)
                },  
        }
        
    }
}
    

-- (SS_AccessoryModels[self.specs.model] or {}).scaleoffset or 
-- TODO: Mark rare items (jackolantern) in description
SS_Item({
    class = 'accessory',
    GetName = function(self) return (SS_AccessoryModels[self.specs.model] or {}).name or string.sub(table.remove(string.Explode("/", self.specs.model)), 1, -5) end,
    GetDescription = function(self) return ( (SS_AccessoryModels[self.specs.model] or {}).description or "You can wear it.") end,
    ScaleLimitOffset = function(self) return (12 / ((self.dspecs or {})[1] or 12))  end,
    GetModel = function(self) return self.specs.model end,
    SanitizeSpecs = function(self)
        local specs, ch = self.specs, false

        if not specs.model then
            specs.model = specs[1] or SelectAccessoryModel() --GetSandboxProp(accessoryradius)
            ch = true
        end

        if specs[1] then
            specs[1] = nil
            ch = true
        end

        return ch
    end,
    color = Vector(1, 1, 1),
    maxscale = 2.0,
        
    settings = {
        wear = {
            scale = {
                min = Vector(0.05, 0.05, 0.05),
                max = Vector(2,2,2)
            },
            pos = {
                min = Vector(-16, -16, -16),
                max = Vector(16, 16, 16)
            }
        },
        
        color = {
            max = 5
        },
        imgur=true

    },
    accessory_slot = true,
    invcategory = "Accessories",
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(8, 0, 0),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 1,
            translate = Vector(8, 0, 0),
            rotate = Angle(0, 0, 0),
        }
    },

    AccessoryTransform = function(self,pone)
        local wear2 = (SS_AccessoryModels[self.specs.model] or {}).wear or self.wear
        local wear = pone and wear2.pony or wear2
        local cfg = self.cfg[pone and "wear_p" or "wear_h"] or {}
        local attach = cfg.attach or wear.attach or wear2.attach
        local translate = cfg.pos or wear.translate or wear2.translate
        local rotate = cfg.ang or wear.rotate or wear2.rotate
        local scale = cfg.scale or wear.scale or wear2.scale
        -- isnumber(scale) and Vector(scale,scale,scale) or scale

        return attach, translate, rotate, scale
    end,

    SellValue = function(self) return (SS_AccessoryModels[self.specs.model] or {}).value or 25000 end
})

-- if SERVER then props={} for i=1,80 do table.insert(props,SelectAccessoryModel()) end net.Start("RunLuaLong") net.WriteString("SetClipboardText([[ "..util.TableToJSON(props).." ]])") net.Send(ME()) end
-- local previews = {"models/props_junk/PopCan01a.mdl", "models/props_lab/jar01b.mdl", "models/dav0r/buttons/button.mdl", "models/food/burger.mdl", "models/props_junk/PopCan01a.mdl", "models/maxofs2d/camera.mdl", "models/swamponions/faucet.mdl", "models/chev/cumjar.mdl", "models/props_phx/misc/potato.mdl", "models/mechanics/various/211.mdl", "models/props_junk/garbage_metalcan001a.mdl", "models/props_c17/TrapPropeller_Lever.mdl", "models/Gibs/HGIBS_spine.mdl", "models/staticprop/props_lab/box01a.mdl", "models/Items/grenadeAmmo.mdl", "models/staticprop/props_junk/garbage_coffeemug001a.mdl", "models/props_c17/TrapPropeller_Lever.mdl", "models/props_junk/PopCan01a.mdl", "models/hunter/plates/plate.mdl", "models/props_junk/PopCan01a.mdl", "models/props_lab/reciever01d.mdl", "models/staticprop/props_junk/garbage_takeoutcarton001a.mdl", "models/props_phx2/garbage_metalcan001a.mdl", "models/swamponions/kleinytiner.mdl", "models/dav0r/buttons/button.mdl", "models/swamponions/kleiner_glasses.mdl", "models/staticprop/props_lab/box01a.mdl", "models/chev/cumjar.mdl", "models/props_wasteland/panel_leverHandle001a.mdl", "models/dav0r/buttons/switch.mdl", "models/food/hotdog.mdl", "models/staticprop/props_junk/garbage_coffeemug001a.mdl", "models/props_combine/combinecamera001.mdl", "models/props_lab/huladoll.mdl", "models/props_junk/PopCan01a.mdl", "models/food/hotdog.mdl", "models/props_wasteland/panel_leverHandle001a.mdl", "models/props_phx/misc/potato.mdl", "models/props_junk/PopCan01a.mdl", "models/chev/cumjar.mdl", "models/dav0r/thruster.mdl", "models/food/hotdog.mdl", "models/props_phx/misc/egg.mdl", "models/props_lab/reciever01d.mdl", "models/dav0r/buttons/switch.mdl", "models/swamponions/kleiner_glasses.mdl", "models/props_junk/garbage_takeoutcarton001a.mdl", "models/staticprop/props_lab/box01a.mdl", "models/props_lab/box01a.mdl", "models/props_c17/TrapPropeller_Lever.mdl"}
-- has playermodels/ragdolls in it
local previews = {"models/maxofs2d/balloon_classic.mdl", "models/hunter/triangles/075x075mirrored.mdl", "models/props_debris/rebar001c_64.mdl", "models/gibs/manhack_gib03.mdl", "models/props_c17/handrail04_brokencorner.mdl", "models/props_debris/rebar004b_48.mdl", "models/mechanics/wheels/wheel_rugged_48.mdl", "models/props_pipes/pipe03_lcurve02_short.mdl", "models/props_debris/concrete_spawnchunk001f.mdl", "models/props_c17/metalladder002b.mdl", "models/props_borealis/bluebarrel002.mdl", "models/props_debris/metal_panelshard01a.mdl", "models/gibs/manhack_gib02.mdl", "models/props_phx/cannonball_solid.mdl", "models/hunter/misc/platehole1x1d.mdl", "models/props_combine/breenbust_chunk03.mdl", "models/xqm/propeller1.mdl", "models/mechanics/wheels/wheel_rugged_24w.mdl", "models/props_combine/tprotato2_chunk01.mdl", "models/shadertest/vertexlitbasealphamaskenvmaptexdetv2.mdl", "models/props_wasteland/barricade002a.mdl", "models/shadertest/vertexlitmaskedenvmap.mdl", "models/props_c17/light_cagelight02_on.mdl", "models/props_c17/canisterchunk02b.mdl", "models/props_junk/garbage_glassbottle003a_chunk02.mdl", "models/props_debris/tile_wall001a_chunk01.mdl", "models/props_borealis/mooring_cleat01.mdl", "models/hunter/blocks/cube025x05x025.mdl", "models/xqm/cylinderx1.mdl", "models/props_pipes/valvewheel002a.mdl", "models/props_phx/construct/metal_plate1_tri.mdl", "models/mechanics/robotics/i1.mdl", "models/props_debris/wood_chunk02f.mdl", "models/props_c17/light_cagelight01_on.mdl", "models/props_junk/watermelon01_chunk02b.mdl", "models/lamps/torch.mdl", "models/props_junk/garbage_glassbottle001a_chunk02.mdl", "models/props_phx/oildrum001_explosive.mdl", "models/mechanics/solid_steel/type_f_6_6.mdl", "models/xqm/rails/turn_45.mdl", "models/props_c17/furnituretable002a.mdl", "models/props_phx/wheels/drugster_front.mdl", "models/gibs/antlion_gib_medium_2.mdl", "models/props_c17/canisterchunk02c.mdl", "models/items/battery.mdl", "models/weapons/w_rif_m4a1_silencer.mdl", "models/weapons/w_rif_sg552.mdl", "models/props_wasteland/light_spotlight02_lamp.mdl", "models/props_phx/misc/potato_launcher_cap.mdl", "models/props_wasteland/prison_throwswitchlever001.mdl"}

-- local previews = {"models/props_rooftop/sign_letter_f001b.mdl", "models/props_trainstation/tracksign10.mdl", "models/xqm/polex2.mdl", "models/editor/cone_helper.mdl", "models/props_debris/metal_panelshard01e.mdl", "models/props_phx/misc/gibs/egg_piece4.mdl", "models/hunter/blocks/cube025x075x025.mdl", "models/weapons/w_c4_planted.mdl", "models/props_debris/concrete_spawnchunk001g.mdl", "models/props_junk/watermelon01_chunk01c.mdl", "models/props_c17/canisterchunk02m.mdl", "models/props_rooftop/roof_dish001.mdl", "models/props_junk/glassbottle01a_chunk01a.mdl", "models/gibs/furniture_gibs/furniture_chair01a_gib05.mdl", "models/perftest/grass_tuft_004a.mdl", "models/editor/overlay_helper.mdl", "models/dav0r/camera.mdl", "models/props_wasteland/gear01.mdl", "models/props_pipes/pipe03_90degree01.mdl", "models/props_wasteland/light_spotlight02_base.mdl", "models/balloons/balloon_dog.mdl", "models/props_c17/canisterchunk02g.mdl", "models/props_junk/cinderblock01a.mdl", "models/props_combine/headcrabcannister01a_skybox.mdl", "models/props_debris/concrete_spawnchunk001i.mdl", "models/props_wasteland/prison_cagedlight001a.mdl", "models/props_debris/rebar002b_48.mdl", "models/props_foliage/tree_springers_card_01_skybox.mdl", "models/props_c17/light_cagelight02_off.mdl", "models/props_junk/watermelon01_chunk02b.mdl", "models/weapons/w_missile_launch.mdl", "models/props_rooftop/roof_vent002.mdl", "models/shadertest/envballs.mdl", "models/props_lab/monitor01a.mdl", "models/props_c17/chair_stool01a.mdl", "models/props_lab/ladel.mdl", "models/props_phx/normal_tire.mdl", "models/props_combine/combine_smallmonitor001.mdl", "models/props_debris/concrete_chunk04a.mdl", "models/weapons/w_defuser.mdl", "models/props_c17/light_cagelight01_off.mdl", "models/xqm/polex1.mdl", "models/gibs/furniture_gibs/furnituredrawer002a_gib03.mdl", "models/props_c17/gaspipes003a.mdl", "models/combine_room/combine_wire002.mdl", "models/props_lab/powerbox02c.mdl", "models/props_wasteland/woodwall030b_window02a.mdl", "models/gibs/furniture_gibs/furnituredrawer002a_gib05.mdl", "models/maxofs2d/companion_doll.mdl", "models/weapons/w_snip_sg550.mdl", "models/editor/air_node_hint.mdl", "models/props_wasteland/prison_pipefaucet001a.mdl", "models/mechanics/wheels/wheel_smooth_24f.mdl", "models/props_lab/powerbox03a.mdl", "models/gibs/furniture_gibs/furniture_chair01a_gib03.mdl", "models/items/combine_rifle_cartridge01.mdl", "models/props_debris/wood_chunk04a.mdl", "models/props_lab/reciever01b.mdl", "models/props_lab/pipesystem02e.mdl", "models/props_c17/canisterchunk02e.mdl", "models/hunter/misc/sphere025x025.mdl", "models/items/boxbuckshot.mdl", "models/props_debris/concrete_chunk08a.mdl", "models/healthvial.mdl", "models/props_junk/vent001_chunk2.mdl", "models/editor/scriptedsequence.mdl", "models/xqm/rhombus1.mdl", "models/vehicles/inner_pod_rotator.mdl", "models/props_phx/games/chess/black_knight.mdl", "models/props_c17/canisterchunk01l.mdl", "models/editor/overlay_helper.mdl", "models/props_debris/wood_chunk04c.mdl", "models/perftest/grass_tuft_001b.mdl", "models/props_c17/light_domelight01_off.mdl", "models/mechanics/wheels/wheel_smooth_24.mdl", "models/props_debris/wood_chunk06c.mdl", "models/gibs/shield_scanner_gib6.mdl", "models/maxofs2d/balloon_gman.mdl", "models/xqm/quad1.mdl", "models/props_debris/rebar002a_32.mdl"}
-- "models/props_wasteland/prison_padlock001b.mdl","models/props_junk/shoe001a.mdl","models/props_pipes/pipe01_90degree01.mdl","models/gibs/wood_gib01e.mdl","models/props_wasteland/prison_toiletchunk01d.mdl","models/gibs/hgibs_scapula.mdl","models/weapons/w_eq_fraggrenade.mdl","models/items/boxbuckshot.mdl","models/shells/shell_9mm.mdl","models/props_wasteland/prison_toiletchunk01f.mdl","models/props_phx/misc/egg.mdl","models/vehicles/inner_pod_rotator.mdl","models/gibs/glass_shard05.mdl","models/props_junk/garbage_metalcan002a.mdl","models/props_wasteland/prison_toiletchunk01g.mdl","models/shells/shell_556.mdl","models/weapons/w_npcnade.mdl","models/props_junk/garbage_glassbottle003a_chunk03.mdl","models/props_citizen_tech/firetrap_button01a.mdl","models/props_junk/watermelon01_chunk02b.mdl","models/props_wasteland/prison_padlock001a.mdl","models/weapons/w_knife_t.mdl","models/props_pipes/valvewheel002.mdl","models/items/battery.mdl","models/props_wasteland/prison_padlock001b.mdl","models/props_junk/garbage_milkcarton002a.mdl","models/gibs/manhack_gib01.mdl","models/props_c17/light_cagelight02_on.mdl","models/props_lab/bindergraylabel01a.mdl","models/items/357ammobox.mdl","models/props_c17/furnituredrawer001a_shard01.mdl","models/props_trainstation/payphone_reciever001a.mdl","models/props_c17/canisterchunk01d.mdl","models/props_c17/light_cagelight02_off.mdl","models/weapons/w_eq_fraggrenade.mdl","models/props_lab/jar01b.mdl","models/props_c17/canisterchunk01l.mdl","models/props_c17/canisterchunk01c.mdl","models/items/combine_rifle_cartridge01.mdl","models/maxofs2d/light_tubular.mdl","models/props_junk/terracotta_chunk01f.mdl","models/props_c17/canisterchunk02j.mdl","models/props_junk/watermelon01_chunk02a.mdl","models/squad/sf_tris/sf_tri1x1.mdl","models/gibs/hgibs_scapula.mdl","models/props_citizen_tech/firetrap_button01a.mdl","models/props_c17/canisterchunk01a.mdl","models/items/flare.mdl","models/gibs/furniture_gibs/furnituretable001a_chunk04.mdl","models/weapons/w_smg_mac10.mdl"
-- "models/props_combine/pipes01_single02c.mdl","models/props_combine/combine_bunker01.mdl","models/props_combine/tprotato2_chunk03.mdl","models/props_combine/combine_barricade_short02a.mdl","models/props_combine/combine_citadel001.mdl","models/props_combine/breenbust_chunk02.mdl","models/props_combine/portalskydome.mdl","models/props_combine/masterinterface.mdl","models/props_combine/combine_generator01.mdl","models/props_combine/combine_intmonitor003.mdl","models/props_combine/breenbust_chunk02.mdl","models/props_combine/combine_barricade_short03a.mdl","models/props_combine/pipes03_single03c.mdl","models/props_combine/combine_tptrack.mdl","models/props_combine/combine_citadel001b.mdl","models/props_combine/combine_barricade_tall03a.mdl","models/props_combine/combine_lock01.mdl","models/props_combine/pipes01_cluster02b.mdl","models/props_combine/railing_corner_outside.mdl","models/props_combine/railing_corner_inside.mdl","models/props_combine/combine_interface003.mdl","models/items/combine_rifle_ammo01.mdl","models/combine_room/combine_monitor003a.mdl","models/props_combine/combine_bunker_shield01b.mdl","models/props_combine/combine_barricade_short02a.mdl","models/props_combine/cell_array_02.mdl","models/props_combine/combine_barricade_bracket01b.mdl","models/props_combine/combine_window001.mdl","models/props_combine/combine_barricade_med01b.mdl","models/props_combine/pipes01_single01a.mdl","models/props_combine/pipes01_cluster02c.mdl","models/props_combine/weaponstripper.mdl","models/props_combine/cell_array_01_extended.mdl","models/props_combine/pipes03_single01a.mdl","models/props_combine/combine_booth_short01a.mdl","models/props_combine/combine_light001a.mdl","models/props_combine/prison01.mdl","models/props_combine/tprotato2_chunk05.mdl","models/props_combine/combine_interface001.mdl","models/combine_room/combine_wire002.mdl","models/props_combine/combine_barricade_short02a.mdl","models/props_combine/combine_emitter01.mdl","models/props_combine/combineinnerwallcluster1024_001a.mdl","models/props_combine/combine_barricade_med02b.mdl","models/props_combine/combine_mortar01b.mdl","models/props_combine/pipes02_single01b.mdl","models/props_combine/eli_pod_inner.mdl","models/props_combine/tprotato2_chunk03.mdl","models/props_combine/combine_binocular01.mdl","models/items/combine_rifle_cartridge01.mdl"
--  "models/hunter/blocks/cube075x3x1.mdl","models/mechanics/robotics/k4.mdl","models/props_debris/concrete_column001a_core.mdl","models/props_buildings/watertower_001a.mdl","models/hunter/blocks/cube075x3x025.mdl","models/props_phx/construct/glass/glass_curve90x1.mdl","models/xqm/coastertrack/turn_slope_90_4.mdl","models/combine_apc_destroyed_gib01.mdl","models/xqm/coastertrack/turn_45_1.mdl","models/hunter/misc/sphere175x175.mdl","models/xqm/jetwing2huge.mdl","models/hunter/misc/sphere2x2.mdl","models/mechanics/robotics/i1.mdl","models/mechanics/solid_steel/i_beam_4.mdl","models/props_vehicles/tire001c_car.mdl","models/props_combine/combine_interface003.mdl","models/props_debris/rebar003c_64.mdl","models/props_debris/wood_splinters01b.mdl","models/props_junk/garbage256_composite001a.mdl","models/maxofs2d/balloon_classic.mdl","models/props_debris/concrete_chunk08a.mdl","models/hunter/blocks/cube1x8x1.mdl","models/props_c17/clock01.mdl","models/hunter/plates/plate16x24.mdl","models/props_rooftop/sign_letter02_k002.mdl","models/xqm/coastertrack/turn_90_tight_2.mdl","models/xqm/rails/turn_30.mdl","models/props_wasteland/bridge_side01-other.mdl","models/props_phx/construct/metal_angle180.mdl","models/props_combine/combine_light001b.mdl","models/hunter/tubes/tube1x1x8d.mdl","models/hunter/tubes/circle2x2b.mdl","models/props_phx/misc/smallcannonclip.mdl","models/hunter/plates/tri1x1.mdl","models/props_combine/pipes01_single01a.mdl","models/hunter/triangles/1x1x2carved025.mdl","models/props_buildings/collapsedbuilding02c.mdl","models/gibs/gunship_gibs_midsection.mdl","models/props_wasteland/prison_sprinkler001b.mdl","models/shadertest/vertexlitmaskedenvmappedtexdetv2.mdl","models/props_trainstation/mount_connection001a.mdl","models/xqm/modernchair.mdl","models/props_combine/railing_corner_outside.mdl","models/props_vehicles/car004a.mdl","models/mechanics/roboticslarge/i4.mdl","models/xeon133/slider/slider_12x12x12.mdl","models/xeon133/offroad/off-road-60.mdl","models/xqm/jettailpiece1large.mdl","models/hunter/plates/plate05x32.mdl","models/props_buildings/row_corner_1_fullscale.mdl"
--  "models/gibs/strider_gib5.mdl","models/props_debris/concrete_spawnchunk001b.mdl","models/props_c17/grinderclamp01a.mdl","models/props_combine/combine_smallmonitor001.mdl","models/props_pipes/valvewheel002a.mdl","models/props_pipes/valvewheel002a.mdl","models/props_rooftop/roof_vent002.mdl","models/maxofs2d/balloon_classic.mdl","models/props_interiors/lightsconce01.mdl","models/props_lab/harddrive02.mdl","models/gibs/manhack_gib03.mdl","models/props_junk/garbage_glassbottle001a_chunk04.mdl","models/props_combine/breenbust_chunk05.mdl","models/props_pipes/valve003.mdl","models/props_foliage/tree_deciduous_card_01_skybox.mdl","models/items/item_item_crate_chunk08.mdl","models/props_debris/wood_chunk08e.mdl","models/props_wasteland/light_spotlight02_base.mdl","models/editor/cone_helper.mdl","models/props_debris/tile_wall001a_chunk09.mdl","models/props_trainstation/traintrack006c.mdl","models/effects/vol_light.mdl","models/items/boxflares.mdl","models/props_phx/games/chess/white_knight.mdl","models/props_junk/propane_tank001a.mdl","models/props_combine/headcrabcannister01a_skybox.mdl","models/props_phx/games/chess/white_queen.mdl","models/tools/camera/camera.mdl","models/props_junk/garbage_plasticbottle002a.mdl","models/mechanics/robotics/b1.mdl","models/props_lab/pipesystem01b.mdl","models/props_wasteland/cafeteria_bench001a_chunk05.mdl","models/gibs/scanner_gib02.mdl","models/props_combine/combine_citadel001b.mdl","models/props_interiors/furniture_chair03a.mdl","models/props_wasteland/cafeteria_table001a_chunk07.mdl","models/props_wasteland/light_spotlight02_lamp.mdl","models/props_pipes/pipe02_straight01_short.mdl","models/xqm/afterburner1.mdl","models/props_building_details/building_tem002_window01_bars.mdl","models/props_phx/gears/spur12.mdl","models/props_junk/trafficcone001a.mdl","models/props_phx/misc/potato.mdl","models/mechanics/solid_steel/type_a_2_2.mdl","models/props_combine/breenbust_chunk07.mdl","models/gibs/shield_scanner_gib1.mdl","models/props_debris/rebar002a_32.mdl","models/editor/ground_node_hint.mdl","models/props_wasteland/prison_padlock001b.mdl","models/props_debris/metal_panelshard01b.mdl"
-- models/chefhat.mdl
SS_Product({
    class = 'hatbox',
    price = 100000,
    name = 'Random Accessory',
    description = "A random prop that you can WEAR. No ratings - all props fully customizable.",
    GetModel = function(self) return previews[(math.floor(SysTime() * 2.5) % #previews) + 1] end,
    CannotBuy = function(self, ply) end,
    -- if ply:SS_CountItem("prop") >= 200 then return "Max 200 props, please sell some!" end
    OnBuy = function(self, ply)
        -- if ply.CANTSANDBOX then return end
        local item = SS_GenerateItem(ply, "accessory")

        ply:SS_GiveNewItem(item, function(item)
            local others = {}

            for i = 1, 15 do
                table.insert(others, SelectAccessoryModel()) --GetSandboxProp(accessoryradius))
            end

            net.Start("LootBoxAnimation")
            net.WriteUInt(item.id, 32)
            net.WriteTable(others)
            net.Send(ply)
        end, 4)
    end
})



function SS_AccessoryProduct(data)

    SS_AccessoryModels[data.model] = {
        name=data.name,
        description=data.description,
        value = math.floor( (data.price or data.value)*0.8 ),
        scaleoffset=data.maxscale/2,
        wear=data.wear
    }

    function data:SanitizeSpecs()
        self.specs = {model=self.model}
        self.class="accessory"
        return true
    end

    data.defaultspecs = {model=data.model}
    data.itemclass = "accessory"

    SS_ItemProduct(data)
end



SS_AccessoryProduct({
    class = 'trumphatfree',
    price = 0,
    name = 'Unstumpable',
    description = "Bold, vibrant, and exuberates power, much like Trump himself. Does not show blood.",
    model = 'models/swamponions/colorabletrumphat.mdl',
    color = Vector(1.0, 0.1, 0.1),
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 0.76,
        translate = Vector(-1.5, 0, 2.8),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), -90)
            ang:RotateAroundAxis(ang:Forward(), -20)
            ang:RotateAroundAxis(ang:Right(), 5)
        end),
        pony = {
            scale = 1.0,
            translate = Vector(-4, 0, 13),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), -90)
                ang:RotateAroundAxis(ang:Forward(), -20)
                ang:RotateAroundAxis(ang:Right(), 5)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "clownshoe",
    price = 50000,
    name = 'Clown Shoe',
    description = "Goofy clown shoe! Yes, just the one.",
    model = 'models/rockyscroll/clownshoes.mdl',
    color = Vector(0.8, 0.1, 0.1),
    maxscale = 1.4,
    wear = {
        attach = "right_foot",
        scale = 1,
        translate = Vector(4, -1, 0),
        rotate = Angle(0, -30, 90),
        pony = {
            attach = "right_hand",
            scale = 1,
            translate = Vector(-1, 3, 0),
            rotate = Angle(0, 90, -90),
        }
    }
})

SS_AccessoryProduct({
    class = "bigburger",
    price = 100000,
    name = 'Burger',
    description = "Staple food of the American diet.",
    model = 'models/swamponions/bigburger.mdl',
    maxscale = 1,
    wear = {
        attach = "left_hand",
        scale = 0.25,
        translate = Vector(5, -3.5, 0),
        rotate = Angle(0, -40, -90),
        pony = {
            attach = "lower_body",
            scale = 0.3,
            translate = Vector(-3, -5, 0),
            rotate = Angle(0, 0, 90),
        }
    }
})

SS_AccessoryProduct({
    class = "bicyclehelmet",
    price = 120000,
    name = 'Safety Helmet',
    description = "Protection from all threats: internal, external, or autismal.",
    model = 'models/swamponions/bicycle_helmet.mdl',
    color = Vector(0.2, 0.3, 1.0),
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3.5, 0, 2),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 1.75,
            translate = Vector(-9, 0, 9),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "buckethat",
    price = 10000,
    name = 'Bucket Head',
    description = "Did you get this out of the trash?",
    model = 'models/props_junk/MetalBucket01a.mdl',
    maxscale = 1.2,
    wear = {
        attach = "eyes",
        scale = 0.5,
        translate = Vector(-3.3, -1, 6),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Right(), 180)
            ang:RotateAroundAxis(ang:Up(), 195)
            ang:RotateAroundAxis(ang:Forward(), 10)
        end),
        pony = {
            scale = 0.9,
            translate = Vector(-11.1, -3.5, 15.5),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Right(), 190)
                ang:RotateAroundAxis(ang:Up(), 195)
                ang:RotateAroundAxis(ang:Forward(), 14)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "combinehelmet",
    price = 150000,
    name = 'Combine Helmet',
    description = "Hide your identity while upholding the law.",
    model = 'models/nova/w_headgear.mdl',
    color = Vector(1, 1, 1),
    maxscale = 2.7,
    wear = {
        attach = "head",
        scale = 1,
        translate = Vector(0, 0, 0),
        rotate = Angle(0, 0, 0),
        pony = {
            attach = "head",
            scale = 2,
            translate = Vector(0, 0, 0),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "conehattest",
    price = 1000,
    name = 'Cone Head',
    description = "You put a traffic cone on your head. Very funny.",
    model = 'models/props_junk/TrafficCone001a.mdl',
    maxscale = 1.0,
    wear = {
        attach = "eyes",
        scale = 0.7,
        translate = Vector(-7, 0, 11),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Right(), 20)
        end),
        pony = {
            scale = 0.7,
            translate = Vector(-7, 0, 22),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Right(), 20)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "kleinerglasses",
    price = 1000000,
    name = "Kleiner's Glasses",
    description = "Sublime and sophisticated. A must-have piece of Garry's Mod fashion.",
    model = 'models/swamponions/kleiner_glasses.mdl',
    maxscale = 3.0,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-1.5, 0, -0.5),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 2.3,
            translate = Vector(-5.5, 0, 2.5),
            rotate = Angle(0, 0, 0),
            nose = true,
        }
    }
})

SS_AccessoryProduct({
    class = "santahat",
    price = 25000,
    name = 'Christmas Hat',
    --description = "",
    model = 'models/cloud/kn_santahat.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3.8, 0, -3),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), -90)
            ang:RotateAroundAxis(ang:Forward(), 90)
            ang:RotateAroundAxis(ang:Right(), 15)
        end),
        pony = {
            scale = 1.5,
            translate = Vector(-8, 0, 2),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), -90)
                ang:RotateAroundAxis(ang:Forward(), 90)
                ang:RotateAroundAxis(ang:Right(), 15)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "shrunkenhead",
    price = 150000,
    name = 'Conjoined Twin',
    --description = "",
    model = 'models/Gibs/HGIBS.mdl',
    maxscale = 2.2,
    wear = {
        attach = "eyes",
        scale = 0.6,
        translate = Vector(-3, -4, 0),
        rotate = Angle(0, 0, -20),
        pony = {
            scale = 1,
            translate = Vector(-8, -7, 0),
            rotate = Angle(0, 0, -20),
        }
    }
})

SS_AccessoryProduct({
    class = "spikecollar",
    price = 200000,
    name = 'Spike Collar',
    --description = "",
    model = 'models/oldbill/spike_collar.mdl',
    maxscale = 3.0,
    wear = {
        attach = "neck",
        scale = 1.05,
        translate = Vector(2.5, -2.1, 0),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), 52)
            ang:RotateAroundAxis(ang:Forward(), 90)
        end),
        pony = {
            scale = 1.56,
            translate = Vector(0, -1.25, 0),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), 52)
                ang:RotateAroundAxis(ang:Forward(), 90)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "tinfoilhat",
    price = 40000,
    name = "InfoWarrior's Hat",
    description = "Block out the globalist's mind control gay-rays with this fashionable foil headgear.",
    model = 'models/dav0r/thruster.mdl',
    material = 'models/swamponions/tinfoil',
    maxscale = 2.2,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-5, 0, 4.8),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Forward(), 180)
            ang:RotateAroundAxis(ang:Right(), -30)
        end),
        pony = {
            scale = 1.75,
            translate = Vector(-11, 0, 14),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Forward(), 180)
                ang:RotateAroundAxis(ang:Right(), -25)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "trashhattest",
    price = 10000000,
    name = 'Party Hat',
    description = "It's just a paper hat.",
    model = 'models/noz/partyhat3d.mdl',
    color = Vector(0, 0.06, 0.94),
    maxscale = 3.0,
    wear = {
        attach = "eyes",
        scale = 1.1,
        translate = Vector(-3.3, -0.3, 2.5),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), -60)
            ang:RotateAroundAxis(ang:Forward(), 15)
        end),
        pony = {
            scale = 1.6,
            translate = Vector(-6.3, -0.2, 10),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), 40)
                ang:RotateAroundAxis(ang:Forward(), 10)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "turtleplush",
    price = 1000,
    name = 'Turtle Plush',
    --	description = "It's just a paper hat.",
    model = 'models/props/de_tides/Vending_turtle.mdl',
    material = 'plushturtlehat',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3.2, 0, 2),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), -90)
        end),
        pony = {
            scale = 1,
            translate = Vector(-5, 0, 9),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), -90)
                ang:RotateAroundAxis(ang:Forward(), -10)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "pickelhaube",
    price = 250000,
    name = 'Pickelhaube',
    model = 'models/noz/pickelhaube.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1.05,
        translate = Vector(-3.5, .1, 2.3),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Right(), 17)
        end),
        pony = {
            attach = "head",
            scale = 1.8,
            translate = Vector(-4, -9, .3),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), -20)
                ang:RotateAroundAxis(ang:Forward(), 90)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "horsemask",
    price = 500,
    name = 'Poverty Pony',
    --	description = "It's just a paper hat.",
    model = 'models/horsie/horsiemask.mdl',
    maxscale = 1.85,
    wear = {
        attach = "eyes",
        scale = 1.0,
        translate = Vector(.6, 0, -1),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), 90)
        end),
        pony = {
            scale = 1.85,
            translate = Vector(-2, 0, 2),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), 90)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = 'sombrero',
    price = 30000,
    name = 'Sombrero',
    description = "Worn by criminals, rapists, and good people.",
    model = 'models/swamponions/swampcinema/sombrero.mdl',
    maxscale = 1.5,
    wear = {
        attach = "eyes",
        scale = 0.9,
        translate = Vector(-2.5, 0, 3),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 1.0,
            translate = Vector(-6.5, 0, 11.5),
            rotate = Angle(5, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = 'headcrabhat',
    price = 600000,
    name = 'Headcrab',
    description = "Llamar! Get down from there!",
    model = 'models/swamponions/swampcinema/headcrabhat.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 0.8,
        translate = Vector(-2, 0, 3),
        rotate = Angle(0, -90, 10),
        pony = {
            scale = 1.2,
            translate = Vector(-7.5, 0, 11.5),
            rotate = Angle(0, -90, 10),
        }
    }
})

SS_AccessoryProduct({
    class = 'catears',
    price = 1450,
    name = 'Cat Ears',
    description = "Become your favorite neko e-girl gamer!",
    model = 'models/milaco/catears/catears.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1.0,
        translate = Vector(-2.859, 0, -2.922),
        rotate = Angle(0, 90, 0),
        pony = {
            scale = 1.0,
            translate = Vector(-16, 0, -4),
            rotate = Angle(0, 90, 0),
        }
    }
})

SS_AccessoryProduct({
    class = 'uwumask',
    price = 50000,
    name = 'Mask',
    description = "No one cared who I was until I put on the mask.",
    model = 'models/milaco/owomask/owomask.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 0.4,
        translate = Vector(0, 0, -3.665),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 1.025,
            translate = Vector(-12, 0, -2),
            rotate = Angle(10, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = 'tophat',
    price = 300000,
    name = 'Top Hat',
    description = "Feel like a sir",
    model = 'models/quattro/tophat/tophat.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1.0,
        translate = Vector(-2, 0, 6),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 1.0,
            translate = Vector(-15.299, 0.008, 16.79),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = 'swampyhat',
    price = 25000,
    name = 'Krusty Hat',
    description = "Crubsty fcrab beemschugger fri",
    model = 'models/milaco/swampyhat/swampyhat.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1.0,
        translate = Vector(0, 0, 0),
        rotate = Angle(0, -90, 0),
        pony = {
            scale = 1.0,
            translate = Vector(0, 0, 0),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "commandercap",
    price = 1933000,
    name = 'Commander Hat',
    description = "Look like a real commander",
    model = 'models/ccap/ccap.mdl',
    color = Vector(0.5, 0, 0),
    maxscale = 1.25,
    wear = {
        attach = "eyes",
        scale = 0.39,
        translate = Vector(-2.2, -0, 4.),
        rotate = Angle(180, 90, 188),
        pony = {
            scale = 0.69,
            translate = Vector(-4.9, -0, 13),
            rotate = Angle(180, 90, 190),
        }
    }
})

SS_AccessoryProduct({
    class = "woolcap",
    price = 50000,
    name = 'Wool Cap with Brim',
    description = "Perfect accessory for concealing a receding hairline.",
    model = 'models/pyroteknik/hats/woolbrim.mdl',
    color = Vector(1, 1, 1),
    maxscale = 3.7,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3, 0, 0),
        rotate = Angle(-10, 0, 0),
        pony = {
            attach = "eyes",
            scale = 2,
            translate = Vector(-8, 0, 4),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "gasmask",
    price = 600000,
    name = 'Gas Mask',
    description = "Protect yourself from the ambient stink of your average movie theater.",
    model = 'models/pyroteknik/hats/gasmask.mdl',
    color = Vector(1, 1, 1),
    maxscale = 3.7,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-2, 0, -1),
        rotate = Angle(-10, 0, 0),
        pony = {
            attach = "eyes",
            scale = 2.2,
            translate = Vector(-7, 0, 2),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "ushanka",
    price = 275000,
    name = 'Ushanka',
    description = "Iconic hat from that video you saw of someone doing something dangerous in the arctic",
    model = 'models/pyroteknik/hats/ushanka.mdl',
    color = Vector(1, 1, 1),
    maxscale = 3.7,
    wear = {
        attach = "eyes",
        scale = 1.04,
        translate = Vector(-2.7, 0, 0),
        rotate = Angle(-10, 0, 0),
        pony = {
            attach = "eyes",
            scale = 2.2,
            translate = Vector(-8, 0, 5),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "americanhelmet",
    price = 19450,
    name = 'WWII American Army Helmet',
    description = "Perfect for re-enacting horrifying war scenarios. Smells faintly of the beach.",
    model = 'models/pyroteknik/hats/american.mdl',
    color = Vector(1, 1, 1),
    maxscale = 3.7,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3, 0, 0),
        rotate = Angle(-10, 0, 0),
        pony = {
            attach = "eyes",
            scale = 2,
            translate = Vector(-8, 0, 5),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "germanhelmet",
    price = 88000,
    name = 'WWII German Army Helmet',
    description = "Perfect for re-enacting horrifying war scenarios. Smells faintly of sausage",
    model = 'models/pyroteknik/hats/german.mdl',
    color = Vector(1, 1, 1),
    maxscale = 3.7,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3, 0, 0),
        rotate = Angle(-10, 0, 0),
        pony = {
            attach = "eyes",
            scale = 2,
            translate = Vector(-10, 0, 5),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "bone",
    price = 9000,
    name = 'Bone',
    description = "A staple of modern fashion. The perfect accessory.",
    model = 'models/pyroteknik/hats/femur.mdl',
    color = Vector(1, 1, 1),
    maxscale = 2.7,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3, 0, 0),
        rotate = Angle(0, 90, 90),
        pony = {
            attach = "eyes",
            scale = 1.8,
            translate = Vector(-9, 0, 5),
            rotate = Angle(0, 90, 90),
        }
    }
})

SS_Heading("Primitives")

local primitives = {
    Plane = 10000,
    Tetrahedron = 10000,
    Angle = 15000,
    Cube = 20000,
    Icosahedron = 30000,
    Dome = 40000,
    Cone = 50000,
    Cylinder = 60000,
    Sphere = 80000,
    Torus = 100000
}

for k, v in pairs(primitives) do
    kl = k:lower()

    local itm = {
        class = 'primitive_' .. kl,
        price = v,
        name = k,
        description = "Select these primitives in your inventory and click 'customize' to build more interesting outfits!",
        model = 'models/swamponions/primitives/' .. kl .. '.mdl',
        maxscale = kl == "plane" and 3 or 2.5,
        wear = {
            attach = "eyes",
            scale = kl == "plane" and 1.5 or 2.0,
            translate = kl == "plane" and Vector(2, 0, 0) or Vector(0, 0, 0),
            rotate = kl == "plane" and Angle(90, 0, 0) or Angle(0, 0, 0),
            pony = {
                --copy of above
                scale = kl == "plane" and 1.5 or 2.0,
                translate = kl == "plane" and Vector(2, 0, 0) or Vector(0, 0, 0),
                rotate = kl == "plane" and Angle(90, 0, 0) or Angle(0, 0, 0),
            }
        }
    }

    if kl == "torus" then
        itm.settings = {
            wear = {
                xs = {
                    max = 10.0
                }
            }
        }
    end

    if kl == "cone" then
        itm.maxscale = 3.0
    end

    if kl == "plane" then
        itm.description = "Two per slot! Lots can be used."
        itm.perslot = 2
    end

    SS_AccessoryProduct(itm)
end
