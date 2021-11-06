-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
local Player = FindMetaTable('Player')
SS_Items = SS_Items or {}
-- this is not used as a table, it is just a unique value
SS_SAMPLE_ITEM_OWNER = SS_SAMPLE_ITEM_OWNER or {}

function SS_SanitizeVector(val, min, max)
    return isvector(val) and val:Clamp(min, max) or nil
end

function SS_SanitizeColor(val)
    return SS_SanitizeVector(val, Vector(0, 0, 0), Vector(5, 5, 5))
end

function SS_SanitizeImgur(imgur)
    local url = istable(imgur) and SanitizeImgurId(imgur.url)

    return url and {
        url = url
    } or nil
end

-- SS_ITEM_META = {
--     __index = function(t, k) return t[k] or t.cfg[k]  or t.class[k] end, --or t.spec[k]
--     __newindex = function(t, k, v) end
-- }
-- convert sql loaded data, or network data, to item
-- still needs to be sanitized on server, left out of here to deal with prop slots
function SS_MakeItem(ply, itemdata)
    local class = SS_Items[itemdata.class] or SS_Items["unknown"]
    -- if not class then
    --     print("Unknown item", itemdata.class)
    --     return
    -- end
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


function SS_WeaponBlueprintItem(item)
    item.CraftingPrice = function(self) return 5000 end

    item.actions = {
        {
            name = "craft",
            text = function(self) return "Craft - " .. tostring(self:CraftingPrice()) .. " points" end,
            server = function(self)
                if self.owner:HasWeapon(self.class) then
                    self.owner:SelectWeapon(self.class)
                else
                    self.owner:SS_TryTakePoints(self:CraftingPrice(), function()
                        self.owner:Give(self.class)
                        self.owner:SelectWeapon(self.class)
                    end)
                end
            end
        }
    }

    item.invcategory = "Blueprints"
    SS_Item(item)
end

--NOMINIFY
--todo move this
function SS_ItemOrProduct(iop)
    if CLIENT then
        -- gets called twice by item/product, needs fixing...
        if not iop.GetNameUncached then
            iop.GetNameUncached = iop.GetName or function(self) return self.name end

            --called a lot by the ordering thing
            function iop:GetName()
                local fn = FrameNumber()

                if self._namecacheframe ~= fn then
                    self._namecacheframe = fn
                    self._namecache = self:GetNameUncached()
                end

                return self._namecache
            end
        end
    else
        iop.GetName = iop.GetName or function(self) return self.name end
    end

    iop.GetDescription = iop.GetDescription or function(self) return self.description end
    iop.GetModel = iop.GetModel or function(self) return self.model end
end

function SS_ClientsideFakeItem(item)
    if SERVER then return end
    item.clientside_fake = true
    SS_Item(item)
end

--ITEMS are stuff that is saved in the database
function SS_Item(item)
    item.ScaleLimitOffset = item.ScaleLimitOffset or function() return 1 end

    function item:Sanitize()
        local changed = false

        if self.SanitizeCfg then
            local dirty_cfg = {}

            for k, v in pairs(self.cfg) do
                dirty_cfg[k] = v
            end

            table.Empty(self.cfg)
            changed = changed or self:SanitizeCfg(dirty_cfg)
        else
            _SS_SanitizeConfig(self)
        end

        if self.owner ~= SS_SAMPLE_ITEM_OWNER and self.eq and self:CannotEquip() then
            changed = true
            self.eq = false
        end

        if self.SanitizeSpecs then
            changed = changed or self:SanitizeSpecs()
        end

        return changed
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

            if table.Count(urls) > 5 then return "You can only equip 5 different imgur materials at once." end
        end
    end

    function item:ShouldShow()
        return self.eq
    end

    if not item.SellValue then
        -- naming it "price" triggers making a product for it below, should probably always call it price and have a special key for unlisted items
        local value = item.value or item.price
        assert(value and value >= 0, "Price or value is needed")
        item.SellValue = function(self) return math.floor((self.specs.value or value) * 0.8) end
    end

    -- item.HoverText = item.HoverText or function(self, second) return second and (self.eq and "HOLSTER" or "EQUIP") or nil end
    -- item.HoverClick = item.HoverClick or function(self, second)
    --     if second then
    --         local status = (not self.eq) and self:CannotEquip() or nil
    --         if status then
    --             surface.PlaySound("common/wpn_denyselect.wav")
    --             LocalPlayerNotify(status)
    --         else
    --             surface.PlaySound("weapons/smg1/switch_single.wav")
    --             SS_EquipItem(self.id, not self.eq)
    --         end
    --     end
    -- end
    -- setup actions
    item.actions = item.actions or {}

    -- Default actions
    if not item.never_equip then
        item.actions.equip = {
            primary = true,
            Text = function(item) return item.eq and "HOLSTER" or "EQUIP" end,
            Cannot = function(item) return not item.eq and item:CannotEquip() end,
        }
    end

    if item.settings or item.SetupCustomizer then
        item.actions.configure = {
            sort = -1,
            Text = function() return "Customize" end,
            OnClient = function(item)
                SS_CustomizerPanel:OpenItem(item)
            end
        }
        -- if SS_CustomizerPanel:IsVisible() then
        --     SS_CustomizerPanel:Close()
        -- else
        --     SS_CustomizerPanel:Open(item)
        -- end
    end

    if not item.clientside_fake then
        item.actions.auction = {
            sort = -2,
            Text = function(item, args) return "Auction" end,
            OnClient = function(item)
                -- if LocalPlayer():SteamID() ~= "STEAM_0:0:38422842" then return end
                SS_OpenAuctionWindow(item)
            end
        }

        item.actions.sell = {
            sort = -3,
            Text = function(item, args) return SS_SELLCONFIRMID == item.id and "CONFIRM?" or "Recycle for " .. tostring(item:SellValue()) .. " points" end,
            OnClient = function(item)
                if SS_SELLCONFIRMID == item.id then
                    SS_ItemServerAction(item.id, "sell")
                else
                    SS_SELLCONFIRMID = item.id
                end
            end
        }
    end

    -- Default action functions
    for id, v in pairs(item.actions) do
        if not v.OnClient then
            local act = id

            v.OnClient = function(item)
                SS_ItemServerAction(item.id, act)
            end
        end

        if SERVER then
            v.OnServer = v.OnServer or SS_ServerActions[id]
        end

        v.Cannot = v.Cannot or function() end

        if v.primary then
            item.primaryaction = v
        end

        v.id = id
    end

    item.GetActions = item.GetActions or function(self) return self.actions end
    item.GetSettings = item.GetSettings or function(self) return self.settings end
    SS_ItemOrProduct(item)
    item.__index = item
    SS_Items[item.class] = item

    if item.price then
        SS_ItemProduct(item)
    end
