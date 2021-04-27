-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
local Player = FindMetaTable('Player')
SS_Items = SS_Items or {}
-- this is not used as a table, it is just a unique value
SS_SAMPLE_ITEM_OWNER = SS_SAMPLE_ITEM_OWNER or {}

-- SS_ITEM_META = {
--     __index = function(t, k) return t[k] or t.cfg[k]  or t.class[k] end, --or t.spec[k]
--     __newindex = function(t, k, v) end
-- }
-- convert sql loaded data, or network data, to item
-- still needs to be sanitized on server, left out of here to deal with prop slots
function SS_MakeItem(ply, itemdata)
    local class = SS_Items[itemdata.class]

    if not class then
        print("Unknown item", itemdata.class)

        return
    end

    assert(IsValid(ply) or ply == SS_SAMPLE_ITEM_OWNER)
    itemdata.owner = ply
    setmetatable(itemdata, class)

    return itemdata
end

function SS_MakeItems(ply, itemdatas, skip_unknown)
    local out = {}

    for i, v in ipairs(itemdatas) do
        v = SS_MakeItem(ply, v)

        if v then
            table.insert(out, v)
        elseif not skip_unknown then
            error()
        end
    end

    return out
end

function SS_AngleGen(func)
    local ang = Angle()
    func(ang)

    return ang
end

function SS_PlayermodelItem(item)
    item.playermodel = true
    item.PlayerSetModelOrig = item.PlayerSetModel

    item.PlayerSetModel = function(self, ply)
        --if ply:GetModel()~=self.model then 
        ply:SetModel(self.model)

        --end
        if self.PlayerSetModelOrig then
            self:PlayerSetModelOrig(ply)
        end
    end

    --gets called just before this object changes state
    item.OnChangeEquip = function(self, ply, eq)
        if eq then
            for k, v in ipairs(ply.SS_ShownItems) do
                -- todo: change this to sanitizing all items, local item last?
                if SS_Items[v.class] and SS_Items[v.class].PlayerSetModel then
                    ply:SS_EquipItem(v, false)
                end
            end
        end
    end

    item.invcategory = "Playermodels"
    SS_Item(item)
end

--ITEMS are stuff that is saved in the database
function SS_Item(item)
    if item.wear then
        item.configurable = item.configurable or {}
        item.configurable.wear = item.configurable.wear or {}

        --Pass -1 for default?
        item.configurable.wear.scale = {
            min = Vector(0.05, 0.05, 0.05),
            max = (item.maxscale or 1) * Vector(1, 1, 1)
        }

        item.configurable.wear.pos = {
            min = Vector(-16, -16, -16),
            max = Vector(16, 16, 16)
        }

        item.configurable.color = {
            max = 5
        }

        item.configurable.imgur = true
        item.accessory_slot = true
        item.invcategory = "Accessories"
    end

    function item:Sanitize()
        _SS_SanitizeConfig(self)

        if self.owner ~= SS_SAMPLE_ITEM_OWNER and self:CannotEquip() then
            self.eq = false
        end
    end

    function item:CannotEquip()
        if self.never_equip then return "This item can't be equipped." end

        if self.accessory_slot then
            local c = self.eq and 0 or 1 / (self.perslot or 1)

            for k, v in pairs(self.owner.SS_Items) do
                if v.eq and (SS_Items[v.class] or {}).accessory_slot then
                    c = c + (1 / (SS_Items[v.class].perslot or 1))
                end
            end
            if c > self.owner:SS_AccessorySlots() then return "Buy more accessory slots (in Upgrades) to wear more items." end
        end

        if self.cfg.imgur then
            local urls = {
                [self.cfg.imgur.url] = true
            }

            for k, v in pairs(self.owner.SS_Items) do
                if v.eq and v.cfg.imgur then
                    urls[v.cfg.imgur.url] = true
                end
            end

            if table.Count(urls) > 4 then return "You can only equip 4 different imgur materials at once." end
        end
    end

    function item:ShouldShow()
        return self.eq
    end

    function item:SellValue()
        return math.floor(self.value * 0.8)
    end

    item.__index = item
    SS_Items[item.class] = item

    if item.price then
        item.value = item.price
        SS_ItemProduct(item)
    end

    assert(item.value and item.value >= 0, "Price or value is needed")
end

function _SS_SanitizeConfig(item)
    local cfg = item.cfg
    local itmc = item.configurable
    if not itmc then return end
    local dirty_cfg = {}

    for k, v in pairs(cfg) do
        dirty_cfg[k] = v
    end

    table.Empty(cfg)

    local function sanitize_vector(val, min, max)
        return isvector(val) and val:Clamp(min, max) or nil
    end

    if itmc.color then
        cfg.color = sanitize_vector(dirty_cfg.color, Vector(0, 0, 0), Vector(itmc.color.max, itmc.color.max, itmc.color.max))
    end

    if itmc.imgur then
        local url = istable(dirty_cfg.imgur) and SanitizeImgurId(dirty_cfg.imgur.url)

        cfg.imgur = url and {
            url = url
        } or nil
    end

    if itmc.wear then
        for _, wk in pairs({"wear_h", "wear_p"}) do
            local curr = istable(dirty_cfg[wk]) and dirty_cfg[wk] or {}

            local tab = {
                pos = sanitize_vector(curr.pos, itmc.wear.pos.min, itmc.wear.pos.max),
                scale = sanitize_vector(curr.scale, itmc.wear.scale.min, itmc.wear.scale.max),
                ang = isangle(curr.ang) and Angle(math.Clamp(curr.ang.x, -180, 180), math.Clamp(curr.ang.y, -180, 180), math.Clamp(curr.ang.z, -180, 180)) or nil,
                attach = isstring(curr.attach) and SS_Attachments[curr.attach] and curr.attach or nil,
            }

            cfg[wk] = table.Count(tab) > 0 and tab or nil
        end
    end

    if itmc.scale then
        cfg.scale_h = sanitize_vector(dirty_cfg.scale_h, itmc.scale.min, itmc.scale.max)
        cfg.scale_p = sanitize_vector(dirty_cfg.scale_p, itmc.scale.min, itmc.scale.max)
    end

    if itmc.pos then
        cfg.pos_h = sanitize_vector(dirty_cfg.pos_h, itmc.pos.min, itmc.pos.max)
        cfg.pos_p = sanitize_vector(dirty_cfg.pos_p, itmc.pos.min, itmc.pos.max)
    end

    if itmc.bone then
        cfg.bone_h = isstring(dirty_cfg.bone_h) and string.sub(dirty_cfg.bone_h, 1, 50) or nil
        cfg.bone_p = isstring(dirty_cfg.bone_p) and string.sub(dirty_cfg.bone_p, 1, 50) or nil
    end

    if itmc.scale_children then
        cfg.scale_children_h = dirty_cfg.scale_children_h and true or nil
        cfg.scale_children_p = dirty_cfg.scale_children_p and true or nil
    end
end