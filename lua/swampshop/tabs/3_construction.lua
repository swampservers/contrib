-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SS_Tab("Construction", "bricks")

-- SS_Heading("Tools")
local function CannotBuyTrash(self, ply)
    if SERVER then return CannotMakeTrash(ply) end
end

SS_WeaponProduct({
    class = "weapon_trash_tape",
    price = 0,
    name = 'Tape Tool',
    description = "Use this to tape (freeze) and un-tape props.",
    model = 'models/swamponions/ducktape.mdl'
})

SS_WeaponProduct({
    class = "weapon_trash_paint",
    name = 'Paint Tool',
    description = "Paint a solid color onto props. Also changes the color of lights.",
    model = 'models/props_junk/metal_paintcan001a.mdl',
    price = 2000
})

SS_WeaponProduct({
    class = "weapon_trash_manager",
    name = 'Manager',
    description = "Use to save and load your builds!",
    model = 'models/props_lab/clipboard.mdl',
    price = 5000
})

SS_Product({
    class = 'trash',
    price = 0,
    name = 'Random Trash',
    description = "Spawn a random piece of junk for building stuff with",
    model = 'models/props_junk/cardboard_box001b.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        makeTrash(ply, trashlist[math.random(1, #trashlist)])
    end
})

if SERVER then
    util.AddNetworkString("LootBoxAnimation")
end

SS_Item({
    class = "prop",
    background = true,
    value = 5000,
    name = "Prop",
    description = "Haha, where did you find this one?",
    model = 'models/maxofs2d/logo_gmod_b.mdl',
    SellValue = function(self) return 250 * 2 ^ SS_GetRating(self.specs.rating).id end,
    GetName = function(self) return string.sub(table.remove(string.Explode("/", self.specs.model)), 1, -5) end,
    GetModel = function(self) return self.specs.model end,
    OutlineColor = function(self) return SS_GetRating(self.specs.rating).color end,
    SanitizeSpecs = function(self)
        local specs, ch = self.specs, false

        if not specs.model then
            specs.model = GetSandboxProp()
            ch = true
        end

        if not specs.rating then
            specs.rating = math.random()
            ch = true
        end

        return ch
    end,
    actions = {
        spawnprop = {
            primary = true,
            Text = function(item) return "MAKE (-" .. tostring(item:SpawnPrice()) .. ")" end,
        }
    },
    GetSettings = function(self)
        return {
            color = (SS_GetRating(self.specs.rating or 0).id >= 5) and {
                max = 5
            } or false,
            imgur = SS_GetRating(self.specs.rating or 0).id >= 7
        }

    end,
    GetColor = function(self)
        if self:GetSettings().color then return self.cfg.color end
        local r = SS_GetRating(self.specs.rating).id
        if r == 2 then return Vector(0.7, 0.7, 0.7) end
        if r == 1 then return Vector(0.5, 0.3, 0.1) end
    end,
    settings = {
        color = {
            max = 5
        },
        imgur = true
    },
    SpawnPrice = function(self) return IsModelExplosive(self.specs.model) and 2000 or 200 end,
    invcategory = "Props",
    never_equip = true
})

