-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
include("net_hd.lua")
include("config.lua")
SS_Layout = SS_Layout or {}
SS_Products = SS_Products or {}
SS_Items = SS_Items or {}

-- add custom paint funcs here
function SS_Tab(name, icon)
    _SS_TABADDTARGET = nil

    for _, tab in pairs(SS_Layout) do
        if tab.name == name then
            _SS_TABADDTARGET = tab
        end
    end

    if _SS_TABADDTARGET == nil then
        table.insert(SS_Layout, {})
        _SS_TABADDTARGET = SS_Layout[#SS_Layout]
    end

    _SS_TABADDTARGET.name = name
    _SS_TABADDTARGET.icon = icon

    _SS_TABADDTARGET.layout = {
        {
            name = "",
            products = {}
        }
    }
end

function SS_Heading(title)
    table.insert(_SS_TABADDTARGET.layout, {
        title = title,
        products = {}
    })
end

function SS_Product(product)
    local tab = _SS_TABADDTARGET.layout
    table.insert(tab[#tab].products, product.class)
    product.price = product.price or 0
    SS_Products[product.class] = product

    if product.model then
        util.PrecacheModel(product.model)

        if product.workshop then
            register_workshop_model(product.model, product.workshop)
        end
    end
end

function SS_AngleGen(func)
    local ang = Angle()
    func(ang)

    return ang
end

function SS_ProductlessItem(item)
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
            for k, v in ipairs(ply.SS_EQItems) do
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

    SS_Items[item.class] = item
    product = item
    product.keepnotice = "This " .. ((item.price or 0) == 0 and "item" or "purchase") .. " is kept forever unless you " .. ((item.price or 0) == 0 and "return" or "sell") .. " it."

    function product:OnBuy(ply)
        ply:SS_GiveItem(self.class)
        net.Start("SS_PointOutInventory")
        net.Send(ply)
    end

    SS_Product(product)
end

function SS_DeathKeepnotice(product)
    product.keepnotice = "This " .. ((product.price or 0) == 0 and "item" or "purchase") .. " will be lost if you die or log out."
end

function SS_WeaponProduct(product)
    --[[	wt = weapons.GetStored(product.class)
	if wt and wt.WorldModel then
		product.model = wt.WorldModel
	end ]]
    product.OnBuyOrig = product.OnBuy
    SS_DeathKeepnotice(product)

    function product:OnBuy(ply)
        ply:Give(self.class)
        ply:SelectWeapon(self.class)

        if self.OnBuyOrig then
            self:OnBuyOrig(ply)
        end
    end

    SS_Product(product)
end

function SS_WeaponAndAmmoProduct(product)
    SS_DeathKeepnotice(product)

    function product:OnBuy(ply)
        if not ply:HasWeapon(self.class) then
            ply:Give(self.class)
            local wep = ply:GetWeapon(self.class)

            if wep:Clip1() > 0 then
                wep:SetClip1(0)
            end

            ply:SetAmmo(self.amount, self.ammotype)
        else
            ply:GiveAmmo(self.amount, self.ammotype)
        end

        ply:SelectWeapon(self.class)
    end

    SS_Product(product)
end

function SS_AmmoProduct(product)
    product.class = "ammo_" .. product.ammotype .. "_" .. tostring(product.amount)
    SS_DeathKeepnotice(product)

    function product:OnBuy(ply)
        ply:GiveAmmo(self.amount, self.ammotype)
    end

    SS_Product(product)
end

function SS_UniqueModelProduct(product)
    product.playermodel = true
    product.CanBuyStatusOrig = product.CanBuyStatus
    product.OnBuyOrig = product.OnBuy

    function product:CanBuyStatus(ply)
        if self.CanBuyStatusOrig then
            local s = self:CanBuyStatusOrig(ply) or SS_BUYSTATUS_OK
            if s ~= SS_BUYSTATUS_OK then return s end
        end

        for k, v in pairs(player.GetAll()) do
            if v:GetNWString("uniqmodl") == self.name and v:Alive() then return v == ply and SS_BUYSTATUS_OWNED or SS_BUYSTATUS_TAKEN end
        end

        return SS_BUYSTATUS_OK
    end

    SS_DeathKeepnotice(product)

    function product:OnBuy(ply)
        ply:SetNWString("uniqmodl", self.name)
        ply:SetModel(self.model)

        if self.OnBuyOrig then
            self:OnBuyOrig(ply)
        end
    end

    SS_Product(product)
end

function SS_Initialize()
    local files, _ = file.Find('swampshop/tabs/*', 'LUA')
    table.sort(files)

    for _, name in pairs(files) do
        AddCSLuaFile('swampshop/tabs/' .. name)
        include('swampshop/tabs/' .. name)
    end
end

local Player = FindMetaTable('Player')

function Player:SS_GetDonation()
    return self.SS_Donation or 0
end

function Player:SS_GetPoints()
    return self.SS_Points or 0
end

function Player:SS_HasPoints(points)
    return (self.SS_Points or 0) >= points
end

SS_BUYSTATUS_OK = 0
SS_BUYSTATUS_AFFORD = 1
SS_BUYSTATUS_OWNED = 2
SS_BUYSTATUS_OWNED_MULTI = 3
SS_BUYSTATUS_SLOTS = 4
SS_BUYSTATUS_TAKEN = 5
SS_BUYSTATUS_PRIVATETHEATER = 6
SS_BUYSTATUS_CANTBUILD = 7
SS_BUYSTATUS_PONYONLY = 8
SS_BUYSTATUS_PREVIOUS_SLOTS = 9

SS_BuyStatusMessage = {"You can't afford this.", "You already own this.", "You own the maximum number of these.", "Buy more accessory slots (in Upgrades) first.", "Someone else is using this - kill them.", "You must own a private theater to use this.", "You can't build here.", "You must own the ponymodel to buy this.", "Buy the previous slots to unlock this one."}

function Player:SS_CanBuyStatus(product)
    local buycode = SS_BUYSTATUS_OK

    if product.CanBuyStatus then
        buycode = product:CanBuyStatus(self) or SS_BUYSTATUS_OK
    end

    if buycode == SS_BUYSTATUS_OK then
        if not self:SS_HasPoints(product.price) then
            buycode = SS_BUYSTATUS_AFFORD
        end

        local maxcount = (product.accessory_slot and self:SS_AccessorySlots() * (product.perslot or 1)) or product.maxowned or 1

        if self:SS_CountItem(product.class) >= maxcount then
            buycode = product.accessory_slot and SS_BUYSTATUS_SLOTS or (maxcount > 1 and SS_BUYSTATUS_OWNED_MULTI or SS_BUYSTATUS_OWNED)
        end
    end

    return buycode
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

function Player:SS_FindItem(item_id)
    for k, v in ipairs(self.SS_Items or {}) do
        if v.id == item_id then return k end
    end

    return false
end

function Player:SS_HasItem(item_class)
    for k, v in ipairs(self.SS_Items or {}) do
        if v.class == item_class then return true end
    end

    return false
end

function Player:SS_CountItem(item_class)
    local c = 0

    for k, v in ipairs(self.SS_Items or {}) do
        if v.class == item_class then
            c = c + 1
        end
    end

    return c
end

function Player:SS_AccessorySlots()
    local c = 1

    for k, v in ipairs(self.SS_Items or {}) do
        if v.class:StartWith("accslot_") then
            c = c + 1
        end
    end

    return c
end