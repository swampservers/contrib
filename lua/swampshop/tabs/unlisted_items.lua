-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SS_Item({
    class = "outfitter",
    value = 1000000,
    name = 'SELL-ONLY',
    description = "asdfdf",
    model = 'models/player/pyroteknik/banana.mdl',
    invcategory = "Playermodels",
    never_equip = true
})

SS_ClientsideFakeItem({
    class = "defaultplayermodel",
    value = 0,
    name = 'Default Playermodels',
    description = "Customization for the poor.",
    GetModel = function(self) return player_manager.TranslatePlayerModel(GetConVar("cl_playermodel"):GetString() or "kleiner") or "models/player/kleiner.mdl" end,
    actions = {
        revertcustomize = {
            Text = function()
                local any = false

                for i, v in ipairs(LocalPlayer().SS_Items) do
                    if v.PlayerSetModel and v.eq then
                        any = true
                    end
                end

                return any and "Revert to default model" or "Choose Playermodel"
            end,
            OnClient = function()
                local any = false

                for i, v in ipairs(LocalPlayer().SS_Items) do
                    if v.PlayerSetModel and v.eq then
                        v.actions.equip.OnClient(v)
                        any = true
                    end
                end

                if not any then
                    SS_ToggleMenu()
                    RunConsoleCommand("customize")
                end
            end
        }
    },
    invcategory = "Playermodels",
    never_equip = true
})

SS_Item({
    class = "whiteeyestest",
    name = "white eyes",
    description = "does nothing. sell me.",
    value = 2000000,
    model = "models/error.mdl",
    material = "models/debug/debugwhite",
})

SS_Item({
    class = "unknown",
    value = 0,
    GetName = function(self) return "Unknown " .. self.class end,
    GetDescription = function(self) return "Unknown item of class " .. self.class .. ". It might do something on another server. All you can do here is delete it." end,
    model = "models/error.mdl",
    invcategory = "Upgrades",
    never_equip = true 
})



-- SS_BaseItem({
--     class = "unknown",
--     price = 0,
--     name = 'Unknown item',
--     description = "dont mess with it",
--     model = 'models/error.mdl',
--     never_equip = true
-- })
