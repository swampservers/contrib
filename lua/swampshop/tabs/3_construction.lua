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
    CanCfgColor = function(self)
        return (SS_GetRating(self.specs.rating or 0).id >= 5) and {
            max = 5
        } or false
    end,
    CanCfgImgur = function(self) return SS_GetRating(self.specs.rating or 0).id >= 7 end,
    GetColor = function(self)
        if self:CanCfgColor() then return self.cfg.color end
        local r = SS_GetRating(self.specs.rating).id
        if r == 2 then return Vector(0.7, 0.7, 0.7) end
        if r == 1 then return Vector(0.5, 0.3, 0.1) end
    end,
    configurable = {
        color = {
            max = 5
        },
        imgur = true
    },
    SpawnPrice = function(self) return 100 end,
    invcategory = "Props",
    never_equip = true
})

SS_Product({
    class = 'sandbox',
    price = 25000,
    name = 'Sandbox Lootbox',
    description = "A random prop that you can spawn from your inventory as much as you want (trading coming soon)",
    model = 'models/Items/ammocrate_smg1.mdl',
    CannotBuy = function(self, ply)
        if ply:SS_CountItem("prop") >= 100 then return "Max 100 props, please sell some!" end
    end,
    OnBuy = function(self, ply)
        -- if ply.CANTSANDBOX then return end
        local item = SS_GenerateItem(ply, "prop")

        ply:SS_GiveNewItem(item, function(item)
            local chosen = item.specs.model
            assert(chosen)
            local others = {}

            for i = 1, 15 do
                table.insert(others, GetSandboxProp())
            end

            net.Start("LootBoxAnimation")
            net.WriteUInt(item.id, 32)
            net.WriteTable(others)
            net.Send(ply)

            timer.Simple(4, function()
                makeTrash(ply, chosen)
            end)
        end, 4)
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
        for k, v in pairs(ents.FindByClass("prop_trash_field")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        timer.Simple(0, function()
            timer.Simple(0.001, function()
                makeForcefield(ply, self.model)
            end)
        end)
    end
})

SS_Product({
    class = 'trashfieldlarge',
    price = 3000,
    name = 'Large Protection Field',
    description = "While taped, prevents other players from building in your space. Also makes blocks stronger in the mines.",
    model = 'models/dav0r/hoverball.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_field")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        timer.Simple(0, function()
            timer.Simple(0.001, function()
                makeForcefield(ply, self.model)
            end)
        end)
    end
})

SS_Product({
    class = 'trashlight',
    price = 1000,
    name = 'Lights',
    description = "Lights up while taped",
    model = 'models/maxofs2d/light_tubular.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        local nxt = {}

        for k, v in pairs(trashlist) do
            if PropTrashLightData[v] then
                table.insert(nxt, v)
            end
        end

        e = makeTrash(ply, nxt[math.random(1, #nxt)])
    end
})

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
        for k, v in pairs(ents.FindByClass("prop_trash_theater")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        timer.Simple(0, function()
            timer.Simple(0.001, function()
                makeTrashTheater(ply, self.model)
            end)
        end)
    end
})

SS_Product({
    class = 'trashtheatertiny',
    price = 4000,
    name = "Tiny Theater Screen",
    description = "Create your own private theater anywhere! You'll remain owner even if you walk away.",
    model = "models/props_c17/tv_monitor01.mdl",
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_theater")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        timer.Simple(0, function()
            timer.Simple(0.001, function()
                makeTrashTheater(ply, self.model)
            end)
        end)
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
        for k, v in pairs(ents.FindByClass("prop_trash_theater")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        timer.Simple(0, function()
            timer.Simple(0.001, function()
                makeTrashTheater(ply, self.model)
            end)
        end)
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
--         for k, v in pairs(ents.FindByClass("prop_trash_theater")) do
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