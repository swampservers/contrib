-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
local Player = FindMetaTable('Player')

SS_Layout = SS_Layout or {}
SS_Products = SS_Products or {}


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