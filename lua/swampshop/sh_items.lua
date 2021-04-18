-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
local Player = FindMetaTable('Player')

SS_Items = SS_Items or {}


-- SS_ITEM_META = {
--     __index = function(t, k) return t[k] or t.cfg[k]  or t.class[k] end, --or t.spec[k]
--     __newindex = function(t, k, v) end
-- }

-- convert sql loaded data, or network data, to item
-- still needs to be sanitized on server, left out of here to deal with prop slots
function SS_MakeItem(ply, item)
    local class = SS_Items[item.class]
    if not class then print("Unknown item",item.class) return end
    item.owner = ply
    setmetatable(item, class)
    return item  
end

function SS_GenerateItem(ply, class)
    return SS_MakeItem(ply, {
        class=class,
        id=-1,
        cfg = {},
        eq=true,
    })
end


function SS_AngleGen(func) local ang = Angle() func(ang) return ang end

function SS_BaseItem(item)
    item.Sanitize = function(item) SS_ConfigurationSanitize(item, item.cfg) if item.owner:SS_CanEquipStatus(item.class, item.cfg) ~= SS_EQUIPSTATUS_OK then item.eq=false end end
    item.ShouldShow = function(item) return item.eq end
    item.__index = item
    SS_Items[item.class] = item
end

function SS_PlayermodelItemProduct(item)
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
                    ply:SS_EquipItem(v.id, false)
                end
            end
        end
    end

    item.invcategory = "Playermodels"
    SS_ItemProduct(item)
end


--ITEMS are stuff that is saved in the database
function SS_ItemProduct(item)
    if item.wear then
        local itmcw = (item.configurable or {}).wear or {}

        local xscale = itmcw.xs or {
            max = (item.maxscale or 1.0)
        }

        local yscale = itmcw.ys or {
            max = (item.maxscale or 1.0)
        }

        local zscale = itmcw.zs or {
            max = (item.maxscale or 1.0)
        }

        xscale.min = xscale.min or 0.05 --(xscale.max/20.0)
        yscale.min = yscale.min or 0.05 --(yscale.max/20.0)
        zscale.min = zscale.min or 0.05 --(zscale.max/20.0)

        item.configurable = {
            color = {
                max = 5.0
            },
            wear = {
                x = {
                    min = -16.0,
                    max = 16.0
                },
                y = {
                    min = -16.0,
                    max = 16.0
                },
                z = {
                    min = -16.0,
                    max = 16.0
                },
                xs = xscale,
                ys = yscale,
                zs = zscale
            },
            imgur = true
        }

        item.accessory_slot = true
        item.invcategory = "Accessories"
    end

    SS_BaseItem(item)
    product = item
    product.keepnotice = "This " .. ((item.price or 0) == 0 and "item" or "purchase") .. " is kept forever unless you " .. ((item.price or 0) == 0 and "return" or "sell") .. " it."

    function product:OnBuy(ply)
        ply:SS_GiveItem(self.class)
        net.Start("SS_PointOutInventory")
        net.Send(ply)
    end

    SS_Product(product)
end



SS_EQUIPSTATUS_OK = 0
SS_EQUIPSTATUS_WEARABLE = 1
SS_EQUIPSTATUS_IMGUR = 2
SS_EQUIPSTATUS_NEVER = 3

SS_EquipStatusMessage = {"Buy more accessory slots (in Upgrades) to wear more items.", "You can only equip 4 different imgur materials at once.", "This item can't be equipped."}

function Player:SS_CanEquipStatus(class, cfg, already_equipped)
    local item = SS_Items[class]
    if item.never_equip then return SS_EQUIPSTATUS_NEVER end

    if item.accessory_slot then
        local c = already_equipped and 0 or 1 / (item.perslot or 1)

        for k, v in pairs(self.SS_Items) do
            if v.eq and (SS_Items[v.class] or {}).accessory_slot then
                c = c + (1 / (SS_Items[v.class].perslot or 1))
            end
        end

        if c > self:SS_AccessorySlots() then return SS_EQUIPSTATUS_WEARABLE end
    end

    if cfg.imgur then
        local urls = {
            [cfg.imgur.url] = true
        }

        for k, v in pairs(self.SS_Items) do
            if v.eq and v.cfg.imgur then
                urls[v.cfg.imgur.url] = true
            end
        end

        if table.Count(urls) > 4 then return SS_EQUIPSTATUS_IMGUR end
    end

    return SS_EQUIPSTATUS_OK
end



function SS_ConfigurationSanitize(itm, cfg)
    if not itm then return end
    local itmc = itm.configurable
    if not itmc then return end
    local san = {}

    if itmc.color then
        if isvector(cfg.color) then
            san.color = Vector(math.Clamp(cfg.color.x, 0, itmc.color.max), math.Clamp(cfg.color.y, 0, itmc.color.max), math.Clamp(cfg.color.z, 0, itmc.color.max))
        end
    end

    if itmc.imgur then
        if istable(cfg.imgur) then
            local url = SanitizeImgurId(cfg.imgur.url)

            if url then
                san.imgur = {
                    url = url
                }
            end
        end
    end

    local function san_pos(pos1, bnd)
        local pos2 = nil

        if isvector(pos1) then
            pos2 = Vector(math.Clamp(pos1.x, bnd.x.min, bnd.x.max), math.Clamp(pos1.y, bnd.y.min, bnd.y.max), math.Clamp(pos1.z, bnd.z.min, bnd.z.max))
        end

        return pos2
    end

    local function san_scale(scl, bnd)
        local scale = nil

        if isnumber(scl) then
            scl = Vector(scl, scl, scl)
        end

        if isvector(scl) then
            scale = Vector(math.Clamp(scl.x, bnd.xs.min, bnd.xs.max), math.Clamp(scl.y, bnd.ys.min, bnd.ys.max), math.Clamp(scl.z, bnd.zs.min, bnd.zs.max))
        end

        return scale
    end

    if itmc.wear then
        for _, wk in pairs({"wear_h", "wear_p"}) do
            if istable(cfg[wk]) then
                san[wk] = {}
                san[wk].scale = san_scale(cfg[wk].scale, itmc.wear)
                san[wk].pos = san_pos(cfg[wk].pos, itmc.wear)

                if isangle(cfg[wk].ang) then
                    san[wk].ang = Angle(math.Clamp(cfg[wk].ang.x, -180, 180), math.Clamp(cfg[wk].ang.y, -180, 180), math.Clamp(cfg[wk].ang.z, -180, 180))
                end

                if isstring(cfg[wk].attach) and SS_Attachments[cfg[wk].attach] then
                    san[wk].attach = cfg[wk].attach
                end
            end
        end
    end

    if itmc.scale then
        san.scale_h = san_scale(cfg.scale_h, itmc.scale)
        san.scale_p = san_scale(cfg.scale_p, itmc.scale)
    end

    if itmc.pos then
        san.pos_h = san_pos(cfg.pos_h, itmc.pos)
        san.pos_p = san_pos(cfg.pos_p, itmc.pos)
    end

    if itmc.bone then
        san.bone_h = isstring(cfg.bone_h) and string.sub(cfg.bone_h, 1, 50)
        san.bone_p = isstring(cfg.bone_p) and string.sub(cfg.bone_p, 1, 50)
    end

    if itmc.scale_children then
        san.scale_children_h = cfg.scale_children_h and true
        san.scale_children_p = cfg.scale_children_p and true
    end

    return san
end