-- props={} for i=1,50 do table.insert(props,GetSandboxProp()) end net.Start("RunLuaLong") net.WriteString("SetClipboardText([[ "..util.TableToJSON(props).." ]])") net.Send(ME())
local previews = {"models/props_c17/cashregister01a.mdl", "models/props_junk/garbage_plasticbottle001a.mdl", "models/maxofs2d/lamp_projector.mdl", "models/props_lab/kennel_physics.mdl", "models/maxofs2d/hover_rings.mdl", "models/props_lab/walllight001a.mdl", "models/Items/BoxBuckshot.mdl", "models/mechanics/solid_steel/i_beam_4.mdl", "models/props_c17/FurnitureChair001a.mdl", "models/maxofs2d/companion_doll.mdl", "models/props/de_tides/patio_chair2r.mdl", "models/props_wasteland/light_spotlight01_lamp.mdl", "models/staticprop/props_c17/furniturefridge001a.mdl", "models/props_junk/TrafficCone001a.mdl", "models/mechanics/roboticslarge/a1.mdl", "models/xqm/Rails/slope_down_15.mdl", "models/combine_room/combine_wire002.mdl", "models/staticprop/props_junk/wood_pallet001a.mdl", "models/props_c17/BriefCase001a.mdl", "models/props_doors/door03_slotted_left.mdl", "models/staticprop/props_c17/furnituretable003a.mdl", "models/props_trainstation/TrackSign08.mdl", "models/props_c17/fence01b.mdl", "models/xqm/hydcontrolbox.mdl", "models/props_phx/rt_screen.mdl", "models/props_phx/wheels/wooden_wheel1.mdl", "models/Gibs/Fast_Zombie_Torso.mdl", "models/xqm/box2s.mdl", "models/props_wasteland/light_spotlight01_base.mdl", "models/Gibs/HGIBS_rib.mdl", "models/props_mlpprops/canterlotdresser2.mdl", "models/mechanics/wheels/wheel_smooth2.mdl", "models/props_c17/FurnitureSink001a.mdl", "models/props_junk/TrashDumpster01a.mdl", "models/hunter/blocks/cube05x1x05.mdl", "models/props_trainstation/trainstation_ornament002.mdl", "models/hunter/blocks/cube05x105x05.mdl", "models/props_c17/FurnitureShelf001a.mdl", "models/props_c17/FurnitureChair001a.mdl", "models/props_c17/cashregister01a.mdl", "models/props_junk/meathook001a.mdl", "models/xqm/Rails/straight_1.mdl", "models/props_docks/channelmarker_gib01.mdl", "models/mechanics/robotics/b1.mdl", "models/maxofs2d/button_slider.mdl", "models/nova/jeep_seat.mdl", "models/props_combine/health_charger001.mdl", "models/props_trainstation/trashcan_indoor001a.mdl", "models/swamponions/bigburger.mdl", "models/Mechanics/gears2/gear_18t3.mdl", "models/props_c17/lampShade001a.mdl", "models/props_c17/gravestone002a.mdl", "models/hunter/tubes/tube2x2x025c.mdl", "models/props_interiors/Furniture_chair01a.mdl", "models/props_c17/furnitureboiler001a.mdl", "models/props_wasteland/panel_leverHandle001a.mdl", "models/xeon133/racewheel/race-wheel-35.mdl", "models/props_phx/games/chess/white_bishop.mdl", "models/props_phx/misc/potato_launcher_cap.mdl", "models/props_c17/FurnitureTable003a.mdl", "models/mechanics/robotics/f1.mdl", "models/xqm/jetenginemedium.mdl", "models/Items/BoxBuckshot.mdl", "models/staticprop/props_phx/ww2bomb2.mdl", "models/props_lab/tpplugholder_single.mdl", "models/staticprop/props_canal/boat001b_chunk01.mdl", "models/combine_room/combine_wire002.mdl", "models/props_junk/propane_tank001a.mdl", "models/props_junk/gascan001a.mdl", "models/props_combine/breendesk.mdl", "models/props_lab/tpplugholder.mdl", "models/xqm/panel2x2.mdl", "models/props_c17/pulleywheels_large01.mdl", "models/swamponions/theater_seats/seat2.mdl", "models/xeon133/slider/slider_12x12x24.mdl", "models/props_wasteland/kitchen_stove001a.mdl", "models/food/burger.mdl", "models/xqm/panel180.mdl", "models/mechanics/wheels/bmwl.mdl", "models/xqm/quad2.mdl", "models/props_trainstation/TrackSign01.mdl", "models/xqm/quad3.mdl", "models/props_wasteland/controlroom_filecabinet002a.mdl", "models/Gibs/wood_gib01c.mdl", "models/phxtended/tri2x1.mdl", "models/hunter/blocks/cube05x1x05.mdl", "models/props_lab/box01b.mdl", "models/alts/props/sportzone/locker/waterfd2.mdl", "models/maxofs2d/button_05.mdl", "models/props_phx/construct/metal_plate_curve.mdl", "models/staticprop/weapons/w_mp40.mdl", "models/props_lab/tpplugholder_single.mdl", "models/props_junk/metalgascan.mdl", "models/props_lab/powerbox01a.mdl", "models/mechanics/robotics/b2.mdl", "models/balloons/balloon_classicheart.mdl", "models/props_c17/metalladder002b.mdl", "models/props_interiors/Radiator01a.mdl", "models/props_lab/reciever01d.mdl", "models/Gibs/helicopter_brokenpiece_02.mdl"}