end

--todo remove
function _SS_SanitizeConfig(item)
    local cfg = item.cfg
    local itmc = item:GetSettings()
    if not itmc then return end
    local dirty_cfg = {}

    for k, v in pairs(cfg) do
        dirty_cfg[k] = v
    end

    table.Empty(cfg)

    if itmc.color then
        cfg.color = SS_SanitizeVector(dirty_cfg.color, Vector(0, 0, 0), Vector(itmc.color.max, itmc.color.max, itmc.color.max))
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
            local scaleoffset = item:ScaleLimitOffset()

            local tab = {
                pos = SS_SanitizeVector(curr.pos, itmc.wear.pos.min, itmc.wear.pos.max),
                scale = SS_SanitizeVector(curr.scale, itmc.wear.scale.min * scaleoffset, itmc.wear.scale.max * scaleoffset),
                ang = isangle(curr.ang) and Angle(math.Clamp(curr.ang.x, -180, 180), math.Clamp(curr.ang.y, -180, 180), math.Clamp(curr.ang.z, -180, 180)) or nil,
                attach = isstring(curr.attach) and SS_Attachments[curr.attach] and curr.attach or nil,
            }

            -- makes sure there is always a scale written so we dont have overside objects
            if item.class == "accessory" then
                tab.scale = tab.scale or Vector(scaleoffset, scaleoffset, scaleoffset)
            end

            cfg[wk] = table.Count(tab) > 0 and tab or nil
        end
    end

    if itmc.scale then
        cfg.scale_h = SS_SanitizeVector(dirty_cfg.scale_h, itmc.scale.min, itmc.scale.max)
        cfg.scale_p = SS_SanitizeVector(dirty_cfg.scale_p, itmc.scale.min, itmc.scale.max)
    end

    if itmc.pos then
        cfg.pos_h = SS_SanitizeVector(dirty_cfg.pos_h, itmc.pos.min, itmc.pos.max)
        cfg.pos_p = SS_SanitizeVector(dirty_cfg.pos_p, itmc.pos.min, itmc.pos.max)
    end

    if itmc.bone then
        cfg.bone_h = isstring(dirty_cfg.bone_h) and string.sub(dirty_cfg.bone_h, 1, 50) or nil
        cfg.bone_p = isstring(dirty_cfg.bone_p) and string.sub(dirty_cfg.bone_p, 1, 50) or nil
    end

    if itmc.scale_children then
        cfg.scale_children_h = dirty_cfg.scale_children_h and true or nil
        cfg.scale_children_p = dirty_cfg.scale_children_p and true or nil
    end

    if itmc.submaterial then
        cfg.submaterial = isnumber(dirty_cfg.submaterial) and math.Clamp(math.floor(dirty_cfg.submaterial), 0, 31) or nil
    end
end
