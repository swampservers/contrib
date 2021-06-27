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

SS_Item({
    class = "whiteeyestest",
    name = "white eyes",
    description = "does nothing. sell me.",
    value = 2000000,
    model = "models/error.mdl",
    material = "models/debug/debugwhite",
})
-- SS_BaseItem({
--     class = "unknown",
--     price = 0,
--     name = 'Unknown item',
--     description = "dont mess with it",
--     model = 'models/error.mdl',
--     never_equip = true
-- })