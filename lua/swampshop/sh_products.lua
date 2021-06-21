-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
local Player = FindMetaTable('Player')
SS_Products = SS_Products or {}

function SS_Product(product)
    assert(product.price)
    product.SS_Product_CannotBuy = product.CannotBuy or function() end

    function product:CannotBuy(ply)
        if ply.SQLCreatingItem then return "Database lock, try again." end

        return product:SS_Product_CannotBuy(ply) or (not ply:SS_HasPoints(self.price) and SS_CANNOTBUY_AFFORD)
    end

    assert(product.OnBuy)
    product.SS_Product_OnBuy = product.OnBuy

    function product:OnBuy(ply)
        local function finish_buy()
            self:SS_Product_OnBuy(ply)
            ply:Notify('Bought ', self.name, ' for ', self.price, ' points')
        end

        if self.price > 0 then
            ply:SS_TakePoints(self.price, finish_buy)
        else
            finish_buy()
        end
    end

    if product.model then
        util.PrecacheModel(product.model)

        if product.workshop then
            register_workshop_model(product.model, product.workshop)
        end
    end

    local tab = _SS_TABADDTARGET.layout
    table.insert(tab[#tab].products, product)
    SS_Products[product.class] = product
end

function SS_ItemProduct(item)
    local product = item --TODO maybe only copy needed keys
    product.keepnotice = "This " .. ((product.price or 0) == 0 and "item" or "purchase") .. " is kept forever unless you " .. ((product.price or 0) == 0 and "return" or "sell") .. " it."

    function product:GenerateItem(ply)
        local item = SS_MakeItem(ply, {
            class = self.class,
            id = -1,
            cfg = {},
            eq = true,
        })

        item:Sanitize()

        return item
    end

    product.sample_item = product:GenerateItem(SS_SAMPLE_ITEM_OWNER)

    function product:CannotBuy(ply)
        local maxcount = (self.accessory_slot and ply:SS_AccessorySlots() * (self.perslot or 1)) or self.maxowned or 1
        if ply:SS_CountItem(self.class) >= maxcount then return self.accessory_slot and "Buy more accessory slots (in Upgrades) first." or (maxcount > 1 and SS_CANNOTBUY_OWNEDMULTI or SS_CANNOTBUY_OWNED) end
    end

    function product:OnBuy(ply)
        ply:SS_GiveItem(self:GenerateItem(ply))
    end

    SS_Product(product)
end

function SS_WeaponProduct(product)
    product.SS_WeaponProduct_OnBuy = product.OnBuy or function() end

    function product:OnBuy(ply)
        if(!ply:HasWeapon(self.Class) )then
            ply:Give(self.class)
            self:SS_WeaponProduct_OnBuy(ply)
        else
            ply:SelectWeapon(self.class)
        end
    end
    function product:CannotBuy(ply)
        return !ply:Alive() and "You're dead!"
    end
    SS_DeathKeepnotice(product)
    SS_Product(product)
end

function SS_WeaponAndAmmoProduct(product)
    function product:OnBuy(ply)
        if not ply:HasWeapon(self.class) then
            local wep = ply:Give(self.class)
            
            if(self.amount)then --ensure the player has at least this many ammo when giving a new one to them. Otherwise, give them whatever is standard.
                local ammotype = self.ammotype or game.GetAmmoName(wep:GetPrimaryAmmoType())
                local curammo = ply:GetAmmoCount(self.ammotype)
                ply:SetAmmo(math.max(curammo,self.amount),ammotype)
            end
        else
            local wep = ply:GetWeapon(self.class)
            local ammotype = self.ammotype or game.GetAmmoName(wep:GetPrimaryAmmoType())
            local ammogive = self.amount or (wep.Primary and wep.Primary.DefaultClip) or wep:GetMaxClip1() or 0

            if (ammotype and ammogive > 0) then
                ply:GiveAmmo(ammogive, ammotype)
            end
        end
        ply:SelectWeapon(self.class)
    end
    function product:CannotBuy(ply)
        if !ply:Alive() then return "You're dead!" end
        if (ply:HasWeapon(self.class)) then
            local wep = ply:GetWeapon(self.class)
            local ammotype = self.ammotype or (game.GetAmmoName(wep:GetPrimaryAmmoType()))
            local ammogive = self.amount or (wep.Primary and wep.Primary.DefaultClip) or wep:GetMaxClip1() or 0
            local fail = assert(ammotype != nil and ammogive > 0,"shop purchase could not refill" .. ply:Nick() .. "'s "..self.class.." with ".. ammogive .." of "..(ammotype or "<nil ammotype>") ,true)
            if(fail)then return "Error!" end 
            
            --i am not sure if i am using this correctly
            local limit = self.maxammo or game.GetAmmoMax(game.GetAmmoID(ammotype)) or 0
            if (limit != 0 and ply:GetAmmoCount(ammotype) >= limit) then return "You can't carry any more of this ammo" end
        end
    end
    SS_DeathKeepnotice(product)
    SS_Product(product)
end

function SS_AmmoProduct(product)
    product.class = "ammo_" .. product.ammotype .. "_" .. tostring(product.amount)

    function product:OnBuy(ply)
        ply:GiveAmmo(self.amount, self.ammotype)
    end

    SS_DeathKeepnotice(product)
    SS_Product(product)
end

function SS_UniqueModelProduct(product)
    product.price = product.price or 0
    product.playermodel = true
    product.SS_UniqueModelProduct_CannotBuy = product.CannotBuy or function() end

    function product:CannotBuy(ply)
        local s = self:SS_UniqueModelProduct_CannotBuy(ply)
        if s then return s end

        for k, v in pairs(player.GetAll()) do
            if v:GetNWString("uniqmodl") == self.name and v:Alive() then return v == ply and SS_CANNOTBUY_OWNED or (v:Nick() .. " is using this - kill them.") end
        end
    end

    product.SS_UniqueModelProduct_OnBuy = product.OnBuy or function() end

    function product:OnBuy(ply)
        ply:SetNWString("uniqmodl", self.name)
        ply:SetModel(self.model)
        self:SS_UniqueModelProduct_OnBuy(ply)
    end

    SS_DeathKeepnotice(product)
    SS_Product(product)
end

SS_CANNOTBUY_AFFORD = "You can't afford this."
SS_CANNOTBUY_OWNED = "You already own this."
SS_CANNOTBUY_OWNEDMULTI = "You own the maximum number of these."

-- SS_BUYSTATUS_OK = 0
-- SS_BUYSTATUS_AFFORD = 1
-- SS_BUYSTATUS_OWNED = 2
-- SS_BUYSTATUS_OWNED_MULTI = 3
-- SS_BUYSTATUS_SLOTS = 4
-- SS_BUYSTATUS_TAKEN = 5
-- SS_BUYSTATUS_PRIVATETHEATER = 6
-- SS_BUYSTATUS_CANTBUILD = 7
-- SS_BUYSTATUS_PONYONLY = 8
-- SS_BUYSTATUS_PREVIOUS_SLOTS = 9
-- SS_BuyStatusMessage = {"You can't afford this.", "You already own this.", "You own the maximum number of these.", "Buy more accessory slots (in Upgrades) first.", "Someone else is using this - kill them.", "You must own a private theater to use this.", "You can't build here.", "You must own the ponymodel to buy this.", "Buy the previous slots to unlock this one."}
function SS_DeathKeepnotice(product)
    product.keepnotice = "This " .. ((product.price or 0) == 0 and "item" or "purchase") .. " will be lost if you die or log out."
end