-- return SS_GetRating(self.specs.rating).id>=7 and 1000 or 100
SS_Product({
    class = 'sandbox',
    background = true,
    price = 25000,
    name = 'Prop Blueprint',
    description = "A random prop that you can spawn from your inventory anytime",
    GetModel = function(self) return previews[(math.floor(SysTime() * 2.5) % #previews) + 1] end,
    CannotBuy = function(self, ply) end,
    -- if ply:SS_CountItem("prop") >= 200 then return "Max 200 props, please sell some!" end
    OnBuy = function(self, ply)
        -- if ply.CANTSANDBOX then return end
        local item = SS_GenerateItem(ply, "prop")

        ply:SS_GiveNewItem(item, function(item)
            local others = {}

            for i = 1, 15 do
                table.insert(others, GetSandboxProp())
            end

            net.Start("LootBoxAnimation")
            net.WriteUInt(item.id, 32)
            net.WriteTable(others)
            net.Send(ply)

            timer.Simple(4, function()
                MakeTrashItem(ply, item)
            end)
        end, 4)
    end
})

SS_Panel(function(parent)
    vgui("DSSAuctionPreview", parent, function(p)
        p:SetCategory("Props")
    end)
end)



SS_Heading("Gadgets (WIP)")

SS_WeaponProduct({
    class = "weapon_trash_cable",
    price = 10000,
    name = 'Cable Tool',
    description = "Use this to wire props together!",
    model = 'models/props_c17/pulleywheels_small01.mdl'
})

SS_Product({
    class = 'trashlight',
    price = 1000,
    name = 'Lights',
    description = "Lights up while taped or powered",
    model = 'models/maxofs2d/light_tubular.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        local nxt = GetSpecialTrashModelsByClass("light")
        e = makeTrash(ply, nxt[math.random(1, #nxt)])
    end
})

SS_Product({
    class = 'trashbutton',
    price = 5000,
    name = 'Buttons',
    description = "The source of power",
    model = 'models/maxofs2d/button_01.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        local nxt = GetSpecialTrashModelsByClass("button")
        e = makeTrash(ply, nxt[math.random(1, #nxt)])
    end
})

SS_Product({
    class = 'trashdoor',
    price = 2000,
    name = 'Doors',
    description = "Can be opened",
    model = 'models/staticprop/props_c17/door01_left.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        local nxt = GetSpecialTrashModelsByClass("door")
        e = makeTrash(ply, nxt[math.random(1, #nxt)])
    end
})

SS_Product({
    class = 'trashinverter',
    price = 1000,
    name = 'Inverter',
    description = "What does this do?",
    model = 'models/maxofs2d/lamp_flashlight.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        e = makeTrash(ply, "models/maxofs2d/lamp_flashlight.mdl")
    end
})

SS_Heading("More Props")

SS_Product({
    class = 'plate1',
    price = 1000,
    name = 'Small Plate',
    description = "Easy but costs money",
    model = 'models/props_phx/construct/metal_plate1.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        makeTrash(ply, self.model)
    end
})

SS_Product({
    class = 'plate2',
    price = 2000,
    name = 'Medium Plate',
    description = "Easy but costs money",
    model = 'models/props_phx/construct/metal_plate1x2.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        makeTrash(ply, self.model)
    end
})

SS_Product({
    class = 'plate3',
    price = 5000,
    name = 'Big Plate',
    description = "Easy but costs money",
    model = 'models/props_phx/construct/metal_plate2x2.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        makeTrash(ply, self.model)
    end
})

SS_Product({
    class = 'plate4',
    price = 2000,
    name = 'Triangle',
    description = "Easy but costs money",
    model = 'models/props_phx/construct/metal_plate2x2_tri.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        makeTrash(ply, self.model)
    end
})

SS_Product({
    class = 'trashfield',
    price = 200,
    name = 'Medium Protection Field',
    description = "While taped, prevents other players from building in your space. Also makes blocks stronger in the mines.",
    model = 'models/maxofs2d/hover_classic.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_zone")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        -- timer.Simple(0, function()
        --     timer.Simple(0.001, function()
        MakeTrashZone(ply, self.model)
    end
})

--     end)
-- end)
SS_Product({
    class = 'trashfieldlarge',
    price = 3000,
    name = 'Large Protection Field',
    description = "While taped, prevents other players from building in your space. Also makes blocks stronger in the mines.",
    model = 'models/dav0r/hoverball.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_zone")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        -- timer.Simple(0, function()
        -- timer.Simple(0.001, function()
        MakeTrashZone(ply, self.model)
    end
})

-- end)
-- end)
SS_Product({
    class = 'trashseat',
    price = 2000,
    name = 'Chairs',
    description = "Can be sat on",
    model = 'models/props_c17/furniturechair001a.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        local nxt = {}

        for k, v in pairs(trashlist) do
            if ChairOffsets[v] then
                table.insert(nxt, v)
            end
        end

        e = makeTrash(ply, nxt[math.random(1, #nxt)])
    end
})

SS_Product({
    class = 'trashtheater',
    price = 8000,
    name = 'Medium Theater Screen',
    description = "Create your own private theater anywhere! You'll remain owner even if you walk away.",
    model = 'models/props_phx/rt_screen.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_zone")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        -- timer.Simple(0, function()
        --     timer.Simple(0.001, function()
        -- makeTrashTheater(ply, self.model)
        MakeTrashZone(ply, self.model)
    end
})

--     end)
-- end)
SS_Product({
    class = 'trashtheatertiny',
    price = 4000,
    name = "Tiny Theater Screen",
    description = "Create your own private theater anywhere! You'll remain owner even if you walk away.",
    model = "models/props_c17/tv_monitor01.mdl",
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_zone")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        -- timer.Simple(0, function()
        --     timer.Simple(0.001, function()
        --         makeTrashTheater(ply, self.model)
        --     end)
        -- end)
        MakeTrashZone(ply, self.model)
    end
})

SS_Product({
    class = 'trashtheaterbig',
    price = 16000,
    name = 'Large Theater Screen',
    description = "Create your own private theater anywhere! You'll remain owner even if you walk away.",
    model = "models/hunter/plates/plate1x2.mdl",
    material = "tools/toolsblack",
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_zone")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        -- timer.Simple(0, function()
        --     timer.Simple(0.001, function()
        --         makeTrashTheater(ply, self.model)
        --     end)
        -- end)
        MakeTrashZone(ply, self.model)
    end
})
-- TODO finish this, make env_projectedtexture when in the theater
-- SS_Product({
--     class = 'trashtheaterprojector',
--     price = 640,
--     name = 'Projector Theater',
--     description = "Create your own private theater anywhere! You'll remain owner even if you walk away.",
--     model = "models/dav0r/camera.mdl",
--     OnBuy = function(self, ply)
--         for k, v in pairs(ents.FindByClass("prop_trash_zone")) do
--             if v:GetOwnerID() == ply:SteamID() then
--                 v:Remove()
--             end
--         end
--         --Delay 1 tick
--         timer.Simple(0, function()
--             timer.Simple(0.001, function()
--                 if tryMakeTrash(ply) then
--                     makeTrashTheater(ply, self.model)
--                 else
--                     ply:SS_GivePoints(self.price)
--                 end
--             end)
--         end)
--     end
-- })
