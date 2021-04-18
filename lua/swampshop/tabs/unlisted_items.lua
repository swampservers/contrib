-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SS_BaseItem({
    class = "outfitter",
    price = 1000000,
    name = 'SELL-ONLY Outfitter',
    description = "asdfdf",
    model = 'models/player/pyroteknik/banana.mdl',
    invcategory = "Playermodels",
    never_equip = true
})

SS_BaseItem({
    class = "whiteeyestest",
    name = "white eyes",
    description = "does nothing. sell me.",
    price = 2000000,
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